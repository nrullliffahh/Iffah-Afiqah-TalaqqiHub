package controller;

import dao.TeacherDAO;
import model.Teacher;
import util.SessionRoleUtil;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class TeacherLoginServlet extends HttpServlet {
    private TeacherDAO teacherDAO;

    @Override
    public void init() {
        teacherDAO = new TeacherDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/teacherLogin.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        Teacher teacher = teacherDAO.authenticateTeacher(email, password);

        if (teacher != null) {
            HttpSession session = request.getSession();
            SessionRoleUtil.bindTeacher(session, teacher.getTeacherId(), teacher.getFullName(), teacher.getEmail());
            response.sendRedirect(request.getContextPath() + "/teacher/teacherdashboard");
        } else {
            request.setAttribute("errorMessage", "Invalid email or password");
            request.getRequestDispatcher("/WEB-INF/views/teacherLogin.jsp").forward(request, response);
        }
    }
}
