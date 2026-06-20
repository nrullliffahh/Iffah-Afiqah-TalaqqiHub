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

public class StudentAnnouncementsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentId") == null) {
            response.sendRedirect(request.getContextPath() + "/student/login");
            return;
        }

        String studentId = (String) session.getAttribute("studentId");
        String studentName = (String) session.getAttribute("studentName");
        if (studentName == null || studentName.trim().isEmpty()) {
            studentName = "Student";
        }

        AnnouncementDAO dao = new AnnouncementDAO();
        List<Announcement> announcements = dao.getStudentAnnouncements(studentId, studentName);

        request.setAttribute("studentName", studentName);
        request.setAttribute("announcements", announcements);
        request.setAttribute("announcementCount", announcements.size());

        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/views/studentAnnouncements.jsp");
        dispatcher.forward(request, response);
    }
}
