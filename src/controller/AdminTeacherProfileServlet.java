package controller;

import dao.TeacherDAO;
import model.Teacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(urlPatterns = {"/admin/teacher-profile"})
public class AdminTeacherProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String teacherId = request.getParameter("teacherId");
        if (teacherId == null || teacherId.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Missing teacherId");
            return;
        }

        TeacherDAO tdao = new TeacherDAO();
        Teacher t = tdao.getTeacherById(teacherId);
        if (t == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.getWriter().write("Teacher not found");
            return;
        }

        int totalStudents = tdao.getTotalStudentsTaught(teacherId);
        double avgRating = tdao.getAverageRating(teacherId);

        request.setAttribute("teacher", t);
        request.setAttribute("totalStudents", totalStudents);
        request.setAttribute("avgRating", avgRating);

        // forward to JSP fragment that renders profile content
        request.getRequestDispatcher("/WEB-INF/views/adminTeacherProfile.jsp").forward(request, response);
    }
}
