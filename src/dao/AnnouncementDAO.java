package dao;

import model.Announcement;
import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AnnouncementDAO {

    private static final String SELECT_COLUMNS =
        "announcementId, title, description, category, author, targetAudience, " +
        "teacherId, studentId, status, createdAt, " +
        "DATE_FORMAT(createdAt, '%b %d, %Y') AS formattedDate";

    private static final String BASE_FROM = " FROM announcement ";

    public List<Announcement> getLatestAnnouncements(int limit) {
        return queryAnnouncements(
            "SELECT " + SELECT_COLUMNS + BASE_FROM +
            "WHERE status = 'published' ORDER BY createdAt DESC LIMIT ?", limit);
    }

    public int getAnnouncementCount() {
        int count = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return 0;

            pstmt = conn.prepareStatement(
                "SELECT COUNT(*) AS total FROM announcement WHERE status = 'published'");
            rs = pstmt.executeQuery();
            if (rs.next()) {
                count = rs.getInt("total");
            }
        } catch (SQLException e) {
            System.err.println("Error counting announcements: " + e.getMessage());
        } finally {
            closeQuietly(rs, pstmt, conn);
        }

        return count;
    }

    public List<Announcement> getRecentAnnouncements(int limit) {
        return queryAnnouncements(
            "SELECT " + SELECT_COLUMNS + BASE_FROM +
            "WHERE status = 'published' ORDER BY createdAt DESC LIMIT ?", limit);
    }

    public List<Announcement> getTeacherAnnouncements(String teacherId, String teacherName) {
        List<Announcement> announcements = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return announcements;

            String sql = "SELECT " + SELECT_COLUMNS + BASE_FROM +
                         "WHERE status = 'published' AND (teacherId = ? OR author = ? OR author = 'Talaqqi Admin') " +
                         "ORDER BY createdAt DESC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, teacherId);
            pstmt.setString(2, teacherName);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                announcements.add(mapAnnouncement(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error getting teacher announcements: " + e.getMessage());
        } finally {
            closeQuietly(rs, pstmt, conn);
        }

        return announcements;
    }

    public List<Announcement> getStudentAnnouncements(String studentId, String studentName) {
        List<Announcement> announcements = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return announcements;

            String sql = "SELECT " + SELECT_COLUMNS + BASE_FROM +
                         "WHERE status = 'published' AND (" +
                         "  author IN ('Talaqqi Admin', 'TalaqqiHub Admin') " +
                         "  OR targetAudience = 'All Students & Teachers' " +
                         "  OR studentId = ? " +
                         "  OR targetAudience = ? " +
                         "  OR (targetAudience = 'All My Students' AND teacherId IN (" +
                         "    SELECT DISTINCT cs.teacherId FROM classbooking cb " +
                         "    INNER JOIN classschedule cs ON cb.scheduleId = cs.scheduleId " +
                         "    WHERE cb.studentId = ? AND cb.bookingStatus NOT IN ('Cancelled', 'Rejected')" +
                         "  ))" +
                         ") ORDER BY createdAt DESC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, studentId);
            pstmt.setString(2, "Student: " + studentName);
            pstmt.setString(3, studentId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                announcements.add(mapAnnouncement(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error getting student announcements: " + e.getMessage());
        } finally {
            closeQuietly(rs, pstmt, conn);
        }

        return announcements;
    }

    public List<Announcement> getAllAnnouncements() {
        return queryAnnouncements(
            "SELECT " + SELECT_COLUMNS + BASE_FROM +
            "WHERE status = 'published' ORDER BY createdAt DESC");
    }

    public Announcement getById(String announcementId) {
        List<Announcement> results = queryAnnouncements(
            "SELECT " + SELECT_COLUMNS + BASE_FROM + "WHERE announcementId = ? LIMIT 1", announcementId);
        return results.isEmpty() ? null : results.get(0);
    }

    public String createAdminAnnouncement(Announcement announcement) {
        String newId = getNextAnnouncementId();
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return null;

            String sql = "INSERT INTO announcement " +
                         "(announcementId, title, description, category, author, targetAudience, teacherId, studentId, status) " +
                         "VALUES (?, ?, ?, ?, ?, ?, NULL, NULL, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, newId);
            pstmt.setString(2, announcement.getTitle());
            pstmt.setString(3, announcement.getDescription());
            pstmt.setString(4, nullToDefault(announcement.getCategory(), "General"));
            pstmt.setString(5, nullToDefault(announcement.getAuthor(), "Talaqqi Admin"));
            pstmt.setString(6, announcement.getTargetAudience());
            pstmt.setString(7, nullToDefault(announcement.getStatus(), "published"));

            if (pstmt.executeUpdate() > 0) {
                announcement.setAnnouncementId(newId);
                NotificationDAO notifDao = new NotificationDAO();
                notifDao.notifyStudentsForAnnouncement(announcement, null);
                notifDao.notifyTeachersForAnnouncement(announcement, null);
                return newId;
            }
        } catch (SQLException e) {
            System.err.println("Error creating admin announcement: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeQuietly(null, pstmt, conn);
        }

        return null;
    }

    public boolean updateAnnouncementByAdmin(Announcement announcement) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return false;

            String sql = "UPDATE announcement SET title = ?, description = ?, category = ?, " +
                         "targetAudience = ?, updatedAt = CURRENT_TIMESTAMP " +
                         "WHERE announcementId = ? AND teacherId IS NULL";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, announcement.getTitle());
            pstmt.setString(2, announcement.getDescription());
            pstmt.setString(3, nullToDefault(announcement.getCategory(), "General"));
            pstmt.setString(4, announcement.getTargetAudience());
            pstmt.setString(5, announcement.getAnnouncementId());

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error updating announcement by admin: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeQuietly(null, pstmt, conn);
        }

        return false;
    }

    public boolean deleteAnnouncementByAdmin(String announcementId) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return false;

            pstmt = conn.prepareStatement("DELETE FROM announcement WHERE announcementId = ? AND teacherId IS NULL");
            pstmt.setString(1, announcementId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error deleting announcement by admin: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeQuietly(null, pstmt, conn);
        }

        return false;
    }

    public String createAnnouncement(Announcement announcement, String teacherId) {
        String newId = getNextAnnouncementId();
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return null;

            String sql = "INSERT INTO announcement " +
                         "(announcementId, title, description, category, author, targetAudience, teacherId, studentId, status) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, newId);
            pstmt.setString(2, announcement.getTitle());
            pstmt.setString(3, announcement.getDescription());
            pstmt.setString(4, nullToDefault(announcement.getCategory(), "General"));
            pstmt.setString(5, announcement.getAuthor());
            pstmt.setString(6, announcement.getTargetAudience());
            pstmt.setString(7, teacherId);
            pstmt.setString(8, resolveStudentId(announcement.getTargetAudience()));
            pstmt.setString(9, nullToDefault(announcement.getStatus(), "published"));

            if (pstmt.executeUpdate() > 0) {
                announcement.setAnnouncementId(newId);
                new NotificationDAO().notifyStudentsForAnnouncement(announcement, teacherId);
                return newId;
            }
        } catch (SQLException e) {
            System.err.println("Error creating announcement: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeQuietly(null, pstmt, conn);
        }

        return null;
    }

    public boolean updateAnnouncement(Announcement announcement, String teacherId) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return false;

            String sql = "UPDATE announcement SET title = ?, description = ?, category = ?, " +
                         "targetAudience = ?, studentId = ?, updatedAt = CURRENT_TIMESTAMP " +
                         "WHERE announcementId = ? AND teacherId = ? AND author <> 'Talaqqi Admin'";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, announcement.getTitle());
            pstmt.setString(2, announcement.getDescription());
            pstmt.setString(3, nullToDefault(announcement.getCategory(), "General"));
            pstmt.setString(4, announcement.getTargetAudience());
            pstmt.setString(5, resolveStudentId(announcement.getTargetAudience()));
            pstmt.setString(6, announcement.getAnnouncementId());
            pstmt.setString(7, teacherId);

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error updating announcement: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeQuietly(null, pstmt, conn);
        }

        return false;
    }

    public boolean deleteAnnouncement(String announcementId, String teacherId) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return false;

            String sql = "DELETE FROM announcement " +
                         "WHERE announcementId = ? AND teacherId = ? AND author <> 'Talaqqi Admin'";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, announcementId);
            pstmt.setString(2, teacherId);

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error deleting announcement: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeQuietly(null, pstmt, conn);
        }

        return false;
    }

    private List<Announcement> queryAnnouncements(String sql, Object... params) {
        List<Announcement> announcements = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return announcements;

            pstmt = conn.prepareStatement(sql);
            for (int i = 0; i < params.length; i++) {
                Object param = params[i];
                if (param instanceof Integer) {
                    pstmt.setInt(i + 1, (Integer) param);
                } else {
                    pstmt.setString(i + 1, String.valueOf(param));
                }
            }

            rs = pstmt.executeQuery();
            while (rs.next()) {
                announcements.add(mapAnnouncement(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error querying announcements: " + e.getMessage());
        } finally {
            closeQuietly(rs, pstmt, conn);
        }

        return announcements;
    }

    private Announcement mapAnnouncement(ResultSet rs) throws SQLException {
        Announcement announcement = new Announcement();
        announcement.setAnnouncementId(rs.getString("announcementId"));
        announcement.setTitle(rs.getString("title"));
        announcement.setDescription(rs.getString("description"));
        announcement.setCategory(rs.getString("category"));
        announcement.setStatus(rs.getString("status"));
        announcement.setAuthor(rs.getString("author"));
        announcement.setTargetAudience(rs.getString("targetAudience"));
        announcement.setTeacherId(rs.getString("teacherId"));
        announcement.setDate(rs.getString("formattedDate"));
        java.sql.Timestamp createdAt = rs.getTimestamp("createdAt");
        if (createdAt != null) {
            long diffDays = (System.currentTimeMillis() - createdAt.getTime()) / (1000L * 60 * 60 * 24);
            announcement.setRecent(diffDays <= 7);
        }
        return announcement;
    }

    private String getNextAnnouncementId() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return "ANN001";

            pstmt = conn.prepareStatement(
                "SELECT announcementId FROM announcement WHERE announcementId LIKE 'ANN%' " +
                "ORDER BY CAST(SUBSTRING(announcementId, 4) AS UNSIGNED) DESC LIMIT 1");
            rs = pstmt.executeQuery();

            int next = 1;
            if (rs.next()) {
                String lastId = rs.getString("announcementId");
                if (lastId != null && lastId.startsWith("ANN")) {
                    next = Integer.parseInt(lastId.substring(3)) + 1;
                }
            }
            return String.format("ANN%03d", next);
        } catch (SQLException | NumberFormatException e) {
            return "ANN001";
        } finally {
            closeQuietly(rs, pstmt, conn);
        }
    }

    private String resolveStudentId(String targetAudience) {
        if (targetAudience == null || !targetAudience.startsWith("Student: ")) {
            return null;
        }

        String studentName = targetAudience.substring("Student: ".length()).trim();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return null;

            pstmt = conn.prepareStatement(
                "SELECT studentId FROM student WHERE studentName = ? LIMIT 1");
            pstmt.setString(1, studentName);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getString("studentId");
            }
        } catch (SQLException e) {
            System.err.println("Error resolving studentId: " + e.getMessage());
        } finally {
            closeQuietly(rs, pstmt, conn);
        }

        return null;
    }

    private String nullToDefault(String value, String defaultValue) {
        return (value == null || value.trim().isEmpty()) ? defaultValue : value.trim();
    }

    private void closeQuietly(ResultSet rs, PreparedStatement pstmt, Connection conn) {
        try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
        try { if (pstmt != null) pstmt.close(); } catch (SQLException ignored) {}
        try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
    }
}
