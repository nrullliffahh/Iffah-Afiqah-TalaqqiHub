<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>Error</title>
    <style>body{font-family:Arial,Helvetica,sans-serif;background:#fff;padding:24px;color:#222} .box{border-left:4px solid #d9534f;padding:16px;background:#fff6f6}</style>
</head>
<body>
    <h1>Application Error</h1>
    <div class="box">
        <p><strong>Message:</strong> <%= request.getAttribute("error") != null ? request.getAttribute("error") : (request.getAttribute("javax.servlet.error.message")!=null?request.getAttribute("javax.servlet.error.message"):"An error occurred") %></p>
        <p><strong>Details:</strong></p>
        <pre style="white-space:pre-wrap; max-height:300px; overflow:auto; background:#f8f8f8;padding:8px;border-radius:4px;"> 
<% Object ex = request.getAttribute("javax.servlet.error.exception"); if (ex != null) { ((Throwable)ex).printStackTrace(out); } else { out.print("No exception available."); } %>
        </pre>
    </div>
    <p><a href="<%= request.getContextPath() %>/teacher/evaluation">Back to Evaluation</a></p>
</body>
</html>