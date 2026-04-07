package debug;

import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class AttachScheduleCompleted {
    public static void main(String[] args) {
        String updateSql = "UPDATE classschedule cs " +
                "JOIN (SELECT DISTINCT scheduleId FROM classbooking WHERE (bookingStatus = 'Completed' OR bookingStatus = 'completed') AND bookingDate < CURDATE()) b " +
                "ON cs.scheduleId = b.scheduleId " +
                "SET cs.classStatus = 'Completed' WHERE cs.classStatus != 'Completed'";

        String selectSql = "SELECT scheduleId, className, scheduleDate, startTime, endTime, classStatus FROM classschedule WHERE classStatus = 'Completed' ORDER BY scheduleDate DESC, startTime DESC LIMIT 50";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                System.err.println("DB connection is null. Aborting.");
                return;
            }

            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                int affected = ps.executeUpdate();
                System.out.println("Rows updated in classschedule: " + affected);
            }

            try (PreparedStatement ps2 = conn.prepareStatement(selectSql);
                 ResultSet rs = ps2.executeQuery()) {
                System.out.println("Sample completed classschedule rows:");
                int i = 0;
                while (rs.next()) {
                    i++;
                    System.out.printf("%d) id=%s name=%s date=%s time=%s-%s status=%s\n",
                            i,
                            rs.getString("scheduleId"),
                            rs.getString("className"),
                            rs.getDate("scheduleDate"),
                            rs.getTime("startTime"),
                            rs.getTime("endTime"),
                            rs.getString("classStatus")
                    );
                }
                if (i == 0) System.out.println("(no completed schedule rows found)");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
