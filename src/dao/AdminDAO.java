package dao;

import model.Admin;
import util.DBConnection;
import util.PasswordUtil;
import java.sql.*;

public class AdminDAO {
    
    /**
     * Authenticates an admin user by email and password
     * 
     * @param email Admin email address
     * @param password Admin password (plain text)
     * @return Admin object if authentication successful, null otherwise
     */
    public Admin loginAdmin(String email, String password) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        Admin admin = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("loginAdmin: DB connection is null.");
                return null;
            }

            String sql = "SELECT managerId, managerEmail, managerPassword, managerName " +
                        "FROM manager " +
                        "WHERE managerEmail = ?";

            stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                String dbPassword = rs.getString("managerPassword");
                
                if (password.equals(dbPassword)) {
                    admin = new Admin();
                    admin.setAdminId(rs.getString("managerId"));
                    admin.setAdminEmail(rs.getString("managerEmail"));
                    admin.setAdminName(rs.getString("managerName"));
                    admin.setAdminStatus("active");
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in loginAdmin: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, stmt, conn);
        }
        
        return admin;
    }
    
    /**
     * Checks if an email already exists in the admin table
     * 
     * @param email Email to check
     * @return true if email exists, false otherwise
     */
    public boolean isEmailExists(String email) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("isEmailExists (AdminDAO): DB connection is null.");
                return false;
            }
            String sql = "SELECT COUNT(*) FROM manager WHERE managerEmail = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("Error checking email existence: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, stmt, conn);
        }
        
        return false;
    }
    
    /**
     * Retrieves admin details by ID
     * 
     * @param adminId Admin ID
     * @return Admin object if found, null otherwise
     */
    public Admin getAdminById(String adminId) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        Admin admin = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getAdminById: DB connection is null.");
                return null;
            }
            String sql = "SELECT managerId, managerEmail, managerName " +
                        "FROM manager WHERE managerId = ?";
            
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, adminId);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                admin = new Admin();
                admin.setAdminId(rs.getString("managerId"));
                admin.setAdminEmail(rs.getString("managerEmail"));
                admin.setAdminName(rs.getString("managerName"));
                admin.setAdminStatus("active");
            }
        } catch (SQLException e) {
            System.err.println("Error retrieving admin: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, stmt, conn);
        }
        
        return admin;
    }
    
    /**
     * Gets admin by email
     */
    public Admin getAdminByEmail(String email) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        Admin admin = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getAdminByEmail: DB connection is null.");
                return null;
            }
            String sql = "SELECT managerId, managerEmail, managerName " +
                        "FROM manager WHERE managerEmail = ?";
            
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                admin = new Admin();
                admin.setAdminId(rs.getString("managerId"));
                admin.setAdminEmail(rs.getString("managerEmail"));
                admin.setAdminName(rs.getString("managerName"));
                admin.setAdminStatus("active");
            }
        } catch (SQLException e) {
            System.err.println("Error retrieving admin by email: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, stmt, conn);
        }
        
        return admin;
    }
    
    /**
     * Updates password by email
     */
    public boolean updatePasswordByEmail(String email, String newPassword) {
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("updatePasswordByEmail: DB connection is null.");
                return false;
            }
            String sql = "UPDATE manager SET managerPassword = ? WHERE managerEmail = ?";
            
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, newPassword);
            stmt.setString(2, email);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error updating password: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(null, stmt, conn);
        }
        
        return false;
    }
    
    /**
     * Updates admin password
     * 
     * @param adminId Admin ID
     * @param newPassword New password (will be hashed)
     * @return true if update successful, false otherwise
     */
    public boolean updatePassword(String adminId, String newPassword) {
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("updatePassword: DB connection is null.");
                return false;
            }
            String sql = "UPDATE manager SET managerPassword = ? WHERE managerId = ?";
            
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, newPassword);
            stmt.setString(2, adminId);
            
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error updating password: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(null, stmt, conn);
        }
        
        return false;
    }
    
    /**
     * Gets security question by email
     */
    public String getSecurityQuestionByEmail(String email) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getSecurityQuestionByEmail (AdminDAO): DB connection is null.");
                return null;
            }
            String sql = "SELECT securityQuestion FROM manager WHERE managerEmail = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getString("securityQuestion");
            }
        } catch (SQLException e) {
            System.err.println("Error getting security question: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, stmt, conn);
        }
        
        return null;
    }
    
    /**
     * Verifies security answer
     */
    public boolean verifySecurityAnswer(String email, String answer) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("verifySecurityAnswer (AdminDAO): DB connection is null.");
                return false;
            }
            String sql = "SELECT securityAnswer FROM manager WHERE managerEmail = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                String storedAnswer = rs.getString("securityAnswer");
                return storedAnswer.equalsIgnoreCase(answer);
            }
        } catch (SQLException e) {
            System.err.println("Error verifying security answer: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, stmt, conn);
        }
        
        return false;
    }
    
    /**
     * Closes database resources
     */
    private void closeResources(ResultSet rs, PreparedStatement stmt, Connection conn) {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            System.err.println("Error closing resources: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
