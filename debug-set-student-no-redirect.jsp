<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Temporary debug helper — sets a student session for testing class booking page
    session.setAttribute("studentId", "S006");
    session.setAttribute("DEBUG_SET_BY", "debug-set-student-no-redirect.jsp");
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Debug: session set</title>
  <style>body{font-family:Arial,Helvetica,sans-serif;background:#f8fafc;color:#0f172a;padding:32px} .card{max-width:760px;margin:36px auto;padding:24px;background:#fff;border-radius:8px;box-shadow:0 6px 24px rgba(2,6,23,0.06)}</style>
</head>
<body>
  <div class="card">
    <h2>Session debug</h2>
    <p>Set <strong>studentId = S006</strong> in session.</p>
    <p>Session debug key: <strong><%= session.getAttribute("DEBUG_SET_BY") %></strong></p>
    <p><a href="<%= request.getContextPath() %>/student/class-booking">Open Class Booking (via servlet)</a></p>
    <p>If that page is blank, please restart Tomcat to pick up recent code changes.</p>
  </div>
</body>
</html>
