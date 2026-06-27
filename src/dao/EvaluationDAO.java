package dao;

import model.Evaluation;
import util.DBConnection;
import util.TalaqqiSchemaUtil;
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
     * Returns the most-recent evaluation a teacher has given to a student.
     */
    public Evaluation getLatestEvaluationByStudent(String studentId) {
        String sql =
            "SELECT se.studentEvaluationId, se.studentId, se.teacherId, se.sessionId, " +
            "       se.tajweedScore, se.fluencyScore, se.accuracyScore, " +
            "       COALESCE(se.overall_score, (COALESCE(se.tajweedScore,0)+COALESCE(se.fluencyScore,0)+COALESCE(se.accuracyScore,0))/3) AS overallScore, " +
            "       se.strength, se.weakness, se.studentImprovements, se.nextTarget, se.comments, " +
            "       t.teacherName, " +
            "       se.surah AS surahName, se.ayah_range AS ayahRange, " +
            "       DATE_FORMAT(se.createdAt,'%b %d, %Y') AS createdAt " +
            "FROM studentevaluation se " +
            "LEFT JOIN teacher t ON se.teacherId = t.teacherId " +
            "WHERE se.studentId = ? " +
            "ORDER BY se.studentEvaluationId DESC LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (conn == null) return null;
            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapStudentEval(rs);
            }
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.getLatestEvaluationByStudent: " + e.getMessage());
        }
        return null;
    }

    /**
     * Returns the full evaluation history given to a student by teachers.
     */
    public List<Evaluation> getEvaluationHistory(String studentId) {
        List<Evaluation> list = new ArrayList<>();
        list = queryEvaluationHistory(studentId, true);
        if (list.isEmpty()) {
            list = queryEvaluationHistory(studentId, false);
        }
        return list;
    }

    private List<Evaluation> queryEvaluationHistory(String studentId, boolean withStatusFilter) {
        List<Evaluation> list = new ArrayList<>();
        String statusClause = withStatusFilter
            ? " AND (se.status IS NULL OR se.status IN ('COMPLETED', 'PENDING', '')) "
            : "";
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) return list;
            String sql =
                "SELECT se.studentEvaluationId, se.studentId, se.teacherId, se.sessionId, " +
                "       se.tajweedScore, se.fluencyScore, se.accuracyScore, " +
                "       COALESCE(se.overall_score, (COALESCE(se.tajweedScore,0)+COALESCE(se.fluencyScore,0)+COALESCE(se.accuracyScore,0))/3) AS overallScore, " +
                "       se.strength, se.weakness, se.studentImprovements, se.nextTarget, se.comments, " +
                "       t.teacherName, " +
                "       COALESCE(NULLIF(se.surah, ''), CAST(COALESCE(qd.currentSurah, cs.classSurah) AS CHAR)) AS surahName, " +
                "       COALESCE(NULLIF(se.ayah_range, ''), CAST(COALESCE(qd.currentAyah, cs.classAyah) AS CHAR)) AS ayahRange, " +
                "       DATE_FORMAT(se.createdAt,'%b %d, %Y') AS createdAt " +
                "FROM studentevaluation se " +
                "LEFT JOIN teacher t ON se.teacherId = t.teacherId " +
                TalaqqiSchemaUtil.leftJoinSessionFromEvaluation(conn) +
                "LEFT JOIN qurandisplay qd ON qd.sessionId = ts.sessionId " +
                "WHERE se.studentId = ? " + statusClause +
                "ORDER BY se.studentEvaluationId DESC";
            String resolved = TalaqqiSchemaUtil.sql(sql, conn);
            try (PreparedStatement ps = conn.prepareStatement(resolved)) {
                ps.setString(1, studentId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) list.add(mapStudentEval(rs));
                }
            }
        } catch (SQLException e) {
            if (withStatusFilter) {
                System.err.println("EvaluationDAO.getEvaluationHistory: " + e.getMessage());
            }
        }
        return list;
    }

    /**
     * Returns monthly performance trend data for Chart.js.
     */
    public List<Map<String, Object>> getPerformanceTrend(String studentId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql =
            "SELECT DATE_FORMAT(se.createdAt,'%b %Y') AS month, " +
            "       AVG(se.tajweedScore)  AS tajweed, " +
            "       AVG(se.fluencyScore)  AS fluency, " +
            "       AVG(se.accuracyScore) AS accuracy, " +
            "       AVG((COALESCE(se.tajweedScore,0)+COALESCE(se.fluencyScore,0)+COALESCE(se.accuracyScore,0))/3) AS overall " +
            "FROM studentevaluation se " +
            "WHERE se.studentId = ? " +
            "GROUP BY DATE_FORMAT(se.createdAt,'%Y-%m') " +
            "ORDER BY MIN(se.createdAt) ASC LIMIT 12";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (conn == null) return list;
            ps.setString(1, studentId);
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
        String sql =
            "SELECT AVG(tajweedScore) AS Tajweed, " +
            "       AVG(fluencyScore) AS Fluency, " +
            "       AVG(accuracyScore) AS Accuracy " +
            "FROM studentevaluation WHERE studentId = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (conn == null) return skills;
            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    skills.put("Tajweed",  roundOrZero(rs.getDouble("Tajweed")));
                    skills.put("Fluency",  roundOrZero(rs.getDouble("Fluency")));
                    skills.put("Accuracy", roundOrZero(rs.getDouble("Accuracy")));
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
        String sql = "SELECT COUNT(*) AS cnt FROM studentevaluation WHERE studentId = ? "
            + "AND (status IS NULL OR status IN ('COMPLETED', 'PENDING', ''))";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (conn == null) return 0;
            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("cnt");
            }
        } catch (SQLException e) {
            System.err.println("EvaluationDAO.getTotalEvaluationCount: " + e.getMessage());
        }
        return 0;
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
            String ayahRange = TalaqqiSchemaUtil.ayahRangeExpr(conn);
            String surahCol = "COALESCE(NULLIF(qd.currentSurah, 0), NULLIF(cs.classSurah, 0))";
            String ayahCol = TalaqqiSchemaUtil.hasClassAyahEnd(conn)
                ? "COALESCE(NULLIF(qd.currentAyah, 0), " + ayahRange + ")"
                : "COALESCE(NULLIF(qd.currentAyah, 0), CAST(cs.classAyah AS CHAR))";
            String sql =
                "SELECT ts.sessionId, cb.scheduleId, cs.teacherId, t.teacherName, "
                + "       DATE_FORMAT(cs.scheduleDate,'%b %d, %Y') AS sessionDate, "
                + "       DATE_FORMAT(cs.startTime,'%I:%i %p')     AS startTime, "
                + "       DATE_FORMAT(cs.endTime,'%I:%i %p')       AS endTime, "
                + "       CAST(" + surahCol + " AS CHAR) AS surahName, "
                + "       CAST(" + ayahCol + " AS CHAR) AS ayahRange "
                + TalaqqiSchemaUtil.innerSessionBookingSchedule(conn)
                + "LEFT JOIN qurandisplay qd ON qd.sessionId = ts.sessionId "
                + "LEFT JOIN teacher   t  ON cs.teacherId   = t.teacherId "
                + "WHERE cb.studentId = ? "
                + "  AND cb.bookingStatus = 'Completed' "
                + "  AND NOT EXISTS ( "
                + "      SELECT 1 FROM studentfeedback sf "
                + "      WHERE sf.sessionId = ts.sessionId AND sf.studentId = cb.studentId "
                + "  ) "
                + "ORDER BY cs.scheduleDate DESC, cs.startTime DESC";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, studentId);
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
            }
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
                + "WHERE cb.studentId = ? "
                + "  AND cb.bookingStatus = 'Completed' "
                + "  AND NOT EXISTS ( "
                + "      SELECT 1 FROM studentfeedback sf "
                + "      WHERE sf.sessionId = ts.sessionId AND sf.studentId = cb.studentId "
                + "  ) "
                + "ORDER BY cs.scheduleDate DESC LIMIT 20";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, studentId);
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
                + "WHERE sf.studentId = ? "
                + "ORDER BY sf.createdAt DESC";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, studentId);
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
        e.setSessionId(rs.getString("sessionId"));

        e.setTajweedScore(rs.getDouble("tajweedScore"));
        e.setFluencyScore(rs.getDouble("fluencyScore"));
        e.setAccuracyScore(rs.getDouble("accuracyScore"));
        e.setOverallScore(rs.getDouble("overallScore"));

        e.setStrengths(rs.getString("strength"));
        e.setImprovements(rs.getString("weakness"));
        e.setSuggestions(rs.getString("studentImprovements"));
        e.setNextTarget(rs.getString("nextTarget"));
        e.setComments(rs.getString("comments"));

        e.setTeacherName(rs.getString("teacherName"));
        e.setSurahName(resolveSurahDisplay(rs.getString("surahName")));
        e.setAyahRange(rs.getString("ayahRange"));
        e.setCreatedAt(rs.getString("createdAt"));
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
