package model;

public class Session {
    private String sessionId;
    private String studentId;
    private String teacherId;
    private String teacherName;
    private String sessionDate;
    private String sessionTime;
    private String sessionType;
    private String status;
    private String location;
    
    public Session() {
    }
    
    public String getSessionId() {
        return sessionId;
    }
    
    public void setSessionId(String sessionId) {
        this.sessionId = sessionId;
    }
    
    public String getStudentId() {
        return studentId;
    }
    
    public void setStudentId(String studentId) {
        this.studentId = studentId;
    }
    
    public String getTeacherId() {
        return teacherId;
    }
    
    public void setTeacherId(String teacherId) {
        this.teacherId = teacherId;
    }
    
    public String getTeacherName() {
        return teacherName;
    }
    
    public void setTeacherName(String teacherName) {
        this.teacherName = teacherName;
    }
    
    public String getSessionDate() {
        return sessionDate;
    }
    
    public void setSessionDate(String sessionDate) {
        this.sessionDate = sessionDate;
    }
    
    public String getSessionTime() {
        return sessionTime;
    }
    
    public void setSessionTime(String sessionTime) {
        this.sessionTime = sessionTime;
    }
    
    public String getSessionType() {
        return sessionType;
    }
    
    public void setSessionType(String sessionType) {
        this.sessionType = sessionType;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getLocation() {
        return location;
    }
    
    public void setLocation(String location) {
        this.location = location;
    }
}
