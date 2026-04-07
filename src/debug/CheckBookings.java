package debug;

import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class CheckBookings {
    public static void main(String[] args) {
        String sql = "SELECT bookingId, studentId, scheduleId, bookingDate, bookingTime, bookingStatus FROM classbooking ORDER BY bookingDate DESC, bookingTime DESC LIMIT 50";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            System.out.println("Recent classbooking rows:");
            int i = 0;
            while (rs.next()) {
                i++;
                System.out.printf("%d) id=%s date=%s time=%s status=%s student=%s schedule=%s\n",
                        i,
                        rs.getString("bookingId"),
                        rs.getDate("bookingDate"),
                        rs.getTime("bookingTime"),
                        rs.getString("bookingStatus"),
                        rs.getString("studentId"),
                        rs.getString("scheduleId")
                );
            }
            if (i == 0) System.out.println("(no rows)");

            // Also check if any bookings with status Completed exist
            String sql2 = "SELECT COUNT(*) AS cnt FROM classbooking WHERE bookingStatus = 'Completed' OR bookingStatus = 'completed'";
            try (PreparedStatement ps2 = conn.prepareStatement(sql2);
                 ResultSet rs2 = ps2.executeQuery()) {
                if (rs2.next()) {
                    System.out.println("Count of bookings with status 'Completed': " + rs2.getInt("cnt"));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
