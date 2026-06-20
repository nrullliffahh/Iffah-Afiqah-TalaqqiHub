<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="model.Announcement" %>
<%
    String adminName = (String) session.getAttribute("adminName");
    if (adminName == null) adminName = "Admin Manager";
    
    int totalActiveStudents = request.getAttribute("totalActiveStudents") != null ? (int) request.getAttribute("totalActiveStudents") : 0;
    int totalActiveTeachers = request.getAttribute("totalActiveTeachers") != null ? (int) request.getAttribute("totalActiveTeachers") : 0;
    int totalSessions = request.getAttribute("totalSessions") != null ? (int) request.getAttribute("totalSessions") : 0;
    int upcomingSessions = request.getAttribute("upcomingSessions") != null ? (int) request.getAttribute("upcomingSessions") : 0;
    int completedSessions = request.getAttribute("completedSessions") != null ? (int) request.getAttribute("completedSessions") : 0;
    int cancelledSessions = request.getAttribute("cancelledSessions") != null ? (int) request.getAttribute("cancelledSessions") : 0;
    
    int presentCount = request.getAttribute("presentCount") != null ? (int) request.getAttribute("presentCount") : 0;
    int absentCount = request.getAttribute("absentCount") != null ? (int) request.getAttribute("absentCount") : 0;
    int lateCount = request.getAttribute("lateCount") != null ? (int) request.getAttribute("lateCount") : 0;
    double attendanceRate = request.getAttribute("attendanceRate") != null ? (double) request.getAttribute("attendanceRate") : 0.0;
    
    double avgTeacherRating = request.getAttribute("avgTeacherRating") != null ? (double) request.getAttribute("avgTeacherRating") : 0.0;
    double avgStudentPerformance = request.getAttribute("avgStudentPerformance") != null ? (double) request.getAttribute("avgStudentPerformance") : 0.0;
    
    List<Map<String, Object>> recentActivities = (List<Map<String, Object>>) request.getAttribute("recentActivities");
    List<Announcement> recentAnnouncements = (List<Announcement>) request.getAttribute("recentAnnouncements");

    double attendanceOffset = 502.4 - (502.4 * attendanceRate / 100.0);
    int teacherRatingWidth = (int) Math.min(100, Math.max(0, (avgTeacherRating / 5.0) * 100));
    int studentPerfWidth = (int) Math.min(100, Math.max(0, (avgStudentPerformance / 5.0) * 100));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - TalaqqiHub</title>
    <%@ include file="/WEB-INF/views/includes/adminLayoutStyles.jsp" %>
    <style>
        .attendance-ring-wrap { display: flex; justify-content: center; margin-bottom: 24px; }
        .attendance-ring { position: relative; width: 192px; height: 192px; }
        .attendance-ring svg { width: 192px; height: 192px; transform: rotate(-90deg); }
        .attendance-ring-center { position: absolute; inset: 0; display: flex; flex-direction: column; align-items: center; justify-content: center; }
        .attendance-rate-value { font-size: 36px; font-weight: 700; color: #1E293B; }
        .attendance-rate-label { font-size: 13px; color: #64748B; }
        .attendance-mini-stats { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 24px; }
        .attendance-mini-stat { border-radius: 12px; padding: 16px; text-align: center; }
        .attendance-mini-stat.present { background: #ECFDF5; border: 1px solid #A7F3D0; }
        .attendance-mini-stat.late { background: #FFFBEB; border: 1px solid #FDE68A; }
        .attendance-mini-stat.absent { background: #FEF2F2; border: 1px solid #FECACA; }
        .attendance-mini-stat .label { font-size: 13px; font-weight: 600; margin-bottom: 4px; }
        .attendance-mini-stat.present .label, .attendance-mini-stat.present .value { color: #059669; }
        .attendance-mini-stat.late .label, .attendance-mini-stat.late .value { color: #D97706; }
        .attendance-mini-stat.absent .label, .attendance-mini-stat.absent .value { color: #DC2626; }
        .attendance-mini-stat .value { font-size: 28px; font-weight: 700; }
        .panel-note { text-align: center; font-size: 13px; color: #64748B; margin-bottom: 16px; }
        .panel-icon-head { display: flex; align-items: center; gap: 12px; margin-bottom: 24px; }
        .panel-icon { width: 40px; height: 40px; border-radius: 12px; background: var(--admin-gradient); color: white; display: flex; align-items: center; justify-content: center; font-size: 18px; flex-shrink: 0; }
        .rating-item { margin-bottom: 24px; }
        .rating-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
        .rating-label { font-size: 13px; font-weight: 600; color: #64748B; }
        .rating-score { font-size: 24px; font-weight: 700; color: #1E293B; }
        .rating-score span { font-size: 13px; color: #94A3B8; font-weight: 500; }
        .rating-stars { color: #F59E0B; font-size: 16px; letter-spacing: 2px; margin-bottom: 8px; }
        .rating-track { height: 8px; background: #F1F5F9; border-radius: 4px; overflow: hidden; }
        .rating-fill { height: 100%; background: var(--admin-gradient-h); border-radius: 4px; }
        .btn-block { display: block; width: 100%; text-align: center; }
        .activity-list { display: flex; flex-direction: column; gap: 16px; }
        .activity-item { display: flex; align-items: flex-start; gap: 12px; padding-bottom: 16px; border-bottom: 1px solid #F1F5F9; }
        .activity-item:last-child { padding-bottom: 0; border-bottom: none; }
        .activity-icon { width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex-shrink: 0; font-size: 14px; }
        .activity-icon.cancelled { background: #FEE2E2; color: #DC2626; }
        .activity-icon.completed { background: #D1FAE5; color: #059669; }
        .activity-icon.upcoming { background: #DBEAFE; color: #2563EB; }
        .activity-icon.default { background: #F1F5F9; color: #64748B; }
        .activity-text { font-size: 13px; color: #1E293B; }
        .activity-date { font-size: 12px; color: #94A3B8; margin-top: 4px; }
        .announcement-list { display: flex; flex-direction: column; gap: 16px; }
        .announcement-meta { display: flex; flex-wrap: wrap; gap: 16px; font-size: 13px; color: #64748B; margin-top: 8px; }
        .announcement-meta span { display: inline-flex; align-items: center; gap: 6px; }
        .quick-actions-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; }
        .quick-action-card { border-radius: 20px; padding: 24px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); cursor: pointer; transition: box-shadow .2s; }
        .quick-action-card:hover { box-shadow: 0 8px 28px rgba(0,0,0,0.12); }
        .quick-action-card.primary { background: var(--admin-gradient); color: white; box-shadow: 0 2px 10px rgba(15,118,110,0.18); }
        .quick-action-card.secondary { background: white; border: 1px solid #F1F5F9; }
        .quick-action-icon { width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 22px; margin-bottom: 16px; }
        .quick-action-card.primary .quick-action-icon { background: rgba(255,255,255,0.25); color: white; }
        .quick-action-card.secondary .quick-action-icon { background: var(--admin-accent-light); color: var(--admin-teal); }
        .quick-action-title { font-size: 16px; font-weight: 600; margin-bottom: 6px; }
        .quick-action-card.secondary .quick-action-title { color: #1E293B; }
        .quick-action-desc { font-size: 13px; }
        .quick-action-card.primary .quick-action-desc { color: rgba(255,255,255,0.9); }
        .quick-action-card.secondary .quick-action-desc { color: #64748B; }
        .empty-state { font-size: 13px; color: #94A3B8; }
        @media (max-width: 1200px) {
            .quick-actions-grid { grid-template-columns: 1fr 1fr; }
            .attendance-mini-stats { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/includes/adminSidebar.jsp">
        <jsp:param name="activePage" value="dashboard"/>
    </jsp:include>

    <div class="main-content">
        <jsp:include page="/WEB-INF/views/includes/adminTopNavbar.jsp">
            <jsp:param name="pageTitle" value="Admin Dashboard"/>
        </jsp:include>

        <div class="page-content">
            <h1 class="page-title">Welcome back, <%= adminName %>!</h1>
            <p class="page-subtitle">Here's an overview of TalaqqiHub platform activity</p>

            <h2 class="section-title">Platform Overview</h2>
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon"><i class="fas fa-users"></i></div>
                    <div>
                        <div class="stat-value"><%= totalActiveStudents %></div>
                        <div class="stat-label">Total Active Students</div>
                        <div class="stat-hint">Currently enrolled</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon purple"><i class="fas fa-chalkboard-user"></i></div>
                    <div>
                        <div class="stat-value"><%= totalActiveTeachers %></div>
                        <div class="stat-label">Total Active Teachers</div>
                        <div class="stat-hint">Currently teaching</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon"><i class="fas fa-video"></i></div>
                    <div>
                        <div class="stat-value"><%= totalSessions %></div>
                        <div class="stat-label">Total Talaqqi Sessions</div>
                        <div class="stat-hint">All-time sessions</div>
                    </div>
                </div>
            </div>

            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon blue"><i class="fas fa-clock"></i></div>
                    <div>
                        <div class="stat-value" style="color:#3B82F6;"><%= upcomingSessions %></div>
                        <div class="stat-label">Upcoming Sessions</div>
                        <div class="stat-hint">Scheduled sessions</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon green"><i class="fas fa-check-circle"></i></div>
                    <div>
                        <div class="stat-value" style="color:#10B981;"><%= completedSessions %></div>
                        <div class="stat-label">Completed Sessions</div>
                        <div class="stat-hint">Successfully finished</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon red"><i class="fas fa-times-circle"></i></div>
                    <div>
                        <div class="stat-value" style="color:#EF4444;"><%= cancelledSessions %></div>
                        <div class="stat-label">Cancelled Sessions</div>
                        <div class="stat-hint">Cancelled by users</div>
                    </div>
                </div>
            </div>

            <h2 class="section-title">Analytics Overview</h2>
            <div class="trends-grid">
                <div class="panel">
                    <div class="panel-icon-head">
                        <div class="panel-icon"><i class="fas fa-chart-pie"></i></div>
                        <div class="panel-title">Attendance Rate Overview</div>
                    </div>

                    <div class="attendance-ring-wrap">
                        <div class="attendance-ring">
                            <svg viewBox="0 0 192 192">
                                <circle cx="96" cy="96" r="80" stroke="#E2E8F0" stroke-width="24" fill="none"/>
                                <circle cx="96" cy="96" r="80" stroke="url(#attendanceGradient)" stroke-width="24" fill="none"
                                    stroke-dasharray="502.4" stroke-dashoffset="<%= attendanceOffset %>" stroke-linecap="round"/>
                                <defs>
                                    <linearGradient id="attendanceGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                                        <stop offset="0%" style="stop-color:#0f766e;stop-opacity:1" />
                                        <stop offset="100%" style="stop-color:#6d28d9;stop-opacity:1" />
                                    </linearGradient>
                                </defs>
                            </svg>
                            <div class="attendance-ring-center">
                                <div class="attendance-rate-value"><%= String.format("%.1f", attendanceRate) %>%</div>
                                <div class="attendance-rate-label">Attendance Rate</div>
                            </div>
                        </div>
                    </div>

                    <div class="attendance-mini-stats">
                        <div class="attendance-mini-stat present">
                            <div class="label">Present</div>
                            <div class="value"><%= presentCount %></div>
                        </div>
                        <div class="attendance-mini-stat late">
                            <div class="label">Late</div>
                            <div class="value"><%= lateCount %></div>
                        </div>
                        <div class="attendance-mini-stat absent">
                            <div class="label">Absent</div>
                            <div class="value"><%= absentCount %></div>
                        </div>
                    </div>

                    <p class="panel-note">Overall student attendance performance</p>
                    <a href="<%= request.getContextPath() %>/admin/attendance" class="btn-primary btn-block">View Full Attendance Analytics</a>
                </div>

                <div class="panel">
                    <div class="panel-icon-head">
                        <div class="panel-icon"><i class="fas fa-star"></i></div>
                        <div class="panel-title">Evaluation Analytics</div>
                    </div>

                    <div class="rating-item">
                        <div class="rating-header">
                            <span class="rating-label">Average Teacher Rating</span>
                            <span class="rating-score"><%= String.format("%.1f", avgTeacherRating) %> <span>/5.0</span></span>
                        </div>
                        <div class="rating-stars">
                            <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="far fa-star"></i>
                        </div>
                        <div class="rating-track">
                            <div class="rating-fill" style="width: <%= teacherRatingWidth %>%"></div>
                        </div>
                    </div>

                    <div class="rating-item">
                        <div class="rating-header">
                            <span class="rating-label">Average Student Performance</span>
                            <span class="rating-score"><%= String.format("%.1f", avgStudentPerformance) %> <span>/5.0</span></span>
                        </div>
                        <div class="rating-stars">
                            <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="far fa-star"></i>
                        </div>
                        <div class="rating-track">
                            <div class="rating-fill" style="width: <%= studentPerfWidth %>%"></div>
                        </div>
                    </div>

                    <p class="panel-note">Platform-wide evaluation metrics</p>
                    <a href="<%= request.getContextPath() %>/admin/evaluation-analytics" class="btn-primary btn-block">View Full Evaluation Analytics</a>
                </div>
            </div>

            <h2 class="section-title">Recent Activities</h2>
            <div class="panel">
                <div class="activity-list">
                    <%
                    if (recentActivities != null && !recentActivities.isEmpty()) {
                        for (Map<String, Object> activity : recentActivities) {
                            String status = (String) activity.get("classStatus");
                            String teacherName = (String) activity.get("teacherName");
                            String studentName = (String) activity.get("studentName");
                            String className = (String) activity.get("className");

                            String iconClass = "default";
                            String iconFa = "fa-circle";
                            String message = className;

                            if ("Cancelled".equals(status)) {
                                iconClass = "cancelled";
                                iconFa = "fa-times";
                                message = teacherName + " cancelled class for " + studentName;
                            } else if ("Completed".equals(status)) {
                                iconClass = "completed";
                                iconFa = "fa-check";
                                message = "Class completed: " + className;
                            } else {
                                iconClass = "upcoming";
                                iconFa = "fa-calendar";
                                message = "Upcoming: " + className;
                            }
                    %>
                    <div class="activity-item">
                        <div class="activity-icon <%= iconClass %>"><i class="fas <%= iconFa %>"></i></div>
                        <div>
                            <div class="activity-text"><%= message %></div>
                            <div class="activity-date"><%= activity.get("scheduleDate") %></div>
                        </div>
                    </div>
                    <%
                        }
                    } else {
                    %>
                    <p class="empty-state">No recent activities</p>
                    <%
                    }
                    %>
                </div>
            </div>

            <div class="panel-head" style="margin-top: 40px;">
                <h2 class="section-title" style="margin-bottom: 0;">Recent Announcements</h2>
                <a href="<%= request.getContextPath() %>/admin/announcements" class="btn-secondary">Manage Announcements</a>
            </div>
            <div class="announcement-list">
                <%
                if (recentAnnouncements != null && !recentAnnouncements.isEmpty()) {
                    for (Announcement announcement : recentAnnouncements) {
                %>
                <div class="panel">
                    <div class="panel-title"><%= announcement.getTitle() != null ? announcement.getTitle() : "Announcement" %></div>
                    <div class="announcement-meta">
                        <span><i class="fas fa-user"></i> <%= announcement.getAuthor() != null ? announcement.getAuthor() : "Admin" %></span>
                        <span><i class="fas fa-users"></i> <%= announcement.getTargetAudience() != null ? announcement.getTargetAudience() : "All Users" %></span>
                        <span><i class="fas fa-calendar"></i> <%= announcement.getDate() != null ? announcement.getDate() : "" %></span>
                    </div>
                </div>
                <%
                    }
                } else {
                %>
                <div class="panel">
                    <p class="empty-state">No recent announcements</p>
                </div>
                <%
                }
                %>
            </div>

            <h2 class="section-title" style="margin-top: 40px;">Quick Actions</h2>
            <div class="quick-actions-grid">
                <a href="<%= request.getContextPath() %>/admin/announcements" class="quick-action-card primary" style="text-decoration:none;">
                    <div class="quick-action-icon"><i class="fas fa-bullhorn"></i></div>
                    <div class="quick-action-title">Create Announcement</div>
                    <div class="quick-action-desc">Send platform-wide message</div>
                </a>
                <a href="<%= request.getContextPath() %>/admin/class-schedule" class="quick-action-card secondary" style="text-decoration:none;">
                    <div class="quick-action-icon"><i class="fas fa-calendar"></i></div>
                    <div class="quick-action-title">View Class Schedule</div>
                    <div class="quick-action-desc">Manage platform schedule</div>
                </a>
                <a href="<%= request.getContextPath() %>/admin/attendance" class="quick-action-card secondary" style="text-decoration:none;">
                    <div class="quick-action-icon"><i class="fas fa-chart-bar"></i></div>
                    <div class="quick-action-title">Attendance Analytics</div>
                    <div class="quick-action-desc">View detailed reports</div>
                </a>
                <a href="<%= request.getContextPath() %>/admin/evaluation-analytics" class="quick-action-card secondary" style="text-decoration:none;">
                    <div class="quick-action-icon"><i class="fas fa-star"></i></div>
                    <div class="quick-action-title">Evaluation Analytics</div>
                    <div class="quick-action-desc">Track performance</div>
                </a>
            </div>
        </div>
    </div>
</body>
</html>
