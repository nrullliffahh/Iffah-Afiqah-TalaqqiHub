package controller;

import dao.TeacherDAO;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class TeacherResetPasswordServlet extends HttpServlet {
    private TeacherDAO teacherDAO;

    @Override
    public void init() {
        teacherDAO = new TeacherDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Boolean verified = (Boolean) session.getAttribute("verified");
        String email = (String) session.getAttribute("resetEmail");

        if (verified == null || !verified || email == null) {
            response.sendRedirect(request.getContextPath() + "/teacher/forgot-password");
            return;
        }

        request.getRequestDispatcher("/WEB-INF/views/teacherResetPassword.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Boolean verified = (Boolean) session.getAttribute("verified");
        String email = (String) session.getAttribute("resetEmail");

        if (verified == null || !verified || email == null) {
            response.sendRedirect(request.getContextPath() + "/teacher/forgot-password");
            return;
        }

        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Passwords do not match");
            request.getRequestDispatcher("/WEB-INF/views/teacherResetPassword.jsp").forward(request, response);
            return;
        }

        if (newPassword.length() < 6) {
            request.setAttribute("errorMessage", "Password must be at least 6 characters long");
            request.getRequestDispatcher("/WEB-INF/views/teacherResetPassword.jsp").forward(request, response);
            return;
        }

        boolean success = teacherDAO.updateTeacherPassword(email, newPassword);

        if (success) {
            session.removeAttribute("resetEmail");
            session.removeAttribute("verified");
            response.sendRedirect(request.getContextPath() + "/teacher/login?reset=success");
        } else {
            request.setAttribute("errorMessage", "Failed to reset password. Please try again.");
            request.getRequestDispatcher("/WEB-INF/views/teacherResetPassword.jsp").forward(request, response);
        }
    }
}
