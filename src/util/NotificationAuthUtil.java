package util;

import javax.servlet.http.HttpSession;

/**
 * Notifications are scoped by explicit ?role=teacher|student (each tab sends its own role).
 */
public final class NotificationAuthUtil {

    private NotificationAuthUtil() {}

    public static class NotificationUser {
        public final String userId;
        public final String userType;

        public NotificationUser(String userId, String userType) {
            this.userId = userId;
            this.userType = userType;
        }
    }

    public static NotificationUser resolve(HttpSession session, String role) {
        if (session == null || role == null || role.trim().isEmpty()) {
            return null;
        }
        if ("teacher".equalsIgnoreCase(role)) {
            String teacherId = SessionRoleUtil.getTeacherId(session);
            if (teacherId == null) return null;
            return new NotificationUser(teacherId, "teacher");
        }
        if ("student".equalsIgnoreCase(role)) {
            String studentId = SessionRoleUtil.getStudentId(session);
            if (studentId == null) return null;
            return new NotificationUser(studentId, "student");
        }
        return null;
    }
}
