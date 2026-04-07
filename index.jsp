<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%
    // Redirect to HomeServlet (MVC Controller)
    response.sendRedirect(request.getContextPath() + "/home");
%>
