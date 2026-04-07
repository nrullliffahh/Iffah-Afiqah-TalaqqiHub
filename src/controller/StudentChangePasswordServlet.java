package controller;

import dao.StudentDAO;
import model.Student;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class StudentChangePasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentId") == null) {
            response.sendRedirect(request.getContextPath() + "/student/login");
            return;
        }

        request.getRequestDispatcher("/WEB-INF/views/studentChangePassword.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentId") == null) {
            response.sendRedirect(request.getContextPath() + "/student/login");
            return;
        }

        String studentId = (String) session.getAttribute("studentId");
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // basic server-side validation
        if (currentPassword == null || newPassword == null || confirmPassword == null) {
            request.setAttribute("error", "Please fill all required fields.");
            doGet(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "New password and confirmation do not match.");
            doGet(request, response);
            return;
        }

        // password policy enforcement
        if (newPassword.length() < 8 || !newPassword.matches(".*[A-Z].*") || !newPassword.matches(".*[a-z].*") || !newPassword.matches(".*\\d.*")) {
            request.setAttribute("error", "Password does not meet requirements: at least 8 chars, upper and lower case, and a number.");
            doGet(request, response);
            return;
        }

        StudentDAO sdao = new StudentDAO();
        Student student = sdao.getStudentById(studentId);
        if (student == null) {
            request.setAttribute("error", "Student not found.");
            doGet(request, response);
            return;
        }

        // verify current password (note: currently compares raw value to match existing system)
        String stored = student.getPassword();
        if (stored == null || !stored.equals(currentPassword)) {
            request.setAttribute("error", "Current password is incorrect.");
            doGet(request, response);
            return;
        }

        boolean updated = sdao.updateStudentPassword(studentId, newPassword);
        if (!updated) {
            request.setAttribute("error", "Unable to update password. Please try again later.");
            doGet(request, response);
            return;
        }

        // success: redirect to profile with message
        session.setAttribute("flash_success", "Password updated successfully.");
        response.sendRedirect(request.getContextPath() + "/student/profile");
    }
}
