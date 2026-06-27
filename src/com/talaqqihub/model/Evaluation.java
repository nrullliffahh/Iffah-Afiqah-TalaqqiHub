package com.talaqqihub.model;

/**
 * Evaluation Model Class
 * Represents a student evaluation record in the Teacher Evaluation Module
 */
public class Evaluation {
    private int evaluationId;
    private String sessionId;
    private String scheduleId;
    private String studentId;
    private String studentIdNum;
    private String studentName;
    private String className;
    private String surah;
    private String ayahRange;
    private int surahNumber;
    private int ayahNumber;
    private String teacherName;
    private String sessionDate;
    private String startTime;
    private String endTime;
    private float tajweedScore;
    private float fluencyScore;
    private float accuracyScore;
    private float overallScore;
    private int rating;
    private String comments;
    private String suggestions;
    private String status;
    private String teacherId;
    private int teacherIdNum;
    private String areasForImprovement;
    private String performanceTag;
    private String nextTarget;
    private String teacherComments;
    private String createdAt;
    private String updatedAt;

    // Default Constructor
    public Evaluation() {}

    // Constructor with all fields
    public Evaluation(int evaluationId, int studentId, String studentName, String className,
                      String surah, String ayahRange, String sessionDate, String startTime,
                      String endTime, float tajweedScore, float fluencyScore, float accuracyScore,
                      float overallScore, int rating, String comments, String suggestions,
                      String status, int teacherId) {
        this.evaluationId = evaluationId;
        this.studentIdNum = String.valueOf(studentId);
        this.studentName = studentName;
        this.className = className;
        this.surah = surah;
        this.ayahRange = ayahRange;
        this.sessionDate = sessionDate;
        this.startTime = startTime;
        this.endTime = endTime;
        this.tajweedScore = tajweedScore;
        this.fluencyScore = fluencyScore;
        this.accuracyScore = accuracyScore;
        this.overallScore = overallScore;
        this.rating = rating;
        this.comments = comments;
        this.suggestions = suggestions;
        this.status = status;
        this.teacherIdNum = teacherId;
    }

    // Getters and Setters
    public int getEvaluationId() {
        return evaluationId;
    }

    public void setEvaluationId(int evaluationId) {
        this.evaluationId = evaluationId;
    }

    public String getSessionId() {
        return sessionId;
    }

    public void setSessionId(String sessionId) {
        this.sessionId = sessionId;
    }

    public String getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(String scheduleId) {
        this.scheduleId = scheduleId;
    }

    public String getStudentId() {
        return studentId;
    }

    public void setStudentId(String studentId) {
        this.studentId = studentId;
    }

    public void setStudentId(int studentId) {
        this.studentIdNum = String.valueOf(studentId);
    }

    public int getStudentIdNum() {
        return Integer.parseInt(studentIdNum != null && !studentIdNum.isEmpty() ? studentIdNum : "0");
    }

    public void setStudentIdNum(int studentId) {
        this.studentIdNum = String.valueOf(studentId);
    }

    public String getStudentName() {
        return studentName;
    }

    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }

    public String getClassName() {
        return className;
    }

    public void setClassName(String className) {
        this.className = className;
    }

    public String getTeacherName() {
        return teacherName;
    }

    public void setTeacherName(String teacherName) {
        this.teacherName = teacherName;
    }

    public String getSurah() {
        return surah;
    }

    public void setSurah(String surah) {
        this.surah = surah;
    }

    public String getAyahRange() {
        return ayahRange;
    }

    public void setAyahRange(String ayahRange) {
        this.ayahRange = ayahRange;
    }

    public int getSurahNumber() {
        return surahNumber;
    }

    public void setSurahNumber(int surahNumber) {
        this.surahNumber = surahNumber;
    }

    public int getAyahNumber() {
        return ayahNumber;
    }

    public void setAyahNumber(int ayahNumber) {
        this.ayahNumber = ayahNumber;
    }

    public String getSessionDate() {
        return sessionDate;
    }

    public void setSessionDate(String sessionDate) {
        this.sessionDate = sessionDate;
    }

    public String getStartTime() {
        return startTime;
    }

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public String getEndTime() {
        return endTime;
    }

    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }

    public float getTajweedScore() {
        return tajweedScore;
    }

    public void setTajweedScore(float tajweedScore) {
        this.tajweedScore = tajweedScore;
    }

    public float getFluencyScore() {
        return fluencyScore;
    }

    public void setFluencyScore(float fluencyScore) {
        this.fluencyScore = fluencyScore;
    }

    public float getAccuracyScore() {
        return accuracyScore;
    }

    public void setAccuracyScore(float accuracyScore) {
        this.accuracyScore = accuracyScore;
    }

    public float getOverallScore() {
        return overallScore;
    }

    public void setOverallScore(float overallScore) {
        this.overallScore = overallScore;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public String getComments() {
        return comments;
    }

    public void setComments(String comments) {
        this.comments = comments;
    }

    public String getSuggestions() {
        return suggestions;
    }

    public void setSuggestions(String suggestions) {
        this.suggestions = suggestions;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getTeacherId() {
        return teacherId;
    }

    public void setTeacherId(String teacherId) {
        this.teacherId = teacherId;
    }

    public void setTeacherId(int teacherId) {
        this.teacherIdNum = teacherId;
    }

    public int getTeacherIdNum() {
        return teacherIdNum;
    }

    public void setTeacherIdNum(int teacherIdNum) {
        this.teacherIdNum = teacherIdNum;
    }

    public String getAreasForImprovement() {
        return areasForImprovement;
    }

    public void setAreasForImprovement(String areasForImprovement) {
        this.areasForImprovement = areasForImprovement;
    }

    public String getPerformanceTag() {
        return performanceTag;
    }

    public void setPerformanceTag(String performanceTag) {
        this.performanceTag = performanceTag;
    }

    public String getNextTarget() {
        return nextTarget;
    }

    public void setNextTarget(String nextTarget) {
        this.nextTarget = nextTarget;
    }

    public String getTeacherComments() {
        return teacherComments;
    }

    public void setTeacherComments(String teacherComments) {
        this.teacherComments = teacherComments;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public String getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(String updatedAt) {
        this.updatedAt = updatedAt;
    }

    // Helper method to get performance label based on overall score
    public String getPerformanceLabel() {
        if (overallScore >= 90) {
            return "Excellent";
        } else if (overallScore >= 80) {
            return "Good";
        } else if (overallScore >= 70) {
            return "Satisfactory";
        } else if (overallScore >= 60) {
            return "Fair";
        } else {
            return "Poor";
        }
    }

    // Helper method to get performance color for UI
    public String getPerformanceColor() {
        if (overallScore >= 90) {
            return "green";
        } else if (overallScore >= 80) {
            return "blue";
        } else if (overallScore >= 70) {
            return "yellow";
        } else if (overallScore >= 60) {
            return "orange";
        } else {
            return "red";
        }
    }
}
