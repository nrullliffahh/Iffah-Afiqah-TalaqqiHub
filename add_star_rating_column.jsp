<%@ page import="java.sql.*" %>
<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://127.0.0.1:3306/talaqqihub_db",
            "root", "admin");
        
        // Add starRating column if it doesn't exist
        String sql = "ALTER TABLE studentevaluation ADD COLUMN starRating INT DEFAULT 5 CHECK (starRating >= 1 AND starRating <= 5)";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.execute();
        
        out.println("<p style='color:green; font-weight:bold;'>✓ Added starRating column (1-5 stars) to studentevaluation table</p>");
        
        pstmt.close();
        conn.close();
    } catch (Exception e) {
        if (e.getMessage().contains("Duplicate column")) {
            out.println("<p style='color:green;'>✓ Column starRating already exists</p>");
        } else {
            out.println("Error: " + e.getMessage());
        }
    }
%>
