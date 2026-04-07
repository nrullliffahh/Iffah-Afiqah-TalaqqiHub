<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Test Availability - Database Check</title>
    <style>
        body { font-family: Arial; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #4CAF50; color: white; }
    </style>
</head>
<body>
    <h1>Availability Data in Database</h1>
    <p>Checking dates: 2026-04-02, 2026-04-03, 2026-04-08</p>
    
    <h2>All Scheduled Classes for These Dates:</h2>
    <table>
        <tr>
            <th>Schedule ID</th>
            <th>Teacher ID</th>
            <th>Date</th>
            <th>Start Time</th>
            <th>End Time</th>
            <th>Status</th>
            <th>Class Name</th>
        </tr>
        <%
            try {
                Connection conn = DBConnection.getConnection();
                String sql = "SELECT scheduleId, teacherId, scheduleDate, startTime, endTime, classStatus, className " +
                            "FROM classschedule " +
                            "WHERE scheduleDate IN ('2026-04-02', '2026-04-03', '2026-04-08') " +
                            "ORDER BY scheduleDate, startTime";
                
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(sql);
                
                int count = 0;
                while (rs.next()) {
                    count++;
                    %>
                    <tr>
                        <td><%= rs.getString("scheduleId") %></td>
                        <td><%= rs.getString("teacherId") %></td>
                        <td><%= rs.getString("scheduleDate") %></td>
                        <td><%= rs.getString("startTime") %></td>
                        <td><%= rs.getString("endTime") %></td>
                        <td><%= rs.getString("classStatus") %></td>
                        <td><%= rs.getString("className") %></td>
                    </tr>
                    <%
                }
                
                if (count == 0) {
                    %>
                    <tr><td colspan="7" style="text-align: center; color: red;"><strong>NO DATA FOUND!</strong></td></tr>
                    <%
                }
                
                rs.close();
                stmt.close();
                conn.close();
                
                out.println("<p>Total records found: " + count + "</p>");
            } catch (Exception e) {
                out.println("<p style='color: red;'>Error: " + e.getMessage() + "</p>");
                e.printStackTrace(out);
            }
        %>
    </table>
    
    <h2>Check with Booking Status:</h2>
    <table>
        <tr>
            <th>Schedule ID</th>
            <th>Date</th>
            <th>Time</th>
            <th>Booking Status</th>
        </tr>
        <%
            try {
                Connection conn = DBConnection.getConnection();
                String sql = "SELECT cs.scheduleId, cs.scheduleDate, cs.startTime, cs.endTime, " +
                            "CASE WHEN cb.bookingId IS NOT NULL AND cb.bookingStatus != 'Rejected' THEN cb.bookingStatus ELSE 'AVAILABLE' END AS status " +
                            "FROM classschedule cs " +
                            "LEFT JOIN classbooking cb ON cs.scheduleId = cb.scheduleId AND cb.bookingStatus != 'Rejected' " +
                            "WHERE cs.scheduleDate IN ('2026-04-02', '2026-04-03', '2026-04-08') " +
                            "ORDER BY cs.scheduleDate, cs.startTime";
                
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(sql);
                
                while (rs.next()) {
                    %>
                    <tr>
                        <td><%= rs.getString("scheduleId") %></td>
                        <td><%= rs.getString("scheduleDate") %></td>
                        <td><%= rs.getString("startTime") %> - <%= rs.getString("endTime") %></td>
                        <td><strong><%= rs.getString("status") %></strong></td>
                    </tr>
                    <%
                }
                
                rs.close();
                stmt.close();
                conn.close();
            } catch (Exception e) {
                out.println("<p style='color: red;'>Error: " + e.getMessage() + "</p>");
                e.printStackTrace(out);
            }
        %>
    </table>
</body>
</html>
