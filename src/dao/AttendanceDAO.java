package dao;

import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

public class AttendanceDAO {
    
    public double getAttendanceRate(String studentId) {
        double rate = 0.0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getAttendanceRate: DB connection is null. Returning 0.0.");
                return 0.0;
            }
            String sql = "SELECT " +
                        "(SELECT COUNT(*) FROM attendance WHERE studentId = ? AND attendanceStatus = 'Present') as present, " +
                        "(SELECT COUNT(*) FROM attendance WHERE studentId = ?) as total";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, studentId);
            pstmt.setString(2, studentId);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                int present = rs.getInt("present");
                int total = rs.getInt("total");
                if (total > 0) {
                    rate = ((double) present / total) * 100;
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error calculating attendance rate: " + e.getMessage());
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
        
        return rate;
    }
    
    public Map<String, Object> getOverallAttendanceStats() {
        Map<String, Object> stats = new HashMap<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getOverallAttendanceStats: DB connection is null. Returning empty stats.");
                return stats;
            }
            String sql = "SELECT " +
                        "SUM(CASE WHEN attendanceStatus = 'Present' THEN 1 ELSE 0 END) as present, " +
                        "SUM(CASE WHEN attendanceStatus = 'Absent' THEN 1 ELSE 0 END) as absent, " +
                        "COUNT(*) as total " +
                        "FROM attendance";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                int present = rs.getInt("present");
                int absent = rs.getInt("absent");
                int total = rs.getInt("total");
                double rate = total > 0 ? ((double) present / total) * 100 : 0.0;
                
                stats.put("present", present);
                stats.put("absent", absent);
                stats.put("total", total);
                stats.put("rate", rate);
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting attendance stats: " + e.getMessage());
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
        
        return stats;
    }
}
