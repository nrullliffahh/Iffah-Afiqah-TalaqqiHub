package dao;

import model.Session;
import model.ClassSchedule;
import model.StudentBooking;
import util.BookingPartitionUtil;
import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SessionDAO {

    public List<ClassSchedule> getAvailableSchedulesByDate(LocalDate date) {
        List<ClassSchedule> schedules = new ArrayList<>();
        String sql = "SELECT scheduleId, className, scheduleDate, startTime, endTime, " +
                     "duration, classStatus FROM classschedule " +
                     "WHERE scheduleDate = ? AND classStatus = 'Available' " +
                     "ORDER BY startTime ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, java.sql.Date.valueOf(date));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ClassSchedule schedule = new ClassSchedule();
                    schedule.setScheduleId(rs.getString("scheduleId"));
                    schedule.setClassName(rs.getString("className"));
                    
                    if (rs.getDate("scheduleDate") != null) {
                        schedule.setScheduleDate(rs.getDate("scheduleDate").toLocalDate());
                    }
                    if (rs.getTime("startTime") != null) {
                        schedule.setStartTime(rs.getTime("startTime").toLocalTime());
                    }
                    if (rs.getTime("endTime") != null) {
                        schedule.setEndTime(rs.getTime("endTime").toLocalTime());
                    }
                    
                    schedule.setDuration(rs.getInt("duration"));
                    schedule.setClassStatus(rs.getString("classStatus"));
                    
                    schedules.add(schedule);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return schedules;
    }

    
    public Session getNextUpcomingSession(String studentId) {
        List<StudentBooking> active = loadUpcomingAndRescheduledThisMonth(studentId);
        if (active.isEmpty()) {
            return null;
        }
        return toDashboardSession(active.get(0));
    }
    
    public int getUpcomingSessionCount(String studentId) {
        return loadUpcomingAndRescheduledThisMonth(studentId).size();
    }

    /** Same partitions as Class Booking: Upcoming + Rescheduled for the current month. */
    private List<StudentBooking> loadUpcomingAndRescheduledThisMonth(String studentId) {
        List<StudentBooking> empty = new ArrayList<>();
        if (studentId == null || studentId.trim().isEmpty()) {
            return empty;
        }
        try {
            StudentBookingDAO bookingDAO = new StudentBookingDAO();
            List<StudentBooking> bookings = bookingDAO.getMyBookingsByMonth(studentId.trim());
            BookingPartitionUtil.Partition partitioned = BookingPartitionUtil.partition(bookings);
            List<StudentBooking> active = new ArrayList<>();
            active.addAll(partitioned.upcoming);
            active.addAll(partitioned.rescheduled);
            active.sort(Comparator
                .comparing(StudentBooking::getBookingDate, Comparator.nullsLast(Comparator.naturalOrder()))
                .thenComparing(b -> b.getBookingTime() != null ? b.getBookingTime() : LocalTime.MIN));
            return active;
        } catch (Exception e) {
            System.err.println("loadUpcomingAndRescheduledThisMonth: " + e.getMessage());
            return empty;
        }
    }

    private static Session toDashboardSession(StudentBooking booking) {
        Session session = new Session();
        session.setSessionId(booking.getBookingId());
        session.setStudentId(booking.getStudentId());
        session.setTeacherId(booking.getTeacherId());
        session.setTeacherName(booking.getTeacherName());
        if (booking.getBookingDate() != null) {
            session.setSessionDate(booking.getBookingDate().toString());
        }
        if (booking.getBookingTime() != null) {
            session.setSessionTime(booking.getBookingTime().toString());
        }
        session.setSessionType(booking.getClassName());
        session.setStatus(booking.getBookingStatus());
        return session;
    }
    
    public int getCompletedSessionCount(String studentId) {
        int count = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getCompletedSessionCount: DB connection is null. Returning count=0.");
                return 0;
            }

            // Prefer explicit bookingStatus = 'Completed' if present in the DB.
            // Fallback: treat past bookings (bookingDate < CURDATE()) as completed when status is not 'Cancelled'.
            String sql = "SELECT COUNT(*) as total FROM classbooking " +
                        "WHERE studentId = ? AND (bookingStatus = 'Completed' OR (bookingDate < CURDATE() AND bookingStatus IS NULL) OR (bookingDate < CURDATE() AND bookingStatus != 'Cancelled'))";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, studentId);

            rs = pstmt.executeQuery();

            if (rs.next()) {
                count = rs.getInt("total");
            }
            
        } catch (SQLException e) {
            System.err.println("Error counting completed sessions: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return count;
    }
    
    public int getTotalSessionCount(String studentId) {
        int count = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT COUNT(*) as total FROM classbooking WHERE studentId = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, studentId);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                count = rs.getInt("total");
            }
            
        } catch (SQLException e) {
            System.err.println("Error counting total sessions: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return count;
    }

    /**
     * Get completed sessions for the current month only
     * This resets progress at the beginning of each new month
     */
    public int getCompletedSessionCountByMonth(String studentId) {
        int count = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getCompletedSessionCountByMonth: DB connection is null. Returning count=0.");
                return 0;
            }

            // Filter by current month and year
            String sql = "SELECT COUNT(*) as total FROM classbooking " +
                        "WHERE studentId = ? " +
                        "AND MONTH(bookingDate) = MONTH(CURDATE()) " +
                        "AND YEAR(bookingDate) = YEAR(CURDATE()) " +
                        "AND (bookingStatus = 'Completed' OR (bookingDate < CURDATE() AND bookingStatus IS NULL) OR (bookingDate < CURDATE() AND bookingStatus != 'Cancelled'))";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, studentId);

            rs = pstmt.executeQuery();

            if (rs.next()) {
                count = rs.getInt("total");
            }
            
        } catch (SQLException e) {
            System.err.println("Error counting completed sessions by month: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return count;
    }
    
    /**
     * Get upcoming classes for a specific teacher
     * Returns list of maps with class details including student info
     */
    public List<Map<String, Object>> getUpcomingClasses(String teacherId, int limit) {
        List<Map<String, Object>> classList = new ArrayList<>();
        java.util.LinkedHashMap<String, Map<String, Object>> bySchedule = new java.util.LinkedHashMap<>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT cs.scheduleId, cs.className, cs.scheduleDate, " +
                        "cs.startTime, cs.endTime, cs.duration, cs.classStatus, " +
                        "cb.studentId AS bookedStudentId, s2.studentName AS bookedStudentName, " +
                        "cs.studentId AS assignedStudentId, s1.studentName AS assignedStudentName " +
                        "FROM classschedule cs " +
                        "LEFT JOIN classbooking cb ON cb.scheduleId = cs.scheduleId " +
                        "    AND cb.bookingStatus IN " + util.BookingStatus.SQL_ACTIVE + " " +
                        "LEFT JOIN student s2 ON cb.studentId = s2.studentId " +
                        "LEFT JOIN student s1 ON cs.studentId = s1.studentId " +
                        "WHERE cs.teacherId = ? " +
                        "AND cs.scheduleDate >= CURDATE() " +
                        "AND (cs.classStatus IS NULL OR cs.classStatus != 'Cancelled') " +
                        "AND (cb.bookingId IS NOT NULL OR cs.studentId IS NOT NULL) " +
                        "ORDER BY cs.scheduleDate ASC, cs.startTime ASC";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, teacherId);
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                String scheduleId = rs.getString("scheduleId");
                if (scheduleId == null || bySchedule.containsKey(scheduleId)) {
                    continue;
                }

                String bookedStudentId = rs.getString("bookedStudentId");
                String bookedStudentName = rs.getString("bookedStudentName");
                String assignedStudentId = rs.getString("assignedStudentId");
                String assignedStudentName = rs.getString("assignedStudentName");

                String chosenStudentId = null;
                String chosenStudentName = null;
                boolean isBooked = false;

                if (bookedStudentId != null && !bookedStudentId.isEmpty()) {
                    chosenStudentId = bookedStudentId;
                    chosenStudentName = bookedStudentName != null ? bookedStudentName : "";
                    isBooked = true;
                } else if (assignedStudentId != null && !assignedStudentId.isEmpty()) {
                    chosenStudentId = assignedStudentId;
                    chosenStudentName = assignedStudentName != null ? assignedStudentName : "";
                }

                if (chosenStudentId == null || chosenStudentName == null || chosenStudentName.trim().isEmpty()) {
                    continue;
                }

                Map<String, Object> classInfo = new HashMap<>();
                classInfo.put("scheduleId", scheduleId);
                classInfo.put("className", rs.getString("className"));
                classInfo.put("scheduleDate", rs.getDate("scheduleDate"));
                classInfo.put("startTime", rs.getTime("startTime"));
                classInfo.put("endTime", rs.getTime("endTime"));
                classInfo.put("duration", rs.getInt("duration"));
                classInfo.put("status", rs.getString("classStatus"));
                classInfo.put("studentId", chosenStudentId);
                classInfo.put("studentName", chosenStudentName);
                classInfo.put("booked", isBooked);
                bySchedule.put(scheduleId, classInfo);

                if (bySchedule.size() >= limit) {
                    break;
                }
            }

            classList.addAll(bySchedule.values());
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return classList;
    }
    
    /**
     * Get the next upcoming class for countdown display
     */
    public Map<String, Object> getNextClass(String teacherId) {
        Map<String, Object> nextClass = null;
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT cs.scheduleDate, cs.startTime " +
                        "FROM classschedule cs " +
                        "LEFT JOIN classbooking cb ON cb.scheduleId = cs.scheduleId " +
                        "    AND cb.bookingStatus IN " + util.BookingStatus.SQL_ACTIVE + " " +
                        "WHERE cs.teacherId = ? " +
                        "AND CONCAT(cs.scheduleDate, ' ', cs.startTime) > NOW() " +
                        "AND (cs.classStatus IS NULL OR cs.classStatus != 'Cancelled') " +
                        "AND (cb.bookingId IS NOT NULL OR cs.studentId IS NOT NULL) " +
                        "ORDER BY cs.scheduleDate ASC, cs.startTime ASC LIMIT 1";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, teacherId);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                nextClass = new HashMap<>();
                nextClass.put("scheduleDate", rs.getDate("scheduleDate"));
                nextClass.put("startTime", rs.getTime("startTime"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return nextClass;
    }
    
    public int getTotalSessionsCount() {
        int count = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT COUNT(*) as total FROM classschedule";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                count = rs.getInt("total");
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting total sessions: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return count;
    }
    
    public int getUpcomingSessionsCount() {
        int count = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT COUNT(*) as total FROM classschedule WHERE scheduleDate >= CURDATE() AND classStatus != 'Cancelled'";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                count = rs.getInt("total");
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting upcoming sessions: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return count;
    }
    
    public int getCompletedSessionsCount() {
        int count = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT COUNT(*) as total FROM classschedule WHERE scheduleDate < CURDATE() AND classStatus != 'Cancelled'";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                count = rs.getInt("total");
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting completed sessions: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return count;
    }
    
    public int getCancelledSessionsCount() {
        int count = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT COUNT(*) as total FROM classschedule WHERE classStatus = 'Cancelled'";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                count = rs.getInt("total");
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting cancelled sessions: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return count;
    }
    
    public List<Map<String, Object>> getRecentActivities(int limit) {
        List<Map<String, Object>> activities = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT cs.scheduleId, cs.className, cs.scheduleDate, cs.classStatus, " +
                        "t.teacherName, s.studentName, cs.startTime " +
                        "FROM classschedule cs " +
                        "LEFT JOIN teacher t ON cs.teacherId = t.teacherId " +
                        "LEFT JOIN student s ON cs.studentId = s.studentId " +
                        "ORDER BY cs.scheduleDate DESC, cs.startTime DESC LIMIT ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, limit);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> activity = new HashMap<>();
                activity.put("className", rs.getString("className"));
                activity.put("teacherName", rs.getString("teacherName"));
                activity.put("studentName", rs.getString("studentName"));
                activity.put("scheduleDate", rs.getDate("scheduleDate"));
                activity.put("classStatus", rs.getString("classStatus"));
                activities.add(activity);
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting recent activities: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return activities;
    }
}
