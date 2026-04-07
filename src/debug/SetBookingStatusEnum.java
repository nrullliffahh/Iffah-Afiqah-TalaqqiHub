package debug;

import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class SetBookingStatusEnum {
    public static void main(String[] args) {
        List<String> allowed = new ArrayList<>();
        allowed.add("Upcoming");
        allowed.add("Completed");
        allowed.add("Cancelled");

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                System.err.println("DB connection null");
                return;
            }

            // 1) show distinct values
            try (PreparedStatement ps = conn.prepareStatement("SELECT DISTINCT bookingStatus FROM classbooking");
                 ResultSet rs = ps.executeQuery()) {
                System.out.println("Current distinct bookingStatus values:");
                List<String> distinct = new ArrayList<>();
                while (rs.next()) {
                    String v = rs.getString(1);
                    distinct.add(v);
                    System.out.println(" - '" + v + "'");
                }

                // 2) map any unexpected values to 'Upcoming'
                for (String v : distinct) {
                    if (v == null) continue;
                    if (!allowed.contains(v)) {
                        try (PreparedStatement up = conn.prepareStatement("UPDATE classbooking SET bookingStatus = 'Upcoming' WHERE bookingStatus = ?")) {
                            up.setString(1, v);
                            int c = up.executeUpdate();
                            System.out.println("Mapped '" + v + "' -> 'Upcoming' (" + c + ")");
                        }
                    }
                }
            }

            // 3) Now alter column to ENUM('Upcoming','Completed','Cancelled')
            try (PreparedStatement ps = conn.prepareStatement("ALTER TABLE classbooking MODIFY bookingStatus ENUM('Upcoming','Completed','Cancelled') NOT NULL DEFAULT 'Upcoming'")) {
                ps.executeUpdate();
                System.out.println("Altered bookingStatus column to ENUM('Upcoming','Completed','Cancelled')");
            } catch (Exception e) {
                System.out.println("ALTER failed: " + e.getMessage());
            }

            // 4) Print final counts
            try (PreparedStatement ps = conn.prepareStatement("SELECT bookingStatus, COUNT(*) AS cnt FROM classbooking GROUP BY bookingStatus");
                 ResultSet rs = ps.executeQuery()) {
                System.out.println("Final status counts:");
                while (rs.next()) {
                    System.out.println(rs.getString("bookingStatus") + " = " + rs.getInt("cnt"));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
