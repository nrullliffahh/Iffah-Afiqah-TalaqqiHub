package controller;

import dao.TalaqqiSessionDAO;
import dao.TeacherDAO;
import model.TalaqqiSession;
import model.Teacher;
import util.JaasJwtGenerator;
import util.JitsiConfig;
import util.SessionRoleUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Time;
import java.time.LocalTime;
import java.util.List;

/**
 * TeacherTalaqqiSessionServlet
 *
 * Handles all lifecycle events for a Talaqqi (live recitation) session.
 *
 * URL: /teacher/sessions
 *
 * ── GET Requests ─────────────────────────────────────────────────────────────
 *   /teacher/sessions              → Loads the next upcoming session for the teacher.
 *   /teacher/sessions?scheduleId=X → Loads the specific session for scheduleId X.
 *
 * ── POST Requests (action= parameter) ────────────────────────────────────────
 *   action=startSession   → Marks session as active in HTTP session. Returns JSON.
 *   action=endSession     → Completes session in DB, records attendance. Returns JSON.
 *   action=updateQuran    → Saves new surah/ayah to classschedule. Returns JSON.
 *   action=recordAttendance → Records the student's join/leave event. Returns JSON.
 *
 * MVC Role: Controller – routes requests, calls DAO, sets request attributes,
 * forwards to the JSP view or returns JSON for AJAX calls.
 */
public class TeacherTalaqqiSessionServlet extends HttpServlet {

    private TalaqqiSessionDAO talaqqiSessionDAO;
    private TeacherDAO         teacherDAO;

    private static final String VIEW_PATH   = "/WEB-INF/views/teacherTalaqqiSession.jsp";
    private static final String SESSION_KEY = "activeTalaqqiSessionId"; // HTTP session key

    @Override
    public void init() throws ServletException {
        talaqqiSessionDAO = new TalaqqiSessionDAO();
        teacherDAO        = new TeacherDAO();
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  GET – Load session view
    // ══════════════════════════════════════════════════════════════════════════

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession httpSession = request.getSession(false);
        if (!isAuthenticated(httpSession)) {
            response.sendRedirect(request.getContextPath() + "/teacher/login");
            return;
        }

        String teacherId = (String) httpSession.getAttribute("teacherId");

        // Resolve which session to display
        String sessionId = request.getParameter("sessionId");
        TalaqqiSession session = null;

        if (sessionId != null && !sessionId.trim().isEmpty()) {
            session = talaqqiSessionDAO.getSessionBySessionId(sessionId.trim(), teacherId);
        }

        // Fall back to the next upcoming session for this teacher
        if (session == null) {
            session = talaqqiSessionDAO.getUpcomingSessionForTeacher(teacherId);
        }

        // Get the list of upcoming sessions for the session-picker dropdown
        List<TalaqqiSession> upcomingSessions =
                talaqqiSessionDAO.getUpcomingSessionsList(teacherId, 10);

        // Restore teacher display name
        Teacher teacher = teacherDAO.getTeacherById(teacherId);
        String teacherName    = teacher != null ? teacher.getFullName() : "Teacher";
        String teacherInitials = resolveInitials(teacherName);

        // Determine whether this talaqqisession is currently active
        String activeTalaqqiSessionId = (String) httpSession.getAttribute(SESSION_KEY);
        boolean isSessionActive = session != null
                && session.getSessionId() != null
                && session.getSessionId().equals(activeTalaqqiSessionId);

        // Set request attributes for the JSP
        request.setAttribute("session",         session);          // current TalaqqiSession
        request.setAttribute("upcomingSessions", upcomingSessions); // list for picker
        request.setAttribute("teacherName",     teacherName);
        request.setAttribute("teacherInitials", teacherInitials);
        request.setAttribute("isSessionActive", isSessionActive);
        request.setAttribute("teacherId",       teacherId);
        request.setAttribute("teacherJitsiJwt",  resolveTeacherJwt(teacher, teacherId, teacherName, session));

        request.getRequestDispatcher(VIEW_PATH).forward(request, response);
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  POST – Session actions (AJAX / form posts)
    // ══════════════════════════════════════════════════════════════════════════

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession httpSession = request.getSession(false);
        if (!isAuthenticated(httpSession)) {
            String authError = (httpSession == null)
                    ? "Session expired. Please log in again."
                    : "Not logged in as teacher. Please log in again.";
            sendJson(response, SC_UNAUTHORIZED,
                    "{\"success\":false,\"error\":\"" + escapeJson(authError) + "\"}");
            return;
        }

        String teacherId = (String) httpSession.getAttribute("teacherId");
        String action    = request.getParameter("action");

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if (action == null) {
            sendJson(response, SC_BAD_REQUEST, "{\"success\":false,\"error\":\"Missing action parameter\"}");
            return;
        }

        switch (action) {

            // ── Start Session ─────────────────────────────────────────────────
            case "startSession": {
                String sessionId = request.getParameter("sessionId");
                if (sessionId != null) sessionId = sessionId.trim();
                if (isEmpty(sessionId)) {
                    sendJson(response, SC_BAD_REQUEST, "{\"success\":false,\"error\":\"sessionId required\"}");
                    return;
                }
                // Validate the session belongs to this teacher
                TalaqqiSession ts = talaqqiSessionDAO.getSessionBySessionId(sessionId, teacherId);
                if (ts == null) {
                    System.err.println("[TeacherTalaqqiSessionServlet] startSession: session not found for sessionId="
                            + sessionId + ", teacherId=" + teacherId);
                    sendJson(response, SC_NOT_FOUND,
                            "{\"success\":false,\"error\":\"Session not found for this teacher\"}");
                    return;
                }
                
                // Record session start time in database (non-blocking; session can still start)
                talaqqiSessionDAO.recordSessionStartTime(sessionId);
                
                // Mark active in HTTP session
                httpSession.setAttribute(SESSION_KEY, sessionId);

                String roomName = ts.generateRoomName();
                Teacher teacher = teacherDAO.getTeacherById(teacherId);
                String teacherName = teacher != null ? teacher.getFullName() : "Teacher";
                String teacherEmail = teacher != null ? teacher.getEmail() : "";
                String jwt = resolveTeacherJwt(teacher, teacherId, teacherName, ts);

                StringBuilder json = new StringBuilder();
                json.append("{\"success\":true,");
                json.append("\"roomName\":\"").append(escapeJson(roomName)).append("\",");
                json.append("\"sessionId\":\"").append(escapeJson(sessionId)).append("\"");
                if (jwt != null && !jwt.isEmpty()) {
                    json.append(",\"jwt\":\"").append(escapeJson(jwt)).append("\"");
                }
                json.append(",\"message\":\"Session started\"}");
                sendJson(response, 200, json.toString());
                break;
            }

            // ── End Session ───────────────────────────────────────────────────
            case "endSession": {
                String sessionId  = request.getParameter("sessionId");
                String studentId  = request.getParameter("studentId");
                if (isEmpty(sessionId)) {
                    sendJson(response, SC_BAD_REQUEST, "{\"success\":false,\"error\":\"sessionId required\"}");
                    return;
                }

                // Record leave time for all students who joined this session
                int leaveUpdated = talaqqiSessionDAO.updateLeaveTimesForSession(sessionId, currentSqlTime());
                if (leaveUpdated == 0 && !isEmpty(studentId)) {
                    talaqqiSessionDAO.updateLeaveTime(sessionId, studentId, currentSqlTime());
                }

                // Mark all missing students (who didn't join) as ABSENT
                int absentMarkedCount = talaqqiSessionDAO.markMissingStudentsAsAbsent(sessionId, teacherId);

                // Mark class as Completed in DB
                boolean completed = talaqqiSessionDAO.completeSession(sessionId, teacherId);

                boolean pendingCreated = false;
                try (java.sql.Connection conn = util.DBConnection.getConnection()) {
                    if (conn != null) {
                        com.talaqqihub.dao.TeacherEvaluationDAO evalDao =
                            new com.talaqqihub.dao.TeacherEvaluationDAO(conn);
                        evalDao.ensureStudentEvaluationSchema();
                        pendingCreated = evalDao.ensurePendingEvaluationForSession(sessionId, teacherId);
                    }
                } catch (Exception evalError) {
                    System.err.println("[TeacherTalaqqiSessionServlet] pending evaluation skipped: "
                        + evalError.getMessage());
                }

                talaqqiSessionDAO.clearLiveSessionStart(sessionId);

                // Clear the active session from HTTP session
                httpSession.removeAttribute(SESSION_KEY);

                sendJson(response, 200,
                    "{\"success\":" + (completed || pendingCreated) + "," +
                    "\"completed\":" + completed + "," +
                    "\"pendingEvaluation\":" + pendingCreated + "," +
                    "\"absentMarked\":" + absentMarkedCount + "," +
                    "\"evaluationUrl\":\"" + request.getContextPath() + "/teacher/evaluation\"," +
                    "\"message\":\"Session ended. Please evaluate your student.\"}");
                break;
            }

            // ── Update Quran Reference ───────────────────────────────────────────────
            case "updateQuran": {
                String sessionId  = request.getParameter("sessionId");
                String surahParam = request.getParameter("surah");
                String ayahParam  = request.getParameter("ayah");
                String ayahEndParam = request.getParameter("ayahEnd");

                if (isEmpty(sessionId) || isEmpty(surahParam) || isEmpty(ayahParam)) {
                    sendJson(response, SC_BAD_REQUEST,
                        "{\"success\":false,\"error\":\"sessionId, surah and ayah are required\"}");
                    return;
                }

                int surah, ayah, ayahEnd = 0;
                try {
                    surah = Integer.parseInt(surahParam.trim());
                    ayah  = Integer.parseInt(ayahParam.trim());
                    if (!isEmpty(ayahEndParam)) {
                        ayahEnd = Integer.parseInt(ayahEndParam.trim());
                    }
                } catch (NumberFormatException e) {
                    sendJson(response, SC_BAD_REQUEST,
                        "{\"success\":false,\"error\":\"surah, ayah and ayahEnd must be integers\"}");
                    return;
                }

                if (surah < 1 || surah > 114 || ayah < 1) {
                    sendJson(response, SC_BAD_REQUEST,
                        "{\"success\":false,\"error\":\"Invalid surah or ayah number\"}");
                    return;
                }
                if (ayahEnd > 0 && ayahEnd < ayah) {
                    sendJson(response, SC_BAD_REQUEST,
                        "{\"success\":false,\"error\":\"ayahEnd must be >= ayah (start)\"}");
                    return;
                }

                boolean updated = talaqqiSessionDAO.updateQuranReference(sessionId, teacherId, surah, ayah, ayahEnd);
                sendJson(response, 200,
                    "{\"success\":" + updated + "," +
                    "\"surah\":" + surah + "," +
                    "\"ayah\":"  + ayah  + "," +
                    "\"ayahEnd\":" + ayahEnd + "}");
                break;
            }

            // ── Record Student Attendance (auto – triggered when student joins) ─
            case "recordAttendance": {
                String sessionId     = request.getParameter("sessionId");
                String studentId     = request.getParameter("studentId");
                String statusParam   = request.getParameter("status");   // "Present" | "Absent" | "Late"
                String autoParam     = request.getParameter("auto");     // "true" | "false"

                if (isEmpty(sessionId) || isEmpty(studentId)) {
                    sendJson(response, SC_BAD_REQUEST,
                        "{\"success\":false,\"error\":\"sessionId and studentId are required\"}");
                    return;
                }

                boolean auto = "true".equalsIgnoreCase(autoParam);
                Time joinTime = currentSqlTime();
                String status;
                if (auto) {
                    status = talaqqiSessionDAO.determineAttendanceStatus(sessionId, studentId, joinTime);
                } else {
                    status = (statusParam != null && !statusParam.isEmpty()) ? statusParam : "Present";
                }

                // Fetch teacherId from the session to ensure correct scope
                TalaqqiSession ts = talaqqiSessionDAO.getSessionBySessionId(sessionId, teacherId);
                String resolvedTeacherId = (ts != null) ? ts.getTeacherId() : teacherId;

                boolean recorded = talaqqiSessionDAO.recordAttendance(
                        sessionId, studentId, resolvedTeacherId, status, joinTime, auto);

                sendJson(response, 200,
                    "{\"success\":" + recorded + "," +
                    "\"status\":\"" + escapeJson(status) + "\"," +
                    "\"message\":\"Attendance recorded\"}");
                break;
            }

            default:
                sendJson(response, SC_BAD_REQUEST,
                    "{\"success\":false,\"error\":\"Unknown action: " + escapeJson(action) + "\"}");
        }
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  Utility helpers
    // ══════════════════════════════════════════════════════════════════════════

    private String resolveTeacherJwt(Teacher teacher, String teacherId, String teacherName,
                                     TalaqqiSession session) {
        if (session == null) return JitsiConfig.getJwt();

        String roomSlug = JitsiConfig.buildRoomSlug(session.getTeacherId(), session.getSessionId());
        String email = teacher != null ? teacher.getEmail() : "";
        String jwt = JaasJwtGenerator.createModeratorToken(teacherId, teacherName, email, roomSlug);
        if (jwt != null && !jwt.isEmpty()) return jwt;
        return JitsiConfig.getJwt();
    }

    private boolean isAuthenticated(HttpSession s) {
        return SessionRoleUtil.isTeacherLoggedIn(s);
    }

    private boolean isEmpty(String s) {
        return s == null || s.trim().isEmpty();
    }

    private void sendJson(HttpServletResponse response, int status, String json) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print(json);
        }
    }

    /** Escapes special characters for safe embedding in a JSON string value. */
    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }

    private Time currentSqlTime() {
        LocalTime now = LocalTime.now();
        return Time.valueOf(now);
    }

    private String resolveInitials(String name) {
        if (name == null || name.trim().isEmpty()) return "??";
        String[] parts = name.trim().split("\\s+");
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < Math.min(parts.length, 2); i++) {
            if (!parts[i].isEmpty()) sb.append(Character.toUpperCase(parts[i].charAt(0)));
        }
        return sb.toString();
    }

    // HTTP status code constants (javax.servlet doesn't expose these as easy constants)
    private static final int SC_BAD_REQUEST  = 400;
    private static final int SC_UNAUTHORIZED = 401;
    private static final int SC_NOT_FOUND    = 404;
}
