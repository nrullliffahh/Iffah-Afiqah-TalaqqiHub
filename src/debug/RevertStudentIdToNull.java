package debug;

import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class RevertStudentIdToNull {
    public static void main(String[] args) {
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                System.err.println("DB connection null");
                return;
            }


            // 1) Drop existing foreign key (if exists)
            try (PreparedStatement ps = conn.prepareStatement("ALTER TABLE classschedule DROP FOREIGN KEY classschedule_ibfk_2")) {
                ps.executeUpdate();
                System.out.println("Dropped foreign key classschedule_ibfk_2");
            } catch (Exception e) {
                System.out.println("Drop FK ignored: " + e.getMessage());
            }

            // 2) Modify column to allow NULL
            try (PreparedStatement ps = conn.prepareStatement("ALTER TABLE classschedule MODIFY studentId varchar(10) DEFAULT NULL")) {
                ps.executeUpdate();
                System.out.println("Modified classschedule.studentId to allow NULL");
            }

            // 3) Set studentId to NULL where there is no active booking
            String updateNull = "UPDATE classschedule cs " +
                    "LEFT JOIN (SELECT DISTINCT scheduleId FROM classbooking WHERE bookingStatus IN ('Upcoming','Confirmed','Approved','Completed')) cb " +
                    "ON cs.scheduleId = cb.scheduleId " +
                    "SET cs.studentId = NULL WHERE cb.scheduleId IS NULL";
            try (PreparedStatement ps = conn.prepareStatement(updateNull)) {
                int c = ps.executeUpdate();
                System.out.println("Set classschedule.studentId to NULL for rows without booking: " + c);
            }

            // 4) Recreate FK with ON DELETE SET NULL
            try (PreparedStatement ps = conn.prepareStatement("ALTER TABLE classschedule ADD CONSTRAINT classschedule_ibfk_2 FOREIGN KEY (studentId) REFERENCES student(studentId) ON DELETE SET NULL ON UPDATE CASCADE")) {
                ps.executeUpdate();
                System.out.println("Recreated foreign key classschedule_ibfk_2 with ON DELETE SET NULL");
            } catch (Exception e) {
                System.out.println("Add FK failed: " + e.getMessage());
            }

            // 5) Report final state
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) AS cnt FROM classschedule WHERE studentId IS NULL");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) System.out.println("Remaining classschedule rows with NULL studentId: " + rs.getInt("cnt"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
