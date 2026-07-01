package dao;

import model.Teacher;
import util.DBConnection;
import java.sql.*;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.UUID;

public class TeacherDAO {
    
    public boolean isEmailExists(String email) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("isEmailExists (TeacherDAO): DB connection is null.");
                return false;
            }
            String sql = "SELECT COUNT(*) FROM teacher WHERE teacherEmail = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
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
        
        return false;
    }
    
    private String getNextTeacherId() {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getNextTeacherId: DB connection is null. Returning default T001.");
                return "T001";
            }
            String sql = "SELECT teacherId FROM teacher WHERE teacherId LIKE 'T%' ORDER BY CAST(SUBSTRING(teacherId, 2) AS UNSIGNED) DESC LIMIT 1";
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                String lastId = rs.getString("teacherId");
                int number = Integer.parseInt(lastId.substring(1));
                return String.format("T%03d", number + 1);
            } else {
                return "T001";
            }
        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
            return "T001";
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    public boolean registerTeacher(Teacher teacher) {
        if (insertTeacher(teacher, true)) {
            return true;
        }
        return insertTeacher(teacher, false);
    }

    private boolean insertTeacher(Teacher teacher, boolean includeApprovalStatus) {
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("registerTeacher: DB connection is null.");
                return false;
            }

            String teacherId = getNextTeacherId();
            String sql = includeApprovalStatus
                    ? "INSERT INTO teacher (teacherId, teacherName, teacherEmail, teacherPassword, teacherPhoneNo, teacherDateofBirth, registrationDate, teacherSecQues, teacherSecPassword, qualifications, specialtyArea, certificationPath, approvalStatus, teacherStatus) VALUES (?, ?, ?, ?, ?, ?, CURDATE(), ?, ?, ?, ?, ?, 'Pending', 'Pending')"
                    : "INSERT INTO teacher (teacherId, teacherName, teacherEmail, teacherPassword, teacherPhoneNo, teacherDateofBirth, registrationDate, teacherSecQues, teacherSecPassword, qualifications, specialtyArea, certificationPath, teacherStatus) VALUES (?, ?, ?, ?, ?, ?, CURDATE(), ?, ?, ?, ?, ?, 'Pending')";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, teacherId);
            stmt.setString(2, teacher.getFullName());
            stmt.setString(3, teacher.getEmail());
            stmt.setString(4, teacher.getPassword());
            stmt.setString(5, teacher.getPhone());
            stmt.setDate(6, teacher.getDateOfBirth() != null ? Date.valueOf(teacher.getDateOfBirth()) : null);
            stmt.setString(7, teacher.getSecurityQuestion());
            stmt.setString(8, teacher.getSecurityAnswer());
            stmt.setString(9, teacher.getQualification());
            stmt.setString(10, teacher.getSpecialty());
            stmt.setString(11, teacher.getCertificationPath());

            int result = stmt.executeUpdate();
            if (result > 0) {
                teacher.setTeacherId(teacherId);
                teacher.setStatus("Pending");
            }
            return result > 0;
        } catch (SQLException e) {
            if (includeApprovalStatus) {
                System.err.println("registerTeacher with approvalStatus failed: " + e.getMessage());
                return false;
            }
            System.err.println("SQL Error in registerTeacher: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes());
            StringBuilder hexString = new StringBuilder();
            
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
            return password;
        }
    }
    
    public Teacher authenticateTeacher(String email, String password) {
        Teacher teacher = lookupTeacherByCredentials(email, password);
        if (teacher == null && password != null) {
            teacher = lookupTeacherByCredentials(email, hashPassword(password));
        }
        return teacher;
    }

    private Teacher lookupTeacherByCredentials(String email, String password) {
        Teacher teacher = null;
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("authenticateTeacher: DB connection is null.");
                return null;
            }
            String sql = "SELECT teacherId, teacherName, teacherEmail FROM teacher WHERE teacherEmail = ? AND teacherPassword = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            stmt.setString(2, password);

            rs = stmt.executeQuery();

            if (rs.next()) {
                teacher = new Teacher();
                teacher.setTeacherId(rs.getString("teacherId"));
                teacher.setFullName(rs.getString("teacherName"));
                teacher.setEmail(rs.getString("teacherEmail"));
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

        return teacher;
    }
    
    public boolean isTeacherEmailExists(String email) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("isTeacherEmailExists: DB connection is null.");
                return false;
            }
            String sql = "SELECT COUNT(*) FROM teacher WHERE teacherEmail = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
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
        
        return false;
    }
    
    public String getSecurityQuestionByEmail(String email) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getSecurityQuestionByEmail (TeacherDAO): DB connection is null.");
                return null;
            }
            String sql = "SELECT teacherSecQues FROM teacher WHERE teacherEmail = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getString("teacherSecQues");
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
        
        return null;
    }
    
    public boolean verifySecurityAnswer(String email, String answer) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("verifySecurityAnswer (TeacherDAO): DB connection is null.");
                return false;
            }
            String sql = "SELECT teacherSecPassword FROM teacher WHERE teacherEmail = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                String storedAnswer = rs.getString("teacherSecPassword");
                return storedAnswer.equalsIgnoreCase(answer);
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
        
        return false;
    }
    
    public boolean updateTeacherPassword(String email, String newPassword) {
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("updateTeacherPassword: DB connection is null.");
                return false;
            }
            String sql = "UPDATE teacher SET teacherPassword = ? WHERE teacherEmail = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, newPassword);
            stmt.setString(2, email);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Get teacher details by teacher ID for dashboard
     */
    public Teacher getTeacherById(String teacherId) {
        if (teacherId == null || teacherId.trim().isEmpty()) {
            return null;
        }
        Teacher teacher = fetchTeacherById(teacherId, true, true);
        if (teacher == null) {
            teacher = fetchTeacherById(teacherId, false, true);
        }
        if (teacher == null) {
            teacher = fetchTeacherById(teacherId, false, false);
        }
        return teacher;
    }

    private Teacher fetchTeacherById(String teacherId, boolean useApprovalStatus, boolean includeCertificationPath) {
        Teacher teacher = null;
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getTeacherById: DB connection is null.");
                return null;
            }

            String statusColumn = useApprovalStatus ? "approvalStatus" : "teacherStatus";
            StringBuilder sql = new StringBuilder(
                "SELECT teacherId, teacherName, teacherEmail, registrationDate, specialtyArea, "
                    + "teacherPhoneNo, qualifications, "
            );
            sql.append(statusColumn);
            if (includeCertificationPath) {
                sql.append(", certificationPath");
            }
            sql.append(" FROM teacher WHERE teacherId = ?");

            stmt = conn.prepareStatement(sql.toString());
            stmt.setString(1, teacherId);
            rs = stmt.executeQuery();

            if (rs.next()) {
                teacher = new Teacher();
                teacher.setTeacherId(rs.getString("teacherId"));
                teacher.setFullName(rs.getString("teacherName"));
                teacher.setEmail(rs.getString("teacherEmail"));
                teacher.setSpecialty(rs.getString("specialtyArea"));
                teacher.setPhone(rs.getString("teacherPhoneNo"));
                teacher.setQualification(rs.getString("qualifications"));
                if (useApprovalStatus) {
                    teacher.setStatus(normalizeApprovalStatus(rs.getString("approvalStatus")));
                } else {
                    teacher.setStatus(mapTeacherStatusToApproval(rs.getString("teacherStatus")));
                }
                if (includeCertificationPath) {
                    teacher.setCertificationPath(rs.getString("certificationPath"));
                }

                java.sql.Date sqlDate = rs.getDate("registrationDate");
                if (sqlDate != null) {
                    teacher.setDateOfBirth(sqlDate.toLocalDate());
                }
            }
        } catch (SQLException e) {
            if (useApprovalStatus || includeCertificationPath) {
                System.out.println("fetchTeacherById fallback (" + statusLabel(useApprovalStatus, includeCertificationPath)
                    + "): " + e.getMessage());
                return null;
            }
            System.err.println("fetchTeacherById failed: " + e.getMessage());
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                System.err.println("fetchTeacherById cleanup failed: " + e.getMessage());
            }
        }

        return teacher;
    }

    private static String statusLabel(boolean useApprovalStatus, boolean includeCertificationPath) {
        return (useApprovalStatus ? "approvalStatus" : "teacherStatus")
            + (includeCertificationPath ? "+certificationPath" : "");
    }

    /**
     * Get count of classes scheduled for this week for a specific teacher
     */
    public int getClassesThisWeekCount(String teacherId) {
        int count = 0;
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getClassesThisWeekCount: DB connection is null. Returning 0.");
                return 0;
            }
            String sql = "SELECT COUNT(DISTINCT cs.scheduleId) AS count " +
                        "FROM classschedule cs " +
                        "LEFT JOIN classbooking cb ON cb.scheduleId = cs.scheduleId " +
                        "    AND cb.bookingStatus IN " + util.BookingStatus.SQL_ACTIVE + " " +
                        "WHERE cs.teacherId = ? " +
                        "AND YEARWEEK(cs.scheduleDate, 1) = YEARWEEK(CURDATE(), 1) " +
                        "AND (cs.classStatus IS NULL OR cs.classStatus != 'Cancelled') " +
                        "AND (cb.bookingId IS NOT NULL OR cs.studentId IS NOT NULL)";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, teacherId);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                count = rs.getInt("count");
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
        
        return count;
    }
    
    /**
     * Get total number of unique students taught by this teacher
     */
    public int getTotalStudentsTaught(String teacherId) {
        int count = 0;
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getTotalStudentsTaught: DB connection is null. Returning 0.");
                return 0;
            }
            String sql = "SELECT COUNT(DISTINCT studentId) AS count FROM ( " +
                        "SELECT cb.studentId AS studentId FROM classbooking cb " +
                        "INNER JOIN classschedule cs ON cb.scheduleId = cs.scheduleId " +
                        "WHERE cs.teacherId = ? AND cb.studentId IS NOT NULL " +
                        "AND UPPER(TRIM(COALESCE(cb.bookingStatus, ''))) NOT IN ('CANCELLED', 'REJECTED') " +
                        "UNION " +
                        "SELECT cs.studentId AS studentId FROM classschedule cs " +
                        "WHERE cs.teacherId = ? AND cs.studentId IS NOT NULL " +
                        ") registered_students";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, teacherId);
            stmt.setString(2, teacherId);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                count = rs.getInt("count");
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
        
        return count;
    }
    
    /**
     * Average student-to-teacher feedback rating (1-5 scale).
     */
    public double getAverageRating(String teacherId) {
        double avgRating = 0.0;
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getAverageRating: DB connection is null. Returning 0.0.");
                return 0.0;
            }
            String sql = "SELECT AVG(sf.rating) AS avgRating " +
                        "FROM studentfeedback sf " +
                        "WHERE sf.teacherId = ? AND sf.rating IS NOT NULL AND sf.rating BETWEEN 1 AND 5";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, teacherId);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                avgRating = rs.getDouble("avgRating");
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
        
        return avgRating;
    }
    
    public int getTotalActiveTeachers() {
        int count = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getTotalActiveTeachers: DB connection is null. Returning 0.");
                return 0;
            }
            String sql = "SELECT COUNT(*) as total FROM teacher WHERE teacherStatus = 'Active'";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                count = rs.getInt("total");
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting total active teachers: " + e.getMessage());
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
     * Get all teachers for admin listing
     */
    public java.util.List<model.Teacher> getAllTeachers() {
        java.util.List<model.Teacher> teachers = queryAllTeachers(true);
        if (teachers != null) {
            return teachers;
        }
        teachers = queryAllTeachers(false);
        return teachers != null ? teachers : new java.util.ArrayList<>();
    }

    private java.util.List<model.Teacher> queryAllTeachers(boolean includeApprovalStatus) {
        java.util.List<model.Teacher> list = new java.util.ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getAllTeachers: DB connection is null.");
                return list;
            }
            String sql = includeApprovalStatus
                    ? "SELECT teacherId, teacherName, teacherEmail, teacherPhoneNo, specialtyArea, qualifications, registrationDate, approvalStatus FROM teacher ORDER BY registrationDate DESC"
                    : "SELECT teacherId, teacherName, teacherEmail, teacherPhoneNo, specialtyArea, qualifications, registrationDate, teacherStatus FROM teacher ORDER BY registrationDate DESC";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                model.Teacher t = mapTeacherRow(rs, includeApprovalStatus);
                list.add(t);
            }
            return list;
        } catch (SQLException e) {
            if (includeApprovalStatus) {
                System.err.println("getAllTeachers with approvalStatus failed: " + e.getMessage());
                return null;
            }
            e.printStackTrace();
            return list;
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
            try { if (pstmt != null) pstmt.close(); } catch (SQLException ignored) {}
            try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
        }
    }

    private model.Teacher mapTeacherRow(ResultSet rs, boolean includeApprovalStatus) throws SQLException {
        model.Teacher t = new model.Teacher();
        t.setTeacherId(rs.getString("teacherId"));
        t.setFullName(rs.getString("teacherName"));
        t.setEmail(rs.getString("teacherEmail"));
        t.setPhone(rs.getString("teacherPhoneNo"));
        t.setSpecialty(rs.getString("specialtyArea"));
        t.setQualification(rs.getString("qualifications"));
        java.sql.Date sqlDate = rs.getDate("registrationDate");
        if (sqlDate != null) {
            t.setDateOfBirth(sqlDate.toLocalDate());
        }
        if (includeApprovalStatus) {
            t.setStatus(normalizeApprovalStatus(rs.getString("approvalStatus")));
        } else {
            t.setStatus(mapTeacherStatusToApproval(rs.getString("teacherStatus")));
        }
        return t;
    }

    private String normalizeApprovalStatus(String status) {
        if (status == null || status.trim().isEmpty()) {
            return "Pending";
        }
        return status.trim();
    }

    private String mapTeacherStatusToApproval(String teacherStatus) {
        if (teacherStatus == null || teacherStatus.trim().isEmpty()) {
            return "Pending";
        }
        switch (teacherStatus.trim().toLowerCase()) {
            case "active":
                return "Approved";
            case "inactive":
                return "Rejected";
            case "pending":
                return "Pending";
            default:
                return "Pending";
        }
    }

    private String mapApprovalToTeacherStatus(String approvalStatus) {
        if (approvalStatus == null) {
            return "Pending";
        }
        switch (approvalStatus.trim().toLowerCase()) {
            case "approved":
                return "Active";
            case "rejected":
                return "Inactive";
            case "pending":
            default:
                return "Pending";
        }
    }

    /**
     * Update teacher status (Approved / Pending / Rejected)
     */
    public boolean updateTeacherStatus(String teacherId, String status) {
        if (updateApprovalStatusColumn(teacherId, status)) {
            updateTeacherStatusColumn(teacherId, status);
            return true;
        }
        return updateTeacherStatusColumn(teacherId, status);
    }

    private boolean updateApprovalStatusColumn(String teacherId, String status) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("updateTeacherStatus: DB connection is null.");
                return false;
            }
            String sql = "UPDATE teacher SET approvalStatus = ? WHERE teacherId = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, normalizeApprovalStatus(status));
            pstmt.setString(2, teacherId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("updateApprovalStatusColumn failed: " + e.getMessage());
            return false;
        } finally {
            try { if (pstmt != null) pstmt.close(); } catch (SQLException ignored) {}
            try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
        }
    }

    private boolean updateTeacherStatusColumn(String teacherId, String status) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                return false;
            }
            String sql = "UPDATE teacher SET teacherStatus = ? WHERE teacherId = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, mapApprovalToTeacherStatus(status));
            pstmt.setString(2, teacherId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (pstmt != null) pstmt.close(); } catch (SQLException ignored) {}
            try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
        }
    }

    public boolean updateCertificationPath(String teacherId, String certPath) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("updateCertificationPath: DB connection is null.");
                return false;
            }
            String sql = "UPDATE teacher SET certificationPath = ? WHERE teacherId = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, certPath);
            pstmt.setString(2, teacherId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (pstmt != null) pstmt.close(); } catch (SQLException ignored) {}
            try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
        }
    }
}
