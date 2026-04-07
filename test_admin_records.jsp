<%@ page import="dao.ClassScheduleDAO, java.util.List, java.util.Map" %>
<%
ClassScheduleDAO dao = new ClassScheduleDAO();
java.util.List<java.util.Map<String,Object>> records = dao.getAllSchedulesForAdmin();
if (records == null) {
    out.println("RECS:NULL");
} else {
    out.println("RECS:" + records.size());
    for (int i = 0; i < Math.min(records.size(), 10); i++) {
        java.util.Map<String, Object> r = records.get(i);
        out.println("ROW:" + r.get("scheduleId") + "," + r.get("teacherName") + "," + r.get("studentName") + "," + r.get("className") + "," + r.get("status"));
    }
}
%>