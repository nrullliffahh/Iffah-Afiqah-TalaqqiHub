<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.sql.DataSource" %>
<%
    try {
        InitialContext ctx = new InitialContext();
        DataSource ds = (DataSource) ctx.lookup("java:comp/env/jdbc/TalaqqiHubDB");
        Connection conn = ds.getConnection();
        
        Statement stmt = conn.createStatement();
        stmt.execute("DELETE FROM studentevaluation WHERE teacherId = 'T001'");
        
        String[] inserts = {
            "INSERT INTO studentevaluation (studentEvaluationId, studentId, teacherId, class_name, surah, ayah_range, session_date, start_time, end_time, tajweedScore, fluencyScore, accuracyScore, overall_score, rating, strength, areas_for_improvement, performance_tag, next_target_surah, suggestions, teacher_comments, status, sessionId) VALUES ('SE101', 'S001', 'T001', 'Class A', 'Al-Fatiha', '1-7', '2024-05-01', '10:00:00', '10:30:00', 88.5, 90.0, 87.0, 88.5, 4, 'Excellent', 'Work on connections', 'Good', 'Al-Baqarah 1-10', 'Continue', 'Great', 'COMPLETED', 'S001')",
            "INSERT INTO studentevaluation (studentEvaluationId, studentId, teacherId, class_name, surah, ayah_range, session_date, start_time, end_time, tajweedScore, fluencyScore, accuracyScore, overall_score, rating, strength, areas_for_improvement, performance_tag, next_target_surah, suggestions, teacher_comments, status, sessionId) VALUES ('SE102', 'S002', 'T001', 'Class B', 'Al-Baqarah', '1-20', '2024-05-02', '11:00:00', '11:45:00', 92.0, 89.5, 91.0, 90.8, 5, 'Fluent', 'Minor pausing', 'Excellent', 'Al-Baqarah 21-40', 'Move', 'Excellent', 'COMPLETED', 'S002')",
            "INSERT INTO studentevaluation (studentEvaluationId, studentId, teacherId, class_name, surah, ayah_range, session_date, start_time, end_time, tajweedScore, fluencyScore, accuracyScore, overall_score, rating, strength, areas_for_improvement, performance_tag, next_target_surah, suggestions, teacher_comments, status, sessionId) VALUES ('SE103', 'S003', 'T001', 'Class A', 'An-Nisa', '1-10', '2024-05-03', '14:00:00', '14:30:00', 75.5, 78.0, 76.5, 76.7, 3, 'Good', 'Tajweed', 'Fair', 'An-Nisa 11-30', 'Study', 'Needs work', 'COMPLETED', 'S003')",
            "INSERT INTO studentevaluation (studentEvaluationId, studentId, teacherId, class_name, surah, ayah_range, session_date, start_time, end_time, tajweedScore, fluencyScore, accuracyScore, overall_score, rating, strength, areas_for_improvement, performance_tag, next_target_surah, suggestions, teacher_comments, status, sessionId) VALUES ('SE104', 'S004', 'T001', 'Class A', 'Al-Araf', '1-20', '2024-05-10', '10:30:00', '11:00:00', 0, 0, 0, 0, 0, '', '', '', '', '', '', 'PENDING', 'S004')",
            "INSERT INTO studentevaluation (studentEvaluationId, studentId, teacherId, class_name, surah, ayah_range, session_date, start_time, end_time, tajweedScore, fluencyScore, accuracyScore, overall_score, rating, strength, areas_for_improvement, performance_tag, next_target_surah, suggestions, teacher_comments, status, sessionId) VALUES ('SE105', 'S005', 'T001', 'Class C', 'At-Tawbah', '1-15', '2024-05-11', '13:00:00', '13:30:00', 0, 0, 0, 0, 0, '', '', '', '', '', '', 'PENDING', 'S005')"
        };
        
        for (String sql : inserts) {
            stmt.execute(sql);
        }
        
        stmt.close();
        conn.close();
        out.println("✓ Test data inserted successfully!");
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
        e.printStackTrace(new java.io.PrintWriter(out));
    }
%>
