package dao;

import model.StudentAttendance;
import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;
import java.sql.Time;
import java.util.*;

public class StudentAttendanceDAO {
    
    public List<StudentAttendance> getAttendanceByStudent(String studentId) {
        List<StudentAttendance> records = new ArrayList<>();
        String query = "SELECT MIN(a.attendanceId) AS attendanceId, a.studentId, " +
                      "cs.className AS session_name, t.teacherName AS teacher_name, a.attendanceDate AS session_date, " +
                      "CONCAT(TIME_FORMAT(cs.startTime, '%h:%i %p'), ' - ', TIME_FORMAT(cs.endTime, '%h:%i %p')) AS time_range, " +
                      "MAX(a.attendanceStatus) AS status, MIN(a.joinTime) AS joinTime, MAX(a.leaveTime) AS leaveTime " +
                      "FROM attendance a " +
                      "LEFT JOIN classschedule cs ON a.scheduleId = cs.scheduleId " +
                      "LEFT JOIN teacher t ON a.teacherId = t.teacherId " +
                      "WHERE a.studentId = ? " +
                      "GROUP BY a.studentId, a.attendanceDate, cs.className, t.teacherName, cs.startTime, cs.endTime " +
                      "ORDER BY a.attendanceDate DESC";
        

        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getAttendanceByStudent: DB connection is null.");
                return records;
            }
            
            ps = conn.prepareStatement(query);
            ps.setString(1, studentId);
            rs = ps.executeQuery();
            
            int count = 0;
            while (rs.next()) {
                count++;
                StudentAttendance attendance = new StudentAttendance();
                attendance.setAttendanceId(rs.getString("attendanceId"));
                attendance.setStudentId(0);
                attendance.setSessionName(rs.getString("session_name"));
                attendance.setTeacherName(rs.getString("teacher_name"));
                
                attendance.setSessionDate(rs.getDate("session_date"));
                
                attendance.setTimeRange(rs.getString("time_range"));
                attendance.setStatus(rs.getString("status"));
                
                attendance.setJoinTime(rs.getTime("joinTime"));
                attendance.setLeaveTime(rs.getTime("leaveTime"));
                
                records.add(attendance);
            }
        } catch (SQLException e) {
            System.err.println("ERROR in getAttendanceByStudent: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return records;
    }
    
    public int getTotalSessions(String studentId) {
        String query = "SELECT COUNT(*) as total FROM attendance WHERE studentId = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getTotalSessions: DB connection is null.");
                return 0;
            }
            
            ps = conn.prepareStatement(query);
            ps.setString(1, studentId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return 0;
    }
    
    public int getPresentCount(String studentId) {
        String query = "SELECT COUNT(*) as total FROM attendance WHERE studentId = ? AND attendanceStatus = 'Present'";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getPresentCount: DB connection is null.");
                return 0;
            }
            
            ps = conn.prepareStatement(query);
            ps.setString(1, studentId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return 0;
    }
    
    public int getAbsentCount(String studentId) {
        String query = "SELECT COUNT(*) as total FROM attendance WHERE studentId = ? AND attendanceStatus = 'Absent'";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getAbsentCount: DB connection is null.");
                return 0;
            }
            
            ps = conn.prepareStatement(query);
            ps.setString(1, studentId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return 0;
    }
    
    public int getLateCount(String studentId) {
        String query = "SELECT COUNT(*) as total FROM attendance WHERE studentId = ? AND attendanceStatus = 'Late'";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getLateCount: DB connection is null.");
                return 0;
            }
            
            ps = conn.prepareStatement(query);
            ps.setString(1, studentId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return 0;
    }
    
    public Map<String, Integer> getAttendanceTrendByWeek(String studentId) {
        Map<String, Integer> trend = new LinkedHashMap<>();
        // Calculate weeks as: days 1-7 = Week 1, days 8-14 = Week 2, etc.
        String query = "SELECT " +
                      "CONCAT('Week ', CEIL(DAY(attendanceDate) / 7.0)) as week, " +
                      "COUNT(*) as count " +
                      "FROM attendance " +
                      "WHERE studentId = ? " +
                      "AND MONTH(attendanceDate) = MONTH(CURDATE()) " +
                      "AND YEAR(attendanceDate) = YEAR(CURDATE()) " +
                      "GROUP BY CEIL(DAY(attendanceDate) / 7.0) " +
                      "ORDER BY CEIL(DAY(attendanceDate) / 7.0)";
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getAttendanceTrendByWeek: DB connection is null.");
                return trend;
            }
            
            ps = conn.prepareStatement(query);
            ps.setString(1, studentId);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                trend.put(rs.getString("week"), rs.getInt("count"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return trend;
    }
    
    public Map<String, Integer> getAttendanceTrendDetails(String studentId) {
        Map<String, Integer> trendDetails = new LinkedHashMap<>();
        for (Map.Entry<String, Map<String, Integer>> week : getWeeklyAttendanceTrend(studentId).entrySet()) {
            for (Map.Entry<String, Integer> status : week.getValue().entrySet()) {
                trendDetails.put(week.getKey() + "_" + status.getKey(), status.getValue());
            }
        }
        return trendDetails;
    }

    /**
     * Weekly Present / Absent / Late counts for the current month (Week 1–4).
     */
    public Map<String, Map<String, Integer>> getWeeklyAttendanceTrend(String studentId) {
        Map<String, Map<String, Integer>> weeklyData = new LinkedHashMap<>();
        for (int w = 1; w <= 4; w++) {
            Map<String, Integer> counts = new HashMap<>();
            counts.put("Present", 0);
            counts.put("Absent", 0);
            counts.put("Late", 0);
            weeklyData.put("Week " + w, counts);
        }

        String query = "SELECT "
            + "LEAST(4, (DAY(attendanceDate) - 1) DIV 7 + 1) AS weekNum, "
            + "UPPER(TRIM(attendanceStatus)) AS statusKey, "
            + "COUNT(*) AS cnt "
            + "FROM attendance "
            + "WHERE studentId = ? "
            + "AND MONTH(attendanceDate) = MONTH(CURDATE()) "
            + "AND YEAR(attendanceDate) = YEAR(CURDATE()) "
            + "GROUP BY weekNum, statusKey";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            if (conn == null) {
                return weeklyData;
            }
            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int weekNum = rs.getInt("weekNum");
                    if (weekNum < 1 || weekNum > 4) {
                        continue;
                    }
                    String weekLabel = "Week " + weekNum;
                    String canonical = normalizeAttendanceStatus(rs.getString("statusKey"));
                    if (canonical == null) {
                        continue;
                    }
                    weeklyData.get(weekLabel).put(canonical, rs.getInt("cnt"));
                }
            }
        } catch (SQLException e) {
            System.err.println("getWeeklyAttendanceTrend: " + e.getMessage());
            e.printStackTrace();
        }
        return weeklyData;
    }

    private static String normalizeAttendanceStatus(String raw) {
        if (raw == null) {
            return null;
        }
        switch (raw.trim().toUpperCase()) {
            case "PRESENT": return "Present";
            case "ABSENT": return "Absent";
            case "LATE": return "Late";
            default: return null;
        }
    }

    /**
     * Get attendance records for the current month only
     * Resets attendance view at the beginning of each new month
     */
    public List<StudentAttendance> getAttendanceByStudentByMonth(String studentId) {
        List<StudentAttendance> records = new ArrayList<>();
        String query = "SELECT MIN(a.attendanceId) AS attendanceId, a.studentId, " +
                      "cs.className AS session_name, t.teacherName AS teacher_name, a.attendanceDate AS session_date, " +
                      "CONCAT(TIME_FORMAT(cs.startTime, '%h:%i %p'), ' - ', TIME_FORMAT(cs.endTime, '%h:%i %p')) AS time_range, " +
                      "MAX(a.attendanceStatus) AS status, MIN(a.joinTime) AS joinTime, MAX(a.leaveTime) AS leaveTime " +
                      "FROM attendance a " +
                      "LEFT JOIN classschedule cs ON a.scheduleId = cs.scheduleId " +
                      "LEFT JOIN teacher t ON a.teacherId = t.teacherId " +
                      "WHERE a.studentId = ? " +
                      "AND MONTH(a.attendanceDate) = MONTH(CURDATE()) " +
                      "AND YEAR(a.attendanceDate) = YEAR(CURDATE()) " +
                      "GROUP BY a.studentId, a.attendanceDate, cs.className, t.teacherName, cs.startTime, cs.endTime " +
                      "ORDER BY a.attendanceDate DESC";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getAttendanceByStudentByMonth: DB connection is null.");
                return records;
            }
            
            ps = conn.prepareStatement(query);
            ps.setString(1, studentId);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                StudentAttendance attendance = new StudentAttendance();
                attendance.setAttendanceId(rs.getString("attendanceId"));
                attendance.setStudentId(0);
                attendance.setSessionName(rs.getString("session_name"));
                attendance.setTeacherName(rs.getString("teacher_name"));
                
                attendance.setSessionDate(rs.getDate("session_date"));
                
                attendance.setTimeRange(rs.getString("time_range"));
                attendance.setStatus(rs.getString("status"));
                
                attendance.setJoinTime(rs.getTime("joinTime"));
                attendance.setLeaveTime(rs.getTime("leaveTime"));
                
                records.add(attendance);
            }
        } catch (SQLException e) {
            System.err.println("ERROR in getAttendanceByStudentByMonth: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return records;
    }

    public int getTotalSessionsByMonth(String studentId) {
        String query = "SELECT COUNT(*) as total FROM attendance " +
                      "WHERE studentId = ? " +
                      "AND MONTH(attendanceDate) = MONTH(CURDATE()) " +
                      "AND YEAR(attendanceDate) = YEAR(CURDATE())";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getTotalSessionsByMonth: DB connection is null.");
                return 0;
            }
            
            ps = conn.prepareStatement(query);
            ps.setString(1, studentId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return 0;
    }

    public int getPresentCountByMonth(String studentId) {
        String query = "SELECT COUNT(*) as total FROM attendance " +
                      "WHERE studentId = ? AND attendanceStatus = 'Present' " +
                      "AND MONTH(attendanceDate) = MONTH(CURDATE()) " +
                      "AND YEAR(attendanceDate) = YEAR(CURDATE())";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getPresentCountByMonth: DB connection is null.");
                return 0;
            }
            
            ps = conn.prepareStatement(query);
            ps.setString(1, studentId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return 0;
    }

    public int getAbsentCountByMonth(String studentId) {
        String query = "SELECT COUNT(*) as total FROM attendance " +
                      "WHERE studentId = ? AND attendanceStatus = 'Absent' " +
                      "AND MONTH(attendanceDate) = MONTH(CURDATE()) " +
                      "AND YEAR(attendanceDate) = YEAR(CURDATE())";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getAbsentCountByMonth: DB connection is null.");
                return 0;
            }
            
            ps = conn.prepareStatement(query);
            ps.setString(1, studentId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return 0;
    }

    public int getLateCountByMonth(String studentId) {
        String query = "SELECT COUNT(*) as total FROM attendance " +
                      "WHERE studentId = ? AND attendanceStatus = 'Late' " +
                      "AND MONTH(attendanceDate) = MONTH(CURDATE()) " +
                      "AND YEAR(attendanceDate) = YEAR(CURDATE())";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getLateCountByMonth: DB connection is null.");
                return 0;
            }
            
            ps = conn.prepareStatement(query);
            ps.setString(1, studentId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return 0;
    }
}

