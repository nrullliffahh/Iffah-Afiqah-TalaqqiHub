package controller;

import dao.AiAssistanceDAO;
import model.AiAssistance;
import util.AiChatService;
import util.AiChatService.Answer;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Student AI Assistance — page + JSON API for Tajweed Q&A (Google Gemini free tier).
 *
 * GET  /student/ai-assistance              → chat page
 * GET  /student/ai-assistance?action=history → JSON history
 * POST /student/ai-assistance (action=ask)   → JSON AI response
 */
public class StudentAiAssistanceServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\n", "\\n")
                    .replace("\r", "");
    }

    private boolean isLoggedIn(HttpSession session) {
        return session != null && session.getAttribute("studentId") != null;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isLoggedIn(session)) {
            response.sendRedirect(request.getContextPath() + "/student/login");
            return;
        }

        String studentId = (String) session.getAttribute("studentId");
        String action = request.getParameter("action");

        if ("history".equals(action)) {
            handleHistory(request, response, studentId);
            return;
        }

        AiAssistanceDAO dao = new AiAssistanceDAO();
        List<AiAssistance> history = dao.getHistoryByStudent(studentId, 20);
        int historyCount = dao.getCountByStudent(studentId);

        request.setAttribute("studentId", studentId);
        request.setAttribute("studentName", session.getAttribute("studentName"));
        request.setAttribute("historyList", history);
        request.setAttribute("historyCount", historyCount);

        RequestDispatcher rd = request.getRequestDispatcher("/WEB-INF/views/studentAiAssistance.jsp");
        rd.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isLoggedIn(session)) {
            sendJson(response, HttpServletResponse.SC_UNAUTHORIZED,
                    "{\"success\":false,\"error\":\"Unauthorized\"}");
            return;
        }

        String studentId = (String) session.getAttribute("studentId");
        String action = request.getParameter("action");

        if ("ask".equals(action)) {
            handleAsk(request, response, studentId);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/student/ai-assistance");
    }

    private void handleAsk(HttpServletRequest request, HttpServletResponse response, String studentId)
            throws IOException {

        String question = request.getParameter("question");
        if (question == null || question.trim().isEmpty()) {
            sendJson(response, HttpServletResponse.SC_BAD_REQUEST,
                    "{\"success\":false,\"error\":\"Please enter a question.\"}");
            return;
        }

        String trimmedQuestion = question.trim();
        Answer result = new AiChatService().resolve(trimmedQuestion);

        if (!result.isSuccess()) {
            sendJson(response, HttpServletResponse.SC_BAD_GATEWAY,
                    "{\"success\":false,\"error\":\"" + escapeJson(result.getError()) + "\"}");
            return;
        }

        String answer = result.getMessage();
        boolean fallback = result.isFallback();

        AiAssistanceDAO dao = new AiAssistanceDAO();
        if (answer.length() >= 120) {
            dao.save(studentId, trimmedQuestion, answer);
        }

        int historyCount = dao.getCountByStudent(studentId);

        StringBuilder json = new StringBuilder();
        json.append("{\"success\":true,");
        json.append("\"response\":\"").append(escapeJson(answer)).append("\",");
        json.append("\"fallback\":").append(fallback).append(",");
        json.append("\"historyCount\":").append(historyCount);
        json.append("}");

        sendJson(response, HttpServletResponse.SC_OK, json.toString());
    }

    private void handleHistory(HttpServletRequest request, HttpServletResponse response, String studentId)
            throws IOException {

        AiAssistanceDAO dao = new AiAssistanceDAO();
        List<AiAssistance> history = dao.getHistoryByStudent(studentId, 50);

        StringBuilder json = new StringBuilder("{\"success\":true,\"history\":[");
        for (int i = 0; i < history.size(); i++) {
            AiAssistance item = history.get(i);
            if (i > 0) json.append(",");
            json.append("{");
            json.append("\"aiId\":\"").append(escapeJson(item.getAiId())).append("\",");
            json.append("\"question\":\"").append(escapeJson(item.getAiQuestion())).append("\",");
            json.append("\"response\":\"").append(escapeJson(item.getAiResponse())).append("\"");
            json.append("}");
        }
        json.append("]}");

        sendJson(response, HttpServletResponse.SC_OK, json.toString());
    }

    private void sendJson(HttpServletResponse response, int status, String body) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(body);
    }
}
