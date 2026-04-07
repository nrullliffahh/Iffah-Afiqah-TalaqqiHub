package controller;

import dao.TeacherDAO;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class TeacherForgotPasswordServlet extends HttpServlet {
    private TeacherDAO teacherDAO;

    @Override
    public void init() {
        teacherDAO = new TeacherDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/teacherForgotPassword.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String email = request.getParameter("email");

        if (teacherDAO.isTeacherEmailExists(email)) {
            HttpSession session = request.getSession();
            session.setAttribute("resetEmail", email);
            response.sendRedirect(request.getContextPath() + "/teacher/security-verification");
        } else {
            request.setAttribute("errorMessage", "Email not found in our system");
            request.getRequestDispatcher("/WEB-INF/views/teacherForgotPassword.jsp").forward(request, response);
        }
    }
}
