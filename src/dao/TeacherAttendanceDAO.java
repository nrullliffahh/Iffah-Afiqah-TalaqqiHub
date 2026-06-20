package dao;

import model.Attendance;
import util.DBConnection;
import java.sql.*;
import java.util.*;

public class TeacherAttendanceDAO {
    
    public List<Attendance> getAllByTeacher(String teacherId) {
        List<Attendance> records = new ArrayList<>();
        String query = "SELECT " +
                      "MIN(a.attendanceId) AS attendanceId, " +
                      "s.studentName, " +
                      "s.studentId AS studentCode, " +
                      "cs.className, " +
                      "cs.className AS sessionName, " +
                      "t.teacherName, " +
                      "a.attendanceDate, " +
                      "CONCAT(TIME_FORMAT(cs.startTime, '%h:%i %p'), ' - ', TIME_FORMAT(cs.endTime, '%h:%i %p')) AS timeRange, " +
                      "MAX(a.attendanceStatus) AS attendanceStatus, " +
                      "TIME_FORMAT(MIN(a.joinTime), '%h:%i %p') AS joinTime, " +
                      "TIME_FORMAT(MAX(a.leaveTime), '%h:%i %p') AS leaveTime " +
                      "FROM attendance a " +
                      "INNER JOIN student s ON a.studentId = s.studentId " +
                      "INNER JOIN teacher t ON a.teacherId = t.teacherId " +
                      "INNER JOIN classschedule cs ON a.scheduleId = cs.scheduleId " +
                      "WHERE a.teacherId = ? " +
                      "GROUP BY s.studentName, s.studentId, a.attendanceDate, cs.className, t.teacherName, cs.startTime, cs.endTime " +
                      "ORDER BY a.attendanceDate DESC " +
                      "LIMIT 500";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setString(1, teacherId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Attendance record = new Attendance();
                record.setId(0);
                record.setStudentName(rs.getString("studentName"));
                record.setStudentCode(rs.getString("studentCode"));
                record.setClassName(rs.getString("className"));
                record.setSessionName(rs.getString("sessionName"));
                record.setTeacherName(rs.getString("teacherName"));
                record.setSessionDate(rs.getDate("attendanceDate"));
                record.setTimeRange(rs.getString("timeRange"));
                record.setStatus(rs.getString("attendanceStatus"));
                
                String joinTime = rs.getString("joinTime");
                String leaveTime = rs.getString("leaveTime");
                
                record.setJoinTime(joinTime != null && !joinTime.equals("null") ? joinTime : null);
                record.setLeaveTime(leaveTime != null && !leaveTime.equals("null") ? leaveTime : null);
                
                records.add(record);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return records;
    }
    
    public int getTotalStudents(String teacherId) {
        String query = "SELECT COUNT(DISTINCT a.studentId) as total FROM attendance a WHERE a.teacherId = ? AND MONTH(a.attendanceDate) = MONTH(NOW()) AND YEAR(a.attendanceDate) = YEAR(NOW())";
        return getCountQuery(query, teacherId);
    }
    
    public int getTotalSessions(String teacherId) {
        String query = "SELECT COUNT(DISTINCT DATE(a.attendanceDate)) as total FROM attendance a WHERE a.teacherId = ? AND MONTH(a.attendanceDate) = MONTH(NOW()) AND YEAR(a.attendanceDate) = YEAR(NOW())";
        return getCountQuery(query, teacherId);
    }
    
    public int getPresentCount(String teacherId) {
        String query = "SELECT COUNT(*) as total FROM attendance a WHERE a.teacherId = ? AND a.attendanceStatus = 'Present' AND MONTH(a.attendanceDate) = MONTH(NOW()) AND YEAR(a.attendanceDate) = YEAR(NOW())";
        return getCountQuery(query, teacherId);
    }
    
    public int getAbsentCount(String teacherId) {
        String query = "SELECT COUNT(*) as total FROM attendance a WHERE a.teacherId = ? AND a.attendanceStatus = 'Absent' AND MONTH(a.attendanceDate) = MONTH(NOW()) AND YEAR(a.attendanceDate) = YEAR(NOW())";
        return getCountQuery(query, teacherId);
    }
    
    public int getLateCount(String teacherId) {
        String query = "SELECT COUNT(*) as total FROM attendance a WHERE a.teacherId = ? AND a.attendanceStatus = 'Late' AND MONTH(a.attendanceDate) = MONTH(NOW()) AND YEAR(a.attendanceDate) = YEAR(NOW())";
        return getCountQuery(query, teacherId);
    }
    
    private int getCountQuery(String query, String teacherId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setString(1, teacherId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
    
    public Map<String, Integer> getAttendanceTrend(String teacherId) {
        Map<String, Integer> trend = new LinkedHashMap<>();
        String query = "SELECT WEEK(a.attendanceDate) as week_num, COUNT(*) as present_count " +
                      "FROM attendance a " +
                      "WHERE a.teacherId = ? AND a.attendanceStatus = 'Present' " +
                      "GROUP BY WEEK(a.attendanceDate) " +
                      "ORDER BY week_num";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setString(1, teacherId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                int weekNum = rs.getInt("week_num");
                int count = rs.getInt("present_count");
                trend.put("Week " + weekNum, count);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return trend;
    }
    
    public Map<String, Map<String, Integer>> getWeeklyAttendanceTrend(String teacherId) {
        Map<String, Map<String, Integer>> weeklyData = new LinkedHashMap<>();
        
        // Get today's date
        java.util.Calendar today = java.util.Calendar.getInstance();
        int currentMonth = today.get(java.util.Calendar.MONTH);
        int currentYear = today.get(java.util.Calendar.YEAR);
        
        // Get first day of current month
        java.util.Calendar monthStart = java.util.Calendar.getInstance();
        monthStart.set(currentYear, currentMonth, 1);
        
        // Get last day of current month
        java.util.Calendar monthEnd = java.util.Calendar.getInstance();
        monthEnd.set(currentYear, currentMonth, monthStart.getActualMaximum(java.util.Calendar.DAY_OF_MONTH));
        
        // Generate weeks within current month (7 days each)
        java.util.Calendar weekStart = java.util.Calendar.getInstance();
        weekStart.setTime(monthStart.getTime());
        
        while (weekStart.before(monthEnd) || weekStart.equals(monthEnd)) {
            java.util.Calendar weekEnd = java.util.Calendar.getInstance();
            weekEnd.setTime(weekStart.getTime());
            weekEnd.add(java.util.Calendar.DAY_OF_MONTH, 6);
            
            // Don't go beyond month end
            if (weekEnd.after(monthEnd)) {
                weekEnd.setTime(monthEnd.getTime());
            }
            
            java.sql.Date sqlStart = new java.sql.Date(weekStart.getTimeInMillis());
            java.sql.Date sqlEnd = new java.sql.Date(weekEnd.getTimeInMillis());
            
            String query = "SELECT a.attendanceStatus, COUNT(*) as count " +
                          "FROM attendance a " +
                          "WHERE a.teacherId = ? " +
                          "AND DATE(a.attendanceDate) BETWEEN ? AND ? " +
                          "GROUP BY a.attendanceStatus";
            
            Map<String, Integer> statusCounts = new HashMap<>();
            statusCounts.put("Present", 0);
            statusCounts.put("Absent", 0);
            statusCounts.put("Late", 0);
            
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(query)) {
                
                ps.setString(1, teacherId);
                ps.setDate(2, sqlStart);
                ps.setDate(3, sqlEnd);
                
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    String status = rs.getString("attendanceStatus");
                    int count = rs.getInt("count");
                    statusCounts.put(status, count);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            
            String dateRange = String.format("%02d/%02d - %02d/%02d",
                    weekStart.get(java.util.Calendar.MONTH) + 1,
                    weekStart.get(java.util.Calendar.DAY_OF_MONTH),
                    weekEnd.get(java.util.Calendar.MONTH) + 1,
                    weekEnd.get(java.util.Calendar.DAY_OF_MONTH));
            
            weeklyData.put(dateRange, statusCounts);
            
            // Move to next week
            weekStart.add(java.util.Calendar.DAY_OF_MONTH, 7);
        }
        
        return weeklyData;
    }

    public List<String> getDistinctStudentNamesByTeacher(String teacherId) {
        List<String> names = new ArrayList<>();
        String query = "SELECT DISTINCT s.studentName " +
                       "FROM classbooking cb " +
                       "INNER JOIN classschedule cs ON cb.scheduleId = cs.scheduleId " +
                       "INNER JOIN student s ON cb.studentId = s.studentId " +
                       "WHERE cs.teacherId = ? " +
                       "AND cb.bookingStatus NOT IN ('Cancelled', 'Rejected') " +
                       "AND s.studentName IS NOT NULL " +
                       "UNION " +
                       "SELECT DISTINCT s2.studentName " +
                       "FROM attendance a " +
                       "INNER JOIN student s2 ON a.studentId = s2.studentId " +
                       "WHERE a.teacherId = ? AND s2.studentName IS NOT NULL " +
                       "ORDER BY studentName ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, teacherId);
            ps.setString(2, teacherId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                String name = rs.getString("studentName");
                if (name != null && !name.trim().isEmpty()) {
                    names.add(name.trim());
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return names;
    }
}
