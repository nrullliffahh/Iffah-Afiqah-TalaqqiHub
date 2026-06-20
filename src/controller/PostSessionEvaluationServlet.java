package controller;

import dao.EvaluationDAO;
import util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * PostSessionEvaluationServlet
 *
 * Handles post-session evaluation feedback collection for both students and teachers.
 * After a Talaqqi session ends, this servlet collects:
 * - Student feedback about the teacher
 * - Teacher feedback about the student (if teacher submits)
 *
 * URL: /api/evaluation/session-feedback
 *
 * ── POST Requests (action= parameter) ────────────────────────────────────
 *   action=submitStudentFeedback   → Student rates teacher after session
 *   action=submitTeacherFeedback   → Teacher rates student after session
 *   action=getPendingEvaluations   → Get sessions needing evaluation
 *   action=getMonthlyStatus        → Check monthly evaluation status
 *
 * Response: JSON
 */
public class PostSessionEvaluationServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private EvaluationDAO evaluationDAO;

    @Override
    public void init() throws ServletException {
        evaluationDAO = new EvaluationDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── Authentication guard ──────────────────────────────────────────────
        HttpSession httpSession = request.getSession(false);
        if (httpSession == null) {
            sendJsonError(response, 401, "Unauthorized - no session");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            sendJsonError(response, 400, "Missing action parameter");
            return;
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            switch (action.trim()) {

                case "submitStudentFeedback": {
                    handleStudentFeedback(request, response, httpSession);
                    break;
                }

                case "submitTeacherFeedback": {
                    handleTeacherFeedback(request, response, httpSession);
                    break;
                }

                case "getPendingEvaluations": {
                    handleGetPendingEvaluations(request, response, httpSession);
                    break;
                }

                case "getMonthlyStatus": {
                    handleGetMonthlyStatus(request, response, httpSession);
                    break;
                }

                default:
                    sendJsonError(response, 400, "Unknown action: " + action);
            }
        } catch (Exception e) {
            System.err.println("PostSessionEvaluationServlet error: " + e.getMessage());
            e.printStackTrace();
            sendJsonError(response, 500, "Internal server error");
        }
    }

    /**
     * Handle student feedback submission after session
     */
    private void handleStudentFeedback(HttpServletRequest request, HttpServletResponse response,
                                      HttpSession httpSession) throws IOException {

        String studentId = (String) httpSession.getAttribute("studentId");
        if (studentId == null) {
            sendJsonError(response, 401, "Student not authenticated");
            return;
        }

        String sessionId = request.getParameter("sessionId");
        String teacherId = request.getParameter("teacherId");
        String ratingStr = request.getParameter("rating");
        String comments = request.getParameter("comments");

        if (sessionId == null || teacherId == null || ratingStr == null) {
            sendJsonError(response, 400, "Missing required parameters");
            return;
        }

        try {
            int rating = Integer.parseInt(ratingStr);
            if (rating < 1 || rating > 5) {
                sendJsonError(response, 400, "Rating must be between 1-5");
                return;
            }

            // Record student feedback
            boolean success = evaluationDAO.recordSessionFeedback(
                sessionId, studentId, teacherId,
                rating, comments != null ? comments : "",
                0, ""  // Teacher rating/comments empty for now
            );

            if (success) {
                new dao.NotificationDAO().notifyTeacherOfStudentEvaluation(teacherId, studentId, sessionId);

                System.out.println("PostSessionEvaluationServlet: Student " + studentId +
                        " submitted feedback for teacher " + teacherId + " on session " + sessionId);

                response.getWriter().write(
                    "{\"success\": true, " +
                    "\"message\": \"Thank you for your feedback!\", " +
                    "\"rating\": " + rating + "}"
                );
            } else {
                sendJsonError(response, 500, "Failed to save feedback");
            }

        } catch (NumberFormatException e) {
            sendJsonError(response, 400, "Invalid rating format");
        }
    }

    /**
     * Handle teacher feedback submission after session
     */
    private void handleTeacherFeedback(HttpServletRequest request, HttpServletResponse response,
                                      HttpSession httpSession) throws IOException {

        String teacherId = (String) httpSession.getAttribute("teacherId");
        if (teacherId == null) {
            // Fallback for teachers who might use different session attribute
            Object teacherIdObj = httpSession.getAttribute("teacher_id");
            if (teacherIdObj != null) {
                teacherId = teacherIdObj.toString();
            } else {
                sendJsonError(response, 401, "Teacher not authenticated");
                return;
            }
        }

        String sessionId = request.getParameter("sessionId");
        String studentId = request.getParameter("studentId");
        String ratingStr = request.getParameter("rating");
        String comments = request.getParameter("comments");

        if (sessionId == null || studentId == null || ratingStr == null) {
            sendJsonError(response, 400, "Missing required parameters");
            return;
        }

        try {
            int rating = Integer.parseInt(ratingStr);
            if (rating < 1 || rating > 5) {
                sendJsonError(response, 400, "Rating must be between 1-5");
                return;
            }

            // Record teacher feedback
            boolean success = evaluationDAO.recordSessionFeedback(
                sessionId, studentId, teacherId,
                0, "",  // Student rating/comments empty (teacher shouldn't overwrite student feedback)
                rating, comments != null ? comments : ""
            );

            if (success) {
                System.out.println("PostSessionEvaluationServlet: Teacher " + teacherId +
                        " submitted feedback for student " + studentId + " on session " + sessionId);

                response.getWriter().write(
                    "{\"success\": true, " +
                    "\"message\": \"Feedback recorded successfully\", " +
                    "\"rating\": " + rating + "}"
                );
            } else {
                sendJsonError(response, 500, "Failed to save feedback");
            }

        } catch (NumberFormatException e) {
            sendJsonError(response, 400, "Invalid rating format");
        }
    }

    /**
     * Get pending evaluation sessions for student
     */
    private void handleGetPendingEvaluations(HttpServletRequest request, HttpServletResponse response,
                                           HttpSession httpSession) throws IOException {

        String studentId = (String) httpSession.getAttribute("studentId");
        if (studentId == null) {
            sendJsonError(response, 401, "Student not authenticated");
            return;
        }

        try {
            java.util.List<java.util.Map<String, Object>> pendingSessions =
                evaluationDAO.getPendingEvaluationSessions(studentId);

            // Convert to JSON
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < pendingSessions.size(); i++) {
                if (i > 0) json.append(",");
                java.util.Map<String, Object> session = pendingSessions.get(i);
                json.append("{")
                    .append("\"sessionId\":\"").append(session.get("sessionId")).append("\",")
                    .append("\"teacherId\":\"").append(session.get("teacherId")).append("\",")
                    .append("\"teacherName\":\"").append(session.get("teacherName")).append("\",")
                    .append("\"surah\":\"").append(session.get("surah")).append("\",")
                    .append("\"ayah\":\"").append(session.get("ayah")).append("\"")
                    .append("}");
            }
            json.append("]");

            response.getWriter().write(
                "{\"success\": true, " +
                "\"count\": " + pendingSessions.size() + ", " +
                "\"sessions\": " + json.toString() + "}"
            );

        } catch (Exception e) {
            System.err.println("Error getting pending evaluations: " + e.getMessage());
            sendJsonError(response, 500, "Failed to retrieve pending evaluations");
        }
    }

    /**
     * Get monthly evaluation status
     */
    private void handleGetMonthlyStatus(HttpServletRequest request, HttpServletResponse response,
                                       HttpSession httpSession) throws IOException {

        String studentId = (String) httpSession.getAttribute("studentId");
        if (studentId == null) {
            sendJsonError(response, 401, "Student not authenticated");
            return;
        }

        try {
            java.util.Map<String, Object> status = evaluationDAO.getMonthlyEvaluationStatus(studentId);

            StringBuilder json = new StringBuilder("{");
            json.append("\"isNewMonth\": ").append(status.get("isNewMonth")).append(",")
                .append("\"currentMonth\": \"").append(status.get("currentMonth")).append("\",")
                .append("\"evaluationSubmitted\": ").append(status.get("evaluationSubmitted")).append(",")
                .append("\"evaluationCount\": ").append(status.get("evaluationCount"));
            json.append("}");

            response.getWriter().write(
                "{\"success\": true, " +
                "\"status\": " + json.toString() + "}"
            );

        } catch (Exception e) {
            System.err.println("Error getting monthly status: " + e.getMessage());
            sendJsonError(response, 500, "Failed to retrieve monthly status");
        }
    }

    /**
     * Send JSON error response
     */
    private void sendJsonError(HttpServletResponse response, int statusCode, String message) throws IOException {
        response.setStatus(statusCode);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write("{\"success\": false, \"error\": \"" + escapeJson(message) + "\"}");
    }

    /**
     * Escape JSON special characters
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
