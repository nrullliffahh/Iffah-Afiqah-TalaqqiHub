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
 * Teacher AI Assistance — page + JSON API (Google Gemini free tier).
 *
 * GET  /teacher/ai-assistance              → chat page
 * GET  /teacher/ai-assistance?action=history → JSON history
 * POST /teacher/ai-assistance (action=ask)   → JSON AI response
 */
public class TeacherAiAssistanceServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\n", "\\n")
                    .replace("\r", "");
    }

    private boolean isLoggedIn(HttpSession session) {
        return session != null && session.getAttribute("teacherId") != null;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isLoggedIn(session)) {
            response.sendRedirect(request.getContextPath() + "/teacher/login");
            return;
        }

        String teacherId = (String) session.getAttribute("teacherId");
        String action = request.getParameter("action");

        if ("history".equals(action)) {
            handleHistory(request, response, teacherId);
            return;
        }

        AiAssistanceDAO dao = new AiAssistanceDAO();
        List<AiAssistance> history = dao.getHistoryByTeacher(teacherId, 20);
        int historyCount = dao.getCountByTeacher(teacherId);

        request.setAttribute("teacherId", teacherId);
        request.setAttribute("teacherName", session.getAttribute("teacherName"));
        request.setAttribute("historyList", history);
        request.setAttribute("historyCount", historyCount);

        RequestDispatcher rd = request.getRequestDispatcher("/WEB-INF/views/teacherAiAssistance.jsp");
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

        String teacherId = (String) session.getAttribute("teacherId");
        String action = request.getParameter("action");

        if ("ask".equals(action)) {
            handleAsk(request, response, teacherId);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/teacher/ai-assistance");
    }

    private void handleAsk(HttpServletRequest request, HttpServletResponse response, String teacherId)
            throws IOException {

        String question = request.getParameter("question");
        if (question == null || question.trim().isEmpty()) {
            sendJson(response, HttpServletResponse.SC_BAD_REQUEST,
                    "{\"success\":false,\"error\":\"Please enter a question.\"}");
            return;
        }

        String trimmedQuestion = question.trim();
        Answer result = new AiChatService().resolveForTeacher(trimmedQuestion);

        if (!result.isSuccess()) {
            sendJson(response, HttpServletResponse.SC_BAD_GATEWAY,
                    "{\"success\":false,\"error\":\"" + escapeJson(result.getError()) + "\"}");
            return;
        }

        String answer = result.getMessage();
        boolean fallback = result.isFallback();

        AiAssistanceDAO dao = new AiAssistanceDAO();
        if (answer.length() >= 120) {
            dao.saveForTeacher(teacherId, trimmedQuestion, answer);
        }

        int historyCount = dao.getCountByTeacher(teacherId);

        StringBuilder json = new StringBuilder();
        json.append("{\"success\":true,");
        json.append("\"response\":\"").append(escapeJson(answer)).append("\",");
        json.append("\"fallback\":").append(fallback).append(",");
        json.append("\"historyCount\":").append(historyCount);
        json.append("}");

        sendJson(response, HttpServletResponse.SC_OK, json.toString());
    }

    private void handleHistory(HttpServletRequest request, HttpServletResponse response, String teacherId)
            throws IOException {

        AiAssistanceDAO dao = new AiAssistanceDAO();
        List<AiAssistance> history = dao.getHistoryByTeacher(teacherId, 50);

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
