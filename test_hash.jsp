<%@ page import="util.PasswordUtil" %>
<%
    String password = "admin";
    String hash = PasswordUtil.hashPassword(password);
    out.println("Password: " + password + "<br>");
    out.println("Hash: " + hash + "<br>");
    out.println("Length: " + hash.length());
%>
