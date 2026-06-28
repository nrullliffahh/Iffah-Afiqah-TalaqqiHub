package com.talaqqihub.dao;

import com.talaqqihub.model.Evaluation;
import util.TalaqqiSchemaUtil;
import util.TextEncodingUtil;
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

        migrateStudentEvaluationColumns();
        TalaqqiSchemaUtil.ensureSessionBookingIdColumn(connection);
    }

    private void migrateStudentEvaluationColumns() {
        String[][] columns = {
            {"sessionId", "VARCHAR(50) DEFAULT NULL"},
            {"scheduleId", "VARCHAR(10) DEFAULT NULL"},
            {"class_name", "VARCHAR(100) DEFAULT NULL"},
            {"surah", "VARCHAR(100) DEFAULT NULL"},
            {"ayah_range", "VARCHAR(50) DEFAULT NULL"},
            {"session_date", "DATE DEFAULT NULL"},
            {"start_time", "TIME DEFAULT NULL"},
            {"end_time", "TIME DEFAULT NULL"},
            {"overall_score", "FLOAT DEFAULT 0"},
            {"rating", "INT DEFAULT 0"},
            {"areas_for_improvement", "TEXT"},
            {"performance_tag", "VARCHAR(50) DEFAULT NULL"},
            {"next_target_surah", "VARCHAR(100) DEFAULT NULL"},
            {"suggestions", "TEXT"},
            {"teacher_comments", "TEXT"},
            {"status", "VARCHAR(20) DEFAULT 'PENDING'"},
            {"updated_at", "TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP"},
        };
        for (String[] col : columns) {
            tryAddColumn("studentevaluation", col[0], col[1]);
        }
        tryModifyColumnNullable("studentevaluation", "sessionId", "VARCHAR(50) DEFAULT NULL");
        tryModifyColumnNullable("studentevaluation", "scheduleId", "VARCHAR(10) DEFAULT NULL");
        ensureScheduleIdAllowsNull();
    }

    /** Legacy production may have NOT NULL scheduleId (INT/VARCHAR) — allow NULL when lookup fails. */
    private void ensureScheduleIdAllowsNull() {
        if (!hasEvalColumn("scheduleId")) {
            return;
        }
        tryModifyColumnNullable("studentevaluation", "scheduleId", "VARCHAR(10) DEFAULT NULL");
        try (Statement stmt = connection.createStatement()) {
            stmt.execute("ALTER TABLE studentevaluation MODIFY COLUMN scheduleId INT DEFAULT NULL");
            System.out.println("[TeacherEvaluationDAO] modified column studentevaluation.scheduleId (INT NULL)");
        } catch (SQLException e) {
            String msg = e.getMessage() != null ? e.getMessage() : "";
            if (!msg.contains("Duplicate column") && !msg.contains("Unknown column")) {
                System.err.println("[TeacherEvaluationDAO] ensureScheduleIdAllowsNull INT: " + msg);
            }
        }
    }

    private void tryModifyColumnNullable(String table, String column, String definition) {
        if (!TalaqqiSchemaUtil.hasColumn(connection, table, column)) {
            return;
        }
        try (Statement stmt = connection.createStatement()) {
            stmt.execute("ALTER TABLE `" + table + "` MODIFY COLUMN `" + column + "` " + definition);
            System.out.println("[TeacherEvaluationDAO] modified column " + table + "." + column);
        } catch (SQLException e) {
            String msg = e.getMessage() != null ? e.getMessage() : "";
            if (!msg.contains("Duplicate column")) {
                System.err.println("[TeacherEvaluationDAO] tryModifyColumnNullable " + column + ": " + msg);
            }
        }
    }

    private void tryAddColumn(String table, String column, String definition) {
        if (TalaqqiSchemaUtil.hasColumn(connection, table, column)) {
            return;
        }
        try (Statement stmt = connection.createStatement()) {
            stmt.execute("ALTER TABLE `" + table + "` ADD COLUMN `" + column + "` " + definition);
            System.out.println("[TeacherEvaluationDAO] added column " + table + "." + column);
        } catch (SQLException e) {
            String msg = e.getMessage() != null ? e.getMessage() : "";
            if (!msg.contains("Duplicate column")) {
                System.err.println("[TeacherEvaluationDAO] tryAddColumn " + column + ": " + msg);
            }
        }
    }

    private boolean hasEvalColumn(String column) {
        return TalaqqiSchemaUtil.hasColumn(connection, "studentevaluation", column);
    }

    /** SQL predicate: row is a completed teacher evaluation. */
    private String evalCompletedPredicate(String alias) {
        String scoreCheck = evalScorePresentPredicate(alias);
        if (hasEvalColumn("status")) {
            return "(UPPER(COALESCE(" + alias + ".status, '')) = 'COMPLETED' OR " + scoreCheck + ")";
        }
        if (hasEvalColumn("overall_score")) {
            return "COALESCE(" + alias + ".overall_score, 0) > 0";
        }
        return scoreCheck;
    }

    private String evalScorePresentPredicate(String alias) {
        String scoreCheck = "(COALESCE(" + alias + ".tajweedScore, 0) > 0 "
            + "OR COALESCE(" + alias + ".fluencyScore, 0) > 0 "
            + "OR COALESCE(" + alias + ".accuracyScore, 0) > 0)";
        if (hasEvalColumn("overall_score")) {
            scoreCheck = "(" + scoreCheck + " OR COALESCE(" + alias + ".overall_score, 0) > 0)";
        }
        return scoreCheck;
    }

    /** SQL predicate: row is pending teacher evaluation. */
    private String evalPendingPredicate(String alias) {
        return "NOT (" + evalCompletedPredicate(alias) + ")";
    }

    /** Backfill COMPLETED status when scores exist but status stayed PENDING. */
    public void syncCompletedEvaluationStatus(String teacherId) {
        if (!hasEvalColumn("status")) {
            return;
        }
        String scoreCheck = evalScorePresentPredicate("studentevaluation");
        String sql = "UPDATE studentevaluation SET status = 'COMPLETED' "
            + "WHERE UPPER(COALESCE(status, 'PENDING')) = 'PENDING' AND " + scoreCheck;
        if (teacherId != null && !teacherId.trim().isEmpty()) {
            sql += " AND " + teacherIdMatchClause("teacherId", teacherIdVariants(teacherId));
        }
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            if (teacherId != null && !teacherId.trim().isEmpty()) {
                bindTeacherIdVariants(stmt, 1, teacherId);
            }
            stmt.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[TeacherEvaluationDAO] syncCompletedEvaluationStatus: " + e.getMessage());
        }
    }

    private String evalSelectColumn(String column) {
        return hasEvalColumn(column) ? "se." + column : "NULL AS " + column;
    }

    private String evalSelectColumnOrAlias(String asName, String primary, String... fallbacks) {
        if (hasEvalColumn(primary)) {
            return primary.equals(asName) ? "se." + primary : "se." + primary + " AS " + asName;
        }
        for (String fallback : fallbacks) {
            if (hasEvalColumn(fallback)) {
                return "se." + fallback + " AS " + asName;
            }
        }
        return "NULL AS " + asName;
    }

    private String evalClassNameExpr() {
        if (hasEvalColumn("class_name")) {
            return "COALESCE(NULLIF(se.class_name, ''), cs.className, '') AS class_name";
        }
        return "COALESCE(cs.className, '') AS class_name";
    }

    private String evalSessionIdRef() {
        if (hasEvalColumn("sessionId")) {
            return "COALESCE(NULLIF(TRIM(se.sessionId), ''), ts.sessionId)";
        }
        return "ts.sessionId";
    }

    private String evalSurahExpr() {
        String sessionRef = evalSessionIdRef();
        String surahFromSession = "CAST(" + quranSurahNumberSql(sessionRef) + " AS CHAR)";
        if (hasEvalColumn("surah")) {
            return "COALESCE(NULLIF(se.surah, ''), NULLIF(" + surahFromSession + ", '0'), '') AS surah";
        }
        return "COALESCE(NULLIF(" + surahFromSession + ", '0'), '') AS surah";
    }

    private String evalAyahExpr() {
        String ayahRange = TalaqqiSchemaUtil.ayahRangeExpr(connection);
        if (hasEvalColumn("ayah_range")) {
            return "COALESCE(NULLIF(se.ayah_range, ''), " + ayahRange + ", '') AS ayah_range";
        }
        return "COALESCE(" + ayahRange + ", '') AS ayah_range";
    }

    /** Surah number from live session display, then schedule. */
    private String quranSurahNumberSql(String sessionIdExpr) {
        if (TalaqqiSchemaUtil.hasQuranDisplayTable(connection)) {
            return "COALESCE("
                + "(SELECT NULLIF(qd.currentSurah, 0) FROM qurandisplay qd "
                + "WHERE qd.sessionId = " + sessionIdExpr + " LIMIT 1), "
                + "NULLIF(cs.classSurah, 0), 0)";
        }
        return "COALESCE(NULLIF(cs.classSurah, 0), 0)";
    }

    /** Ayah number from live session display, then schedule. */
    private String quranAyahNumberSql(String sessionIdExpr) {
        if (TalaqqiSchemaUtil.hasQuranDisplayTable(connection)) {
            return "COALESCE("
                + "(SELECT NULLIF(qd.currentAyah, 0) FROM qurandisplay qd "
                + "WHERE qd.sessionId = " + sessionIdExpr + " LIMIT 1), "
                + "NULLIF(cs.classAyah, 0), 0)";
        }
        return "COALESCE(NULLIF(cs.classAyah, 0), 0)";
    }

    private String pendingSessionSurahColumns(String sessionIdExpr) {
        String surahNum = quranSurahNumberSql(sessionIdExpr);
        return "CAST(" + surahNum + " AS CHAR) AS surah, "
            + surahNum + " AS quran_surah_number, "
            + quranAyahNumberSql(sessionIdExpr) + " AS quran_ayah_number, ";
    }

    private String evalSessionDateExpr() {
        StringBuilder expr = new StringBuilder("COALESCE(");
        if (hasEvalColumn("session_date")) {
            expr.append("NULLIF(DATE_FORMAT(se.session_date,'%Y-%m-%d'), ''), ");
        }
        expr.append("NULLIF(DATE_FORMAT(cb.bookingDate,'%Y-%m-%d'), ''), ");
        expr.append("NULLIF(DATE_FORMAT(ts.sessionDate,'%Y-%m-%d'), ''), ");
        expr.append("NULLIF(DATE_FORMAT(cs.scheduleDate,'%Y-%m-%d'), ''), ");
        expr.append("'') AS session_date");
        return expr.toString();
    }

    private String evalStartTimeExpr() {
        String fromSchedule = "DATE_FORMAT(cs.startTime,'%H:%i:%s')";
        if (hasEvalColumn("start_time")) {
            return "COALESCE(NULLIF(DATE_FORMAT(se.start_time,'%H:%i:%s'), ''), " + fromSchedule + ", '') AS start_time";
        }
        return "COALESCE(" + fromSchedule + ", '') AS start_time";
    }

    private String evalEndTimeExpr() {
        String fromSchedule = "DATE_FORMAT(cs.endTime,'%H:%i:%s')";
        if (hasEvalColumn("end_time")) {
            return "COALESCE(NULLIF(DATE_FORMAT(se.end_time,'%H:%i:%s'), ''), " + fromSchedule + ", '') AS end_time";
        }
        return "COALESCE(" + fromSchedule + ", '') AS end_time";
    }

    private String evalNotExistsBlocksPending() {
        String sessionLookup = TalaqqiSchemaUtil.sessionIdForBookingSubquery(connection);
        if (hasEvalColumn("sessionId")) {
            return "se.sessionId = " + sessionLookup
                + " OR (" + sessionLookup + " IS NULL AND " + evalCompletedPredicate("se") + ")";
        }
        return evalCompletedPredicate("se");
    }

    private String evalNotExistsBlocksPendingFallback() {
        String sessionLookup = TalaqqiSchemaUtil.sessionIdForBookingSubquery(connection);
        if (hasEvalColumn("sessionId")) {
            return "se.sessionId = " + sessionLookup
                + " OR (" + sessionLookup + " IS NULL AND " + evalCompletedPredicate("se") + ")";
        }
        return evalCompletedPredicate("se");
    }

    private List<String> teacherIdVariants(String teacherId) {
        List<String> ids = new ArrayList<>();
        if (teacherId == null || teacherId.trim().isEmpty()) {
            return ids;
        }
        String trimmed = teacherId.trim();
        ids.add(trimmed);
        String digits = trimmed.replaceAll("[^0-9]", "");
        if (!digits.isEmpty()) {
            int n = Integer.parseInt(digits);
            String formatted = "T" + String.format("%03d", n);
            String plain = String.valueOf(n);
            if (!ids.contains(formatted)) {
                ids.add(formatted);
            }
            if (!ids.contains(plain)) {
                ids.add(plain);
            }
        }
        return ids;
    }

    private String teacherIdMatchClause(String column, List<String> variants) {
        if (variants == null || variants.isEmpty()) {
            return column + " = ?";
        }
        if (variants.size() == 1) {
            return column + " = ?";
        }
        StringBuilder clause = new StringBuilder(column).append(" IN (");
        for (int i = 0; i < variants.size(); i++) {
            if (i > 0) {
                clause.append(", ");
            }
            clause.append("?");
        }
        clause.append(")");
        return clause.toString();
    }

    private int bindTeacherIdVariants(PreparedStatement stmt, int index, String teacherId)
            throws SQLException {
        List<String> variants = teacherIdVariants(teacherId);
        if (variants.isEmpty()) {
            stmt.setString(index++, teacherId);
            return index;
        }
        for (String id : variants) {
            stmt.setString(index++, id);
        }
        return index;
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
        ensureStudentEvaluationSchema();

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
        if (teacherId == null || teacherId.trim().isEmpty()) {
            return null;
        }

        String query;
        if (sessionId != null && !sessionId.trim().isEmpty() && hasEvalColumn("sessionId")) {
            query = "SELECT studentEvaluationId FROM studentevaluation WHERE sessionId = ? AND "
                + teacherIdMatchClause("teacherId", teacherIdVariants(teacherId)) + " LIMIT 1";
        } else {
            return null;
        }

        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setString(1, sessionId.trim());
            bindTeacherIdVariants(stmt, 2, teacherId);
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
            String msg = e.getMessage() != null ? e.getMessage() : "";
            if (msg.contains("Unknown column") && msg.contains("sessionId")) {
                return null;
            }
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

        String completedWhere = evalCompletedPredicate("se");
        String overallAvg = hasEvalColumn("overall_score")
            ? "AVG(overall_score)"
            : "AVG((COALESCE(tajweedScore,0)+COALESCE(fluencyScore,0)+COALESCE(accuracyScore,0))/3)";

        String query = "SELECT " +
            "COUNT(DISTINCT studentId) as total_students_evaluated, " +
            "COUNT(*) as total_sessions_evaluated, " +
            overallAvg + " as avg_overall_score, " +
            "AVG(tajweedScore) as avg_tajweed_score, " +
            "AVG(fluencyScore) as avg_fluency_score, " +
            "AVG(accuracyScore) as avg_accuracy_score " +
            "FROM studentevaluation se " +
            "WHERE se.teacherId = ? AND " + completedWhere;

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
        List<String> teacherIds = teacherIdVariants(teacherId);
        String createdCol = TalaqqiSchemaUtil.studentEvalCreatedColumn(connection, "se");
        String orderCol = hasEvalColumn("session_date") ? "se.session_date" : createdCol;
        String teacherClause = teacherIdMatchClause("se.teacherId", teacherIds);
        String query = buildEvaluationListSelectSql() +
            "WHERE " + teacherClause + " AND " + evalPendingPredicate("se") + " " +
            "ORDER BY " + orderCol + " DESC, " + createdCol + " DESC";

        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            bindTeacherIdVariants(stmt, 1, teacherId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                evaluations.add(mapResultSetToEvaluation(rs));
            }
        } catch (SQLException e) {
            setError("Unable to load pending evaluations", e);
            tryLegacyPendingEvaluationsFallback(teacherId, evaluations);
        }

        if (evaluations.isEmpty()) {
            tryLegacyPendingEvaluationsFallback(teacherId, evaluations);
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
        List<String> teacherIds = teacherIdVariants(teacherId);
        String teacherClause = teacherIdMatchClause("se.teacherId", teacherIds);

        StringBuilder query = new StringBuilder(buildEvaluationListSelectSql());
        query.append("WHERE ").append(teacherClause).append(" AND ").append(evalCompletedPredicate("se"));

        // Add search filter
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            if (hasEvalColumn("surah")) {
                query.append(" AND (s.studentName LIKE ? OR se.surah LIKE ?)");
            } else {
                query.append(" AND (s.studentName LIKE ? OR CAST(cs.classSurah AS CHAR) LIKE ?)");
            }
        }

        // Add class filter
        if (filterClass != null && !filterClass.trim().isEmpty()) {
            if (hasEvalColumn("class_name")) {
                query.append(" AND se.class_name = ?");
            } else {
                query.append(" AND cs.className = ?");
            }
        }

        // Add sorting
        if ("oldest".equals(sortBy)) {
            query.append(" ORDER BY ").append(hasEvalColumn("session_date") ? "se.session_date" : "cs.scheduleDate").append(" ASC");
        } else if ("best".equals(sortBy)) {
            query.append(" ORDER BY ").append(hasEvalColumn("overall_score") ? "se.overall_score" : "se.tajweedScore").append(" DESC");
        } else if ("lowest".equals(sortBy)) {
            query.append(" ORDER BY ").append(hasEvalColumn("overall_score") ? "se.overall_score" : "se.tajweedScore").append(" ASC");
        } else {
            query.append(" ORDER BY ").append(hasEvalColumn("session_date") ? "se.session_date" : "cs.scheduleDate").append(" DESC");
        }

        try (PreparedStatement stmt = connection.prepareStatement(query.toString())) {
            int paramIndex = bindTeacherIdVariants(stmt, 1, teacherId);

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
            evaluations.addAll(getCompletedEvaluationsFallback(teacherId, searchTerm, filterClass, sortBy));
        }

        if (evaluations.isEmpty()) {
            evaluations.addAll(getCompletedEvaluationsFallback(teacherId, searchTerm, filterClass, sortBy));
        }

        enrichPendingEvaluations(evaluations);
        return evaluations;
    }

    private String evalFallbackSurahExpr() {
        if (hasEvalColumn("surah")) {
            return "COALESCE(NULLIF(se.surah, ''), '') AS surah";
        }
        return "'' AS surah";
    }

    private String evalFallbackAyahExpr() {
        if (hasEvalColumn("ayah_range")) {
            return "COALESCE(NULLIF(se.ayah_range, ''), '') AS ayah_range";
        }
        return "'' AS ayah_range";
    }

    private String evalFallbackSessionDateExpr() {
        if (hasEvalColumn("session_date")) {
            return "COALESCE(DATE_FORMAT(se.session_date,'%Y-%m-%d'), '') AS session_date";
        }
        return "'' AS session_date";
    }

    private String evalFallbackStartTimeExpr() {
        if (hasEvalColumn("start_time")) {
            return "COALESCE(DATE_FORMAT(se.start_time,'%H:%i:%s'), '') AS start_time";
        }
        return "'' AS start_time";
    }

    private String evalFallbackEndTimeExpr() {
        if (hasEvalColumn("end_time")) {
            return "COALESCE(DATE_FORMAT(se.end_time,'%H:%i:%s'), '') AS end_time";
        }
        return "'' AS end_time";
    }

    private List<Evaluation> getCompletedEvaluationsFallback(String teacherId, String searchTerm,
                                                             String filterClass, String sortBy) {
        List<Evaluation> evaluations = new ArrayList<>();
        String sessionCol = hasEvalColumn("sessionId") ? "se.sessionId" : "NULL AS sessionId";
        String createdCol = TalaqqiSchemaUtil.studentEvalCreatedColumn(connection, "se");
        String overallExpr = hasEvalColumn("overall_score")
            ? "COALESCE(se.overall_score, (COALESCE(se.tajweedScore,0)+COALESCE(se.fluencyScore,0)+COALESCE(se.accuracyScore,0))/3)"
            : "(COALESCE(se.tajweedScore,0)+COALESCE(se.fluencyScore,0)+COALESCE(se.accuracyScore,0))/3";
        String statusCol = hasEvalColumn("status") ? "se.status" : "'COMPLETED' AS status";
        StringBuilder query = new StringBuilder(
            "SELECT se.studentEvaluationId, se.studentId, "
            + sessionCol + ", se.teacherId, "
            + "se.tajweedScore, se.fluencyScore, se.accuracyScore, "
            + overallExpr + " AS overall_score, "
            + evalSelectColumnOrAlias("strength", "strength") + ", "
            + evalSelectColumnOrAlias("weakness", "weakness", "areas_for_improvement") + ", "
            + evalSelectColumnOrAlias("studentImprovements", "studentImprovements", "suggestions") + ", "
            + evalSelectColumnOrAlias("nextTarget", "nextTarget", "next_target_surah") + ", "
            + evalSelectColumnOrAlias("comments", "comments", "teacher_comments") + ", "
            + statusCol + ", "
            + "COALESCE(s.studentName, '') AS student_name, "
            + "COALESCE(t.teacherName, '') AS teacher_name, "
            + "'' AS class_name, "
            + evalFallbackSurahExpr() + ", "
            + evalFallbackAyahExpr() + ", "
            + evalFallbackSessionDateExpr() + ", "
            + evalFallbackStartTimeExpr() + ", "
            + evalFallbackEndTimeExpr() + ", "
            + "0 AS quran_surah_number, 0 AS quran_ayah_number, "
            + evalSelectColumn("rating") + ", "
            + evalSelectColumn("areas_for_improvement") + ", "
            + evalSelectColumn("performance_tag") + ", "
            + evalSelectColumn("next_target_surah") + ", "
            + evalSelectColumn("suggestions") + ", "
            + evalSelectColumn("teacher_comments") + ", "
            + createdCol + " AS createdAt, NULL AS updated_at "
            + "FROM studentevaluation se "
            + "LEFT JOIN student s ON se.studentId = s.studentId "
            + "LEFT JOIN teacher t ON se.teacherId = t.teacherId "
            + "WHERE " + teacherIdMatchClause("se.teacherId", teacherIdVariants(teacherId))
            + " AND " + evalCompletedPredicate("se")
        );

        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            query.append(" AND s.studentName LIKE ?");
        }
        if ("oldest".equals(sortBy)) {
            query.append(" ORDER BY se.studentEvaluationId ASC");
        } else if ("best".equals(sortBy)) {
            query.append(" ORDER BY overall_score DESC");
        } else if ("lowest".equals(sortBy)) {
            query.append(" ORDER BY overall_score ASC");
        } else {
            query.append(" ORDER BY se.studentEvaluationId DESC");
        }

        try (PreparedStatement stmt = connection.prepareStatement(query.toString())) {
            int paramIndex = bindTeacherIdVariants(stmt, 1, teacherId);
            if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                stmt.setString(paramIndex++, "%" + searchTerm + "%");
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    evaluations.add(mapResultSetToEvaluation(rs));
                }
            }
        } catch (SQLException e) {
            setError("Fallback completed evaluation query failed", e);
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

    /** Binds INSERT/UPDATE fragments using only columns that exist in production. */
    private static final class EvalSqlParts {
        private final StringBuilder columns = new StringBuilder();
        private final StringBuilder placeholders = new StringBuilder();
        private final List<Object> values = new ArrayList<>();

        void add(String column, Object value) {
            if (columns.length() > 0) {
                columns.append(", ");
                placeholders.append(", ");
            }
            columns.append(column);
            placeholders.append("?");
            values.add(value);
        }

        void addExpression(String column, String expression) {
            if (columns.length() > 0) {
                columns.append(", ");
                placeholders.append(", ");
            }
            columns.append(column);
            placeholders.append(expression);
        }

        void addSet(String column, Object value, StringBuilder setClause, List<Object> params) {
            if (setClause.length() > 0) {
                setClause.append(", ");
            }
            setClause.append(column).append(" = ?");
            params.add(value);
        }
    }

    private void sqlAdd(EvalSqlParts parts, String column, Object value) {
        if (hasEvalColumn(column)) {
            parts.add(column, value);
        }
    }

    private void sqlAddNullable(EvalSqlParts parts, String column, String value) {
        if (hasEvalColumn(column)) {
            parts.add(column, isBlank(value) ? null : value.trim());
        }
    }

    private void addSetNullable(EvalSqlParts helper, String column, String value,
                                StringBuilder setClause, List<Object> params) {
        if (setClause.length() > 0) {
            setClause.append(", ");
        }
        if (isBlank(value)) {
            setClause.append(column).append(" = NULL");
        } else {
            setClause.append(column).append(" = ?");
            params.add(value.trim());
        }
    }

    private void bindJdbcParam(PreparedStatement stmt, int index, Object value) throws SQLException {
        if (value instanceof Float) {
            stmt.setFloat(index, (Float) value);
        } else if (value instanceof Integer) {
            stmt.setInt(index, (Integer) value);
        } else if (value == null) {
            stmt.setNull(index, Types.VARCHAR);
        } else {
            stmt.setString(index, String.valueOf(value));
        }
    }

    private void sqlAddScheduleId(EvalSqlParts parts, Evaluation evaluation) {
        if (!hasEvalColumn("scheduleId")) {
            return;
        }
        hydrateLegacyKeys(evaluation);
        String scheduleId = resolveScheduleIdString(evaluation);
        parts.add("scheduleId", scheduleId);
    }

    private void hydrateLegacyKeys(Evaluation evaluation) {
        if (evaluation == null) {
            return;
        }
        if (isBlank(evaluation.getScheduleId())) {
            String scheduleId = lookupScheduleIdForSession(
                evaluation.getSessionId(), resolveStudentId(evaluation));
            if (scheduleId != null) {
                evaluation.setScheduleId(scheduleId);
            }
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private String lookupScheduleIdForSession(String sessionId, String studentId) {
        if (sessionId == null || sessionId.trim().isEmpty()) {
            return null;
        }
        String table = TalaqqiSchemaUtil.sessionTable(connection);
        String directSql = "SELECT scheduleId FROM " + table + " WHERE sessionId = ? LIMIT 1";
        try (PreparedStatement stmt = connection.prepareStatement(directSql)) {
            stmt.setString(1, sessionId.trim());
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    String scheduleId = readScheduleIdColumn(rs);
                    if (scheduleId != null && !scheduleId.isEmpty()) {
                        return scheduleId;
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[TeacherEvaluationDAO] lookupScheduleIdForSession direct: " + e.getMessage());
        }

        if (studentId != null && !studentId.trim().isEmpty()) {
            String bookingOn = TalaqqiSchemaUtil.hasColumn(connection, table, "bookingId")
                ? "((ts.bookingId IS NOT NULL AND ts.bookingId <> '' AND ts.bookingId = cb.bookingId) "
                    + "OR ((ts.bookingId IS NULL OR ts.bookingId = '') AND ts.scheduleId = cb.scheduleId))"
                : "ts.scheduleId = cb.scheduleId";
            String bookingSql =
                "SELECT cb.scheduleId FROM " + table + " ts "
                + "JOIN classbooking cb ON " + bookingOn + " "
                + "WHERE ts.sessionId = ? AND cb.studentId = ? "
                + "ORDER BY cb.bookingDate DESC, cb.bookingTime DESC LIMIT 1";
            try (PreparedStatement stmt = connection.prepareStatement(bookingSql)) {
                stmt.setString(1, sessionId.trim());
                stmt.setString(2, studentId.trim());
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        String scheduleId = readScheduleIdColumn(rs);
                        if (scheduleId != null) {
                            return scheduleId;
                        }
                    }
                }
            } catch (SQLException e) {
                System.err.println("[TeacherEvaluationDAO] lookupScheduleIdForSession booking: " + e.getMessage());
            }

            bookingSql =
                "SELECT cb.scheduleId FROM " + table + " ts "
                + "JOIN classbooking cb ON cb.scheduleId = ts.scheduleId "
                + "WHERE ts.sessionId = ? AND cb.studentId = ? "
                + "ORDER BY cb.bookingDate DESC, cb.bookingTime DESC LIMIT 1";
            try (PreparedStatement stmt = connection.prepareStatement(bookingSql)) {
                stmt.setString(1, sessionId.trim());
                stmt.setString(2, studentId.trim());
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        String scheduleId = readScheduleIdColumn(rs);
                        if (scheduleId != null) {
                            return scheduleId;
                        }
                    }
                }
            } catch (SQLException e) {
                System.err.println("[TeacherEvaluationDAO] lookupScheduleIdForSession schedule join: "
                    + e.getMessage());
            }
        }
        return null;
    }

    private String resolveScheduleIdString(Evaluation evaluation) {
        hydrateLegacyKeys(evaluation);
        String scheduleId = evaluation.getScheduleId();
        if (isBlank(scheduleId)) {
            return null;
        }
        scheduleId = scheduleId.trim();
        if (scheduleIdExistsInClassSchedule(scheduleId)) {
            return scheduleId;
        }
        // Keep FK value when classschedule probe fails but form/session provided an id.
        return scheduleId;
    }

    private boolean isScheduleIdRequiredError(SQLException e) {
        String msg = e.getMessage();
        return msg != null && (msg.contains("Field 'scheduleId' doesn't have a default value")
            || msg.contains("fk_StudentEvaluation_scheduleId")
            || msg.contains("Column 'scheduleId' cannot be null"));
    }

    private boolean scheduleIdExistsInClassSchedule(String scheduleId) {
        if (isBlank(scheduleId)) {
            return false;
        }
        try (PreparedStatement stmt = connection.prepareStatement(
                "SELECT 1 FROM classschedule WHERE scheduleId = ? LIMIT 1")) {
            stmt.setString(1, scheduleId.trim());
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.err.println("[TeacherEvaluationDAO] scheduleIdExistsInClassSchedule: " + e.getMessage());
            return false;
        }
    }

    private String readScheduleIdColumn(ResultSet rs) throws SQLException {
        Object value = rs.getObject("scheduleId");
        if (value == null) {
            return null;
        }
        String scheduleId = value.toString().trim();
        return scheduleId.isEmpty() ? null : scheduleId;
    }

    private boolean isScheduleIdConstraintError(SQLException e) {
        return isScheduleIdRequiredError(e);
    }

    private void bindParams(PreparedStatement stmt, List<Object> values) throws SQLException {
        for (int i = 0; i < values.size(); i++) {
            bindJdbcParam(stmt, i + 1, values.get(i));
        }
    }

    private String resolvedEvalStatus(Evaluation evaluation) {
        String status = evaluation.getStatus();
        if (status != null && !status.trim().isEmpty()) {
            return status.trim();
        }
        if (evaluation.getOverallScore() > 0
                || evaluation.getTajweedScore() > 0
                || evaluation.getFluencyScore() > 0
                || evaluation.getAccuracyScore() > 0) {
            return "COMPLETED";
        }
        return "PENDING";
    }

    private EvalSqlParts buildEvaluationInsertParts(Evaluation evaluation) {
        hydrateLegacyKeys(evaluation);
        EvalSqlParts parts = new EvalSqlParts();
        parts.add("studentEvaluationId", resolveEvaluationId(evaluation));
        parts.add("studentId", resolveStudentId(evaluation));
        parts.add("teacherId", resolveTeacherId(evaluation));
        sqlAdd(parts, "sessionId", nullToEmpty(evaluation.getSessionId()));
        sqlAddScheduleId(parts, evaluation);
        sqlAdd(parts, "class_name", nullToEmpty(evaluation.getClassName()));
        sqlAdd(parts, "surah", nullToEmpty(evaluation.getSurah()));
        sqlAdd(parts, "ayah_range", nullToEmpty(evaluation.getAyahRange()));
        sqlAddNullable(parts, "session_date", evaluation.getSessionDate());
        sqlAddNullable(parts, "start_time", evaluation.getStartTime());
        sqlAddNullable(parts, "end_time", evaluation.getEndTime());
        sqlAdd(parts, "tajweedScore", evaluation.getTajweedScore());
        sqlAdd(parts, "fluencyScore", evaluation.getFluencyScore());
        sqlAdd(parts, "accuracyScore", evaluation.getAccuracyScore());
        sqlAdd(parts, "overall_score", evaluation.getOverallScore());
        sqlAdd(parts, "rating", evaluation.getRating());
        sqlAdd(parts, "strength", truncate(evaluation.getComments(), 255));
        sqlAdd(parts, "areas_for_improvement", nullToEmpty(evaluation.getAreasForImprovement()));
        sqlAdd(parts, "performance_tag", nullToEmpty(evaluation.getPerformanceTag()));
        sqlAdd(parts, "next_target_surah", nullToEmpty(TextEncodingUtil.normalizeAsciiDash(evaluation.getNextTarget())));
        sqlAdd(parts, "suggestions", nullToEmpty(evaluation.getSuggestions()));
        sqlAdd(parts, "teacher_comments", nullToEmpty(evaluation.getTeacherComments()));
        sqlAdd(parts, "status", resolvedEvalStatus(evaluation));
        sqlAdd(parts, "weakness", truncate(evaluation.getAreasForImprovement(), 255));
        sqlAdd(parts, "studentImprovements", nullToEmpty(evaluation.getSuggestions()));
        sqlAdd(parts, "nextTarget", nullToEmpty(TextEncodingUtil.normalizeAsciiDash(evaluation.getNextTarget())));
        sqlAdd(parts, "comments", nullToEmpty(evaluation.getComments()));
        if (TalaqqiSchemaUtil.hasColumn(connection, "studentevaluation", "createdAt")) {
            parts.addExpression("createdAt", "NOW()");
        } else if (hasEvalColumn("created_at")) {
            parts.addExpression("created_at", "NOW()");
        }
        return parts;
    }

    private boolean insertLegacyEvaluation(Evaluation evaluation) {
        hydrateLegacyKeys(evaluation);
        EvalSqlParts parts = new EvalSqlParts();
        if (hasEvalColumn("studentEvaluationId")) {
            parts.add("studentEvaluationId", resolveEvaluationId(evaluation));
        }
        parts.add("studentId", resolveStudentId(evaluation));
        parts.add("teacherId", resolveTeacherId(evaluation));
        sqlAdd(parts, "sessionId", nullToEmpty(evaluation.getSessionId()));
        sqlAddScheduleId(parts, evaluation);
        sqlAdd(parts, "tajweedScore", evaluation.getTajweedScore());
        sqlAdd(parts, "fluencyScore", evaluation.getFluencyScore());
        sqlAdd(parts, "accuracyScore", evaluation.getAccuracyScore());
        sqlAdd(parts, "strength", truncate(evaluation.getComments(), 255));
        sqlAdd(parts, "weakness", truncate(evaluation.getAreasForImprovement(), 255));
        sqlAdd(parts, "studentImprovements", nullToEmpty(evaluation.getSuggestions()));
        sqlAdd(parts, "nextTarget", nullToEmpty(TextEncodingUtil.normalizeAsciiDash(evaluation.getNextTarget())));
        sqlAdd(parts, "comments", nullToEmpty(evaluation.getComments()));
        sqlAdd(parts, "status", resolvedEvalStatus(evaluation));

        String sql = "INSERT INTO studentevaluation (" + parts.columns + ") VALUES (" + parts.placeholders + ")";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            bindParams(stmt, parts.values);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            setError("Legacy evaluation insert failed: " + e.getMessage(), e);
            return false;
        }
    }

    /**
     * Insert a new evaluation record
     * @param evaluation The evaluation object to insert
     * @return true if successful, false otherwise
     */
    public boolean insertEvaluation(Evaluation evaluation) {
        clearError();
        ensureStudentEvaluationSchema();

        String studentIdStr = resolveStudentId(evaluation);
        if (studentIdStr == null || studentIdStr.trim().isEmpty()) {
            setError("Student ID is missing. Please reopen the evaluation form.", null);
            return false;
        }

        EvalSqlParts parts = buildEvaluationInsertParts(evaluation);
        String sql = "INSERT INTO studentevaluation (" + parts.columns + ") VALUES (" + parts.placeholders + ")";

        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            bindParams(stmt, parts.values);
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
            System.err.println("[TeacherEvaluationDAO] insertEvaluation primary failed: " + e.getMessage());
            if (isScheduleIdRequiredError(e)) {
                ensureScheduleIdAllowsNull();
                if (isBlank(evaluation.getScheduleId())) {
                    evaluation.setScheduleId(lookupScheduleIdForSession(
                        evaluation.getSessionId(), resolveStudentId(evaluation)));
                }
                EvalSqlParts retryParts = buildEvaluationInsertParts(evaluation);
                String retrySql = "INSERT INTO studentevaluation (" + retryParts.columns + ") VALUES ("
                    + retryParts.placeholders + ")";
                try (PreparedStatement retryStmt = connection.prepareStatement(retrySql)) {
                    bindParams(retryStmt, retryParts.values);
                    if (retryStmt.executeUpdate() > 0) {
                        return true;
                    }
                } catch (SQLException retryError) {
                    System.err.println("[TeacherEvaluationDAO] insertEvaluation scheduleId retry: "
                        + retryError.getMessage());
                }
                evaluation.setScheduleId(null);
                EvalSqlParts nullScheduleParts = buildEvaluationInsertParts(evaluation);
                String nullScheduleSql = "INSERT INTO studentevaluation (" + nullScheduleParts.columns
                    + ") VALUES (" + nullScheduleParts.placeholders + ")";
                try (PreparedStatement retryStmt = connection.prepareStatement(nullScheduleSql)) {
                    bindParams(retryStmt, nullScheduleParts.values);
                    if (retryStmt.executeUpdate() > 0) {
                        return true;
                    }
                } catch (SQLException retryError) {
                    System.err.println("[TeacherEvaluationDAO] insertEvaluation retry without scheduleId: "
                        + retryError.getMessage());
                }
            }
            if (insertLegacyEvaluation(evaluation)) {
                return true;
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

        StringBuilder setClause = new StringBuilder();
        List<Object> params = new ArrayList<>();
        EvalSqlParts helper = new EvalSqlParts();

        helper.addSet("studentId", resolveStudentId(evaluation), setClause, params);
        if (hasEvalColumn("sessionId")) {
            helper.addSet("sessionId", nullToEmpty(evaluation.getSessionId()), setClause, params);
        }
        if (hasEvalColumn("scheduleId")) {
            String scheduleId = resolveScheduleIdString(evaluation);
            if (scheduleId != null) {
                helper.addSet("scheduleId", scheduleId, setClause, params);
            } else {
                addSetNullable(helper, "scheduleId", null, setClause, params);
            }
        }
        if (hasEvalColumn("class_name")) {
            helper.addSet("class_name", nullToEmpty(evaluation.getClassName()), setClause, params);
        }
        if (hasEvalColumn("surah")) {
            helper.addSet("surah", nullToEmpty(evaluation.getSurah()), setClause, params);
        }
        if (hasEvalColumn("ayah_range")) {
            helper.addSet("ayah_range", nullToEmpty(evaluation.getAyahRange()), setClause, params);
        }
        if (hasEvalColumn("session_date")) {
            addSetNullable(helper, "session_date", evaluation.getSessionDate(), setClause, params);
        }
        if (hasEvalColumn("start_time")) {
            addSetNullable(helper, "start_time", evaluation.getStartTime(), setClause, params);
        }
        if (hasEvalColumn("end_time")) {
            addSetNullable(helper, "end_time", evaluation.getEndTime(), setClause, params);
        }
        if (hasEvalColumn("tajweedScore")) {
            helper.addSet("tajweedScore", evaluation.getTajweedScore(), setClause, params);
        }
        if (hasEvalColumn("fluencyScore")) {
            helper.addSet("fluencyScore", evaluation.getFluencyScore(), setClause, params);
        }
        if (hasEvalColumn("accuracyScore")) {
            helper.addSet("accuracyScore", evaluation.getAccuracyScore(), setClause, params);
        }
        if (hasEvalColumn("overall_score")) {
            helper.addSet("overall_score", evaluation.getOverallScore(), setClause, params);
        }
        if (hasEvalColumn("rating")) {
            helper.addSet("rating", evaluation.getRating(), setClause, params);
        }
        if (hasEvalColumn("strength")) {
            helper.addSet("strength", truncate(evaluation.getComments(), 255), setClause, params);
        }
        if (hasEvalColumn("areas_for_improvement")) {
            helper.addSet("areas_for_improvement", nullToEmpty(evaluation.getAreasForImprovement()), setClause, params);
        }
        if (hasEvalColumn("performance_tag")) {
            helper.addSet("performance_tag", nullToEmpty(evaluation.getPerformanceTag()), setClause, params);
        }
        if (hasEvalColumn("next_target_surah")) {
            helper.addSet("next_target_surah",
                nullToEmpty(TextEncodingUtil.normalizeAsciiDash(evaluation.getNextTarget())), setClause, params);
        }
        if (hasEvalColumn("suggestions")) {
            helper.addSet("suggestions", nullToEmpty(evaluation.getSuggestions()), setClause, params);
        }
        if (hasEvalColumn("teacher_comments")) {
            helper.addSet("teacher_comments", nullToEmpty(evaluation.getTeacherComments()), setClause, params);
        }
        if (hasEvalColumn("status")) {
            helper.addSet("status", resolvedEvalStatus(evaluation), setClause, params);
        }
        if (hasEvalColumn("weakness")) {
            helper.addSet("weakness", truncate(evaluation.getAreasForImprovement(), 255), setClause, params);
        }
        if (hasEvalColumn("studentImprovements")) {
            helper.addSet("studentImprovements", nullToEmpty(evaluation.getSuggestions()), setClause, params);
        }
        if (hasEvalColumn("nextTarget")) {
            helper.addSet("nextTarget",
                nullToEmpty(TextEncodingUtil.normalizeAsciiDash(evaluation.getNextTarget())), setClause, params);
        }
        if (hasEvalColumn("comments")) {
            helper.addSet("comments", nullToEmpty(evaluation.getComments()), setClause, params);
        }
        if (hasEvalColumn("updated_at")) {
            if (setClause.length() > 0) {
                setClause.append(", ");
            }
            setClause.append("updated_at = NOW()");
        }

        String evalIdStr = resolveEvaluationId(evaluation);
        List<String> teacherIds = teacherIdVariants(resolveTeacherId(evaluation));
        List<String> evalIdVariants = evaluationIdVariants(evaluation, evalIdStr);
        for (String evalIdVariant : evalIdVariants) {
            String query = "UPDATE studentevaluation SET " + setClause
                + " WHERE studentEvaluationId = ? AND "
                + teacherIdMatchClause("teacherId", teacherIds);
            try (PreparedStatement stmt = connection.prepareStatement(query)) {
                int index = 1;
                for (Object param : params) {
                    bindJdbcParam(stmt, index++, param);
                }
                stmt.setString(index++, evalIdVariant);
                bindTeacherIdVariants(stmt, index, resolveTeacherId(evaluation));
                int rowsAffected = stmt.executeUpdate();
                if (rowsAffected > 0) {
                    return true;
                }
            } catch (SQLException e) {
                setError("Database error while updating evaluation: " + e.getMessage(), e);
            }
        }

        if (evaluation.getSessionId() != null && !evaluation.getSessionId().trim().isEmpty()
                && hasEvalColumn("sessionId")) {
            String query = "UPDATE studentevaluation SET " + setClause
                + " WHERE sessionId = ? AND " + teacherIdMatchClause("teacherId", teacherIds);
            try (PreparedStatement stmt = connection.prepareStatement(query)) {
                int index = 1;
                for (Object param : params) {
                    bindJdbcParam(stmt, index++, param);
                }
                stmt.setString(index++, evaluation.getSessionId().trim());
                bindTeacherIdVariants(stmt, index, resolveTeacherId(evaluation));
                int rowsAffected = stmt.executeUpdate();
                if (rowsAffected > 0) {
                    return true;
                }
            } catch (SQLException e) {
                setError("Database error while updating evaluation by session: " + e.getMessage(), e);
            }
        }

        setError("Evaluation record not found for update. It may belong to another teacher.", null);
        return false;
    }

    private List<String> evaluationIdVariants(Evaluation evaluation, String resolvedEvalId) {
        Set<String> ids = new LinkedHashSet<>();
        if (resolvedEvalId != null && !resolvedEvalId.trim().isEmpty()) {
            ids.add(resolvedEvalId.trim());
        }
        int numericId = evaluation.getEvaluationId();
        if (numericId > 0) {
            ids.add("SE" + String.format("%03d", numericId));
            ids.add(String.valueOf(numericId));
        }
        return new ArrayList<>(ids);
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
        List<String> teacherIds = teacherIdVariants(teacherId);
        String ayahRange = TalaqqiSchemaUtil.ayahRangeExpr(connection);
        String teacherClause = teacherIdMatchClause("cs.teacherId", teacherIds);
        String query =
            "SELECT DISTINCT cb.bookingId, ts.sessionId, cb.studentId, s.studentName AS student_name, " +
            "cs.className AS class_name, " +
            pendingSessionSurahColumns("ts.sessionId") +
            ayahRange + " AS ayah_range, " +
            "DATE_FORMAT(cs.scheduleDate,'%Y-%m-%d') AS session_date, " +
            "DATE_FORMAT(cs.startTime,'%H:%i:%s') AS start_time, " +
            "DATE_FORMAT(cs.endTime,'%H:%i:%s') AS end_time, " +
            "cs.teacherId " +
            "FROM classbooking cb " +
            "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId " +
            "JOIN student s ON cb.studentId = s.studentId " +
            TalaqqiSchemaUtil.leftJoinSessionToBooking(connection) +
            "WHERE " + teacherClause + " "
            + "AND UPPER(TRIM(COALESCE(cb.bookingStatus, ''))) IN ('COMPLETED', 'COMPLETE', 'DONE') " +
            "AND NOT EXISTS ( " +
            "  SELECT 1 FROM studentevaluation se " +
            "  WHERE se.teacherId = cs.teacherId AND se.studentId = cb.studentId " +
            "  AND (" + evalNotExistsBlocksPending() + ") " +
            ") " +
            "ORDER BY cs.scheduleDate DESC, cs.startTime DESC";

        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            bindTeacherIdVariants(stmt, 1, teacherId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                evaluations.add(mapPendingSessionRow(rs));
            }
        } catch (SQLException e) {
            setError("Unable to load completed sessions needing evaluation", e);
            evaluations.addAll(getPendingSessionsFallback(teacherId));
        }
        if (evaluations.isEmpty()) {
            evaluations.addAll(getPendingSessionsFallback(teacherId));
            evaluations.addAll(getPendingSessionsFromEndedOnly(teacherId));
            evaluations.addAll(getPendingSessionsFromAttendance(teacherId));
        }
        return evaluations;
    }

    /** Attended sessions (Present/Late) that still need a teacher evaluation row. */
    private List<Evaluation> getPendingSessionsFromAttendance(String teacherId) {
        List<Evaluation> evaluations = new ArrayList<>();
        List<String> teacherIds = teacherIdVariants(teacherId);
        String sessionTable = TalaqqiSchemaUtil.sessionTable(connection);
        String ayahRange = TalaqqiSchemaUtil.ayahRangeExpr(connection);
        String teacherClause = teacherIdMatchClause("cs.teacherId", teacherIds);
        String sessionIdExpr = "(SELECT ts2.sessionId FROM " + sessionTable + " ts2 "
            + "WHERE ts2.scheduleId = a.scheduleId "
            + "AND (ts2.sessionDate = a.attendanceDate OR ts2.sessionDate IS NULL) "
            + "ORDER BY ts2.sessionDate DESC LIMIT 1)";
        String query =
            "SELECT cb.bookingId, " + sessionIdExpr + " AS sessionId, a.studentId, "
            + "s.studentName AS student_name, cs.className AS class_name, "
            + pendingSessionSurahColumns(sessionIdExpr) + ayahRange + " AS ayah_range, "
            + "DATE_FORMAT(a.attendanceDate,'%Y-%m-%d') AS session_date, "
            + "DATE_FORMAT(cs.startTime,'%H:%i:%s') AS start_time, "
            + "DATE_FORMAT(cs.endTime,'%H:%i:%s') AS end_time, cs.teacherId "
            + "FROM attendance a "
            + "JOIN classschedule cs ON a.scheduleId = cs.scheduleId "
            + "JOIN classbooking cb ON cb.scheduleId = cs.scheduleId AND cb.studentId = a.studentId "
            + "JOIN student s ON a.studentId = s.studentId "
            + "WHERE " + teacherClause + " "
            + "AND a.attendanceStatus IN ('Present', 'Late') "
            + "AND NOT EXISTS ( "
            + "  SELECT 1 FROM studentevaluation se "
            + "  WHERE se.teacherId = cs.teacherId AND se.studentId = a.studentId "
            + "  AND (se.sessionId = " + sessionIdExpr + " OR (" + sessionIdExpr + " IS NULL AND "
            + evalCompletedPredicate("se") + ")) "
            + ") "
            + "ORDER BY a.attendanceDate DESC, cs.startTime DESC";
        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            bindTeacherIdVariants(stmt, 1, teacherId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    evaluations.add(mapPendingSessionRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[TeacherEvaluationDAO] getPendingSessionsFromAttendance: " + e.getMessage());
        }
        return evaluations;
    }

    /**
     * Combine DB pending rows with completed sessions still needing evaluation.
     * Fills missing date/time/surah on existing rows from session schedule data.
     */
    public List<Evaluation> mergePendingWithSessions(List<Evaluation> pendingEvaluations,
                                                     List<Evaluation> pendingSessions) {
        if (pendingEvaluations == null) {
            pendingEvaluations = new ArrayList<>();
        }
        if (pendingSessions == null || pendingSessions.isEmpty()) {
            enrichPendingEvaluations(pendingEvaluations);
            return pendingEvaluations;
        }

        for (Evaluation sessionRow : pendingSessions) {
            if (sessionRow == null) {
                continue;
            }
            Evaluation matched = findMatchingPendingEvaluation(pendingEvaluations, sessionRow);
            if (matched != null) {
                fillMissingEvaluationDetails(matched, sessionRow);
            } else {
                pendingEvaluations.add(sessionRow);
            }
        }
        enrichPendingEvaluations(pendingEvaluations);
        return pendingEvaluations;
    }

    /** Backfill date/time/surah when join or minimal insert left fields empty. */
    public void enrichPendingEvaluations(List<Evaluation> evaluations) {
        if (evaluations == null || evaluations.isEmpty()) {
            return;
        }
        for (Evaluation evaluation : evaluations) {
            if (needsSessionMetadata(evaluation)) {
                enrichSinglePendingEvaluation(evaluation);
            }
        }
    }

    private boolean needsSessionMetadata(Evaluation evaluation) {
        return isBlank(evaluation.getSessionDate())
            || isBlank(evaluation.getStartTime())
            || isBlank(evaluation.getEndTime())
            || isBlank(evaluation.getSurah());
    }

    private Evaluation findMatchingPendingEvaluation(List<Evaluation> pendingEvaluations,
                                                     Evaluation sessionRow) {
        String sessionId = sessionRow.getSessionId();
        if (!isBlank(sessionId)) {
            for (Evaluation existing : pendingEvaluations) {
                if (sessionId.equals(existing.getSessionId())) {
                    return existing;
                }
            }
        }
        if (!isBlank(sessionRow.getStudentId())) {
            for (Evaluation existing : pendingEvaluations) {
                if (sessionRow.getStudentId().equals(existing.getStudentId())
                        && isBlank(existing.getSessionDate())
                        && isBlank(existing.getStartTime())) {
                    return existing;
                }
            }
        }
        return null;
    }

    private void fillMissingEvaluationDetails(Evaluation target, Evaluation source) {
        if (isBlank(target.getSessionDate()) && !isBlank(source.getSessionDate())) {
            target.setSessionDate(source.getSessionDate());
        }
        if (isBlank(target.getStartTime()) && !isBlank(source.getStartTime())) {
            target.setStartTime(source.getStartTime());
        }
        if (isBlank(target.getEndTime()) && !isBlank(source.getEndTime())) {
            target.setEndTime(source.getEndTime());
        }
        if (isBlank(target.getClassName()) && !isBlank(source.getClassName())) {
            target.setClassName(source.getClassName());
        }
        if (isBlank(target.getSurah()) && !isBlank(source.getSurah())) {
            target.setSurah(source.getSurah());
        }
        if (isBlank(target.getAyahRange()) && !isBlank(source.getAyahRange())) {
            target.setAyahRange(source.getAyahRange());
        }
        if (target.getSurahNumber() <= 0 && source.getSurahNumber() > 0) {
            target.setSurahNumber(source.getSurahNumber());
        }
        if (target.getAyahNumber() <= 0 && source.getAyahNumber() > 0) {
            target.setAyahNumber(source.getAyahNumber());
        }
        if (isBlank(target.getSessionId()) && !isBlank(source.getSessionId())) {
            target.setSessionId(source.getSessionId());
        }
        if (isBlank(target.getTeacherName()) && !isBlank(source.getTeacherName())) {
            target.setTeacherName(source.getTeacherName());
        }
    }

    private void enrichSinglePendingEvaluation(Evaluation evaluation) {
        if (evaluation == null) {
            return;
        }
        String sessionId = evaluation.getSessionId();
        if (!isBlank(sessionId)) {
            loadSessionMetadataIntoEvaluation(evaluation, sessionId, null);
        }
        String scheduleId = evaluation.getScheduleId();
        if (isBlank(scheduleId) && !isBlank(sessionId)) {
            scheduleId = lookupScheduleIdForSession(sessionId, evaluation.getStudentId());
            if (!isBlank(scheduleId)) {
                evaluation.setScheduleId(scheduleId);
            }
        }
        if (!isBlank(scheduleId)) {
            loadSessionMetadataIntoEvaluation(evaluation, null, scheduleId);
        }
        if (needsSessionMetadata(evaluation)) {
            loadAttendanceMetadataIntoEvaluation(evaluation);
        }
    }

    private void loadAttendanceMetadataIntoEvaluation(Evaluation evaluation) {
        if (evaluation == null || isBlank(evaluation.getStudentId())) {
            return;
        }
        String ayahRange = TalaqqiSchemaUtil.ayahRangeExpr(connection);
        List<String> studentIds = studentIdVariants(evaluation.getStudentId());
        String studentClause = studentIdMatchClause("a.studentId", studentIds);
        String scheduleFilter = isBlank(evaluation.getScheduleId()) ? "" : "AND a.scheduleId = ? ";
        String sql =
            "SELECT DATE_FORMAT(a.attendanceDate,'%Y-%m-%d') AS session_date, "
            + "DATE_FORMAT(cs.startTime,'%H:%i:%s') AS start_time, "
            + "DATE_FORMAT(cs.endTime,'%H:%i:%s') AS end_time, "
            + "cs.className AS class_name, "
            + "CAST(COALESCE(NULLIF(cs.classSurah, 0), 0) AS CHAR) AS surah, "
            + "COALESCE(NULLIF(cs.classSurah, 0), 0) AS quran_surah_number, "
            + "COALESCE(NULLIF(cs.classAyah, 0), 0) AS quran_ayah_number, "
            + ayahRange + " AS ayah_range "
            + "FROM attendance a "
            + "INNER JOIN classschedule cs ON a.scheduleId = cs.scheduleId "
            + "WHERE " + studentClause + " "
            + scheduleFilter
            + "AND UPPER(TRIM(a.attendanceStatus)) IN ('PRESENT', 'LATE') "
            + "AND a.joinTime IS NOT NULL "
            + "ORDER BY a.attendanceDate DESC, cs.startTime DESC LIMIT 1";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            int idx = bindStudentIdVariants(stmt, 1, evaluation.getStudentId());
            if (!isBlank(evaluation.getScheduleId())) {
                stmt.setString(idx++, evaluation.getScheduleId().trim());
            }
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    return;
                }
                if (isBlank(evaluation.getSessionDate())) {
                    evaluation.setSessionDate(rs.getString("session_date"));
                }
                if (isBlank(evaluation.getStartTime())) {
                    evaluation.setStartTime(rs.getString("start_time"));
                }
                if (isBlank(evaluation.getEndTime())) {
                    evaluation.setEndTime(rs.getString("end_time"));
                }
                if (isBlank(evaluation.getClassName())) {
                    evaluation.setClassName(rs.getString("class_name"));
                }
                if (isBlank(evaluation.getSurah()) || isBlank(evaluation.getAyahRange())) {
                    applyQuranFieldsFromResultSet(evaluation, rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[TeacherEvaluationDAO] loadAttendanceMetadataIntoEvaluation: "
                + e.getMessage());
        }
    }

    private List<String> studentIdVariants(String studentId) {
        List<String> ids = new ArrayList<>();
        if (studentId == null || studentId.trim().isEmpty()) {
            return ids;
        }
        String trimmed = studentId.trim();
        ids.add(trimmed);
        String digits = trimmed.replaceAll("[^0-9]", "");
        if (!digits.isEmpty()) {
            int n = Integer.parseInt(digits);
            String formatted = "S" + String.format("%03d", n);
            String plain = String.valueOf(n);
            if (!ids.contains(formatted)) {
                ids.add(formatted);
            }
            if (!ids.contains(plain)) {
                ids.add(plain);
            }
        }
        return ids;
    }

    private String studentIdMatchClause(String column, List<String> variants) {
        if (variants == null || variants.isEmpty()) {
            return column + " = ?";
        }
        if (variants.size() == 1) {
            return column + " = ?";
        }
        StringBuilder clause = new StringBuilder(column).append(" IN (");
        for (int i = 0; i < variants.size(); i++) {
            if (i > 0) {
                clause.append(", ");
            }
            clause.append("?");
        }
        clause.append(")");
        return clause.toString();
    }

    private int bindStudentIdVariants(PreparedStatement stmt, int startIndex, String studentId)
            throws SQLException {
        List<String> variants = studentIdVariants(studentId);
        if (variants.isEmpty()) {
            stmt.setString(startIndex, studentId);
            return startIndex + 1;
        }
        for (int i = 0; i < variants.size(); i++) {
            stmt.setString(startIndex + i, variants.get(i));
        }
        return startIndex + variants.size();
    }

    private boolean loadSessionMetadataIntoEvaluation(Evaluation evaluation,
                                                      String sessionId,
                                                      String scheduleId) {
        String ayahRange = TalaqqiSchemaUtil.ayahRangeExpr(connection);
        String sessionTable = TalaqqiSchemaUtil.sessionTable(connection);
        String query;
        if (!isBlank(sessionId)) {
            query = "SELECT DATE_FORMAT(COALESCE(ts.sessionDate, cs.scheduleDate),'%Y-%m-%d') AS session_date, "
                + "DATE_FORMAT(cs.startTime,'%H:%i:%s') AS start_time, "
                + "DATE_FORMAT(cs.endTime,'%H:%i:%s') AS end_time, "
                + "cs.className AS class_name, "
                + pendingSessionSurahColumns("ts.sessionId")
                + ayahRange + " AS ayah_range "
                + "FROM " + sessionTable + " ts "
                + "JOIN classschedule cs ON ts.scheduleId = cs.scheduleId "
                + "WHERE ts.sessionId = ? LIMIT 1";
        } else {
            query = "SELECT DATE_FORMAT(cs.scheduleDate,'%Y-%m-%d') AS session_date, "
                + "DATE_FORMAT(cs.startTime,'%H:%i:%s') AS start_time, "
                + "DATE_FORMAT(cs.endTime,'%H:%i:%s') AS end_time, "
                + "cs.className AS class_name, "
                + pendingSessionSurahColumns(
                    "(SELECT ts2.sessionId FROM " + sessionTable + " ts2 "
                    + "WHERE ts2.scheduleId = cs.scheduleId LIMIT 1)")
                + ayahRange + " AS ayah_range "
                + "FROM classschedule cs "
                + "WHERE cs.scheduleId = ? LIMIT 1";
        }

        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            if (!isBlank(sessionId)) {
                stmt.setString(1, sessionId.trim());
            } else {
                stmt.setString(1, scheduleId.trim());
            }
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    return false;
                }
                if (isBlank(evaluation.getSessionDate())) {
                    evaluation.setSessionDate(rs.getString("session_date"));
                }
                if (isBlank(evaluation.getStartTime())) {
                    evaluation.setStartTime(rs.getString("start_time"));
                }
                if (isBlank(evaluation.getEndTime())) {
                    evaluation.setEndTime(rs.getString("end_time"));
                }
                if (isBlank(evaluation.getClassName())) {
                    evaluation.setClassName(rs.getString("class_name"));
                }
                if (isBlank(evaluation.getSurah()) || isBlank(evaluation.getAyahRange())) {
                    applyQuranFieldsFromResultSet(evaluation, rs);
                }
                return true;
            }
        } catch (SQLException e) {
            System.err.println("[TeacherEvaluationDAO] enrichSinglePendingEvaluation: " + e.getMessage());
            return false;
        }
    }

    /** Completed bookings without evaluation — does not require talaqqisession join. */
    private List<Evaluation> getPendingSessionsFallback(String teacherId) {
        List<Evaluation> evaluations = new ArrayList<>();
        List<String> teacherIds = teacherIdVariants(teacherId);
        String ayahRange = TalaqqiSchemaUtil.ayahRangeExpr(connection);
        String sessionLookup = TalaqqiSchemaUtil.sessionIdForBookingSubquery(connection);
        String teacherClause = teacherIdMatchClause("cs.teacherId", teacherIds);
        String query =
            "SELECT cb.bookingId, " + sessionLookup + " AS sessionId, cb.studentId, "
            + "s.studentName AS student_name, cs.className AS class_name, "
            + pendingSessionSurahColumns(sessionLookup) + ayahRange + " AS ayah_range, "
            + "DATE_FORMAT(cs.scheduleDate,'%Y-%m-%d') AS session_date, "
            + "DATE_FORMAT(cs.startTime,'%H:%i:%s') AS start_time, "
            + "DATE_FORMAT(cs.endTime,'%H:%i:%s') AS end_time, cs.teacherId "
            + "FROM classbooking cb "
            + "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId "
            + "JOIN student s ON cb.studentId = s.studentId "
            + "WHERE " + teacherClause + " "
            + "AND UPPER(TRIM(COALESCE(cb.bookingStatus, ''))) IN ('COMPLETED', 'COMPLETE', 'DONE') "
            + "AND NOT EXISTS ( "
            + "  SELECT 1 FROM studentevaluation se "
            + "  WHERE se.teacherId = cs.teacherId AND se.studentId = cb.studentId "
            + "  AND (" + evalNotExistsBlocksPendingFallback() + ") "
            + ") "
            + "ORDER BY cs.scheduleDate DESC, cs.startTime DESC";

        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            bindTeacherIdVariants(stmt, 1, teacherId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    evaluations.add(mapPendingSessionRow(rs));
                }
            }
        } catch (SQLException e) {
            setError("Fallback pending session query failed", e);
        }
        return evaluations;
    }

    /** Sessions with sessionDate set but booking not marked Completed. */
    private List<Evaluation> getPendingSessionsFromEndedOnly(String teacherId) {
        List<Evaluation> evaluations = new ArrayList<>();
        List<String> teacherIds = teacherIdVariants(teacherId);
        String sessionTable = TalaqqiSchemaUtil.sessionTable(connection);
        String ayahRange = TalaqqiSchemaUtil.ayahRangeExpr(connection);
        String bookingLink = TalaqqiSchemaUtil.hasColumn(connection, sessionTable, "bookingId")
            ? "((ts.bookingId IS NOT NULL AND ts.bookingId <> '' AND ts.bookingId = cb.bookingId) "
                + "OR ((ts.bookingId IS NULL OR ts.bookingId = '') AND ts.scheduleId = cb.scheduleId))"
            : "ts.scheduleId = cb.scheduleId";
        String teacherClause = teacherIdMatchClause("cs.teacherId", teacherIds);
        String sessionLookup = "ts.sessionId";
        String query =
            "SELECT cb.bookingId, ts.sessionId, cb.studentId, s.studentName AS student_name, "
            + "cs.className AS class_name, "
            + pendingSessionSurahColumns("ts.sessionId") + ayahRange + " AS ayah_range, "
            + "DATE_FORMAT(COALESCE(ts.sessionDate, cs.scheduleDate),'%Y-%m-%d') AS session_date, "
            + "DATE_FORMAT(cs.startTime,'%H:%i:%s') AS start_time, "
            + "DATE_FORMAT(cs.endTime,'%H:%i:%s') AS end_time, cs.teacherId "
            + "FROM " + sessionTable + " ts "
            + "JOIN classschedule cs ON ts.scheduleId = cs.scheduleId "
            + "JOIN classbooking cb ON " + bookingLink + " "
            + "JOIN student s ON cb.studentId = s.studentId "
            + "WHERE " + teacherClause + " AND ts.sessionDate IS NOT NULL "
            + "AND NOT EXISTS ( "
            + "  SELECT 1 FROM studentevaluation se "
            + "  WHERE se.teacherId = cs.teacherId AND se.studentId = cb.studentId "
            + "  AND se.sessionId = " + sessionLookup
            + ") "
            + "ORDER BY ts.sessionDate DESC, cs.startTime DESC";
        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            bindTeacherIdVariants(stmt, 1, teacherId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    evaluations.add(mapPendingSessionRow(rs));
                }
            }
        } catch (SQLException e) {
            setError("Ended-session pending query failed", e);
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
            "SELECT ts.sessionId, cb.scheduleId, cb.studentId, cs.teacherId, cs.className, " +
            pendingSessionSurahColumns("ts.sessionId") + ayahRange + " AS ayah_range, " +
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
                    return ensurePendingEvaluationFromSessionFallback(sessionId.trim(), teacherId.trim());
                }

                Evaluation evaluation = new Evaluation();
                evaluation.setSessionId(rs.getString("sessionId"));
                String scheduleId = readScheduleIdColumn(rs);
                if (scheduleId != null) {
                    evaluation.setScheduleId(scheduleId);
                }
                evaluation.setStudentId(rs.getString("studentId"));
                evaluation.setTeacherId(rs.getString("teacherId"));
                evaluation.setStudentName(rs.getString("student_name"));
                evaluation.setClassName(rs.getString("className"));
                applyQuranFieldsFromResultSet(evaluation, rs);
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
            return ensurePendingEvaluationFromSessionFallback(sessionId.trim(), teacherId.trim());
        }
    }

    private boolean ensurePendingEvaluationFromSessionFallback(String sessionId, String teacherId) {
        String sessionTable = TalaqqiSchemaUtil.sessionTable(connection);
        String ayahRange = TalaqqiSchemaUtil.ayahRangeExpr(connection);
        String bookingLink = TalaqqiSchemaUtil.hasColumn(connection, sessionTable, "bookingId")
            ? "((ts.bookingId IS NOT NULL AND ts.bookingId <> '' AND ts.bookingId = cb.bookingId) "
                + "OR ((ts.bookingId IS NULL OR ts.bookingId = '') AND ts.scheduleId = cb.scheduleId))"
            : "ts.scheduleId = cb.scheduleId";
        List<String> teacherIds = teacherIdVariants(teacherId);
        String teacherClause = teacherIdMatchClause("cs.teacherId", teacherIds);
        String query =
            "SELECT ts.sessionId, cb.scheduleId, cb.studentId, cs.teacherId, cs.className, "
            + pendingSessionSurahColumns("ts.sessionId") + ayahRange + " AS ayah_range, "
            + "DATE_FORMAT(COALESCE(ts.sessionDate, cs.scheduleDate),'%Y-%m-%d') AS session_date, "
            + "DATE_FORMAT(cs.startTime,'%H:%i:%s') AS start_time, "
            + "DATE_FORMAT(cs.endTime,'%H:%i:%s') AS end_time, "
            + "s.studentName AS student_name "
            + "FROM " + sessionTable + " ts "
            + "JOIN classschedule cs ON ts.scheduleId = cs.scheduleId "
            + "JOIN classbooking cb ON " + bookingLink + " "
            + "LEFT JOIN student s ON cb.studentId = s.studentId "
            + "WHERE ts.sessionId = ? AND " + teacherClause + " "
            + "LIMIT 1";
        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setString(1, sessionId);
            bindTeacherIdVariants(stmt, 2, teacherId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    return false;
                }
                Evaluation evaluation = new Evaluation();
                evaluation.setSessionId(rs.getString("sessionId"));
                String scheduleId = readScheduleIdColumn(rs);
                if (scheduleId != null) {
                    evaluation.setScheduleId(scheduleId);
                }
                evaluation.setStudentId(rs.getString("studentId"));
                evaluation.setTeacherId(rs.getString("teacherId"));
                evaluation.setStudentName(rs.getString("student_name"));
                evaluation.setClassName(rs.getString("className"));
                applyQuranFieldsFromResultSet(evaluation, rs);
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
            setError("Fallback pending evaluation for session " + sessionId, e);
            return false;
        }
    }

    private boolean insertMinimalPendingEvaluation(Evaluation evaluation) {
        hydrateLegacyKeys(evaluation);
        String evalIdStr = resolveEvaluationId(evaluation);
        String teacherIdStr = resolveTeacherId(evaluation);
        String studentIdStr = resolveStudentId(evaluation);
        String sessionId = nullToEmpty(evaluation.getSessionId());

        EvalSqlParts parts = new EvalSqlParts();
        if (hasEvalColumn("studentEvaluationId")) {
            parts.add("studentEvaluationId", evalIdStr);
        }
        parts.add("studentId", studentIdStr);
        parts.add("teacherId", teacherIdStr);
        sqlAdd(parts, "sessionId", sessionId);
        sqlAddScheduleId(parts, evaluation);
        sqlAddNullable(parts, "session_date", evaluation.getSessionDate());
        sqlAddNullable(parts, "start_time", evaluation.getStartTime());
        sqlAddNullable(parts, "end_time", evaluation.getEndTime());
        sqlAddNullable(parts, "surah", evaluation.getSurah());
        sqlAddNullable(parts, "ayah_range", evaluation.getAyahRange());
        sqlAddNullable(parts, "class_name", evaluation.getClassName());
        if (hasEvalColumn("status")) {
            parts.add("status", "PENDING");
        }

        String sql = "INSERT INTO studentevaluation (" + parts.columns + ") VALUES (" + parts.placeholders + ")";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            bindParams(stmt, parts.values);
            if (stmt.executeUpdate() > 0) {
                return true;
            }
        } catch (SQLException e) {
            System.err.println("[TeacherEvaluationDAO] minimal pending insert: " + e.getMessage());
        }

        if (!hasEvalColumn("studentEvaluationId")) {
            return false;
        }

        EvalSqlParts fallback = new EvalSqlParts();
        fallback.add("studentId", studentIdStr);
        fallback.add("teacherId", teacherIdStr);
        sqlAdd(fallback, "sessionId", sessionId);
        sqlAddScheduleId(fallback, evaluation);
        sqlAddNullable(fallback, "session_date", evaluation.getSessionDate());
        sqlAddNullable(fallback, "start_time", evaluation.getStartTime());
        sqlAddNullable(fallback, "end_time", evaluation.getEndTime());
        sqlAddNullable(fallback, "surah", evaluation.getSurah());
        sqlAddNullable(fallback, "ayah_range", evaluation.getAyahRange());
        sqlAddNullable(fallback, "class_name", evaluation.getClassName());
        if (hasEvalColumn("status")) {
            fallback.add("status", "PENDING");
        }
        String fallbackSql = "INSERT INTO studentevaluation (" + fallback.columns + ") VALUES ("
            + fallback.placeholders + ")";
        try (PreparedStatement stmt = connection.prepareStatement(fallbackSql)) {
            bindParams(stmt, fallback.values);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            setError("Unable to create minimal pending evaluation: " + e.getMessage(), e);
            return false;
        }
    }

    private String buildEvaluationListSelectSql() {
        String createdCol = TalaqqiSchemaUtil.studentEvalCreatedColumn(connection, "se");
        String updatedCol = TalaqqiSchemaUtil.studentEvalUpdatedColumn(connection, "se");
        String statusCol = hasEvalColumn("status") ? "se.status" : "'PENDING' AS status";
        String sessionRef = evalSessionIdRef();

        return "SELECT " +
            "se.studentEvaluationId, " +
            "se.studentId, " +
            "COALESCE(s.studentName, '') AS student_name, " +
            evalClassNameExpr() + ", " +
            evalSurahExpr() + ", " +
            evalAyahExpr() + ", " +
            evalSessionDateExpr() + ", " +
            evalStartTimeExpr() + ", " +
            evalEndTimeExpr() + ", " +
            quranSurahNumberSql(sessionRef) + " AS quran_surah_number, " +
            quranAyahNumberSql(sessionRef) + " AS quran_ayah_number, " +
            "COALESCE(NULLIF(se.teacherId, ''), cs.teacherId, '') AS teacherId, " +
            "COALESCE(NULLIF(t.teacherName, ''), '') AS teacher_name, " +
            (hasEvalColumn("sessionId") ? "se.sessionId" : "NULL AS sessionId") + ", " +
            (hasEvalColumn("scheduleId") ? "se.scheduleId" : "NULL AS scheduleId") + ", se.tajweedScore, se.fluencyScore, se.accuracyScore, " +
            evalSelectColumn("overall_score") + ", " +
            evalSelectColumn("rating") + ", " +
            evalSelectColumnOrAlias("strength", "strength") + ", " +
            evalSelectColumn("areas_for_improvement") + ", " +
            evalSelectColumn("performance_tag") + ", " +
            evalSelectColumn("next_target_surah") + ", " +
            evalSelectColumn("suggestions") + ", " +
            evalSelectColumn("teacher_comments") + ", " +
            statusCol + ", " +
            evalSelectColumnOrAlias("weakness", "weakness", "areas_for_improvement") + ", " +
            evalSelectColumnOrAlias("studentImprovements", "studentImprovements", "suggestions") + ", " +
            evalSelectColumnOrAlias("nextTarget", "nextTarget", "next_target_surah") + ", " +
            evalSelectColumnOrAlias("comments", "comments", "teacher_comments") + ", " +
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
        String query = buildEvaluationListSelectSql()
            + "WHERE se.teacherId = ? AND " + evalPendingPredicate("se") + " "
            + "ORDER BY " + createdCol + " DESC";

        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setString(1, teacherId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    evaluations.add(mapResultSetToEvaluation(rs));
                }
            }
        } catch (SQLException e) {
            setError("Fallback pending evaluation query failed", e);
            tryLegacyPendingEvaluationsFallback(teacherId, evaluations);
        }
        return evaluations;
    }

    /** Last-resort: only columns guaranteed on the oldest production dump. */
    private void tryLegacyPendingEvaluationsFallback(String teacherId, List<Evaluation> evaluations) {
        String sessionCol = hasEvalColumn("sessionId") ? "se.sessionId" : "NULL AS sessionId";
        String query =
            "SELECT se.studentEvaluationId, se.studentId, " + sessionCol + ", se.teacherId, "
            + "se.tajweedScore, se.fluencyScore, se.accuracyScore, "
            + evalSelectColumnOrAlias("strength", "strength") + ", "
            + evalSelectColumnOrAlias("weakness", "weakness", "areas_for_improvement") + ", "
            + evalSelectColumnOrAlias("studentImprovements", "studentImprovements", "suggestions") + ", "
            + evalSelectColumnOrAlias("nextTarget", "nextTarget", "next_target_surah") + ", "
            + evalSelectColumnOrAlias("comments", "comments", "teacher_comments") + ", "
            + "COALESCE(s.studentName, '') AS student_name, '' AS teacher_name, "
            + "'' AS class_name, '' AS surah, '' AS ayah_range, "
            + "'' AS session_date, '' AS start_time, '' AS end_time, "
            + "0 AS quran_surah_number, 0 AS quran_ayah_number, "
            + "NULL AS overall_score, 0 AS rating, "
            + "NULL AS areas_for_improvement, NULL AS performance_tag, NULL AS next_target_surah, "
            + "NULL AS suggestions, NULL AS teacher_comments, 'PENDING' AS status, "
            + "NULL AS createdAt, NULL AS updated_at "
            + "FROM studentevaluation se "
            + "LEFT JOIN student s ON se.studentId = s.studentId "
            + "WHERE " + teacherIdMatchClause("se.teacherId", teacherIdVariants(teacherId))
            + " AND " + evalPendingPredicate("se");

        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            bindTeacherIdVariants(stmt, 1, teacherId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    evaluations.add(mapResultSetToEvaluation(rs));
                }
            }
        } catch (SQLException e) {
            setError("Legacy pending evaluation query failed", e);
        }
    }

    /**
     * Student feedback about this teacher (studentfeedback table).
     */
    public void ensureStudentFeedbackSchema() {
        String ddl =
            "CREATE TABLE IF NOT EXISTS studentfeedback ("
            + "feedbackId VARCHAR(50) NOT NULL PRIMARY KEY, "
            + "studentId VARCHAR(50) NOT NULL, "
            + "teacherId VARCHAR(50) NOT NULL, "
            + "sessionId VARCHAR(50) DEFAULT NULL, "
            + "scheduleId VARCHAR(10) DEFAULT NULL, "
            + "rating INT NOT NULL DEFAULT 0, "
            + "comments TEXT, "
            + "suggestions TEXT, "
            + "createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, "
            + "KEY idx_sf_student (studentId), "
            + "KEY idx_sf_teacher (teacherId), "
            + "KEY idx_sf_session (sessionId)"
            + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
        try (Statement stmt = connection.createStatement()) {
            stmt.execute(ddl);
            try {
                stmt.execute("ALTER TABLE studentfeedback MODIFY scheduleId VARCHAR(10) DEFAULT NULL");
            } catch (SQLException ignored) {}
        } catch (SQLException e) {
            System.err.println("[TeacherEvaluationDAO] ensureStudentFeedbackSchema: " + e.getMessage());
        }
    }

    /**
     * Student feedback about this teacher (studentfeedback table).
     */
    public List<Evaluation> getStudentFeedbackForTeacher(String teacherId) {
        List<Evaluation> evaluations = new ArrayList<>();
        ensureStudentFeedbackSchema();

        List<String> teacherIds = teacherIdMatchValues(teacherId);
        if (teacherIds.isEmpty()) {
            return evaluations;
        }

        evaluations = queryStudentFeedbackForTeacher(teacherId, teacherIds, true);
        if (evaluations.isEmpty()) {
            evaluations = queryStudentFeedbackForTeacher(teacherId, teacherIds, false);
        }
        if (evaluations.isEmpty() && countStudentFeedbackForTeacher(teacherIds) > 0) {
            loadStudentFeedbackFallback(teacherIds, evaluations);
        }
        return evaluations;
    }

    private int countStudentFeedbackForTeacher(List<String> teacherIds) {
        StringBuilder inClause = new StringBuilder();
        for (int i = 0; i < teacherIds.size(); i++) {
            if (i > 0) {
                inClause.append(", ");
            }
            inClause.append("?");
        }
        String query = "SELECT COUNT(*) AS cnt FROM studentfeedback WHERE teacherId IN (" + inClause + ")";
        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            bindTeacherIdParams(stmt, teacherIds);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cnt");
                }
            }
        } catch (SQLException e) {
            System.err.println("[TeacherEvaluationDAO] countStudentFeedbackForTeacher: " + e.getMessage());
        }
        return 0;
    }

    private List<Evaluation> queryStudentFeedbackForTeacher(String teacherId, List<String> teacherIds,
                                                             boolean withSessionJoin) {
        List<Evaluation> evaluations = new ArrayList<>();
        StringBuilder inClause = new StringBuilder();
        for (int i = 0; i < teacherIds.size(); i++) {
            if (i > 0) {
                inClause.append(", ");
            }
            inClause.append("?");
        }

        String createdCol = feedbackCreatedAtColumn();
        String ayahRange = TalaqqiSchemaUtil.ayahRangeExpr(connection);
        StringBuilder query = new StringBuilder();
        query.append("SELECT sf.feedbackId, sf.sessionId, sf.rating, sf.comments, sf.suggestions, ")
            .append("DATE_FORMAT(").append(createdCol).append(",'%Y-%m-%d') AS createdAt, ")
            .append("COALESCE(s.studentName, '') AS student_name ");
        if (withSessionJoin) {
            query.append(", DATE_FORMAT(cs.scheduleDate,'%Y-%m-%d') AS session_date ")
                .append(", DATE_FORMAT(cs.startTime,'%H:%i:%s') AS start_time ")
                .append(", DATE_FORMAT(cs.endTime,'%H:%i:%s') AS end_time ")
                .append(", ").append(pendingSessionSurahColumns("sf.sessionId"))
                .append(ayahRange).append(" AS ayah_range ");
        } else {
            query.append(", '' AS session_date, '' AS start_time, '' AS end_time, '' AS surah, ")
                .append("0 AS quran_surah_number, 0 AS quran_ayah_number, '' AS ayah_range ");
        }
        query.append("FROM studentfeedback sf ")
            .append("LEFT JOIN student s ON s.studentId = sf.studentId ");
        if (withSessionJoin) {
            query.append(TalaqqiSchemaUtil.leftJoinSessionFromFeedback(connection));
        }
        query.append("WHERE sf.teacherId IN (").append(inClause).append(") ")
            .append("ORDER BY ").append(createdCol).append(" DESC");

        try (PreparedStatement stmt = connection.prepareStatement(query.toString())) {
            bindTeacherIdParams(stmt, teacherIds);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    evaluations.add(mapStudentFeedbackRow(rs));
                }
            }
            System.out.println("[TeacherEvaluationDAO] getStudentFeedbackForTeacher teacherId="
                + teacherId + " joined=" + withSessionJoin + " -> " + evaluations.size() + " rows");
        } catch (SQLException e) {
            System.err.println("[TeacherEvaluationDAO] getStudentFeedbackForTeacher join query failed: "
                + e.getMessage());
            if (!withSessionJoin) {
                loadStudentFeedbackFallback(teacherIds, evaluations);
            }
        }
        return evaluations;
    }

    private String feedbackCreatedAtColumn() {
        if (TalaqqiSchemaUtil.hasColumn(connection, "studentfeedback", "createdAt")) {
            return "sf.createdAt";
        }
        if (TalaqqiSchemaUtil.hasColumn(connection, "studentfeedback", "created_at")) {
            return "sf.created_at";
        }
        return "sf.feedbackId";
    }

    private void loadStudentFeedbackFallback(List<String> teacherIds, List<Evaluation> evaluations) {
        StringBuilder inClause = new StringBuilder();
        for (int i = 0; i < teacherIds.size(); i++) {
            if (i > 0) {
                inClause.append(", ");
            }
            inClause.append("?");
        }

        String query =
            "SELECT sf.feedbackId, sf.sessionId, sf.rating, sf.comments, sf.suggestions, "
            + "DATE_FORMAT(" + feedbackCreatedAtColumn() + ",'%Y-%m-%d') AS createdAt, "
            + "COALESCE(s.studentName, '') AS student_name "
            + "FROM studentfeedback sf "
            + "LEFT JOIN student s ON sf.studentId = s.studentId "
            + "WHERE sf.teacherId IN (" + inClause + ") "
            + "ORDER BY " + feedbackCreatedAtColumn() + " DESC";

        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            bindTeacherIdParams(stmt, teacherIds);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    evaluations.add(mapStudentFeedbackRow(rs));
                }
            }
            System.out.println("[TeacherEvaluationDAO] getStudentFeedbackForTeacher fallback -> "
                + evaluations.size() + " rows");
        } catch (SQLException e) {
            setError("Unable to load student feedback for teacher", e);
        }
    }

    private Evaluation mapStudentFeedbackRow(ResultSet rs) throws SQLException {
        Evaluation evaluation = new Evaluation();
        evaluation.setSessionId(rs.getString("sessionId"));
        evaluation.setStudentName(rs.getString("student_name"));
        evaluation.setRating(rs.getInt("rating"));
        evaluation.setComments(rs.getString("comments"));
        evaluation.setSuggestions(rs.getString("suggestions"));
        evaluation.setCreatedAt(rs.getString("createdAt"));
        try {
            evaluation.setSessionDate(rs.getString("session_date"));
            evaluation.setStartTime(rs.getString("start_time"));
            evaluation.setEndTime(rs.getString("end_time"));
            applyQuranFieldsFromResultSet(evaluation, rs);
        } catch (SQLException ignored) {
            // Fallback query omits schedule/session join columns.
        }
        return evaluation;
    }

    private List<String> teacherIdMatchValues(String teacherId) {
        LinkedHashSet<String> ids = new LinkedHashSet<>();
        if (teacherId == null || teacherId.trim().isEmpty()) {
            return new ArrayList<>();
        }
        String trimmed = teacherId.trim();
        ids.add(trimmed);

        String digits = trimmed.replaceAll("[^0-9]", "");
        if (!digits.isEmpty()) {
            int num = Integer.parseInt(digits);
            ids.add("T" + String.format("%03d", num));
            ids.add("T" + num);
            ids.add(String.valueOf(num));
        } else if (trimmed.matches("T\\d+")) {
            ids.add(trimmed.replaceFirst("^T0+", "T"));
        }
        return new ArrayList<>(ids);
    }

    private void bindTeacherIdParams(PreparedStatement stmt, List<String> teacherIds) throws SQLException {
        for (int i = 0; i < teacherIds.size(); i++) {
            stmt.setString(i + 1, teacherIds.get(i));
        }
    }

    /**
     * Get all unique class names for filter dropdown
     * @param teacherId The teacher's ID (String)
     * @return List of class names
     */
    public List<String> getClassNames(String teacherId) {
        List<String> classNames = new ArrayList<>();
        String query;
        if (hasEvalColumn("class_name")) {
            query = "SELECT DISTINCT class_name FROM studentevaluation WHERE teacherId = ? AND class_name IS NOT NULL AND class_name <> '' ORDER BY class_name";
        } else {
            query = "SELECT DISTINCT cs.className AS class_name "
                + "FROM classschedule cs "
                + "JOIN classbooking cb ON cb.scheduleId = cs.scheduleId "
                + "WHERE cs.teacherId = ? AND cb.bookingStatus = 'Completed' "
                + "ORDER BY cs.className";
        }

        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setString(1, teacherId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                String name = rs.getString("class_name");
                if (name != null && !name.trim().isEmpty()) {
                    classNames.add(name);
                }
            }
        } catch (SQLException e) {
            System.err.println("[TeacherEvaluationDAO] getClassNames: " + e.getMessage());
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

        return null;
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
                int surahNumber = Integer.parseInt(trimmed);
                if (surahNumber <= 0) {
                    return "";
                }
                return getSurahName(surahNumber);
            } catch (NumberFormatException e) {
                return trimmed;
            }
        }

        return trimmed;
    }

    private Evaluation mapPendingSessionRow(ResultSet rs) throws SQLException {
        Evaluation evaluation = new Evaluation();
        evaluation.setSessionId(rs.getString("sessionId"));
        evaluation.setStudentId(rs.getString("studentId"));
        evaluation.setStudentName(rs.getString("student_name"));
        evaluation.setClassName(rs.getString("class_name"));
        evaluation.setSessionDate(rs.getString("session_date"));
        evaluation.setStartTime(rs.getString("start_time"));
        evaluation.setEndTime(rs.getString("end_time"));
        evaluation.setTeacherId(rs.getString("teacherId"));
        evaluation.setStatus("PENDING");
        applyQuranFieldsFromResultSet(evaluation, rs);
        return evaluation;
    }

    private void applyQuranFieldsFromResultSet(Evaluation evaluation, ResultSet rs) throws SQLException {
        int quranSurahNumber = 0;
        try {
            quranSurahNumber = rs.getInt("quran_surah_number");
            if (rs.wasNull()) {
                quranSurahNumber = 0;
            }
        } catch (SQLException ignored) {
        }

        int quranAyahNumber = 0;
        try {
            quranAyahNumber = rs.getInt("quran_ayah_number");
            if (rs.wasNull()) {
                quranAyahNumber = 0;
            }
        } catch (SQLException ignored) {
        }

        String surahValue = null;
        try {
            surahValue = rs.getString("surah");
        } catch (SQLException ignored) {
        }

        if (surahValue == null || surahValue.trim().isEmpty() || "0".equals(surahValue.trim())) {
            if (quranSurahNumber > 0) {
                surahValue = getSurahName(quranSurahNumber);
            } else {
                surahValue = "";
            }
        }
        evaluation.setSurah(resolveSurahDisplay(surahValue));

        if (quranSurahNumber > 0) {
            evaluation.setSurahNumber(quranSurahNumber);
        } else if (surahValue != null && surahValue.trim().matches("\\d+")) {
            try {
                evaluation.setSurahNumber(Integer.parseInt(surahValue.trim()));
            } catch (NumberFormatException ignored) {
                evaluation.setSurahNumber(0);
            }
        } else {
            evaluation.setSurahNumber(0);
        }

        String ayahValue = null;
        try {
            ayahValue = rs.getString("ayah_range");
        } catch (SQLException ignored) {
        }

        if (isBlankOrZeroAyah(ayahValue)) {
            if (quranAyahNumber > 0) {
                ayahValue = String.valueOf(quranAyahNumber);
            } else {
                ayahValue = "";
            }
        }
        evaluation.setAyahRange(ayahValue != null ? ayahValue : "");
        evaluation.setAyahNumber(quranAyahNumber);
    }

    private boolean isBlankOrZeroAyah(String ayahValue) {
        if (ayahValue == null || ayahValue.trim().isEmpty()) {
            return true;
        }
        String trimmed = ayahValue.trim();
        return "0".equals(trimmed) || "0-0".equals(trimmed);
    }

    private String normalizeNextTargetFromResultSet(ResultSet rs) throws SQLException {
        String value = null;
        try {
            value = rs.getString("nextTarget");
        } catch (SQLException ignored) {
        }
        if (value == null || value.trim().isEmpty()) {
            try {
                value = rs.getString("next_target_surah");
            } catch (SQLException ignored) {
            }
        }
        return TextEncodingUtil.normalizeAsciiDash(value);
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
            String scheduleId = readScheduleIdColumn(rs);
            if (scheduleId != null) {
                evaluation.setScheduleId(scheduleId);
            }
        } catch (SQLException ignored) {
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
            applyQuranFieldsFromResultSet(evaluation, rs);
        } catch (SQLException e) {
            evaluation.setSurah("");
            evaluation.setAyahRange("");
            evaluation.setSurahNumber(0);
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
            evaluation.setNextTarget(normalizeNextTargetFromResultSet(rs));
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
