import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class DbTeacherList {
    public static void main(String[] args) {
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                System.out.println("Connection is null");
                return;
            }
            System.out.println("--- SHOW CREATE TABLE teacher ---");
            try (PreparedStatement ps = conn.prepareStatement("SHOW CREATE TABLE teacher"); ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    System.out.println(rs.getString(2));
                }
            } catch (Exception e) {
                System.out.println("SHOW CREATE TABLE teacher failed: " + e.getMessage());
            }

            System.out.println("--- SHOW CREATE TABLE student ---");
            try (PreparedStatement ps2 = conn.prepareStatement("SHOW CREATE TABLE student"); ResultSet rs2 = ps2.executeQuery()) {
                if (rs2.next()) {
                    System.out.println(rs2.getString(2));
                }
            } catch (Exception e) {
                System.out.println("SHOW CREATE TABLE student failed: " + e.getMessage());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
