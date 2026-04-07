package controller;

import dao.StudentDAO;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class ResetPasswordServlet extends HttpServlet {

    private StudentDAO studentDAO;

    @Override
    public void init() {
        studentDAO = new StudentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String studentId = (String) session.getAttribute("resetStudentId");
        
        if (studentId == null) {
            response.sendRedirect(request.getContextPath() + "/student/login");
            return;
        }
        
        request.getRequestDispatcher("/WEB-INF/views/studentResetPassword.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String studentId = (String) session.getAttribute("resetStudentId");
        
        if (studentId == null) {
            response.sendRedirect(request.getContextPath() + "/student/login");
            return;
        }
        
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        
        if (newPassword == null || newPassword.length() < 8) {
            request.setAttribute("errorMessage", "Password must be at least 8 characters long");
            request.getRequestDispatcher("/WEB-INF/views/studentResetPassword.jsp").forward(request, response);
            return;
        }
        
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Passwords do not match");
            request.getRequestDispatcher("/WEB-INF/views/studentResetPassword.jsp").forward(request, response);
            return;
        }
        
        boolean updated = studentDAO.updateStudentPassword(studentId, newPassword);
        
        if (updated) {
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/student/login?reset=success");
        } else {
            request.setAttribute("errorMessage", "Failed to reset password. Please try again.");
            request.getRequestDispatcher("/WEB-INF/views/studentResetPassword.jsp").forward(request, response);
        }
    }
}
