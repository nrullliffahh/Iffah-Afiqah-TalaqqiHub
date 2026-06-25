package controller;

import dao.StudentDAO;
import model.Student;
import util.SessionRoleUtil;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class StudentLoginServlet extends HttpServlet {

    private StudentDAO studentDAO;

    @Override
    public void init() {
        studentDAO = new StudentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/studentLogin.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String rememberMe = request.getParameter("rememberMe");
        
        Student student = studentDAO.authenticateStudent(email, password);
        
        if (student != null) {
            HttpSession session = request.getSession();
            SessionRoleUtil.bindStudent(session, student, student.getStudentId(), student.getName());
            response.sendRedirect(request.getContextPath() + "/student/dashboard");
        } else if (!util.DBConnection.canConnect()) {
            request.setAttribute("errorMessage",
                "Database is unavailable. Ask admin to check Kerocket DB settings and import db/talaqqihub_backup.sql.");
            request.getRequestDispatcher("/WEB-INF/views/studentLogin.jsp").forward(request, response);
        } else {
            request.setAttribute("errorMessage", "Invalid email or password. Please try again.");
            request.getRequestDispatcher("/WEB-INF/views/studentLogin.jsp").forward(request, response);
        }
    }
}
