package controller;

import dao.TeacherDAO;
import dao.EvaluationDAO;
import dao.SessionDAO;
import model.Teacher;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Time;
import java.text.SimpleDateFormat;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * TeacherDashboardServlet
 * 
 * Handles teacher dashboard display with statistics and upcoming classes.
 * Requires teacher to be authenticated (teacherId in session).
 * 
 * MVC Flow:
 * 1. Check authentication
 * 2. Fetch dashboard data via DAOs
 * 3. Forward to dashboard.jsp
 */
public class TeacherDashboardServlet extends HttpServlet {
    
    private TeacherDAO teacherDAO;
    private EvaluationDAO evaluationDAO;
    private SessionDAO sessionDAO;
    
    @Override
    public void init() throws ServletException {
        teacherDAO = new TeacherDAO();
        evaluationDAO = new EvaluationDAO();
        sessionDAO = new SessionDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check authentication
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("teacherId") == null) {
            response.sendRedirect(request.getContextPath() + "/teacher/login");
            return;
        }
        
        String teacherId = (String) session.getAttribute("teacherId");
        
        try {
            // Fetch teacher information
            Teacher teacher = teacherDAO.getTeacherById(teacherId);
            
            if (teacher == null) {
                response.sendRedirect(request.getContextPath() + "/teacher/login");
                return;
            }
            
            // Fetch statistics
            int classesThisWeek = teacherDAO.getClassesThisWeekCount(teacherId);
            int totalStudents = teacherDAO.getTotalStudentsTaught(teacherId);
            int pendingEvaluations = evaluationDAO.getPendingEvaluationsCount(teacherId);
            double averageRating = teacherDAO.getAverageRating(teacherId);
            
            // Fetch upcoming classes (limit to 5)
            List<Map<String, Object>> upcomingClasses = sessionDAO.getUpcomingClasses(teacherId, 5);
            
            // Fetch recent feedback (limit to 3)
            List<Map<String, Object>> recentFeedback = evaluationDAO.getRecentFeedback(teacherId, 3);
            
            // Get next class for countdown
            Map<String, Object> nextClass = sessionDAO.getNextClass(teacherId);
            String nextClassCountdown = "No upcoming classes";
            
            if (nextClass != null && nextClass.get("scheduleDate") != null && nextClass.get("startTime") != null) {
                nextClassCountdown = calculateTimeUntilClass(
                    (java.sql.Date) nextClass.get("scheduleDate"),
                    (java.sql.Time) nextClass.get("startTime")
                );
            }
            
            // Format joined date
            String joinedDate = "N/A";
            if (teacher.getDateOfBirth() != null) {
                SimpleDateFormat sdf = new SimpleDateFormat("MMMM yyyy");
                joinedDate = sdf.format(java.sql.Date.valueOf(teacher.getDateOfBirth()));
            }
            
            // Set attributes for JSP
            request.setAttribute("teacher", teacher);
            request.setAttribute("teacherName", teacher.getFullName());
            request.setAttribute("teacherCode", teacherId);
            request.setAttribute("specialization", teacher.getSpecialty() != null ? teacher.getSpecialty() : "N/A");
            request.setAttribute("joinedDate", joinedDate);
            request.setAttribute("nextClassCountdown", nextClassCountdown);
            
            request.setAttribute("classesThisWeek", classesThisWeek);
            request.setAttribute("totalStudents", totalStudents);
            request.setAttribute("pendingEvaluations", pendingEvaluations);
            request.setAttribute("averageRating", String.format("%.1f", averageRating));
            
            request.setAttribute("upcomingClasses", upcomingClasses);
            request.setAttribute("recentFeedback", recentFeedback);
            
            // Forward to dashboard JSP
            request.getRequestDispatcher("/WEB-INF/views/teacherdashboard.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                "Error loading dashboard: " + e.getMessage());
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
    
    /**
     * Calculate time remaining until the next class
     */
    private String calculateTimeUntilClass(java.sql.Date scheduleDate, java.sql.Time startTime) {
        try {
            // Combine date and time
            LocalDateTime classDateTime = LocalDateTime.of(
                scheduleDate.toLocalDate(),
                startTime.toLocalTime()
            );
            
            LocalDateTime now = LocalDateTime.now();
            Duration duration = Duration.between(now, classDateTime);
            
            if (duration.isNegative()) {
                return "Class starting soon";
            }
            
            long hours = duration.toHours();
            long minutes = duration.toMinutes() % 60;
            
            if (hours > 24) {
                long days = hours / 24;
                hours = hours % 24;
                return String.format("%d days %d hours", days, hours);
            } else if (hours > 0) {
                return String.format("%d hours %d min", hours, minutes);
            } else {
                return String.format("%d min", minutes);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            return "N/A";
        }
    }
}
