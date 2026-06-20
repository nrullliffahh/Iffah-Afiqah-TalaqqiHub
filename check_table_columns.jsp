<%@ page import="java.sql.*" %>
<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://127.0.0.1:3306/talaqqihub_db",
            "root", "admin");
        
        String sql = "DESCRIBE studentevaluation";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        ResultSet rs = pstmt.executeQuery();
        
        out.println("<h3>StudentEvaluation Table Columns:</h3>");
        while(rs.next()) {
            String colName = rs.getString("Field");
            String colType = rs.getString("Type");
            out.println(colName + " - " + colType + "<br>");
        }
        
        rs.close();
        pstmt.close();
        conn.close();
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    }
%>
