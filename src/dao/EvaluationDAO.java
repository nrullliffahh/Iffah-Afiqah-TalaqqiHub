package dao;

import model.Evaluation;
import util.DBConnection;
import util.TalaqqiSchemaUtil;
import util.TextEncodingUtil;
import java.sql.*;
import java.util.*;

/**
 * EvaluationDAO
 *
 * Handles all database operations for:
 *  - Teacher evaluations of students  (table: studentevaluation)
 *  - Student feedback about teachers  (table: studentfeedback)
 *  - Admin/teacher aggregate queries  (tables: studentevaluation, studentfeedback)
 */
public class EvaluationDAO {

    // ══════════════════════════════════════════════════════════════════════════
    // TEACHER → STUDENT evaluations  (studentevaluation table)
    // ══════════════════════════════════════════════════════════════════════════

    /**
     * Returns the most-recent completed evaluation a teacher has given to a student.
     */
    public Evaluation getLatestEvaluationByStudent(String studentId) {
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return null;
            }
            syncCompletedEvaluationStatus(conn, studentId);
            List<Evaluation> list = loadStudentEvaluations(conn, studentId, 1);
            return list.isEmpty() ? null : list.get(0);
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.getLatestEvaluationByStudent: " + e.getMessage());
        }
        return null;
    }

    /**
     * Returns the full evaluation history given to a student by teachers.
     */
    public List<Evaluation> getEvaluationHistory(String studentId) {
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return new ArrayList<>();
            }
            syncCompletedEvaluationStatus(conn, studentId);
            return loadStudentEvaluations(conn, studentId, 0);
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.getEvaluationHistory: " + e.getMessage());
            return new ArrayList<>();
        }
    }

    /** Joined query → plain select → minimal legacy columns (production Aiven schema). */
    private List<Evaluation> loadStudentEvaluations(Connection conn, String studentId, int limit)
            throws SQLException {
        List<Evaluation> list = queryStudentEvaluations(conn, studentId, true, limit);
        if (list.isEmpty()) {
            list = queryStudentEvaluations(conn, studentId, false, limit);
        }
        if (list.isEmpty()) {
            list = queryStudentEvaluationsMinimal(conn, studentId, limit);
        }
        return list;
    }

    private List<Evaluation> queryStudentEvaluations(Connection conn, String studentId,
                                                     boolean withJoin, int limit) {
        List<Evaluation> list = new ArrayList<>();
        String sql = buildStudentEvalSelectSql(conn, withJoin)
            + "WHERE " + studentIdMatchClause("se.studentId", studentIdVariants(studentId))
            + " AND " + evalCompletedPredicate(conn, "se") + " "
            + "ORDER BY se.studentEvaluationId DESC"
            + (limit > 0 ? " LIMIT " + limit : "");
        try (PreparedStatement ps = conn.prepareStatement(TalaqqiSchemaUtil.sql(sql, conn))) {
            bindStudentIdVariants(ps, 1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapStudentEval(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.queryStudentEvaluations(withJoin=" + withJoin + "): "
                + e.getMessage());
        }
        return list;
    }

    /** Last-resort: only columns that exist on the oldest production dump. */
    private List<Evaluation> queryStudentEvaluationsMinimal(Connection conn, String studentId, int limit) {
        List<Evaluation> list = new ArrayList<>();
        String overallExpr = hasEvalColumn(conn, "overall_score")
            ? "COALESCE(se.overall_score, (COALESCE(se.tajweedScore,0)+COALESCE(se.fluencyScore,0)+COALESCE(se.accuracyScore,0))/3)"
            : "(COALESCE(se.tajweedScore,0)+COALESCE(se.fluencyScore,0)+COALESCE(se.accuracyScore,0))/3";
        String createdCol = TalaqqiSchemaUtil.studentEvalCreatedColumn(conn, "se");
        String createdExpr = createdCol.contains(".")
            ? "DATE_FORMAT(" + createdCol + ",'%b %d, %Y')"
            : "DATE_FORMAT(NOW(),'%b %d, %Y')";
        String sql =
            "SELECT se.studentEvaluationId, se.studentId, se.teacherId, "
            + evalColExpr(conn, "se", "sessionId", null, "sessionId") + ", "
            + "se.tajweedScore, se.fluencyScore, se.accuracyScore, "
            + overallExpr + " AS overallScore, "
            + evalColExpr(conn, "se", "strength", null, "strength") + ", "
            + evalColExpr(conn, "se", "weakness", "areas_for_improvement", "weakness") + ", "
            + evalColExpr(conn, "se", "studentImprovements", "suggestions", "studentImprovements") + ", "
            + evalColExpr(conn, "se", "nextTarget", "next_target_surah", "nextTarget") + ", "
            + evalColExpr(conn, "se", "comments", "teacher_comments", "comments") + ", "
            + "COALESCE(t.teacherName, '') AS teacherName, "
            + "'' AS surahName, '' AS ayahRange, "
            + createdExpr + " AS createdAt "
            + "FROM studentevaluation se "
            + "LEFT JOIN teacher t ON se.teacherId = t.teacherId "
            + "WHERE " + studentIdMatchClause("se.studentId", studentIdVariants(studentId))
            + " AND " + evalCompletedPredicate(conn, "se") + " "
            + "ORDER BY se.studentEvaluationId DESC"
            + (limit > 0 ? " LIMIT " + limit : "");
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            bindStudentIdVariants(ps, 1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapStudentEval(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.queryStudentEvaluationsMinimal: " + e.getMessage());
        }
        return list;
    }

    private String buildStudentEvalSelectSql(Connection conn, boolean withJoin) {
        String sessionCol = hasEvalColumn(conn, "sessionId") ? "se.sessionId" : "NULL AS sessionId";
        String overallExpr = hasEvalColumn(conn, "overall_score")
            ? "COALESCE(se.overall_score, (COALESCE(se.tajweedScore,0)+COALESCE(se.fluencyScore,0)+COALESCE(se.accuracyScore,0))/3)"
            : "(COALESCE(se.tajweedScore,0)+COALESCE(se.fluencyScore,0)+COALESCE(se.accuracyScore,0))/3";
        String createdCol = TalaqqiSchemaUtil.studentEvalCreatedColumn(conn, "se");
        String createdExpr = createdCol.contains(".")
            ? "DATE_FORMAT(" + createdCol + ",'%b %d, %Y')"
            : "DATE_FORMAT(NOW(),'%b %d, %Y')";

        String surahExpr;
        String ayahExpr;
        if (withJoin) {
            surahExpr = hasEvalColumn(conn, "surah")
                ? "COALESCE(NULLIF(se.surah, ''), CAST(COALESCE(qd.currentSurah, cs.classSurah) AS CHAR))"
                : "CAST(COALESCE(qd.currentSurah, cs.classSurah) AS CHAR)";
            ayahExpr = hasEvalColumn(conn, "ayah_range")
                ? "COALESCE(NULLIF(se.ayah_range, ''), CAST(COALESCE(qd.currentAyah, cs.classAyah) AS CHAR))"
                : "CAST(COALESCE(qd.currentAyah, cs.classAyah) AS CHAR)";
        } else {
            surahExpr = hasEvalColumn(conn, "surah") ? "COALESCE(se.surah, '')" : "''";
            ayahExpr = hasEvalColumn(conn, "ayah_range") ? "COALESCE(se.ayah_range, '')" : "''";
        }

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT se.studentEvaluationId, se.studentId, se.teacherId, ")
            .append(sessionCol).append(", ")
            .append("se.tajweedScore, se.fluencyScore, se.accuracyScore, ")
            .append(overallExpr).append(" AS overallScore, ")
            .append(evalColExpr(conn, "se", "strength", null, "strength")).append(", ")
            .append(evalColExpr(conn, "se", "weakness", "areas_for_improvement", "weakness")).append(", ")
            .append(evalColExpr(conn, "se", "studentImprovements", "suggestions", "studentImprovements")).append(", ")
            .append(evalColExpr(conn, "se", "nextTarget", "next_target_surah", "nextTarget")).append(", ")
            .append(evalColExpr(conn, "se", "comments", "teacher_comments", "comments")).append(", ")
            .append("t.teacherName, ")
            .append(surahExpr).append(" AS surahName, ")
            .append(ayahExpr).append(" AS ayahRange, ")
            .append(createdExpr).append(" AS createdAt ")
            .append("FROM studentevaluation se ")
            .append("LEFT JOIN teacher t ON se.teacherId = t.teacherId ");
        if (withJoin) {
            sql.append(TalaqqiSchemaUtil.leftJoinSessionFromEvaluation(conn));
            if (TalaqqiSchemaUtil.hasQuranDisplayTable(conn)) {
                sql.append("LEFT JOIN qurandisplay qd ON qd.sessionId = ts.sessionId ");
            }
        }
        return sql.toString();
    }

    private String evalScorePresentPredicate(Connection conn, String alias) {
        String scoreCheck = "(COALESCE(" + alias + ".tajweedScore, 0) > 0 "
            + "OR COALESCE(" + alias + ".fluencyScore, 0) > 0 "
            + "OR COALESCE(" + alias + ".accuracyScore, 0) > 0)";
        if (hasEvalColumn(conn, "overall_score")) {
            scoreCheck = "(" + scoreCheck + " OR COALESCE(" + alias + ".overall_score, 0) > 0)";
        }
        return scoreCheck;
    }

    private String evalCompletedPredicate(Connection conn, String alias) {
        String scoreCheck = evalScorePresentPredicate(conn, alias);
        if (hasEvalColumn(conn, "status")) {
            return "(UPPER(COALESCE(" + alias + ".status, '')) = 'COMPLETED' OR " + scoreCheck + ")";
        }
        if (hasEvalColumn(conn, "overall_score")) {
            return "COALESCE(" + alias + ".overall_score, 0) > 0";
        }
        return scoreCheck;
    }

    /** Backfill COMPLETED status when scores exist but status stayed PENDING. */
    private void syncCompletedEvaluationStatus(Connection conn, String studentId) {
        if (!hasEvalColumn(conn, "status")) {
            return;
        }
        String scoreCheck = evalScorePresentPredicate(conn, "studentevaluation");
        String sql = "UPDATE studentevaluation SET status = 'COMPLETED' "
            + "WHERE UPPER(COALESCE(status, 'PENDING')) = 'PENDING' AND " + scoreCheck;
        if (studentId != null && !studentId.trim().isEmpty()) {
            sql += " AND " + studentIdMatchClause("studentId", studentIdVariants(studentId));
        }
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            if (studentId != null && !studentId.trim().isEmpty()) {
                bindStudentIdVariants(ps, 1, studentId);
            }
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.syncCompletedEvaluationStatus: " + e.getMessage());
        }
    }

    private boolean hasEvalColumn(Connection conn, String column) {
        return TalaqqiSchemaUtil.hasColumn(conn, "studentevaluation", column);
    }

    private String evalColExpr(Connection conn, String alias, String primary,
                               String fallback, String asName) {
        if (hasEvalColumn(conn, primary)) {
            return primary.equals(asName) ? alias + "." + primary : alias + "." + primary + " AS " + asName;
        }
        if (fallback != null && hasEvalColumn(conn, fallback)) {
            return alias + "." + fallback + " AS " + asName;
        }
        return "NULL AS " + asName;
    }

    /**
     * Returns monthly performance trend data for Chart.js.
     */
    public List<Map<String, Object>> getPerformanceTrend(String studentId) {
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return list;
            }
            syncCompletedEvaluationStatus(conn, studentId);
            String createdCol = TalaqqiSchemaUtil.studentEvalCreatedColumn(conn, "se");
            String sql =
                "SELECT DATE_FORMAT(" + createdCol + ",'%b %Y') AS month, "
                + "       AVG(se.tajweedScore)  AS tajweed, "
                + "       AVG(se.fluencyScore)  AS fluency, "
                + "       AVG(se.accuracyScore) AS accuracy, "
                + "       AVG((COALESCE(se.tajweedScore,0)+COALESCE(se.fluencyScore,0)+COALESCE(se.accuracyScore,0))/3) AS overall "
                + "FROM studentevaluation se "
                + "WHERE " + studentIdMatchClause("se.studentId", studentIdVariants(studentId))
                + " AND " + evalCompletedPredicate(conn, "se") + " "
                + "GROUP BY DATE_FORMAT(" + createdCol + ",'%Y-%m') "
                + "ORDER BY MIN(" + createdCol + ") ASC LIMIT 12";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                bindStudentIdVariants(ps, 1, studentId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> row = new LinkedHashMap<>();
                        row.put("month",    rs.getString("month"));
                        row.put("tajweed",  rs.getDouble("tajweed"));
                        row.put("fluency",  rs.getDouble("fluency"));
                        row.put("accuracy", rs.getDouble("accuracy"));
                        row.put("overall",  rs.getDouble("overall"));
                        list.add(row);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.getPerformanceTrend: " + e.getMessage());
        }
        return list;
    }

    /**
     * Returns average skill scores across all teacher evaluations for a student.
     */
    public Map<String, Double> getSkillsAssessment(String studentId) {
        Map<String, Double> skills = new LinkedHashMap<>();
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return skills;
            }
            syncCompletedEvaluationStatus(conn, studentId);
            String sql =
                "SELECT AVG(tajweedScore) AS Tajweed, "
                + "       AVG(fluencyScore) AS Fluency, "
                + "       AVG(accuracyScore) AS Accuracy "
                + "FROM studentevaluation se "
                + "WHERE " + studentIdMatchClause("se.studentId", studentIdVariants(studentId))
                + " AND " + evalCompletedPredicate(conn, "se");

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                bindStudentIdVariants(ps, 1, studentId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        skills.put("Tajweed",  roundOrZero(rs.getDouble("Tajweed")));
                        skills.put("Fluency",  roundOrZero(rs.getDouble("Fluency")));
                        skills.put("Accuracy", roundOrZero(rs.getDouble("Accuracy")));
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.getSkillsAssessment: " + e.getMessage());
        }
        return skills;
    }

    /**
     * Returns the total number of teacher evaluations for a student.
     */
    public int getTotalEvaluationCount(String studentId) {
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return 0;
            }
            syncCompletedEvaluationStatus(conn, studentId);
            String sql = "SELECT COUNT(*) AS cnt FROM studentevaluation se "
                + "WHERE " + studentIdMatchClause("se.studentId", studentIdVariants(studentId))
                + " AND " + evalCompletedPredicate(conn, "se");
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                bindStudentIdVariants(ps, 1, studentId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt("cnt");
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.getTotalEvaluationCount: " + e.getMessage());
        }
        return 0;
    }

    /** True when the student has conducted sessions awaiting teacher scores. */
    public boolean hasAwaitingTeacherEvaluation(String studentId) {
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return false;
            }
            if (!hasEvalColumn(conn, "status")) {
                return false;
            }
            String sql = "SELECT 1 FROM studentevaluation se "
                + "WHERE " + studentIdMatchClause("se.studentId", studentIdVariants(studentId))
                + " AND UPPER(COALESCE(se.status, 'PENDING')) = 'PENDING' "
                + " AND NOT (" + evalCompletedPredicate(conn, "se") + ") LIMIT 1";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                bindStudentIdVariants(ps, 1, studentId);
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next();
                }
            }
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.hasAwaitingTeacherEvaluation: " + e.getMessage());
        }
        return false;
    }

    // ══════════════════════════════════════════════════════════════════════════
    // COMPLETED SESSIONS for Evaluate-Teacher UI
    // ══════════════════════════════════════════════════════════════════════════

    /**
     * Returns completed sessions that the student has NOT yet rated.
     * These appear in the "Evaluate Teacher" section.
     */
    public List<Evaluation> getCompletedSessionsForStudent(String studentId) {
        List<Evaluation> merged = new ArrayList<>();
        java.util.Set<String> seen = new java.util.LinkedHashSet<>();
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                return merged;
            }
            ensureFeedbackTableExists();
            try {
                String resolvedStudentId = resolveStudentIdForFeedback(conn, studentId);
                if (resolvedStudentId != null && !resolvedStudentId.isEmpty()) {
                    studentId = resolvedStudentId;
                }
            } catch (SQLException e) {
                System.err.println("EvaluationDAO.getCompletedSessionsForStudent resolveStudentId: "
                    + e.getMessage());
            }

            // Present/Late attendance is the primary signal that a session is done.
            mergeEvaluableSessions(merged, seen,
                queryEvaluableSessionsFromAttendance(conn, studentId));
            mergeEvaluableSessions(merged, seen,
                queryEvaluableSessionsFromAttendedBookings(conn, studentId));
            mergeEvaluableSessions(merged, seen,
                queryCompletedSessionsForStudent(conn, studentId, true));
            mergeEvaluableSessions(merged, seen,
                queryCompletedSessionsForStudent(conn, studentId, false));
            mergeEvaluableSessions(merged, seen,
                queryCompletedSessionsBookingOnly(conn, studentId));
            mergeEvaluableSessions(merged, seen,
                queryCompletedSessionsFromEndedSessions(conn, studentId));
            mergeEvaluableSessions(merged, seen,
                queryCompletedSessionsFromTeacherEval(conn, studentId));
            mergeEvaluableSessions(merged, seen,
                queryCompletedSessionsFromPendingTeacherEval(conn, studentId));

            System.out.println("EvaluationDAO.getCompletedSessionsForStudent: studentId="
                + studentId + " found=" + merged.size());
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException ignored) {}
            }
        }
        return merged;
    }

    private void mergeEvaluableSessions(List<Evaluation> merged, java.util.Set<String> seen,
                                        List<Evaluation> batch) {
        if (batch == null || batch.isEmpty()) {
            return;
        }
        for (Evaluation e : batch) {
            if (e == null) {
                continue;
            }
            String key = evaluableSessionKey(e);
            if (seen.add(key)) {
                merged.add(e);
            }
        }
    }

    private String evaluableSessionKey(Evaluation e) {
        if (e.getSessionId() != null && !e.getSessionId().trim().isEmpty()) {
            return "sid:" + e.getSessionId().trim();
        }
        if (e.getScheduleId() != null && !e.getScheduleId().trim().isEmpty()) {
            return "sch:" + e.getScheduleId().trim() + ":" + nullToEmpty(e.getSessionDate());
        }
        return "row:" + nullToEmpty(e.getTeacherId()) + ":" + nullToEmpty(e.getSessionDate())
            + ":" + nullToEmpty(e.getStartTime());
    }

    private static String nullToEmpty(String value) {
        return value != null ? value.trim() : "";
    }

    private List<Evaluation> queryCompletedSessionsForStudent(Connection conn, String studentId,
                                                              boolean withFeedbackFilter) {
        List<Evaluation> list = new ArrayList<>();
        ensureFeedbackTableExists();
        String ayahRange = TalaqqiSchemaUtil.ayahRangeExpr(conn);
        String surahCol = TalaqqiSchemaUtil.hasQuranDisplayTable(conn)
            ? "COALESCE(NULLIF(qd.currentSurah, 0), NULLIF(cs.classSurah, 0))"
            : "NULLIF(cs.classSurah, 0)";
        String ayahCol = TalaqqiSchemaUtil.hasClassAyahEnd(conn)
            ? "COALESCE(NULLIF(qd.currentAyah, 0), " + ayahRange + ")"
            : "COALESCE(NULLIF(cs.classAyah, 0), CAST(cs.classAyah AS CHAR))";
        String feedbackFilter = withFeedbackFilter
            ? "  AND " + feedbackNotExistsForSession("cb.studentId", "ts.sessionId", "cb.scheduleId") + " "
            : "";
        String quranJoin = TalaqqiSchemaUtil.hasQuranDisplayTable(conn)
            ? "LEFT JOIN qurandisplay qd ON qd.sessionId = ts.sessionId "
            : "";
        String sql =
            "SELECT ts.sessionId, cb.scheduleId, cs.teacherId, t.teacherName, "
            + "       DATE_FORMAT(cs.scheduleDate,'%b %d, %Y') AS sessionDate, "
            + "       DATE_FORMAT(cs.startTime,'%I:%i %p')     AS startTime, "
            + "       DATE_FORMAT(cs.endTime,'%I:%i %p')       AS endTime, "
            + "       CAST(" + surahCol + " AS CHAR) AS surahName, "
            + "       CAST(" + ayahCol + " AS CHAR) AS ayahRange "
            + TalaqqiSchemaUtil.innerSessionBookingSchedule(conn)
            + quranJoin
            + "LEFT JOIN teacher t ON cs.teacherId = t.teacherId "
            + "WHERE " + studentIdMatchClause("cb.studentId", studentIdVariants(studentId))
            + "  AND UPPER(TRIM(COALESCE(cb.bookingStatus, ''))) IN ('COMPLETED', 'COMPLETE', 'DONE') "
            + feedbackFilter
            + "ORDER BY cs.scheduleDate DESC, cs.startTime DESC";

        try (PreparedStatement ps = conn.prepareStatement(TalaqqiSchemaUtil.sql(sql, conn))) {
            bindStudentIdVariants(ps, 1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Evaluation e = new Evaluation();
                    e.setSessionId(rs.getString("sessionId"));
                    e.setScheduleId(rs.getString("scheduleId"));
                    e.setTeacherId(rs.getString("teacherId"));
                    e.setTeacherName(rs.getString("teacherName"));
                    e.setSessionDate(rs.getString("sessionDate"));
                    e.setStartTime(rs.getString("startTime"));
                    e.setEndTime(rs.getString("endTime"));
                    e.setSurahName(resolveSurahDisplay(rs.getString("surahName")));
                    e.setAyahRange(rs.getString("ayahRange"));
                    list.add(e);
                }
            }
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.queryCompletedSessionsForStudent(withFeedback="
                + withFeedbackFilter + "): " + e.getMessage());
        }
        return list;
    }

    /** Booking + schedule only when session table join fails on legacy production schema. */
    private List<Evaluation> queryCompletedSessionsBookingOnly(Connection conn, String studentId) {
        List<Evaluation> list = new ArrayList<>();
        String ayahRange = TalaqqiSchemaUtil.ayahRangeExpr(conn);
        String sql =
            "SELECT COALESCE(" + TalaqqiSchemaUtil.sessionIdForBookingSubquery(conn)
            + ", cb.bookingId) AS sessionId, "
            + "cb.scheduleId, cs.teacherId, t.teacherName, "
            + "DATE_FORMAT(cs.scheduleDate,'%b %d, %Y') AS sessionDate, "
            + "DATE_FORMAT(cs.startTime,'%I:%i %p') AS startTime, "
            + "DATE_FORMAT(cs.endTime,'%I:%i %p') AS endTime, "
            + "CAST(cs.classSurah AS CHAR) AS surahName, "
            + "CAST(" + ayahRange + " AS CHAR) AS ayahRange "
            + "FROM classbooking cb "
            + "JOIN classschedule cs ON cb.scheduleId = cs.scheduleId "
            + "LEFT JOIN teacher t ON cs.teacherId = t.teacherId "
            + "WHERE " + studentIdMatchClause("cb.studentId", studentIdVariants(studentId))
            + "  AND UPPER(TRIM(COALESCE(cb.bookingStatus, ''))) IN ('COMPLETED', 'COMPLETE', 'DONE') "
            + "  AND NOT EXISTS ( "
            + "      SELECT 1 FROM studentfeedback sf "
            + "      WHERE sf.studentId = cb.studentId "
            + "        AND (sf.sessionId = " + TalaqqiSchemaUtil.sessionIdForBookingSubquery(conn)
            + "             OR sf.sessionId = cb.bookingId) "
            + "  ) "
            + "ORDER BY cs.scheduleDate DESC, cs.startTime DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            bindStudentIdVariants(ps, 1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Evaluation e = mapCompletedSessionRow(rs);
                    list.add(e);
                }
            }
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.queryCompletedSessionsBookingOnly: " + e.getMessage());
        }
        return list;
    }

    /** Ended talaqqi sessions even when classbooking was not marked Completed. */
    private List<Evaluation> queryCompletedSessionsFromEndedSessions(Connection conn, String studentId) {
        List<Evaluation> list = new ArrayList<>();
        String sessionTable = TalaqqiSchemaUtil.sessionTable(conn);
        String ayahRange = TalaqqiSchemaUtil.ayahRangeExpr(conn);
        String bookingLink = TalaqqiSchemaUtil.hasColumn(conn, sessionTable, "bookingId")
            ? "((ts.bookingId IS NOT NULL AND ts.bookingId <> '' AND ts.bookingId = cb.bookingId) "
                + "OR ((ts.bookingId IS NULL OR ts.bookingId = '') AND ts.scheduleId = cb.scheduleId))"
            : "ts.scheduleId = cb.scheduleId";
        String studentClause = studentIdMatchClause("cb.studentId", studentIdVariants(studentId));
        String sql =
            "SELECT ts.sessionId, cb.scheduleId, cs.teacherId, t.teacherName, "
            + "DATE_FORMAT(COALESCE(ts.sessionDate, cs.scheduleDate),'%b %d, %Y') AS sessionDate, "
            + "DATE_FORMAT(cs.startTime,'%I:%i %p') AS startTime, "
            + "DATE_FORMAT(cs.endTime,'%I:%i %p') AS endTime, "
            + "CAST(cs.classSurah AS CHAR) AS surahName, "
            + "CAST(" + ayahRange + " AS CHAR) AS ayahRange "
            + "FROM " + sessionTable + " ts "
            + "JOIN classschedule cs ON ts.scheduleId = cs.scheduleId "
            + "JOIN classbooking cb ON " + bookingLink + " AND " + studentClause + " "
            + "LEFT JOIN teacher t ON cs.teacherId = t.teacherId "
            + "WHERE ts.sessionDate IS NOT NULL "
            + "  AND NOT EXISTS ( "
            + "      SELECT 1 FROM studentfeedback sf "
            + "      WHERE sf.studentId = cb.studentId AND sf.sessionId = ts.sessionId "
            + "  ) "
            + "ORDER BY ts.sessionDate DESC, cs.startTime DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            bindStudentIdVariants(ps, 1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapCompletedSessionRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.queryCompletedSessionsFromEndedSessions: " + e.getMessage());
        }
        return list;
    }

    /**
     * After a teacher completes studentevaluation, the student can rate the teacher —
     * even when booking/session joins fail on legacy production schema.
     */
    private List<Evaluation> queryCompletedSessionsFromTeacherEval(Connection conn, String studentId) {
        List<Evaluation> list = new ArrayList<>();
        String sessionCol = hasEvalColumn(conn, "sessionId")
            ? "NULLIF(TRIM(se.sessionId), '')" : "NULL";
        String scheduleCol = hasEvalColumn(conn, "scheduleId") ? "se.scheduleId" : "NULL AS scheduleId";
        String surahExpr = hasEvalColumn(conn, "surah") ? "COALESCE(se.surah, '')" : "''";
        String ayahExpr = hasEvalColumn(conn, "ayah_range") ? "COALESCE(se.ayah_range, '')" : "''";
        String createdCol = TalaqqiSchemaUtil.studentEvalCreatedColumn(conn, "se");
        String dateExpr = createdCol.contains(".")
            ? "DATE_FORMAT(" + createdCol + ",'%b %d, %Y')"
            : "DATE_FORMAT(NOW(),'%b %d, %Y')";
        String sql =
            "SELECT " + sessionCol + " AS sessionId, " + scheduleCol + ", se.teacherId, "
            + "COALESCE(t.teacherName, '') AS teacherName, "
            + dateExpr + " AS sessionDate, '' AS startTime, '' AS endTime, "
            + surahExpr + " AS surahName, " + ayahExpr + " AS ayahRange "
            + "FROM studentevaluation se "
            + "LEFT JOIN teacher t ON se.teacherId = t.teacherId "
            + "WHERE " + studentIdMatchClause("se.studentId", studentIdVariants(studentId))
            + " AND " + evalCompletedPredicate(conn, "se") + " "
            + "AND " + sessionCol + " IS NOT NULL "
            + "AND " + feedbackNotExistsForSession("se.studentId", sessionCol, 
                hasEvalColumn(conn, "scheduleId") ? "COALESCE(se.scheduleId, se.sessionId)" : sessionCol) + " "
            + "ORDER BY se.studentEvaluationId DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            bindStudentIdVariants(ps, 1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapCompletedSessionRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.queryCompletedSessionsFromTeacherEval: " + e.getMessage());
        }
        return list;
    }

    /**
     * Sessions where the teacher ended class (PENDING eval row exists) but the student
     * has not yet submitted teacher feedback.
     */
    private List<Evaluation> queryCompletedSessionsFromPendingTeacherEval(Connection conn, String studentId) {
        List<Evaluation> list = new ArrayList<>();
        if (!hasEvalColumn(conn, "sessionId")) {
            return list;
        }
        String sessionCol = "NULLIF(TRIM(se.sessionId), '')";
        String scheduleCol = hasEvalColumn(conn, "scheduleId") ? "se.scheduleId" : "NULL AS scheduleId";
        String scheduleMatch = hasEvalColumn(conn, "scheduleId") ? "COALESCE(se.scheduleId, se.sessionId)" : sessionCol;
        String surahExpr = hasEvalColumn(conn, "surah") ? "COALESCE(se.surah, '')" : "''";
        String ayahExpr = hasEvalColumn(conn, "ayah_range") ? "COALESCE(se.ayah_range, '')" : "''";
        String createdCol = TalaqqiSchemaUtil.studentEvalCreatedColumn(conn, "se");
        String dateExpr = hasEvalColumn(conn, "session_date")
            ? "DATE_FORMAT(COALESCE(se.session_date, " + createdCol + "),'%b %d, %Y')"
            : (createdCol.contains(".")
                ? "DATE_FORMAT(" + createdCol + ",'%b %d, %Y')"
                : "DATE_FORMAT(NOW(),'%b %d, %Y')");
        String startExpr = hasEvalColumn(conn, "start_time")
            ? "DATE_FORMAT(se.start_time,'%I:%i %p')" : "''";
        String endExpr = hasEvalColumn(conn, "end_time")
            ? "DATE_FORMAT(se.end_time,'%I:%i %p')" : "''";
        String sql =
            "SELECT " + sessionCol + " AS sessionId, " + scheduleCol + ", se.teacherId, "
            + "COALESCE(t.teacherName, '') AS teacherName, "
            + dateExpr + " AS sessionDate, " + startExpr + " AS startTime, " + endExpr + " AS endTime, "
            + surahExpr + " AS surahName, " + ayahExpr + " AS ayahRange "
            + "FROM studentevaluation se "
            + "LEFT JOIN teacher t ON se.teacherId = t.teacherId "
            + "WHERE " + studentIdMatchClause("se.studentId", studentIdVariants(studentId))
            + " AND " + sessionCol + " IS NOT NULL "
            + " AND UPPER(COALESCE(se.status, 'PENDING')) = 'PENDING' "
            + "AND " + feedbackNotExistsForSession("se.studentId", sessionCol, scheduleMatch) + " "
            + "ORDER BY se.studentEvaluationId DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            bindStudentIdVariants(ps, 1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapCompletedSessionRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.queryCompletedSessionsFromPendingTeacherEval: " + e.getMessage());
        }
        return list;
    }

    /** Present/Late attendance — primary source for Evaluate Teacher list. */
    private List<Evaluation> queryEvaluableSessionsFromAttendance(Connection conn, String studentId) {
        List<Evaluation> list = new ArrayList<>();
        String sessionTable = TalaqqiSchemaUtil.sessionTable(conn);
        String sessionIdExpr =
            "COALESCE(NULLIF(TRIM(ts.sessionId), ''), NULLIF(TRIM(cb.bookingId), ''), a.scheduleId)";
        String sql =
            "SELECT " + sessionIdExpr + " AS sessionId, a.scheduleId, cs.teacherId, "
            + "COALESCE(t.teacherName, '') AS teacherName, "
            + "DATE_FORMAT(COALESCE(cs.scheduleDate, a.attendanceDate),'%b %d, %Y') AS sessionDate, "
            + "DATE_FORMAT(cs.startTime,'%I:%i %p') AS startTime, "
            + "DATE_FORMAT(cs.endTime,'%I:%i %p') AS endTime, "
            + "CAST(COALESCE(cs.classSurah, 0) AS CHAR) AS surahName, "
            + "'' AS ayahRange "
            + "FROM attendance a "
            + "INNER JOIN classschedule cs ON a.scheduleId = cs.scheduleId "
            + "LEFT JOIN classbooking cb ON cb.scheduleId = a.scheduleId "
            + "  AND cb.bookingDate = a.attendanceDate "
            + "LEFT JOIN " + sessionTable + " ts ON ts.scheduleId = a.scheduleId "
            + "  AND (ts.sessionDate = a.attendanceDate OR ts.sessionDate IS NULL) "
            + "LEFT JOIN teacher t ON cs.teacherId = t.teacherId "
            + "WHERE " + studentIdMatchClause("a.studentId", studentIdVariants(studentId))
            + " AND UPPER(TRIM(a.attendanceStatus)) IN ('PRESENT', 'LATE') "
            + " AND a.joinTime IS NOT NULL "
            + " AND " + feedbackNotExistsForSession("a.studentId", sessionIdExpr, "a.scheduleId") + " "
            + "ORDER BY a.attendanceDate DESC, cs.startTime DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            bindStudentIdVariants(ps, 1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapCompletedSessionRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.queryEvaluableSessionsFromAttendance: " + e.getMessage());
            list = queryEvaluableSessionsFromAttendanceSimple(conn, studentId);
        }
        return list;
    }

    /** Minimal attendance query when extended joins fail on production schema. */
    private List<Evaluation> queryEvaluableSessionsFromAttendanceSimple(Connection conn, String studentId) {
        List<Evaluation> list = new ArrayList<>();
        String sql =
            "SELECT COALESCE(a.scheduleId, '') AS sessionId, a.scheduleId, "
            + "COALESCE(a.teacherId, cs.teacherId) AS teacherId, "
            + "COALESCE(t.teacherName, '') AS teacherName, "
            + "DATE_FORMAT(a.attendanceDate,'%b %d, %Y') AS sessionDate, "
            + "DATE_FORMAT(cs.startTime,'%I:%i %p') AS startTime, "
            + "DATE_FORMAT(cs.endTime,'%I:%i %p') AS endTime, "
            + "CAST(COALESCE(cs.classSurah, 0) AS CHAR) AS surahName, "
            + "'' AS ayahRange "
            + "FROM attendance a "
            + "INNER JOIN classschedule cs ON a.scheduleId = cs.scheduleId "
            + "LEFT JOIN teacher t ON t.teacherId = COALESCE(a.teacherId, cs.teacherId) "
            + "WHERE " + studentIdMatchClause("a.studentId", studentIdVariants(studentId))
            + " AND UPPER(TRIM(a.attendanceStatus)) IN ('PRESENT', 'LATE') "
            + " AND a.joinTime IS NOT NULL "
            + " AND " + feedbackNotExistsForSession("a.studentId", "a.scheduleId", "a.scheduleId") + " "
            + "ORDER BY a.attendanceDate DESC, cs.startTime DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            bindStudentIdVariants(ps, 1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapCompletedSessionRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.queryEvaluableSessionsFromAttendanceSimple: " + e.getMessage());
        }
        return list;
    }

    /** Bookings where the student attended (Present/Late), even if bookingStatus is not Completed. */
    private List<Evaluation> queryEvaluableSessionsFromAttendedBookings(Connection conn, String studentId) {
        List<Evaluation> list = new ArrayList<>();
        String sessionTable = TalaqqiSchemaUtil.sessionTable(conn);
        String sessionIdExpr =
            "COALESCE(NULLIF(TRIM(ts.sessionId), ''), NULLIF(TRIM(cb.bookingId), ''), cb.scheduleId)";
        String sql =
            "SELECT " + sessionIdExpr + " AS sessionId, cb.scheduleId, cs.teacherId, "
            + "COALESCE(t.teacherName, '') AS teacherName, "
            + "DATE_FORMAT(cb.bookingDate,'%b %d, %Y') AS sessionDate, "
            + "DATE_FORMAT(cs.startTime,'%I:%i %p') AS startTime, "
            + "DATE_FORMAT(cs.endTime,'%I:%i %p') AS endTime, "
            + "CAST(COALESCE(cs.classSurah, 0) AS CHAR) AS surahName, "
            + "'' AS ayahRange "
            + "FROM classbooking cb "
            + "INNER JOIN classschedule cs ON cb.scheduleId = cs.scheduleId "
            + "INNER JOIN attendance a ON a.scheduleId = cb.scheduleId "
            + "  AND a.attendanceDate = cb.bookingDate "
            + "  AND UPPER(TRIM(a.attendanceStatus)) IN ('PRESENT', 'LATE') "
            + "  AND a.joinTime IS NOT NULL "
            + "LEFT JOIN " + sessionTable + " ts ON ts.scheduleId = cb.scheduleId "
            + "  AND (ts.sessionDate = cb.bookingDate OR ts.sessionDate IS NULL) "
            + "LEFT JOIN teacher t ON cs.teacherId = t.teacherId "
            + "WHERE " + studentIdMatchClause("cb.studentId", studentIdVariants(studentId))
            + " AND " + studentIdMatchClause("a.studentId", studentIdVariants(studentId))
            + " AND cb.bookingStatus NOT IN ('Cancelled', 'Rescheduled') "
            + " AND " + feedbackNotExistsForSession("cb.studentId", sessionIdExpr, "cb.scheduleId") + " "
            + "ORDER BY cb.bookingDate DESC, cs.startTime DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            int nextParam = bindStudentIdVariants(ps, 1, studentId);
            bindStudentIdVariants(ps, nextParam, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapCompletedSessionRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.queryEvaluableSessionsFromAttendedBookings: " + e.getMessage());
        }
        return list;
    }

    /** @deprecated use {@link #queryEvaluableSessionsFromAttendance} */
    private List<Evaluation> queryCompletedSessionsFromAttendance(Connection conn, String studentId) {
        return queryEvaluableSessionsFromAttendance(conn, studentId);
    }

    private String feedbackNotExistsForSession(String studentIdExpr, String sessionIdExpr, String scheduleIdExpr) {
        return "NOT EXISTS ( "
            + "SELECT 1 FROM studentfeedback sf "
            + "WHERE sf.studentId = " + studentIdExpr + " "
            + "AND (sf.sessionId = " + sessionIdExpr
            + " OR sf.sessionId = " + scheduleIdExpr
            + " OR sf.scheduleId = " + scheduleIdExpr
            + ")) ";
    }

    private Evaluation mapCompletedSessionRow(ResultSet rs) throws SQLException {
        Evaluation e = new Evaluation();
        e.setSessionId(rs.getString("sessionId"));
        e.setScheduleId(rs.getString("scheduleId"));
        e.setTeacherId(rs.getString("teacherId"));
        e.setTeacherName(rs.getString("teacherName"));
        e.setSessionDate(rs.getString("sessionDate"));
        e.setStartTime(rs.getString("startTime"));
        e.setEndTime(rs.getString("endTime"));
        e.setSurahName(resolveSurahDisplay(rs.getString("surahName")));
        e.setAyahRange(rs.getString("ayahRange"));
        return e;
    }

    /**
     * Returns completed sessions that are PENDING evaluation (no feedback submitted yet).
     * Used by PostSessionEvaluationServlet.
     */
    public List<Map<String, Object>> getPendingEvaluationSessions(String studentId) {
        List<Map<String, Object>> list = new ArrayList<>();
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                return list;
            }
            String ayahRange = TalaqqiSchemaUtil.ayahRangeExpr(conn);
            String sql =
                "SELECT ts.sessionId, cs.teacherId, t.teacherName, "
                + "       cs.classSurah AS surah, "
                + "       " + ayahRange + " AS ayah "
                + TalaqqiSchemaUtil.innerSessionBookingSchedule(conn)
                + "LEFT JOIN teacher   t  ON cs.teacherId  = t.teacherId "
                + "WHERE " + studentIdMatchClause("cb.studentId", studentIdVariants(studentId))
                + "  AND UPPER(TRIM(COALESCE(cb.bookingStatus, ''))) IN ('COMPLETED', 'COMPLETE', 'DONE') "
                + "  AND NOT EXISTS ( "
                + "      SELECT 1 FROM studentfeedback sf "
                + "      WHERE sf.sessionId = ts.sessionId AND sf.studentId = cb.studentId "
                + "  ) "
                + "ORDER BY cs.scheduleDate DESC LIMIT 20";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                bindStudentIdVariants(ps, 1, studentId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> row = new HashMap<>();
                        row.put("sessionId",   rs.getString("sessionId"));
                        row.put("teacherId",   rs.getString("teacherId"));
                        row.put("teacherName", rs.getString("teacherName"));
                        row.put("surah",       rs.getString("surah"));
                        row.put("ayah",        rs.getString("ayah"));
                        list.add(row);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.getPendingEvaluationSessions: " + e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException ignored) {}
            }
        }
        return list;
    }

    // ══════════════════════════════════════════════════════════════════════════
    // STUDENT → TEACHER feedback  (studentfeedback table)
    // ══════════════════════════════════════════════════════════════════════════

    /**
     * Inserts a new student evaluation of a teacher.
     */
    public boolean insertTeacherEvaluation(String studentId, String teacherId,
                                           String sessionId, String scheduleId,
                                           int rating, String comments, String suggestions) {
        ensureFeedbackTableExists();
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                return false;
            }
            studentId = resolveStudentIdForFeedback(conn, studentId);
            teacherId = resolveTeacherIdForFeedback(conn, teacherId);
            if (studentId == null || studentId.isEmpty() || teacherId == null || teacherId.isEmpty()) {
                System.err.println("EvaluationDAO.insertTeacherEvaluation: missing studentId or teacherId");
                return false;
            }

            String existingId = findExistingFeedbackId(conn, studentId, sessionId, scheduleId);
            if (existingId != null) {
                return updateTeacherEvaluation(existingId, rating, comments, suggestions);
            }

            String sql =
                "INSERT INTO studentfeedback (feedbackId, studentId, teacherId, sessionId, scheduleId, rating, comments, suggestions) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                String feedbackId = "FB-" + System.currentTimeMillis() + "-" + (int) (Math.random() * 10000);
                ps.setString(1, feedbackId);
                ps.setString(2, studentId);
                ps.setString(3, teacherId);
                ps.setString(4, sessionId);
                bindFeedbackScheduleId(ps, 5, conn, scheduleId);
                ps.setInt(6, rating);
                ps.setString(7, comments);
                ps.setString(8, suggestions);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.insertTeacherEvaluation: " + e.getMessage());
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException ignored) {}
            }
        }
        return false;
    }

    /**
     * Updates an existing student feedback record.
     */
    public boolean updateTeacherEvaluation(String feedbackId, int rating,
                                           String comments, String suggestions) {
        String sql =
            "UPDATE studentfeedback SET rating=?, comments=?, suggestions=? WHERE feedbackId=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (conn == null) return false;
            ps.setInt(1, rating);
            ps.setString(2, comments);
            ps.setString(3, suggestions);
            ps.setString(4, feedbackId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.updateTeacherEvaluation: " + e.getMessage());
        }
        return false;
    }

    /**
     * Returns all teacher evaluations submitted by a student.
     */
    public List<Evaluation> getStudentSubmittedFeedback(String studentId) {
        List<Evaluation> list = new ArrayList<>();
        ensureFeedbackTableExists();
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                return list;
            }
            try {
                String resolvedStudentId = resolveStudentIdForFeedback(conn, studentId);
                if (resolvedStudentId != null && !resolvedStudentId.isEmpty()) {
                    studentId = resolvedStudentId;
                }
            } catch (SQLException e) {
                System.err.println("EvaluationDAO.getStudentSubmittedFeedback resolveStudentId: "
                    + e.getMessage());
            }
            list = queryStudentSubmittedFeedback(conn, studentId, true);
            if (list.isEmpty()) {
                list = queryStudentSubmittedFeedback(conn, studentId, false);
            }
        } catch (SQLException ex) {
            System.err.println("EvaluationDAO.getStudentSubmittedFeedback: " + ex.getMessage());
            ex.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException ignored) {}
            }
        }
        return list;
    }

    private List<Evaluation> queryStudentSubmittedFeedback(Connection conn, String studentId, boolean withSessionJoin)
            throws SQLException {
        List<Evaluation> list = new ArrayList<>();
        String createdExpr = feedbackCreatedAtExpr(conn);
        String ayahRange = TalaqqiSchemaUtil.ayahRangeExpr(conn);
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT sf.feedbackId, sf.studentId, sf.teacherId, sf.sessionId, ")
            .append("       sf.rating, sf.comments, sf.suggestions, ")
            .append("       ").append(createdExpr).append(" AS createdAt, ")
            .append("       COALESCE(t.teacherName, '') AS teacherName ");
        if (withSessionJoin) {
            sql.append(", DATE_FORMAT(cs.scheduleDate,'%Y-%m-%d') AS sessionDate ")
                .append(", DATE_FORMAT(cs.startTime,'%H:%i:%s') AS startTime ")
                .append(", DATE_FORMAT(cs.endTime,'%H:%i:%s') AS endTime ")
                .append(", CAST(cs.classSurah AS CHAR) AS surahName ")
                .append(", ").append(ayahRange).append(" AS ayahRange ");
        } else {
            sql.append(", '' AS sessionDate, '' AS startTime, '' AS endTime, '' AS surahName, '' AS ayahRange ");
        }
        sql.append("FROM studentfeedback sf ")
            .append("LEFT JOIN teacher t ON t.teacherId = sf.teacherId ");
        if (withSessionJoin) {
            sql.append(TalaqqiSchemaUtil.leftJoinSessionFromFeedback(conn));
        }
        sql.append("WHERE ").append(studentIdMatchClause("sf.studentId", studentIdVariants(studentId)))
            .append(" ORDER BY ").append(feedbackOrderColumn(conn)).append(" DESC");

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bindStudentIdVariants(ps, 1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapSubmittedFeedbackRow(rs));
                }
            }
        } catch (SQLException e) {
            if (withSessionJoin) {
                throw e;
            }
            System.err.println("EvaluationDAO.queryStudentSubmittedFeedback: " + e.getMessage());
        }
        return list;
    }

    private Evaluation mapSubmittedFeedbackRow(ResultSet rs) throws SQLException {
        Evaluation e = new Evaluation();
        e.setFeedbackId(rs.getString("feedbackId"));
        e.setStudentId(rs.getString("studentId"));
        e.setTeacherId(rs.getString("teacherId"));
        e.setSessionId(rs.getString("sessionId"));
        e.setRating(rs.getInt("rating"));
        e.setComments(rs.getString("comments"));
        e.setSuggestions(rs.getString("suggestions"));
        e.setCreatedAt(rs.getString("createdAt"));
        e.setTeacherName(rs.getString("teacherName"));
        try {
            e.setSessionDate(rs.getString("sessionDate"));
            e.setStartTime(rs.getString("startTime"));
            e.setEndTime(rs.getString("endTime"));
            e.setSurahName(resolveSurahDisplay(rs.getString("surahName")));
            e.setAyahRange(rs.getString("ayahRange"));
        } catch (SQLException ignored) {
            e.setSessionDate("");
            e.setStartTime("");
            e.setEndTime("");
            e.setSurahName("");
            e.setAyahRange("");
        }
        return e;
    }

    /**
     * Records session feedback. Used by PostSessionEvaluationServlet.
     * studentRating / teacherRating = 0 means "not provided".
     */
    public boolean recordSessionFeedback(String sessionId, String studentId, String teacherId,
                                         int studentRating, String studentComments,
                                         int teacherRating, String teacherComments) {
        ensureFeedbackTableExists();
        if (studentRating > 0) {
            return insertTeacherEvaluation(studentId, teacherId, sessionId, null,
                                          studentRating, studentComments, "");
        }
        return false;
    }

    /**
     * Returns monthly evaluation status (used by PostSessionEvaluationServlet).
     */
    public Map<String, Object> getMonthlyEvaluationStatus(String studentId) {
        Map<String, Object> status = new HashMap<>();
        ensureFeedbackTableExists();

        String sql =
            "SELECT COUNT(*) AS cnt FROM studentfeedback " +
            "WHERE studentId = ? AND MONTH(createdAt)=MONTH(NOW()) AND YEAR(createdAt)=YEAR(NOW())";

        int count = 0;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (conn != null) {
                ps.setString(1, studentId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) count = rs.getInt("cnt");
                }
            }
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.getMonthlyEvaluationStatus: " + e.getMessage());
        }

        java.time.Month currentMonth = java.time.LocalDate.now().getMonth();
        status.put("isNewMonth",           count == 0);
        status.put("currentMonth",         currentMonth.getDisplayName(java.time.format.TextStyle.FULL, java.util.Locale.ENGLISH));
        status.put("evaluationSubmitted",  count > 0);
        status.put("evaluationCount",      count);
        return status;
    }

    // ══════════════════════════════════════════════════════════════════════════
    // ADMIN / TEACHER aggregate helpers
    // ══════════════════════════════════════════════════════════════════════════

    /** Legacy: get latest result string for admin dashboard. */
    public String getLatestEvaluationResult(String studentId) {
        String sql =
            "SELECT tajweedScore, fluencyScore, accuracyScore " +
            "FROM studentevaluation WHERE studentId = ? " +
            "ORDER BY studentEvaluationId DESC LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (conn == null) return "N/A";
            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double sum = 0; int n = 0;
                    Object t = rs.getObject("tajweedScore");
                    Object f = rs.getObject("fluencyScore");
                    Object a = rs.getObject("accuracyScore");
                    if (t != null) { sum += ((Number)t).doubleValue(); n++; }
                    if (f != null) { sum += ((Number)f).doubleValue(); n++; }
                    if (a != null) { sum += ((Number)a).doubleValue(); n++; }
                    return n > 0 ? String.format("%.1f / 100", sum / n) : "N/A";
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return "N/A";
    }

    /** Pending evaluations count for teacher dashboard. */
    public int getPendingEvaluationsCount(String teacherId) {
        String sql =
            "SELECT COUNT(*) AS cnt FROM studentevaluation " +
            "WHERE teacherId=? AND tajweedScore IS NULL AND fluencyScore IS NULL AND accuracyScore IS NULL";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (conn == null) return 0;
            ps.setString(1, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("cnt");
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    /** Recent student feedback list for teacher dashboard. */
    public List<Map<String, Object>> getRecentFeedback(String teacherId, int limit) {
        List<Map<String, Object>> feedbackList = new ArrayList<>();
        String sql =
            "SELECT sf.feedbackId, sf.rating, sf.comments, sf.createdAt, " +
            "       s.studentName, s.studentId " +
            "FROM studentfeedback sf " +
            "JOIN student s ON sf.studentId = s.studentId " +
            "WHERE sf.teacherId = ? " +
            "ORDER BY sf.createdAt DESC LIMIT ?";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) return feedbackList;
            // studentfeedback may not exist yet — fall back gracefully
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, teacherId);
                ps.setInt(2, limit);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> row = new HashMap<>();
                        row.put("rating",      rs.getInt("rating"));
                        row.put("comment",     rs.getString("comments"));
                        row.put("date",        rs.getTimestamp("createdAt"));
                        row.put("studentName", rs.getString("studentName"));
                        row.put("studentId",   rs.getString("studentId"));
                        feedbackList.add(row);
                    }
                }
            } catch (SQLException ex) {
                System.err.println("EvaluationDAO.getRecentFeedback (studentfeedback not ready): " + ex.getMessage());
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return feedbackList;
    }

    /** Average ratings for admin dashboard. */
    public Map<String, Object> getAverageRatings() {
        Map<String, Object> ratings = new HashMap<>();
        String sql =
            "SELECT AVG((COALESCE(tajweedScore,0)+COALESCE(fluencyScore,0)+COALESCE(accuracyScore,0))/3) AS avgTeacherRating " +
            "FROM studentevaluation " +
            "WHERE tajweedScore IS NOT NULL OR fluencyScore IS NOT NULL OR accuracyScore IS NOT NULL";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (conn == null) { ratings.put("teacherRating", 4.6); ratings.put("studentPerformance", 4.2); return ratings; }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double avg = rs.getDouble("avgTeacherRating");
                    ratings.put("teacherRating",      avg > 0 ? avg : 4.6);
                    ratings.put("studentPerformance", avg > 0 ? avg : 4.2);
                    return ratings;
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        ratings.put("teacherRating", 4.6);
        ratings.put("studentPerformance", 4.2);
        return ratings;
    }

    // ══════════════════════════════════════════════════════════════════════════
    // Private helpers
    // ══════════════════════════════════════════════════════════════════════════

    private Evaluation mapStudentEval(ResultSet rs) throws SQLException {
        Evaluation e = new Evaluation();
        e.setEvaluationId(rs.getString("studentEvaluationId"));
        e.setStudentId(rs.getString("studentId"));
        e.setTeacherId(rs.getString("teacherId"));
        try {
            e.setSessionId(rs.getString("sessionId"));
        } catch (SQLException ignored) {
            e.setSessionId("");
        }

        e.setTajweedScore(rs.getDouble("tajweedScore"));
        e.setFluencyScore(rs.getDouble("fluencyScore"));
        e.setAccuracyScore(rs.getDouble("accuracyScore"));
        e.setOverallScore(rs.getDouble("overallScore"));

        e.setStrengths(rs.getString("strength"));
        e.setImprovements(rs.getString("weakness"));
        e.setSuggestions(rs.getString("studentImprovements"));
        e.setNextTarget(TextEncodingUtil.normalizeAsciiDash(rs.getString("nextTarget")));
        e.setComments(rs.getString("comments"));

        e.setTeacherName(rs.getString("teacherName"));
        try {
            e.setSurahName(resolveSurahDisplay(rs.getString("surahName")));
            e.setAyahRange(rs.getString("ayahRange"));
            e.setCreatedAt(rs.getString("createdAt"));
        } catch (SQLException ignored) {
            e.setSurahName("");
            e.setAyahRange("");
            e.setCreatedAt("");
        }
        return e;
    }

    private String resolveSurahDisplay(String surahValue) {
        if (surahValue == null) return "";
        String trimmed = surahValue.trim();
        if (trimmed.isEmpty()) return "";
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
        return "Surah " + surahNumber;
    }

    private double roundOrZero(double v) {
        return Double.isNaN(v) ? 0.0 : Math.round(v * 10.0) / 10.0;
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
            String formatted = trimmed.toUpperCase().startsWith("S")
                ? "S" + String.format("%03d", n) : String.format("%03d", n);
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

    private int bindStudentIdVariants(PreparedStatement ps, int index, String studentId)
            throws SQLException {
        List<String> variants = studentIdVariants(studentId);
        if (variants.isEmpty()) {
            ps.setString(index++, studentId);
            return index;
        }
        for (String id : variants) {
            ps.setString(index++, id);
        }
        return index;
    }

    private String normalizeTeacherId(String teacherId) {
        if (teacherId == null || teacherId.trim().isEmpty()) {
            return teacherId;
        }
        String trimmed = teacherId.trim();
        if (trimmed.matches("T\\d+")) {
            return trimmed;
        }
        String digits = trimmed.replaceAll("[^0-9]", "");
        if (!digits.isEmpty()) {
            return "T" + String.format("%03d", Integer.parseInt(digits));
        }
        return trimmed;
    }

    private String normalizeStudentId(String studentId) {
        if (studentId == null || studentId.trim().isEmpty()) {
            return studentId;
        }
        String trimmed = studentId.trim();
        if (trimmed.matches("S\\d+")) {
            return trimmed;
        }
        String digits = trimmed.replaceAll("[^0-9]", "");
        if (!digits.isEmpty()) {
            return "S" + String.format("%03d", Integer.parseInt(digits));
        }
        return trimmed;
    }

    /** Resolve studentId to a row that satisfies studentfeedback FK. */
    private String resolveStudentIdForFeedback(Connection conn, String studentId) throws SQLException {
        if (studentId == null || studentId.trim().isEmpty()) {
            return null;
        }
        for (String candidate : studentIdVariants(studentId)) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT studentId FROM student WHERE studentId = ? LIMIT 1")) {
                ps.setString(1, candidate);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getString("studentId");
                    }
                }
            }
        }
        return normalizeStudentId(studentId);
    }

    /** Resolve teacherId to a row that satisfies studentfeedback FK. */
    private String resolveTeacherIdForFeedback(Connection conn, String teacherId) throws SQLException {
        if (teacherId == null || teacherId.trim().isEmpty()) {
            return null;
        }
        String normalized = normalizeTeacherId(teacherId);
        List<String> candidates = new ArrayList<>();
        candidates.add(normalized);
        candidates.add(teacherId.trim());
        String digits = teacherId.replaceAll("[^0-9]", "");
        if (!digits.isEmpty()) {
            candidates.add("T" + String.format("%03d", Integer.parseInt(digits)));
        }
        for (String candidate : candidates) {
            if (candidate == null || candidate.isEmpty()) {
                continue;
            }
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT teacherId FROM teacher WHERE teacherId = ? LIMIT 1")) {
                ps.setString(1, candidate);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getString("teacherId");
                    }
                }
            }
        }
        return normalized;
    }

    private String findExistingFeedbackId(Connection conn, String studentId, String sessionId, String scheduleId)
            throws SQLException {
        if (sessionId != null && !sessionId.trim().isEmpty()) {
            String sql = "SELECT feedbackId FROM studentfeedback WHERE studentId = ? AND sessionId = ? LIMIT 1";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, studentId);
                ps.setString(2, sessionId.trim());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getString("feedbackId");
                    }
                }
            }
        }
        if (scheduleId != null && !scheduleId.trim().isEmpty()) {
            String sql = "SELECT feedbackId FROM studentfeedback WHERE studentId = ? AND scheduleId = ? LIMIT 1";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, studentId);
                bindFeedbackScheduleId(ps, 2, conn, scheduleId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getString("feedbackId");
                    }
                }
            }
        }
        return null;
    }

    private void bindFeedbackScheduleId(PreparedStatement ps, int index, Connection conn, String scheduleId)
            throws SQLException {
        if (scheduleId == null || scheduleId.trim().isEmpty()) {
            ps.setNull(index, Types.VARCHAR);
            return;
        }
        String trimmed = scheduleId.trim();
        if (TalaqqiSchemaUtil.hasColumn(conn, "studentfeedback", "scheduleId")) {
            ps.setString(index, trimmed);
            return;
        }
        ps.setNull(index, Types.VARCHAR);
    }

    private String feedbackCreatedAtExpr(Connection conn) {
        if (TalaqqiSchemaUtil.hasColumn(conn, "studentfeedback", "createdAt")) {
            return "DATE_FORMAT(sf.createdAt,'%b %d, %Y')";
        }
        if (TalaqqiSchemaUtil.hasColumn(conn, "studentfeedback", "created_at")) {
            return "DATE_FORMAT(sf.created_at,'%b %d, %Y')";
        }
        return "DATE_FORMAT(NOW(),'%b %d, %Y')";
    }

    private String feedbackOrderColumn(Connection conn) {
        if (TalaqqiSchemaUtil.hasColumn(conn, "studentfeedback", "createdAt")) {
            return "sf.createdAt";
        }
        if (TalaqqiSchemaUtil.hasColumn(conn, "studentfeedback", "created_at")) {
            return "sf.created_at";
        }
        return "sf.feedbackId";
    }

    /**
     * Creates the studentfeedback table if it does not exist.
     * Called before every write/read against that table so the first deploy
     * works without a manual SQL migration.
     */
    private void ensureFeedbackTableExists() {
        String ddl =
            "CREATE TABLE IF NOT EXISTS studentfeedback (" +
            "  feedbackId  VARCHAR(50)  NOT NULL PRIMARY KEY, " +
            "  studentId   VARCHAR(50)  NOT NULL, " +
            "  teacherId   VARCHAR(50)  NOT NULL, " +
            "  sessionId   VARCHAR(50)  DEFAULT NULL, " +
            "  scheduleId  VARCHAR(10)  DEFAULT NULL, " +
            "  rating      INT          NOT NULL DEFAULT 0, " +
            "  comments    TEXT, " +
            "  suggestions TEXT, " +
            "  createdAt   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP, " +
            "  KEY idx_sf_student (studentId), " +
            "  KEY idx_sf_teacher (teacherId), " +
            "  KEY idx_sf_session (sessionId) " +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";

        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement()) {
            if (conn == null) {
                return;
            }
            st.execute(ddl);
            migrateFeedbackScheduleIdColumn(conn);
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.ensureFeedbackTableExists: " + e.getMessage());
        }
    }

    /** classschedule.scheduleId is VARCHAR; legacy studentfeedback used INT. */
    private void migrateFeedbackScheduleIdColumn(Connection conn) {
        try (Statement st = conn.createStatement()) {
            st.execute("ALTER TABLE studentfeedback MODIFY scheduleId VARCHAR(10) DEFAULT NULL");
        } catch (SQLException ignored) {
            // Column may already be VARCHAR or ALTER unsupported on hosted DB
        }
    }
}
