package dao;

import model.ClassSchedule;
import util.DBConnection;
import java.sql.*;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

public class ClassScheduleDAO {

    public static final int MIN_HOURS_BEFORE_CANCEL = 12;
    public static final String CANCEL_TOO_LATE_MSG =
        "Classes cannot be cancelled less than 12 hours before the start time.";
    
    /**
     * Generate the next sequential schedule ID in format C001, C002, C003, etc.
     */
    public String generateNextScheduleId() {
        String sql = "SELECT scheduleId FROM classschedule WHERE scheduleId LIKE 'C%' ORDER BY scheduleId DESC LIMIT 1";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            if (rs.next()) {
                String lastId = rs.getString("scheduleId");
                // Extract number from C001, C002, etc.
                if (lastId != null && lastId.startsWith("C") && lastId.length() > 1) {
                    try {
                        int lastNumber = Integer.parseInt(lastId.substring(1));
                        int nextNumber = lastNumber + 1;
                        String nextId = String.format("C%03d", nextNumber);
                        System.out.println("Generated next schedule ID: " + nextId + " (last was: " + lastId + ")");
                        return nextId;
                    } catch (NumberFormatException e) {
                        System.err.println("Could not parse number from scheduleId: " + lastId);
                    }
                }
            }
            
            // If no existing ID found or parsing failed, start with C001
            System.out.println("No existing schedule IDs found, starting with C001");
            return "C001";
            
        } catch (SQLException e) {
            System.err.println("Error generating schedule ID: " + e.getMessage());
            e.printStackTrace();
            return "C001"; // Fallback to C001
        }
    }
    
    public boolean insertAvailability(ClassSchedule schedule) {
        if (availabilitySlotExists(
                schedule.getTeacherId(),
                schedule.getScheduleDate() != null ? schedule.getScheduleDate().toString() : null,
                schedule.getStartTime())) {
            System.out.println("Duplicate availability slot rejected: " + schedule.getScheduleDate() + " " + schedule.getStartTime());
            return false;
        }
        String sql = "INSERT INTO classschedule " +
            "(scheduleId, className, scheduleDate, startTime, endTime, duration, classStatus, teacherId) " +
            "VALUES (?, ?, ?, ?, ?, ?, 'Scheduled', ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            System.out.println("=== Inserting availability ===");
            System.out.println("Schedule ID: " + schedule.getScheduleId());
            System.out.println("Class Name: " + schedule.getClassName());
            System.out.println("Date: " + schedule.getScheduleDate());
            System.out.println("Start: " + schedule.getStartTime());
            System.out.println("End: " + schedule.getEndTime());
            System.out.println("Teacher: " + schedule.getTeacherId());
            
            stmt.setString(1, schedule.getScheduleId());
            stmt.setString(2, schedule.getClassName());
            stmt.setDate(3, Date.valueOf(schedule.getScheduleDate()));
            stmt.setTime(4, Time.valueOf(schedule.getStartTime()));
            stmt.setTime(5, Time.valueOf(schedule.getEndTime()));
            stmt.setInt(6, schedule.getDuration());
            stmt.setString(7, schedule.getTeacherId());
            
            int rowsAffected = stmt.executeUpdate();
            System.out.println("Rows affected: " + rowsAffected);
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("SQL Error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Database error: " + e.getMessage(), e);
        }
    }

    public boolean availabilitySlotExists(String teacherId, String scheduleDate, String startTime) {
        String normalizedStart = startTime;
        if (normalizedStart != null && normalizedStart.length() == 5) {
            normalizedStart = normalizedStart + ":00";
        }
        String sql = "SELECT COUNT(*) AS cnt FROM classschedule " +
                     "WHERE teacherId = ? AND scheduleDate = ? AND startTime = ? " +
                     "AND classStatus NOT IN ('Cancelled')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, teacherId);
            stmt.setDate(2, Date.valueOf(scheduleDate));
            stmt.setTime(3, Time.valueOf(normalizedStart));
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cnt") > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error checking duplicate availability: " + e.getMessage());
        }
        return false;
    }
    
    public List<ClassSchedule> getSchedulesByTeacherId(String teacherId) {
        List<ClassSchedule> schedules = new ArrayList<>();
        String sql = "SELECT * FROM classschedule WHERE teacherId = ? ORDER BY scheduleDate, startTime";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, teacherId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                ClassSchedule schedule = new ClassSchedule();
                schedule.setScheduleId(rs.getString("scheduleId"));
                schedule.setClassName(rs.getString("className"));
                schedule.setScheduleDate(rs.getString("scheduleDate"));
                schedule.setStartTime(rs.getString("startTime"));
                schedule.setEndTime(rs.getString("endTime"));
                schedule.setDuration(rs.getInt("duration"));
                schedule.setClassStatus(rs.getString("classStatus"));
                schedule.setTeacherId(rs.getString("teacherId"));
                schedules.add(schedule);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return schedules;
    }

    /**
     * Fetch schedule records for admin listing. Includes teacher name and booked/assigned student if any.
     */
    public java.util.List<java.util.Map<String, Object>> getAllSchedulesForAdmin() {
        java.util.List<java.util.Map<String, Object>> list = new java.util.ArrayList<>();

        // Booking-centric admin listing: show rows from classbooking joined to classschedule/teacher/student
        String sql = "SELECT b.bookingId AS bookingId, b.bookingStatus AS bookingStatus, b.bookingDate AS scheduleDate, " +
                 "b.bookingTime AS startTime, cs.endTime AS endTime, cs.duration AS duration, cs.className AS className, " +
                 "cs.scheduleId AS scheduleId, t.teacherName AS teacherName, s.studentName AS bookedStudentName " +
                     "FROM classbooking b " +
                     "LEFT JOIN classschedule cs ON b.scheduleId = cs.scheduleId " +
                     "LEFT JOIN teacher t ON cs.teacherId = t.teacherId " +
                     "LEFT JOIN student s ON b.studentId = s.studentId " +
                     "ORDER BY b.bookingDate DESC, b.bookingTime DESC";

        System.out.println("ENTER getAllSchedulesForAdmin");
        System.out.println("SQL: " + sql);

        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                // Print some connection metadata for debugging
                try {
                    java.sql.DatabaseMetaData md = conn.getMetaData();
                    System.out.println("DB Product: " + md.getDatabaseProductName() + " " + md.getDatabaseProductVersion());
                    System.out.println("DB URL: " + md.getURL());
                    System.out.println("DB User: " + md.getUserName());
                    System.out.println("AutoCommit: " + conn.getAutoCommit());
                } catch (Exception metaEx) {
                    System.out.println("Could not read connection metadata: " + metaEx.getMessage());
                }

                try {
                    try (ResultSet rs = stmt.executeQuery()) {
                        int rowCount = 0;
                        while (rs.next()) {
                            rowCount++;
                            java.util.Map<String, Object> row = new java.util.HashMap<>();
                            row.put("bookingId", rs.getString("bookingId"));
                            row.put("scheduleId", rs.getString("scheduleId"));
                            row.put("className", rs.getString("className"));
                            row.put("scheduleDate", rs.getDate("scheduleDate"));
                            row.put("startTime", rs.getTime("startTime"));
                            row.put("endTime", rs.getTime("endTime"));
                            row.put("duration", rs.getInt("duration"));
                            // use bookingStatus as canonical status for admin listing
                            row.put("status", rs.getString("bookingStatus"));
                            row.put("teacherName", rs.getString("teacherName"));
                            row.put("studentId", null);
                            row.put("studentName", rs.getString("bookedStudentName"));
                            row.put("booked", rs.getString("bookingId") != null);
                            list.add(row);
                            if (rowCount <= 3) {
                                System.out.println("Row[" + rowCount + "] bookingId=" + rs.getString("bookingId") + ", scheduleId=" + rs.getString("scheduleId") + ", teacher=" + rs.getString("teacherName"));
                            }
                        }
                        System.out.println("ResultSet rows iterated: " + rowCount);
                    }
                } catch (SQLException ex) {
                    // Retry with fallback SQL if createdAt column is missing in classbooking
                    String msg = ex.getMessage() == null ? "" : ex.getMessage();
                        if (msg.contains("Unknown column") && msg.contains("createdAt")) {
                        System.out.println("createdAt column missing in classbooking; retrying admin query without createdAt");
                        String fallbackSql = "SELECT b.bookingId AS bookingId, b.bookingStatus AS bookingStatus, b.bookingDate AS scheduleDate, " +
                                             "b.bookingTime AS startTime, cs.endTime AS endTime, cs.duration AS duration, cs.className AS className, " +
                                             "cs.scheduleId AS scheduleId, t.teacherName AS teacherName, s.studentName AS bookedStudentName " +
                                             "FROM classbooking b " +
                                             "LEFT JOIN classschedule cs ON b.scheduleId = cs.scheduleId " +
                                             "LEFT JOIN teacher t ON cs.teacherId = t.teacherId " +
                                             "LEFT JOIN student s ON b.studentId = s.studentId " +
                                             "ORDER BY b.bookingDate DESC, b.bookingTime DESC";
                        try (PreparedStatement stmt2 = conn.prepareStatement(fallbackSql)) {
                            try (ResultSet rs2 = stmt2.executeQuery()) {
                                int rowCount2 = 0;
                                while (rs2.next()) {
                                    rowCount2++;
                                    java.util.Map<String, Object> row = new java.util.HashMap<>();
                                    row.put("bookingId", rs2.getString("bookingId"));
                                    row.put("scheduleId", rs2.getString("scheduleId"));
                                    row.put("className", rs2.getString("className"));
                                    row.put("scheduleDate", rs2.getDate("scheduleDate"));
                                    row.put("startTime", rs2.getTime("startTime"));
                                    row.put("endTime", rs2.getTime("endTime"));
                                    row.put("duration", rs2.getInt("duration"));
                                    row.put("status", rs2.getString("bookingStatus"));
                                    row.put("teacherName", rs2.getString("teacherName"));
                                    row.put("studentId", null);
                                    row.put("studentName", rs2.getString("bookedStudentName"));
                                    row.put("booked", rs2.getString("bookingId") != null);
                                    list.add(row);
                                }
                                System.out.println("Fallback ResultSet rows iterated: " + rowCount2);
                            }
                        }
                    } else {
                        throw ex;
                    }
                }
            }

        } catch (SQLException e) {
            System.err.println("SQL Error in getAllSchedulesForAdmin: " + e.getMessage());
            e.printStackTrace();
        }

        System.out.println("DEBUG: getAllSchedulesForAdmin returning rows=" + list.size());
        return list;
    }
    
    // Get availability slots (slots without student bookings) for a teacher
    public List<ClassSchedule> getAvailabilityByTeacherId(String teacherId) {
        List<ClassSchedule> availability = new ArrayList<>();
        
        System.out.println("=== ClassScheduleDAO.getAvailabilityByTeacherId ===");
        System.out.println("Teacher ID: " + teacherId);
        
        // Query returns ALL scheduled classes (including past dates)
        // with booking status so frontend can render them differently (light vs dark purple)
        // Checks for any booking that is NOT rejected (Pending or Approved are shown as booked)
        // No date restriction - shows past, present, and future so teacher can see their full history
        String sql = "SELECT cs.*, CASE " +
                     "WHEN cb.bookingId IS NOT NULL AND cb.bookingStatus NOT IN ('Rejected', 'Cancelled') THEN cb.bookingStatus " +
                     "ELSE NULL " +
                     "END AS isBooked " +
                     "FROM classschedule cs " +
                     "LEFT JOIN classbooking cb ON cs.scheduleId = cb.scheduleId " +
                     "AND cb.bookingStatus NOT IN ('Rejected', 'Cancelled') " +
                     "WHERE cs.teacherId = ? " +
                     "AND cs.classStatus IN ('Scheduled', 'Booked', 'Available') " +
                     "ORDER BY cs.scheduleDate, cs.startTime";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            System.out.println("Attempting to fetch all scheduled classes (available and booked)");
            stmt.setString(1, teacherId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                ClassSchedule schedule = new ClassSchedule();
                schedule.setScheduleId(rs.getString("scheduleId"));
                schedule.setClassName(rs.getString("className"));
                schedule.setScheduleDate(rs.getString("scheduleDate"));
                schedule.setStartTime(rs.getString("startTime"));
                schedule.setEndTime(rs.getString("endTime"));
                schedule.setDuration(rs.getInt("duration"));
                schedule.setClassStatus(rs.getString("classStatus"));
                schedule.setTeacherId(rs.getString("teacherId"));
                
                // Set booking status - will be null for unbooked, or the booking status for booked
                String isBooked = rs.getString("isBooked");
                schedule.setBookingStatus(isBooked);
                
                availability.add(schedule);
                String bookingInfo = isBooked != null ? "BOOKED (" + isBooked + ")" : "AVAILABLE";
                System.out.println("Found " + bookingInfo + " slot: " + schedule.getScheduleDate() + " " + 
                                 schedule.getStartTime() + "-" + schedule.getEndTime());
            }
            
            System.out.println("Query succeeded. Total slots found: " + availability.size());
            
        } catch (SQLException e) {
            System.err.println("SQL Error in getAvailabilityByTeacherId: " + e.getMessage());
            e.printStackTrace();
        }
        
        return availability;
    }
    
    /**
     * Update availability notes
     */
    public boolean updateAvailability(String scheduleId, String teacherId, String notes) {
        String sql = "UPDATE classschedule SET notes = ? WHERE scheduleId = ? AND teacherId = ?";
        
        System.out.println("=== ClassScheduleDAO.updateAvailability ===");
        System.out.println("Schedule ID: " + scheduleId);
        System.out.println("Teacher ID: " + teacherId);
        System.out.println("Notes: " + notes);
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, notes);
            stmt.setString(2, scheduleId);
            stmt.setString(3, teacherId);
            
            int rowsAffected = stmt.executeUpdate();
            System.out.println("Rows updated: " + rowsAffected);
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("SQL Error in updateAvailability: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Update the class status (e.g., Upcoming, Completed, Rescheduled, Cancelled)
     */
    public boolean updateClassStatus(String scheduleId, String newStatus) {
        String sql = "UPDATE classschedule SET classStatus = ? WHERE scheduleId = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, newStatus);
            stmt.setString(2, scheduleId);
            int rows = stmt.executeUpdate();
            System.out.println("updateClassStatus: scheduleId=" + scheduleId + " newStatus=" + newStatus + " rows=" + rows);
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("SQL Error in updateClassStatus: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Reschedule a class (update date/time and mark as Rescheduled)
     */
    public boolean rescheduleClass(String scheduleId, java.time.LocalDate newDate, java.time.LocalTime newStart, java.time.LocalTime newEnd) {
        String sql = "UPDATE classschedule SET scheduleDate = ?, startTime = ?, endTime = ?, classStatus = 'Rescheduled' WHERE scheduleId = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setDate(1, java.sql.Date.valueOf(newDate));
            stmt.setTime(2, java.sql.Time.valueOf(newStart));
            stmt.setTime(3, java.sql.Time.valueOf(newEnd));
            stmt.setString(4, scheduleId);
            int rows = stmt.executeUpdate();
            System.out.println("rescheduleClass: scheduleId=" + scheduleId + " rows=" + rows);
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("SQL Error in rescheduleClass: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Delete availability
     */
    /**
     * Delete or cancel availability
     * If the slot is booked, cancel it (update booking status and add cancellation reason)
     * If not booked, delete the availability
     */
    public boolean deleteAvailability(String scheduleId, String teacherId, String cancellationReason) {
        System.out.println("=== ClassScheduleDAO.deleteAvailability ===");
        System.out.println("Schedule ID: " + scheduleId);
        System.out.println("Teacher ID: " + teacherId);
        System.out.println("Cancellation Reason: " + cancellationReason);
        
        Connection conn = null;
        
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Start transaction
            
            // First, check if this slot has been booked
            String checkBookingSql = "SELECT bookingId, studentId FROM classbooking WHERE scheduleId = ? AND bookingStatus != 'Cancelled'";
            String bookingId = null;
            String studentId = null;
            
            try (PreparedStatement checkStmt = conn.prepareStatement(checkBookingSql)) {
                checkStmt.setString(1, scheduleId);
                try (ResultSet rs = checkStmt.executeQuery()) {
                    if (rs.next()) {
                        bookingId = rs.getString("bookingId");
                        studentId = rs.getString("studentId");
                        System.out.println("Found booking - BookingId: " + bookingId + ", StudentId: " + studentId);
                    }
                }
            }
            
            if (bookingId != null) {
                // Slot is booked - cancel it instead of deleting
                System.out.println("Slot is booked. Cancelling instead of deleting.");
                
                // Update booking status to Cancelled
                String updateBookingSql = "UPDATE classbooking SET bookingStatus = 'Cancelled' WHERE bookingId = ?";
                try (PreparedStatement updateBookingStmt = conn.prepareStatement(updateBookingSql)) {
                    updateBookingStmt.setString(1, bookingId);
                    int updated = updateBookingStmt.executeUpdate();
                    System.out.println("Booking status updated, rows affected: " + updated);
                }
                
                // Insert cancellation reason into studentcancellation table
                String insertCancellationSql = "INSERT INTO studentcancellation (bookingId, cancellationReason) VALUES (?, ?)";
                try (PreparedStatement insertCancellationStmt = conn.prepareStatement(insertCancellationSql)) {
                    insertCancellationStmt.setString(1, bookingId);
                    insertCancellationStmt.setString(2, cancellationReason);
                    int inserted = insertCancellationStmt.executeUpdate();
                    System.out.println("Cancellation reason inserted, rows affected: " + inserted);
                }
                
                System.out.println("Booking cancelled successfully");
                
            } else {
                // Slot is not booked - delete it from classschedule
                System.out.println("Slot is not booked. Deleting from classschedule.");
                
                String deleteSql = "DELETE FROM classschedule WHERE scheduleId = ? AND teacherId = ?";
                try (PreparedStatement deleteStmt = conn.prepareStatement(deleteSql)) {
                    deleteStmt.setString(1, scheduleId);
                    deleteStmt.setString(2, teacherId);
                    
                    int rowsDeleted = deleteStmt.executeUpdate();
                    System.out.println("Rows deleted from classschedule: " + rowsDeleted);
                    
                    if (rowsDeleted == 0) {
                        System.err.println("WARNING: No rows were deleted. Schedule may not exist.");
                    }
                }
            }
            
            conn.commit(); // Commit transaction
            System.out.println("Transaction committed successfully");
            return true;
            
        } catch (SQLException e) {
            System.err.println("SQL Error in deleteAvailability: " + e.getMessage());
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            e.printStackTrace();
            
            // Rollback on error
            if (conn != null) {
                try {
                    System.out.println("Rolling back transaction...");
                    conn.rollback();
                } catch (SQLException ex) {
                    System.err.println("Error during rollback: " + ex.getMessage());
                    ex.printStackTrace();
                }
            }
            return false;
            
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    System.err.println("Error closing connection: " + e.getMessage());
                    e.printStackTrace();
                }
            }
        }
    }

    public boolean isCancellationAllowed(String scheduleId) {
        LocalDateTime classStart = getClassStartDateTime(scheduleId, null);
        return isAtLeastHoursBefore(classStart, MIN_HOURS_BEFORE_CANCEL);
    }

    public boolean isCancellationAllowedByBookingId(String bookingId) {
        LocalDateTime classStart = getClassStartDateTime(null, bookingId);
        return isAtLeastHoursBefore(classStart, MIN_HOURS_BEFORE_CANCEL);
    }

    public static boolean isAtLeastHoursBefore(LocalDateTime classStart, int minimumHours) {
        if (classStart == null) return false;
        LocalDateTime now = LocalDateTime.now();
        if (!classStart.isAfter(now)) return false;
        return Duration.between(now, classStart).toMinutes() >= (long) minimumHours * 60L;
    }

    private LocalDateTime getClassStartDateTime(String scheduleId, String bookingId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return null;

            String sql;
            if (bookingId != null && !bookingId.trim().isEmpty()) {
                sql = "SELECT cs.scheduleDate, cs.startTime FROM classbooking cb " +
                      "INNER JOIN classschedule cs ON cb.scheduleId = cs.scheduleId " +
                      "WHERE cb.bookingId = ? LIMIT 1";
                ps = conn.prepareStatement(sql);
                ps.setString(1, bookingId);
            } else if (scheduleId != null && !scheduleId.trim().isEmpty()) {
                sql = "SELECT scheduleDate, startTime FROM classschedule WHERE scheduleId = ? LIMIT 1";
                ps = conn.prepareStatement(sql);
                ps.setString(1, scheduleId);
            } else {
                return null;
            }

            rs = ps.executeQuery();
            if (!rs.next()) return null;

            LocalDate date = rs.getDate("scheduleDate").toLocalDate();
            Time time = rs.getTime("startTime");
            if (time == null) return null;
            return LocalDateTime.of(date, time.toLocalTime());
        } catch (SQLException e) {
            System.err.println("Error resolving class start time: " + e.getMessage());
            return null;
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
            try { if (ps != null) ps.close(); } catch (SQLException ignored) {}
            try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
        }
    }
}
