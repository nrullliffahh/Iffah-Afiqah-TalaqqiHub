package com.talaqqihub.servlet;

import com.talaqqihub.model.Evaluation;
import com.talaqqihub.dao.TeacherEvaluationDAO;
import dao.NotificationDAO;
import java.io.*;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import util.DBConnection;

/**
 * TeacherEvaluationServlet
 * Handles requests for teacher evaluation module
 */
public class TeacherEvaluationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private Connection getConnection() throws SQLException {
        Connection conn = DBConnection.getConnection();
        if (conn == null) {
            throw new SQLException("Unable to obtain database connection");
        }
        return conn;
    }

    /**
     * Handle GET requests - Display evaluation dashboard
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        if (session == null || session.getAttribute("teacherId") == null) {
            response.sendRedirect(request.getContextPath() + "/teacher/login");
            return;
        }

        Object teacherIdObj = session.getAttribute("teacherId");
        String teacherId = formatTeacherIdFromSession(teacherIdObj);
        if (teacherId.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/teacher/login");
            return;
        }

        System.out.println("TeacherEvaluationServlet: loading data for teacherId=" + teacherId);
        
        try (Connection connection = getConnection()) {
            TeacherEvaluationDAO dao = new TeacherEvaluationDAO(connection);
            dao.ensureStudentEvaluationSchema();

            // Get dashboard summary
            Map<String, Object> dashboardSummary = dao.getDashboardSummary(teacherId);
            request.setAttribute("dashboardSummary", dashboardSummary);

            // Backfill PENDING rows for completed sessions, then load pending list
            List<Evaluation> pendingSessions = dao.getPendingSessionsNeedingEvaluation(teacherId);
            for (Evaluation pendingSession : pendingSessions) {
                if (pendingSession.getSessionId() != null && !pendingSession.getSessionId().trim().isEmpty()) {
                    dao.ensurePendingEvaluationForSession(pendingSession.getSessionId(), teacherId);
                }
            }

            List<Evaluation> pendingEvaluations = dao.getPendingEvaluations(teacherId);
            pendingSessions = dao.getPendingSessionsNeedingEvaluation(teacherId);
            for (Evaluation pendingSession : pendingSessions) {
                boolean exists = false;
                for (Evaluation existing : pendingEvaluations) {
                    if (pendingSession.getSessionId() != null
                            && pendingSession.getSessionId().equals(existing.getSessionId())) {
                        exists = true;
                        break;
                    }
                }
                if (!exists) {
                    pendingEvaluations.add(pendingSession);
                }
            }
            request.setAttribute("pendingEvaluations", pendingEvaluations);

            // Get search, filter, and sort parameters
            String searchTerm = request.getParameter("search");
            String filterClass = request.getParameter("filterClass");
            String sortBy = request.getParameter("sort");

            // Get completed evaluations
            List<Evaluation> completedEvaluations = dao.getCompletedEvaluations(
                teacherId, searchTerm, filterClass, sortBy
            );
            request.setAttribute("completedEvaluations", completedEvaluations);

            List<Evaluation> studentFeedbackList = dao.getStudentFeedbackForTeacher(teacherId);
            request.setAttribute("studentFeedbackList", studentFeedbackList);
            System.out.println("TeacherEvaluationServlet: pending=" + pendingEvaluations.size()
                + ", completed=" + completedEvaluations.size()
                + ", studentFeedback=" + studentFeedbackList.size());

            // Get class names for filter dropdown
            List<String> classNames = dao.getClassNames(teacherId);
            request.setAttribute("classNames", classNames);

            // Forward parameters to JSP for displaying in form
            request.setAttribute("searchTerm", searchTerm);
            request.setAttribute("filterClass", filterClass);
            request.setAttribute("sortBy", sortBy);
            request.setAttribute("teacherId", teacherId);
            request.setAttribute("teacherName", session.getAttribute("teacherName"));
            request.setAttribute("loadedFromServlet", Boolean.TRUE);

            RequestDispatcher dispatcher = request.getRequestDispatcher("/teacherEvaluation.jsp");
            dispatcher.forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database connection error: " + e.getMessage());
            RequestDispatcher dispatcher = request.getRequestDispatcher("/error.jsp");
            dispatcher.forward(request, response);
        }
    }

    /**
     * Handle POST requests - Save/Update evaluation
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        // Detect AJAX before auth check so we can return JSON on auth failure
        boolean isAjaxEarly = "true".equals(request.getParameter("ajax"))
                || "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));

        // Check if user is logged in
        if (session == null || session.getAttribute("teacherId") == null) {
            if (isAjaxEarly) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\":false,\"message\":\"Session expired. Please log in again.\"}");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/teacher/login");
            return;
        }

        Object teacherIdObj = session.getAttribute("teacherId");
        String teacherIdStr = formatTeacherIdFromSession(teacherIdObj);
        if (teacherIdStr.isEmpty()) {
            if (isAjaxEarly) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\":false,\"message\":\"Session expired. Please log in again.\"}");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/teacher/login");
            return;
        }
        String action = request.getParameter("action");
        String evaluationIdParam = request.getParameter("evaluationId");

        // Existing DB records have a real evaluationId (>0). "0" or blank means a new insert.
        boolean hasExistingEvalId = evaluationIdParam != null
                && !evaluationIdParam.trim().isEmpty()
                && !"0".equals(evaluationIdParam.trim());
        if (hasExistingEvalId) {
            action = "update";
        } else if (action == null || action.trim().isEmpty()) {
            action = "insert";
        }

        // Detect AJAX early so every code path can return JSON
        boolean isAjax = "true".equals(request.getParameter("ajax"))
                || "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));

        try {
            Connection connection = null;
            try {
                // Try JNDI DataSource first, fall back to DriverManager
                connection = getConnection();

                TeacherEvaluationDAO dao = new TeacherEvaluationDAO(connection);
                dao.ensureStudentEvaluationSchema();

                Evaluation evaluation = extractEvaluationFromRequest(request);
                evaluation.setTeacherId(teacherIdStr);
                ensureOverallScore(evaluation);

                boolean success;
                String successMsg;
                String failMsg;

                if ("update".equals(action)) {
                    success = dao.updateEvaluation(evaluation);
                    if (!success) {
                        success = dao.saveEvaluation(evaluation);
                    }
                    successMsg = "Evaluation saved successfully!";
                    failMsg    = "Failed to save evaluation.";
                } else {
                    success = dao.saveEvaluation(evaluation);
                    successMsg = "Evaluation recorded successfully!";
                    failMsg    = "Failed to record evaluation.";
                    if (success && evaluation.getStudentId() != null) {
                        String classLabel = evaluation.getClassName() != null ? evaluation.getClassName() : "your session";
                        try {
                            new NotificationDAO().createNotification(
                                evaluation.getStudentId(), "student",
                                NotificationDAO.TITLE_EVALUATION_RECEIVED,
                                "New evaluation received for " + classLabel,
                                evaluation.getSessionId(), null);
                        } catch (Exception notifyError) {
                            System.err.println("[TeacherEvaluationServlet] notification skipped: " + notifyError.getMessage());
                        }
                    }
                }

                String daoError = dao.getLastError();
                if (!success && daoError != null && !daoError.trim().isEmpty()) {
                    failMsg = daoError;
                }

                if (isAjax) {
                    writeJsonResponse(response, success, successMsg, failMsg, evaluation);
                    return;
                }
                response.sendRedirect(request.getContextPath() + "/teacher/evaluation");

            } finally {
                if (connection != null) {
                    try { connection.close(); } catch (Exception ignored) {}
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("[TeacherEvaluationServlet] doPost error: " + e.getClass().getName() + ": " + e.getMessage());
            if (isAjax) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\":false,\"message\":\"" + jsonEscape(e.getMessage()) + "\"}");
                return;
            }
            request.setAttribute("error", "Error: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }

    /**
     * Extract evaluation data from request parameters
     */
    private Evaluation extractEvaluationFromRequest(HttpServletRequest request) {
        Evaluation evaluation = new Evaluation();

        // Parse integer fields — evaluationId may be numeric ("1") or prefixed ("SE001")
        String evaluationId = request.getParameter("evaluationId");
        if (evaluationId != null && !evaluationId.trim().isEmpty() && !"0".equals(evaluationId.trim())) {
            try {
                String numericOnly = evaluationId.trim().replaceAll("[^0-9]", "");
                if (!numericOnly.isEmpty() && !"0".equals(numericOnly)) {
                    evaluation.setEvaluationId(Integer.parseInt(numericOnly));
                }
            } catch (NumberFormatException ignored) {}
        }

        String studentId = request.getParameter("studentId");
        if (studentId != null && !studentId.trim().isEmpty()) {
            evaluation.setStudentId(studentId); // string form like "S006"
        }

        String rating = request.getParameter("rating");
        if (rating != null && !rating.trim().isEmpty()) {
            evaluation.setRating(Integer.parseInt(rating));
        }

        // Parse float fields
        String tajweedScore = request.getParameter("tajweedScore");
        if (tajweedScore != null && !tajweedScore.trim().isEmpty()) {
            evaluation.setTajweedScore(Float.parseFloat(tajweedScore));
        }

        String fluencyScore = request.getParameter("fluencyScore");
        if (fluencyScore != null && !fluencyScore.trim().isEmpty()) {
            evaluation.setFluencyScore(Float.parseFloat(fluencyScore));
        }

        String accuracyScore = request.getParameter("accuracyScore");
        if (accuracyScore != null && !accuracyScore.trim().isEmpty()) {
            evaluation.setAccuracyScore(Float.parseFloat(accuracyScore));
        }

        String overallScore = request.getParameter("overallScore");
        if (overallScore != null && !overallScore.trim().isEmpty()) {
            evaluation.setOverallScore(Float.parseFloat(overallScore));
        }

        // String fields
        evaluation.setStudentName(request.getParameter("studentName"));
        evaluation.setClassName(request.getParameter("className"));
        evaluation.setSurah(request.getParameter("surah"));
        evaluation.setAyahRange(request.getParameter("ayahRange"));
        evaluation.setSessionDate(request.getParameter("sessionDate"));
        evaluation.setStartTime(request.getParameter("startTime"));
        evaluation.setEndTime(request.getParameter("endTime"));
        evaluation.setComments(request.getParameter("comments"));
        evaluation.setAreasForImprovement(request.getParameter("areasForImprovement"));
        evaluation.setPerformanceTag(request.getParameter("performanceTag"));
        evaluation.setNextTarget(request.getParameter("nextTarget"));
        evaluation.setSuggestions(request.getParameter("suggestions"));
        evaluation.setTeacherComments(request.getParameter("teacherComments"));
        evaluation.setStatus(request.getParameter("status"));
        evaluation.setSessionId(request.getParameter("sessionId"));
        String scheduleIdParam = request.getParameter("scheduleId");
        if (scheduleIdParam != null && !scheduleIdParam.trim().isEmpty()) {
            try {
                evaluation.setScheduleId(Integer.parseInt(scheduleIdParam.trim().replaceAll("[^0-9]", "")));
            } catch (NumberFormatException ignored) {}
        }

        return evaluation;
    }

    /**
     * Compute an overall score if the form did not submit one.
     */
    private void ensureOverallScore(Evaluation evaluation) {
        if (evaluation.getOverallScore() > 0) {
            return;
        }

        float averageScore = (evaluation.getTajweedScore() + evaluation.getFluencyScore() + evaluation.getAccuracyScore()) / 3.0f;
        evaluation.setOverallScore(averageScore);
    }

    private void writeJsonResponse(HttpServletResponse response, boolean success,
                                   String successMsg, String failMsg,
                                   com.talaqqihub.model.Evaluation evaluation) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        if (success) {
            String evalJson;
            try {
                // Resolve numeric evalId (e.g. evaluationId=1 → "SE001") for the response
                String resolvedEvalId = evaluation.getEvaluationId() > 0
                        ? "SE" + String.format("%03d", evaluation.getEvaluationId())
                        : "";
                evalJson = "{" +
                    "\"evaluationId\":"   + evaluation.getEvaluationId()             + "," +
                    "\"evaluationIdStr\":\"" + jsonEscape(resolvedEvalId)            + "\"," +
                    "\"studentId\":\""    + jsonEscape(evaluation.getStudentId())    + "\"," +
                    "\"studentName\":\""  + jsonEscape(evaluation.getStudentName())  + "\"," +
                    "\"sessionId\":\""    + jsonEscape(evaluation.getSessionId())    + "\"," +
                    "\"sessionDate\":\""  + jsonEscape(evaluation.getSessionDate())  + "\"," +
                    "\"startTime\":\""    + jsonEscape(evaluation.getStartTime())    + "\"," +
                    "\"endTime\":\""      + jsonEscape(evaluation.getEndTime())      + "\"," +
                    "\"className\":\""    + jsonEscape(evaluation.getClassName())    + "\"," +
                    "\"surah\":\""        + jsonEscape(evaluation.getSurah())        + "\"," +
                    "\"ayahRange\":\""    + jsonEscape(evaluation.getAyahRange())    + "\"," +
                    "\"tajweedScore\":"   + evaluation.getTajweedScore()             + "," +
                    "\"fluencyScore\":"   + evaluation.getFluencyScore()             + "," +
                    "\"accuracyScore\":"  + evaluation.getAccuracyScore()            + "," +
                    "\"overallScore\":"   + evaluation.getOverallScore()             + "," +
                    "\"rating\":"         + evaluation.getRating()                   + "," +
                    "\"comments\":\""     + jsonEscape(evaluation.getComments())     + "\"," +
                    "\"areasForImprovement\":\"" + jsonEscape(evaluation.getAreasForImprovement()) + "\"," +
                    "\"suggestions\":\""  + jsonEscape(evaluation.getSuggestions())  + "\"," +
                    "\"nextTarget\":\""   + jsonEscape(evaluation.getNextTarget())   + "\"," +
                    "\"teacherComments\":\"" + jsonEscape(evaluation.getTeacherComments()) + "\"," +
                    "\"performanceTag\":\"" + jsonEscape(evaluation.getPerformanceTag()) + "\"" +
                    "}";
            } catch (Exception e) {
                evalJson = "{}";
            }
            out.print("{\"success\":true,\"message\":\"" + successMsg + "\",\"evaluation\":" + evalJson + "}");
        } else {
            out.print("{\"success\":false,\"message\":\"" + jsonEscape(failMsg) + "\"}");
        }
        out.flush();
    }

    // Simple JSON string escaper for small payloads
    private String jsonEscape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }

    private String formatTeacherIdFromSession(Object teacherIdObj) {
        if (teacherIdObj == null) {
            return "";
        }
        if (teacherIdObj instanceof String) {
            String id = ((String) teacherIdObj).trim();
            if (id.matches("T\\d+")) {
                return id;
            }
            String digits = id.replaceAll("[^0-9]", "");
            if (!digits.isEmpty()) {
                return "T" + String.format("%03d", Integer.parseInt(digits));
            }
            return id;
        }
        if (teacherIdObj instanceof Number) {
            return "T" + String.format("%03d", ((Number) teacherIdObj).intValue());
        }
        return teacherIdObj.toString().trim();
    }
}
