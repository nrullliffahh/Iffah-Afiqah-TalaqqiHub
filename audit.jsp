<%@ page import="util.DBConnection" %>
<%@ page import="java.sql.*" %>
<%
    out.println("<h2>Complete Database Audit</h2>");
    
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    
    try {
        conn = DBConnection.getConnection();
        if (conn != null) {
            stmt = conn.createStatement();
            
            // 1. Check all evaluations in teacherevaluation
            out.println("<h3>1. ALL Records in teacherevaluation Table</h3>");
            rs = stmt.executeQuery("SELECT * FROM teacherevaluation ORDER BY evaluatedAt DESC");
            
            int totalRows = 0;
            while (rs.next()) {
                totalRows++;
                out.println("<pre>");
                out.println("ID: " + rs.getString("teacherEvaluationId"));
                out.println("StudentID: " + rs.getString("studentId"));
                out.println("TeacherID: " + rs.getString("teacherId"));
                out.println("SessionID: " + rs.getString("sessionId"));
                out.println("Rating: " + rs.getInt("rating"));
                out.println("Comments: " + rs.getString("teacherComments"));
                out.println("Evaluated At: " + rs.getTimestamp("evaluatedAt"));
                out.println("</pre><hr>");
            }
            out.println("<p><strong>Total records in table: " + totalRows + "</strong></p>");
            
            // 2. Check what getStudentSubmittedFeedback query would return for a specific student
            out.println("<h3>2. Query Test - What getStudentSubmittedFeedback Returns</h3>");
            String testStudentId = "S003";
            String sql = "SELECT te.teacherEvaluationId as feedbackId, te.studentId, te.teacherId, " +
                        "te.evaluationDate as sessionDate, te.evaluatedAt as createdAt, " +
                        "te.teacherComments as comments, te.teacherImprovements as suggestions, " +
                        "te.rating, " +
                        "t.teacherName " +
                        "FROM teacherevaluation te " +
                        "LEFT JOIN teacher t ON te.teacherId = t.teacherId " +
                        "WHERE te.studentId = ? " +
                        "ORDER BY te.evaluatedAt DESC LIMIT 10";
            out.println("<p><strong>Testing query for student: " + testStudentId + "</strong></p>");
            out.println("<pre>" + sql + "</pre>");
            
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, testStudentId);
            rs = pstmt.executeQuery();
            
            int resultCount = 0;
            while (rs.next()) {
                resultCount++;
                out.println("<pre>");
                out.println("FeedbackID: " + rs.getString("feedbackId"));
                out.println("StudentID: " + rs.getString("studentId"));
                out.println("TeacherID: " + rs.getString("teacherId"));
                out.println("TeacherName: " + rs.getString("teacherName"));
                out.println("SessionDate: " + rs.getDate("sessionDate"));
                out.println("CreatedAt: " + rs.getTimestamp("createdAt"));
                out.println("Comments: " + rs.getString("comments"));
                out.println("Rating: " + rs.getInt("rating"));
                out.println("</pre><hr>");
            }
            out.println("<p><strong>Results returned: " + resultCount + "</strong></p>");
            pstmt.close();
            
            // 3. Check for any recent evaluations (last 1 hour)
            out.println("<h3>3. Evaluations Submitted in Last 1 Hour</h3>");
            rs = stmt.executeQuery("SELECT * FROM teacherevaluation WHERE evaluatedAt > DATE_SUB(NOW(), INTERVAL 1 HOUR)");
            int recentCount = 0;
            while (rs.next()) {
                recentCount++;
            }
            out.println("<p>Recent evaluations: " + recentCount + "</p>");
            
        } else {
            out.println("<p style='color: red;'>ERROR: Cannot connect to database</p>");
        }
    } catch (Exception e) {
        out.println("<p style='color: red;'>ERROR: " + e.getMessage() + "</p>");
        e.printStackTrace(new java.io.PrintWriter(out));
    } finally {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {}
    }
%>
