package controller;

import dao.StudentAttendanceDAO;
import model.StudentAttendance;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;

public class StudentAttendanceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get student ID from session
        HttpSession session = request.getSession();
        String studentId = "S003"; // Default to student ID S003
        
        try {
            Object studentIdObj = session.getAttribute("studentId");
            if (studentIdObj != null) {
                studentId = studentIdObj.toString();
            }
        } catch (Exception e) {
            // Use default if parsing fails
            studentId = "S003";
        }
        
        // Initialize DAO
        StudentAttendanceDAO dao = new StudentAttendanceDAO();
        
        // Get attendance records
        List<StudentAttendance> records = dao.getAttendanceByStudentByMonth(studentId);
        
        // Get statistics (monthly only)
        int total = dao.getTotalSessionsByMonth(studentId);
        int present = dao.getPresentCountByMonth(studentId);
        int absent = dao.getAbsentCountByMonth(studentId);
        int late = dao.getLateCountByMonth(studentId);
        
        // Calculate attendance rate
        double rate = (total > 0) ? Math.round(((double) present / total) * 100) : 0;
        
        // Get trend data
        Map<String, Integer> trendDetails = dao.getAttendanceTrendDetails(studentId);
        
        // Set request attributes
        request.setAttribute("records", records);
        request.setAttribute("total", total);
        request.setAttribute("present", present);
        request.setAttribute("absent", absent);
        request.setAttribute("late", late);
        request.setAttribute("rate", (int)rate);
        request.setAttribute("trendDetails", trendDetails);
        
        // Forward to JSP
        request.getRequestDispatcher("/WEB-INF/views/studentAttendance.jsp").forward(request, response);
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}
