<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%

    String navbarTitle = request.getParameter("pageTitle");

    if (navbarTitle == null) navbarTitle = "Teacher Portal";



    String teacherName = (String) session.getAttribute("teacherName");

    if (teacherName == null) {

        teacherName = (String) request.getAttribute("teacherName");

    }

    if (teacherName == null) teacherName = "Teacher";



    String teacherCode = (String) session.getAttribute("teacherId");

    if (teacherCode == null) {

        teacherCode = (String) request.getAttribute("teacherCode");

    }



    String initials = "T";

    if (teacherName != null && !teacherName.trim().isEmpty()) {

        String[] parts = teacherName.trim().split("\\s+");

        if (parts.length >= 2) {

            initials = parts[0].substring(0, 1).toUpperCase() + parts[parts.length - 1].substring(0, 1).toUpperCase();

        } else {

            initials = parts[0].substring(0, Math.min(2, parts[0].length())).toUpperCase();

        }

    }



    String notifPrefix = request.getParameter("notifPrefix");

    if (notifPrefix == null || notifPrefix.trim().isEmpty()) {

        notifPrefix = "teacherNotif";

    }

%>

<div class="top-navbar">

    <div class="navbar-title"><%= navbarTitle %></div>

    <div class="navbar-right">

        <jsp:include page="/WEB-INF/views/includes/teacherNotifications.jsp">

            <jsp:param name="prefix" value="<%= notifPrefix %>"/>

        </jsp:include>

        <div class="user-info">

            <div class="user-avatar"><%= initials %></div>

            <div>

                <p class="user-name"><%= teacherName %></p>

                <p class="user-role"><%= teacherCode != null ? "Teacher ID: " + teacherCode : "Teacher" %></p>

            </div>

        </div>

    </div>

</div>

