<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String navbarTitle = request.getParameter("pageTitle");
    if (navbarTitle == null) navbarTitle = "Admin Portal";

    String adminName = (String) session.getAttribute("adminName");
    if (adminName == null) adminName = "Admin Manager";

    String initials = "AM";
    if (adminName != null && !adminName.trim().isEmpty()) {
        String[] parts = adminName.trim().split("\\s+");
        if (parts.length >= 2) {
            initials = parts[0].substring(0, 1).toUpperCase() + parts[parts.length - 1].substring(0, 1).toUpperCase();
        } else {
            initials = parts[0].substring(0, Math.min(2, parts[0].length())).toUpperCase();
        }
    }
%>
<div class="top-navbar">
    <div class="navbar-title"><%= navbarTitle %></div>
    <div class="navbar-right">
        <div class="user-info">
            <div class="user-avatar"><%= initials %></div>
            <div>
                <p class="user-name"><%= adminName %></p>
                <p class="user-role">Administrator</p>
            </div>
        </div>
    </div>
</div>
