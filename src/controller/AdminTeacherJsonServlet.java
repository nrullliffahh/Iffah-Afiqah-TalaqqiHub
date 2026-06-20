package controller;

import dao.TeacherDAO;
import model.Teacher;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

public class AdminTeacherJsonServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        TeacherDAO dao = new TeacherDAO();
        List<Teacher> teachers = dao.getAllTeachers();
        StringBuilder sb = new StringBuilder();
        sb.append('[');
        if (teachers != null) {
            boolean first = true;
            for (Teacher t : teachers) {
                if (!first) sb.append(',');
                first = false;
                String id = t.getTeacherId() != null ? t.getTeacherId().replace("\"", "\\\"") : "";
                String name = t.getFullName() != null ? t.getFullName().replace("\"", "\\\"") : "";
                sb.append('{');
                sb.append("\"id\":\"").append(id).append("\"");
                sb.append(",\"name\":\"").append(name).append("\"");
                sb.append('}');
            }
        }
        sb.append(']');
        resp.getWriter().write(sb.toString());
    }
}
