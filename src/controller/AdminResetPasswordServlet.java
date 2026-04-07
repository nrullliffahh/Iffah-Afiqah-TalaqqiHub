package controller;

import dao.AdminDAO;
import model.Admin;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class AdminResetPasswordServlet extends HttpServlet {
    private AdminDAO adminDAO;

    @Override
    public void init() {
        adminDAO = new AdminDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Boolean verified = (Boolean) session.getAttribute("adminVerified");
        String email = (String) session.getAttribute("adminResetEmail");

        if (verified == null || !verified || email == null) {
            response.sendRedirect(request.getContextPath() + "/admin/forgot-password");
            return;
        }

        request.getRequestDispatcher("/WEB-INF/views/adminResetPassword.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Boolean verified = (Boolean) session.getAttribute("adminVerified");
        String email = (String) session.getAttribute("adminResetEmail");

        if (verified == null || !verified || email == null) {
            response.sendRedirect(request.getContextPath() + "/admin/forgot-password");
            return;
        }

        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Passwords do not match");
            request.getRequestDispatcher("/WEB-INF/views/adminResetPassword.jsp").forward(request, response);
            return;
        }

        if (newPassword.length() < 6) {
            request.setAttribute("errorMessage", "Password must be at least 6 characters long");
            request.getRequestDispatcher("/WEB-INF/views/adminResetPassword.jsp").forward(request, response);
            return;
        }

        boolean success = adminDAO.updatePasswordByEmail(email, newPassword);

        if (success) {
            // Get admin details and set session
            Admin admin = adminDAO.getAdminByEmail(email);
            if (admin != null) {
                session.setAttribute("adminId", admin.getAdminId());
                session.setAttribute("adminEmail", admin.getAdminEmail());
                session.setAttribute("adminName", admin.getAdminName());
                session.setAttribute("userType", "admin");
            }
            
            session.removeAttribute("adminResetEmail");
            session.removeAttribute("adminVerified");
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        } else {
            request.setAttribute("errorMessage", "Failed to reset password. Please try again.");
            request.getRequestDispatcher("/WEB-INF/views/adminResetPassword.jsp").forward(request, response);
        }
    }
}
