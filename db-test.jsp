<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>DB Connection Test - TalaqqiHub</title>
    <style>body{font-family:Segoe UI,Arial;background:#f8fafc;padding:24px} .card{background:#fff;padding:16px;border-radius:8px;box-shadow:0 1px 3px rgba(0,0,0,0.08);max-width:720px}</style>
</head>
<body>
<div class="card">
<h2>DB Connection Test</h2>
<pre>
<%
    Connection conn = null;
    try {
        conn = DBConnection.getConnection();
        if (conn == null) {
            out.println("Connection returned null. Check DB config and logs.");
        } else {
            out.println("Connected to DB successfully.\n");
            // Query some useful counts
            String q1 = "SELECT COUNT(*) AS cnt FROM classschedule";
            String q2 = "SELECT COUNT(*) AS cnt FROM classbooking";
            String q3 = "SELECT COUNT(*) AS cnt FROM classbooking WHERE bookingStatus LIKE 'Cancelled'";
            String q4 = "SELECT COUNT(*) AS cnt FROM classbooking WHERE bookingStatus LIKE 'Rescheduled'";

            try (Statement st = conn.createStatement()) {
                try (ResultSet rs = st.executeQuery(q1)) { if (rs.next()) out.println("classschedule rows: " + rs.getInt("cnt")); }
                try (ResultSet rs = st.executeQuery(q2)) { if (rs.next()) out.println("classbooking rows:  " + rs.getInt("cnt")); }
                try (ResultSet rs = st.executeQuery(q3)) { if (rs.next()) out.println("cancelled bookings: " + rs.getInt("cnt")); }
                try (ResultSet rs = st.executeQuery(q4)) { if (rs.next()) out.println("rescheduled bookings: " + rs.getInt("cnt")); }
            } catch (SQLException qex) {
                out.println("Query failed: " + qex.getMessage());
                qex.printStackTrace(new java.io.PrintWriter(out));
            }
        }
    } catch (Exception e) {
        out.println("Exception obtaining connection: " + e.getMessage());
        e.printStackTrace(new java.io.PrintWriter(out));
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ignore) {}
    }
%>
</pre>
</div>
</body>
</html>