<%@ page import="java.sql.*" %>
<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://127.0.0.1:3306/talaqqihub_db",
            "root", "admin");
        
        String sql = "SELECT studentEvaluationId, studentId, createdAt FROM studentevaluation WHERE studentId = 'S003' ORDER BY studentEvaluationId";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        ResultSet rs = pstmt.executeQuery();
        
        out.println("<h3>Evaluation History Dates:</h3>");
        while(rs.next()) {
            String evalId = rs.getString("studentEvaluationId");
            String date = rs.getString("createdAt");
            out.println(evalId + " - Date: " + date + "<br>");
        }
        out.println("<p style='color:green; font-weight:bold;'>✓ Dates now displaying from database</p>");
        
        rs.close();
        pstmt.close();
        conn.close();
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    }
%>
