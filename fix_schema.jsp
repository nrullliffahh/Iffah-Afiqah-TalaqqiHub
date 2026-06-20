<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.sql.DataSource" %>
<!DOCTYPE html>
<html>
<body>
<h2>Database Schema Fix</h2>
<%
    try {
        InitialContext ctx = new InitialContext();
        DataSource ds = (DataSource) ctx.lookup("java:comp/env/jdbc/TalaqqiHubDB");
        Connection conn = ds.getConnection();
        
        Statement stmt = conn.createStatement();
        
        // Check if student_name column exists in studentevaluation
        try {
            stmt.execute("ALTER TABLE studentevaluation DROP COLUMN student_name");
            out.println("✓ Dropped student_name column from studentevaluation<br>");
        } catch (SQLException e) {
            out.println("Note: student_name column may not exist: " + e.getMessage() + "<br>");
        }
        
        stmt.close();
        conn.close();
        out.println("✓ Schema update complete!");
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
        e.printStackTrace(new java.io.PrintWriter(out));
    }
%>
</body>
</html>
