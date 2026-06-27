package controller;

import dao.TalaqqiSessionDAO;
import dao.QuranDAO;
import model.Student;
import model.TalaqqiSession;
import model.QuranVerse;
import util.JaasJwtGenerator;
import util.JitsiConfig;
import util.SessionRoleUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * StudentTalaqqiSessionServlet
 *
 * Handles Talaqqi (live recitation) session viewing for students.
 *
 * URL: /student/talaqqi-session
 *
 * ── GET Requests ─────────────────────────────────────────────────────────
 *   /student/talaqqi-session           → Loads the current or next session
 *   /student/talaqqi-session?sessionId=X  → Loads specific session
 *
 * ── POST Requests (action= parameter) ────────────────────────────────────
 *   action=joinSession    → Records student join time, returns JSON
 *   action=leaveSession   → Records student leave time, returns JSON
 *   action=acknowledgeVerse → Confirms student received verse reference
 *
 * MVC Role: Controller – authenticates student, retrieves session and Quran data,
 * forwards to JSP for rendering.
 *
 * Differences from Teacher version:
 *   - Student is read-only: cannot start/end session or update Quran
 *   - Can only join sessions they are booked for
 *   - Join/leave events are logged for attendance tracking
 */
public class StudentTalaqqiSessionServlet extends HttpServlet {

    private TalaqqiSessionDAO talaqqiSessionDAO;
    private QuranDAO quranDAO;

    private static final String VIEW_PATH = "/WEB-INF/views/studentTalaqqiSession.jsp";

    @Override
    public void init() throws ServletException {
        talaqqiSessionDAO = new TalaqqiSessionDAO();
        quranDAO = new QuranDAO();
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  GET – Load session view
    // ══════════════════════════════════════════════════════════════════════════

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── Authentication guard ──────────────────────────────────────────────
        HttpSession httpSession = request.getSession(false);
        if (!isAuthenticated(httpSession)) {
            response.sendRedirect(request.getContextPath() + "/student/login");
            return;
        }

        String studentId = (String) httpSession.getAttribute("studentId");

        // ── Resolve which session to display ──────────────────────────────────
        String sessionId = request.getParameter("sessionId");
        TalaqqiSession session = null;

        if (sessionId != null && !sessionId.trim().isEmpty()) {
            // Try to load specific session (verify ownership)
            session = talaqqiSessionDAO.getSessionBySessionId(sessionId.trim(), null);
            if (session != null && !studentId.equals(session.getStudentId())) {
                // Student does not own this session – deny access
                session = null;
            }
        }

        // Fall back to next upcoming session for this student
        if (session == null) {
            session = talaqqiSessionDAO.getUpcomingSessionForStudent(studentId);
        }

        List<TalaqqiSession> upcomingSessions =
                talaqqiSessionDAO.getUpcomingSessionsListForStudent(studentId, 0);

        // ── Load Quran data for current session ─────────────────────────────
        List<QuranVerse> verses = null;
        if (session != null) {
            int surahNumber = session.getCurrentSurahNumber();
            int ayahNumber = session.getCurrentAyahNumber();
            int ayahEnd = session.getCurrentAyahEnd();

            int verseCount;
            if (ayahEnd > ayahNumber) {
                verseCount = ayahEnd - ayahNumber + 1;
            } else if (ayahEnd > 0) {
                verseCount = 1;
            } else {
                verseCount = 5;
            }
            if (verseCount > 50) {
                verseCount = 50;
            }

            QuranVerse currentVerse = quranDAO.getAyah(surahNumber, ayahNumber);
            verses = loadVerseSequence(surahNumber, ayahNumber, verseCount);

            request.setAttribute("currentVerse", currentVerse);
        } else {
            verses = new java.util.ArrayList<>();
        }

        // ── Set request attributes for JSP ───────────────────────────────────
        request.setAttribute("session", session);
        request.setAttribute("upcomingSessions", upcomingSessions);
        request.setAttribute("verses", verses);
        request.setAttribute("studentId", studentId);
        request.setAttribute("studentName", httpSession.getAttribute("studentName"));
        request.setAttribute("studentInitials", httpSession.getAttribute("studentInitials"));

        // Also set context path for URL building in JSP
        request.setAttribute("contextPath", request.getContextPath());

        // ── Forward to JSP ───────────────────────────────────────────────────
        request.getRequestDispatcher(VIEW_PATH).forward(request, response);
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  POST – Handle AJAX requests
    // ══════════════════════════════════════════════════════════════════════════

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // ── Authentication guard ──────────────────────────────────────────────
        HttpSession httpSession = request.getSession(false);
        if (!isAuthenticated(httpSession)) {
            sendJsonError(response, "Unauthorized");
            return;
        }

        String studentId = (String) httpSession.getAttribute("studentId");

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            sendJsonError(response, "Missing action parameter");
            return;
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        switch (action.trim()) {

            case "joinSession": {
                String sessionId = request.getParameter("sessionId");
                if (sessionId == null || sessionId.trim().isEmpty()) {
                    sendJsonError(response, "sessionId required");
                    return;
                }

                // Get the session to verify permission and get teacher ID
                TalaqqiSession session = talaqqiSessionDAO.getSessionBySessionId(sessionId.trim(), null);
                if (session == null || !studentId.equals(session.getStudentId())) {
                    sendJsonError(response, "Session not found or access denied");
                    return;
                }

                // Determine if student is late (joined > 5 minutes after teacher started)
                java.sql.Time joinTime = new java.sql.Time(System.currentTimeMillis());
                String attendanceStatus = talaqqiSessionDAO.determineAttendanceStatus(
                    sessionId, studentId, joinTime);
                
                // Record join time
                boolean recorded = talaqqiSessionDAO.recordAttendance(
                    sessionId, studentId, session.getTeacherId(), attendanceStatus, joinTime, true);

                if (recorded) {
                    String studentName = stringAttr(httpSession, "studentName");
                    String studentEmail = resolveStudentEmail(httpSession);
                    String roomSlug = JitsiConfig.buildRoomSlug(
                            session.getTeacherId(), session.getSessionId());
                    String jwt = JaasJwtGenerator.createParticipantToken(
                            studentId, studentName, studentEmail, roomSlug);

                    StringBuilder json = new StringBuilder();
                    json.append("{\"success\": true, ");
                    json.append("\"message\": \"Joined session as ").append(attendanceStatus).append("\", ");
                    json.append("\"status\": \"").append(attendanceStatus).append("\"");
                    if (jwt != null && !jwt.isEmpty()) {
                        json.append(", \"jwt\": \"").append(escapeJson(jwt)).append("\"");
                    }
                    json.append("}");
                    response.getWriter().write(json.toString());
                } else {
                    sendJsonError(response, "Failed to record attendance");
                }
                break;
            }

            case "leaveSession": {
                String sessionId = request.getParameter("sessionId");
                if (sessionId == null || sessionId.trim().isEmpty()) {
                    sendJsonError(response, "sessionId required");
                    return;
                }

                // Update leave time in attendance table
                java.sql.Time leaveTime = new java.sql.Time(System.currentTimeMillis());
                boolean updated = talaqqiSessionDAO.updateLeaveTime(sessionId, studentId, leaveTime);

                if (updated) {
                    response.getWriter().write("{\"success\": true, \"message\": \"Left session\"}");
                } else {
                    sendJsonError(response, "Failed to record leave time");
                }
                break;
            }

            case "acknowledgeVerse": {
                String sessionId = request.getParameter("sessionId");
                int surah = Integer.parseInt(request.getParameter("surah"));
                int ayah = Integer.parseInt(request.getParameter("ayah"));
                // TODO: Log that student acknowledged receipt of verse reference
                response.getWriter().write("{\"success\": true, \"message\": \"Verse acknowledged\"}");
                break;
            }

            case "getCurrentQuran": {
                // Fetch the current session's Quran reference and return as JSON
                // Used by JavaScript polling to detect when teacher updates the verse
                String sessionId = request.getParameter("sessionId");
                
                TalaqqiSession session = null;
                if (sessionId != null && !sessionId.trim().isEmpty()) {
                    session = talaqqiSessionDAO.getSessionBySessionId(sessionId.trim(), null);
                    if (session != null && !studentId.equals(session.getStudentId())) {
                        session = null;
                    }
                }
                
                if (session == null) {
                    session = talaqqiSessionDAO.getUpcomingSessionForStudent(studentId);
                }
                
                if (session != null) {
                    int surah = session.getCurrentSurahNumber();
                    int ayah = session.getCurrentAyahNumber();
                    int ayahEnd = session.getCurrentAyahEnd();
                    int juzuk = session.getCurrentJuzukNumber();
                    if (juzuk <= 0) {
                        juzuk = 1;
                    }
                    
                    response.getWriter().write(
                        "{\"success\": true, " +
                        "\"surah\": " + surah + ", " +
                        "\"ayah\": " + ayah + ", " +
                        "\"ayahEnd\": " + ayahEnd + ", " +
                        "\"juzuk\": " + juzuk + ", " +
                        "\"sessionId\": \"" + escapeJson(session.getSessionId()) + "\"}"
                    );
                } else {
                    response.getWriter().write(
                        "{\"success\": false, " +
                        "\"error\": \"No active session found\"}"
                    );
                }
                break;
            }

            default:
                sendJsonError(response, "Unknown action: " + action);
        }
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  Helper Methods
    // ══════════════════════════════════════════════════════════════════════════

    /**
     * Checks if student is authenticated (has studentId in session).
     */
    private boolean isAuthenticated(HttpSession httpSession) {
        if (httpSession == null) return false;
        String studentId = (String) httpSession.getAttribute("studentId");
        return SessionRoleUtil.isStudentLoggedIn(httpSession);
    }

    /**
     * Loads a sequence of verses starting from the given surah:ayah.
     * Used for pre-loading the Quran panel.
     *
     * @param startSurah   Starting surah number
     * @param startAyah    Starting ayah number
     * @param count        Number of verses to load
     * @return List of QuranVerse objects
     */
    private List<QuranVerse> loadVerseSequence(int startSurah, int startAyah, int count) {
        List<QuranVerse> result = new java.util.ArrayList<>();

        int currentSurah = startSurah;
        int currentAyah = startAyah;

        for (int i = 0; i < count; i++) {
            QuranVerse verse = quranDAO.getAyah(currentSurah, currentAyah);
            if (verse != null) {
                result.add(verse);
                currentAyah++;

                // Check if we've reached the end of the surah
                if (currentAyah > verse.getTotalAyahs()) {
                    if (currentSurah < 114) {
                        currentSurah++;
                        currentAyah = 1;
                    } else {
                        // Reached end of Quran
                        break;
                    }
                }
            }
        }

        return result;
    }

    private String resolveStudentEmail(HttpSession httpSession) {
        if (httpSession == null) return "";
        Object studentObj = httpSession.getAttribute("student");
        if (studentObj instanceof Student) {
            Student student = (Student) studentObj;
            String email = student.getEmail();
            if (email == null || email.isEmpty()) {
                email = student.getStudentEmail();
            }
            return email != null ? email : "";
        }
        return "";
    }

    private String stringAttr(HttpSession httpSession, String key) {
        if (httpSession == null) return "";
        Object value = httpSession.getAttribute(key);
        return value != null ? value.toString() : "";
    }

    /**
     * Sends a JSON error response.
     */
    private void sendJsonError(HttpServletResponse response, String message) throws IOException {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write("{\"success\": false, \"error\": \"" + escapeJson(message) + "\"}");
    }

    /**
     * Escapes JSON special characters in a string.
     */
    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r")
                    .replace("\t", "\\t");
    }
}
