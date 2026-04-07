package debug;

import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class NormalizeBookingStatus {
    public static void main(String[] args) {
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                System.err.println("DB connection null");
                return;
            }

            // 1) Alter column to varchar(20) with default 'Upcoming'
            try (PreparedStatement ps = conn.prepareStatement("ALTER TABLE classbooking MODIFY bookingStatus VARCHAR(20) NOT NULL DEFAULT 'Upcoming'")) {
                ps.executeUpdate();
                System.out.println("Altered bookingStatus to VARCHAR(20)");
            } catch (Exception e) {
                System.out.println("ALTER failed or already applied: " + e.getMessage());
            }

            // 2) Normalize existing values to Upcoming / Completed / Cancelled
            // Map common legacy values to new set
            String[] mapUpcoming = {"Pending","Approved","Confirmed","Upcoming"};
            for (String v : mapUpcoming) {
                try (PreparedStatement ps = conn.prepareStatement("UPDATE classbooking SET bookingStatus = 'Upcoming' WHERE bookingStatus = ?")) {
                    ps.setString(1, v);
                    int c = ps.executeUpdate();
                    if (c > 0) System.out.println("Mapped '" + v + "' -> 'Upcoming' (" + c + ")");
                } catch (Exception e) {
                    // continue
                }
            }

            String[] mapCancelled = {"Rejected","Cancelled","cancelled","rejected"};
            for (String v : mapCancelled) {
                try (PreparedStatement ps = conn.prepareStatement("UPDATE classbooking SET bookingStatus = 'Cancelled' WHERE bookingStatus = ?")) {
                    ps.setString(1, v);
                    int c = ps.executeUpdate();
                    if (c > 0) System.out.println("Mapped '" + v + "' -> 'Cancelled' (" + c + ")");
                } catch (Exception e) {
                }
            }

            // Ensure Completed entries stay as Completed (case variations)
            try (PreparedStatement ps = conn.prepareStatement("UPDATE classbooking SET bookingStatus = 'Completed' WHERE LOWER(bookingStatus) = 'completed'")) {
                int c = ps.executeUpdate();
                if (c > 0) System.out.println("Normalized 'completed' -> 'Completed' (" + c + ")");
            }

            // 3) Show counts by status
            try (PreparedStatement ps = conn.prepareStatement("SELECT bookingStatus, COUNT(*) AS cnt FROM classbooking GROUP BY bookingStatus");
                 ResultSet rs = ps.executeQuery()) {
                System.out.println("Status counts:");
                while (rs.next()) {
                    System.out.println(rs.getString("bookingStatus") + " = " + rs.getInt("cnt"));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
