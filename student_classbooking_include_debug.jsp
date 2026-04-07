<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <title>Include Debug</title>
  <style>body{font-family:monospace;background:#fff;padding:24px} pre{white-space:pre-wrap;background:#fee; padding:12px;border-radius:6px;border:1px solid #fbb}</style>
</head>
<body>
<h2>Including /WEB-INF/views/classBooking.jsp (debug)</h2>
<%
    try {
%>
        <jsp:include page="/WEB-INF/views/classBooking.jsp" />
<%
    } catch (Throwable t) {
        java.io.StringWriter sw = new java.io.StringWriter();
        t.printStackTrace(new java.io.PrintWriter(sw));
        out.println("<h3 style='color:red'>Exception during include:</h3>");
        out.println("<pre>" + org.apache.jasper.runtime.JspRuntimeLibrary.URLEncode(sw.toString(), "UTF-8") + "</pre>");
    }
%>
</body>
</html>
