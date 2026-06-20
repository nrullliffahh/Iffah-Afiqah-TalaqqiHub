<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%
    // Auth check
    if (session == null || session.getAttribute("adminId") == null) {
        response.sendRedirect(request.getContextPath() + "/admin/login");
        return;
    }

    // Database variables
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    // Initialize variables with defaults
    int totalStudents = 0;
    int totalSessions = 0;
    double attendanceRate = 0.0;
    int totalPresent = 0;
    int totalAbsent = 0;
    int lateSessions = 0;
    
    List<Map<String, Object>> attendanceRecords = new ArrayList<>();
    Map<String, int[]> monthlyStats = new LinkedHashMap<>();
    
    String adminName = (String) session.getAttribute("adminName");
    if (adminName == null) adminName = "Admin Manager";
    
    try {
        conn = DBConnection.getConnection();
        if (conn != null) {
            // Get total students
            pstmt = conn.prepareStatement("SELECT COUNT(*) as total FROM student WHERE studentStatus = 'Active'");
            rs = pstmt.executeQuery();
            if (rs.next()) {
                totalStudents = rs.getInt("total");
            }
            rs.close();
            pstmt.close();
            
            // Get total sessions
            pstmt = conn.prepareStatement("SELECT COUNT(*) as total FROM classschedule");
            rs = pstmt.executeQuery();
            if (rs.next()) {
                totalSessions = rs.getInt("total");
            }
            rs.close();
            pstmt.close();
            
            // Get attendance statistics (Present, Absent, Late counted separately)
            String attendanceQuery = "SELECT " +
                "COUNT(CASE WHEN attendanceStatus = 'Present' THEN 1 END) as present, " +
                "COUNT(CASE WHEN attendanceStatus = 'Absent' THEN 1 END) as absent, " +
                "COUNT(CASE WHEN attendanceStatus = 'Late' THEN 1 END) as late, " +
                "COUNT(*) as total " +
                "FROM attendance";
            pstmt = conn.prepareStatement(attendanceQuery);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                totalPresent = rs.getInt("present");
                totalAbsent = rs.getInt("absent");
                lateSessions = rs.getInt("late");
                int total = rs.getInt("total");
                if (total > 0) {
                    attendanceRate = ((double) totalPresent / total) * 100;
                }
            }
            rs.close();
            pstmt.close();
            
            // Get recent attendance records with proper column names
            String recordsQuery = "SELECT a.attendanceId, s.studentName, t.teacherName, a.attendanceDate, cs.startTime, cs.endTime, " +
                "a.joinTime, a.leaveTime, a.attendanceStatus, cs.className " +
                "FROM attendance a " +
                "LEFT JOIN student s ON a.studentId = s.studentId " +
                "LEFT JOIN teacher t ON a.teacherId = t.teacherId " +
                "LEFT JOIN classschedule cs ON a.scheduleId = cs.scheduleId " +
                "ORDER BY a.attendanceDate DESC LIMIT 10";
            pstmt = conn.prepareStatement(recordsQuery);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> record = new HashMap<>();
                record.put("studentName", rs.getString("studentName") != null ? rs.getString("studentName") : "Unknown");
                record.put("teacherName", rs.getString("teacherName") != null ? rs.getString("teacherName") : "Unknown");
                record.put("sessionDate", rs.getDate("attendanceDate"));
                record.put("startTime", rs.getTime("startTime"));
                record.put("endTime", rs.getTime("endTime"));
                record.put("joinTime", rs.getTime("joinTime"));
                record.put("leaveTime", rs.getTime("leaveTime"));
                record.put("status", rs.getString("attendanceStatus"));
                record.put("classType", rs.getString("className") != null ? rs.getString("className") : "General Class");
                attendanceRecords.add(record);
            }
            rs.close();
            pstmt.close();
            
            // Get monthly attendance trend (last 6 months) — Present / Absent / Late separate
            String monthlyQuery = "SELECT DATE_FORMAT(a.attendanceDate, '%b') as month, " +
                "SUM(CASE WHEN a.attendanceStatus = 'Present' THEN 1 ELSE 0 END) as present, " +
                "SUM(CASE WHEN a.attendanceStatus = 'Absent' THEN 1 ELSE 0 END) as absent, " +
                "SUM(CASE WHEN a.attendanceStatus = 'Late' THEN 1 ELSE 0 END) as late " +
                "FROM attendance a " +
                "WHERE a.attendanceDate >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) " +
                "GROUP BY DATE_FORMAT(a.attendanceDate, '%Y-%m') " +
                "ORDER BY DATE_FORMAT(a.attendanceDate, '%Y-%m') ASC LIMIT 6";
            pstmt = conn.prepareStatement(monthlyQuery);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                String month = rs.getString("month");
                monthlyStats.put(month, new int[] {
                    rs.getInt("present"),
                    rs.getInt("absent"),
                    rs.getInt("late")
                });
            }
            rs.close();
            pstmt.close();
        }
    } catch (SQLException e) {
        System.err.println("Error fetching attendance data: " + e.getMessage());
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Attendance Analytics - TalaqqiHub Admin</title>
    
    <!-- Bootstrap 5 CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <%@ include file="/WEB-INF/views/includes/adminLayoutStyles.jsp" %>

    <!-- Chart.js CDN -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.js"></script>

    <style>
        .page-header {
            margin-bottom: 40px;
        }

        /* ==================== STAT CARDS ==================== */
        .stats-container {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 24px;
            margin-bottom: 40px;
        }

        .stat-card {
            background: white;
            border-radius: 20px;
            padding: 28px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
            display: flex;
            align-items: center;
            gap: 20px;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 28px rgba(0, 0, 0, 0.12);
        }

        .stat-icon-box {
            width: 70px;
            height: 70px;
            border-radius: 16px;
            background: linear-gradient(135deg, #0f766e 0%, #6d28d9 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 32px;
            flex-shrink: 0;
        }

        .stat-icon-box.green {
            background: linear-gradient(135deg, #34D399 0%, #10B981 100%);
        }

        .stat-icon-box.red {
            background: linear-gradient(135deg, #F87171 0%, #EF4444 100%);
        }

        .stat-icon-box.orange {
            background: linear-gradient(135deg, #FBBF24 0%, #F59E0B 100%);
        }

        .stat-content {
            flex: 1;
        }

        .stat-number {
            font-size: 32px;
            font-weight: 700;
            color: #1E293B;
            line-height: 1;
            margin-bottom: 8px;
        }

        .stat-label {
            font-size: 13px;
            color: #64748B;
            font-weight: 500;
        }

        .stat-description {
            font-size: 12px;
            color: #94A3B8;
            margin-top: 3px;
        }

        /* ==================== ANALYTICS SECTION ==================== */
        .analytics-container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
            margin-bottom: 40px;
        }

        .analytics-card {
            background: white;
            border-radius: 20px;
            padding: 28px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
        }

        .card-title {
            font-size: 16px;
            font-weight: 700;
            color: #1E293B;
            margin-bottom: 24px;
        }

        .donut-chart-container {
            display: flex;
            justify-content: center;
            align-items: center;
            position: relative;
            margin-bottom: 24px;
            height: 280px;
        }

        .donut-summary {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 16px;
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #E2E8F0;
        }

        .summary-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px;
            background-color: #F8FAFC;
            border-radius: 12px;
        }

        .summary-item.absent {
            background-color: #FEE2E2;
        }

        .summary-item.late {
            background-color: #FEF3C7;
        }

        .summary-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background-color: #10B981;
            flex-shrink: 0;
        }

        .summary-dot.absent {
            background-color: #EF4444;
        }

        .summary-dot.late {
            background-color: #F59E0B;
        }

        .summary-text {
            flex: 1;
        }

        .summary-label {
            font-size: 12px;
            color: #64748B;
            display: block;
        }

        .summary-value {
            font-size: 18px;
            font-weight: 700;
            color: #1E293B;
        }

        /* ==================== TREND BARS ==================== */
        .trend-item {
            margin-bottom: 20px;
        }

        .trend-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
        }

        .trend-month {
            font-size: 14px;
            font-weight: 600;
            color: #1E293B;
        }

        .trend-count {
            font-size: 12px;
            color: #64748B;
            font-weight: 500;
        }

        .trend-bar {
            height: 24px;
            background-color: #E2E8F0;
            border-radius: 12px;
            overflow: hidden;
            display: flex;
            align-items: center;
        }

        .trend-bar-fill {
            height: 100%;
            background: linear-gradient(90deg, #10B981 0%, #10B981 100%);
            border-radius: 12px 0 0 12px;
            display: flex;
            align-items: center;
            justify-content: flex-end;
            padding-right: 8px;
        }

        .trend-bar-late {
            height: 100%;
            background-color: #F59E0B;
        }

        .trend-bar-absent {
            height: 100%;
            background-color: #FCA5A5;
            border-radius: 0 12px 12px 0;
        }

        .trend-percentage {
            font-size: 11px;
            font-weight: 700;
            color: white;
        }

        .trend-legend {
            display: flex;
            gap: 20px;
            justify-content: center;
            padding-top: 20px;
            border-top: 1px solid #E2E8F0;
            margin-top: 24px;
        }

        .legend-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            color: #1E293B;
            font-weight: 500;
        }

        .legend-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background-color: #10B981;
        }

        .legend-dot.absent {
            background-color: #EF4444;
        }

        .legend-dot.late {
            background-color: #F59E0B;
        }

        /* ==================== TABLE SECTION ==================== */
        .table-section {
            background: white;
            border-radius: 20px;
            padding: 28px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
        }

        .table-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
        }

        .table-title {
            font-size: 16px;
            font-weight: 700;
            color: #1E293B;
        }

        .table-actions {
            display: flex;
            gap: 12px;
            align-items: center;
        }

        .action-btn {
            padding: 10px 16px;
            border-radius: 10px;
            border: 1px solid #E2E8F0;
            background: white;
            color: #64748B;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .action-btn:hover {
            border-color: #CBD5E1;
            color: #1E293B;
        }

        .action-btn.primary {
            background: linear-gradient(135deg, #0f766e 0%, #6d28d9 100%);
            color: white;
            border: none;
        }

        .action-btn.primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(236, 72, 153, 0.4);
        }

        /* ==================== FILTERS ==================== */
        .filters-row {
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1fr 1fr;
            gap: 16px;
            margin-bottom: 24px;
        }

        .search-input-wrapper {
            position: relative;
        }

        .search-input {
            width: 100%;
            padding: 10px 16px 10px 40px;
            border: 1px solid #E2E8F0;
            border-radius: 10px;
            font-size: 13px;
            transition: border 0.3s ease;
        }

        .search-input:focus {
            outline: none;
            border-color: #6d28d9;
            box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.1);
        }

        .search-icon {
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: #94A3B8;
            font-size: 14px;
        }

        .form-select {
            padding: 10px 12px;
            border: 1px solid #E2E8F0;
            border-radius: 10px;
            font-size: 13px;
            color: #1E293B;
        }

        .form-select:focus {
            border-color: #6d28d9;
            box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.1);
            outline: none;
        }

        .date-input {
            padding: 10px 12px;
            border: 1px solid #E2E8F0;
            border-radius: 10px;
            font-size: 13px;
            color: #1E293B;
            cursor: pointer;
        }

        .date-input:focus {
            border-color: #6d28d9;
            box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.1);
            outline: none;
        }
        
        .date-input::placeholder {
            color: #CBD5E1;
        }

        /* ==================== TABLE ==================== */
        .records-info {
            font-size: 13px;
            color: #64748B;
            margin-bottom: 16px;
            font-weight: 500;
        }

        .table-responsive {
            overflow-x: auto;
        }

        .records-table {
            width: 100%;
            border-collapse: collapse;
        }

        .records-table thead tr {
            background-color: #F8FAFC;
            border-bottom: 1px solid #E2E8F0;
        }

        .records-table th {
            padding: 14px 16px;
            text-align: left;
            font-size: 12px;
            font-weight: 700;
            color: #64748B;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .records-table td {
            padding: 16px;
            border-bottom: 1px solid #E2E8F0;
            font-size: 13px;
            color: #1E293B;
        }

        .records-table tbody tr:hover {
            background-color: #F8FAFC;
        }

        .status-badge {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            border: 2px solid;
        }

        .status-badge.present {
            background-color: #ECFDF5;
            border-color: #10B981;
            color: #047857;
        }

        .status-badge.absent {
            background-color: #FEF2F2;
            border-color: #EF4444;
            color: #DC2626;
        }

        .status-badge.late {
            background-color: #FFFBEB;
            border-color: #F59E0B;
            color: #D97706;
        }

        /* ==================== RESPONSIVE ==================== */
        @media (max-width: 1400px) {
            .stats-container {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 992px) {
            .analytics-container {
                grid-template-columns: 1fr;
            }

            .stats-container {
                grid-template-columns: 1fr;
            }

            .filters-row {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/includes/adminSidebar.jsp">
        <jsp:param name="activePage" value="attendance"/>
    </jsp:include>

    <div class="main-content">
        <jsp:include page="/WEB-INF/views/includes/adminTopNavbar.jsp">
            <jsp:param name="pageTitle" value="Attendance Analytics"/>
        </jsp:include>

        <div class="page-content">
            <!-- PAGE HEADER -->
            <div class="page-header">
                <h1 class="page-title">Attendance Analytics</h1>
                <p class="page-subtitle">Monitor attendance performance across the entire TalaqqiHub platform</p>
            </div>

            <!-- STAT CARDS - ROW 1 -->
            <div class="stats-container">
                <div class="stat-card">
                    <div class="stat-icon-box">
                        <i class="fas fa-users"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-number"><%= totalStudents %></div>
                        <div class="stat-label">Total Students</div>
                        <div class="stat-description">Enrolled on platform</div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon-box">
                        <i class="fas fa-video"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-number"><%= totalSessions %></div>
                        <div class="stat-label">Total Sessions</div>
                        <div class="stat-description">All-time sessions</div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon-box">
                        <i class="fas fa-percent"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-number"><%= String.format("%.1f%%", attendanceRate) %></div>
                        <div class="stat-label">Overall Attendance Rate</div>
                        <div class="stat-description">Platform-wide average</div>
                    </div>
                </div>
            </div>

            <!-- STAT CARDS - ROW 2 -->
            <div class="stats-container">
                <div class="stat-card">
                    <div class="stat-icon-box green">
                        <i class="fas fa-check-circle"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-number"><%= totalPresent %></div>
                        <div class="stat-label">Total Present</div>
                        <div class="stat-description">Students attended</div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon-box red">
                        <i class="fas fa-times-circle"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-number"><%= totalAbsent %></div>
                        <div class="stat-label">Total Absent</div>
                        <div class="stat-description">Students missed</div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon-box orange">
                        <i class="fas fa-clock"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-number"><%= lateSessions %></div>
                        <div class="stat-label">Late Sessions</div>
                        <div class="stat-description">Joined after start time</div>
                    </div>
                </div>
            </div>

            <!-- ANALYTICS SECTION -->
            <div class="analytics-container">
                <!-- LEFT CARD: DONUT CHART -->
                <div class="analytics-card">
                    <div class="card-title">Attendance Distribution</div>
                    <div class="donut-chart-container">
                        <canvas id="attendanceChart" style="max-height: 250px;"></canvas>
                    </div>
                    <div style="text-align: center; margin: 20px 0;"></div>
                    <div class="donut-summary">
                        <div class="summary-item">
                            <div class="summary-dot"></div>
                            <div class="summary-text">
                                <span class="summary-label">Present</span>
                                <span class="summary-value"><%= totalPresent %></span>
                            </div>
                        </div>
                        <div class="summary-item absent">
                            <div class="summary-dot absent"></div>
                            <div class="summary-text">
                                <span class="summary-label">Absent</span>
                                <span class="summary-value"><%= totalAbsent %></span>
                            </div>
                        </div>
                        <div class="summary-item late">
                            <div class="summary-dot late"></div>
                            <div class="summary-text">
                                <span class="summary-label">Late</span>
                                <span class="summary-value"><%= lateSessions %></span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- RIGHT CARD: TREND BARS -->
                <div class="analytics-card">
                    <div class="card-title">Attendance Trend (Last 6 Months)</div>
                    
                    <%
                        List<String> sortedMonths = new ArrayList<>(monthlyStats.keySet());
                        if (sortedMonths.isEmpty()) {
                    %>
                    <p class="text-muted text-center py-3">No attendance data for the last 6 months.</p>
                    <%
                        } else {
                            for (String month : sortedMonths) {
                                int[] stats = monthlyStats.get(month);
                                int p = stats[0];
                                int a = stats[1];
                                int l = stats[2];
                                int total = p + a + l;
                                int pPct = total > 0 ? (p * 100) / total : 0;
                                int lPct = total > 0 ? (l * 100) / total : 0;
                                int aPct = total > 0 ? (a * 100) / total : 0;
                    %>
                    <div class="trend-item">
                        <div class="trend-header">
                            <span class="trend-month"><%= month %></span>
                            <span class="trend-count">P <%= p %> · L <%= l %> · A <%= a %></span>
                        </div>
                        <div class="trend-bar">
                            <% if (pPct > 0) { %>
                            <div class="trend-bar-fill" style="width: <%= pPct %>%;">
                                <% if (pPct >= 12) { %><span class="trend-percentage"><%= pPct %>%</span><% } %>
                            </div>
                            <% } %>
                            <% if (lPct > 0) { %>
                            <div class="trend-bar-late" style="width: <%= lPct %>%;">
                                <% if (lPct >= 12) { %><span class="trend-percentage"><%= lPct %>%</span><% } %>
                            </div>
                            <% } %>
                            <% if (aPct > 0) { %>
                            <div class="trend-bar-absent" style="width: <%= aPct %>%;">
                                <% if (aPct >= 12) { %><span class="trend-percentage"><%= aPct %>%</span><% } %>
                            </div>
                            <% } %>
                        </div>
                    </div>
                    <%
                            }
                        }
                    %>

                    <div class="trend-legend">
                        <div class="legend-item">
                            <div class="legend-dot"></div>
                            <span>Present</span>
                        </div>
                        <div class="legend-item">
                            <div class="legend-dot late"></div>
                            <span>Late</span>
                        </div>
                        <div class="legend-item">
                            <div class="legend-dot absent"></div>
                            <span>Absent</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- TABLE SECTION -->
            <div class="table-section">
                <div class="table-header">
                    <div class="table-title">Attendance Records</div>
                    <div class="table-actions">
                        <button class="action-btn primary">
                            <i class="fas fa-file-pdf"></i> Export PDF
                        </button>
                        <button class="action-btn">CSV</button>
                        <button class="action-btn">Excel</button>
                        <button class="action-btn">
                            <i class="fas fa-print"></i> Print
                        </button>
                    </div>
                </div>

                <!-- FILTERS ROW -->
                <div class="filters-row">
                    <div class="search-input-wrapper">
                        <i class="fas fa-search search-icon"></i>
                        <input type="text" class="search-input" placeholder="Search student or teacher...">
                    </div>
                    <select class="form-select">
                        <option value="All Status">All Status</option>
                        <option value="Present">Present</option>
                        <option value="Absent">Absent</option>
                        <option value="Late">Late</option>
                    </select>
                    <select class="form-select">
                        <option value="All Teachers">All Teachers</option>
                        <option value="Ustadh Ibrahim Khan">Ustadh Ibrahim Khan</option>
                        <option value="Ustadha Maryam Yusuf">Ustadha Maryam Yusuf</option>
                        <option value="Ustadh Omar Abdullah">Ustadh Omar Abdullah</option>
                    </select>
                    <input type="text" class="date-input" placeholder="dd/mm/yyyy">
                    <input type="text" class="date-input" placeholder="dd/mm/yyyy">
                </div>

                <div class="records-info">Showing 1-<%= Math.min(attendanceRecords.size(), 10) %> of <%= attendanceRecords.size() %> records</div>

                <!-- TABLE -->
                <div class="table-responsive">
                    <table class="records-table">
                        <thead>
                            <tr>
                                <th>Student Name</th>
                                <th>Teacher Name</th>
                                <th>Session Date</th>
                                <th>Time</th>
                                <th>Class Type</th>
                                <th>Status</th>
                                <th>Join Time</th>
                                <th>Leave Time</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                for (Map<String, Object> record : attendanceRecords) {
                                    String status = (String) record.get("status");
                                    String statusClass = status != null && status.equals("Present") ? "present" : 
                                                       status != null && status.equals("Absent") ? "absent" : "late";
                            %>
                            <tr>
                                <td><%= record.get("studentName") %></td>
                                <td><%= record.get("teacherName") %></td>
                                <td><%= record.get("sessionDate") %></td>
                                <td><%= record.get("startTime") %> - <%= record.get("endTime") %></td>
                                <td><%= record.get("classType") %></td>
                                <td><span class="status-badge <%= statusClass %>"><%= status %></span></td>
                                <td><%= record.get("joinTime") != null ? record.get("joinTime") : "-" %></td>
                                <td><%= record.get("leaveTime") != null ? record.get("leaveTime") : "-" %></td>
                            </tr>
                            <%
                                }
                                
                                // Show sample data if no records found
                                if (attendanceRecords.isEmpty()) {
                            %>
                            <tr>
                                <td>Ahmad Hassan</td>
                                <td>Ustadh Ibrahim Khan</td>
                                <td>Dec 28, 2024</td>
                                <td>10:00 AM - 10:15 AM</td>
                                <td>Quran Recitation & Tajweed</td>
                                <td><span class="status-badge present">Present</span></td>
                                <td>10:00 AM</td>
                                <td>10:15 AM</td>
                            </tr>
                            <tr>
                                <td>Fatima Ali</td>
                                <td>Ustadh Ibrahim Khan</td>
                                <td>Dec 28, 2024</td>
                                <td>2:00 PM - 2:15 PM</td>
                                <td>Quran Recitation & Tajweed</td>
                                <td><span class="status-badge present">Present</span></td>
                                <td>2:01 PM</td>
                                <td>2:16 PM</td>
                            </tr>
                            <tr>
                                <td>Aisha Rahman</td>
                                <td>Ustadha Maryam Yusuf</td>
                                <td>Dec 27, 2024</td>
                                <td>4:00 PM - 4:15 PM</td>
                                <td>Quran Recitation & Tajweed</td>
                                <td><span class="status-badge absent">Absent</span></td>
                                <td>-</td>
                                <td>-</td>
                            </tr>
                            <tr>
                                <td>Muhammad Yusuf</td>
                                <td>Ustadh Omar Abdullah</td>
                                <td>Dec 29, 2024</td>
                                <td>11:00 AM - 11:15 AM</td>
                                <td>Quran Recitation & Tajweed</td>
                                <td><span class="status-badge present">Present</span></td>
                                <td>11:02 AM</td>
                                <td>11:14 AM</td>
                            </tr>
                            <tr>
                                <td>Sarah Khan</td>
                                <td>Ustadh Ibrahim Khan</td>
                                <td>Dec 28, 2024</td>
                                <td>3:30 PM - 3:45 PM</td>
                                <td>Quran Recitation & Tajweed</td>
                                <td><span class="status-badge late">Late</span></td>
                                <td>3:32 PM</td>
                                <td>3:45 PM</td>
                            </tr>
                            <tr>
                                <td>Omar Hassan</td>
                                <td>Ustadha Maryam Yusuf</td>
                                <td>Dec 27, 2024</td>
                                <td>5:00 PM - 5:15 PM</td>
                                <td>Quran Recitation & Tajweed</td>
                                <td><span class="status-badge present">Present</span></td>
                                <td>5:00 PM</td>
                                <td>5:15 PM</td>
                            </tr>
                            <tr>
                                <td>Zainab Ali</td>
                                <td>Ustadh Omar Abdullah</td>
                                <td>Dec 29, 2024</td>
                                <td>1:00 PM - 1:15 PM</td>
                                <td>Quran Recitation & Tajweed</td>
                                <td><span class="status-badge absent">Absent</span></td>
                                <td>-</td>
                                <td>-</td>
                            </tr>
                            <tr>
                                <td>Hassan Ahmed</td>
                                <td>Ustadh Ibrahim Khan</td>
                                <td>Dec 28, 2024</td>
                                <td>11:30 AM - 11:45 AM</td>
                                <td>Quran Recitation & Tajweed</td>
                                <td><span class="status-badge present">Present</span></td>
                                <td>11:30 AM</td>
                                <td>11:45 AM</td>
                            </tr>
                            <tr>
                                <td>Mariam Hassan</td>
                                <td>Ustadha Maryam Yusuf</td>
                                <td>Dec 27, 2024</td>
                                <td>2:30 PM - 2:45 PM</td>
                                <td>Quran Recitation & Tajweed</td>
                                <td><span class="status-badge present">Present</span></td>
                                <td>2:31 PM</td>
                                <td>2:44 PM</td>
                            </tr>
                            <tr>
                                <td>Ibrahim Khan</td>
                                <td>Ustadh Omar Abdullah</td>
                                <td>Dec 29, 2024</td>
                                <td>2:00 PM - 2:15 PM</td>
                                <td>Quran Recitation & Tajweed</td>
                                <td><span class="status-badge late">Late</span></td>
                                <td>2:05 PM</td>
                                <td>2:16 PM</td>
                            </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- For PDF Export -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    
    <!-- For Excel Export (SheetJS) -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.min.js"></script>
    
    <!-- Flatpickr Date Picker -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>

    <script>
        // Store original table data
        const originalTableRows = Array.from(document.querySelectorAll('.records-table tbody tr'));
        
        // ========== DATE PICKER INITIALIZATION ==========
        
        const dateInputs = document.querySelectorAll('.date-input');
        dateInputs.forEach((input, index) => {
            flatpickr(input, {
                mode: 'single',
                dateFormat: 'd/m/Y',
                placeholder: index === 0 ? 'From Date' : 'To Date',
                onChange: function(selectedDates, dateStr, instance) {
                    filterTable();
                }
            });
        });
        
        // ========== EXPORT FUNCTIONS ==========
        
        // Export as PDF
        function exportPDF() {
            const element = document.querySelector('.records-table');
            const opt = {
                margin: 10,
                filename: 'attendance_records.pdf',
                image: { type: 'jpeg', quality: 0.98 },
                html2canvas: { scale: 2 },
                jsPDF: { orientation: 'landscape', unit: 'mm', format: 'a4' }
            };
            html2pdf().set(opt).from(element).save();
            showNotification('PDF exported successfully!');
        }
        
        // Export as CSV
        function exportCSV() {
            const table = document.querySelector('.records-table');
            let csv = [];
            
            // Get headers
            const headers = [];
            table.querySelectorAll('thead th').forEach(th => {
                headers.push('"' + th.textContent.trim() + '"');
            });
            csv.push(headers.join(','));
            
            // Get visible data rows only
            table.querySelectorAll('tbody tr').forEach(tr => {
                if (tr.style.display !== 'none') {
                    const row = [];
                    tr.querySelectorAll('td').forEach(td => {
                        let text = td.textContent.trim();
                        row.push('"' + text + '"');
                    });
                    csv.push(row.join(','));
                }
            });
            
            const csvContent = csv.join('\n');
            downloadFile(csvContent, 'attendance_records.csv', 'text/csv');
            showNotification('CSV exported successfully!');
        }
        
        // Export as Excel
        function exportExcel() {
            const table = document.querySelector('.records-table');
            const wb = XLSX.utils.table_to_book(table);
            XLSX.writeFile(wb, "attendance_records.xlsx");
            showNotification('Excel file exported successfully!');
        }
        
        // Helper function to download file
        function downloadFile(content, filename, mimeType) {
            const blob = new Blob([content], { type: mimeType });
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = filename;
            document.body.appendChild(a);
            a.click();
            window.URL.revokeObjectURL(url);
            document.body.removeChild(a);
        }
        
        // Print functionality
        function printTable() {
            const printWindow = window.open('', '', 'height=600,width=800');
            const tableHTML = document.querySelector('.records-table').outerHTML;
            
            printWindow.document.write(`
                <!DOCTYPE html>
                <html>
                <head>
                    <title>Attendance Records</title>
                    <style>
                        body { font-family: 'Poppins', sans-serif; margin: 20px; }
                        h1 { color: #1e293b; margin-bottom: 10px; }
                        p { color: #64748b; margin-bottom: 20px; font-size: 12px; }
                        table { width: 100%; border-collapse: collapse; }
                        th, td { border: 1px solid #ddd; padding: 10px; text-align: left; font-size: 12px; }
                        th { background-color: #f8fafc; font-weight: 600; }
                        tr:nth-child(even) { background-color: #f8fafc; }
                        .status-badge { padding: 5px 10px; border-radius: 20px; font-size: 11px; font-weight: 600;  }
                        .status-badge.present { background-color: #ecfdf5; color: #047857; }
                        .status-badge.absent { background-color: #fef2f2; color: #dc2626; }
                        .status-badge.late { background-color: #fffbeb; color: #d97706; }
                        @media print {
                            body { margin: 0; }
                        }
                    </style>
                </head>
                <body>
                    <h1>Attendance Records Report</h1>
                    <p>Generated on: ' + new Date().toLocaleString('en-US', { 
                        year: 'numeric', month: 'long', day: 'numeric', 
                        hour: '2-digit', minute: '2-digit', second: '2-digit' 
                    }) + '</p>
                    ' + tableHTML + '
                </body>
                </html>
            `);
            printWindow.document.close();
            setTimeout(() => {
                printWindow.focus();
                printWindow.print();
            }, 250);
        }
        
        // Show temporary notification
        function showNotification(message) {
            const notification = document.createElement('div');
            notification.textContent = message;
            notification.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                background-color: #10b981;
                color: white;
                padding: 12px 20px;
                border-radius: 8px;
                font-weight: 500;
                z-index: 9999;
                animation: slideIn 0.3s ease;
            `;
            document.body.appendChild(notification);
            setTimeout(() => {
                notification.style.animation = 'slideOut 0.3s ease';
                setTimeout(() => notification.remove(), 300);
            }, 3000);
        }
        
        // ========== FILTER & SEARCH FUNCTIONS ==========
        
        function filterTable() {
            const searchInput = document.querySelector('.search-input').value.toLowerCase().trim();
            const statusSelects = document.querySelectorAll('.form-select');
            const statusSelect = statusSelects[0] ? statusSelects[0].value : 'All Status';
            const teacherSelect = statusSelects[1] ? statusSelects[1].value : 'All Teachers';
            const dateInputs = document.querySelectorAll('.date-input');
            const dateFromInput = dateInputs[0] ? dateInputs[0].value : '';
            const dateToInput = dateInputs[1] ? dateInputs[1].value : '';
            
            let visibleCount = 0;
            
            originalTableRows.forEach(row => {
                let show = true;
                
                // Search filter
                if (searchInput) {
                    const studentName = row.cells[0].textContent.toLowerCase();
                    const teacherName = row.cells[1].textContent.toLowerCase();
                    show = show && (studentName.includes(searchInput) || teacherName.includes(searchInput));
                }
                
                // Status filter
                if (statusSelect && statusSelect !== 'All Status') {
                    const status = row.cells[5].textContent.trim();
                    show = show && status === statusSelect;
                }
                
                // Teacher filter
                if (teacherSelect && teacherSelect !== 'All Teachers') {
                    const teacher = row.cells[1].textContent.trim();
                    show = show && teacher === teacherSelect;
                }
                
                // Date range filter
                if (dateFromInput || dateToInput) {
                    const cellDate = row.cells[2].textContent.trim();
                    const rowDate = parseDate(cellDate);
                    
                    if (dateFromInput) {
                        const fromDate = parseCustomDate(dateFromInput);
                        show = show && rowDate >= fromDate;
                    }
                    
                    if (dateToInput) {
                        const toDate = parseCustomDate(dateToInput);
                        show = show && rowDate <= toDate;
                    }
                }
                
                row.style.display = show ? '' : 'none';
                if (show) visibleCount++;
            });
            
            // Update records count
            const recordsInfo = document.querySelector('.records-info');
            if (recordsInfo) {
                const total = originalTableRows.length;
                recordsInfo.textContent = `Showing 1-${visibleCount} of ${total} records`;
            }
        }
        
        function parseDate(dateStr) {
            // Handle formats like "Dec 28, 2024"
            const date = new Date(dateStr);
            return date;
        }
        
        function parseCustomDate(dateStr) {
            // Handle d/m/Y format
            const parts = dateStr.split('/');
            if (parts.length === 3) {
                return new Date(parts[2], parts[1] - 1, parts[0]);
            }
            return new Date();
        }
        
        // ========== EVENT LISTENERS ==========
        
        document.addEventListener('DOMContentLoaded', function() {
            // Export buttons
            document.querySelectorAll('.action-btn').forEach(btn => {
                btn.addEventListener('click', function(e) {
                    e.preventDefault();
                    const text = this.textContent.trim();
                    
                    if (text.includes('PDF')) {
                        exportPDF();
                    } else if (text === 'CSV') {
                        exportCSV();
                    } else if (text === 'Excel') {
                        exportExcel();
                    } else if (text.includes('Print')) {
                        printTable();
                    }
                });
            });
            
            // Filter inputs
            const searchInput = document.querySelector('.search-input');
            if (searchInput) {
                searchInput.addEventListener('keyup', filterTable);
            }
            
            document.querySelectorAll('.form-select').forEach(select => {
                select.addEventListener('change', filterTable);
            });
        });

        // Initialize Donut Chart
        const ctx = document.getElementById('attendanceChart');
        if (ctx) {
            const chart = new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: ['Present', 'Absent', 'Late'],
                    datasets: [{
                        data: [<%= totalPresent %>, <%= totalAbsent %>, <%= lateSessions %>],
                        backgroundColor: [
                            '#10B981',
                            '#FCA5A5',
                            '#F59E0B'
                        ],
                        borderColor: [
                            '#10B981',
                            '#FCA5A5',
                            '#F59E0B'
                        ],
                        borderWidth: 0,
                        borderRadius: 8
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        },
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                    const percentage = ((context.parsed / total) * 100).toFixed(1);
                                    return context.label + ': ' + context.parsed + ' (' + percentage + '%)';
                                }
                            }
                        }
                    }
                }
            });

            // Add text in center of donut
            const chartContainer = document.querySelector('.donut-chart-container');
            const centerText = document.createElement('div');
            centerText.style.cssText = `
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                text-align: center;
                pointer-events: none;
            `;
            const attendanceRate = <%= attendanceRate %>;
            centerText.innerHTML = `
                <div style="font-size: 32px; font-weight: 700; color: #1E293B;"><%= String.format("%.1f%%", attendanceRate) %></div>
                <div style="font-size: 13px; color: #64748B; margin-top: 4px;">Present</div>
            `;
            chartContainer.appendChild(centerText);
        }

        // Smooth hover effects on table rows
        document.querySelectorAll('.records-table tbody tr').forEach(row => {
            row.style.cursor = 'pointer';
            row.addEventListener('click', function() {
                console.log('Row clicked:', this.querySelectorAll('td')[0].textContent);
            });
        });
        
        // Add animation styles
        const style = document.createElement('style');
        style.textContent = `
            @keyframes slideIn {
                from { transform: translateX(400px); opacity: 0; }
                to { transform: translateX(0); opacity: 1; }
            }
            @keyframes slideOut {
                from { transform: translateX(0); opacity: 1; }
                to { transform: translateX(400px); opacity: 0; }
            }
        `;
        document.head.appendChild(style);
    </script>
</body>
</html>
