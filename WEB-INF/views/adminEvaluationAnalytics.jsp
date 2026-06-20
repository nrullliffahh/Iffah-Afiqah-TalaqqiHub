<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%
    if (session == null || session.getAttribute("adminId") == null) {
        response.sendRedirect(request.getContextPath() + "/admin/login");
        return;
    }

    String adminName = (String) session.getAttribute("adminName");
    if (adminName == null) adminName = "Admin Manager";

    int totalTeacherEvals = 0;
    int totalStudentEvals = 0;
    double avgOverall = 0, avgTajweed = 0, avgFluency = 0, avgAccuracy = 0;

    List<Map<String, Object>> teacherRecords = new ArrayList<>();
    List<Map<String, Object>> studentRecords = new ArrayList<>();
    List<Map<String, Object>> teacherRatings = new ArrayList<>();
    List<Map<String, String>> teachers = new ArrayList<>();
    List<Map<String, Object>> studentPerformanceList = new ArrayList<>();

    String[] surahNames = {
        "", "Al-Fatiha", "Al-Baqarah", "Al-Imran", "An-Nisa", "Al-Maidah",
        "Al-Anam", "Al-Araf", "Al-Anfal", "At-Tawbah", "Yunus",
        "Hud", "Yusuf", "Ar-Rad", "Ibrahim", "Al-Hijr",
        "An-Nahl", "Al-Isra", "Al-Kahf", "Maryam", "Taha",
        "Al-Anbiya", "Al-Hajj", "Al-Muminun", "An-Nur", "Al-Furqan",
        "Ash-Shuara", "An-Naml", "Al-Qasas", "Al-Ankabut", "Ar-Rum",
        "Luqman", "As-Sajdah", "Al-Ahzab", "Saba", "Fatir",
        "Yasin", "As-Saffat", "Sad", "Az-Zumar", "Ghafir",
        "Fussilat", "Ash-Shura", "Az-Zukhruf", "Ad-Dukhan", "Al-Jathiya",
        "Al-Ahqaf", "Muhammad", "Al-Fath", "Al-Hujurat", "Qaf",
        "Adh-Dhariyat", "At-Tur", "An-Najm", "Al-Qamar", "Ar-Rahman",
        "Al-Waqiah", "Al-Hadid", "Al-Mujadalah", "Al-Hashr", "Al-Mumtahanah",
        "As-Saff", "Al-Jumu'ah", "Al-Munafiqun", "At-Taghabun", "At-Talaq",
        "At-Tahrim", "Al-Mulk", "Al-Qalam", "Al-Haqqah", "Al-Maarij",
        "Nuh", "Al-Jinn", "Al-Muzzammil", "Al-Muddaththir", "Al-Qiyamah",
        "Al-Insan", "Al-Mursalat", "An-Naba", "An-Nazi'at", "Abasa",
        "At-Takwir", "Al-Infitar", "Al-Mutaffifin", "Al-Inshiqaq", "Al-Buruj",
        "At-Tariq", "Al-A'la", "Al-Ghashiyah", "Al-Fajr", "Al-Balad",
        "Ash-Shams", "Al-Layl", "Ad-Duha", "Ash-Sharh", "At-Tin",
        "Al-Alaq", "Al-Qadr", "Al-Bayyinah", "Az-Zalzalah", "Al-Adiyat",
        "Al-Qari'ah", "At-Takathur", "Al-Asr", "Al-Humaza", "Al-Fil",
        "Quraysh", "Al-Maun", "Al-Kawthar", "Al-Kafirun", "An-Nasr",
        "Al-Masad", "Al-Ikhlas", "Al-Falaq", "An-Nas"
    };

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();
        if (conn != null) {
            pstmt = conn.prepareStatement(
                "SELECT COUNT(*) AS cnt FROM studentevaluation WHERE status = 'COMPLETED'");
            rs = pstmt.executeQuery();
            if (rs.next()) totalTeacherEvals = rs.getInt("cnt");
            rs.close(); pstmt.close();

            pstmt = conn.prepareStatement("SELECT COUNT(*) AS cnt FROM studentfeedback");
            rs = pstmt.executeQuery();
            if (rs.next()) totalStudentEvals = rs.getInt("cnt");
            rs.close(); pstmt.close();

            pstmt = conn.prepareStatement(
                "SELECT AVG(COALESCE(overall_score,(tajweedScore+fluencyScore+accuracyScore)/3)) AS avgOverall, " +
                "AVG(tajweedScore) AS avgTajweed, AVG(fluencyScore) AS avgFluency, AVG(accuracyScore) AS avgAccuracy " +
                "FROM studentevaluation WHERE status = 'COMPLETED'");
            rs = pstmt.executeQuery();
            if (rs.next()) {
                avgOverall = rs.getDouble("avgOverall");
                avgTajweed = rs.getDouble("avgTajweed");
                avgFluency = rs.getDouble("avgFluency");
                avgAccuracy = rs.getDouble("avgAccuracy");
            }
            rs.close(); pstmt.close();

            pstmt = conn.prepareStatement(
                "SELECT s.studentId, s.studentName, " +
                "AVG(se.tajweedScore) AS tajweed, AVG(se.fluencyScore) AS fluency, " +
                "AVG(se.accuracyScore) AS accuracy, " +
                "AVG(COALESCE(se.overall_score,(se.tajweedScore+se.fluencyScore+se.accuracyScore)/3)) AS overall " +
                "FROM studentevaluation se " +
                "JOIN student s ON se.studentId = s.studentId " +
                "WHERE se.status = 'COMPLETED' " +
                "GROUP BY s.studentId, s.studentName " +
                "ORDER BY s.studentName");
            rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("studentId", rs.getString("studentId"));
                row.put("studentName", rs.getString("studentName"));
                row.put("tajweed", rs.getDouble("tajweed"));
                row.put("fluency", rs.getDouble("fluency"));
                row.put("accuracy", rs.getDouble("accuracy"));
                row.put("overall", rs.getDouble("overall"));
                studentPerformanceList.add(row);
            }
            rs.close(); pstmt.close();

            pstmt = conn.prepareStatement(
                "SELECT t.teacherName, AVG(sf.rating) AS avgRating, COUNT(*) AS reviews " +
                "FROM studentfeedback sf JOIN teacher t ON sf.teacherId = t.teacherId " +
                "GROUP BY sf.teacherId, t.teacherName ORDER BY avgRating DESC LIMIT 5");
            rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("teacherName", rs.getString("teacherName"));
                row.put("avgRating", rs.getDouble("avgRating"));
                row.put("reviews", rs.getInt("reviews"));
                teacherRatings.add(row);
            }
            rs.close(); pstmt.close();

            pstmt = conn.prepareStatement(
                "SELECT se.studentEvaluationId, t.teacherName, s.studentName, " +
                "DATE_FORMAT(COALESCE(cs.scheduleDate, se.session_date, se.createdAt),'%b %d, %Y') AS sessionDate, " +
                "COALESCE(cs.className, se.class_name, 'Quran Recitation & Tajweed') AS classType, " +
                "se.surah, se.ayah_range, se.tajweedScore, se.fluencyScore, se.accuracyScore, " +
                "COALESCE(se.overall_score,(se.tajweedScore+se.fluencyScore+se.accuracyScore)/3) AS overall, " +
                "se.teacherId " +
                "FROM studentevaluation se " +
                "LEFT JOIN teacher t ON se.teacherId = t.teacherId " +
                "LEFT JOIN student s ON se.studentId = s.studentId " +
                "LEFT JOIN talaqqisession ts ON se.sessionId = ts.sessionId " +
                "LEFT JOIN classbooking cb ON ts.bookingId = cb.bookingId " +
                "LEFT JOIN classschedule cs ON cb.scheduleId = cs.scheduleId " +
                "WHERE se.status = 'COMPLETED' " +
                "ORDER BY COALESCE(cs.scheduleDate, se.session_date, se.createdAt) DESC, se.createdAt DESC");
            rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getString("studentEvaluationId"));
                row.put("teacherName", rs.getString("teacherName"));
                row.put("studentName", rs.getString("studentName"));
                row.put("sessionDate", rs.getString("sessionDate"));
                row.put("classType", rs.getString("classType"));
                String surahRaw = rs.getString("surah");
                String surahLabel = surahRaw;
                if (surahRaw != null && surahRaw.matches("\\d+")) {
                    int n = Integer.parseInt(surahRaw);
                    if (n > 0 && n < surahNames.length) surahLabel = surahNames[n];
                }
                String ayah = rs.getString("ayah_range");
                row.put("lesson", "Quran Recitation (Surah " + surahLabel + (ayah != null && !ayah.isEmpty() ? ", Ayah " + ayah : "") + ")");
                row.put("tajweed", rs.getDouble("tajweedScore"));
                row.put("fluency", rs.getDouble("fluencyScore"));
                row.put("accuracy", rs.getDouble("accuracyScore"));
                row.put("overall", rs.getDouble("overall"));
                row.put("teacherId", rs.getString("teacherId"));
                teacherRecords.add(row);
            }
            rs.close(); pstmt.close();

            pstmt = conn.prepareStatement(
                "SELECT sf.feedbackId, t.teacherName, s.studentName, " +
                "DATE_FORMAT(COALESCE(cs.scheduleDate, sf.createdAt),'%b %d, %Y') AS sessionDate, " +
                "sf.rating, sf.comments, sf.teacherId " +
                "FROM studentfeedback sf " +
                "LEFT JOIN teacher t ON sf.teacherId = t.teacherId " +
                "LEFT JOIN student s ON sf.studentId = s.studentId " +
                "LEFT JOIN talaqqisession ts ON sf.sessionId = ts.sessionId " +
                "LEFT JOIN classbooking cb ON ts.bookingId = cb.bookingId " +
                "LEFT JOIN classschedule cs ON cb.scheduleId = cs.scheduleId " +
                "ORDER BY COALESCE(cs.scheduleDate, sf.createdAt) DESC, sf.createdAt DESC");
            rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getString("feedbackId"));
                row.put("teacherName", rs.getString("teacherName"));
                row.put("studentName", rs.getString("studentName"));
                row.put("sessionDate", rs.getString("sessionDate"));
                row.put("rating", rs.getInt("rating"));
                row.put("comments", rs.getString("comments"));
                row.put("teacherId", rs.getString("teacherId"));
                studentRecords.add(row);
            }
            rs.close(); pstmt.close();

            pstmt = conn.prepareStatement("SELECT teacherId, teacherName FROM teacher ORDER BY teacherName");
            rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, String> t = new HashMap<>();
                t.put("id", rs.getString("teacherId"));
                t.put("name", rs.getString("teacherName"));
                teachers.add(t);
            }
            rs.close(); pstmt.close();
        }
    } catch (SQLException e) {
        System.err.println("adminEvaluationAnalytics: " + e.getMessage());
    } finally {
        try { if (rs != null) rs.close(); if (pstmt != null) pstmt.close(); if (conn != null) conn.close(); } catch (SQLException ignored) {}
    }

    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Evaluation Analytics - TalaqqiHub Admin</title>
    <%@ include file="/WEB-INF/views/includes/adminLayoutStyles.jsp" %>
    <style>
        .student-performance-select { min-width: 220px; padding: 10px 12px; border: 1px solid #E2E8F0; border-radius: 10px; font-size: 13px; font-weight: 600; color: #1E293B; background: white; }
        .rating-item { margin-bottom: 18px; }
        .rating-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px; }
        .rating-name { font-size: 14px; font-weight: 600; color: #1E293B; }
        .rating-score { font-size: 14px; font-weight: 700; color: #1E293B; }
        .rating-stars { color: #F59E0B; font-size: 13px; letter-spacing: 1px; }
        .rating-reviews { font-size: 12px; color: #94A3B8; }
        .rating-track { height: 6px; background: #F1F5F9; border-radius: 3px; overflow: hidden; }
        .rating-fill { height: 100%; background: linear-gradient(90deg, #FBBF24, #F59E0B); border-radius: 3px; }
        .export-btns { display: flex; gap: 10px; flex-wrap: wrap; }
        .btn-export { padding: 10px 18px; border-radius: 10px; font-size: 13px; font-weight: 600; border: 1px solid #E2E8F0; background: white; color: #64748B; cursor: pointer; }
        .btn-export.primary { background: var(--admin-gradient); color: white; border: none; }
        .tabs { display: flex; gap: 28px; border-bottom: 2px solid #E2E8F0; margin-bottom: 24px; }
        .tab-btn { padding: 12px 0; background: none; border: none; font-size: 14px; font-weight: 600; color: #64748B; cursor: pointer; border-bottom: 3px solid transparent; margin-bottom: -2px; }
        .tab-btn.active { color: #6d28d9; border-bottom-color: #6d28d9; }
        .filters { display: grid; grid-template-columns: 2fr 1.2fr 1fr 1fr; gap: 16px; margin-bottom: 16px; }
        .search-wrap { position: relative; }
        .search-wrap i { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: #94A3B8; }
        .search-wrap input { padding-left: 36px; }
        .records-info { font-size: 13px; color: #64748B; margin-bottom: 12px; }
        .score-high { color: #10B981; font-weight: 700; }
        .score-mid { color: #3B82F6; font-weight: 700; }
        .score-low { color: #F59E0B; font-weight: 700; }
        .tab-panel { display: none; }
        .tab-panel.active { display: block; }
        @media (max-width: 1200px) { .filters { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/includes/adminSidebar.jsp">
        <jsp:param name="activePage" value="evaluation-analytics"/>
    </jsp:include>

    <div class="main-content">
        <jsp:include page="/WEB-INF/views/includes/adminTopNavbar.jsp">
            <jsp:param name="pageTitle" value="Evaluation Analytics"/>
        </jsp:include>

        <div class="page-content">
            <h1 class="page-title">Evaluation Analytics</h1>
            <p class="page-subtitle">Monitor evaluation performance across the TalaqqiHub platform</p>

            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon"><i class="fas fa-file-alt"></i></div>
                    <div>
                        <div class="stat-value"><%= totalTeacherEvals %></div>
                        <div class="stat-label">Total Teacher Evaluations</div>
                        <div class="stat-hint">Teachers &rarr; Students</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon"><i class="fas fa-star"></i></div>
                    <div>
                        <div class="stat-value"><%= totalStudentEvals %></div>
                        <div class="stat-label">Total Student Evaluations</div>
                        <div class="stat-hint">Students &rarr; Teachers</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon purple"><i class="fas fa-chart-line"></i></div>
                    <div>
                        <div class="stat-value"><%= String.format("%.1f%%", avgOverall) %></div>
                        <div class="stat-label">Overall Average Score</div>
                        <div class="stat-hint">Platform-wide average</div>
                    </div>
                </div>
            </div>

            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon blue"><i class="fas fa-book-open"></i></div>
                    <div>
                        <div class="stat-value" style="color:#3B82F6;"><%= String.format("%.1f%%", avgTajweed) %></div>
                        <div class="stat-label">Average Tajweed Score</div>
                        <div class="stat-hint">Tajweed mastery level</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon green"><i class="fas fa-microphone"></i></div>
                    <div>
                        <div class="stat-value" style="color:#10B981;"><%= String.format("%.1f%%", avgFluency) %></div>
                        <div class="stat-label">Average Fluency Score</div>
                        <div class="stat-hint">Recitation fluency</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon purple"><i class="fas fa-check-circle"></i></div>
                    <div>
                        <div class="stat-value" style="color:#6d28d9;"><%= String.format("%.1f%%", avgAccuracy) %></div>
                        <div class="stat-label">Average Accuracy Score</div>
                        <div class="stat-hint">Recitation accuracy</div>
                    </div>
                </div>
            </div>

            <div class="trends-grid">
                <div class="panel">
                    <div class="panel-head">
                        <div>
                            <div class="panel-title">Student Performance (/100%)</div>
                            <p class="panel-subtitle">Average scores for each student</p>
                        </div>
                        <select id="studentPerformanceFilter" class="student-performance-select">
                            <% if (studentPerformanceList.isEmpty()) { %>
                                <option value="">No student data</option>
                            <% } else {
                                for (Map<String, Object> student : studentPerformanceList) { %>
                            <option value="<%= student.get("studentId") %>"><%= student.get("studentName") %></option>
                            <%   }
                               } %>
                        </select>
                    </div>
                    <div id="studentScoreBars">
                        <% if (studentPerformanceList.isEmpty()) { %>
                            <p style="color:#94A3B8;font-size:14px;">No completed student evaluations yet.</p>
                        <% } else {
                            Map<String, Object> firstStudent = studentPerformanceList.get(0);
                            String[][] scoreRows = {
                                {"Overall Score", "overall"},
                                {"Tajweed Score", "tajweed"},
                                {"Fluency Score", "fluency"},
                                {"Accuracy Score", "accuracy"}
                            };
                            for (String[] scoreRow : scoreRows) {
                                double pct = (Double) firstStudent.get(scoreRow[1]);
                                int width = (int) Math.max(20, Math.min(100, pct));
                        %>
                        <div class="trend-row" data-score-key="<%= scoreRow[1] %>">
                            <div class="trend-label"><%= scoreRow[0] %></div>
                            <div class="trend-bar-wrap">
                                <div class="trend-bar" style="width:<%= width %>%"><%= String.format("%.1f%%", pct) %></div>
                            </div>
                        </div>
                        <%   }
                           } %>
                    </div>
                </div>
                <div class="panel">
                    <div class="panel-title">Teacher Ratings (Student Feedback)</div>
                    <% if (teacherRatings.isEmpty()) { %>
                        <p style="color:#94A3B8;font-size:14px;">No student feedback yet.</p>
                    <% } else {
                        for (Map<String, Object> tr : teacherRatings) {
                            double rating = (Double) tr.get("avgRating");
                            int reviews = (Integer) tr.get("reviews");
                            int stars = (int) Math.round(rating);
                            StringBuilder starHtml = new StringBuilder();
                            for (int i = 1; i <= 5; i++) starHtml.append(i <= stars ? "&#9733;" : "&#9734;");
                    %>
                    <div class="rating-item">
                        <div class="rating-header">
                            <div>
                                <div class="rating-name"><%= tr.get("teacherName") %></div>
                                <div class="rating-stars"><%= starHtml.toString() %></div>
                            </div>
                            <div class="rating-score"><%= String.format("%.1f", rating) %></div>
                        </div>
                        <div class="rating-reviews"><%= reviews %> review<%= reviews == 1 ? "" : "s" %></div>
                        <div class="rating-track"><div class="rating-fill" style="width:<%= (rating/5.0)*100 %>%"></div></div>
                    </div>
                    <%   }
                       } %>
                </div>
            </div>

            <div class="records-panel">
                <div class="records-header">
                    <div class="records-title">Evaluation Records</div>
                    <div class="export-btns">
                        <button class="btn-export primary" onclick="exportCsv()"><i class="fas fa-file-pdf"></i> Export CSV</button>
                        <button class="btn-export" onclick="window.print()"><i class="fas fa-print"></i> Print</button>
                    </div>
                </div>

                <div class="tabs">
                    <button class="tab-btn active" data-tab="teacher-tab">Student Evaluation</button>
                    <button class="tab-btn" data-tab="student-tab">Teacher Evaluation</button>
                </div>

                <div class="filters">
                    <div>
                        <label class="filter-label">Search</label>
                        <div class="search-wrap">
                            <i class="fas fa-search"></i>
                            <input type="text" id="searchInput" class="filter-input" placeholder="Search teacher or student...">
                        </div>
                    </div>
                    <div>
                        <label class="filter-label">Teacher</label>
                        <select id="teacherFilter" class="filter-select">
                            <option value="">All Teachers</option>
                            <% for (Map<String, String> t : teachers) { %>
                            <option value="<%= t.get("id") %>"><%= t.get("name") %></option>
                            <% } %>
                        </select>
                    </div>
                    <div>
                        <label class="filter-label">Date From</label>
                        <input type="date" id="dateFrom" class="filter-input">
                    </div>
                    <div>
                        <label class="filter-label">Date To</label>
                        <input type="date" id="dateTo" class="filter-input">
                    </div>
                </div>

                <div id="teacher-tab" class="tab-panel active">
                    <div class="records-info" id="teacherCount">Showing 1-<%= teacherRecords.size() %> of <%= teacherRecords.size() %> evaluations</div>
                    <div class="table-responsive">
                        <table class="records-table" id="teacherTable">
                            <thead>
                                <tr>
                                    <th>Teacher Name</th>
                                    <th>Student Name</th>
                                    <th>Session Date</th>
                                    <th>Lesson</th>
                                    <th>Tajweed</th>
                                    <th>Fluency</th>
                                    <th>Accuracy</th>
                                    <th>Overall</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Map<String, Object> r : teacherRecords) {
                                    double o = (Double) r.get("overall");
                                    String scoreClass = o >= 90 ? "score-high" : o >= 80 ? "score-mid" : "score-low";
                                %>
                                <tr data-teacher-id="<%= r.get("teacherId") %>" data-search="<%= (r.get("teacherName")+" "+r.get("studentName")).toLowerCase() %>">
                                    <td><%= r.get("teacherName") %></td>
                                    <td><%= r.get("studentName") %></td>
                                    <td><%= r.get("sessionDate") %></td>
                                    <td><%= r.get("lesson") %></td>
                                    <td class="<%= scoreClass %>"><%= String.format("%.0f%%", (Double)r.get("tajweed")) %></td>
                                    <td class="<%= scoreClass %>"><%= String.format("%.0f%%", (Double)r.get("fluency")) %></td>
                                    <td class="<%= scoreClass %>"><%= String.format("%.0f%%", (Double)r.get("accuracy")) %></td>
                                    <td class="<%= scoreClass %>"><%= String.format("%.1f%%", o) %></td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div id="student-tab" class="tab-panel">
                    <div class="records-info" id="studentCount">Showing 1-<%= studentRecords.size() %> of <%= studentRecords.size() %> evaluations</div>
                    <div class="table-responsive">
                        <table class="records-table" id="studentTable">
                            <thead>
                                <tr>
                                    <th>Teacher Name</th>
                                    <th>Student Name</th>
                                    <th>Session Date</th>
                                    <th>Rating</th>
                                    <th>Comments</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Map<String, Object> r : studentRecords) {
                                    int rating = (Integer) r.get("rating");
                                %>
                                <tr data-teacher-id="<%= r.get("teacherId") %>" data-search="<%= (r.get("teacherName")+" "+r.get("studentName")).toLowerCase() %>">
                                    <td><%= r.get("teacherName") %></td>
                                    <td><%= r.get("studentName") %></td>
                                    <td><%= r.get("sessionDate") %></td>
                                    <td><span class="rating-stars"><% for(int i=1;i<=5;i++){ %><%= i<=rating?"&#9733;":"&#9734;" %><% } %></span> <%= rating %>/5</td>
                                    <td><%= r.get("comments") != null ? r.get("comments") : "" %></td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        const studentPerformanceData = [
            <% for (int i = 0; i < studentPerformanceList.size(); i++) {
                Map<String, Object> student = studentPerformanceList.get(i);
            %>
            {
                studentId: "<%= student.get("studentId") %>",
                studentName: "<%= String.valueOf(student.get("studentName")).replace("\\", "\\\\").replace("\"", "\\\"") %>",
                overall: <%= student.get("overall") %>,
                tajweed: <%= student.get("tajweed") %>,
                fluency: <%= student.get("fluency") %>,
                accuracy: <%= student.get("accuracy") %>
            }<%= i < studentPerformanceList.size() - 1 ? "," : "" %>
            <% } %>
        ];

        const studentScoreMetrics = [
            { key: 'overall', label: 'Overall Score' },
            { key: 'tajweed', label: 'Tajweed Score' },
            { key: 'fluency', label: 'Fluency Score' },
            { key: 'accuracy', label: 'Accuracy Score' }
        ];

        function renderStudentScoreBars(studentId) {
            const container = document.getElementById('studentScoreBars');
            if (!container) return;

            const student = studentPerformanceData.find(function(item) {
                return item.studentId === studentId;
            }) || studentPerformanceData[0];

            if (!student) {
                container.innerHTML = '<p style="color:#94A3B8;font-size:14px;">No completed student evaluations yet.</p>';
                return;
            }

            container.innerHTML = studentScoreMetrics.map(function(metric) {
                const pct = Number(student[metric.key] || 0);
                const width = Math.max(20, Math.min(100, pct));
                return '' +
                    '<div class="trend-row">' +
                        '<div class="trend-label">' + metric.label + '</div>' +
                        '<div class="trend-bar-wrap">' +
                            '<div class="trend-bar" style="width:' + width + '%">' + pct.toFixed(1) + '%</div>' +
                        '</div>' +
                    '</div>';
            }).join('');
        }

        const studentPerformanceFilter = document.getElementById('studentPerformanceFilter');
        if (studentPerformanceFilter) {
            studentPerformanceFilter.addEventListener('change', function() {
                renderStudentScoreBars(this.value);
            });
        }

        document.querySelectorAll('.tab-btn').forEach(function(btn) {
            btn.addEventListener('click', function() {
                document.querySelectorAll('.tab-btn').forEach(function(b) { b.classList.remove('active'); });
                document.querySelectorAll('.tab-panel').forEach(function(p) { p.classList.remove('active'); });
                btn.classList.add('active');
                document.getElementById(btn.dataset.tab).classList.add('active');
                applyFilters();
            });
        });

        function getActiveTable() {
            return document.getElementById('teacher-tab').classList.contains('active')
                ? document.getElementById('teacherTable') : document.getElementById('studentTable');
        }

        function applyFilters() {
            var search = (document.getElementById('searchInput').value || '').toLowerCase();
            var teacherId = document.getElementById('teacherFilter').value;
            var table = getActiveTable();
            var rows = table.querySelectorAll('tbody tr');
            var visible = 0;
            rows.forEach(function(row) {
                var matchSearch = !search || (row.dataset.search || '').indexOf(search) >= 0;
                var matchTeacher = !teacherId || row.dataset.teacherId === teacherId;
                var show = matchSearch && matchTeacher;
                row.style.display = show ? '' : 'none';
                if (show) visible++;
            });
            var countEl = document.getElementById(
                document.getElementById('teacher-tab').classList.contains('active') ? 'teacherCount' : 'studentCount');
            countEl.textContent = 'Showing ' + (visible > 0 ? '1-' + visible : '0') + ' of ' + visible + ' evaluations';
        }

        document.getElementById('searchInput').addEventListener('input', applyFilters);
        document.getElementById('teacherFilter').addEventListener('change', applyFilters);

        function exportCsv() {
            var table = getActiveTable();
            var rows = Array.from(table.querySelectorAll('tr')).filter(function(r) { return r.style.display !== 'none'; });
            var csv = rows.map(function(row) {
                return Array.from(row.querySelectorAll('th,td')).map(function(cell) {
                    return '"' + (cell.textContent || '').replace(/"/g, '""').trim() + '"';
                }).join(',');
            }).join('\n');
            var blob = new Blob([csv], { type: 'text/csv' });
            var a = document.createElement('a');
            a.href = URL.createObjectURL(blob);
            a.download = 'evaluation-records.csv';
            a.click();
        }
    </script>
</body>
</html>
