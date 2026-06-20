<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
    String activePage = request.getParameter("activePage");
    if (activePage == null) activePage = "";
%>
<div class="sidebar" id="portalSidebar">
    <button type="button" class="sidebar-close" id="portalSidebarClose" aria-label="Close navigation menu">
        <i class="fas fa-times"></i>
    </button>
    <div class="sidebar-brand">
        <div class="brand-title">TalaqqiHub</div>
        <div class="brand-subtitle">Student Portal</div>
    </div>
    <ul class="sidebar-menu">
        <li><a href="<%= ctx %>/student/dashboard" class="<%= "dashboard".equals(activePage) ? "active" : "" %>"><i class="fas fa-home"></i><span>Dashboard</span></a></li>
        <li><a href="<%= ctx %>/student/class-booking" class="<%= "class-booking".equals(activePage) ? "active" : "" %>"><i class="fas fa-calendar"></i><span>Class Booking</span></a></li>
        <li><a href="<%= ctx %>/student/sessions" class="<%= "talaqqi-sessions".equals(activePage) ? "active" : "" %>"><i class="fas fa-book-quran"></i><span>Talaqqi Session</span></a></li>
        <li><a href="<%= ctx %>/student/attendance" class="<%= "attendance".equals(activePage) ? "active" : "" %>"><i class="fas fa-clipboard-check"></i><span>Attendance</span></a></li>
        <li><a href="<%= ctx %>/student/evaluation" class="<%= "evaluation".equals(activePage) ? "active" : "" %>"><i class="fas fa-star"></i><span>Evaluation</span></a></li>
        <li><a href="<%= ctx %>/student/ai-assistance" class="<%= "ai-assistance".equals(activePage) ? "active" : "" %>"><i class="fas fa-bolt"></i><span>AI Assistance</span></a></li>
        <li><a href="<%= ctx %>/student/announcements" class="<%= "announcements".equals(activePage) ? "active" : "" %>"><i class="fas fa-bullhorn"></i><span>Announcement</span></a></li>
    </ul>
    <div class="sidebar-logout">
        <a href="<%= ctx %>/student/logout"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a>
    </div>
</div>
