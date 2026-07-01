<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, java.text.SimpleDateFormat, java.sql.Time, java.sql.Date" %>
<%
    if (session == null || session.getAttribute("teacherId") == null) {
        response.sendRedirect(request.getContextPath() + "/teacher/login");
        return;
    }

    String teacherName = (String) request.getAttribute("teacherName");
    String teacherCode = (String) request.getAttribute("teacherCode");
    String specialization = (String) request.getAttribute("specialization");
    String joinedDate = (String) request.getAttribute("joinedDate");
    String nextClassCountdown = (String) request.getAttribute("nextClassCountdown");

    int classesThisWeek = (Integer) request.getAttribute("classesThisWeek");
    int totalStudents = (Integer) request.getAttribute("totalStudents");
    int pendingEvaluations = (Integer) request.getAttribute("pendingEvaluations");
    int completedEvaluations = request.getAttribute("completedEvaluations") != null
        ? (Integer) request.getAttribute("completedEvaluations") : 0;
    int studentsEvaluated = request.getAttribute("studentsEvaluated") != null
        ? (Integer) request.getAttribute("studentsEvaluated") : 0;
    String averageRating = (String) request.getAttribute("averageRating");

    List<Map<String, Object>> upcomingClasses = (List<Map<String, Object>>) request.getAttribute("upcomingClasses");
    List<Map<String, Object>> recentFeedback = (List<Map<String, Object>>) request.getAttribute("recentFeedback");

    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM d");
    SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");

    double avgRating = 0.0;
    try { avgRating = Double.parseDouble(averageRating); } catch (Exception ignored) {}
    int ratingWidth = (int) Math.min(100, Math.max(0, (avgRating / 5.0) * 100));
    int pendingWidth = request.getAttribute("evaluationProgressWidth") != null
        ? (Integer) request.getAttribute("evaluationProgressWidth") : 0;
    int studentProgressWidth = request.getAttribute("studentProgressWidth") != null
        ? (Integer) request.getAttribute("studentProgressWidth") : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Teacher Dashboard - TalaqqiHub</title>
    <%@ include file="/WEB-INF/views/includes/teacherLayoutStyles.jsp" %>
    <style>
        .panel-icon-head { display: flex; align-items: center; gap: 12px; margin-bottom: 24px; }
        .panel-icon { width: 40px; height: 40px; border-radius: 12px; background: var(--teacher-gradient); color: white; display: flex; align-items: center; justify-content: center; font-size: 18px; flex-shrink: 0; }
        .panel-note { text-align: center; font-size: 13px; color: #64748B; margin-bottom: 16px; }
        .rating-item { margin-bottom: 24px; }
        .rating-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
        .rating-label { font-size: 13px; font-weight: 600; color: #64748B; }
        .rating-score { font-size: 24px; font-weight: 700; color: #1E293B; }
        .rating-score span { font-size: 13px; color: #94A3B8; font-weight: 500; }
        .rating-stars { color: #F59E0B; font-size: 16px; letter-spacing: 2px; margin-bottom: 8px; }
        .rating-track { height: 8px; background: #F1F5F9; border-radius: 4px; overflow: hidden; }
        .rating-fill { height: 100%; background: var(--teacher-gradient-h); border-radius: 4px; }
        .info-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 40px; }
        .info-card { background: white; border-radius: 16px; padding: 20px; box-shadow: 0 4px 20px rgba(139,92,246,0.08); display: flex; align-items: center; gap: 14px; }
        .info-icon { width: 44px; height: 44px; border-radius: 12px; background: linear-gradient(135deg, #ede9fe, #fce7f3); color: var(--teacher-purple); display: flex; align-items: center; justify-content: center; font-size: 18px; flex-shrink: 0; }
        .info-label { font-size: 12px; color: #94A3B8; font-weight: 600; }
        .info-value { font-size: 14px; font-weight: 700; color: #1E293B; margin-top: 2px; }
        .class-list { display: flex; flex-direction: column; gap: 16px; }
        .class-item { display: flex; align-items: center; justify-content: space-between; gap: 16px; padding: 16px; background: #F8FAFC; border-radius: 14px; flex-wrap: wrap; }
        .class-item-left { display: flex; align-items: center; gap: 14px; }
        .class-avatar { width: 44px; height: 44px; border-radius: 50%; background: var(--teacher-gradient); color: white; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px; flex-shrink: 0; }
        .class-name { font-size: 14px; font-weight: 700; color: #1E293B; }
        .class-student { font-size: 13px; color: #64748B; margin-top: 2px; }
        .class-meta { display: flex; flex-wrap: wrap; gap: 14px; font-size: 12px; color: #94A3B8; margin-top: 6px; }
        .class-meta span { display: inline-flex; align-items: center; gap: 5px; }
        .feedback-list { display: flex; flex-direction: column; gap: 16px; }
        .feedback-item { padding: 16px; background: #F8FAFC; border-radius: 14px; }
        .feedback-head { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
        .feedback-student { font-size: 14px; font-weight: 700; color: #1E293B; }
        .feedback-time { font-size: 12px; color: #94A3B8; }
        .feedback-comment { font-size: 13px; color: #64748B; font-style: italic; margin-top: 8px; line-height: 1.5; }
        .quick-actions-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; }
        .quick-action-card { border-radius: 20px; padding: 24px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); cursor: pointer; transition: box-shadow .2s; text-decoration: none; display: block; }
        .quick-action-card:hover { box-shadow: 0 8px 28px rgba(0,0,0,0.12); }
        .quick-action-card.primary { background: var(--teacher-gradient); color: white; box-shadow: 0 8px 20px rgba(139,92,246,0.25); }
        .quick-action-card.secondary { background: white; border: 1px solid #F1F5F9; }
        .quick-action-icon { width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 22px; margin-bottom: 16px; }
        .quick-action-card.primary .quick-action-icon { background: rgba(255,255,255,0.25); color: white; }
        .quick-action-card.secondary .quick-action-icon { background: linear-gradient(135deg, #ede9fe, #fce7f3); color: var(--teacher-purple); }
        .quick-action-title { font-size: 16px; font-weight: 600; margin-bottom: 6px; }
        .quick-action-card.secondary .quick-action-title { color: #1E293B; }
        .quick-action-desc { font-size: 13px; }
        .quick-action-card.primary .quick-action-desc { color: rgba(255,255,255,0.9); }
        .quick-action-card.secondary .quick-action-desc { color: #64748B; }
        @media (max-width: 1200px) {
            .info-grid, .quick-actions-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/includes/teacherSidebar.jsp">
        <jsp:param name="activePage" value="dashboard"/>
    </jsp:include>

    <div class="main-content">
        <jsp:include page="/WEB-INF/views/includes/teacherTopNavbar.jsp">
            <jsp:param name="pageTitle" value="Teacher Dashboard"/>
            <jsp:param name="notifPrefix" value="dashNotif"/>
        </jsp:include>

        <div class="page-content">
            <h1 class="page-title">Welcome back, <%= teacherName %>!</h1>
            <p class="page-subtitle">Here's an overview of your teaching activities and student progress.</p>

            <div class="info-grid">
                <div class="info-card">
                    <div class="info-icon"><i class="fas fa-calendar"></i></div>
                    <div>
                        <div class="info-label">Joined</div>
                        <div class="info-value"><%= joinedDate %></div>
                    </div>
                </div>
                <div class="info-card">
                    <div class="info-icon"><i class="fas fa-book-quran"></i></div>
                    <div>
                        <div class="info-label">Specialization</div>
                        <div class="info-value"><%= specialization %></div>
                    </div>
                </div>
                <div class="info-card">
                    <div class="info-icon"><i class="fas fa-clock"></i></div>
                    <div>
                        <div class="info-label">Next Class In</div>
                        <div class="info-value"><%= nextClassCountdown %></div>
                    </div>
                </div>
            </div>

            <h2 class="section-title">Teaching Overview</h2>
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon"><i class="fas fa-calendar-week"></i></div>
                    <div>
                        <div class="stat-value"><%= classesThisWeek %></div>
                        <div class="stat-label">Classes This Week</div>
                        <div class="stat-hint">Booked sessions this week</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon pink"><i class="fas fa-users"></i></div>
                    <div>
                        <div class="stat-value"><%= totalStudents %></div>
                        <div class="stat-label">Total Students</div>
                        <div class="stat-hint">Students registered with you</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon amber"><i class="fas fa-file-alt"></i></div>
                    <div>
                        <div class="stat-value" style="color:#F59E0B;"><%= pendingEvaluations %></div>
                        <div class="stat-label">Pending Evaluations</div>
                        <div class="stat-hint">Sessions awaiting your evaluation</div>
                    </div>
                </div>
            </div>

            <h2 class="section-title">Performance Overview</h2>
            <div class="trends-grid">
                <div class="panel">
                    <div class="panel-icon-head">
                        <div class="panel-icon"><i class="fas fa-star"></i></div>
                        <div class="panel-title">Your Average Rating</div>
                    </div>

                    <div class="rating-item">
                        <div class="rating-header">
                            <span class="rating-label">Student Feedback Rating</span>
                            <span class="rating-score"><%= averageRating %> <span>/ 5.0</span></span>
                        </div>
                        <div class="rating-stars">
                            <% for (int i = 1; i <= 5; i++) { %>
                                <i class="<%= i <= Math.round(avgRating) ? "fas" : "far" %> fa-star"></i>
                            <% } %>
                        </div>
                        <div class="rating-track">
                            <div class="rating-fill" style="width: <%= ratingWidth %>%"></div>
                        </div>
                    </div>

                    <p class="panel-note">Based on student evaluations</p>
                    <a href="<%= request.getContextPath() %>/teacher/evaluation" class="btn-primary btn-block">View Evaluations</a>
                </div>

                <div class="panel">
                    <div class="panel-icon-head">
                        <div class="panel-icon"><i class="fas fa-clipboard-check"></i></div>
                        <div class="panel-title">Evaluation Progress</div>
                    </div>

                    <div class="rating-item">
                        <div class="rating-header">
                            <span class="rating-label">Pending Evaluations</span>
                            <span class="rating-score"><%= pendingEvaluations %> <span>remaining</span></span>
                        </div>
                        <div class="rating-track">
                            <div class="rating-fill" style="width: <%= pendingWidth %>%"></div>
                        </div>
                    </div>

                    <div class="rating-item" style="margin-bottom: 0;">
                        <div class="rating-header">
                            <span class="rating-label">Students Evaluated</span>
                            <span class="rating-score"><%= studentsEvaluated %> <span>of <%= totalStudents %></span></span>
                        </div>
                        <div class="rating-track">
                            <div class="rating-fill" style="width: <%= studentProgressWidth %>%"></div>
                        </div>
                    </div>

                    <p class="panel-note" style="margin-top: 24px;">Complete evaluations to track student progress</p>
                    <a href="<%= request.getContextPath() %>/teacher/evaluation" class="btn-primary btn-block">Evaluate Students</a>
                </div>
            </div>

            <div class="trends-grid">
                <div class="panel">
                    <div class="panel-head">
                        <div>
                            <div class="panel-title">Your Upcoming Classes</div>
                            <div class="panel-subtitle">Classes assigned to you</div>
                        </div>
                        <a href="<%= request.getContextPath() %>/teacher/classschedule" class="btn-secondary">View All</a>
                    </div>

                    <div class="class-list">
                        <%
                        boolean hasUpcoming = false;
                        if (upcomingClasses != null && !upcomingClasses.isEmpty()) {
                            for (Map<String, Object> classInfo : upcomingClasses) {
                                String className = (String) classInfo.get("className");
                                String studentName = (String) classInfo.get("studentName");
                                Date scheduleDate = (Date) classInfo.get("scheduleDate");
                                Time startTime = (Time) classInfo.get("startTime");
                                Time endTime = (Time) classInfo.get("endTime");
                                String status = (String) classInfo.get("status");

                                Object bookedObj = classInfo.get("booked");
                                boolean booked = bookedObj instanceof Boolean && (Boolean) bookedObj;
                                if (studentName == null || studentName.trim().isEmpty()) continue;
                                hasUpcoming = true;

                                String studentInitials = "S";
                                if (studentName.length() > 0) {
                                    String[] names = studentName.split(" ");
                                    studentInitials = names.length > 1 ?
                                        names[0].substring(0, 1) + names[1].substring(0, 1) :
                                        names[0].substring(0, 1);
                                }

                                String pillClass = "upcoming";
                                if (status != null && status.equalsIgnoreCase("Scheduled")) pillClass = "scheduled";
                        %>
                        <div class="class-item">
                            <div class="class-item-left">
                                <div class="class-avatar"><%= studentInitials.toUpperCase() %></div>
                                <div>
                                    <div class="class-name"><%= className != null ? className : "Class Session" %></div>
                                    <div class="class-student"><%= studentName %></div>
                                    <div class="class-meta">
                                        <span><i class="fas fa-calendar"></i> <%= scheduleDate != null ? dateFormat.format(scheduleDate) : "N/A" %></span>
                                        <span><i class="fas fa-clock"></i> <%= startTime != null ? timeFormat.format(startTime) : "N/A" %> - <%= endTime != null ? timeFormat.format(endTime) : "N/A" %></span>
                                    </div>
                                </div>
                            </div>
                            <span class="status-pill <%= pillClass %>"><%= status != null ? status : "Upcoming" %></span>
                        </div>
                        <%
                            }
                        }
                        if (!hasUpcoming) {
                        %>
                        <p class="empty-state">No upcoming classes scheduled</p>
                        <%
                        }
                        %>
                    </div>
                </div>

                <div class="panel">
                    <div class="panel-head">
                        <div>
                            <div class="panel-title">Recent Student Feedback</div>
                            <div class="panel-subtitle">Evaluations you received</div>
                        </div>
                        <a href="<%= request.getContextPath() %>/teacher/evaluation" class="btn-secondary">View All</a>
                    </div>

                    <div class="feedback-list">
                        <%
                        if (recentFeedback != null && !recentFeedback.isEmpty()) {
                            for (Map<String, Object> feedback : recentFeedback) {
                                String fbStudentName = (String) feedback.get("studentName");
                                int rating = (Integer) feedback.get("rating");
                                String comment = (String) feedback.get("comment");
                                java.sql.Timestamp feedbackDate = (java.sql.Timestamp) feedback.get("date");

                                long diffInMillis = new java.util.Date().getTime() - feedbackDate.getTime();
                                long hours = diffInMillis / (1000 * 60 * 60);
                                long days = hours / 24;
                                String timeAgo = days > 0 ? days + " days ago" : hours + " hours ago";
                        %>
                        <div class="feedback-item">
                            <div class="feedback-head">
                                <span class="feedback-student"><%= fbStudentName %></span>
                                <span class="feedback-time"><%= timeAgo %></span>
                            </div>
                            <div class="rating-stars" style="font-size: 14px; margin-bottom: 0;">
                                <% for (int i = 1; i <= 5; i++) { %>
                                    <i class="<%= i <= rating ? "fas" : "far" %> fa-star"></i>
                                <% } %>
                            </div>
                            <p class="feedback-comment">"<%= comment != null ? comment : "No comment provided" %>"</p>
                        </div>
                        <%
                            }
                        } else {
                        %>
                        <p class="empty-state">No feedback received yet</p>
                        <%
                        }
                        %>
                    </div>
                </div>
            </div>

            <h2 class="section-title">Quick Actions</h2>
            <div class="quick-actions-grid">
                <a href="<%= request.getContextPath() %>/teacher/setAvailability" class="quick-action-card primary">
                    <div class="quick-action-icon"><i class="fas fa-plus"></i></div>
                    <div class="quick-action-title">Set Availability</div>
                    <div class="quick-action-desc">Create your time slots</div>
                </a>
                <a href="<%= request.getContextPath() %>/teacher/classschedule" class="quick-action-card secondary">
                    <div class="quick-action-icon"><i class="fas fa-calendar"></i></div>
                    <div class="quick-action-title">View Class Schedule</div>
                    <div class="quick-action-desc">Manage your sessions</div>
                </a>
                <a href="<%= request.getContextPath() %>/teacher/evaluation" class="quick-action-card secondary">
                    <div class="quick-action-icon"><i class="fas fa-star"></i></div>
                    <div class="quick-action-title">Evaluate Students</div>
                    <div class="quick-action-desc"><%= pendingEvaluations %> pending</div>
                </a>
                <a href="<%= request.getContextPath() %>/teacher/sessions" class="quick-action-card secondary">
                    <div class="quick-action-icon"><i class="fas fa-book-quran"></i></div>
                    <div class="quick-action-title">Talaqqi Session</div>
                    <div class="quick-action-desc">Start or join a session</div>
                </a>
            </div>
        </div>
    </div>
</body>
</html>
