package model;

import java.io.Serializable;
import java.sql.Date;

public class StudentAttendance implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private String attendanceId;
    private int studentId;
    private String sessionName;
    private String teacherName;
    private Date sessionDate;
    private String timeRange;
    private String status;
    private String joinTime;
    private String leaveTime;
    
    // Default Constructor
    public StudentAttendance() {
    }
    
    // Full Constructor
    public StudentAttendance(String attendanceId, int studentId, String sessionName, String teacherName,
                            Date sessionDate, String timeRange, String status,
                            String joinTime, String leaveTime) {
        this.attendanceId = attendanceId;
        this.studentId = studentId;
        this.sessionName = sessionName;
        this.teacherName = teacherName;
        this.sessionDate = sessionDate;
        this.timeRange = timeRange;
        this.status = status;
        this.joinTime = joinTime;
        this.leaveTime = leaveTime;
    }
    
    // Getters and Setters
    public String getAttendanceId() {
        return attendanceId;
    }
    
    public void setAttendanceId(String attendanceId) {
        this.attendanceId = attendanceId;
    }
    
    public int getStudentId() {
        return studentId;
    }
    
    public void setStudentId(int studentId) {
        this.studentId = studentId;
    }
    
    public String getSessionName() {
        return sessionName;
    }
    
    public void setSessionName(String sessionName) {
        this.sessionName = sessionName;
    }
    
    public String getTeacherName() {
        return teacherName;
    }
    
    public void setTeacherName(String teacherName) {
        this.teacherName = teacherName;
    }
    
    public Date getSessionDate() {
        return sessionDate;
    }
    
    public void setSessionDate(Date sessionDate) {
        this.sessionDate = sessionDate;
    }
    
    public String getTimeRange() {
        return timeRange;
    }
    
    public void setTimeRange(String timeRange) {
        this.timeRange = timeRange;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getJoinTime() {
        return joinTime;
    }
    
    public void setJoinTime(String joinTime) {
        this.joinTime = joinTime;
    }
    
    public String getLeaveTime() {
        return leaveTime;
    }
    
    public void setLeaveTime(String leaveTime) {
        this.leaveTime = leaveTime;
    }
}
