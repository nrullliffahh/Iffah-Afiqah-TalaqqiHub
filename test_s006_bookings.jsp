<%@ page import="java.sql.*, java.io.*, util.DBConnection" %>
<%
    response.setContentType("text/plain;charset=UTF-8");
    try (Connection conn = DBConnection.getConnection()) {
        if (conn == null) {
            out.println("ERROR: DBConnection.getConnection() returned null.");
        } else {
            out.println("Connected: " + !conn.isClosed());

            // List rows for S006
            String listSql = "SELECT bookingId, studentId, scheduleId, bookingDate, bookingTime, bookingStatus FROM classbooking WHERE studentId = 'S006' ORDER BY bookingDate DESC, bookingTime DESC";
            try (PreparedStatement ps = conn.prepareStatement(listSql);
                 ResultSet rs = ps.executeQuery()) {
                out.println("\nRows for S006:");
                int row = 0;
                while (rs.next()) {
                    row++;
                    out.println(row + ") bookingId=" + rs.getString("bookingId") + ", scheduleId=" + rs.getString("scheduleId") + ", bookingDate=" + rs.getDate("bookingDate") + ", bookingTime=" + rs.getTime("bookingTime") + ", status=" + rs.getString("bookingStatus"));
                }
                if (row == 0) out.println("(no rows found for S006)");
            } catch (SQLException qex) {
                out.println("SQL Error listing S006 rows: " + qex.getMessage());
                StringWriter sw = new StringWriter();
                qex.printStackTrace(new PrintWriter(sw));
                out.println(sw.toString());
            }

            // Count completed this month for S006
            String cntSql = "SELECT COUNT(*) AS used_this_month FROM classbooking WHERE studentId = 'S006' AND MONTH(bookingDate)=MONTH(CURRENT_DATE()) AND YEAR(bookingDate)=YEAR(CURRENT_DATE()) AND bookingStatus IN ('Completed')";
            try (PreparedStatement ps2 = conn.prepareStatement(cntSql);
                 ResultSet rs2 = ps2.executeQuery()) {
                if (rs2.next()) {
                    out.println("\nUsed this month for S006: " + rs2.getInt("used_this_month"));
                }
            } catch (SQLException qex2) {
                out.println("SQL Error counting S006 used sessions: " + qex2.getMessage());
                StringWriter sw2 = new StringWriter();
                qex2.printStackTrace(new PrintWriter(sw2));
                out.println(sw2.toString());
            }
        }
    } catch (Exception ex) {
        out.println("Exception while testing DB for S006: " + ex.getMessage());
        StringWriter sw2 = new StringWriter();
        ex.printStackTrace(new PrintWriter(sw2));
        out.println(sw2.toString());
    }
%>