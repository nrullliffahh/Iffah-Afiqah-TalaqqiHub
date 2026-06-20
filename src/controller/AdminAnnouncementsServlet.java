package controller;

import dao.AnnouncementDAO;
import model.Announcement;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

public class AdminAnnouncementsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        String adminName = (String) session.getAttribute("adminName");
        if (adminName == null || adminName.trim().isEmpty()) {
            adminName = "Admin Manager";
        }

        AnnouncementDAO dao = new AnnouncementDAO();
        List<Announcement> announcements = dao.getAllAnnouncements();

        String message = request.getParameter("message");
        String error = request.getParameter("error");
        if (message != null) request.setAttribute("flashMessage", message);
        if (error != null) request.setAttribute("flashError", error);

        request.setAttribute("adminName", adminName);
        request.setAttribute("announcements", announcements);
        request.setAttribute("announcementCount", announcements.size());

        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/views/adminAnnouncements.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        String action = request.getParameter("action");
        AnnouncementDAO dao = new AnnouncementDAO();
        String redirect = request.getContextPath() + "/admin/announcements";

        if ("create".equals(action)) {
            Announcement announcement = buildFromRequest(request);
            String newId = dao.createAdminAnnouncement(announcement);
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

            Announcement announcement = buildFromRequest(request);
            announcement.setAnnouncementId(announcementId.trim());

            if (dao.updateAnnouncementByAdmin(announcement)) {
                response.sendRedirect(redirect + "?message=Announcement+updated+successfully");
            } else {
                response.sendRedirect(redirect + "?error=You+can+only+edit+announcements+created+by+admin");
            }
            return;
        }

        if ("delete".equals(action)) {
            String announcementId = request.getParameter("announcementId");
            if (announcementId == null || announcementId.trim().isEmpty()) {
                response.sendRedirect(redirect + "?error=Invalid+announcement");
                return;
            }

            if (dao.deleteAnnouncementByAdmin(announcementId.trim())) {
                response.sendRedirect(redirect + "?message=Announcement+deleted+successfully");
            } else {
                response.sendRedirect(redirect + "?error=You+can+only+delete+announcements+created+by+admin");
            }
            return;
        }

        response.sendRedirect(redirect);
    }

    private Announcement buildFromRequest(HttpServletRequest request) {
        Announcement announcement = new Announcement();
        announcement.setTitle(trim(request.getParameter("title")));
        announcement.setDescription(trim(request.getParameter("description")));
        announcement.setCategory(trim(request.getParameter("category")));
        announcement.setTargetAudience(trim(request.getParameter("targetAudience")));
        announcement.setAuthor("Talaqqi Admin");
        announcement.setStatus("published");
        return announcement;
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
