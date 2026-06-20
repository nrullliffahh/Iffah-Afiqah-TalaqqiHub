<%@ page import="java.sql.*" %>
<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://127.0.0.1:3306/talaqqihub_db",
            "root", "admin");
        
        String sql = "ALTER TABLE studentevaluation ADD COLUMN createdAt DATETIME DEFAULT CURRENT_TIMESTAMP";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.execute();
        
        out.println("<p style='color:green; font-weight:bold;'>✓ Added createdAt column to studentevaluation table</p>");
        
        pstmt.close();
        conn.close();
    } catch (Exception e) {
        if (e.getMessage().contains("Duplicate column")) {
            out.println("<p style='color:green;'>✓ Column createdAt already exists</p>");
        } else {
            out.println("Error: " + e.getMessage());
        }
    }
%>
