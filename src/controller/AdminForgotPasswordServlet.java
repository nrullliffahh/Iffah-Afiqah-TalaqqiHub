package controller;

import dao.AdminDAO;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class AdminForgotPasswordServlet extends HttpServlet {
    private AdminDAO adminDAO;

    @Override
    public void init() {
        adminDAO = new AdminDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/adminForgotPassword.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String email = request.getParameter("email");

        if (adminDAO.isEmailExists(email)) {
            HttpSession session = request.getSession();
            session.setAttribute("adminResetEmail", email);
            response.sendRedirect(request.getContextPath() + "/admin/security-verification");
        } else {
            request.setAttribute("errorMessage", "Email not found in our system");
            request.getRequestDispatcher("/WEB-INF/views/adminForgotPassword.jsp").forward(request, response);
        }
    }
}
