<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - TalaqqiHub</title>
    <%@ include file="/WEB-INF/views/includes/studentLayoutStyles.jsp" %>
</head>
<body>
    <jsp:include page="/WEB-INF/views/includes/studentSidebar.jsp">
        <jsp:param name="activePage" value="dashboard"/>
    </jsp:include>

    <div class="main-content">
        <jsp:include page="/WEB-INF/views/includes/studentTopNavbar.jsp">
            <jsp:param name="pageTitle" value="Dashboard"/>
            <jsp:param name="notifPrefix" value="dashNotif"/>
        </jsp:include>

        <div class="page-content">
            <h1 class="page-title">Assalamu'alaikum, ${studentName}</h1>
            <p class="page-subtitle">Here is an overview of your Quran learning progress.<c:if test="${not empty packageName and packageName ne '-'}"> Package: <strong>${packageName}</strong></c:if></p>

            <div class="stats-grid-4">
                <div class="stat-card">
                    <div class="stat-icon blue"><i class="fas fa-calendar"></i></div>
                    <div>
                        <div class="stat-value">${upcomingClassCount}</div>
                        <div class="stat-label">Upcoming Classes</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon teal"><i class="fas fa-chart-line"></i></div>
                    <div>
                        <div class="stat-value">${attendanceRate}%</div>
                        <div class="stat-label">Attendance Rate</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon green"><i class="fas fa-book-quran"></i></div>
                    <div>
                        <div class="stat-value">${completedSessions}/${totalSessions}</div>
                        <div class="stat-label">Completed Sessions</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon amber"><i class="fas fa-star"></i></div>
                    <div>
                        <div class="stat-value stat-value-sm">${evaluationResult}</div>
                        <div class="stat-label">Latest Evaluation</div>
                    </div>
                </div>
            </div>

            <div class="content-grid-2-1">
                <div class="dashboard-left">
                    <div class="panel">
                        <div class="panel-head">
                            <div>
                                <div class="panel-title">Next Talaqqi Session</div>
                                <div class="panel-subtitle">Your upcoming class details</div>
                            </div>
                            <c:if test="${nextSession != null}">
                                <span class="status-pill upcoming">Upcoming</span>
                            </c:if>
                        </div>

                        <c:if test="${nextSession != null}">
                            <div class="session-detail">
                                <i class="fas fa-calendar"></i>
                                <div>
                                    <div class="session-detail-label">Date</div>
                                    <div class="session-detail-value">${nextSession.sessionDate}</div>
                                </div>
                            </div>
                            <div class="session-detail">
                                <i class="fas fa-clock"></i>
                                <div>
                                    <div class="session-detail-label">Time</div>
                                    <div class="session-detail-value">${nextSession.sessionTime}</div>
                                </div>
                            </div>
                            <div class="session-detail">
                                <i class="fas fa-chalkboard-teacher"></i>
                                <div>
                                    <div class="session-detail-label">Teacher</div>
                                    <div class="session-detail-value">${nextSession.teacherName}</div>
                                </div>
                            </div>
                            <div class="session-detail">
                                <i class="fas fa-book-quran"></i>
                                <div>
                                    <div class="session-detail-label">Session Type</div>
                                    <div class="session-detail-value">${nextSession.sessionType}</div>
                                </div>
                            </div>
                            <a href="<%= request.getContextPath() %>/student/sessions" class="btn-primary btn-block" style="margin-top:20px;">Join Session</a>
                        </c:if>
                        <c:if test="${nextSession == null}">
                            <div class="panel-empty">
                                <div class="empty-state">No upcoming sessions scheduled</div>
                            </div>
                        </c:if>
                    </div>

                    <div class="panel" style="margin-bottom:0;">
                        <div class="panel-title">Learning Progress</div>
                        <div class="panel-subtitle" style="margin-bottom:16px;">Session completion overview</div>
                        <c:set var="progressPercent" value="0" />
                        <c:if test="${totalSessions > 0}">
                            <c:set var="progressPercent" value="${(completedSessions * 100.0) / totalSessions}" />
                        </c:if>
                        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:4px;">
                            <span style="font-size:13px;font-weight:600;color:#64748b;">Session Completion</span>
                            <span style="font-size:13px;font-weight:700;color:var(--student-green);">${completedSessions}/${totalSessions}</span>
                        </div>
                        <div class="progress-track">
                            <div class="progress-fill" style="width:${progressPercent}%;"></div>
                        </div>
                        <p style="font-size:13px;color:#64748b;margin-top:12px;">You've completed <fmt:formatNumber value="${progressPercent}" maxFractionDigits="2" minFractionDigits="0"/>% of your sessions. Keep up the great work!</p>
                    </div>
                </div>

                <div class="panel panel-announcements">
                    <div class="panel-head">
                        <div class="panel-title">Announcements</div>
                        <span class="badge-count">${announcementCount > 9 ? '9+' : announcementCount}</span>
                    </div>
                    <div class="announcements-list">
                        <c:forEach items="${announcementList}" var="announcement">
                            <div class="announcement-item">
                                <h4>${announcement.title}</h4>
                                <div class="date">${announcement.date}</div>
                                <p>${announcement.description}</p>
                            </div>
                        </c:forEach>
                        <c:if test="${empty announcementList}">
                            <div class="empty-state">No announcements yet</div>
                        </c:if>
                    </div>
                    <a href="<%= request.getContextPath() %>/student/announcements" class="btn-outline" style="margin-top:16px;">View All Announcements</a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
