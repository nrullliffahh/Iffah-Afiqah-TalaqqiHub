<%@ page import="util.DBConnection, java.sql.*" %>
<%
Connection conn = null;
try {
    conn = DBConnection.getConnection();
    if (conn == null) {
        out.println("CONN_NULL");
    } else {
        PreparedStatement ps = conn.prepareStatement("SHOW COLUMNS FROM classschedule");
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            out.println(rs.getString("Field") + " - " + rs.getString("Type") + "<br/>");
        }
        rs.close(); ps.close();
    }
} catch (Exception e) {
    out.println("ERROR:" + e.getMessage());
} finally {
    if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
}
%>