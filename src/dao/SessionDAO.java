package dao;

import model.Session;
import model.ClassSchedule;
import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
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
        Session session = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getNextUpcomingSession: DB connection is null. Cannot query next session.");
                return null;
            }
            // Use classbooking/classschedule as the DB contains those tables
            String sql = "SELECT cb.bookingId AS sessionId, cb.studentId, cs.teacherId, t.teacherName, " +
                        "cb.bookingDate AS sessionDate, cb.bookingTime AS sessionTime, cs.className AS sessionType, cb.bookingStatus AS sessionStatus " +
                        "FROM classbooking cb " +
                        "LEFT JOIN classschedule cs ON cb.scheduleId = cs.scheduleId " +
                        "LEFT JOIN teacher t ON cs.teacherId = t.teacherId " +
                        "WHERE cb.studentId = ? AND cb.bookingDate >= CURDATE() " +
                        "ORDER BY cb.bookingDate ASC, cb.bookingTime ASC LIMIT 1";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, studentId);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                session = new Session();
                session.setSessionId(rs.getString("sessionId"));
                session.setStudentId(rs.getString("studentId"));
                session.setTeacherId(rs.getString("teacherId"));
                session.setTeacherName(rs.getString("teacherName"));
                session.setSessionDate(rs.getString("sessionDate"));
                session.setSessionTime(rs.getString("sessionTime"));
                session.setSessionType(rs.getString("sessionType"));
                session.setStatus(rs.getString("sessionStatus"));
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting next session: " + e.getMessage());
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
        
        return session;
    }
    
    public int getUpcomingSessionCount(String studentId) {
        int count = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getUpcomingSessionCount: DB connection is null. Returning count=0.");
                return 0;
            }
            String sql = "SELECT COUNT(*) as total FROM classbooking " +
                        "WHERE studentId = ? AND bookingDate >= CURDATE()";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, studentId);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                count = rs.getInt("total");
            }
            
        } catch (SQLException e) {
            System.err.println("Error counting upcoming sessions: " + e.getMessage());
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
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            // Include bookings from classbooking so booked slots show student info
            String sql = "SELECT cs.scheduleId, cs.className, cs.scheduleDate, " +
                        "cs.startTime, cs.endTime, cs.duration, cs.classStatus, " +
                        "cb.studentId AS bookedStudentId, s2.studentName AS bookedStudentName, " +
                        "cs.studentId AS assignedStudentId, s1.studentName AS assignedStudentName " +
                        "FROM classschedule cs " +
                            "LEFT JOIN classbooking cb ON cb.scheduleId = cs.scheduleId " +
                            "    AND cb.bookingDate = cs.scheduleDate AND cb.bookingStatus IN " + util.BookingStatus.SQL_ACTIVE + " " +
                        "LEFT JOIN student s2 ON cb.studentId = s2.studentId " +
                        "LEFT JOIN student s1 ON cs.studentId = s1.studentId " +
                        "WHERE cs.teacherId = ? " +
                        "AND cs.scheduleDate >= CURDATE() " +
                        "AND (cb.bookingId IS NOT NULL OR cs.studentId IS NOT NULL) " +
                        "GROUP BY cs.scheduleId " +
                        "ORDER BY cs.scheduleDate ASC, cs.startTime ASC LIMIT ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, teacherId);
            stmt.setInt(2, limit);
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> classInfo = new HashMap<>();
                classInfo.put("scheduleId", rs.getString("scheduleId"));
                classInfo.put("className", rs.getString("className"));
                classInfo.put("scheduleDate", rs.getDate("scheduleDate"));
                classInfo.put("startTime", rs.getTime("startTime"));
                classInfo.put("endTime", rs.getTime("endTime"));
                classInfo.put("duration", rs.getInt("duration"));
                classInfo.put("status", rs.getString("classStatus"));
                // Prefer booked student (from classbooking) if present, else fall back to assigned student
                String bookedStudentId = rs.getString("bookedStudentId");
                String bookedStudentName = rs.getString("bookedStudentName");
                String assignedStudentId = rs.getString("assignedStudentId");
                String assignedStudentName = rs.getString("assignedStudentName");

                if (bookedStudentId != null && !bookedStudentId.isEmpty()) {
                    classInfo.put("studentId", bookedStudentId);
                    classInfo.put("studentName", bookedStudentName != null ? bookedStudentName : "");
                    classInfo.put("booked", true);
                } else if (assignedStudentId != null && !assignedStudentId.isEmpty()) {
                    classInfo.put("studentId", assignedStudentId);
                    classInfo.put("studentName", assignedStudentName != null ? assignedStudentName : "");
                    classInfo.put("booked", false);
                } else {
                    // Skip unbooked availability for teacher's upcoming classes list
                    continue;
                }
                classList.add(classInfo);
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
                        "WHERE cs.teacherId = ? " +
                        "AND CONCAT(cs.scheduleDate, ' ', cs.startTime) > NOW() " +
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
