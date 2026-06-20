package util;

import dao.AiAssistanceDAO;
import util.OpenAIService.ChatResult;

/**
 * Routes AI requests to the configured provider.
 * Default: Google Gemini (free tier).
 */
public class AiChatService {

    private final GeminiService gemini = new GeminiService();
    private final OpenAIService openai = new OpenAIService();

    public static class Answer {
        private final String message;
        private final boolean fallback;
        private final String error;

        private Answer(String message, boolean fallback, String error) {
            this.message = message;
            this.fallback = fallback;
            this.error = error;
        }

        public static Answer live(String message) { return new Answer(message, false, null); }
        public static Answer offline(String message) { return new Answer(message, true, null); }
        public static Answer failed(String error) { return new Answer(null, false, error); }

        public boolean isSuccess() { return message != null; }
        public String getMessage() { return message; }
        public boolean isFallback() { return fallback; }
        public String getError() { return error; }
    }

    public Answer resolve(String question) {
        return resolveInternal(question, false);
    }

    public Answer resolveForTeacher(String question) {
        return resolveInternal(question, true);
    }

    private Answer resolveInternal(String question, boolean forTeacher) {
        ChatResult primary = askLive(question, forTeacher);
        if (primary.isSuccess()) {
            return Answer.live(primary.getMessage());
        }

        if (!shouldUseOfflineFallback(primary.getError())) {
            return Answer.failed(primary.getError());
        }

        String offline = TajweedKnowledgeBase.findAnswer(question);
        if (offline != null) {
            return Answer.offline(offline);
        }

        AiAssistanceDAO dao = new AiAssistanceDAO();
        String dbAnswer = dao.findSimilarResponse(question);
        if (isUsefulCachedAnswer(dbAnswer)) {
            return Answer.offline(dbAnswer);
        }

        return Answer.failed(primary.getError());
    }

    private boolean isUsefulCachedAnswer(String answer) {
        if (answer == null) return false;
        String trimmed = answer.trim();
        if (trimmed.length() < 120) return false;
        String lower = trimmed.toLowerCase();
        if (lower.contains("great question") && trimmed.length() < 200) return false;
        return true;
    }

    private ChatResult askLive(String question, boolean forTeacher) {
        String provider = AiConfig.getProvider();

        if ("openai".equals(provider)) {
            return forTeacher ? gemini.askForTeacher(question) : openai.ask(question);
        }

        ChatResult geminiResult = forTeacher ? gemini.askForTeacher(question) : gemini.ask(question);
        if (geminiResult.isSuccess()) {
            return geminiResult;
        }

        if (AiConfig.getOpenAiApiKey() != null) {
            ChatResult openaiResult = openai.ask(question);
            if (openaiResult.isSuccess()) {
                return openaiResult;
            }
        }

        return geminiResult;
    }

    private boolean shouldUseOfflineFallback(String error) {
        if (error == null) return false;
        String lower = error.toLowerCase();
        if (lower.contains("api key") || lower.contains("not configured") || lower.contains("invalid")) {
            return false;
        }
        return lower.contains("quota") || lower.contains("rate limit")
                || lower.contains("resource exhausted")
                || lower.contains("incomplete answer");
    }
}
