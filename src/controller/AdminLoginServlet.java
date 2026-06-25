package controller;

import dao.AdminDAO;
import model.Admin;
import util.SessionRoleUtil;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class AdminLoginServlet extends HttpServlet {
    private AdminDAO adminDAO;

    @Override
    public void init() {
        adminDAO = new AdminDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/adminLogin.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String remember = request.getParameter("remember");

        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Email and password are required");
            request.getRequestDispatcher("/WEB-INF/views/adminLogin.jsp").forward(request, response);
            return;
        }

        Admin admin = adminDAO.loginAdmin(email.trim(), password);

        if (admin != null) {
            HttpSession session = request.getSession();
            SessionRoleUtil.bindAdmin(session, admin.getAdminId(), admin.getAdminName(), admin.getAdminEmail());
            
            if ("on".equals(remember)) {
                session.setMaxInactiveInterval(30 * 24 * 60 * 60); // 30 days
            } else {
                session.setMaxInactiveInterval(30 * 60); // 30 minutes
            }
            
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        } else if (!util.DBConnection.canConnect()) {
            request.setAttribute("errorMessage",
                "Database is unavailable. Check Kerocket DB settings and import db/talaqqihub_backup.sql.");
            request.getRequestDispatcher("/WEB-INF/views/adminLogin.jsp").forward(request, response);
        } else {
            request.setAttribute("errorMessage", "Invalid email or password");
            request.getRequestDispatcher("/WEB-INF/views/adminLogin.jsp").forward(request, response);
        }
    }
}
