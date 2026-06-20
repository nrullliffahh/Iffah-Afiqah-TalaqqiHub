package controller;

import dao.AiAssistanceDAO;
import model.AiInteraction;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;

public class AdminAiAssistanceServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        AiAssistanceDAO dao = new AiAssistanceDAO();
        Map<String, Object> stats = dao.getAdminStats();
        List<AiInteraction> interactions = dao.getAllInteractionsForAdmin();

        request.setAttribute("adminName", session.getAttribute("adminName"));
        request.setAttribute("totalQuestions", stats.get("total"));
        request.setAttribute("studentQuestions", stats.get("studentCount"));
        request.setAttribute("teacherQuestions", stats.get("teacherCount"));
        request.setAttribute("mostActiveRole", stats.get("mostActiveRole"));
        request.setAttribute("interactions", interactions);

        request.getRequestDispatcher("/WEB-INF/views/adminAiAssistance.jsp").forward(request, response);
    }
}
