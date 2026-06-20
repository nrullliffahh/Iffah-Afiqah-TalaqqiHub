package model;

public class AiInteraction {

    private String aiId;
    private String userRole;
    private String userName;
    private String category;
    private String question;
    private String response;
    private String dateTime;

    public String getAiId() { return aiId; }
    public void setAiId(String aiId) { this.aiId = aiId; }

    public String getUserRole() { return userRole; }
    public void setUserRole(String userRole) { this.userRole = userRole; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getQuestion() { return question; }
    public void setQuestion(String question) { this.question = question; }

    public String getResponse() { return response; }
    public void setResponse(String response) { this.response = response; }

    public String getDateTime() { return dateTime; }
    public void setDateTime(String dateTime) { this.dateTime = dateTime; }
}
