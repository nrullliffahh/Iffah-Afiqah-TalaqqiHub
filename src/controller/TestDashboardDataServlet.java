package controller;

import dao.StudentDAO;
import dao.TeacherDAO;
import dao.SessionDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/testDashboardData")
public class TestDashboardDataServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        out.println("<html><body>");
        out.println("<h1>Dashboard Data Test</h1>");
        
        try {
            StudentDAO studentDAO = new StudentDAO();
            int totalStudents = studentDAO.getTotalActiveStudents();
            out.println("<p>Total Active Students: " + totalStudents + "</p>");
            
            TeacherDAO teacherDAO = new TeacherDAO();
            int totalTeachers = teacherDAO.getTotalActiveTeachers();
            out.println("<p>Total Active Teachers: " + totalTeachers + "</p>");
            
            SessionDAO sessionDAO = new SessionDAO();
            int totalSessions = sessionDAO.getTotalSessionsCount();
            out.println("<p>Total Sessions: " + totalSessions + "</p>");
            
            int upcomingSessions = sessionDAO.getUpcomingSessionsCount();
            out.println("<p>Upcoming Sessions: " + upcomingSessions + "</p>");
            
            int completedSessions = sessionDAO.getCompletedSessionsCount();
            out.println("<p>Completed Sessions: " + completedSessions + "</p>");
            
            int cancelledSessions = sessionDAO.getCancelledSessionsCount();
            out.println("<p>Cancelled Sessions: " + cancelledSessions + "</p>");
            
            out.println("<p style='color: green;'><b>SUCCESS - All data retrieved!</b></p>");
            
        } catch (Exception e) {
            out.println("<p style='color: red;'><b>ERROR:</b> " + e.getMessage() + "</p>");
            out.println("<pre>");
            e.printStackTrace(out);
            out.println("</pre>");
        }
        
        out.println("</body></html>");
    }
}
