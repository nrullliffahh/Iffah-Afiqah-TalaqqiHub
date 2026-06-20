package model;

/**
 * Represents a single AI assistance Q&A record stored in the aiassistance table.
 */
public class AiAssistance {

    private String aiId;
    private String aiQuestion;
    private String aiResponse;
    private String studentId;
    private String teacherId;

    public AiAssistance() {}

    public AiAssistance(String aiId, String aiQuestion, String aiResponse, String studentId) {
        this.aiId = aiId;
        this.aiQuestion = aiQuestion;
        this.aiResponse = aiResponse;
        this.studentId = studentId;
    }

    public String getAiId() { return aiId; }
    public void setAiId(String aiId) { this.aiId = aiId; }

    public String getAiQuestion() { return aiQuestion; }
    public void setAiQuestion(String aiQuestion) { this.aiQuestion = aiQuestion; }

    public String getAiResponse() { return aiResponse; }
    public void setAiResponse(String aiResponse) { this.aiResponse = aiResponse; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getTeacherId() { return teacherId; }
    public void setTeacherId(String teacherId) { this.teacherId = teacherId; }
}
