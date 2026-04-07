package debug;

import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class ListStudentCancellations {
    public static void main(String[] args) {
        String sql = "SELECT bookingId, cancellationReason, cancelledAt, cancelledBy FROM studentcancellation ORDER BY cancelledAt DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            System.out.println("studentcancellation rows:");
            int i = 0;
            while (rs.next()) {
                i++;
                System.out.printf("%d) bookingId=%s by=%s at=%s reason=%s\n", i, rs.getString("bookingId"), rs.getString("cancelledBy"), rs.getTimestamp("cancelledAt"), rs.getString("cancellationReason"));
            }
            if (i==0) System.out.println("(no rows)");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
