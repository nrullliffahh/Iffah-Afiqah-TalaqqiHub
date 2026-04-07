package controller;

import dao.TalaqqiSessionDAO;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;

public class AdminTalaqqiSessionServlet extends HttpServlet {
    
    private TalaqqiSessionDAO talaqqiSessionDAO;

    @Override
    public void init() {
        talaqqiSessionDAO = new TalaqqiSessionDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check if user is authenticated
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        try {
            // Check if viewing a specific session
            String viewId = request.getParameter("viewId");
            if (viewId != null && !viewId.trim().isEmpty()) {
                java.util.Map<String, Object> selectedSession = talaqqiSessionDAO.getSessionById(viewId);
                request.setAttribute("selectedSession", selectedSession);
            }
            
            // Fetch all talaqqi sessions
            List<java.util.Map<String, Object>> sessions = talaqqiSessionDAO.getAllSessions();
            
            // Fetch all teachers for filter dropdown
            List<String> teachers = talaqqiSessionDAO.getAllTeachers();
            
            // Fetch statistics
            int completedSessionsCount = talaqqiSessionDAO.getCompletedSessionsCount();
            int activeTeachersCount = talaqqiSessionDAO.getActiveTeachersCount();
            int activeStudentsCount = talaqqiSessionDAO.getActiveStudentsCount();

            // Set request attributes
            request.setAttribute("sessions", sessions);
            request.setAttribute("teachers", teachers);
            request.setAttribute("completedSessionsCount", completedSessionsCount);
            request.setAttribute("activeTeachersCount", activeTeachersCount);
            request.setAttribute("activeStudentsCount", activeStudentsCount);
            
            // Forward to JSP
            request.getRequestDispatcher("/WEB-INF/views/adminTalaqqiSession.jsp")
                   .forward(request, response);
                   
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                              "Error loading Talaqqi sessions");
        }
    }
}
