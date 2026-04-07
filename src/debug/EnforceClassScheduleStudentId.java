package debug;

import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class EnforceClassScheduleStudentId {
    public static void main(String[] args) {
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                System.err.println("DB connection null");
                return;
            }

            // 1) ensure placeholder student exists
            String insertPlaceholder = "INSERT IGNORE INTO student (studentId, studentName, studentEmail, studentPassword, registrationDate, packageId) " +
                    "VALUES ('S000','Unassigned Student','unassigned@example.com','changeme',CURDATE(),'P001')";
            try (PreparedStatement ps = conn.prepareStatement(insertPlaceholder)) {
                int c = ps.executeUpdate();
                System.out.println("Inserted placeholder student rows: " + c);
            }

            // 2) populate classschedule.studentId from bookings where available
            String updateFromBooking = "UPDATE classschedule cs JOIN classbooking cb ON cs.scheduleId = cb.scheduleId " +
                    "SET cs.studentId = cb.studentId " +
                    "WHERE cs.studentId IS NULL AND cb.bookingStatus IN ('Upcoming','Confirmed','Approved','Completed')";
            try (PreparedStatement ps = conn.prepareStatement(updateFromBooking)) {
                int c = ps.executeUpdate();
                System.out.println("Updated classschedule.studentId from bookings: " + c);
            }

            // 3) set remaining NULL studentId to placeholder
            String setPlaceholder = "UPDATE classschedule SET studentId = 'S000' WHERE studentId IS NULL";
            try (PreparedStatement ps = conn.prepareStatement(setPlaceholder)) {
                int c = ps.executeUpdate();
                System.out.println("Set placeholder for remaining classschedule rows: " + c);
            }

            // 4) alter FK: drop existing FK and set column NOT NULL then recreate FK with RESTRICT
            System.out.println("Altering table: changing studentId to NOT NULL and updating FK");
            try (PreparedStatement ps = conn.prepareStatement("ALTER TABLE classschedule DROP FOREIGN KEY classschedule_ibfk_2")) {
                ps.executeUpdate();
                System.out.println("Dropped foreign key classschedule_ibfk_2");
            } catch (Exception e) {
                System.out.println("Drop FK failed (maybe it doesn't exist): " + e.getMessage());
            }

            try (PreparedStatement ps = conn.prepareStatement("ALTER TABLE classschedule MODIFY studentId varchar(10) NOT NULL")) {
                ps.executeUpdate();
                System.out.println("Modified studentId to NOT NULL");
            }

            try (PreparedStatement ps = conn.prepareStatement("ALTER TABLE classschedule ADD CONSTRAINT classschedule_ibfk_2 FOREIGN KEY (studentId) REFERENCES student(studentId) ON DELETE RESTRICT ON UPDATE CASCADE")) {
                ps.executeUpdate();
                System.out.println("Recreated foreign key classschedule_ibfk_2 with ON DELETE RESTRICT");
            }

            // 5) report final state
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) AS cnt FROM classschedule WHERE studentId IS NULL");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) System.out.println("Remaining classschedule rows with NULL studentId: " + rs.getInt("cnt"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
