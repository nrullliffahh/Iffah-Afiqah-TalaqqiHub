<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String navbarTitle = request.getParameter("pageTitle");
    if (navbarTitle == null) navbarTitle = "Student Portal";

    String studentName = (String) session.getAttribute("studentName");
    if (studentName == null) studentName = (String) request.getAttribute("studentName");
    if (studentName == null) studentName = "Student";

    String studentId = (String) session.getAttribute("studentId");
    if (studentId == null) studentId = (String) request.getAttribute("studentId");

    String initials = "S";
    if (studentName != null && !studentName.trim().isEmpty()) {
        String[] parts = studentName.trim().split("\\s+");
        if (parts.length >= 2) {
            initials = parts[0].substring(0, 1).toUpperCase() + parts[parts.length - 1].substring(0, 1).toUpperCase();
        } else {
            initials = parts[0].substring(0, Math.min(2, parts[0].length())).toUpperCase();
        }
    }

    String notifPrefix = request.getParameter("notifPrefix");
    if (notifPrefix == null || notifPrefix.trim().isEmpty()) notifPrefix = "studentNotif";

    String ctx = request.getContextPath();
%>
<div class="top-navbar">
    <div class="navbar-left">
        <button type="button" class="sidebar-toggle" id="portalSidebarToggle" aria-label="Toggle navigation menu" aria-expanded="false">
            <i class="fas fa-bars"></i>
        </button>
        <div class="navbar-title"><%= navbarTitle %></div>
    </div>
    <div class="navbar-right">
        <jsp:include page="/WEB-INF/views/includes/studentNotifications.jsp">
            <jsp:param name="prefix" value="<%= notifPrefix %>"/>
        </jsp:include>
        <div class="user-info" id="studentProfileWrap">
            <button type="button" class="profile-trigger" onclick="document.getElementById('studentProfileDropdown').classList.toggle('open')">
                <div class="user-avatar"><%= initials %></div>
                <div class="user-text">
                    <p class="user-name"><%= studentName %></p>
                    <p class="user-role"><%= studentId != null ? "Student ID: " + studentId : "Student" %></p>
                </div>
                <i class="fas fa-chevron-down profile-chevron"></i>
            </button>
            <div id="studentProfileDropdown" class="profile-dropdown">
                <a href="<%= ctx %>/student/profile"><i class="fas fa-user"></i> View Profile</a>
                <a href="<%= ctx %>/student/edit-profile"><i class="fas fa-pen"></i> Edit Profile</a>
                <a href="<%= ctx %>/student/change-password"><i class="fas fa-key"></i> Change Password</a>
                <hr>
                <a href="<%= ctx %>/student/logout" class="logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </div>
    </div>
</div>
<script>
document.addEventListener('click', function(e) {
    var wrap = document.getElementById('studentProfileWrap');
    var menu = document.getElementById('studentProfileDropdown');
    if (!wrap || !menu || !menu.classList.contains('open')) return;
    if (!wrap.contains(e.target)) menu.classList.remove('open');
});
</script>
