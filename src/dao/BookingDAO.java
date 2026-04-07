package dao;

import model.StudentBooking;
import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

public class BookingDAO {

    public List<StudentBooking> getStudentBookings(String studentId) {
        List<StudentBooking> bookings = new ArrayList<>();
        String sql = "SELECT b.bookingId, b.studentId, b.scheduleId, b.classId, " +
                     "b.bookingDate, b.bookingTime, b.bookingStatus, b.createdAt, " +
                     "cs.className, cs.teacherName, cs.teacherId, cs.duration " +
                     "FROM booking b " +
                     "LEFT JOIN classschedule cs ON b.scheduleId = cs.scheduleId " +
                     "WHERE b.studentId = ? " +
                     "ORDER BY b.bookingDate DESC, b.bookingTime DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, studentId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    StudentBooking booking = new StudentBooking();
                    booking.setBookingId(rs.getString("bookingId"));
                    booking.setStudentId(rs.getString("studentId"));
                    booking.setScheduleId(rs.getString("scheduleId"));
                    booking.setClassId(rs.getString("classId"));
                    
                    if (rs.getDate("bookingDate") != null) {
                        booking.setBookingDate(rs.getDate("bookingDate").toLocalDate());
                    }
                    if (rs.getTime("bookingTime") != null) {
                        booking.setBookingTime(rs.getTime("bookingTime").toLocalTime());
                    }
                    
                    booking.setBookingStatus(rs.getString("bookingStatus"));
                    
                    if (rs.getDate("createdAt") != null) {
                        booking.setCreatedAt(rs.getDate("createdAt").toLocalDate());
                    }
                    
                    booking.setClassName(rs.getString("className"));
                    booking.setTeacherName(rs.getString("teacherName"));
                    booking.setTeacherId(rs.getString("teacherId"));
                    booking.setDuration(rs.getInt("duration"));
                    
                    bookings.add(booking);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return bookings;
    }

    public boolean createBooking(StudentBooking booking) {
        String sql = "INSERT INTO booking (bookingId, studentId, scheduleId, classId, " +
                     "bookingDate, bookingTime, bookingStatus, createdAt) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, booking.getBookingId());
            ps.setString(2, booking.getStudentId());
            ps.setString(3, booking.getScheduleId());
            ps.setString(4, booking.getClassId());
            ps.setDate(5, booking.getBookingDate() != null ? java.sql.Date.valueOf(booking.getBookingDate()) : null);
            ps.setTime(6, booking.getBookingTime() != null ? java.sql.Time.valueOf(booking.getBookingTime()) : null);
            ps.setString(7, booking.getBookingStatus() != null ? booking.getBookingStatus() : "Confirmed");
            ps.setDate(8, booking.getCreatedAt() != null ? java.sql.Date.valueOf(booking.getCreatedAt()) : java.sql.Date.valueOf(LocalDate.now()));

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean cancelBooking(String bookingId, String reason) {
        Connection conn = null;
        PreparedStatement ps1 = null;
        PreparedStatement ps2 = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            String updateBookingSql = "UPDATE booking SET bookingStatus = 'Cancelled' WHERE bookingId = ?";
            ps1 = conn.prepareStatement(updateBookingSql);
            ps1.setString(1, bookingId);
            int rowsUpdated = ps1.executeUpdate();

            if (rowsUpdated > 0) {
                String insertCancellationSql = "INSERT INTO student_cancellation " +
                                               "(bookingId, studentId, reason, cancellationDate, cancellationTime, status) " +
                                               "SELECT bookingId, studentId, ?, ?, ?, 'Processed' FROM booking WHERE bookingId = ?";
                ps2 = conn.prepareStatement(insertCancellationSql);
                ps2.setString(1, reason);
                ps2.setDate(2, java.sql.Date.valueOf(LocalDate.now()));
                ps2.setTime(3, java.sql.Time.valueOf(LocalTime.now()));
                ps2.setString(4, bookingId);
                ps2.executeUpdate();
            }

            conn.commit();
            return rowsUpdated > 0;

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (ps1 != null) ps1.close();
                if (ps2 != null) ps2.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    public int getMonthlySessionCount(String studentId) {
        String sql = "SELECT COUNT(*) as sessionCount FROM booking " +
                     "WHERE studentId = ? " +
                     "AND MONTH(bookingDate) = MONTH(CURRENT_DATE()) " +
                     "AND YEAR(bookingDate) = YEAR(CURRENT_DATE()) " +
                     "AND bookingStatus IN ('Confirmed', 'Completed')";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, studentId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("sessionCount");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    public List<StudentBooking> getBookingsByStudentId(String studentId) {
        return getStudentBookings(studentId);
    }

    public boolean cancelBooking(String bookingId, String studentId, String reason) {
        return cancelBooking(bookingId, reason);
    }

    public int countUsedSessions(String studentId) {
        String sql = "SELECT COUNT(*) as used FROM booking " +
                     "WHERE studentId = ? " +
                     "AND MONTH(bookingDate) = MONTH(CURRENT_DATE()) " +
                     "AND YEAR(bookingDate) = YEAR(CURRENT_DATE()) " +
                     "AND bookingStatus IN ('Completed')";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, studentId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("used");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    public int countTotalSessions(String studentId) {
        return 16;
    }
}