<%@ page import="java.sql.*" %>
<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://127.0.0.1:3306/talaqqihub_db",
            "root", "admin");
        
        String sql = "DESCRIBE feedback";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        ResultSet rs = pstmt.executeQuery();
        
        out.println("<h3>Feedback Table Structure:</h3>");
        while(rs.next()) {
            String colName = rs.getString("Field");
            String colType = rs.getString("Type");
            out.println(colName + " - " + colType + "<br>");
        }
        
        out.println("<br><h3>Sample Data:</h3>");
        sql = "SELECT * FROM feedback LIMIT 3";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        
        while(rs.next()) {
            out.println("Rating: " + rs.getInt("rating") + "<br>");
        }
        
        rs.close();
        pstmt.close();
        conn.close();
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    }
%>
