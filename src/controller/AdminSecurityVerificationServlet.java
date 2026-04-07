package controller;

import dao.AdminDAO;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class AdminSecurityVerificationServlet extends HttpServlet {
    private AdminDAO adminDAO;

    @Override
    public void init() {
        adminDAO = new AdminDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("adminResetEmail");

        if (email == null) {
            response.sendRedirect(request.getContextPath() + "/admin/forgot-password");
            return;
        }

        String securityQuestion = adminDAO.getSecurityQuestionByEmail(email);
        request.setAttribute("email", email);
        request.setAttribute("securityQuestion", securityQuestion);
        
        request.getRequestDispatcher("/WEB-INF/views/adminSecurityVerification.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("adminResetEmail");

        if (email == null) {
            response.sendRedirect(request.getContextPath() + "/admin/forgot-password");
            return;
        }

        String answer = request.getParameter("answer");

        if (adminDAO.verifySecurityAnswer(email, answer)) {
            session.setAttribute("adminVerified", true);
            response.sendRedirect(request.getContextPath() + "/admin/reset-password");
        } else {
            String securityQuestion = adminDAO.getSecurityQuestionByEmail(email);
            request.setAttribute("email", email);
            request.setAttribute("securityQuestion", securityQuestion);
            request.setAttribute("errorMessage", "Incorrect security answer");
            request.getRequestDispatcher("/WEB-INF/views/adminSecurityVerification.jsp").forward(request, response);
        }
    }
}
