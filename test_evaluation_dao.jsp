<%@ page import="dao.EvaluationDAO" %>
<%@ page import="java.util.*, java.sql.*" %>
<%
    try {
        EvaluationDAO evalDAO = new EvaluationDAO();
        String testStudentId = "S001";
        String result = evalDAO.getLatestEvaluationResult(testStudentId);
        out.println("✓ SUCCESS: getLatestEvaluationResult() executed without ClassCastException");
        out.println("<br>Student ID: " + testStudentId);
        out.println("<br>Latest Evaluation Result: " + result);
        out.println("<br><br>✓ The Float casting issue has been fixed!");
    } catch (ClassCastException e) {
        out.println("✗ FAILED: ClassCastException still occurring");
        out.println("<br>Error: " + e.getMessage());
        e.printStackTrace(new java.io.PrintWriter(out));
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
        e.printStackTrace(new java.io.PrintWriter(out));
    }
%>
