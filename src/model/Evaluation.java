package model;

public class Evaluation {

    // Core identifiers
    private String evaluationId;   // PK from studentevaluation
    private String feedbackId;     // PK from studentfeedback
    private String studentId;
    private String teacherId;
    private String sessionId;
    private String scheduleId;

    // Teacher-assigned scores (studentevaluation table)
    private double tajweedScore;
    private double fluencyScore;
    private double accuracyScore;
    private double overallScore;

    // Teacher-assigned feedback
    private String strengths;       // maps to strength column
    private String improvements;    // maps to weakness / areas_for_improvement
    private String suggestions;     // maps to studentImprovements / suggestions
    private String nextTarget;
    private String comments;        // teacher's comments to the student

    // Student-submitted rating about the teacher
    private int    rating;          // 1-5 star rating given by student

    // Session / schedule info
    private String teacherName;
    private String surahName;
    private String ayahRange;
    private String sessionDate;
    private String startTime;
    private String endTime;
    private String createdAt;

    // Legacy fields (kept for backward compatibility)
    private String result;
    private String grade;
    private String feedback;
    private String date;

    public Evaluation() {}

    // Getters and Setters

    public String getEvaluationId()              { return evaluationId; }
    public void   setEvaluationId(String v)      { this.evaluationId = v; }

    public String getFeedbackId()                { return feedbackId; }
    public void   setFeedbackId(String v)        { this.feedbackId = v; }

    public String getStudentId()                 { return studentId; }
    public void   setStudentId(String v)         { this.studentId = v; }

    public String getTeacherId()                 { return teacherId; }
    public void   setTeacherId(String v)         { this.teacherId = v; }

    public String getSessionId()                 { return sessionId; }
    public void   setSessionId(String v)         { this.sessionId = v; }

    public String getScheduleId()                { return scheduleId; }
    public void   setScheduleId(String v)        { this.scheduleId = v; }

    public double getTajweedScore()              { return tajweedScore; }
    public void   setTajweedScore(double v)      { this.tajweedScore = v; }

    public double getFluencyScore()              { return fluencyScore; }
    public void   setFluencyScore(double v)      { this.fluencyScore = v; }

    public double getAccuracyScore()             { return accuracyScore; }
    public void   setAccuracyScore(double v)     { this.accuracyScore = v; }

    public double getOverallScore()              { return overallScore; }
    public void   setOverallScore(double v)      { this.overallScore = v; }

    public String getStrengths()                 { return strengths; }
    public void   setStrengths(String v)         { this.strengths = v; }

    public String getImprovements()              { return improvements; }
    public void   setImprovements(String v)      { this.improvements = v; }

    public String getSuggestions()               { return suggestions; }
    public void   setSuggestions(String v)       { this.suggestions = v; }

    public String getNextTarget()                { return nextTarget; }
    public void   setNextTarget(String v)        { this.nextTarget = v; }

    public String getComments()                  { return comments; }
    public void   setComments(String v)          { this.comments = v; }

    public int    getRating()                    { return rating; }
    public void   setRating(int v)               { this.rating = v; }

    public String getTeacherName()               { return teacherName; }
    public void   setTeacherName(String v)       { this.teacherName = v; }

    public String getSurahName()                 { return surahName; }
    public void   setSurahName(String v)         { this.surahName = v; }

    public String getAyahRange()                 { return ayahRange; }
    public void   setAyahRange(String v)         { this.ayahRange = v; }

    public String getSessionDate()               { return sessionDate; }
    public void   setSessionDate(String v)       { this.sessionDate = v; }

    public String getStartTime()                 { return startTime; }
    public void   setStartTime(String v)         { this.startTime = v; }

    public String getEndTime()                   { return endTime; }
    public void   setEndTime(String v)           { this.endTime = v; }

    public String getCreatedAt()                 { return createdAt; }
    public void   setCreatedAt(String v)         { this.createdAt = v; }

    // Legacy
    public String getResult()                    { return result; }
    public void   setResult(String v)            { this.result = v; }

    public String getGrade()                     { return grade; }
    public void   setGrade(String v)             { this.grade = v; }

    public String getFeedback()                  { return feedback; }
    public void   setFeedback(String v)          { this.feedback = v; }

    public String getDate()                      { return date; }
    public void   setDate(String v)              { this.date = v; }
}
