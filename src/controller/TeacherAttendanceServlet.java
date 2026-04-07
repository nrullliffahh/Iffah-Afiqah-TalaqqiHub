package controller;

import dao.TeacherAttendanceDAO;
import model.Attendance;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

public class TeacherAttendanceServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Get teacher from session
        HttpSession session = request.getSession();
        Object teacherObj = session.getAttribute("teacherId");
        
        if (teacherObj == null) {
            response.sendRedirect(request.getContextPath() + "/teacher/login");
            return;
        }
        
        String teacherId = (String) teacherObj;
        String teacherName = (String) session.getAttribute("teacherName");
        if (teacherName == null) {
            teacherName = "Teacher";
        }
        
        // Initialize DAO
        TeacherAttendanceDAO dao = new TeacherAttendanceDAO();
        
        // Get all records
        List<Attendance> records = dao.getAllByTeacher(teacherId);
        
        // Get statistics
        int totalStudents = dao.getTotalStudents(teacherId);
        int totalSessions = dao.getTotalSessions(teacherId);
        int present = dao.getPresentCount(teacherId);
        int absent = dao.getAbsentCount(teacherId);
        int late = dao.getLateCount(teacherId);
        
        // Calculate attendance rate
        int total = present + absent + late;
        double rate = (total > 0) ? (double) present / total * 100 : 0;
        
        // Get attendance trend
        Map<String, Integer> trend = dao.getAttendanceTrend(teacherId);
        
        // Get weekly attendance breakdown
        Map<String, Map<String, Integer>> weeklyTrend = dao.getWeeklyAttendanceTrend(teacherId);
        
        // Convert to Lists for JSTL
        List<String> weekLabels = new ArrayList<>();
        List<Integer> presentData = new ArrayList<>();
        List<Integer> absentData = new ArrayList<>();
        List<Integer> lateData = new ArrayList<>();
        
        for (Map.Entry<String, Map<String, Integer>> entry : weeklyTrend.entrySet()) {
            weekLabels.add(entry.getKey());
            Map<String, Integer> counts = entry.getValue();
            presentData.add(counts.getOrDefault("Present", 0));
            absentData.add(counts.getOrDefault("Absent", 0));
            lateData.add(counts.getOrDefault("Late", 0));
        }
        
        // Build JSON for debugging
        StringBuilder weekLabelsJson = new StringBuilder("[");
        for (int i = 0; i < weekLabels.size(); i++) {
            if (i > 0) weekLabelsJson.append(",");
            weekLabelsJson.append("'").append(weekLabels.get(i)).append("'");
        }
        weekLabelsJson.append("]");
        
        StringBuilder presentDataJson = new StringBuilder("[");
        for (int i = 0; i < presentData.size(); i++) {
            if (i > 0) presentDataJson.append(",");
            presentDataJson.append(presentData.get(i));
        }
        presentDataJson.append("]");
        
        StringBuilder absentDataJson = new StringBuilder("[");
        for (int i = 0; i < absentData.size(); i++) {
            if (i > 0) absentDataJson.append(",");
            absentDataJson.append(absentData.get(i));
        }
        absentDataJson.append("]");
        
        StringBuilder lateDataJson = new StringBuilder("[");
        for (int i = 0; i < lateData.size(); i++) {
            if (i > 0) lateDataJson.append(",");
            lateDataJson.append(lateData.get(i));
        }
        lateDataJson.append("]");
        
        // Set attributes
        request.setAttribute("records", records);
        request.setAttribute("totalStudents", totalStudents);
        request.setAttribute("totalSessions", totalSessions);
        request.setAttribute("present", present);
        request.setAttribute("absent", absent);
        request.setAttribute("late", late);
        request.setAttribute("rate", String.format("%.0f", rate));
        request.setAttribute("trend", trend);
        request.setAttribute("teacherName", teacherName);
        request.setAttribute("weekLabelsJson", weekLabelsJson.toString());
        request.setAttribute("presentDataJson", presentDataJson.toString());
        request.setAttribute("absentDataJson", absentDataJson.toString());
        request.setAttribute("lateDataJson", lateDataJson.toString());

        
        // Forward to JSP
        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/views/teacherAttendance.jsp");
        dispatcher.forward(request, response);
    }
}
