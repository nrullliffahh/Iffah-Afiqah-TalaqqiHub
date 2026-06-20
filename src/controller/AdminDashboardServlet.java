package controller;

import dao.StudentDAO;
import dao.TeacherDAO;
import dao.SessionDAO;
import dao.AttendanceDAO;
import dao.EvaluationDAO;
import dao.AnnouncementDAO;
import model.Announcement;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;

public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }
        
        try {
            StudentDAO studentDAO = new StudentDAO();
            TeacherDAO teacherDAO = new TeacherDAO();
            SessionDAO sessionDAO = new SessionDAO();
            AttendanceDAO attendanceDAO = new AttendanceDAO();
            EvaluationDAO evaluationDAO = new EvaluationDAO();
            AnnouncementDAO announcementDAO = new AnnouncementDAO();
            
            int totalActiveStudents = studentDAO.getTotalActiveStudents();
            int totalActiveTeachers = teacherDAO.getTotalActiveTeachers();
            int totalSessions = sessionDAO.getTotalSessionsCount();
            int upcomingSessions = sessionDAO.getUpcomingSessionsCount();
            int completedSessions = sessionDAO.getCompletedSessionsCount();
            int cancelledSessions = sessionDAO.getCancelledSessionsCount();
            
            Map<String, Object> attendanceStats = attendanceDAO.getOverallAttendanceStats();
            int presentCount = attendanceStats.get("present") != null ? (int) attendanceStats.get("present") : 0;
            int absentCount = attendanceStats.get("absent") != null ? (int) attendanceStats.get("absent") : 0;
            int lateCount = attendanceStats.get("late") != null ? (int) attendanceStats.get("late") : 0;
            double attendanceRate = attendanceStats.get("rate") != null ? (double) attendanceStats.get("rate") : 0.0;
            
            Map<String, Object> evaluationStats = evaluationDAO.getAverageRatings();
            double avgTeacherRating = (double) evaluationStats.get("teacherRating");
            double avgStudentPerformance = (double) evaluationStats.get("studentPerformance");
            
            List<Map<String, Object>> recentActivities = sessionDAO.getRecentActivities(5);
            List<Announcement> recentAnnouncements = announcementDAO.getRecentAnnouncements(3);
            
            request.setAttribute("totalActiveStudents", totalActiveStudents);
            request.setAttribute("totalActiveTeachers", totalActiveTeachers);
            request.setAttribute("totalSessions", totalSessions);
            request.setAttribute("upcomingSessions", upcomingSessions);
            request.setAttribute("completedSessions", completedSessions);
            request.setAttribute("cancelledSessions", cancelledSessions);
            
            request.setAttribute("presentCount", presentCount);
            request.setAttribute("absentCount", absentCount);
            request.setAttribute("lateCount", lateCount);
            request.setAttribute("attendanceRate", attendanceRate);
            
            request.setAttribute("avgTeacherRating", avgTeacherRating);
            request.setAttribute("avgStudentPerformance", avgStudentPerformance);
            
            request.setAttribute("recentActivities", recentActivities);
            request.setAttribute("recentAnnouncements", recentAnnouncements);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error loading dashboard data");
        }
        
        request.getRequestDispatcher("/WEB-INF/views/adminDashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}
