package debug;

import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class PrintBookingStatusColumn {
    public static void main(String[] args) {
        String sql = "SELECT COLUMN_TYPE, DATA_TYPE, COLUMN_DEFAULT FROM INFORMATION_SCHEMA.COLUMNS " +
                     "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'classbooking' AND COLUMN_NAME = 'bookingStatus'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                System.out.println("COLUMN_TYPE: " + rs.getString("COLUMN_TYPE"));
                System.out.println("DATA_TYPE: " + rs.getString("DATA_TYPE"));
                System.out.println("COLUMN_DEFAULT: " + rs.getString("COLUMN_DEFAULT"));
            } else {
                System.out.println("Column bookingStatus not found in classbooking");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
