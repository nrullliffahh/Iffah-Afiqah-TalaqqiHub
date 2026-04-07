<%@ page import="util.DBConnection, java.sql.*" %>
<%
Connection conn = null;
try {
    conn = DBConnection.getConnection();
    if (conn == null) {
        out.println("CONN_NULL");
    } else {
        PreparedStatement ps = conn.prepareStatement("SELECT managerEmail FROM manager LIMIT 1");
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            out.println("EMAIL:" + rs.getString("managerEmail"));
        } else {
            out.println("NO_MANAGER");
        }
        rs.close(); ps.close();
    }
} catch (Exception e) {
    out.println("ERROR:" + e.getMessage());
} finally {
    if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
}
%>