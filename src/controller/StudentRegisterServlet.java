package controller;

import dao.StudentDAO;
import model.Student;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class StudentRegisterServlet extends HttpServlet {

    private StudentDAO studentDAO;

    @Override
    public void init() throws ServletException {
        studentDAO = new StudentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/WEB-INF/views/studentRegister.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phoneNumber = request.getParameter("phoneNumber");
        String dateOfBirth = request.getParameter("dateOfBirth");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String securityQuestion = request.getParameter("securityQuestion");
        String securityAnswer = request.getParameter("securityAnswer");
        String agreeToTerms = request.getParameter("agreeToTerms");

        // Validation
        if (!password.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Passwords do not match!");
            request.getRequestDispatcher("/WEB-INF/views/studentRegister.jsp")
                   .forward(request, response);
            return;
        }

        if (agreeToTerms == null) {
            request.setAttribute("errorMessage", "Please agree to the Terms & Conditions");
            request.getRequestDispatcher("/WEB-INF/views/studentRegister.jsp")
                   .forward(request, response);
            return;
        }

        Student student = new Student();
        student.setFullName(fullName);
        student.setEmail(email);
        student.setPhoneNumber(phoneNumber);
        student.setDateOfBirth(dateOfBirth);
        student.setPassword(password);
        student.setSecurityQuestion(securityQuestion);
        student.setSecurityAnswer(securityAnswer);
        student.setStatus("active");

        boolean success = studentDAO.registerStudent(student);

        if (success) {
            // Load the newly created student and set session so choosePackages can read studentId
            Student created = studentDAO.getStudentByEmail(email);
            if (created != null) {
                util.SessionRoleUtil.bindStudent(
                        request.getSession(), created, created.getStudentId(), created.getStudentName());
            }
            // After successful registration, redirect to the choose packages page
            response.sendRedirect(request.getContextPath() + "/choosePackages");
        } else {
            request.setAttribute("errorMessage", "Registration failed. Please try again.");
            request.getRequestDispatcher("/WEB-INF/views/studentRegister.jsp")
                   .forward(request, response);
        }
    }
}
