package com.talaqqihub.dao;

import com.talaqqihub.model.Evaluation;
import util.TalaqqiSchemaUtil;
import java.sql.*;
import java.util.*;

/**
 * TeacherEvaluationDAO Class
 * Handles database operations for teacher evaluations
 */
public class TeacherEvaluationDAO {
    
    private Connection connection;
    private String lastError;

    public TeacherEvaluationDAO(Connection connection) {
        this.connection = connection;
    }

    public String getLastError() {
        return lastError != null ? lastError : "";
    }

    /**
     * Ensure studentevaluation table exists with columns required by the teacher portal.
     */
    public void ensureStudentEvaluationSchema() {
        String ddl =
            "CREATE TABLE IF NOT EXISTS studentevaluation ("
            + "studentEvaluationId VARCHAR(10) NOT NULL PRIMARY KEY, "
            + "studentId VARCHAR(50) NOT NULL, "
            + "teacherId VARCHAR(50) NOT NULL, "
            + "sessionId VARCHAR(50) DEFAULT NULL, "
            + "class_name VARCHAR(100) DEFAULT NULL, "
            + "surah VARCHAR(100) DEFAULT NULL, "
            + "ayah_range VARCHAR(50) DEFAULT NULL, "
            + "session_date DATE DEFAULT NULL, "
            + "start_time TIME DEFAULT NULL, "
            + "end_time TIME DEFAULT NULL, "
            + "tajweedScore FLOAT DEFAULT 0, "
            + "fluencyScore FLOAT DEFAULT 0, "
            + "accuracyScore FLOAT DEFAULT 0, "
            + "overall_score FLOAT DEFAULT 0, "
            + "rating INT DEFAULT 0, "
            + "strength TEXT, "
            + "areas_for_improvement TEXT, "
            + "performance_tag VARCHAR(50) DEFAULT NULL, "
            + "next_target_surah VARCHAR(100) DEFAULT NULL, "
            + "suggestions TEXT, "
            + "teacher_comments TEXT, "
            + "status VARCHAR(20) DEFAULT 'PENDING', "
            + "weakness TEXT, "
            + "studentImprovements TEXT, "
            + "nextTarget VARCHAR(255) DEFAULT NULL, "
            + "comments TEXT, "
            + "createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
            + "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, "
            + "KEY idx_teacherId (teacherId), "
            + "KEY idx_studentId (studentId), "
            + "KEY idx_sessionId (sessionId), "
            + "KEY idx_status (status)"
            + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";

        try (Statement stmt = connection.createStatement()) {
            stmt.execute(ddl);
        } catch (SQLException e) {
            setError("Unable to ensure studentevaluation schema", e);
        }
    }

    private void clearError() {
        lastError = null;
    }

    private void setError(String message, SQLException e) {
        lastError = message;
        System.err.println("[TeacherEvaluationDAO] " + message);
        if (e != null) {
            e.printStackTrace();
        }
    }

    /**
     * Insert or update an evaluation depending on existing session/ID records.
     */
    public boolean saveEvaluation(Evaluation evaluation) {
        clearError();

        String teacherIdStr = resolveTeacherId(evaluation);
        evaluation.setTeacherId(teacherIdStr);

        if (evaluation.getEvaluationId() > 0) {
            if (updateEvaluation(evaluation)) {
                return true;
            }
            Evaluation existing = findBySessionAndTeacher(evaluation.getSessionId(), teacherIdStr);
            if (existing != null) {
                evaluation.setEvaluationId(existing.getEvaluationId());
                return updateEvaluation(evaluation);
            }
            return insertEvaluation(evaluation);
        }

        Evaluation existing = findBySessionAndTeacher(evaluation.getSessionId(), teacherIdStr);
        if (existing != null) {
            evaluation.setEvaluationId(existing.getEvaluationId());
            return updateEvaluation(evaluation);
        }

        return insertEvaluation(evaluation);
    }

    private Evaluation findBySessionAndTeacher(String sessionId, String teacherId) {
        if (sessionId == null || sessionId.trim().isEmpty()
                || teacherId == null || teacherId.trim().isEmpty()) {
            return null;
        }

        String query = "SELECT studentEvaluationId FROM studentevaluation WHERE sessionId = ? AND teacherId = ? LIMIT 1";
        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setString(1, sessionId.trim());
            stmt.setString(2, teacherId.trim());
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Evaluation evaluation = new Evaluation();
                    String evalId = rs.getString("studentEvaluationId");
                    if (evalId != null && !evalId.isEmpty()) {
                        String numericOnly = evalId.replaceAll("[^0-9]", "");
                        if (!numericOnly.isEmpty()) {
                            evaluation.setEvaluationId(Integer.parseInt(numericOnly));
                        }
                    }
                    evaluation.setSessionId(sessionId.trim());
                    evaluation.setTeacherId(teacherId.trim());
                    return evaluation;
                }
            }
        } catch (SQLException e) {
            setError("Unable to look up existing evaluation for session " + sessionId, e);
        }

        return null;
    }

    /**
     * Get dashboard summary statistics for a teacher (String ID version)
     * @param teacherId The teacher's ID (String, e.g., "T001")
     * @return A map containing summary statistics
     */
    public Map<String, Object> getDashboardSummary(String teacherId) {
        Map<String, Object> summary = new HashMap<>();
        summary.put("totalStudentsEvaluated", 0);
        summary.put("totalSessionsEvaluated", 0);
        summary.put("avgOverallScore", 0.0);
        summary.put("avgTajweedScore", 0.0);
        summary.put("avgFluencyScore", 0.0);
        summary.put("avgAccuracyScore", 0.0);

        String query = "SELECT " +
            "COUNT(DISTINCT studentId) as total_students_evaluated, " +
            "COUNT(*) as total_sessions_evaluated, " +
            "AVG(overall_score) as avg_overall_score, " +
            "AVG(tajweedScore) as avg_tajweed_score, " +
            "AVG(fluencyScore) as avg_fluency_score, " +
            "AVG(accuracyScore) as avg_accuracy_score " +
            "FROM studentevaluation " +
            "WHERE teacherId = ? AND UPPER(COALESCE(status, '')) = 'COMPLETED'";

        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setString(1, teacherId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                summary.put("totalStudentsEvaluated", rs.getInt("total_students_evaluated"));
                summary.put("totalSessionsEvaluated", rs.getInt("total_sessions_evaluated"));
                summary.put("avgOverallScore", Math.round(rs.getDouble("avg_overall_score") * 100.0) / 100.0);
                summary.put("avgTajweedScore", Math.round(rs.getDouble("avg_tajweed_score") * 100.0) / 100.0);
                summary.put("avgFluencyScore", Math.round(rs.getDouble("avg_fluency_score") * 100.0) / 100.0);
                summary.put("avgAccuracyScore", Math.round(rs.getDouble("avg_accuracy_score") * 100.0) / 100.0);
            }
        } catch (SQLException e) {
            setError("Unable to load evaluation summary", e);
        }

        return summary;
    }

    /**
     * Get pending evaluations for a teacher (from evaluation_session_feedback table)
     * Pending = Student has submitted feedback (studentRating IS NOT NULL) but teacher hasn't evaluated yet (teacherRating IS NULL)
     * @param teacherId The teacher's ID (String)
     * @return List of pending evaluations
     */
    public List<Evaluation> getPendingEvaluations(String teacherId) {
        List<Evaluation> evaluations = new ArrayList<>();
        String createdCol = TalaqqiSchemaUtil.studentEvalCreatedColumn(connection, "se");
        String query = buildEvaluationListSelectSql() +
            "WHERE se.teacherId = ? AND UPPER(COALESCE(se.status, 'PENDING')) = 'PENDING' " +
            "ORDER BY COALESCE(NULLIF(se.session_date, ''), DATE_FORMAT(ts.sessionDate, '%Y-%m-%d'), DATE_FORMAT(cs.scheduleDate, '%Y-%m-%d'), '') DESC, " +
            createdCol + " DESC";

        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setString(1, teacherId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                evaluations.add(mapResultSetToEvaluation(rs));
            }
        } catch (SQLException e) {
            setError("Unable to load pending evaluations", e);
            evaluations.addAll(getPendingEvaluationsFallback(teacherId));
        }

        return evaluations;
    }

    /**
     * Get completed evaluations for a teacher with search, filter, and sort
     * @param teacherId The teacher's ID (String)
     * @param searchTerm Search by student name or surah (optional)
     * @param filterClass Filter by class name (optional)
     * @param sortBy Sort option: "newest" (default), "oldest", "best", "lowest"
     * @return List of completed evaluations
     */
    public List<Evaluation> getCompletedEvaluations(String teacherId, String searchTerm, String filterClass, String sortBy) {
        List<Evaluation> evaluations = new ArrayList<>();

        StringBuilder query = new StringBuilder(buildEvaluationListSelectSql());
        query.append("WHERE se.teacherId = ? AND UPPER(COALESCE(se.status, '')) = 'COMPLETED'");

        // Add search filter
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            query.append(" AND (s.studentName LIKE ? OR se.surah LIKE ?)");
        }

        // Add class filter
        if (filterClass != null && !filterClass.trim().isEmpty()) {
            query.append(" AND se.class_name = ?");
        }

        // Add sorting
        if ("oldest".equals(sortBy)) {
            query.append(" ORDER BY se.session_date ASC");
        } else if ("best".equals(sortBy)) {
            query.append(" ORDER BY se.overall_score DESC");
        } else if ("lowest".equals(sortBy)) {
            query.append(" ORDER BY se.overall_score ASC");
        } else {
            query.append(" ORDER BY se.session_date DESC"); // default: newest
        }

        try (PreparedStatement stmt = connection.prepareStatement(query.toString())) {
            int paramIndex = 1;
            stmt.setString(paramIndex++, teacherId);

            if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                String searchPattern = "%" + searchTerm + "%";
                stmt.setString(paramIndex++, searchPattern);
                stmt.setString(paramIndex++, searchPattern);
            }

            if (filterClass != null && !filterClass.trim().isEmpty()) {
                stmt.setString(paramIndex++, filterClass);
            }

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                try {
                    evaluations.add(mapResultSetToEvaluation(rs));
                } catch (SQLException e) {
                    System.err.println("Error mapping evaluation row: " + e.getMessage());
                    e.printStackTrace();
                }
            }
        } catch (SQLException e) {
            setError("Unable to load completed evaluations", e);
        }

        return evaluations;
    }

    /**
     * Get a specific evaluation by ID
     * @param evaluationId The evaluation ID
     * @return Evaluation object or null if not found
     */
    public Evaluation getEvaluationById(int evaluationId) {
        String query = "SELECT * FROM studentevaluation WHERE studentEvaluationId = ?";
        
        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            // Convert evaluation ID to string format "SE00X"
            String evalIdStr = (evaluationId > 0) ? "SE" + String.format("%03d", evaluationId) : "SE001";
            stmt.setString(1, evalIdStr);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToEvaluation(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Insert a new evaluation record
     * @param evaluation The evaluation object to insert
     * @return true if successful, false otherwise
     */
    public boolean insertEvaluation(Evaluation evaluation) {
        clearError();

        String studentIdStr = resolveStudentId(evaluation);
        if (studentIdStr == null || studentIdStr.trim().isEmpty()) {
            setError("Student ID is missing. Please reopen the evaluation form.", null);
            return false;
        }

        String createdColumn = TalaqqiSchemaUtil.hasColumn(connection, "studentevaluation", "createdAt")
            ? "createdAt" : "created_at";
        String query = "INSERT INTO studentevaluation " +
            "(studentEvaluationId, studentId, teacherId, sessionId, class_name, surah, ayah_range, session_date, " +
            "start_time, end_time, tajweedScore, fluencyScore, accuracyScore, overall_score, rating, strength, " +
            "areas_for_improvement, performance_tag, next_target_surah, suggestions, teacher_comments, status, " +
            "weakness, studentImprovements, nextTarget, comments, " + createdColumn + ") " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            String evalIdStr = resolveEvaluationId(evaluation);
            String teacherIdStr = resolveTeacherId(evaluation);
            String sessionId = evaluation.getSessionId();
            if (sessionId == null || sessionId.trim().isEmpty()) {
                sessionId = "";
            }

            stmt.setString(1, evalIdStr);
            stmt.setString(2, studentIdStr);
            stmt.setString(3, teacherIdStr);
            stmt.setString(4, sessionId);
            stmt.setString(5, nullToEmpty(evaluation.getClassName()));
            stmt.setString(6, nullToEmpty(evaluation.getSurah()));
            stmt.setString(7, nullToEmpty(evaluation.getAyahRange()));
            stmt.setString(8, nullToEmpty(evaluation.getSessionDate()));
            stmt.setString(9, nullToEmpty(evaluation.getStartTime()));
            stmt.setString(10, nullToEmpty(evaluation.getEndTime()));
            stmt.setFloat(11, evaluation.getTajweedScore());
            stmt.setFloat(12, evaluation.getFluencyScore());
            stmt.setFloat(13, evaluation.getAccuracyScore());
            stmt.setFloat(14, evaluation.getOverallScore());
            stmt.setInt(15, evaluation.getRating());
            stmt.setString(16, truncate(evaluation.getComments(), 255));
            stmt.setString(17, nullToEmpty(evaluation.getAreasForImprovement()));
            stmt.setString(18, nullToEmpty(evaluation.getPerformanceTag()));
            stmt.setString(19, nullToEmpty(evaluation.getNextTarget()));
            stmt.setString(20, nullToEmpty(evaluation.getSuggestions()));
            stmt.setString(21, nullToEmpty(evaluation.getTeacherComments()));
            stmt.setString(22, nullToEmpty(evaluation.getStatus()));
            stmt.setString(23, truncate(evaluation.getAreasForImprovement(), 255));
            stmt.setString(24, nullToEmpty(evaluation.getSuggestions()));
            stmt.setString(25, nullToEmpty(evaluation.getNextTarget()));
            stmt.setString(26, nullToEmpty(evaluation.getComments()));

            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected <= 0) {
                setError("No evaluation row was created.", null);
            }
            return rowsAffected > 0;
        } catch (SQLException e) {
            if (e.getMessage() != null && e.getMessage().contains("Duplicate entry")) {
                Evaluation existing = findBySessionAndTeacher(evaluation.getSessionId(), resolveTeacherId(evaluation));
                if (existing != null) {
                    evaluation.setEvaluationId(existing.getEvaluationId());
                    return updateEvaluation(evaluation);
                }
            }
            setError("Database error while saving evaluation: " + e.getMessage(), e);
        }

        return false;
    }

    /**
     * Update an existing evaluation record
     * @param evaluation The evaluation object with updated values
     * @return true if successful, false otherwise
     */
    public boolean updateEvaluation(Evaluation evaluation) {
        clearError();

        String query = "UPDATE studentevaluation SET " +
            "studentId = ?, sessionId = ?, class_name = ?, surah = ?, ayah_range = ?, session_date = ?, " +
            "start_time = ?, end_time = ?, tajweedScore = ?, fluencyScore = ?, accuracyScore = ?, " +
            "overall_score = ?, rating = ?, strength = ?, areas_for_improvement = ?, " +
            "performance_tag = ?, next_target_surah = ?, suggestions = ?, teacher_comments = ?, status = ?, " +
            "weakness = ?, studentImprovements = ?, nextTarget = ?, comments = ?, updated_at = NOW() " +
            "WHERE studentEvaluationId = ? AND teacherId = ?";

        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            String evalIdStr = resolveEvaluationId(evaluation);
            String teacherIdStr = resolveTeacherId(evaluation);
            String studentIdStr = resolveStudentId(evaluation);

            stmt.setString(1, studentIdStr);
            stmt.setString(2, nullToEmpty(evaluation.getSessionId()));
            stmt.setString(3, nullToEmpty(evaluation.getClassName()));
            stmt.setString(4, nullToEmpty(evaluation.getSurah()));
            stmt.setString(5, nullToEmpty(evaluation.getAyahRange()));
            stmt.setString(6, nullToEmpty(evaluation.getSessionDate()));
            stmt.setString(7, nullToEmpty(evaluation.getStartTime()));
            stmt.setString(8, nullToEmpty(evaluation.getEndTime()));
            stmt.setFloat(9, evaluation.getTajweedScore());
            stmt.setFloat(10, evaluation.getFluencyScore());
            stmt.setFloat(11, evaluation.getAccuracyScore());
            stmt.setFloat(12, evaluation.getOverallScore());
            stmt.setInt(13, evaluation.getRating());
            stmt.setString(14, truncate(evaluation.getComments(), 255));
            stmt.setString(15, nullToEmpty(evaluation.getAreasForImprovement()));
            stmt.setString(16, nullToEmpty(evaluation.getPerformanceTag()));
            stmt.setString(17, nullToEmpty(evaluation.getNextTarget()));
            stmt.setString(18, nullToEmpty(evaluation.getSuggestions()));
            stmt.setString(19, nullToEmpty(evaluation.getTeacherComments()));
            stmt.setString(20, nullToEmpty(evaluation.getStatus()));
            stmt.setString(21, truncate(evaluation.getAreasForImprovement(), 255));
            stmt.setString(22, nullToEmpty(evaluation.getSuggestions()));
            stmt.setString(23, nullToEmpty(evaluation.getNextTarget()));
            stmt.setString(24, nullToEmpty(evaluation.getComments()));
            stmt.setString(25, evalIdStr);
            stmt.setString(26, teacherIdStr);

            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected <= 0) {
                setError("Evaluation record not found for update. It may belong to another teacher.", null);
            }
            return rowsAffected > 0;
        } catch (SQLException e) {
            setError("Database error while updating evaluation: " + e.getMessage(), e);
        }

        return false;
    }

    private String nullToEmpty(String value) {
        return value != null ? value : "";
    }

    private String truncate(String value, int maxLength) {
        if (value == null) {
            return "";
        }
        return value.length() <= maxLength ? value : value.substring(0, maxLength);
    }

    /**
     * Delete an evaluation record
     * @param evaluationId The evaluation ID
     * @param teacherId The teacher ID (for authorization)
     * @return true if successful, false otherwise
     */
    public boolean deleteEvaluation(int evaluationId, String teacherId) {
        String query = "DELETE FROM studentevaluation WHERE studentEvaluationId = ? AND teacherId = ?";

        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            String evalIdStr = "SE" + String.format("%03d", evaluationId);
            stmt.setString(1, evalIdStr);
            stmt.setString(2, teacherId);

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Completed sessions that still need a teacher evaluation record.
     */
    public List<Evaluation> getPendingSessionsNeedingEvaluation(String teacherId) {
        List<Evaluation> evaluations = new ArrayList<>();
        String ayahRange = TalaqqiSchemaUtil.ayahRangeExpr(connection);
        String query =
            "SELECT DISTINCT cb.bookingId, ts.sessionId, cb.studentId, s.studentName AS student_name, " +
            "cs.className AS class_name, cs.classSurah AS surah, " +
            ayahRange + " AS ayah_range, " +
            "DATE_FORMAT(cs.scheduleDate,'%Y-%m-%d') AS session_date, " +
            "DATE_FORMAT(cs.startTime,'%H:%i:%s') AS start_time, " +
            "DATE_FORMAT(cs.endTime,'%H:%i:%s') AS end_time, " +
            "cs.teacherId " +
            "FROM classbooking cb " +
            "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId " +
            "JOIN student s ON cb.studentId = s.studentId " +
            TalaqqiSchemaUtil.leftJoinSessionToBooking(connection) +
            "WHERE cs.teacherId = ? AND LOWER(cb.bookingStatus) = 'completed' " +
            "AND NOT EXISTS ( " +
            "  SELECT 1 FROM studentevaluation se " +
            "  WHERE se.teacherId = cs.teacherId AND se.studentId = cb.studentId " +
            "  AND ( " +
            "    UPPER(COALESCE(se.status, '')) = 'COMPLETED' " +
            "    OR (ts.sessionId IS NOT NULL AND se.sessionId = ts.sessionId) " +
            "  ) " +
            ") " +
            "ORDER BY cs.scheduleDate DESC, cs.startTime DESC";

        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setString(1, teacherId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Evaluation evaluation = new Evaluation();
                evaluation.setSessionId(rs.getString("sessionId"));
                evaluation.setStudentId(rs.getString("studentId"));
                evaluation.setStudentName(rs.getString("student_name"));
                evaluation.setClassName(rs.getString("class_name"));
                evaluation.setSurah(resolveSurahDisplay(rs.getString("surah")));
                evaluation.setAyahRange(rs.getString("ayah_range"));
                evaluation.setSessionDate(rs.getString("session_date"));
                evaluation.setStartTime(rs.getString("start_time"));
                evaluation.setEndTime(rs.getString("end_time"));
                evaluation.setTeacherId(rs.getString("teacherId"));
                evaluation.setStatus("PENDING");
                evaluations.add(evaluation);
            }
        } catch (SQLException e) {
            setError("Unable to load completed sessions needing evaluation", e);
            evaluations.addAll(getPendingSessionsFallback(teacherId));
        }
        if (evaluations.isEmpty()) {
            evaluations.addAll(getPendingSessionsFallback(teacherId));
        }
        return evaluations;
    }

    /** Completed bookings without evaluation — does not require talaqqisession join. */
    private List<Evaluation> getPendingSessionsFallback(String teacherId) {
        List<Evaluation> evaluations = new ArrayList<>();
        String ayahRange = TalaqqiSchemaUtil.ayahRangeExpr(connection);
        String sessionLookup = TalaqqiSchemaUtil.sql(
            "(SELECT ts2.sessionId FROM talaqqisession ts2 "
                + "WHERE (ts2.bookingId IS NOT NULL AND ts2.bookingId <> '' AND ts2.bookingId = cb.bookingId) "
                + "   OR ((ts2.bookingId IS NULL OR ts2.bookingId = '') AND ts2.scheduleId = cb.scheduleId) "
                + "LIMIT 1)",
            connection);
        String query =
            "SELECT cb.bookingId, " + sessionLookup + " AS sessionId, cb.studentId, "
            + "s.studentName AS student_name, cs.className AS class_name, cs.classSurah AS surah, "
            + ayahRange + " AS ayah_range, "
            + "DATE_FORMAT(cs.scheduleDate,'%Y-%m-%d') AS session_date, "
            + "DATE_FORMAT(cs.startTime,'%H:%i:%s') AS start_time, "
            + "DATE_FORMAT(cs.endTime,'%H:%i:%s') AS end_time, cs.teacherId "
            + "FROM classbooking cb "
            + "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId "
            + "JOIN student s ON cb.studentId = s.studentId "
            + "WHERE cs.teacherId = ? AND LOWER(cb.bookingStatus) = 'completed' "
            + "AND NOT EXISTS ( "
            + "  SELECT 1 FROM studentevaluation se "
            + "  WHERE se.teacherId = cs.teacherId AND se.studentId = cb.studentId "
            + "  AND UPPER(COALESCE(se.status, '')) = 'COMPLETED' "
            + ") "
            + "ORDER BY cs.scheduleDate DESC, cs.startTime DESC";

        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setString(1, teacherId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Evaluation evaluation = new Evaluation();
                    evaluation.setSessionId(rs.getString("sessionId"));
                    evaluation.setStudentId(rs.getString("studentId"));
                    evaluation.setStudentName(rs.getString("student_name"));
                    evaluation.setClassName(rs.getString("class_name"));
                    evaluation.setSurah(resolveSurahDisplay(rs.getString("surah")));
                    evaluation.setAyahRange(rs.getString("ayah_range"));
                    evaluation.setSessionDate(rs.getString("session_date"));
                    evaluation.setStartTime(rs.getString("start_time"));
                    evaluation.setEndTime(rs.getString("end_time"));
                    evaluation.setTeacherId(rs.getString("teacherId"));
                    evaluation.setStatus("PENDING");
                    evaluations.add(evaluation);
                }
            }
        } catch (SQLException e) {
            setError("Fallback pending session query failed", e);
        }
        return evaluations;
    }

    /**
     * Create a PENDING evaluation row when a teacher ends a Talaqqi session (if none exists yet).
     */
    public boolean ensurePendingEvaluationForSession(String sessionId, String teacherId) {
        if (sessionId == null || sessionId.trim().isEmpty()
                || teacherId == null || teacherId.trim().isEmpty()) {
            return false;
        }

        Evaluation existing = findBySessionAndTeacher(sessionId.trim(), teacherId.trim());
        if (existing != null) {
            return true;
        }

        String ayahRange = TalaqqiSchemaUtil.ayahRangeExpr(connection);
        String query =
            "SELECT ts.sessionId, cb.studentId, cs.teacherId, cs.className, " +
            "CAST(cs.classSurah AS CHAR) AS surah, " + ayahRange + " AS ayah_range, " +
            "DATE_FORMAT(cs.scheduleDate,'%Y-%m-%d') AS session_date, " +
            "DATE_FORMAT(cs.startTime,'%H:%i:%s') AS start_time, " +
            "DATE_FORMAT(cs.endTime,'%H:%i:%s') AS end_time, " +
            "s.studentName AS student_name " +
            TalaqqiSchemaUtil.innerSessionBookingSchedule(connection) +
            "LEFT JOIN student s ON cb.studentId = s.studentId " +
            "WHERE ts.sessionId = ? AND cs.teacherId = ?";

        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setString(1, sessionId.trim());
            stmt.setString(2, teacherId.trim());
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    return false;
                }

                Evaluation evaluation = new Evaluation();
                evaluation.setSessionId(rs.getString("sessionId"));
                evaluation.setStudentId(rs.getString("studentId"));
                evaluation.setTeacherId(rs.getString("teacherId"));
                evaluation.setStudentName(rs.getString("student_name"));
                evaluation.setClassName(rs.getString("className"));
                evaluation.setSurah(resolveSurahDisplay(rs.getString("surah")));
                evaluation.setAyahRange(rs.getString("ayah_range"));
                evaluation.setSessionDate(rs.getString("session_date"));
                evaluation.setStartTime(rs.getString("start_time"));
                evaluation.setEndTime(rs.getString("end_time"));
                evaluation.setStatus("PENDING");
                if (insertEvaluation(evaluation)) {
                    return true;
                }
                return insertMinimalPendingEvaluation(evaluation);
            }
        } catch (SQLException e) {
            setError("Unable to create pending evaluation for session " + sessionId, e);
            return false;
        }
    }

    private boolean insertMinimalPendingEvaluation(Evaluation evaluation) {
        String evalIdStr = resolveEvaluationId(evaluation);
        String teacherIdStr = resolveTeacherId(evaluation);
        String studentIdStr = resolveStudentId(evaluation);
        String sessionId = nullToEmpty(evaluation.getSessionId());

        String[] queries = {
            "INSERT INTO studentevaluation (studentEvaluationId, studentId, teacherId, sessionId, status) "
                + "VALUES (?, ?, ?, ?, 'PENDING')",
            "INSERT INTO studentevaluation (studentId, teacherId, sessionId, status) "
                + "VALUES (?, ?, ?, 'PENDING')"
        };

        try (PreparedStatement stmt = connection.prepareStatement(queries[0])) {
            stmt.setString(1, evalIdStr);
            stmt.setString(2, studentIdStr);
            stmt.setString(3, teacherIdStr);
            stmt.setString(4, sessionId);
            if (stmt.executeUpdate() > 0) {
                return true;
            }
        } catch (SQLException e) {
            System.err.println("[TeacherEvaluationDAO] minimal pending insert (with id): " + e.getMessage());
        }

        try (PreparedStatement stmt = connection.prepareStatement(queries[1])) {
            stmt.setString(1, studentIdStr);
            stmt.setString(2, teacherIdStr);
            stmt.setString(3, sessionId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            setError("Unable to create minimal pending evaluation: " + e.getMessage(), e);
            return false;
        }
    }

    private String buildEvaluationListSelectSql() {
        String ayahRange = TalaqqiSchemaUtil.ayahRangeExpr(connection);
        String createdCol = TalaqqiSchemaUtil.studentEvalCreatedColumn(connection, "se");
        String updatedCol = TalaqqiSchemaUtil.studentEvalUpdatedColumn(connection, "se");

        return "SELECT " +
            "se.studentEvaluationId, " +
            "se.studentId, " +
            "COALESCE(s.studentName, '') AS student_name, " +
            "COALESCE(NULLIF(se.class_name, ''), cs.className, '') AS class_name, " +
            "COALESCE(NULLIF(se.surah, ''), CAST(cs.classSurah AS CHAR), '') AS surah, " +
            "COALESCE(NULLIF(se.ayah_range, ''), " + ayahRange + ", '') AS ayah_range, " +
            "COALESCE(NULLIF(se.session_date, ''), DATE_FORMAT(ts.sessionDate, '%Y-%m-%d'), DATE_FORMAT(cs.scheduleDate, '%Y-%m-%d'), '') AS session_date, " +
            "COALESCE(NULLIF(se.start_time, ''), cs.startTime, '') AS start_time, " +
            "COALESCE(NULLIF(se.end_time, ''), cs.endTime, '') AS end_time, " +
            "COALESCE(cs.classSurah, 0) AS quran_surah_number, " +
            "COALESCE(cs.classAyah, 0) AS quran_ayah_number, " +
            "COALESCE(NULLIF(se.teacherId, ''), cs.teacherId, '') AS teacherId, " +
            "COALESCE(NULLIF(t.teacherName, ''), '') AS teacher_name, " +
            "se.sessionId, se.tajweedScore, se.fluencyScore, se.accuracyScore, se.overall_score, se.rating, " +
            "se.strength, se.areas_for_improvement, se.performance_tag, se.next_target_surah, se.suggestions, " +
            "se.teacher_comments, se.status, se.weakness, se.studentImprovements, se.nextTarget, se.comments, " +
            createdCol + " AS createdAt, " +
            updatedCol + " AS updated_at " +
            "FROM studentevaluation se " +
            "LEFT JOIN student s ON se.studentId = s.studentId " +
            TalaqqiSchemaUtil.leftJoinSessionFromEvaluation(connection) +
            "LEFT JOIN teacher t ON COALESCE(NULLIF(se.teacherId, ''), cs.teacherId) = t.teacherId ";
    }

    private List<Evaluation> getPendingEvaluationsFallback(String teacherId) {
        List<Evaluation> evaluations = new ArrayList<>();
        String createdCol = TalaqqiSchemaUtil.studentEvalCreatedColumn(connection, "se");
        String query =
            "SELECT se.studentEvaluationId, se.studentId, se.sessionId, se.teacherId, " +
            "se.tajweedScore, se.fluencyScore, se.accuracyScore, se.overall_score, se.rating, " +
            "se.strength, se.areas_for_improvement, se.performance_tag, se.next_target_surah, " +
            "se.suggestions, se.teacher_comments, se.status, se.weakness, se.studentImprovements, " +
            "se.nextTarget, se.comments, " +
            "COALESCE(s.studentName, '') AS student_name, '' AS teacher_name, " +
            "COALESCE(se.class_name, '') AS class_name, COALESCE(se.surah, '') AS surah, " +
            "COALESCE(se.ayah_range, '') AS ayah_range, " +
            "COALESCE(se.session_date, '') AS session_date, " +
            "COALESCE(se.start_time, '') AS start_time, " +
            "COALESCE(se.end_time, '') AS end_time, " +
            "0 AS quran_surah_number, 0 AS quran_ayah_number, " +
            createdCol + " AS createdAt, NULL AS updated_at " +
            "FROM studentevaluation se " +
            "LEFT JOIN student s ON se.studentId = s.studentId " +
            "WHERE se.teacherId = ? AND UPPER(COALESCE(se.status, 'PENDING')) = 'PENDING' " +
            "ORDER BY " + createdCol + " DESC";

        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setString(1, teacherId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    evaluations.add(mapResultSetToEvaluation(rs));
                }
            }
        } catch (SQLException e) {
            setError("Fallback pending evaluation query failed", e);
        }
        return evaluations;
    }

    /**
     * Student feedback about this teacher (studentfeedback table).
     */
    public List<Evaluation> getStudentFeedbackForTeacher(String teacherId) {
        List<Evaluation> evaluations = new ArrayList<>();
        String ayahRange = TalaqqiSchemaUtil.ayahRangeExpr(connection);
        String query =
            "SELECT sf.feedbackId, sf.sessionId, sf.rating, sf.comments, sf.suggestions, " +
            "DATE_FORMAT(sf.createdAt,'%Y-%m-%d') AS createdAt, " +
            "s.studentName AS student_name, " +
            "DATE_FORMAT(cs.scheduleDate,'%Y-%m-%d') AS session_date, " +
            "DATE_FORMAT(cs.startTime,'%H:%i:%s') AS start_time, " +
            "DATE_FORMAT(cs.endTime,'%H:%i:%s') AS end_time, " +
            "cs.classSurah AS surah, " +
            ayahRange + " AS ayah_range " +
            "FROM studentfeedback sf " +
            "JOIN student s ON sf.studentId = s.studentId " +
            TalaqqiSchemaUtil.leftJoinSessionFromFeedback(connection) +
            "WHERE sf.teacherId = ? " +
            "ORDER BY sf.createdAt DESC";

        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setString(1, teacherId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Evaluation evaluation = new Evaluation();
                evaluation.setSessionId(rs.getString("sessionId"));
                evaluation.setStudentName(rs.getString("student_name"));
                evaluation.setRating(rs.getInt("rating"));
                evaluation.setComments(rs.getString("comments"));
                evaluation.setSuggestions(rs.getString("suggestions"));
                evaluation.setCreatedAt(rs.getString("createdAt"));
                evaluation.setSessionDate(rs.getString("session_date"));
                evaluation.setStartTime(rs.getString("start_time"));
                evaluation.setEndTime(rs.getString("end_time"));
                evaluation.setSurah(resolveSurahDisplay(rs.getString("surah")));
                evaluation.setAyahRange(rs.getString("ayah_range"));
                evaluations.add(evaluation);
            }
        } catch (SQLException e) {
            System.err.println("Error in getStudentFeedbackForTeacher: " + e.getMessage());
            e.printStackTrace();
        }
        return evaluations;
    }

    /**
     * Get all unique class names for filter dropdown
     * @param teacherId The teacher's ID (String)
     * @return List of class names
     */
    public List<String> getClassNames(String teacherId) {
        List<String> classNames = new ArrayList<>();
        String query = "SELECT DISTINCT class_name FROM studentevaluation WHERE teacherId = ? ORDER BY class_name";

        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setString(1, teacherId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                classNames.add(rs.getString("class_name"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return classNames;
    }

    private String resolveStudentId(Evaluation evaluation) {
        String studentId = evaluation.getStudentId();
        if (studentId != null && !studentId.trim().isEmpty()) {
            if (studentId.matches("S\\d+")) {
                return studentId;
            }

            String digits = studentId.replaceAll("[^0-9]", "");
            if (!digits.isEmpty()) {
                return "S" + String.format("%03d", Integer.parseInt(digits));
            }
        }

        int studentIdNum = evaluation.getStudentIdNum();
        if (studentIdNum > 0) {
            return "S" + String.format("%03d", studentIdNum);
        }

        return "S001";
    }

    private String resolveTeacherId(Evaluation evaluation) {
        String teacherId = evaluation.getTeacherId();
        if (teacherId != null && !teacherId.trim().isEmpty()) {
            if (teacherId.matches("T\\d+")) {
                return teacherId;
            }

            String digits = teacherId.replaceAll("[^0-9]", "");
            if (!digits.isEmpty()) {
                return "T" + String.format("%03d", Integer.parseInt(digits));
            }
        }

        int teacherIdNum = evaluation.getTeacherIdNum();
        if (teacherIdNum > 0) {
            return "T" + String.format("%03d", teacherIdNum);
        }

        return "T001";
    }

    private String resolveEvaluationId(Evaluation evaluation) {
        int evaluationId = evaluation.getEvaluationId();
        if (evaluationId > 0) {
            return "SE" + String.format("%03d", evaluationId);
        }

        return generateNextEvaluationId();
    }

    private String generateNextEvaluationId() {
        String query =
            "SELECT MAX(CAST(SUBSTRING(studentEvaluationId, 3) AS UNSIGNED)) AS maxId " +
            "FROM studentevaluation WHERE studentEvaluationId REGEXP '^SE[0-9]+$'";
        try (PreparedStatement stmt = connection.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            int next = 1;
            if (rs.next()) {
                next = rs.getInt("maxId") + 1;
            }
            return "SE" + String.format("%03d", next);
        } catch (SQLException e) {
            System.err.println("Error generating next evaluation ID: " + e.getMessage());
            return "SE001";
        }
    }

    private String resolveSurahDisplay(String surahValue) {
        if (surahValue == null) {
            return "";
        }

        String trimmed = surahValue.trim();
        if (trimmed.isEmpty()) {
            return "";
        }

        if (trimmed.matches("\\d+")) {
            try {
                return getSurahName(Integer.parseInt(trimmed));
            } catch (NumberFormatException e) {
                return trimmed;
            }
        }

        return trimmed;
    }

    private String getSurahName(int surahNumber) {
        String[] surahNames = {
            "",
            "Al-Fatiha", "Al-Baqarah", "Al-Imran", "An-Nisa", "Al-Maidah",
            "Al-Anam", "Al-Araf", "Al-Anfal", "At-Tawbah", "Yunus",
            "Hud", "Yusuf", "Ar-Rad", "Ibrahim", "Al-Hijr",
            "An-Nahl", "Al-Isra", "Al-Kahf", "Maryam", "Taha",
            "Al-Anbiya", "Al-Hajj", "Al-Muminun", "An-Nur", "Al-Furqan",
            "Ash-Shuara", "An-Naml", "Al-Qasas", "Al-Ankabut", "Ar-Rum",
            "Luqman", "As-Sajdah", "Al-Ahzab", "Saba", "Fatir",
            "Yasin", "As-Saffat", "Sad", "Az-Zumar", "Ghafir",
            "Fussilat", "Ash-Shura", "Az-Zukhruf", "Ad-Dukhan", "Al-Jathiya",
            "Al-Ahqaf", "Muhammad", "Al-Fath", "Al-Hujurat", "Qaf",
            "Adh-Dhariyat", "At-Tur", "An-Najm", "Al-Qamar", "Ar-Rahman",
            "Al-Waqiah", "Al-Hadid", "Al-Mujadalah", "Al-Hashr", "Al-Mumtahanah",
            "As-Saff", "Al-Jumu'ah", "Al-Munafiqun", "At-Taghabun", "At-Talaq",
            "At-Tahrim", "Al-Mulk", "Al-Qalam", "Al-Haqqah", "Al-Maarij",
            "Nuh", "Al-Jinn", "Al-Muzzammil", "Al-Muddaththir", "Al-Qiyamah",
            "Al-Insan", "Al-Mursalat", "An-Naba", "An-Nazi'at", "Abasa",
            "At-Takwir", "Al-Infitar", "Al-Mutaffifin", "Al-Inshiqaq", "Al-Buruj",
            "At-Tariq", "Al-A'la", "Al-Ghashiyah", "Al-Fajr", "Al-Balad",
            "Ash-Shams", "Al-Layl", "Ad-Duha", "Ash-Sharh", "At-Tin",
            "Al-Alaq", "Al-Qadr", "Al-Bayyinah", "Az-Zalzalah", "Al-Adiyat",
            "Al-Qari'ah", "At-Takathur", "Al-Asr", "Al-Humaza", "Al-Fil",
            "Quraysh", "Al-Maun", "Al-Kawthar", "Al-Kafirun", "An-Nasr",
            "Al-Masad", "Al-Ikhlas", "Al-Falaq", "An-Nas"
        };

        if (surahNumber >= 1 && surahNumber < surahNames.length) {
            return surahNames[surahNumber];
        }

        return "Unknown Surah";
    }

    /**
     * Map a ResultSet row to an Evaluation object
     * @param rs The ResultSet
     * @return Evaluation object
     */
    private Evaluation mapResultSetToEvaluation(ResultSet rs) throws SQLException {
        Evaluation evaluation = new Evaluation();
        
        // Use safer getInt/getString methods with defaults
        try {
            // Debug: log raw surah/ayah fields from ResultSet to help diagnose missing labels
            try {
                String rawSurah = rs.getString("surah");
                Object rawSurahNum = null;
                try { rawSurahNum = rs.getObject("quran_surah_number"); } catch (Exception ignored) {}
                String rawAyah = rs.getString("ayah_range");
                Object rawAyahNum = null;
                try { rawAyahNum = rs.getObject("quran_ayah_number"); } catch (Exception ignored) {}
                String sess = "";
                try { sess = rs.getString("sessionId"); } catch (Exception ignored) {}
                System.out.println("[TeacherEvaluationDAO] mapResultSetToEvaluation RAW -> sessionId:" + sess + ", surah:'" + rawSurah + "', quran_surah_number:" + rawSurahNum + ", ayah_range:'" + rawAyah + "', quran_ayah_number:" + rawAyahNum);
            } catch (Exception e) {
                // ignore logging errors
            }
            // studentEvaluationId is VARCHAR like "SE009", extract numeric part
            String evalId = rs.getString("studentEvaluationId");
            if (evalId != null && !evalId.isEmpty()) {
                String numericOnly = evalId.replaceAll("[^0-9]", "");
                if (!numericOnly.isEmpty()) {
                    evaluation.setEvaluationId(Integer.parseInt(numericOnly));
                } else {
                    evaluation.setEvaluationId(0);
                }
            } else {
                evaluation.setEvaluationId(0);
            }
        } catch (Exception e) {
            evaluation.setEvaluationId(0);
        }
        
        try {
            // studentId is VARCHAR like "S001", pass it directly as a string
            String studentIdStr = rs.getString("studentId");
            if (studentIdStr != null && !studentIdStr.isEmpty()) {
                evaluation.setStudentId(studentIdStr);
            } else {
                evaluation.setStudentId("");
            }
        } catch (Exception e) {
            evaluation.setStudentId("");
        }
        
        try {
            evaluation.setSessionId(rs.getString("sessionId"));
        } catch (SQLException e) {
            evaluation.setSessionId("");
        }

        try {
            evaluation.setStudentName(rs.getString("student_name"));
        } catch (SQLException e) {
            evaluation.setStudentName("");
        }
        
        try {
            evaluation.setClassName(rs.getString("class_name"));
        } catch (SQLException e) {
            evaluation.setClassName("");
        }

        try {
            evaluation.setTeacherName(rs.getString("teacher_name"));
        } catch (SQLException e) {
            evaluation.setTeacherName("");
        }
        
        try {
            String surahValue = rs.getString("surah");
            if (surahValue == null || surahValue.trim().isEmpty()) {
                int quranSurahNumber = 0;
                try {
                    quranSurahNumber = rs.getInt("quran_surah_number");
                } catch (SQLException ignored) {
                }
                if (quranSurahNumber > 0) {
                    surahValue = getSurahName(quranSurahNumber);
                }
            }
            evaluation.setSurah(resolveSurahDisplay(surahValue));
        } catch (SQLException e) {
            evaluation.setSurah("");
        }
        
        try {
            String ayahValue = rs.getString("ayah_range");
            if (ayahValue == null || ayahValue.trim().isEmpty()) {
                int quranAyahNumber = 0;
                try {
                    quranAyahNumber = rs.getInt("quran_ayah_number");
                } catch (SQLException ignored) {
                }
                if (quranAyahNumber > 0) {
                    ayahValue = String.valueOf(quranAyahNumber);
                }
            }
            evaluation.setAyahRange(ayahValue != null ? ayahValue : "");
        } catch (SQLException e) {
            evaluation.setAyahRange("");
        }

        try {
            evaluation.setSurahNumber(rs.getInt("quran_surah_number"));
        } catch (SQLException e) {
            evaluation.setSurahNumber(0);
        }

        try {
            evaluation.setAyahNumber(rs.getInt("quran_ayah_number"));
        } catch (SQLException e) {
            evaluation.setAyahNumber(0);
        }
        
        try {
            evaluation.setSessionDate(rs.getString("session_date"));
        } catch (SQLException e) {
            evaluation.setSessionDate("");
        }
        
        try {
            evaluation.setStartTime(rs.getString("start_time"));
        } catch (SQLException e) {
            evaluation.setStartTime("");
        }
        
        try {
            evaluation.setEndTime(rs.getString("end_time"));
        } catch (SQLException e) {
            evaluation.setEndTime("");
        }
        
        try {
            evaluation.setTajweedScore(rs.getFloat("tajweedScore"));
        } catch (SQLException e) {
            evaluation.setTajweedScore(0.0f);
        }
        
        try {
            evaluation.setFluencyScore(rs.getFloat("fluencyScore"));
        } catch (SQLException e) {
            evaluation.setFluencyScore(0.0f);
        }
        
        try {
            evaluation.setAccuracyScore(rs.getFloat("accuracyScore"));
        } catch (SQLException e) {
            evaluation.setAccuracyScore(0.0f);
        }
        
        try {
            evaluation.setOverallScore(rs.getFloat("overall_score"));
        } catch (SQLException e) {
            evaluation.setOverallScore(0.0f);
        }
        
        try {
            evaluation.setRating(rs.getInt("rating"));
        } catch (SQLException e) {
            evaluation.setRating(0);
        }
        
        try {
            evaluation.setComments(rs.getString("strength"));
        } catch (SQLException e) {
            evaluation.setComments("");
        }
        
        try {
            evaluation.setAreasForImprovement(rs.getString("areas_for_improvement"));
        } catch (SQLException e) {
            evaluation.setAreasForImprovement("");
        }
        
        try {
            evaluation.setPerformanceTag(rs.getString("performance_tag"));
        } catch (SQLException e) {
            evaluation.setPerformanceTag("");
        }
        
        try {
            evaluation.setNextTarget(rs.getString("next_target_surah"));
        } catch (SQLException e) {
            evaluation.setNextTarget("");
        }
        
        try {
            evaluation.setSuggestions(rs.getString("suggestions"));
        } catch (SQLException e) {
            evaluation.setSuggestions("");
        }
        
        try {
            evaluation.setTeacherComments(rs.getString("teacher_comments"));
        } catch (SQLException e) {
            evaluation.setTeacherComments("");
        }
        
        try {
            evaluation.setStatus(rs.getString("status"));
        } catch (SQLException e) {
            evaluation.setStatus("");
        }
        
        try {
            // teacherId is VARCHAR like "T001", pass it directly as a string
            String teacherIdStr = rs.getString("teacherId");
            if (teacherIdStr != null && !teacherIdStr.isEmpty()) {
                evaluation.setTeacherId(teacherIdStr);
            } else {
                evaluation.setTeacherId("");
            }
        } catch (Exception e) {
            evaluation.setTeacherId("");
        }
        
        try {
            String createdAt = rs.getString("createdAt");
            if (createdAt != null) {
                evaluation.setCreatedAt(createdAt);
            }
        } catch (SQLException e) {
            // Column doesn't exist, ignore
        }
        
        try {
            String updatedAt = rs.getString("updated_at");
            if (updatedAt != null) {
                evaluation.setUpdatedAt(updatedAt);
            }
        } catch (SQLException e) {
            // Column doesn't exist, ignore
        }
        
        return evaluation;
    }
}
