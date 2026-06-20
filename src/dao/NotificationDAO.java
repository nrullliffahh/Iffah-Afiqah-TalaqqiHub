package dao;

import model.Announcement;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public class NotificationDAO {

    public static final int RETENTION_DAYS = 5;

    public static final String TITLE_ANNOUNCEMENT = "New Announcement Posted";
    public static final String TITLE_UPCOMING_CLASS = "Upcoming Class Reminder";
    public static final String TITLE_CLASS_CANCELLED = "Class Cancelled";
    public static final String TITLE_NEW_BOOKING = "New Booking Received";
    public static final String TITLE_EVALUATION_RECEIVED = "New Evaluation Received";
    public static final String TITLE_EVALUATION_SUBMITTED = "Evaluation Submitted";
    public static final String TITLE_STUDENT_EVALUATION = "Student Evaluation Submitted";
    public static final String TITLE_LOW_ATTENDANCE = "Low Attendance Warning";

    public boolean createNotification(String userId, String userType, String title, String message,
                                      String bookingId, String scheduleId) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return false;
            return createNotification(conn, userId, userType, title, message, bookingId, scheduleId);
        } catch (SQLException e) {
            System.err.println("NotificationDAO.createNotification error: " + e.getMessage());
            return false;
        } finally {
            closeQuietly(null, null, conn);
        }
    }

    public boolean createNotification(Connection conn, String userId, String userType, String title,
                                      String message, String bookingId, String scheduleId) throws SQLException {
        if (userId == null || userId.trim().isEmpty()) return false;

        String sql = "INSERT INTO notifications (id, userId, userType, title, message, bookingId, relatedScheduleId, isRead, createdAt) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, 0, NOW())";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, UUID.randomUUID().toString());
            ps.setString(2, userId);
            ps.setString(3, userType);
            ps.setString(4, title);
            ps.setString(5, message);
            ps.setString(6, bookingId);
            ps.setString(7, scheduleId);
            return ps.executeUpdate() > 0;
        } catch (SQLException primary) {
            String fallbackSql = "INSERT INTO notifications (userId, userType, title, message, bookingId, relatedScheduleId, isRead, createdAt) " +
                                 "VALUES (?, ?, ?, ?, ?, ?, 0, NOW())";
            try (PreparedStatement ps = conn.prepareStatement(fallbackSql)) {
                ps.setString(1, userId);
                ps.setString(2, userType);
                ps.setString(3, title);
                ps.setString(4, message);
                ps.setString(5, bookingId);
                ps.setString(6, scheduleId);
                return ps.executeUpdate() > 0;
            }
        }
    }

    public int deleteExpiredNotifications() {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return 0;

            ps = conn.prepareStatement(
                "DELETE FROM notifications WHERE createdAt < DATE_SUB(NOW(), INTERVAL ? DAY)");
            ps.setInt(1, RETENTION_DAYS);
            return ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("NotificationDAO.deleteExpiredNotifications error: " + e.getMessage());
        } finally {
            closeQuietly(null, ps, conn);
        }
        return 0;
    }

    public int getUnreadCount(String userId, String userType) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return 0;

            ps = conn.prepareStatement(
                "SELECT COUNT(*) AS cnt FROM notifications " +
                "WHERE userId = ? AND userType = ? AND (isRead = 0 OR isRead IS NULL) " +
                "AND createdAt >= DATE_SUB(NOW(), INTERVAL ? DAY)");
            ps.setString(1, userId);
            ps.setString(2, userType);
            ps.setInt(3, RETENTION_DAYS);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("cnt");
        } catch (SQLException e) {
            System.err.println("NotificationDAO.getUnreadCount error: " + e.getMessage());
        } finally {
            closeQuietly(rs, ps, conn);
        }
        return 0;
    }

    public List<Map<String, Object>> getNotifications(String userId, String userType, int limit) {
        List<Map<String, Object>> items = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return items;

            ps = conn.prepareStatement(
                "SELECT id, title, message, bookingId, relatedScheduleId, isRead, createdAt " +
                "FROM notifications WHERE userType = ? AND userId = ? " +
                "AND createdAt >= DATE_SUB(NOW(), INTERVAL ? DAY) " +
                "ORDER BY createdAt DESC LIMIT ?");
            ps.setString(1, userType);
            ps.setString(2, userId);
            ps.setInt(3, RETENTION_DAYS);
            ps.setInt(4, limit);
            rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("id", rs.getString("id"));
                m.put("title", rs.getString("title"));
                m.put("message", rs.getString("message"));
                m.put("bookingId", rs.getString("bookingId"));
                m.put("scheduleId", rs.getString("relatedScheduleId"));
                m.put("isRead", String.valueOf(rs.getInt("isRead")));
                Timestamp ts = rs.getTimestamp("createdAt");
                m.put("time", ts != null ? ts.toString() : "");
                m.put("timeAgo", formatTimeAgo(ts));
                m.put("type", resolveType(rs.getString("title")));
                items.add(m);
            }
        } catch (SQLException e) {
            System.err.println("NotificationDAO.getNotifications error: " + e.getMessage());
        } finally {
            closeQuietly(rs, ps, conn);
        }
        return items;
    }

    public void syncStudentNotifications(String studentId) {
        if (studentId == null || studentId.trim().isEmpty()) return;
        syncUpcomingClassReminders(studentId);
        syncLowAttendanceWarning(studentId);
    }

    public void syncTeacherNotifications(String teacherId) {
        if (teacherId == null || teacherId.trim().isEmpty()) return;
        syncUpcomingClassRemindersForTeacher(teacherId);
    }

    public void syncUpcomingClassReminders(String studentId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return;

            String sql =
                "SELECT cb.bookingId, cb.scheduleId, cs.className, cs.startTime, cb.bookingDate " +
                "FROM classbooking cb " +
                "INNER JOIN classschedule cs ON cb.scheduleId = cs.scheduleId " +
                "WHERE cb.studentId = ? " +
                "AND (cb.bookingStatus IS NULL OR cb.bookingStatus NOT IN ('Cancelled', 'Rejected', 'Completed')) " +
                "AND cb.bookingDate >= CURDATE() " +
                "AND TIMESTAMP(cb.bookingDate, cs.startTime) BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 24 HOUR) " +
                "ORDER BY cb.bookingDate ASC, cs.startTime ASC";

            ps = conn.prepareStatement(sql);
            ps.setString(1, studentId);
            rs = ps.executeQuery();

            while (rs.next()) {
                String bookingId = rs.getString("bookingId");
                String scheduleId = rs.getString("scheduleId");
                String className = rs.getString("className");
                String startTime = rs.getString("startTime");

                if (hasRecentNotification(conn, studentId, "student", TITLE_UPCOMING_CLASS, scheduleId, 24)) {
                    continue;
                }

                String msg = "Your " + (className != null ? className : "talaqqi session") +
                             " starts soon at " + (startTime != null ? startTime : "the scheduled time");
                createNotification(conn, studentId, "student", TITLE_UPCOMING_CLASS, msg, bookingId, scheduleId);
            }
        } catch (SQLException e) {
            System.err.println("NotificationDAO.syncUpcomingClassReminders error: " + e.getMessage());
        } finally {
            closeQuietly(rs, ps, conn);
        }
    }

    public void syncLowAttendanceWarning(String studentId) {
        try {
            AttendanceDAO attendanceDAO = new AttendanceDAO();
            double rate = attendanceDAO.getAttendanceRate(studentId);
            if (rate >= 50.0) return;

            Connection conn = DBConnection.getConnection();
            if (conn == null) return;

            try {
                if (hasRecentNotification(conn, studentId, "student", TITLE_LOW_ATTENDANCE, "attendance", 720)) {
                    return;
                }

                String msg = String.format(
                    "Your attendance rate is %.0f%%. Please attend more sessions to stay on track.", rate);
                createNotification(conn, studentId, "student", TITLE_LOW_ATTENDANCE, msg, null, "attendance");
            } finally {
                closeQuietly(null, null, conn);
            }
        } catch (Exception e) {
            System.err.println("NotificationDAO.syncLowAttendanceWarning error: " + e.getMessage());
        }
    }

    public void notifyStudentsForAnnouncement(Announcement announcement, String teacherId) {
        if (announcement == null || announcement.getTitle() == null) return;

        List<String> studentIds = resolveTargetStudentIds(
            announcement.getTargetAudience(),
            null,
            teacherId
        );

        String author = announcement.getAuthor() != null ? announcement.getAuthor() : "Admin Team";
        String msg = author + " posted: " + announcement.getTitle();
        String relatedId = announcement.getAnnouncementId();

        for (String studentId : studentIds) {
            createNotification(studentId, "student", TITLE_ANNOUNCEMENT, msg, relatedId, null);
        }
    }

    public void notifyTeachersForAnnouncement(Announcement announcement, String creatingTeacherId) {
        if (announcement == null || announcement.getTitle() == null) return;

        String author = announcement.getAuthor() != null ? announcement.getAuthor() : "Admin Team";
        boolean isAdminAuthor = author.contains("Admin") || author.contains("TalaqqiHub");
        if (!isAdminAuthor) return;

        List<String> teacherIds = resolveTargetTeacherIds(announcement.getTargetAudience());
        String msg = author + " posted: " + announcement.getTitle();
        String relatedId = announcement.getAnnouncementId();

        for (String teacherId : teacherIds) {
            if (creatingTeacherId != null && creatingTeacherId.equals(teacherId)) continue;
            createNotification(teacherId, "teacher", TITLE_ANNOUNCEMENT, msg, relatedId, null);
        }
    }

    public void notifyTeacherOfNewBooking(String bookingId, String scheduleId, String studentId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return;

            String teacherId = null;
            String studentName = lookupStudentName(studentId);
            String className = null;
            String startTime = null;
            String bookingDate = null;

            if (bookingId != null && !bookingId.trim().isEmpty()) {
                String sql =
                    "SELECT cs.teacherId, cs.className, cs.startTime, cb.bookingDate, s.studentName " +
                    "FROM classschedule cs " +
                    "INNER JOIN classbooking cb ON cb.scheduleId = cs.scheduleId " +
                    "LEFT JOIN student s ON s.studentId = cb.studentId " +
                    "WHERE cb.bookingId = ? LIMIT 1";
                ps = conn.prepareStatement(sql);
                ps.setString(1, bookingId);
                rs = ps.executeQuery();
                if (rs.next()) {
                    teacherId = rs.getString("teacherId");
                    if (studentName == null) studentName = rs.getString("studentName");
                    className = rs.getString("className");
                    startTime = rs.getString("startTime");
                    bookingDate = rs.getString("bookingDate");
                }
                closeQuietly(rs, ps, null);
                rs = null;
                ps = null;
            }

            if ((teacherId == null || teacherId.trim().isEmpty()) && scheduleId != null && !scheduleId.trim().isEmpty()) {
                String fallbackSql =
                    "SELECT teacherId, className, startTime, scheduleDate FROM classschedule WHERE scheduleId = ? LIMIT 1";
                ps = conn.prepareStatement(fallbackSql);
                ps.setString(1, scheduleId);
                rs = ps.executeQuery();
                if (rs.next()) {
                    teacherId = rs.getString("teacherId");
                    if (className == null) className = rs.getString("className");
                    if (startTime == null) startTime = rs.getString("startTime");
                    if (bookingDate == null) bookingDate = rs.getString("scheduleDate");
                }
            }

            if (teacherId == null || teacherId.trim().isEmpty()) {
                System.err.println("NotificationDAO.notifyTeacherOfNewBooking: teacherId not found for booking="
                    + bookingId + " schedule=" + scheduleId);
                return;
            }

            String msg = (studentName != null ? studentName : "A student") +
                         " booked " + (className != null ? className : "your class") +
                         " on " + (bookingDate != null ? bookingDate : "") +
                         (startTime != null ? " at " + startTime : "");

            boolean created = createNotification(conn, teacherId, "teacher", TITLE_NEW_BOOKING, msg.trim(),
                bookingId, scheduleId);
            System.out.println("NotificationDAO.notifyTeacherOfNewBooking: teacher=" + teacherId
                + " booking=" + bookingId + " created=" + created);
        } catch (SQLException e) {
            System.err.println("NotificationDAO.notifyTeacherOfNewBooking error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeQuietly(rs, ps, conn);
        }
    }

    public void notifyTeacherOfStudentEvaluation(String teacherId, String studentId, String sessionId) {
        if (teacherId == null || teacherId.trim().isEmpty()) return;

        String studentName = lookupStudentName(studentId);
        String msg = (studentName != null ? studentName : "A student") + " submitted an evaluation for your session";
        createNotification(teacherId, "teacher", TITLE_STUDENT_EVALUATION, msg, sessionId, null);
    }

    public void syncUpcomingClassRemindersForTeacher(String teacherId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return;

            String sql =
                "SELECT cb.bookingId, cb.scheduleId, cs.className, cs.startTime, cb.bookingDate, s.studentName " +
                "FROM classbooking cb " +
                "INNER JOIN classschedule cs ON cb.scheduleId = cs.scheduleId " +
                "LEFT JOIN student s ON s.studentId = cb.studentId " +
                "WHERE cs.teacherId = ? " +
                "AND (cb.bookingStatus IS NULL OR cb.bookingStatus NOT IN ('Cancelled', 'Rejected', 'Completed')) " +
                "AND cb.bookingDate >= CURDATE() " +
                "AND TIMESTAMP(cb.bookingDate, cs.startTime) BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 24 HOUR) " +
                "ORDER BY cb.bookingDate ASC, cs.startTime ASC";

            ps = conn.prepareStatement(sql);
            ps.setString(1, teacherId);
            rs = ps.executeQuery();

            while (rs.next()) {
                String bookingId = rs.getString("bookingId");
                String scheduleId = rs.getString("scheduleId");
                String className = rs.getString("className");
                String startTime = rs.getString("startTime");
                String studentName = rs.getString("studentName");

                if (hasRecentNotification(conn, teacherId, "teacher", TITLE_UPCOMING_CLASS, scheduleId, 24)) {
                    continue;
                }

                String msg = "Your " + (className != null ? className : "class") +
                             " with " + (studentName != null ? studentName : "a student") +
                             " starts soon at " + (startTime != null ? startTime : "the scheduled time");
                createNotification(conn, teacherId, "teacher", TITLE_UPCOMING_CLASS, msg, bookingId, scheduleId);
            }
        } catch (SQLException e) {
            System.err.println("NotificationDAO.syncUpcomingClassRemindersForTeacher error: " + e.getMessage());
        } finally {
            closeQuietly(rs, ps, conn);
        }
    }

    private List<String> resolveTargetTeacherIds(String targetAudience) {
        List<String> ids = new ArrayList<>();
        if (targetAudience == null) targetAudience = "";

        if ("All Students".equals(targetAudience)) {
            return ids;
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return ids;

            ps = conn.prepareStatement(
                "SELECT teacherId FROM teacher WHERE teacherStatus = 'Active' OR teacherStatus IS NULL");
            rs = ps.executeQuery();
            while (rs.next()) ids.add(rs.getString("teacherId"));
        } catch (SQLException e) {
            System.err.println("NotificationDAO.resolveTargetTeacherIds error: " + e.getMessage());
        } finally {
            closeQuietly(rs, ps, conn);
        }
        return ids;
    }

    private String lookupStudentName(String studentId) {
        if (studentId == null || studentId.trim().isEmpty()) return null;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return null;
            ps = conn.prepareStatement("SELECT studentName FROM student WHERE studentId = ? LIMIT 1");
            ps.setString(1, studentId);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getString("studentName");
        } catch (SQLException e) {
            System.err.println("NotificationDAO.lookupStudentName error: " + e.getMessage());
        } finally {
            closeQuietly(rs, ps, conn);
        }
        return null;
    }

    private List<String> resolveTargetStudentIds(String targetAudience, String specificStudentId, String teacherId) {
        List<String> ids = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) return ids;

            if (specificStudentId != null && !specificStudentId.trim().isEmpty()) {
                ids.add(specificStudentId.trim());
                return ids;
            }

            if (targetAudience == null) targetAudience = "";

            if (targetAudience.contains("All Students") || targetAudience.contains("All Students & Teachers")) {
                ps = conn.prepareStatement(
                    "SELECT studentId FROM student WHERE studentStatus = 'Active' OR studentStatus IS NULL");
                rs = ps.executeQuery();
                while (rs.next()) ids.add(rs.getString("studentId"));
                closeQuietly(rs, ps, null);
                rs = null;
                ps = null;
                return ids;
            }

            if (targetAudience.startsWith("Student:")) {
                String studentName = targetAudience.replaceFirst("^Student:\\s*", "").trim();
                ps = conn.prepareStatement("SELECT studentId FROM student WHERE studentName = ? LIMIT 1");
                ps.setString(1, studentName);
                rs = ps.executeQuery();
                if (rs.next()) ids.add(rs.getString("studentId"));
                return ids;
            }

            if ("All My Students".equals(targetAudience) && teacherId != null && !teacherId.trim().isEmpty()) {
                ps = conn.prepareStatement(
                    "SELECT DISTINCT cb.studentId FROM classbooking cb " +
                    "INNER JOIN classschedule cs ON cb.scheduleId = cs.scheduleId " +
                    "WHERE cs.teacherId = ? AND cb.bookingStatus NOT IN ('Cancelled', 'Rejected')");
                ps.setString(1, teacherId);
                rs = ps.executeQuery();
                while (rs.next()) ids.add(rs.getString("studentId"));
            }
        } catch (SQLException e) {
            System.err.println("NotificationDAO.resolveTargetStudentIds error: " + e.getMessage());
        } finally {
            closeQuietly(rs, ps, conn);
        }

        return ids;
    }

    private boolean hasRecentNotification(Connection conn, String userId, String userType,
                                          String title, String relatedScheduleId, int hours) throws SQLException {
        String sql =
            "SELECT COUNT(*) AS cnt FROM notifications " +
            "WHERE userId = ? AND userType = ? AND title = ? " +
            "AND (relatedScheduleId = ? OR relatedScheduleId IS NULL AND ? IS NULL) " +
            "AND createdAt >= DATE_SUB(NOW(), INTERVAL ? HOUR)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, userType);
            ps.setString(3, title);
            ps.setString(4, relatedScheduleId);
            ps.setString(5, relatedScheduleId);
            ps.setInt(6, hours);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt("cnt") > 0;
            }
        }
    }

    public static String resolveType(String title) {
        if (title == null) return "general";
        if (title.contains("Announcement")) return "announcement";
        if (title.contains("Upcoming") || title.contains("Reminder")) return "upcoming";
        if (title.contains("Booking")) return "booking";
        if (title.contains("Cancelled") || title.contains("Canceled")) return "cancelled";
        if (title.contains("Evaluation")) return "evaluation";
        if (title.contains("Attendance")) return "attendance";
        return "general";
    }

    public static String formatTimeAgo(Timestamp ts) {
        if (ts == null) return "";
        long diffMs = System.currentTimeMillis() - ts.getTime();
        long mins = diffMs / 60000;
        if (mins < 1) return "Just now";
        if (mins < 60) return mins + " min" + (mins == 1 ? "" : "s") + " ago";
        long hours = mins / 60;
        if (hours < 24) return hours + " hour" + (hours == 1 ? "" : "s") + " ago";
        long days = hours / 24;
        if (days < 7) return days + " day" + (days == 1 ? "" : "s") + " ago";
        long weeks = days / 7;
        return weeks + " week" + (weeks == 1 ? "" : "s") + " ago";
    }

    private void closeQuietly(ResultSet rs, PreparedStatement ps, Connection conn) {
        try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
        try { if (ps != null) ps.close(); } catch (SQLException ignored) {}
        try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
    }
}
