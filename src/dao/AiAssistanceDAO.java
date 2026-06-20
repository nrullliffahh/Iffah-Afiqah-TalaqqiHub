package dao;

import model.AiAssistance;
import model.AiInteraction;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AiAssistanceDAO {

    public List<AiAssistance> getHistoryByStudent(String studentId, int limit) {
        List<AiAssistance> history = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return history;

            String sql = "SELECT aiId, aiQuestion, aiResponse, studentId, teacherId " +
                         "FROM aiassistance WHERE studentId = ? ORDER BY aiId DESC LIMIT ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, studentId);
            pstmt.setInt(2, limit);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                AiAssistance record = new AiAssistance();
                record.setAiId(rs.getString("aiId"));
                record.setAiQuestion(rs.getString("aiQuestion"));
                record.setAiResponse(rs.getString("aiResponse"));
                record.setStudentId(rs.getString("studentId"));
                record.setTeacherId(rs.getString("teacherId"));
                history.add(record);
            }
        } catch (SQLException e) {
            System.err.println("AiAssistanceDAO.getHistoryByStudent error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeQuietly(rs, pstmt, conn);
        }

        return history;
    }

    public int getCountByStudent(String studentId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return 0;

            String sql = "SELECT COUNT(*) AS total FROM aiassistance WHERE studentId = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, studentId);
            rs = pstmt.executeQuery();
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            System.err.println("AiAssistanceDAO.getCountByStudent error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeQuietly(rs, pstmt, conn);
        }

        return 0;
    }

    public String findSimilarResponse(String question) {
        if (question == null || question.trim().isEmpty()) return null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return null;

            String sql = "SELECT aiResponse FROM aiassistance " +
                         "WHERE LOWER(aiQuestion) LIKE ? ORDER BY aiId DESC LIMIT 1";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, "%" + question.trim().toLowerCase() + "%");
            rs = pstmt.executeQuery();
            if (rs.next()) return rs.getString("aiResponse");
        } catch (SQLException e) {
            System.err.println("AiAssistanceDAO.findSimilarResponse error: " + e.getMessage());
        } finally {
            closeQuietly(rs, pstmt, conn);
        }
        return null;
    }

    public List<AiAssistance> getHistoryByTeacher(String teacherId, int limit) {
        List<AiAssistance> history = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return history;

            String sql = "SELECT aiId, aiQuestion, aiResponse, studentId, teacherId " +
                         "FROM aiassistance WHERE teacherId = ? ORDER BY aiId DESC LIMIT ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, teacherId);
            pstmt.setInt(2, limit);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                AiAssistance record = mapRecord(rs);
                history.add(record);
            }
        } catch (SQLException e) {
            System.err.println("AiAssistanceDAO.getHistoryByTeacher error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeQuietly(rs, pstmt, conn);
        }

        return history;
    }

    public int getCountByTeacher(String teacherId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return 0;

            String sql = "SELECT COUNT(*) AS total FROM aiassistance WHERE teacherId = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, teacherId);
            rs = pstmt.executeQuery();
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            System.err.println("AiAssistanceDAO.getCountByTeacher error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeQuietly(rs, pstmt, conn);
        }

        return 0;
    }

    public boolean saveForTeacher(String teacherId, String question, String response) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return false;

            String studentId = resolveLinkedStudentId(conn, teacherId);
            if (studentId == null) {
                System.err.println("AiAssistanceDAO.saveForTeacher: no linked student for teacher " + teacherId);
                return false;
            }

            String aiId = generateNextId(conn);
            String sql = "INSERT INTO aiassistance (aiId, aiQuestion, aiResponse, studentId, teacherId) " +
                         "VALUES (?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, aiId);
            pstmt.setString(2, question);
            pstmt.setString(3, response);
            pstmt.setString(4, studentId);
            pstmt.setString(5, teacherId);

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("AiAssistanceDAO.saveForTeacher error: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeQuietly(rs, pstmt, conn);
        }
    }

    private String resolveLinkedStudentId(Connection conn, String teacherId) throws SQLException {
        String sql = "SELECT studentId FROM classschedule WHERE teacherId = ? AND studentId IS NOT NULL LIMIT 1";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, teacherId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getString("studentId");
            }
        }
        sql = "SELECT studentId FROM student LIMIT 1";
        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) return rs.getString("studentId");
        }
        return null;
    }

    private AiAssistance mapRecord(ResultSet rs) throws SQLException {
        AiAssistance record = new AiAssistance();
        record.setAiId(rs.getString("aiId"));
        record.setAiQuestion(rs.getString("aiQuestion"));
        record.setAiResponse(rs.getString("aiResponse"));
        record.setStudentId(rs.getString("studentId"));
        record.setTeacherId(rs.getString("teacherId"));
        return record;
    }

    public boolean save(String studentId, String question, String response) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return false;

            String aiId = generateNextId(conn);
            String sql = "INSERT INTO aiassistance (aiId, aiQuestion, aiResponse, studentId, teacherId) " +
                         "VALUES (?, ?, ?, ?, NULL)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, aiId);
            pstmt.setString(2, question);
            pstmt.setString(3, response);
            pstmt.setString(4, studentId);

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("AiAssistanceDAO.save error: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeQuietly(null, pstmt, conn);
        }
    }

    private String generateNextId(Connection conn) throws SQLException {
        String sql = "SELECT aiId FROM aiassistance ORDER BY aiId DESC LIMIT 1";
        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            int next = 1;
            if (rs.next()) {
                String lastId = rs.getString("aiId");
                if (lastId != null && lastId.startsWith("AI")) {
                    try {
                        next = Integer.parseInt(lastId.substring(2)) + 1;
                    } catch (NumberFormatException ignored) {
                        next = 1;
                    }
                }
            }
            return String.format("AI%02d", next);
        }
    }

    public Map<String, Object> getAdminStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("total", 0);
        stats.put("studentCount", 0);
        stats.put("teacherCount", 0);
        stats.put("mostActiveRole", "—");

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return stats;

            pstmt = conn.prepareStatement("SELECT COUNT(*) AS total FROM aiassistance");
            rs = pstmt.executeQuery();
            if (rs.next()) stats.put("total", rs.getInt("total"));
            closeQuietly(rs, pstmt, null);

            pstmt = conn.prepareStatement(
                    "SELECT COUNT(*) AS cnt FROM aiassistance WHERE teacherId IS NULL");
            rs = pstmt.executeQuery();
            if (rs.next()) stats.put("studentCount", rs.getInt("cnt"));
            closeQuietly(rs, pstmt, null);

            pstmt = conn.prepareStatement(
                    "SELECT COUNT(*) AS cnt FROM aiassistance WHERE teacherId IS NOT NULL");
            rs = pstmt.executeQuery();
            if (rs.next()) stats.put("teacherCount", rs.getInt("cnt"));
            closeQuietly(rs, pstmt, null);

            int studentCount = (Integer) stats.get("studentCount");
            int teacherCount = (Integer) stats.get("teacherCount");
            if (studentCount > teacherCount) {
                stats.put("mostActiveRole", "Student");
            } else if (teacherCount > studentCount) {
                stats.put("mostActiveRole", "Teacher");
            } else if (studentCount > 0) {
                stats.put("mostActiveRole", "Student");
            }
        } catch (SQLException e) {
            System.err.println("AiAssistanceDAO.getAdminStats error: " + e.getMessage());
        } finally {
            closeQuietly(rs, pstmt, conn);
        }

        return stats;
    }

    public List<AiInteraction> getAllInteractionsForAdmin() {
        List<AiInteraction> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return list;

            String sql = buildAdminSelectSql(conn);
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                AiInteraction row = new AiInteraction();
                row.setAiId(rs.getString("aiId"));
                row.setQuestion(rs.getString("aiQuestion"));
                row.setResponse(rs.getString("aiResponse"));

                String teacherId = rs.getString("teacherId");
                boolean isTeacher = teacherId != null && !teacherId.trim().isEmpty();
                row.setUserRole(isTeacher ? "Teacher" : "Student");

                String name = isTeacher ? rs.getString("teacherName") : rs.getString("studentName");
                if (name == null || name.trim().isEmpty()) {
                    name = isTeacher ? teacherId : rs.getString("studentId");
                }
                row.setUserName(name);
                row.setCategory(inferCategory(row.getQuestion()));
                row.setDateTime(readDateTime(rs));
                list.add(row);
            }
        } catch (SQLException e) {
            System.err.println("AiAssistanceDAO.getAllInteractionsForAdmin error: " + e.getMessage());
        } finally {
            closeQuietly(rs, pstmt, conn);
        }

        return list;
    }

    private String buildAdminSelectSql(Connection conn) throws SQLException {
        boolean hasCreatedAt = hasColumn(conn, "aiassistance", "createdAt");
        String dateExpr = hasCreatedAt
                ? "DATE_FORMAT(a.createdAt, '%b %d, %Y %h:%i %p')"
                : "'—'";
        return "SELECT a.aiId, a.aiQuestion, a.aiResponse, a.studentId, a.teacherId, " +
               "s.studentName, t.teacherName, " + dateExpr + " AS formattedDate " +
               (hasCreatedAt ? ", a.createdAt " : "") +
               "FROM aiassistance a " +
               "LEFT JOIN student s ON a.studentId = s.studentId " +
               "LEFT JOIN teacher t ON a.teacherId = t.teacherId " +
               "ORDER BY a.aiId DESC";
    }

    private String readDateTime(ResultSet rs) throws SQLException {
        try {
            String formatted = rs.getString("formattedDate");
            if (formatted != null && !formatted.equals("—")) return formatted;
        } catch (SQLException ignored) {}
        return "—";
    }

    private boolean hasColumn(Connection conn, String table, String column) {
        try (ResultSet cols = conn.getMetaData().getColumns(null, null, table, column)) {
            return cols.next();
        } catch (SQLException e) {
            return false;
        }
    }

    public static String inferCategory(String question) {
        if (question == null) return "General";
        String q = question.toLowerCase();
        if (containsAny(q, "tajweed", "hukum", "madd", "noon", "meem", "qalqalah", "ghunnah", "izhar", "idgham")) {
            return "Tajweed Rules";
        }
        if (containsAny(q, "pronounc", "makhraj", "letter", "ض", "dad", "articulation")) {
            return "Pronunciation";
        }
        if (containsAny(q, "memoriz", "hifz", "hafiz", "surah")) {
            return "Memorization";
        }
        if (containsAny(q, "teach", "lesson", "classroom", "student")) {
            return "Teaching Tips";
        }
        return "General";
    }

    private static boolean containsAny(String text, String... keywords) {
        for (String kw : keywords) {
            if (text.contains(kw)) return true;
        }
        return false;
    }

    private void closeQuietly(ResultSet rs, PreparedStatement pstmt, Connection conn) {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
