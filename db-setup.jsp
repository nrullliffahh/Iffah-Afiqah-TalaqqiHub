<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.sql.DataSource" %>

<!DOCTYPE html>
<html>
<head>
    <title>Database Test & Data Setup</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        pre { background: #f3f4f6; padding: 1rem; border-radius: 0.5rem; overflow-x: auto; }
        .status-ok { color: #10b981; }
        .status-error { color: #ef4444; }
        .status-warn { color: #f59e0b; }
    </style>
</head>
<body class="bg-gray-50 p-8">
    <div class="max-w-6xl mx-auto">
        <h1 class="text-4xl font-bold mb-8 text-gray-800">Database Setup & Diagnostics</h1>

        <%
            String action = request.getParameter("action");
            boolean showResults = false;
            String resultMessage = "";
            
            try {
                InitialContext ctx = new InitialContext();
                DataSource dataSource = (DataSource) ctx.lookup("java:comp/env/jdbc/TalaqqiHubDB");
                Connection connection = dataSource.getConnection();
                
                if ("insertTestData".equals(action)) {
                    try {
                        Statement stmt = connection.createStatement();
                        
                        // Clear existing test data first
                        stmt.execute("DELETE FROM studentevaluation WHERE teacherId = 'T001'");
                        
                        // Insert sample data into studentevaluation using REAL student IDs from student table
                        // Student names will be fetched from student table via JOIN
                        String[] insertStatements = {
                            "INSERT INTO studentevaluation (studentEvaluationId, studentId, teacherId, class_name, surah, ayah_range, session_date, start_time, end_time, tajweedScore, fluencyScore, accuracyScore, overall_score, rating, strength, areas_for_improvement, performance_tag, next_target_surah, suggestions, teacher_comments, status, sessionId) VALUES ('SE101', 'S001', 'T001', 'Class A', 'Al-Fatiha', '1-7', '2024-05-01', '10:00:00', '10:30:00', 88.5, 90.0, 87.0, 88.5, 4, 'Excellent pronunciation', 'Work on connections', 'Good', 'Al-Baqarah 1-10', 'Continue practice', 'Great dedication', 'COMPLETED', 'S001')",
                            "INSERT INTO studentevaluation (studentEvaluationId, studentId, teacherId, class_name, surah, ayah_range, session_date, start_time, end_time, tajweedScore, fluencyScore, accuracyScore, overall_score, rating, strength, areas_for_improvement, performance_tag, next_target_surah, suggestions, teacher_comments, status, sessionId) VALUES ('SE102', 'S002', 'T001', 'Class B', 'Al-Baqarah', '1-20', '2024-05-02', '11:00:00', '11:45:00', 92.0, 89.5, 91.0, 90.8, 5, 'Very fluent and accurate', 'Minor pausing', 'Excellent', 'Al-Baqarah 21-40', 'Move to longer surahs', 'Excellent performance', 'COMPLETED', 'S002')",
                            "INSERT INTO studentevaluation (studentEvaluationId, studentId, teacherId, class_name, surah, ayah_range, session_date, start_time, end_time, tajweedScore, fluencyScore, accuracyScore, overall_score, rating, strength, areas_for_improvement, performance_tag, next_target_surah, suggestions, teacher_comments, status, sessionId) VALUES ('SE103', 'S003', 'T001', 'Class A', 'An-Nisa', '1-10', '2024-05-03', '14:00:00', '14:30:00', 75.5, 78.0, 76.5, 76.7, 3, 'Good effort', 'Need Tajweed review', 'Fair', 'An-Nisa 11-30', 'Study Assimilation', 'Needs dedication', 'COMPLETED', 'S003')",
                            "INSERT INTO studentevaluation (studentEvaluationId, studentId, teacherId, class_name, surah, ayah_range, session_date, start_time, end_time, tajweedScore, fluencyScore, accuracyScore, overall_score, rating, strength, areas_for_improvement, performance_tag, next_target_surah, suggestions, teacher_comments, status, sessionId) VALUES ('SE104', 'S004', 'T001', 'Class A', 'Al-A''raf', '1-20', '2024-05-10', '10:30:00', '11:00:00', 0, 0, 0, 0, 0, '', '', '', '', '', '', 'PENDING', 'S004')",
                            "INSERT INTO studentevaluation (studentEvaluationId, studentId, teacherId, class_name, surah, ayah_range, session_date, start_time, end_time, tajweedScore, fluencyScore, accuracyScore, overall_score, rating, strength, areas_for_improvement, performance_tag, next_target_surah, suggestions, teacher_comments, status, sessionId) VALUES ('SE105', 'S005', 'T001', 'Class C', 'At-Tawbah', '1-15', '2024-05-11', '13:00:00', '13:30:00', 0, 0, 0, 0, 0, '', '', '', '', '', '', 'PENDING', 'S005')"
                        };
                        
                        for (String sql : insertStatements) {
                            stmt.execute(sql);
                        }
                        
                        stmt.close();
                        resultMessage = "<p class='status-ok'>✓ Test data inserted successfully into studentevaluation!</p>";
                    } catch (SQLException e) {
                        resultMessage = "<p class='status-error'>✗ Error inserting data: " + e.getMessage() + "</p>";
                    }
                }
                
                // Get database statistics
                String statsQuery = "SELECT COUNT(*) as total, SUM(CASE WHEN status='COMPLETED' THEN 1 ELSE 0 END) as completed, SUM(CASE WHEN status='PENDING' THEN 1 ELSE 0 END) as pending FROM studentevaluation WHERE teacherId = 'T001'";
                Statement stmt = connection.createStatement();
                ResultSet rs = stmt.executeQuery(statsQuery);
        %>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
            <!-- Database Status -->
            <div class="bg-white rounded-lg shadow-md p-6">
                <h2 class="text-2xl font-bold mb-4 text-gray-800">Database Connection Status</h2>
                
                <%
                    try {
                        Statement connTest = connection.createStatement();
                        ResultSet testRs = connTest.executeQuery("SELECT DATABASE() as dbname");
                        if (testRs.next()) {
                            String dbName = testRs.getString("dbname");
                %>
                            <div class="status-ok text-lg font-semibold mb-4">✓ Connected to database: <%= dbName %></div>
                <%
                        }
                    } catch (Exception e) {
                %>
                        <div class="status-error text-lg font-semibold mb-4">✗ Connection failed: <%= e.getMessage() %></div>
                <%
                    }
                %>
                
                <!-- Current Data Statistics -->
                <h3 class="text-xl font-bold mb-3 text-gray-700">Current Data in studentevaluation Table (Teacher ID = T001):</h3>
                <div class="space-y-2">
                <%
                    if (rs.next()) {
                        int total = rs.getInt("total");
                        int completed = rs.getInt("completed");
                        int pending = rs.getInt("pending");
                %>
                    <p><strong>Total Evaluations:</strong> <%= total %></p>
                    <p><strong>Completed:</strong> <span class="text-green-600 font-semibold"><%= completed %></span></p>
                    <p><strong>Pending:</strong> <span class="text-yellow-600 font-semibold"><%= pending %></span></p>
                <%
                    }
                %>
                </div>
            </div>

            <!-- Actions Panel -->
            <div class="bg-white rounded-lg shadow-md p-6">
                <h2 class="text-2xl font-bold mb-4 text-gray-800">Actions</h2>
                
                <form method="POST" class="space-y-4">
                    <button type="submit" name="action" value="insertTestData" class="w-full bg-purple-600 hover:bg-purple-700 text-white font-bold py-3 px-4 rounded-lg transition">
                        📊 Insert Sample Test Data
                    </button>
                </form>

                <% if (!resultMessage.isEmpty()) { %>
                    <div class="mt-4 p-4 bg-blue-50 rounded border border-blue-200">
                        <%= resultMessage %>
                    </div>
                <% } %>

                <div class="mt-4 p-4 bg-yellow-50 rounded border border-yellow-200">
                    <p class="text-sm text-gray-700">
                        <strong>ℹ️ Note:</strong> This will insert 5 sample evaluations (3 completed, 2 pending) for testing.
                    </p>
                </div>
            </div>
        </div>

        <!-- Recent Evaluations Preview -->
        <div class="bg-white rounded-lg shadow-md p-6 mt-8">
            <h2 class="text-2xl font-bold mb-6 text-gray-800">📋 Recent Evaluations Preview (Teacher ID = T001)</h2>
            
            <div class="grid grid-cols-2 gap-6">
                <!-- Completed Evaluations -->
                <div>
                    <h3 class="text-lg font-bold mb-4 text-green-700">✓ Completed</h3>
                    <%
                        try {
                            String completedQuery = "SELECT studentEvaluationId, student_name, surah, overall_score, status FROM studentevaluation WHERE teacherId = 'T001' AND status = 'COMPLETED' ORDER BY session_date DESC LIMIT 5";
                            ResultSet completedRs = connection.createStatement().executeQuery(completedQuery);
                            if (!completedRs.isBeforeFirst()) {
                    %>
                        <p class="text-gray-500 italic">No completed evaluations yet. Click "Insert Sample Test Data" to add some.</p>
                    <%
                            } else {
                    %>
                        <table class="w-full text-sm">
                            <thead>
                                <tr class="border-b">
                                    <th class="text-left py-2">Student</th>
                                    <th class="text-left py-2">Surah</th>
                                    <th class="text-right py-2">Score</th>
                                </tr>
                            </thead>
                            <tbody>
                    <%
                                while (completedRs.next()) {
                    %>
                                <tr class="border-b hover:bg-gray-50">
                                    <td class="py-2"><%= completedRs.getString("student_name") %></td>
                                    <td class="py-2"><%= completedRs.getString("surah") %></td>
                                    <td class="py-2 text-right font-semibold"><%= completedRs.getDouble("overall_score") %>%</td>
                                </tr>
                    <%
                                }
                    %>
                            </tbody>
                        </table>
                    <%
                            }
                        } catch (Exception e) {
                    %>
                        <p class="status-error"><%= e.getMessage() %></p>
                    <%
                        }
                    %>
                </div>

                <!-- Pending Evaluations -->
                <div>
                    <h3 class="text-lg font-bold mb-4 text-yellow-700">⏳ Pending</h3>
                    <%
                        try {
                            String pendingQuery = "SELECT studentEvaluationId, student_name, surah, session_date, status FROM studentevaluation WHERE teacherId = 'T001' AND status = 'PENDING' ORDER BY session_date DESC LIMIT 5";
                            ResultSet pendingRs = connection.createStatement().executeQuery(pendingQuery);
                            if (!pendingRs.isBeforeFirst()) {
                    %>
                        <p class="text-gray-500 italic">No pending evaluations. Click "Insert Sample Test Data" to add some.</p>
                    <%
                            } else {
                    %>
                        <table class="w-full text-sm">
                            <thead>
                                <tr class="border-b">
                                    <th class="text-left py-2">Student</th>
                                    <th class="text-left py-2">Surah</th>
                                    <th class="text-left py-2">Date</th>
                                </tr>
                            </thead>
                            <tbody>
                    <%
                                while (pendingRs.next()) {
                    %>
                                <tr class="border-b hover:bg-gray-50">
                                    <td class="py-2"><%= pendingRs.getString("student_name") %></td>
                                    <td class="py-2"><%= pendingRs.getString("surah") %></td>
                                    <td class="py-2"><%= pendingRs.getString("session_date") %></td>
                                </tr>
                    <%
                                }
                    %>
                            </tbody>
                        </table>
                    <%
                            }
                        } catch (Exception e) {
                    %>
                        <p class="status-error"><%= e.getMessage() %></p>
                    <%
                        }
                    %>
                </div>
            </div>
        </div>

        <!-- Next Steps -->
        <div class="bg-blue-50 border border-blue-200 rounded-lg p-6 mt-8">
            <h2 class="text-xl font-bold mb-4 text-blue-900">📍 Next Steps</h2>
            <ol class="list-decimal list-inside space-y-2 text-gray-700">
                <li><strong>Insert Test Data:</strong> Click "Insert Sample Test Data" button above to populate the database with sample evaluations</li>
                <li><strong>Visit Teacher Portal:</strong> Go to <a href="./teacher/evaluation" class="text-blue-600 hover:underline">/teacher/evaluation</a> to see the data displayed on the dashboard</li>
                <li><strong>Check Dashboard:</strong> You should see:
                    <ul class="list-disc list-inside ml-4 mt-2">
                        <li>Dashboard cards with statistics (Total Students, Sessions, Average Scores)</li>
                        <li>Completed Evaluations list</li>
                        <li>Pending Evaluations list</li>
                    </ul>
                </li>
                <li><strong>Test Forms:</strong> Click "Evaluate Now" on any pending evaluation to test the evaluation form</li>
            </ol>
        </div>

        <!-- Troubleshooting -->
        <div class="bg-red-50 border border-red-200 rounded-lg p-6 mt-8">
            <h2 class="text-xl font-bold mb-4 text-red-900">🔧 Troubleshooting</h2>
            <div class="space-y-2 text-gray-700">
                <p><strong>No data showing in teacher portal?</strong></p>
                <ul class="list-disc list-inside ml-4">
                    <li>Make sure you're logged in with a teacher account (teacherId = 1)</li>
                    <li>Click "Insert Sample Test Data" button on this page</li>
                    <li>Refresh the teacher evaluation page</li>
                </ul>
                <p class="mt-4"><strong>Still not working?</strong></p>
                <ul class="list-disc list-inside ml-4">
                    <li>Check Tomcat logs: <code>c:\xampp\tomcat\logs\catalina.out</code></li>
                    <li>Verify database connection in Tomcat Manager</li>
                    <li>Check that the evaluation table exists and has columns</li>
                </ul>
            </div>
        </div>

        <!-- Quick Links -->
        <div class="mt-8 flex gap-4">
            <a href="./teacher/evaluation" class="bg-green-600 hover:bg-green-700 text-white font-bold py-2 px-6 rounded-lg transition">
                → Go to Teacher Evaluation Portal
            </a>
            <a href="index.jsp" class="bg-gray-600 hover:bg-gray-700 text-white font-bold py-2 px-6 rounded-lg transition">
                ← Back to Home
            </a>
        </div>
    </div>

    <%
            connection.close();
        } catch (Exception e) {
            out.println("<div class='bg-red-100 border border-red-400 text-red-700 p-4 rounded'>");
            out.println("<strong>Error:</strong> " + e.getMessage());
            out.println("</div>");
        }
    %>
</body>
</html>
