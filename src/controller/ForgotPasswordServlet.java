package controller;

import dao.StudentDAO;
import model.Student;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class ForgotPasswordServlet extends HttpServlet {

    private StudentDAO studentDAO;

    @Override
    public void init() {
        studentDAO = new StudentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/studentForgotPassword.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        
        Student student = studentDAO.getSecurityQuestionByEmail(email);
        
        if (student != null) {
            HttpSession session = request.getSession();
            session.setAttribute("resetStudentId", student.getStudentId());
            session.setAttribute("resetEmail", student.getEmail());
            session.setAttribute("securityQuestion", student.getSecurityQuestion());
            
            response.sendRedirect(request.getContextPath() + "/student/security-question");
        } else {
            request.setAttribute("errorMessage", "Email not found");
            request.getRequestDispatcher("/WEB-INF/views/studentForgotPassword.jsp").forward(request, response);
        }
    }
}
