package controller;

import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Teacher;

public class AdminManageTeachersServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        String search = trim(request.getParameter("search"));
        String statusFilter = trim(request.getParameter("status"));
        String regFrom = trim(request.getParameter("regFrom"));

        dao.TeacherDAO tdao = new dao.TeacherDAO();
        List<Teacher> allTeachers = tdao.getAllTeachers();
        List<Teacher> teachers = filterTeachers(allTeachers, search, statusFilter, regFrom);

        int approved = 0;
        int pending = 0;
        int rejected = 0;
        for (Teacher t : allTeachers) {
            String s = t.getStatus() != null ? t.getStatus() : "";
            switch (s.toLowerCase()) {
                case "approved": approved++; break;
                case "pending": pending++; break;
                case "rejected": rejected++; break;
                default: pending++; break;
            }
        }

        Object flashMessage = session.getAttribute("adminFlashMessage");
        Object flashType = session.getAttribute("adminFlashType");
        if (flashMessage != null) {
            request.setAttribute("flashMessage", flashMessage);
            request.setAttribute("flashType", flashType != null ? flashType : "success");
            session.removeAttribute("adminFlashMessage");
            session.removeAttribute("adminFlashType");
        }

        request.setAttribute("teachers", teachers);
        request.setAttribute("totalTeachers", allTeachers.size());
        request.setAttribute("displayCount", teachers.size());
        request.setAttribute("approvedTeachers", approved);
        request.setAttribute("pendingTeachers", pending);
        request.setAttribute("rejectedTeachers", rejected);
        request.setAttribute("filterSearch", search);
        request.setAttribute("filterStatus", statusFilter);
        request.setAttribute("filterRegFrom", regFrom);

        request.getRequestDispatcher("/WEB-INF/views/adminManageTeachers.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        String teacherId = trim(request.getParameter("teacherId"));
        String action = trim(request.getParameter("action"));
        if (teacherId != null && action != null) {
            dao.TeacherDAO tdao = new dao.TeacherDAO();
            String status = null;
            if ("approve".equalsIgnoreCase(action)) {
                status = "Approved";
            } else if ("reject".equalsIgnoreCase(action)) {
                status = "Rejected";
            }

            if (status != null) {
                boolean success = tdao.updateTeacherStatus(teacherId, status);
                if (success) {
                    session.setAttribute("adminFlashMessage", "Teacher " + action.toLowerCase() + "d successfully.");
                    session.setAttribute("adminFlashType", "success");
                } else {
                    session.setAttribute("adminFlashMessage", "Failed to update teacher status. Check database connection and approvalStatus column.");
                    session.setAttribute("adminFlashType", "error");
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/manage-teachers");
    }

    private List<Teacher> filterTeachers(List<Teacher> teachers, String search, String statusFilter, String regFrom) {
        List<Teacher> filtered = new ArrayList<>();
        if (teachers == null) {
            return filtered;
        }

        LocalDate fromDate = null;
        if (regFrom != null && !regFrom.isEmpty()) {
            try {
                fromDate = LocalDate.parse(regFrom);
            } catch (Exception ignored) {}
        }

        for (Teacher t : teachers) {
            if (statusFilter != null && !statusFilter.isEmpty()) {
                String status = t.getStatus() != null ? t.getStatus() : "Pending";
                if (!statusFilter.equalsIgnoreCase(status)) {
                    continue;
                }
            }

            if (fromDate != null) {
                if (t.getDateOfBirth() == null || t.getDateOfBirth().isBefore(fromDate)) {
                    continue;
                }
            }

            if (search != null && !search.isEmpty()) {
                String needle = search.toLowerCase();
                String name = t.getFullName() != null ? t.getFullName().toLowerCase() : "";
                String email = t.getEmail() != null ? t.getEmail().toLowerCase() : "";
                if (!name.contains(needle) && !email.contains(needle)) {
                    continue;
                }
            }

            filtered.add(t);
        }

        return filtered;
    }

    private String trim(String value) {
        return value != null ? value.trim() : "";
    }
}
