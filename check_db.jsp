<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%
    response.setContentType("text/html; charset=UTF-8");
    
    // Get teacher ID from session
    String teacherId = (String) session.getAttribute("teacherId");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Database Check</title>
    <style>
        body { font-family: monospace; padding: 20px; background: #f5f5f5; }
        .info { background: #e3f2fd; border: 2px solid #2196f3; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .success { background: #e8f5e9; border: 2px solid #4caf50; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .error { background: #ffebee; border: 2px solid #f44336; padding: 15px; margin: 10px 0; border-radius: 5px; }
        table { border-collapse: collapse; width: 100%; background: white; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #673ab7; color: white; }
    </style>
</head>
<body>
    <h1>🔍 Database Connection Test</h1>
    
    <div class="info">
        <strong>Session Info:</strong><br>
        Teacher ID from session: <strong><%= teacherId != null ? teacherId : "NOT LOGGED IN" %></strong>
    </div>
    
    <%
    Connection conn = null;
    try {
        conn = DBConnection.getConnection();
        
        if (conn != null) {
            out.println("<div class='success'><strong>✓ Database Connection: SUCCESS</strong></div>");
            
            // Check all schedules for this teacher
            String sql1 = "SELECT scheduleId, className, scheduleDate, startTime, endTime, teacherId " +
                         "FROM classschedule WHERE teacherId = ? ORDER BY scheduleDate, startTime";
            PreparedStatement stmt1 = conn.prepareStatement(sql1);
            stmt1.setString(1, teacherId);
            ResultSet rs1 = stmt1.executeQuery();
            
            out.println("<h2>All Schedules for Teacher: " + teacherId + "</h2>");
            out.println("<table>");
            out.println("<tr><th>Schedule ID</th><th>Class</th><th>Date</th><th>Start</th><th>End</th></tr>");
            
            int count1 = 0;
            while (rs1.next()) {
                count1++;
                out.println("<tr>");
                out.println("<td>" + rs1.getString("scheduleId") + "</td>");
                out.println("<td>" + rs1.getString("className") + "</td>");
                out.println("<td>" + rs1.getString("scheduleDate") + "</td>");
                out.println("<td>" + rs1.getString("startTime") + "</td>");
                out.println("<td>" + rs1.getString("endTime") + "</td>");
                out.println("</tr>");
            }
            out.println("</table>");
            out.println("<p><strong>Total schedules: " + count1 + "</strong></p>");
            
            rs1.close();
            stmt1.close();
            
            // Check availability (not booked)
            String sql2 = "SELECT cs.scheduleId, cs.className, cs.scheduleDate, cs.startTime, cs.endTime, " +
                         "b.bookingId FROM classschedule cs " +
                         "LEFT JOIN booking b ON cs.scheduleId = b.scheduleId " +
                         "WHERE cs.teacherId = ? AND cs.scheduleDate >= CURDATE() " +
                         "ORDER BY cs.scheduleDate, cs.startTime";
            PreparedStatement stmt2 = conn.prepareStatement(sql2);
            stmt2.setString(1, teacherId);
            ResultSet rs2 = stmt2.executeQuery();
            
            out.println("<h2>Future Schedules (with booking status)</h2>");
            out.println("<table>");
            out.println("<tr><th>Schedule ID</th><th>Class</th><th>Date</th><th>Start</th><th>End</th><th>Booking ID</th><th>Status</th></tr>");
            
            int count2 = 0;
            int availableCount = 0;
            while (rs2.next()) {
                count2++;
                String bookingId = rs2.getString("bookingId");
                boolean isAvailable = (bookingId == null);
                if (isAvailable) availableCount++;
                
                out.println("<tr style='background: " + (isAvailable ? "#e8f5e9" : "#fff3e0") + "'>");
                out.println("<td>" + rs2.getString("scheduleId") + "</td>");
                out.println("<td>" + rs2.getString("className") + "</td>");
                out.println("<td>" + rs2.getString("scheduleDate") + "</td>");
                out.println("<td>" + rs2.getString("startTime") + "</td>");
                out.println("<td>" + rs2.getString("endTime") + "</td>");
                out.println("<td>" + (bookingId != null ? bookingId : "NULL") + "</td>");
                out.println("<td><strong>" + (isAvailable ? "AVAILABLE" : "BOOKED") + "</strong></td>");
                out.println("</tr>");
            }
            out.println("</table>");
            out.println("<p><strong>Total future schedules: " + count2 + "</strong></p>");
            out.println("<p><strong>Available (not booked): " + availableCount + "</strong></p>");
            
            rs2.close();
            stmt2.close();
            
            // Check if booking table exists
            out.println("<h2>Table Check</h2>");
            DatabaseMetaData meta = conn.getMetaData();
            ResultSet tables = meta.getTables(null, null, "booking", null);
            if (tables.next()) {
                out.println("<div class='success'>✓ Table 'booking' EXISTS</div>");
            } else {
                out.println("<div class='error'>✗ Table 'booking' DOES NOT EXIST</div>");
            }
            tables.close();
            
        } else {
            out.println("<div class='error'><strong>✗ Database Connection: FAILED</strong></div>");
        }
        
    } catch (Exception e) {
        out.println("<div class='error'><strong>ERROR:</strong><br>");
        out.println(e.getMessage() + "<br><pre>");
        e.printStackTrace(new java.io.PrintWriter(out));
        out.println("</pre></div>");
    } finally {
        if (conn != null) {
            try { conn.close(); } catch (Exception e) {}
        }
    }
    %>
    
    <hr>
    <p><a href="<%= request.getContextPath() %>/teacher/classschedule">← Back to Class Schedule</a></p>
</body>
</html>
