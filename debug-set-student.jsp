<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Temporary debug helper — sets a student session for testing class booking page
    session.setAttribute("studentId", "S006");
    session.setAttribute("DEBUG_SET_BY", "debug-set-student.jsp");
    response.sendRedirect(request.getContextPath() + "/student/class-booking");
%>
