<%@ page import="java.sql.*, java.io.*, util.DBConnection" %>
<%
    response.setContentType("text/plain;charset=UTF-8");
    try (Connection conn = DBConnection.getConnection()) {
        if (conn == null) {
            out.println("ERROR: DBConnection.getConnection() returned null. Check DB settings and connector JAR.");
        } else {
            out.println("Connected: " + !conn.isClosed());
            String sql = "SELECT COUNT(*) AS cnt FROM classbooking";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    out.println("classbooking count: " + rs.getInt("cnt"));
                } else {
                    out.println("classbooking count: (no rows returned)");
                }
            } catch (SQLException qex) {
                out.println("SQL Error executing query against classbooking: " + qex.getMessage());
                StringWriter sw = new StringWriter();
                qex.printStackTrace(new PrintWriter(sw));
                out.println(sw.toString());
            }
        }
    } catch (Exception ex) {
        out.println("Exception while testing DB connection: " + ex.getMessage());
        StringWriter sw2 = new StringWriter();
        ex.printStackTrace(new PrintWriter(sw2));
        out.println(sw2.toString());
    }
%>