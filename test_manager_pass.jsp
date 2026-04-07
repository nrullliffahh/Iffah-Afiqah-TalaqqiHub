<%@ page import="util.DBConnection, java.sql.*" %>
<%
String target = "iffah@gmail.com";
Connection conn = null;
try {
    conn = DBConnection.getConnection();
    if (conn == null) {
        out.println("CONN_NULL");
    } else {
        PreparedStatement ps = conn.prepareStatement("SELECT managerPassword FROM manager WHERE managerEmail = ?");
        ps.setString(1, target);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            out.println("PWD:" + rs.getString("managerPassword"));
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