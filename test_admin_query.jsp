<%@ page import="util.DBConnection, java.sql.*" %>
<%
String sql = "SELECT cs.scheduleId, cs.className, cs.scheduleDate, cs.startTime, cs.endTime, cs.duration, cs.classStatus, " +
             "t.teacherName, cb.bookingId, cb.bookingStatus, cb.studentId AS bookedStudentId, s2.studentName AS bookedStudentName, " +
             "cs.studentId AS assignedStudentId, s1.studentName AS assignedStudentName " +
             "FROM classschedule cs " +
             "LEFT JOIN teacher t ON cs.teacherId = t.teacherId " +
             "LEFT JOIN classbooking cb ON cs.scheduleId = cb.scheduleId AND cb.bookingStatus != 'Cancelled' " +
             "LEFT JOIN student s2 ON cb.studentId = s2.studentId " +
             "LEFT JOIN student s1 ON cs.studentId = s1.studentId " +
             "ORDER BY cs.scheduleDate, cs.startTime";
%>
<%
out.println("SQL: " + sql.replaceAll("\n"," "));
Connection conn = null;
try {
    conn = DBConnection.getConnection();
    PreparedStatement ps = conn.prepareStatement(sql);
    ResultSet rs = ps.executeQuery();
    int c = 0;
    while (rs.next()) {
        c++;
        if (c <= 5) {
            out.println("ROW:" + rs.getString("scheduleId") + "," + rs.getString("teacherName") + "," + rs.getString("className") + "<br/>");
        }
    }
    out.println("TOTAL:" + c);
    rs.close(); ps.close();
} catch (Exception e) {
    java.io.StringWriter sw = new java.io.StringWriter();
    e.printStackTrace(new java.io.PrintWriter(sw));
    out.println("ERROR: " + e.getMessage());
    out.println(sw.toString().replaceAll("<","&lt;").replaceAll("&","&amp;"));
} finally {
    if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
}
%>