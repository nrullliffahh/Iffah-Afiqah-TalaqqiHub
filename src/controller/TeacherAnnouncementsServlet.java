package controller;

import dao.AnnouncementDAO;
import dao.TeacherAttendanceDAO;
import model.Announcement;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class TeacherAnnouncementsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("teacherId") == null) {
            response.sendRedirect(request.getContextPath() + "/teacher/login");
            return;
        }

        String teacherId = (String) session.getAttribute("teacherId");
        String teacherName = (String) session.getAttribute("teacherName");
        if (teacherName == null || teacherName.trim().isEmpty()) {
            teacherName = "Teacher";
        }

        AnnouncementDAO dao = new AnnouncementDAO();
        List<Announcement> announcements = dao.getTeacherAnnouncements(teacherId, teacherName);

        TeacherAttendanceDAO attendanceDAO = new TeacherAttendanceDAO();
        List<String> students = attendanceDAO.getDistinctStudentNamesByTeacher(teacherId);
        if (students == null || students.isEmpty()) {
            students = new ArrayList<>();
        }

        String message = request.getParameter("message");
        String error = request.getParameter("error");
        if (message != null) request.setAttribute("flashMessage", message);
        if (error != null) request.setAttribute("flashError", error);

        request.setAttribute("teacherName", teacherName);
        request.setAttribute("announcements", announcements);
        request.setAttribute("announcementCount", announcements.size());
        request.setAttribute("students", students);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/views/teacherAnnouncements.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("teacherId") == null) {
            response.sendRedirect(request.getContextPath() + "/teacher/login");
            return;
        }

        String teacherId = (String) session.getAttribute("teacherId");
        String teacherName = (String) session.getAttribute("teacherName");
        if (teacherName == null || teacherName.trim().isEmpty()) {
            teacherName = "Teacher";
        }

        String action = request.getParameter("action");
        AnnouncementDAO dao = new AnnouncementDAO();
        String redirect = request.getContextPath() + "/teacher/announcements";

        if ("create".equals(action)) {
            Announcement announcement = buildFromRequest(request, teacherName);
            String newId = dao.createAnnouncement(announcement, teacherId);
            if (newId != null) {
                response.sendRedirect(redirect + "?message=Announcement+created+successfully");
            } else {
                response.sendRedirect(redirect + "?error=Failed+to+create+announcement");
            }
            return;
        }

        if ("update".equals(action)) {
            String announcementId = request.getParameter("announcementId");
            if (announcementId == null || announcementId.trim().isEmpty()) {
                response.sendRedirect(redirect + "?error=Invalid+announcement");
                return;
            }

            Announcement announcement = buildFromRequest(request, teacherName);
            announcement.setAnnouncementId(announcementId.trim());

            if (dao.updateAnnouncement(announcement, teacherId)) {
                response.sendRedirect(redirect + "?message=Announcement+updated+successfully");
            } else {
                response.sendRedirect(redirect + "?error=Failed+to+update+announcement");
            }
            return;
        }

        if ("delete".equals(action)) {
            String announcementId = request.getParameter("announcementId");
            if (announcementId == null || announcementId.trim().isEmpty()) {
                response.sendRedirect(redirect + "?error=Invalid+announcement");
                return;
            }

            if (dao.deleteAnnouncement(announcementId.trim(), teacherId)) {
                response.sendRedirect(redirect + "?message=Announcement+deleted+successfully");
            } else {
                response.sendRedirect(redirect + "?error=Failed+to+delete+announcement");
            }
            return;
        }

        response.sendRedirect(redirect);
    }

    private Announcement buildFromRequest(HttpServletRequest request, String teacherName) {
        Announcement announcement = new Announcement();
        announcement.setTitle(trim(request.getParameter("title")));
        announcement.setDescription(trim(request.getParameter("description")));
        announcement.setCategory(trim(request.getParameter("category")));
        announcement.setTargetAudience(trim(request.getParameter("targetAudience")));
        announcement.setAuthor(teacherName);
        announcement.setStatus("published");
        return announcement;
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
