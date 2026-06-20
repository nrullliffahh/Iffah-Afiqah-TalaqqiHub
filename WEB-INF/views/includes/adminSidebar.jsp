<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
    String activePage = request.getParameter("activePage");
    if (activePage == null) activePage = "";
%>
<div class="sidebar">
    <div class="sidebar-brand">
        <div class="brand-title">TalaqqiHub</div>
        <div class="brand-subtitle">Admin Portal</div>
    </div>
    <ul class="sidebar-menu">
        <li><a href="<%= ctx %>/admin/dashboard" class="<%= "dashboard".equals(activePage) ? "active" : "" %>"><i class="fas fa-home"></i><span>Dashboard</span></a></li>
        <li><a href="<%= ctx %>/admin/manage-teachers" class="<%= "manage-teachers".equals(activePage) ? "active" : "" %>"><i class="fas fa-chalkboard-user"></i><span>Manage Teachers</span></a></li>
        <li><a href="<%= ctx %>/admin/manage-students" class="<%= "manage-students".equals(activePage) ? "active" : "" %>"><i class="fas fa-users"></i><span>Manage Students</span></a></li>
        <li><a href="<%= ctx %>/admin/packages" class="<%= "packages".equals(activePage) ? "active" : "" %>"><i class="fas fa-box"></i><span>Manage Packages</span></a></li>
        <li><a href="<%= ctx %>/admin/class-schedule" class="<%= "class-schedule".equals(activePage) ? "active" : "" %>"><i class="fas fa-calendar"></i><span>Class Schedule</span></a></li>
        <li><a href="<%= ctx %>/admin/talaqqi-sessions" class="<%= "talaqqi-sessions".equals(activePage) ? "active" : "" %>"><i class="fas fa-book-quran"></i><span>Talaqqi Session</span></a></li>
        <li><a href="<%= ctx %>/admin/attendance" class="<%= "attendance".equals(activePage) ? "active" : "" %>"><i class="fas fa-chart-bar"></i><span>Attendance Analytics</span></a></li>
        <li><a href="<%= ctx %>/admin/evaluation-analytics" class="<%= "evaluation-analytics".equals(activePage) ? "active" : "" %>"><i class="fas fa-star"></i><span>Evaluation Analytics</span></a></li>
        <li><a href="<%= ctx %>/admin/ai-assistance" class="<%= "ai-assistance".equals(activePage) ? "active" : "" %>"><i class="fas fa-bolt"></i><span>AI Assistance</span></a></li>
        <li><a href="<%= ctx %>/admin/announcements" class="<%= "announcements".equals(activePage) ? "active" : "" %>"><i class="fas fa-bullhorn"></i><span>Announcement</span></a></li>
    </ul>
    <div class="sidebar-logout">
        <a href="<%= ctx %>/admin/logout"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a>
    </div>
</div>
