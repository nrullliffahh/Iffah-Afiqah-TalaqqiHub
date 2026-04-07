package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import dao.ClassScheduleDAO;
import java.util.List;
import java.util.Map;

public class AdminClassScheduleServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }
        
        // load schedule records from DB for admin
        ClassScheduleDAO dao = new ClassScheduleDAO();
        List<Map<String, Object>> records = dao.getAllSchedulesForAdmin();
        request.setAttribute("classRecords", records);

        // Also compute dashboard counts (live)
        int totalClasses = 0;
        int totalBooked = 0;
        int cancelled = 0;
        int rescheduled = 0;
        java.sql.Connection conn = null;
        try {
            conn = util.DBConnection.getConnection();
            if (conn != null) {
                try (java.sql.Statement st = conn.createStatement()) {
                    try (java.sql.ResultSet rs = st.executeQuery("SELECT COUNT(*) AS cnt FROM classschedule")) { if (rs.next()) totalClasses = rs.getInt("cnt"); }
                    try (java.sql.ResultSet rs = st.executeQuery("SELECT COUNT(*) AS cnt FROM classbooking")) { if (rs.next()) totalBooked = rs.getInt("cnt"); }
                    try (java.sql.ResultSet rs = st.executeQuery("SELECT COUNT(*) AS cnt FROM classbooking WHERE bookingStatus LIKE 'Cancelled' OR bookingStatus LIKE 'cancelled'")) { if (rs.next()) cancelled = rs.getInt("cnt"); }
                    try (java.sql.ResultSet rs = st.executeQuery("SELECT COUNT(*) AS cnt FROM classbooking WHERE bookingStatus LIKE 'Rescheduled' OR bookingStatus LIKE 'reschedule' OR bookingStatus LIKE 'rescheduled'")) { if (rs.next()) rescheduled = rs.getInt("cnt"); }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception ignore) {}
        }

        request.setAttribute("totalClasses", totalClasses);
        request.setAttribute("totalBooked", totalBooked);
        request.setAttribute("cancelledCount", cancelled);
        request.setAttribute("rescheduledCount", rescheduled);

        request.getRequestDispatcher("/WEB-INF/views/adminClassSchedule.jsp").forward(request, response);
    }
}
