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
        List<Evaluation> list = new ArrayList<>();
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                return list;
            }
            ensureFeedbackTableExists();
            list = queryCompletedSessionsForStudent(conn, studentId, true);
            if (list.isEmpty()) {
                list = queryCompletedSessionsForStudent(conn, studentId, false);
            }
            if (list.isEmpty()) {
                list = queryCompletedSessionsBookingOnly(conn, studentId);
            }
            if (list.isEmpty()) {
                list = queryCompletedSessionsFromEndedSessions(conn, studentId);
            }
            if (list.isEmpty()) {
                list = queryCompletedSessionsFromTeacherEval(conn, studentId);
            }
            if (list.isEmpty()) {
                list = queryCompletedSessionsFromPendingTeacherEval(conn, studentId);
            }
            if (list.isEmpty()) {
                list = queryCompletedSessionsFromAttendance(conn, studentId);
            }
            System.out.println("EvaluationDAO.getCompletedSessionsForStudent: studentId="
                + studentId + " found=" + list.size());
        } catch (SQLException ex) {
            System.err.println("EvaluationDAO.getCompletedSessionsForStudent: " + ex.getMessage());
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

    private List<Evaluation> queryCompletedSessionsForStudent(Connection conn, String studentId,
                                                              boolean withFeedbackFilter)
            throws SQLException {
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
            ? "  AND NOT EXISTS ( "
                + "      SELECT 1 FROM studentfeedback sf "
                + "      WHERE sf.sessionId = ts.sessionId AND sf.studentId = cb.studentId "
                + "  ) "
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
            if (withFeedbackFilter) {
                throw e;
            }
            System.err.println("EvaluationDAO.queryCompletedSessionsForStudent fallback: "
                + e.getMessage());
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
            + "AND NOT EXISTS ( "
            + "  SELECT 1 FROM studentfeedback sf "
            + "  WHERE sf.studentId = se.studentId AND sf.sessionId = se.sessionId "
            + ") "
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
            + "AND NOT EXISTS ( "
            + "  SELECT 1 FROM studentfeedback sf "
            + "  WHERE sf.studentId = se.studentId AND sf.sessionId = se.sessionId "
            + ") "
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

    /** Sessions where the student attended (Present/Late) and may rate the teacher. */
    private List<Evaluation> queryCompletedSessionsFromAttendance(Connection conn, String studentId) {
        List<Evaluation> list = new ArrayList<>();
        String sessionTable = TalaqqiSchemaUtil.sessionTable(conn);
        String ayahRange = TalaqqiSchemaUtil.ayahRangeExpr(conn);
        String sessionIdExpr = "COALESCE("
            + "(SELECT ts2.sessionId FROM " + sessionTable + " ts2 "
            + " WHERE ts2.scheduleId = a.scheduleId "
            + " AND (ts2.sessionDate = a.attendanceDate OR ts2.sessionDate IS NULL) "
            + " ORDER BY ts2.sessionDate DESC LIMIT 1), a.scheduleId)";
        String sql =
            "SELECT " + sessionIdExpr + " AS sessionId, a.scheduleId, cs.teacherId, t.teacherName, "
            + "DATE_FORMAT(a.attendanceDate,'%b %d, %Y') AS sessionDate, "
            + "DATE_FORMAT(cs.startTime,'%I:%i %p') AS startTime, "
            + "DATE_FORMAT(cs.endTime,'%I:%i %p') AS endTime, "
            + "CAST(cs.classSurah AS CHAR) AS surahName, "
            + "CAST(" + ayahRange + " AS CHAR) AS ayahRange "
            + "FROM attendance a "
            + "JOIN classschedule cs ON a.scheduleId = cs.scheduleId "
            + "LEFT JOIN teacher t ON cs.teacherId = t.teacherId "
            + "WHERE " + studentIdMatchClause("a.studentId", studentIdVariants(studentId))
            + " AND a.attendanceStatus IN ('Present', 'Late') "
            + " AND NOT EXISTS ( "
            + "   SELECT 1 FROM studentfeedback sf "
            + "   WHERE sf.studentId = a.studentId "
            + "   AND (sf.sessionId = " + sessionIdExpr + " OR sf.sessionId = a.scheduleId) "
            + " ) "
            + "ORDER BY a.attendanceDate DESC, cs.startTime DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            bindStudentIdVariants(ps, 1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapCompletedSessionRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.queryCompletedSessionsFromAttendance: " + e.getMessage());
        }
        return list;
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
        teacherId = normalizeTeacherId(teacherId);
        String sql =
            "INSERT INTO studentfeedback (feedbackId, studentId, teacherId, sessionId, scheduleId, rating, comments, suggestions) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (conn == null) return false;
            String feedbackId = "FB-" + System.currentTimeMillis() + "-" + (int)(Math.random()*10000);
            ps.setString(1, feedbackId);
            ps.setString(2, studentId);
            ps.setString(3, teacherId);
            ps.setString(4, sessionId);
            if (scheduleId != null && !scheduleId.isEmpty()) {
                try { ps.setInt(5, Integer.parseInt(scheduleId)); }
                catch (NumberFormatException e) { ps.setNull(5, Types.INTEGER); }
            } else {
                ps.setNull(5, Types.INTEGER);
            }
            ps.setInt(6, rating);
            ps.setString(7, comments);
            ps.setString(8, suggestions);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.insertTeacherEvaluation: " + e.getMessage());
            e.printStackTrace();
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
            String ayahRange = TalaqqiSchemaUtil.ayahRangeExpr(conn);
            String sql =
                "SELECT sf.feedbackId, sf.studentId, sf.teacherId, sf.sessionId, "
                + "       sf.rating, sf.comments, sf.suggestions, "
                + "       DATE_FORMAT(sf.createdAt,'%b %d, %Y') AS createdAt, "
                + "       t.teacherName, "
                + "       DATE_FORMAT(cs.scheduleDate,'%Y-%m-%d') AS sessionDate, "
                + "       DATE_FORMAT(cs.startTime,'%H:%i:%s') AS startTime, "
                + "       DATE_FORMAT(cs.endTime,'%H:%i:%s') AS endTime, "
                + "       cs.classSurah AS surahName, "
                + "       " + ayahRange + " AS ayahRange "
                + "FROM studentfeedback sf "
                + "LEFT JOIN teacher      t  ON sf.teacherId  = t.teacherId "
                + TalaqqiSchemaUtil.leftJoinSessionFromFeedback(conn)
                + "WHERE " + studentIdMatchClause("sf.studentId", studentIdVariants(studentId))
                + " ORDER BY sf.createdAt DESC";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                bindStudentIdVariants(ps, 1, studentId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
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
                        e.setSessionDate(rs.getString("sessionDate"));
                        e.setStartTime(rs.getString("startTime"));
                        e.setEndTime(rs.getString("endTime"));
                        e.setSurahName(resolveSurahDisplay(rs.getString("surahName")));
                        e.setAyahRange(rs.getString("ayahRange"));
                        list.add(e);
                    }
                }
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
            "  scheduleId  INT          DEFAULT NULL, " +
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
            if (conn == null) return;
            st.execute(ddl);
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.ensureFeedbackTableExists: " + e.getMessage());
        }
    }
}
