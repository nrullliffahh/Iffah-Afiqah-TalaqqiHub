package controller;

import dao.TeacherDAO;
import model.Teacher;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class AdminTeacherProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("Unauthorized");
            return;
        }

        String teacherId = request.getParameter("teacherId");
        if (teacherId == null || teacherId.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Missing teacherId");
            return;
        }

        TeacherDAO tdao = new TeacherDAO();
        Teacher t = tdao.getTeacherById(teacherId.trim());
        if (t == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.getWriter().write("Teacher not found");
            return;
        }

        double avgRating = tdao.getAverageRating(teacherId.trim());

        request.setAttribute("teacher", t);
        request.setAttribute("avgRating", avgRating);

        request.getRequestDispatcher("/WEB-INF/views/adminTeacherProfile.jsp").forward(request, response);
    }
}
