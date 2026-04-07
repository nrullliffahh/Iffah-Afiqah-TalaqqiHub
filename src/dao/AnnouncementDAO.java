package dao;

import model.Announcement;
import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AnnouncementDAO {
    
    public List<Announcement> getLatestAnnouncements(int limit) {
        List<Announcement> announcements = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getLatestAnnouncements: DB connection is null. Returning empty list.");
                return announcements;
            }
            // aiassistance table uses 'aid' as primary key and columns aiQuestion/aiResponse
            String sql = "SELECT * FROM aiassistance ORDER BY aid DESC LIMIT ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, limit);
            
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Announcement announcement = new Announcement();
                announcement.setAnnouncementId(rs.getString("aid"));
                // Map aiQuestion -> title, aiResponse -> description
                announcement.setTitle(rs.getString("aiQuestion"));
                announcement.setDescription(rs.getString("aiResponse"));
                announcement.setDate("");
                announcements.add(announcement);
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting announcements: " + e.getMessage());
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
        
        return announcements;
    }
    
    public int getAnnouncementCount() {
        int count = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getAnnouncementCount: DB connection is null. Returning 0.");
                return 0;
            }
            String sql = "SELECT COUNT(*) as total FROM aiassistance";
            pstmt = conn.prepareStatement(sql);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                count = rs.getInt("total");
            }
            
        } catch (SQLException e) {
            System.err.println("Error counting announcements: " + e.getMessage());
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
    
    public List<Announcement> getRecentAnnouncements(int limit) {
        List<Announcement> announcements = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getRecentAnnouncements: DB connection is null. Returning empty list.");
                return announcements;
            }
            String sql = "SELECT * FROM aiassistance ORDER BY aid DESC LIMIT ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, limit);
            
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Announcement announcement = new Announcement();
                announcement.setAnnouncementId(rs.getString("aid"));
                announcement.setTitle(rs.getString("aiQuestion"));
                announcement.setDescription(rs.getString("aiResponse"));
                announcement.setDate("");
                announcement.setAuthor("Talaqqi Admin");
                announcement.setTargetAudience("All Students & Teachers");
                announcements.add(announcement);
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting announcements: " + e.getMessage());
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
        
        return announcements;
    }
}
