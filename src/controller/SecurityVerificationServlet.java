package controller;

import dao.StudentDAO;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class SecurityVerificationServlet extends HttpServlet {

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
        String email = (String) session.getAttribute("resetEmail");
        String securityQuestion = (String) session.getAttribute("securityQuestion");
        
        if (studentId == null || email == null || securityQuestion == null) {
            response.sendRedirect(request.getContextPath() + "/student/forgot-password");
            return;
        }
        
        request.getRequestDispatcher("/WEB-INF/views/securityVerification.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String studentId = (String) session.getAttribute("resetStudentId");
        String answer = request.getParameter("answer");
        
        if (studentId == null) {
            response.sendRedirect(request.getContextPath() + "/student/forgot-password");
            return;
        }
        
        boolean verified = studentDAO.verifySecurityAnswer(studentId, answer);
        
        if (verified) {
            response.sendRedirect(request.getContextPath() + "/student/reset-password");
        } else {
            request.setAttribute("errorMessage", "Incorrect answer");
            request.getRequestDispatcher("/WEB-INF/views/securityVerification.jsp").forward(request, response);
        }
    }
}
