<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Test Class Details Query</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; background: #f5f5f5; }
        .success { background: #e8f5e9; border: 2px solid #4caf50; padding: 15px; margin: 10px 0; }
        .error { background: #ffebee; border: 2px solid #f44336; padding: 15px; margin: 10px 0; }
        table { border-collapse: collapse; width: 100%; background: white; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #673ab7; color: white; }
        pre { background: #333; color: #fff; padding: 10px; border-radius: 5px; }
    </style>
</head>
<body>
    <h1>Test Class Details Query</h1>
    
    <%
    Connection conn = null;
    try {
        conn = DBConnection.getConnection();
        
        if (conn != null) {
            out.println("<div class='success'>✓ Database Connected</div>");
            
            // Check booking table structure
            out.println("<h2>1. Booking Table Structure</h2>");
            DatabaseMetaData meta = conn.getMetaData();
            ResultSet columns = meta.getColumns(null, null, "booking", null);
            out.println("<table><tr><th>Column Name</th><th>Type</th></tr>");
            while (columns.next()) {
                out.println("<tr><td>" + columns.getString("COLUMN_NAME") + "</td><td>" + columns.getString("TYPE_NAME") + "</td></tr>");
            }
            out.println("</table>");
            columns.close();
            
            // Check studentcancellation table
            out.println("<h2>2. Student Cancellation Table Structure</h2>");
            columns = meta.getColumns(null, null, "studentcancellation", null);
            out.println("<table><tr><th>Column Name</th><th>Type</th></tr>");
            while (columns.next()) {
                out.println("<tr><td>" + columns.getString("COLUMN_NAME") + "</td><td>" + columns.getString("TYPE_NAME") + "</td></tr>");
            }
            out.println("</table>");
            columns.close();
            
            // Check sample bookings
            out.println("<h2>3. Sample Bookings</h2>");
            String sql = "SELECT b.bookingId, b.bookingStatus, b.studentId, b.scheduleId, " +
                        "cs.className, cs.teacherId, s.studentName " +
                        "FROM booking b " +
                        "LEFT JOIN classschedule cs ON b.scheduleId = cs.scheduleId " +
                        "LEFT JOIN student s ON b.studentId = s.studentId " +
                        "LIMIT 5";
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            out.println("<table>");
            out.println("<tr><th>Booking ID</th><th>Status</th><th>Student</th><th>Class</th><th>Teacher</th></tr>");
            while (rs.next()) {
                out.println("<tr>");
                out.println("<td>" + rs.getString("bookingId") + "</td>");
                out.println("<td>" + rs.getString("bookingStatus") + "</td>");
                out.println("<td>" + rs.getString("studentName") + "</td>");
                out.println("<td>" + rs.getString("className") + "</td>");
                out.println("<td>" + rs.getString("teacherId") + "</td>");
                out.println("</tr>");
            }
            out.println("</table>");
            rs.close();
            stmt.close();
            
            // Test the actual query
            out.println("<h2>4. Test Class Details Query (First Booking)</h2>");
            String testSql = "SELECT " +
                            "b.bookingId, b.bookingStatus, b.bookingDate, b.bookingTime, " +
                            "cs.scheduleId, cs.className, cs.duration, cs.classStatus, cs.notes, " +
                            "s.studentId, s.studentName, s.email, " +
                            "sc.cancellationReason, sc.cancelledAt " +
                            "FROM booking b " +
                            "INNER JOIN classschedule cs ON b.scheduleId = cs.scheduleId " +
                            "INNER JOIN student s ON b.studentId = s.studentId " +
                            "LEFT JOIN studentcancellation sc ON b.bookingId = sc.bookingId " +
                            "LIMIT 1";
            stmt = conn.createStatement();
            rs = stmt.executeQuery(testSql);
            if (rs.next()) {
                out.println("<table>");
                out.println("<tr><th>Field</th><th>Value</th></tr>");
                out.println("<tr><td>Booking ID</td><td>" + rs.getString("bookingId") + "</td></tr>");
                out.println("<tr><td>Status</td><td>" + rs.getString("bookingStatus") + "</td></tr>");
                out.println("<tr><td>Student Name</td><td>" + rs.getString("studentName") + "</td></tr>");
                out.println("<tr><td>Student ID</td><td>" + rs.getString("studentId") + "</td></tr>");
                out.println("<tr><td>Class Name</td><td>" + rs.getString("className") + "</td></tr>");
                out.println("<tr><td>Duration</td><td>" + rs.getInt("duration") + " min</td></tr>");
                out.println("<tr><td>Date</td><td>" + rs.getDate("bookingDate") + "</td></tr>");
                out.println("<tr><td>Time</td><td>" + rs.getTime("bookingTime") + "</td></tr>");
                out.println("<tr><td>Notes</td><td>" + rs.getString("notes") + "</td></tr>");
                out.println("<tr><td>Cancellation Reason</td><td>" + rs.getString("cancellationReason") + "</td></tr>");
                out.println("</table>");
            } else {
                out.println("<div class='error'>No bookings found</div>");
            }
            rs.close();
            stmt.close();
            
        } else {
            out.println("<div class='error'>✗ Failed to connect to database</div>");
        }
        
    } catch (Exception e) {
        out.println("<div class='error'><strong>Error:</strong> " + e.getMessage() + "</div>");
        out.println("<pre>");
        e.printStackTrace(new java.io.PrintWriter(out));
        out.println("</pre>");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
    %>
    
</body>
</html>
