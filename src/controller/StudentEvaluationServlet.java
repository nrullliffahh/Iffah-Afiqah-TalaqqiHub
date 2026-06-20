package controller;

import dao.EvaluationDAO;
import model.Evaluation;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

/**
 * StudentEvaluationServlet
 * Handles student evaluation & progress requests
 */
public class StudentEvaluationServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    
    /**
     * Convert a List of Maps to JSON string for JavaScript
     */
    private String mapToJson(Object obj) {
        if (obj instanceof Map) {
            Map<?, ?> map = (Map<?, ?>) obj;
            StringBuilder json = new StringBuilder("{");
            int i = 0;
            for (Map.Entry<?, ?> entry : map.entrySet()) {
                if (i > 0) json.append(",");
                json.append("\"").append(entry.getKey()).append("\":");
                Object value = entry.getValue();
                if (value instanceof String) {
                    json.append("\"").append(value).append("\"");
                } else {
                    json.append(value);
                }
                i++;
            }
            json.append("}");
            return json.toString();
        } else if (obj instanceof List) {
            List<?> list = (List<?>) obj;
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < list.size(); i++) {
                if (i > 0) json.append(",");
                json.append(mapToJson(list.get(i)));
            }
            json.append("]");
            return json.toString();
        }
        return "[]";
    }

    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\n", "\\n")
                    .replace("\r", "");
    }

    private String buildEvaluationDataJson(List<Evaluation> historyList) {
        if (historyList == null || historyList.isEmpty()) return "{}";
        StringBuilder json = new StringBuilder("{");
        for (int i = 0; i < historyList.size(); i++) {
            Evaluation e = historyList.get(i);
            if (i > 0) json.append(",");
            json.append("\"").append(escapeJson(e.getEvaluationId())).append("\":{");
            json.append("\"evaluationId\":\"").append(escapeJson(e.getEvaluationId())).append("\",");
            json.append("\"teacherName\":\"").append(escapeJson(e.getTeacherName())).append("\",");
            json.append("\"createdAt\":\"").append(escapeJson(e.getCreatedAt())).append("\",");
            json.append("\"surahName\":\"").append(escapeJson(e.getSurahName())).append("\",");
            json.append("\"ayahRange\":\"").append(escapeJson(e.getAyahRange())).append("\",");
            json.append("\"tajweedScore\":").append(e.getTajweedScore()).append(",");
            json.append("\"fluencyScore\":").append(e.getFluencyScore()).append(",");
            json.append("\"accuracyScore\":").append(e.getAccuracyScore()).append(",");
            json.append("\"overallScore\":").append(e.getOverallScore()).append(",");
            json.append("\"strengths\":\"").append(escapeJson(e.getStrengths())).append("\",");
            json.append("\"improvements\":\"").append(escapeJson(e.getImprovements())).append("\",");
            json.append("\"suggestions\":\"").append(escapeJson(e.getSuggestions())).append("\",");
            json.append("\"nextTarget\":\"").append(escapeJson(e.getNextTarget())).append("\",");
            json.append("\"comments\":\"").append(escapeJson(e.getComments())).append("\"");
            json.append("}");
        }
        json.append("}");
        return json.toString();
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        // Check if user is logged in
        if (session == null || session.getAttribute("studentId") == null) {
            System.out.println("StudentEvaluationServlet: No session or studentId found, redirecting to login");
            response.sendRedirect(request.getContextPath() + "/student/login");
            return;
        }
        
        // Get student_id from session
        String studentId = (String) session.getAttribute("studentId");
        String studentName = (String) session.getAttribute("studentName");
        System.out.println("StudentEvaluationServlet: Loading evaluations for student: " + studentId);
        if (studentName != null) {
            System.out.println("StudentEvaluationServlet: Student Name: " + studentName);
        }
        
        // Initialize DAO and fetch data from database
        EvaluationDAO evaluationDAO = new EvaluationDAO();
        List<Evaluation> historyList = new ArrayList<>();
        List<Map<String, Object>> trendData = new ArrayList<>();
        Map<String, Double> skillsData = new HashMap<>();
        Evaluation latestEvaluation = null;
        int totalEvaluations = 0;
        
        try {
            latestEvaluation = evaluationDAO.getLatestEvaluationByStudent(studentId);
            System.out.println("StudentEvaluationServlet: latestEvaluation=" + (latestEvaluation != null ? latestEvaluation.getEvaluationId() : "null"));
        } catch (Exception e) {
            System.err.println("StudentEvaluationServlet: Error loading latestEvaluation: " + e.getMessage());
            e.printStackTrace();
        }
        
        try {
            historyList = evaluationDAO.getEvaluationHistory(studentId);
            System.out.println("StudentEvaluationServlet: Loaded " + historyList.size() + " evaluations from database");
        } catch (Exception e) {
            System.err.println("StudentEvaluationServlet: Error loading historyList: " + e.getMessage());
            e.printStackTrace();
        }
        
        try {
            trendData = evaluationDAO.getPerformanceTrend(studentId);
            if (trendData == null) trendData = new ArrayList<>();
        } catch (Exception e) {
            System.err.println("StudentEvaluationServlet: Error loading trendData: " + e.getMessage());
            e.printStackTrace();
        }
        
        try {
            skillsData = evaluationDAO.getSkillsAssessment(studentId);
            if (skillsData == null) skillsData = new HashMap<>();
        } catch (Exception e) {
            System.err.println("StudentEvaluationServlet: Error loading skillsData: " + e.getMessage());
            e.printStackTrace();
        }
        
        try {
            totalEvaluations = evaluationDAO.getTotalEvaluationCount(studentId);
        } catch (Exception e) {
            System.err.println("StudentEvaluationServlet: Error loading totalEvaluations: " + e.getMessage());
            e.printStackTrace();
        }
        
        // Convert to JSON strings for JavaScript
        String trendDataJson = mapToJson(trendData);
        String skillsDataJson = mapToJson(skillsData);
        String historyDataJson = buildEvaluationDataJson(historyList);
        
        // Fetch completed sessions for Evaluate Teacher section
        List<Evaluation> completedSessions = new ArrayList<>();
        try {
            completedSessions = evaluationDAO.getCompletedSessionsForStudent(studentId);
            System.out.println("StudentEvaluationServlet: Loaded " + completedSessions.size() + " completed sessions from database");
        } catch (Exception e) {
            System.err.println("StudentEvaluationServlet: Error loading completed sessions: " + e.getMessage());
            e.printStackTrace();
        }
        
        // Fetch submitted feedback (My Submitted Evaluations section)
        List<Evaluation> submittedList = new ArrayList<>();
        try {
            submittedList = evaluationDAO.getStudentSubmittedFeedback(studentId);
            System.out.println("StudentEvaluationServlet: Loaded " + submittedList.size() + " submitted feedbacks from database");
        } catch (Exception e) {
            System.err.println("StudentEvaluationServlet: Error loading submitted feedbacks: " + e.getMessage());
            e.printStackTrace();
        }
        
        // Set attributes for JSP
        request.setAttribute("studentId", studentId);
        request.setAttribute("studentName", studentName);
        request.setAttribute("latestEvaluation", latestEvaluation);
        request.setAttribute("historyList", historyList);
        request.setAttribute("historyDataJson", historyDataJson);
        request.setAttribute("trendDataJson", trendDataJson);
        request.setAttribute("skillsDataJson", skillsDataJson);
        request.setAttribute("totalEvaluations", totalEvaluations);
        request.setAttribute("completedSessions", completedSessions);
        request.setAttribute("submittedList", submittedList);
        System.out.println("StudentEvaluationServlet: Loaded DATABASE data - Student: " + studentId + ", " + totalEvaluations + " evaluations, " + completedSessions.size() + " completed sessions, " + submittedList.size() + " submitted feedbacks");
        
        // Forward to JSP
        RequestDispatcher rd = request.getRequestDispatcher("/WEB-INF/views/studentEvaluation.jsp");
        rd.forward(request, response);
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        // Check if user is logged in
        if (session == null || session.getAttribute("studentId") == null) {
            response.sendRedirect(request.getContextPath() + "/student/login");
            return;
        }
        
        String action = request.getParameter("action");
        boolean wantsJson = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"));
        
        if ("submitTeacherEvaluation".equals(action)) {
            // Handle teacher evaluation submission
            String studentId = (String) session.getAttribute("studentId");
            String teacherId = request.getParameter("teacherId");
            String sessionId = request.getParameter("sessionId");
            String scheduleId = request.getParameter("scheduleId");
            String ratingStr = request.getParameter("rating");
            String comments = request.getParameter("comments");
            String suggestions = request.getParameter("suggestions");
            
            try {
                int rating = Integer.parseInt(ratingStr);
                
                // Call DAO to insert teacher evaluation into database
                EvaluationDAO evaluationDAO = new EvaluationDAO();
                boolean success = evaluationDAO.insertTeacherEvaluation(studentId, teacherId, sessionId, scheduleId, rating, comments, suggestions);
                
                if (success) {
                    dao.NotificationDAO notifDao = new dao.NotificationDAO();
                    notifDao.createNotification(
                        studentId, "student",
                        dao.NotificationDAO.TITLE_EVALUATION_SUBMITTED,
                        "Teacher evaluation submitted successfully",
                        sessionId, scheduleId);
                    notifDao.notifyTeacherOfStudentEvaluation(teacherId, studentId, sessionId);

                    System.out.println("StudentEvaluationServlet: Successfully saved teacher evaluation to database");
                    System.out.println("  Student: " + studentId);
                    System.out.println("  Teacher: " + teacherId);
                    System.out.println("  Rating: " + rating);
                    if (wantsJson) {
                        List<Evaluation> submittedList = evaluationDAO.getStudentSubmittedFeedback(studentId);
                        Evaluation submitted = submittedList.isEmpty() ? null : submittedList.get(0);

                        response.setContentType("application/json");
                        response.setCharacterEncoding("UTF-8");
                        StringBuilder json = new StringBuilder("{");
                        json.append("\"success\":true");
                        if (submitted != null) {
                            json.append(",\"feedbackId\":\"").append(escapeJson(submitted.getFeedbackId())).append("\"");
                            json.append(",\"teacherName\":\"").append(escapeJson(submitted.getTeacherName())).append("\"");
                            json.append(",\"rating\":").append(submitted.getRating());
                            json.append(",\"comments\":\"").append(escapeJson(submitted.getComments())).append("\"");
                            json.append(",\"suggestions\":\"").append(escapeJson(submitted.getSuggestions())).append("\"");
                            json.append(",\"createdAt\":\"").append(escapeJson(submitted.getCreatedAt())).append("\"");
                            json.append(",\"sessionDate\":\"").append(escapeJson(submitted.getSessionDate())).append("\"");
                            json.append(",\"startTime\":\"").append(escapeJson(submitted.getStartTime())).append("\"");
                            json.append(",\"endTime\":\"").append(escapeJson(submitted.getEndTime())).append("\"");
                            json.append(",\"surahName\":\"").append(escapeJson(submitted.getSurahName())).append("\"");
                            json.append(",\"ayahRange\":\"").append(escapeJson(submitted.getAyahRange())).append("\"");
                        }
                        json.append("}");
                        response.getWriter().write(json.toString());
                    } else {
                        response.sendRedirect(request.getContextPath() + "/student/evaluation?success=evaluated");
                    }
                } else {
                    System.out.println("StudentEvaluationServlet: Failed to save teacher evaluation");
                    if (wantsJson) {
                        response.setContentType("application/json");
                        response.setCharacterEncoding("UTF-8");
                        response.getWriter().write("{\"success\":false,\"error\":\"submitFailed\"}");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/student/evaluation?error=submitFailed");
                    }
                }
            } catch (Exception e) {
                System.out.println("StudentEvaluationServlet: Error submitting evaluation: " + e.getMessage());
                e.printStackTrace();
                // Redirect back to evaluation page with error
                if (wantsJson) {
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    response.getWriter().write("{\"success\":false,\"error\":\"submitFailed\"}");
                } else {
                    response.sendRedirect(request.getContextPath() + "/student/evaluation?error=submitFailed");
                }
            }
        } else if ("updateTeacherEvaluation".equals(action)) {
            // Handle teacher evaluation update
            String feedbackId = request.getParameter("feedbackId");
            String ratingStr = request.getParameter("rating");
            String comments = request.getParameter("comments");
            String suggestions = request.getParameter("suggestions");
            
            try {
                int rating = Integer.parseInt(ratingStr);
                
                // Call DAO to update teacher evaluation
                EvaluationDAO evaluationDAO = new EvaluationDAO();
                boolean success = evaluationDAO.updateTeacherEvaluation(feedbackId, rating, comments, suggestions);
                
                if (success) {
                    System.out.println("StudentEvaluationServlet: Successfully updated teacher evaluation in database");
                    System.out.println("  Feedback ID: " + feedbackId);
                    System.out.println("  Rating: " + rating);
                    response.sendRedirect(request.getContextPath() + "/student/evaluation?success=updated");
                } else {
                    System.out.println("StudentEvaluationServlet: Failed to update teacher evaluation");
                    response.sendRedirect(request.getContextPath() + "/student/evaluation?error=updateFailed");
                }
            } catch (Exception e) {
                System.out.println("StudentEvaluationServlet: Error updating evaluation: " + e.getMessage());
                e.printStackTrace();
                // Redirect back to evaluation page with error
                response.sendRedirect(request.getContextPath() + "/student/evaluation?error=updateFailed");
            }
        } else {
            // Default: call doGet
            doGet(request, response);
        }
    }
}
