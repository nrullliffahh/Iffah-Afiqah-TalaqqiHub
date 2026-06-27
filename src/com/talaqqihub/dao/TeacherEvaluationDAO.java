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

        migrateStudentEvaluationColumns();
        TalaqqiSchemaUtil.ensureSessionBookingIdColumn(connection);
    }

    private void migrateStudentEvaluationColumns() {
        String[][] columns = {
            {"sessionId", "VARCHAR(50) DEFAULT NULL"},
            {"scheduleId", "INT DEFAULT NULL"},
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
        tryModifyColumnNullable("studentevaluation", "scheduleId", "INT DEFAULT NULL");
        tryModifyColumnNullable("studentevaluation", "sessionId", "VARCHAR(50) DEFAULT NULL");
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
        if (hasEvalColumn("status")) {
            return "UPPER(COALESCE(" + alias + ".status, '')) = 'COMPLETED'";
        }
        if (hasEvalColumn("overall_score")) {
            return "COALESCE(" + alias + ".overall_score, 0) > 0";
        }
        return "(COALESCE(" + alias + ".tajweedScore, 0) > 0 "
            + "OR COALESCE(" + alias + ".fluencyScore, 0) > 0 "
            + "OR COALESCE(" + alias + ".accuracyScore, 0) > 0)";
    }

    /** SQL predicate: row is pending teacher evaluation. */
    private String evalPendingPredicate(String alias) {
        if (hasEvalColumn("status")) {
            return "UPPER(COALESCE(" + alias + ".status, 'PENDING')) = 'PENDING'";
        }
        return "NOT (" + evalCompletedPredicate(alias) + ")";
    }

    private String evalSelectColumn(String column) {
        return hasEvalColumn(column) ? "se." + column : "NULL AS " + column;
    }

    private String evalClassNameExpr() {
        if (hasEvalColumn("class_name")) {
            return "COALESCE(NULLIF(se.class_name, ''), cs.className, '') AS class_name";
        }
        return "COALESCE(cs.className, '') AS class_name";
    }

    private String evalSurahExpr() {
        if (hasEvalColumn("surah")) {
            return "COALESCE(NULLIF(se.surah, ''), CAST(cs.classSurah AS CHAR), '') AS surah";
        }
        return "COALESCE(CAST(cs.classSurah AS CHAR), '') AS surah";
    }

    private String evalAyahExpr() {
        String ayahRange = TalaqqiSchemaUtil.ayahRangeExpr(connection);
        if (hasEvalColumn("ayah_range")) {
            return "COALESCE(NULLIF(se.ayah_range, ''), " + ayahRange + ", '') AS ayah_range";
        }
        return "COALESCE(" + ayahRange + ", '') AS ayah_range";
    }

    private String evalSessionDateExpr() {
        if (hasEvalColumn("session_date")) {
            return "COALESCE(NULLIF(se.session_date, ''), DATE_FORMAT(ts.sessionDate, '%Y-%m-%d'), DATE_FORMAT(cs.scheduleDate, '%Y-%m-%d'), '') AS session_date";
        }
        return "COALESCE(DATE_FORMAT(ts.sessionDate, '%Y-%m-%d'), DATE_FORMAT(cs.scheduleDate, '%Y-%m-%d'), '') AS session_date";
    }

    private String evalNotExistsBlocksPending() {
        if (hasEvalColumn("sessionId")) {
            return evalCompletedPredicate("se")
                + " OR (ts.sessionId IS NOT NULL AND se.sessionId = ts.sessionId)";
        }
        return evalCompletedPredicate("se");
    }

    private String evalNotExistsBlocksPendingFallback() {
        return evalCompletedPredicate("se");
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
            query = "SELECT studentEvaluationId FROM studentevaluation WHERE sessionId = ? AND teacherId = ? LIMIT 1";
        } else {
            return null;
        }

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
        String createdCol = TalaqqiSchemaUtil.studentEvalCreatedColumn(connection, "se");
        String orderCol = hasEvalColumn("session_date") ? "se.session_date" : createdCol;
        String query = buildEvaluationListSelectSql() +
            "WHERE se.teacherId = ? AND " + evalPendingPredicate("se") + " " +
            "ORDER BY " + orderCol + " DESC, " + createdCol + " DESC";

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
        query.append("WHERE se.teacherId = ? AND ").append(evalCompletedPredicate("se"));

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

    private void sqlAddInt(EvalSqlParts parts, String column, Integer value) {
        if (hasEvalColumn(column)) {
            parts.add(column, value != null ? value : 0);
        }
    }

    private void hydrateLegacyKeys(Evaluation evaluation) {
        if (evaluation == null) {
            return;
        }
        if (evaluation.getScheduleId() <= 0) {
            Integer scheduleId = lookupScheduleIdForSession(evaluation.getSessionId());
            if (scheduleId != null && scheduleId > 0) {
                evaluation.setScheduleId(scheduleId);
            }
        }
    }

    private Integer lookupScheduleIdForSession(String sessionId) {
        if (sessionId == null || sessionId.trim().isEmpty()) {
            return null;
        }
        String table = TalaqqiSchemaUtil.sessionTable(connection);
        String sql = "SELECT scheduleId FROM " + table + " WHERE sessionId = ? LIMIT 1";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, sessionId.trim());
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return parseScheduleIdValue(rs.getObject("scheduleId"));
                }
            }
        } catch (SQLException e) {
            System.err.println("[TeacherEvaluationDAO] lookupScheduleIdForSession: " + e.getMessage());
        }
        return null;
    }

    private Integer resolveScheduleId(Evaluation evaluation) {
        hydrateLegacyKeys(evaluation);
        if (evaluation.getScheduleId() > 0) {
            return evaluation.getScheduleId();
        }
        return 0;
    }

    private Integer parseScheduleIdValue(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Number) {
            int num = ((Number) value).intValue();
            return num > 0 ? num : null;
        }
        String digits = value.toString().replaceAll("[^0-9]", "");
        if (digits.isEmpty()) {
            return null;
        }
        int num = Integer.parseInt(digits);
        return num > 0 ? num : null;
    }

    private void bindParams(PreparedStatement stmt, List<Object> values) throws SQLException {
        for (int i = 0; i < values.size(); i++) {
            Object value = values.get(i);
            int index = i + 1;
            if (value instanceof Float) {
                stmt.setFloat(index, (Float) value);
            } else if (value instanceof Integer) {
                stmt.setInt(index, (Integer) value);
            } else {
                stmt.setString(index, value != null ? String.valueOf(value) : "");
            }
        }
    }

    private String resolvedEvalStatus(Evaluation evaluation) {
        String status = evaluation.getStatus();
        if (status == null || status.trim().isEmpty()) {
            return evaluation.getOverallScore() > 0 ? "COMPLETED" : "PENDING";
        }
        return status.trim();
    }

    private EvalSqlParts buildEvaluationInsertParts(Evaluation evaluation) {
        hydrateLegacyKeys(evaluation);
        EvalSqlParts parts = new EvalSqlParts();
        parts.add("studentEvaluationId", resolveEvaluationId(evaluation));
        parts.add("studentId", resolveStudentId(evaluation));
        parts.add("teacherId", resolveTeacherId(evaluation));
        sqlAdd(parts, "sessionId", nullToEmpty(evaluation.getSessionId()));
        sqlAddInt(parts, "scheduleId", resolveScheduleId(evaluation));
        sqlAdd(parts, "class_name", nullToEmpty(evaluation.getClassName()));
        sqlAdd(parts, "surah", nullToEmpty(evaluation.getSurah()));
        sqlAdd(parts, "ayah_range", nullToEmpty(evaluation.getAyahRange()));
        sqlAdd(parts, "session_date", nullToEmpty(evaluation.getSessionDate()));
        sqlAdd(parts, "start_time", nullToEmpty(evaluation.getStartTime()));
        sqlAdd(parts, "end_time", nullToEmpty(evaluation.getEndTime()));
        sqlAdd(parts, "tajweedScore", evaluation.getTajweedScore());
        sqlAdd(parts, "fluencyScore", evaluation.getFluencyScore());
        sqlAdd(parts, "accuracyScore", evaluation.getAccuracyScore());
        sqlAdd(parts, "overall_score", evaluation.getOverallScore());
        sqlAdd(parts, "rating", evaluation.getRating());
        sqlAdd(parts, "strength", truncate(evaluation.getComments(), 255));
        sqlAdd(parts, "areas_for_improvement", nullToEmpty(evaluation.getAreasForImprovement()));
        sqlAdd(parts, "performance_tag", nullToEmpty(evaluation.getPerformanceTag()));
        sqlAdd(parts, "next_target_surah", nullToEmpty(evaluation.getNextTarget()));
        sqlAdd(parts, "suggestions", nullToEmpty(evaluation.getSuggestions()));
        sqlAdd(parts, "teacher_comments", nullToEmpty(evaluation.getTeacherComments()));
        sqlAdd(parts, "status", resolvedEvalStatus(evaluation));
        sqlAdd(parts, "weakness", truncate(evaluation.getAreasForImprovement(), 255));
        sqlAdd(parts, "studentImprovements", nullToEmpty(evaluation.getSuggestions()));
        sqlAdd(parts, "nextTarget", nullToEmpty(evaluation.getNextTarget()));
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
        sqlAddInt(parts, "scheduleId", resolveScheduleId(evaluation));
        sqlAdd(parts, "tajweedScore", evaluation.getTajweedScore());
        sqlAdd(parts, "fluencyScore", evaluation.getFluencyScore());
        sqlAdd(parts, "accuracyScore", evaluation.getAccuracyScore());
        sqlAdd(parts, "strength", truncate(evaluation.getComments(), 255));
        sqlAdd(parts, "weakness", truncate(evaluation.getAreasForImprovement(), 255));
        sqlAdd(parts, "studentImprovements", nullToEmpty(evaluation.getSuggestions()));
        sqlAdd(parts, "nextTarget", nullToEmpty(evaluation.getNextTarget()));
        sqlAdd(parts, "comments", nullToEmpty(evaluation.getComments()));
        sqlAdd(parts, "status", resolvedEvalStatus(evaluation));
        sqlAdd(parts, "sessionId", nullToEmpty(evaluation.getSessionId()));

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
            helper.addSet("scheduleId", resolveScheduleId(evaluation), setClause, params);
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
            helper.addSet("session_date", nullToEmpty(evaluation.getSessionDate()), setClause, params);
        }
        if (hasEvalColumn("start_time")) {
            helper.addSet("start_time", nullToEmpty(evaluation.getStartTime()), setClause, params);
        }
        if (hasEvalColumn("end_time")) {
            helper.addSet("end_time", nullToEmpty(evaluation.getEndTime()), setClause, params);
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
            helper.addSet("next_target_surah", nullToEmpty(evaluation.getNextTarget()), setClause, params);
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
            helper.addSet("nextTarget", nullToEmpty(evaluation.getNextTarget()), setClause, params);
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
        String teacherIdStr = resolveTeacherId(evaluation);
        String query = "UPDATE studentevaluation SET " + setClause
            + " WHERE studentEvaluationId = ? AND teacherId = ?";

        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            int index = 1;
            for (Object param : params) {
                if (param instanceof Float) {
                    stmt.setFloat(index++, (Float) param);
                } else if (param instanceof Integer) {
                    stmt.setInt(index++, (Integer) param);
                } else {
                    stmt.setString(index++, param != null ? String.valueOf(param) : "");
                }
            }
            stmt.setString(index++, evalIdStr);
            stmt.setString(index, teacherIdStr);

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
            "  AND (" + evalNotExistsBlocksPending() + ") " +
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
        String sessionLookup = TalaqqiSchemaUtil.sessionIdForBookingSubquery(connection);
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
            + "  AND (" + evalNotExistsBlocksPendingFallback() + ") "
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
            "SELECT ts.sessionId, cb.scheduleId, cb.studentId, cs.teacherId, cs.className, " +
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
                Integer scheduleId = parseScheduleIdValue(rs.getObject("scheduleId"));
                if (scheduleId != null) {
                    evaluation.setScheduleId(scheduleId);
                }
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
        hydrateLegacyKeys(evaluation);
        String evalIdStr = resolveEvaluationId(evaluation);
        String teacherIdStr = resolveTeacherId(evaluation);
        String studentIdStr = resolveStudentId(evaluation);
        String sessionId = nullToEmpty(evaluation.getSessionId());
        Integer scheduleId = resolveScheduleId(evaluation);

        EvalSqlParts parts = new EvalSqlParts();
        if (hasEvalColumn("studentEvaluationId")) {
            parts.add("studentEvaluationId", evalIdStr);
        }
        parts.add("studentId", studentIdStr);
        parts.add("teacherId", teacherIdStr);
        sqlAdd(parts, "sessionId", sessionId);
        sqlAddInt(parts, "scheduleId", scheduleId);
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
        sqlAddInt(fallback, "scheduleId", scheduleId);
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

        return "SELECT " +
            "se.studentEvaluationId, " +
            "se.studentId, " +
            "COALESCE(s.studentName, '') AS student_name, " +
            evalClassNameExpr() + ", " +
            evalSurahExpr() + ", " +
            evalAyahExpr() + ", " +
            evalSessionDateExpr() + ", " +
            (hasEvalColumn("start_time") ? "COALESCE(NULLIF(se.start_time, ''), cs.startTime, '') AS start_time" : "COALESCE(cs.startTime, '') AS start_time") + ", " +
            (hasEvalColumn("end_time") ? "COALESCE(NULLIF(se.end_time, ''), cs.endTime, '') AS end_time" : "COALESCE(cs.endTime, '') AS end_time") + ", " +
            "COALESCE(cs.classSurah, 0) AS quran_surah_number, " +
            "COALESCE(cs.classAyah, 0) AS quran_ayah_number, " +
            "COALESCE(NULLIF(se.teacherId, ''), cs.teacherId, '') AS teacherId, " +
            "COALESCE(NULLIF(t.teacherName, ''), '') AS teacher_name, " +
            (hasEvalColumn("sessionId") ? "se.sessionId" : "NULL AS sessionId") + ", se.tajweedScore, se.fluencyScore, se.accuracyScore, " +
            evalSelectColumn("overall_score") + ", " +
            evalSelectColumn("rating") + ", " +
            "se.strength, " +
            evalSelectColumn("areas_for_improvement") + ", " +
            evalSelectColumn("performance_tag") + ", " +
            evalSelectColumn("next_target_surah") + ", " +
            evalSelectColumn("suggestions") + ", " +
            evalSelectColumn("teacher_comments") + ", " +
            statusCol + ", se.weakness, se.studentImprovements, se.nextTarget, se.comments, " +
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
            + "se.tajweedScore, se.fluencyScore, se.accuracyScore, se.strength, se.weakness, "
            + "se.studentImprovements, se.nextTarget, se.comments, "
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
            + "WHERE se.teacherId = ? AND " + evalPendingPredicate("se");

        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setString(1, teacherId);
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
            + "scheduleId INT DEFAULT NULL, "
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

        StringBuilder inClause = new StringBuilder();
        for (int i = 0; i < teacherIds.size(); i++) {
            if (i > 0) {
                inClause.append(", ");
            }
            inClause.append("?");
        }

        String ayahRange = TalaqqiSchemaUtil.ayahRangeExpr(connection);
        String query =
            "SELECT sf.feedbackId, sf.sessionId, sf.rating, sf.comments, sf.suggestions, "
            + "DATE_FORMAT(sf.createdAt,'%Y-%m-%d') AS createdAt, "
            + "s.studentName AS student_name, "
            + "DATE_FORMAT(cs.scheduleDate,'%Y-%m-%d') AS session_date, "
            + "DATE_FORMAT(cs.startTime,'%H:%i:%s') AS start_time, "
            + "DATE_FORMAT(cs.endTime,'%H:%i:%s') AS end_time, "
            + "cs.classSurah AS surah, "
            + ayahRange + " AS ayah_range "
            + "FROM studentfeedback sf "
            + "JOIN student s ON sf.studentId = s.studentId "
            + TalaqqiSchemaUtil.leftJoinSessionFromFeedback(connection)
            + "WHERE sf.teacherId IN (" + inClause + ") "
            + "ORDER BY sf.createdAt DESC";

        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            bindTeacherIdParams(stmt, teacherIds);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    evaluations.add(mapStudentFeedbackRow(rs));
                }
            }
            System.out.println("[TeacherEvaluationDAO] getStudentFeedbackForTeacher teacherId="
                + teacherId + " -> " + evaluations.size() + " rows");
        } catch (SQLException e) {
            System.err.println("[TeacherEvaluationDAO] getStudentFeedbackForTeacher join query failed: "
                + e.getMessage());
            loadStudentFeedbackFallback(teacherIds, evaluations);
        }
        return evaluations;
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
            + "DATE_FORMAT(sf.createdAt,'%Y-%m-%d') AS createdAt, "
            + "COALESCE(s.studentName, '') AS student_name "
            + "FROM studentfeedback sf "
            + "LEFT JOIN student s ON sf.studentId = s.studentId "
            + "WHERE sf.teacherId IN (" + inClause + ") "
            + "ORDER BY sf.createdAt DESC";

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
            evaluation.setSurah(resolveSurahDisplay(rs.getString("surah")));
            evaluation.setAyahRange(rs.getString("ayah_range"));
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
