package util;

import javax.servlet.http.HttpSession;

/**
 * Supports teacher and student logged in at the same time (same browser, different tabs).
 * Each role keeps its own session attributes; logging into one does not clear the other.
 */
public final class SessionRoleUtil {

    private SessionRoleUtil() {}

    public static void clearStudent(HttpSession session) {
        if (session == null) return;
        session.removeAttribute("student");
        session.removeAttribute("studentId");
        session.removeAttribute("studentName");
    }

    public static void clearTeacher(HttpSession session) {
        if (session == null) return;
        session.removeAttribute("teacherId");
        session.removeAttribute("teacherName");
        session.removeAttribute("teacherEmail");
        session.removeAttribute("teacherApprovalStatus");
        session.removeAttribute("activeTalaqqiSessionId");
    }

    public static void clearAdmin(HttpSession session) {
        if (session == null) return;
        session.removeAttribute("adminId");
        session.removeAttribute("adminName");
        session.removeAttribute("adminEmail");
        session.removeAttribute("userType");
    }

    /** Log in teacher without touching student/admin data (safe for another Chrome tab). */
    public static void bindTeacher(HttpSession session, String teacherId, String teacherName, String teacherEmail) {
        if (session == null) return;
        session.setAttribute("teacherId", teacherId);
        session.setAttribute("teacherName", teacherName);
        session.setAttribute("teacherEmail", teacherEmail);
    }

    /** Log in student without touching teacher/admin data (safe for another Chrome tab). */
    public static void bindStudent(HttpSession session, Object student, String studentId, String studentName) {
        if (session == null) return;
        if (student != null) {
            session.setAttribute("student", student);
        }
        session.setAttribute("studentId", studentId);
        session.setAttribute("studentName", studentName);
    }

    public static void bindAdmin(HttpSession session, String adminId, String adminName, String adminEmail) {
        if (session == null) return;
        session.setAttribute("adminId", adminId);
        session.setAttribute("adminName", adminName);
        session.setAttribute("adminEmail", adminEmail);
        session.setAttribute("userType", "admin");
    }

    public static String getTeacherId(HttpSession session) {
        if (session == null) return null;
        Object v = session.getAttribute("teacherId");
        if (v == null) return null;
        String id = v.toString().trim();
        return id.isEmpty() ? null : id;
    }

    public static String getStudentId(HttpSession session) {
        if (session == null) return null;
        Object v = session.getAttribute("studentId");
        if (v == null) return null;
        String id = v.toString().trim();
        return id.isEmpty() ? null : id;
    }

    public static boolean hasAnyPortal(HttpSession session) {
        if (session == null) return false;
        Object adminId = session.getAttribute("adminId");
        return getTeacherId(session) != null
                || getStudentId(session) != null
                || (adminId != null && !adminId.toString().trim().isEmpty());
    }

    public static boolean isTeacherLoggedIn(HttpSession session) {
        return getTeacherId(session) != null;
    }

    public static boolean isStudentLoggedIn(HttpSession session) {
        return getStudentId(session) != null;
    }
}
