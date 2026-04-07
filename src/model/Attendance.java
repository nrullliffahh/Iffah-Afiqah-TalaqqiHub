package model;

import java.util.Date;

public class Attendance {
    private int id;
    private String studentName;
    private String studentCode;
    private String className;
    private String sessionName;
    private String teacherName;
    private Date sessionDate;
    private String timeRange;
    private String status;
    private String joinTime;
    private String leaveTime;

    // Constructor
    public Attendance() {
    }

    public Attendance(int id, String studentName, String studentCode, String className,
                      String sessionName, String teacherName, Date sessionDate, String timeRange,
                      String status, String joinTime, String leaveTime) {
        this.id = id;
        this.studentName = studentName;
        this.studentCode = studentCode;
        this.className = className;
        this.sessionName = sessionName;
        this.teacherName = teacherName;
        this.sessionDate = sessionDate;
        this.timeRange = timeRange;
        this.status = status;
        this.joinTime = joinTime;
        this.leaveTime = leaveTime;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getStudentName() {
        return studentName;
    }

    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }

    public String getStudentCode() {
        return studentCode;
    }

    public void setStudentCode(String studentCode) {
        this.studentCode = studentCode;
    }

    public String getClassName() {
        return className;
    }

    public void setClassName(String className) {
        this.className = className;
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
