package controller;

import dao.TeacherDAO;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class TeacherSecurityVerificationServlet extends HttpServlet {
    private TeacherDAO teacherDAO;

    @Override
    public void init() {
        teacherDAO = new TeacherDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("resetEmail");

        if (email == null) {
            response.sendRedirect(request.getContextPath() + "/teacher/forgot-password");
            return;
        }

        String securityQuestion = teacherDAO.getSecurityQuestionByEmail(email);
        request.setAttribute("email", email);
        request.setAttribute("securityQuestion", securityQuestion);
        
        request.getRequestDispatcher("/WEB-INF/views/teacherSecurityVerification.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("resetEmail");

        if (email == null) {
            response.sendRedirect(request.getContextPath() + "/teacher/forgot-password");
            return;
        }

        String answer = request.getParameter("answer");

        if (teacherDAO.verifySecurityAnswer(email, answer)) {
            session.setAttribute("verified", true);
            response.sendRedirect(request.getContextPath() + "/teacher/reset-password");
        } else {
            String securityQuestion = teacherDAO.getSecurityQuestionByEmail(email);
            request.setAttribute("email", email);
            request.setAttribute("securityQuestion", securityQuestion);
            request.setAttribute("errorMessage", "Incorrect security answer");
            request.getRequestDispatcher("/WEB-INF/views/teacherSecurityVerification.jsp").forward(request, response);
        }
    }
}
