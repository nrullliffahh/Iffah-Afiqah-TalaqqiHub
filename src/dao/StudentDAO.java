package dao;

import model.Student;
import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class StudentDAO {
    
    public Student authenticateStudent(String email, String password) {
        Student student = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("authenticateStudent: DB connection is null.");
                return null;
            }
            String sql = "SELECT * FROM student WHERE studentEmail = ? AND studentPassword = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, email);
            pstmt.setString(2, password);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                student = new Student();
                student.setStudentId(rs.getString("studentId"));
                student.setEmail(rs.getString("studentEmail"));
                student.setPassword(rs.getString("studentPassword"));
                student.setName(rs.getString("studentName"));
                student.setStatus(rs.getString("studentStatus"));
            }
            
        } catch (SQLException e) {
            System.err.println("Error authenticating student: " + e.getMessage());
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
        
        return student;
    }

    public boolean registerStudent(Student student) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            
            if (conn == null) {
                System.err.println("ERROR: Database connection is null!");
                return false;
            }
            
            System.out.println("DEBUG: Starting student registration for email: " + student.getEmail());
            
            // Generate next student ID
            String getMaxIdSql = "SELECT MAX(CAST(SUBSTRING(studentId, 2) AS UNSIGNED)) as maxId FROM student";
            pstmt = conn.prepareStatement(getMaxIdSql);
            rs = pstmt.executeQuery();
            
            int nextIdNumber = 1;
            if (rs.next() && rs.getObject("maxId") != null) {
                nextIdNumber = rs.getInt("maxId") + 1;
            }
            String newStudentId = String.format("S%03d", nextIdNumber);
            System.out.println("DEBUG: Generated new student ID: " + newStudentId);
            
            // Close first statement
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            
            // Insert new student (use `packageId` column expected by schema)
            String sql = "INSERT INTO student (studentId, studentName, studentEmail, studentPhoneNo, studentDateofBirth, studentPassword, studentSecQues, studentSecPassword, packageId, registrationDate, studentStatus) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, CURDATE(), 'Active')";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, newStudentId);
            pstmt.setString(2, student.getFullName());
            pstmt.setString(3, student.getEmail());
            pstmt.setString(4, student.getPhoneNumber());
            pstmt.setString(5, student.getDateOfBirth());
            pstmt.setString(6, student.getPassword());
            pstmt.setString(7, student.getSecurityQuestion());
            pstmt.setString(8, student.getSecurityAnswer());
            // If packageId is not supplied during registration, default to a starter package (P001)
            String pkgId = student.getPackageId();
            if (pkgId == null || pkgId.trim().isEmpty()) {
                pkgId = "P001"; // default package
            }
            pstmt.setString(9, pkgId);
            
            System.out.println("DEBUG: Executing INSERT with values - ID: " + newStudentId + ", Name: " + student.getFullName() + ", Email: " + student.getEmail() + ", Package: " + pkgId);
            
            int rowsAffected = pstmt.executeUpdate();
            System.out.println("DEBUG: Rows affected: " + rowsAffected);
            
            if (rowsAffected > 0) {
                System.out.println("SUCCESS: Student registered successfully with ID: " + newStudentId);
            }
            
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("Error registering student: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    public Student getSecurityQuestionByEmail(String email) {
        Student student = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getSecurityQuestionByEmail: DB connection is null.");
                return null;
            }
            String sql = "SELECT studentId, studentEmail, studentSecQues FROM student WHERE studentEmail = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, email);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                student = new Student();
                student.setStudentId(rs.getString("studentId"));
                student.setEmail(rs.getString("studentEmail"));
                student.setSecurityQuestion(rs.getString("studentSecQues"));
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting security question: " + e.getMessage());
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
        
        return student;
    }
    
    public boolean verifySecurityAnswer(String studentId, String answer) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("verifySecurityAnswer: DB connection is null.");
                return false;
            }
            String sql = "SELECT studentSecPassword FROM student WHERE studentId = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, studentId);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                String storedAnswer = rs.getString("studentSecPassword");
                return answer != null && answer.equals(storedAnswer);
            }
            
        } catch (SQLException e) {
            System.err.println("Error verifying security answer: " + e.getMessage());
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
        
        return false;
    }
    
    public boolean updateStudentPassword(String studentId, String newPassword) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("updateStudentPassword: DB connection is null.");
                return false;
            }
            String sql = "UPDATE student SET studentPassword = ? WHERE studentId = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, newPassword);
            pstmt.setString(2, studentId);
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("Error updating password: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    public boolean updateStudentDetails(String studentId, String fullName, String phoneNumber, String dateOfBirth) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("updateStudentDetails: DB connection is null.");
                return false;
            }
            String sql = "UPDATE student SET studentName = ?, studentPhoneNo = ?, studentDateofBirth = ? WHERE studentId = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, fullName);
            pstmt.setString(2, phoneNumber);
            pstmt.setString(3, dateOfBirth);
            pstmt.setString(4, studentId);
            int rows = pstmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("Error updating student details: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) { e.printStackTrace(); }
        }
    }
    
    public int getTotalActiveStudents() {
        int count = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getTotalActiveStudents: DB connection is null. Returning 0.");
                return 0;
            }
            String sql = "SELECT COUNT(*) as total FROM student WHERE studentStatus = 'Active'";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                count = rs.getInt("total");
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting total active students: " + e.getMessage());
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

    public List<Student> getAllStudents() {
        List<Student> students = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getAllStudents: DB connection is null. Returning empty list.");
                return students;
            }

            String sql = "SELECT * FROM student ORDER BY registrationDate DESC";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Student student = new Student();
                student.setStudentId(rs.getString("studentId"));
                student.setStudentName(rs.getString("studentName"));
                student.setStudentEmail(rs.getString("studentEmail"));
                student.setPhoneNumber(rs.getString("studentPhoneNo"));
                student.setDateOfBirth(rs.getString("studentDateofBirth"));
                student.setRegistrationDate(rs.getString("registrationDate"));
                student.setStudentStatus(rs.getString("studentStatus"));
                // try both possible column names for package id (schema may use packageId or studentPackageId)
                try {
                    String pkg = rs.getString("studentPackageId");
                    if (pkg == null) pkg = rs.getString("packageId");
                    if (pkg != null) student.setPackageId(pkg);
                } catch (Exception ignore) {
                    // column not present; ignore
                }
                students.add(student);
            }

        } catch (SQLException e) {
            System.err.println("Error fetching students: " + e.getMessage());
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

        return students;
    }

    public Student getStudentById(String studentId) {
        Student student = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getStudentById: DB connection is null.");
                return null;
            }

            String sql = "SELECT * FROM student WHERE studentId = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, studentId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                student = new Student();
                student.setStudentId(rs.getString("studentId"));
                student.setStudentName(rs.getString("studentName"));
                student.setStudentEmail(rs.getString("studentEmail"));
                student.setPhoneNumber(rs.getString("studentPhoneNo"));
                student.setDateOfBirth(rs.getString("studentDateofBirth"));
                student.setRegistrationDate(rs.getString("registrationDate"));
                student.setStudentStatus(rs.getString("studentStatus"));
                student.setPassword(rs.getString("studentPassword"));
                // try both possible column names for package id
                try {
                    String pkgId = null;
                    try { pkgId = rs.getString("studentPackageId"); } catch (Exception ignore) {}
                    if (pkgId == null) {
                        try { pkgId = rs.getString("packageId"); } catch (Exception ignore) {}
                    }
                    if (pkgId != null) student.setPackageId(pkgId);
                } catch (Exception ignore) {
                    // ignore any errors reading optional column
                }
            }

        } catch (SQLException e) {
            System.err.println("Error fetching student by id: " + e.getMessage());
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

        return student;
    }

    public Student getStudentByEmail(String email) {
        Student student = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("getStudentByEmail: DB connection is null.");
                return null;
            }

            String sql = "SELECT * FROM student WHERE studentEmail = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, email);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                student = new Student();
                student.setStudentId(rs.getString("studentId"));
                student.setStudentName(rs.getString("studentName"));
                student.setStudentEmail(rs.getString("studentEmail"));
                student.setPhoneNumber(rs.getString("studentPhoneNo"));
                student.setDateOfBirth(rs.getString("studentDateofBirth"));
                student.setRegistrationDate(rs.getString("registrationDate"));
                student.setStudentStatus(rs.getString("studentStatus"));
                student.setPassword(rs.getString("studentPassword"));
                try { student.setPackageId(rs.getString("packageId")); } catch (Exception ignore) {}
            }

        } catch (SQLException e) {
            System.err.println("Error fetching student by email: " + e.getMessage());
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

        return student;
    }

    public boolean updateStudentPackage(String studentId, String packageId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("updateStudentPackage: DB connection is null.");
                return false;
            }
            String sql = "UPDATE student SET packageId = ? WHERE studentId = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, packageId);
            pstmt.setString(2, studentId);
            int rows = pstmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("Error updating student package: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) { e.printStackTrace(); }
        }
    }
}
