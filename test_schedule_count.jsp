<%@ page import="util.DBConnection, java.sql.*" %>
<%
Connection conn = null;
try {
    conn = DBConnection.getConnection();
    if (conn == null) {
        out.println("CONN_NULL");
    } else {
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            ps = conn.prepareStatement("SELECT COUNT(*) AS c FROM classschedule");
            rs = ps.executeQuery();
            if (rs.next()) {
                out.println("COUNT:" + rs.getInt("c"));
            } else {
                out.println("NO_RESULT");
            }
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
            if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
        }
    }
} catch (Exception e) {
    java.io.StringWriter sw = new java.io.StringWriter();
    e.printStackTrace(new java.io.PrintWriter(sw));
    out.println("ERROR:" + e.getMessage());
    out.println(sw.toString().replaceAll("<", "&lt;").replaceAll("&", "&amp;"));
} finally {
    if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
}
%>