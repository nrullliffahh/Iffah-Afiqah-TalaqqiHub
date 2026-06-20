<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.sql.DataSource" %>
<!DOCTYPE html>
<html>
<body>
<h2>Verification: Student Names from JOIN</h2>
<%
    try {
        InitialContext ctx = new InitialContext();
        DataSource ds = (DataSource) ctx.lookup("java:comp/env/jdbc/TalaqqiHubDB");
        Connection conn = ds.getConnection();
        
        String sql = "SELECT se.studentEvaluationId, se.studentId, s.studentName, se.surah, se.overall_score, se.status FROM studentevaluation se LEFT JOIN student s ON se.studentId = s.studentId WHERE se.teacherId = 'T001' ORDER BY se.status DESC";
        
        PreparedStatement pstmt = conn.prepareStatement(sql);
        ResultSet rs = pstmt.executeQuery();
        
        out.println("<table border='1' cellpadding='10'>");
        out.println("<tr><th>Eval ID</th><th>Student ID</th><th>Student Name (from JOIN)</th><th>Surah</th><th>Score</th><th>Status</th></tr>");
        
        while (rs.next()) {
            String evalId = rs.getString("studentEvaluationId");
            String studentId = rs.getString("studentId");
            String studentName = rs.getString("studentName");
            String surah = rs.getString("surah");
            String score = rs.getString("overall_score");
            String status = rs.getString("status");
            
            out.println("<tr>");
            out.println("<td>" + evalId + "</td>");
            out.println("<td>" + studentId + "</td>");
            out.println("<td><b>" + (studentName != null ? studentName : "NULL") + "</b></td>");
            out.println("<td>" + surah + "</td>");
            out.println("<td>" + score + "</td>");
            out.println("<td>" + status + "</td>");
            out.println("</tr>");
        }
        
        out.println("</table>");
        rs.close();
        pstmt.close();
        conn.close();
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
        e.printStackTrace(new java.io.PrintWriter(out));
    }
%>
</body>
</html>
