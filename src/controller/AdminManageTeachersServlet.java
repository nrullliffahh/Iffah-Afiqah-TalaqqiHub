package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class AdminManageTeachersServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }
        
        // fetch teachers from DB and compute counts
        dao.TeacherDAO tdao = new dao.TeacherDAO();
        java.util.List<model.Teacher> teachers = tdao.getAllTeachers();

        int totalTeachers = teachers != null ? teachers.size() : 0;
        int approved = 0;
        int pending = 0;
        int rejected = 0;

        if (teachers != null) {
            for (model.Teacher t : teachers) {
                String s = t.getStatus();
                if (s == null) s = "";
                switch (s.toLowerCase()) {
                    case "approved": approved++; break;
                    case "pending": pending++; break;
                    case "rejected": rejected++; break;
                    default: break;
                }
            }
        }

        request.setAttribute("teachers", teachers);
        request.setAttribute("totalTeachers", totalTeachers);
        request.setAttribute("approvedTeachers", approved);
        request.setAttribute("pendingTeachers", pending);
        request.setAttribute("rejectedTeachers", rejected);

        request.getRequestDispatcher("/WEB-INF/views/adminManageTeachers.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        String teacherId = request.getParameter("teacherId");
        String action = request.getParameter("action");
        if (teacherId != null && action != null) {
            dao.TeacherDAO tdao = new dao.TeacherDAO();
            if ("approve".equalsIgnoreCase(action)) {
                tdao.updateTeacherStatus(teacherId, "Approved");
            } else if ("reject".equalsIgnoreCase(action)) {
                tdao.updateTeacherStatus(teacherId, "Rejected");
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/manage-teachers");
    }
}
