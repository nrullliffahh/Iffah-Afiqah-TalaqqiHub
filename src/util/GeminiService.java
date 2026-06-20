package util;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

/**
 * Google Gemini API client — free tier via Google AI Studio.
 * Get a free key: https://aistudio.google.com/apikey
 */
public class GeminiService {

    private static final String API_BASE =
            "https://generativelanguage.googleapis.com/v1beta/models/";
    private static final int CONNECT_MS = 10_000;
    private static final int READ_MS = 30_000;
    private static final int MAX_TOKENS = 2048;

    private static final String STUDENT_SYSTEM_PROMPT =
            "You are the AI Learning Assistant for TalaqqiHub, a Quran recitation and Tajweed learning platform. "
            + "Help students with questions about Quran recitation, Tajweed rules, pronunciation (makhraj), "
            + "memorization tips, and general learning guidance. "
            + "Always give a complete, detailed answer to the student's question. "
            + "Do not stop at a greeting — include the full explanation, lists, and examples requested. "
            + "Keep answers clear, educational, and encouraging. Use simple examples when explaining Tajweed rules. "
            + "Always remind students that AI responses are for learning support only and important matters "
            + "should be verified with qualified teachers. Do not issue fatwas or legal rulings.";

    private static final String TEACHER_SYSTEM_PROMPT =
            "You are the AI Teaching Assistant for TalaqqiHub Teacher Portal. "
            + "Help Quran teachers prepare lessons, explain Tajweed rules clearly for instruction, "
            + "suggest teaching approaches, pronunciation drills, and student feedback tips. "
            + "Always give a complete, detailed answer. Do not stop at a greeting — include full lists and examples. "
            + "Frame answers for educators: how to teach, common student mistakes, and classroom examples. "
            + "AI responses are for teaching reference only — verify important matters with qualified scholars. "
            + "Do not issue fatwas or legal rulings.";

    public OpenAIService.ChatResult ask(String question) {
        return askWithPrompt(question, STUDENT_SYSTEM_PROMPT);
    }

    public OpenAIService.ChatResult askForTeacher(String question) {
        return askWithPrompt(question, TEACHER_SYSTEM_PROMPT);
    }

    private OpenAIService.ChatResult askWithPrompt(String question, String systemPrompt) {
        String apiKey = AiConfig.getGeminiApiKey();
        if (apiKey == null) {
            return OpenAIService.ChatResult.fail(
                    "Gemini API key is not configured. Get a FREE key at https://aistudio.google.com/apikey "
                    + "and add it to WEB-INF/openai.properties as gemini.api.key=...");
        }

        if (!apiKey.startsWith("AIza") && !apiKey.startsWith("AQ.")) {
            return OpenAIService.ChatResult.fail(
                    "Unrecognized Gemini API key format. Keys from Google AI Studio start with AIzaSy or AQ.");
        }

        if (question == null || question.trim().isEmpty()) {
            return OpenAIService.ChatResult.fail("Question cannot be empty.");
        }

        String trimmed = question.trim();
        if (trimmed.length() > 1000) {
            return OpenAIService.ChatResult.fail("Question is too long. Please keep it under 1000 characters.");
        }

        String[] models = buildModelFallbacks(AiConfig.getGeminiModel());
        OpenAIService.ChatResult lastResult = null;

        for (String model : models) {
            OpenAIService.ChatResult result = callModel(model, apiKey, trimmed, systemPrompt, false);
            if (result.isSuccess()) {
                return result;
            }
            String err = result.getError() == null ? "" : result.getError().toLowerCase();
            if (model.contains("2.5") && (err.contains("thinking") || err.contains("invalid"))) {
                System.out.println("GeminiService: retrying " + model + " without thinkingConfig");
                result = callModel(model, apiKey, trimmed, systemPrompt, true);
                if (result.isSuccess()) return result;
            }
            lastResult = result;
            if (!err.contains("not found") && !err.contains("not supported")
                    && !err.contains("incomplete answer")) {
                return result;
            }
            System.out.println("GeminiService: model " + model + " unavailable, trying next...");
        }

        return lastResult != null ? lastResult
                : OpenAIService.ChatResult.fail("No Gemini models available.");
    }

    private String[] buildModelFallbacks(String configured) {
        String[] defaults = {
            "gemini-2.5-flash",
            "gemini-2.5-flash-lite",
            "gemini-3.5-flash"
        };
        if (configured == null || configured.trim().isEmpty()) {
            return defaults;
        }
        String primary = configured.trim();
        boolean found = false;
        String[] ordered = new String[defaults.length];
        ordered[0] = primary;
        int idx = 1;
        for (String model : defaults) {
            if (model.equals(primary)) {
                found = true;
                continue;
            }
            if (idx < ordered.length) {
                ordered[idx++] = model;
            }
        }
        if (!found && idx < ordered.length) {
            ordered[idx] = primary;
        }
        return ordered;
    }

    private boolean isSubstantiveAnswer(String answer, String question) {
        if (answer == null) return false;
        String trimmed = answer.trim();
        if (trimmed.length() < 80) return false;
        String lower = trimmed.toLowerCase();
        if (lower.contains("great question") && trimmed.length() < 150) return false;
        String q = question == null ? "" : question.toLowerCase();
        if ((q.contains("list") || q.contains("hukum") || q.contains("type")) && trimmed.length() < 200) {
            return false;
        }
        return true;
    }

    private OpenAIService.ChatResult callModel(String model, String apiKey, String question,
                                               String systemPrompt, boolean skipThinkingConfig) {
        HttpURLConnection conn = null;
        try {
            String urlStr = API_BASE + model + ":generateContent";
            conn = (HttpURLConnection) new URL(urlStr).openConnection();
            conn.setRequestMethod("POST");
            conn.setConnectTimeout(CONNECT_MS);
            conn.setReadTimeout(READ_MS);
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("x-goog-api-key", apiKey);

            String body = buildRequestBody(question, model, systemPrompt, skipThinkingConfig);
            try (OutputStream os = conn.getOutputStream()) {
                os.write(body.getBytes(StandardCharsets.UTF_8));
            }

            int status = conn.getResponseCode();
            InputStream stream = status < 400 ? conn.getInputStream() : conn.getErrorStream();
            String responseBody = readStream(stream);

            if (status != 200) {
                String err = extractGeminiError(responseBody);
                return OpenAIService.ChatResult.fail(
                        toFriendlyError(err, status));
            }

            String answer = extractText(responseBody);
            if (answer == null || answer.isEmpty()) {
                return OpenAIService.ChatResult.fail("No response received from Gemini.");
            }

            if (!isSubstantiveAnswer(answer, question)) {
                System.out.println("GeminiService: response too short, treating as failure");
                return OpenAIService.ChatResult.fail("Gemini returned an incomplete answer. Please try again.");
            }

            return OpenAIService.ChatResult.ok(answer);

        } catch (Exception e) {
            System.err.println("GeminiService error: " + e.getMessage());
            e.printStackTrace();
            return OpenAIService.ChatResult.fail("Unable to reach Gemini AI. Please try again later.");
        } finally {
            if (conn != null) conn.disconnect();
        }
    }

    private String buildRequestBody(String question, String model, String systemPrompt,
                                    boolean skipThinkingConfig) {
        String thinking = (!skipThinkingConfig && model != null && model.contains("2.5"))
                ? "\"thinkingConfig\":{\"thinkingBudget\":0},"
                : "";
        return "{"
                + "\"systemInstruction\":{\"parts\":[{\"text\":\"" + escapeJson(systemPrompt) + "\"}]},"
                + "\"contents\":[{\"parts\":[{\"text\":\"" + escapeJson(question) + "\"}]}],"
                + "\"generationConfig\":{"
                + thinking
                + "\"maxOutputTokens\":" + MAX_TOKENS + ","
                + "\"temperature\":0.7"
                + "}"
                + "}";
    }

    private String extractText(String json) {
        int candidatesIdx = json.indexOf("\"candidates\"");
        String searchArea = candidatesIdx >= 0 ? json.substring(candidatesIdx) : json;

        StringBuilder answer = new StringBuilder();
        String longest = "";
        int pos = 0;

        while (pos < searchArea.length()) {
            int textKey = searchArea.indexOf("\"text\"", pos);
            if (textKey < 0) break;

            int partStart = searchArea.lastIndexOf('{', textKey);
            int partEnd = searchArea.indexOf('}', textKey);
            String partBlock = (partStart >= 0 && partEnd > partStart)
                    ? searchArea.substring(partStart, partEnd)
                    : "";

            if (partBlock.contains("\"thought\":true") || partBlock.contains("\"thought\": true")) {
                pos = textKey + 6;
                continue;
            }

            String chunk = extractJsonStringValue(searchArea, textKey);
            if (chunk != null && !chunk.isEmpty()) {
                if (chunk.length() > longest.length()) {
                    longest = chunk;
                }
                if (answer.length() > 0) answer.append("\n\n");
                answer.append(chunk);
            }
            pos = textKey + 6;
        }

        String result = longest.length() >= answer.length() ? longest : answer.toString();
        return result.trim().isEmpty() ? null : result.trim();
    }

    private String extractJsonStringValue(String json, int keyIndex) {
        int colon = json.indexOf(':', keyIndex);
        if (colon < 0) return null;
        int startQuote = json.indexOf('"', colon + 1);
        if (startQuote < 0) return null;

        StringBuilder sb = new StringBuilder();
        for (int i = startQuote + 1; i < json.length(); i++) {
            char c = json.charAt(i);
            if (c == '\\' && i + 1 < json.length()) {
                char next = json.charAt(i + 1);
                switch (next) {
                    case '"': sb.append('"'); i++; break;
                    case '\\': sb.append('\\'); i++; break;
                    case 'n': sb.append('\n'); i++; break;
                    case 'r': sb.append('\r'); i++; break;
                    case 't': sb.append('\t'); i++; break;
                    default: sb.append(c); break;
                }
            } else if (c == '"') {
                break;
            } else {
                sb.append(c);
            }
        }
        return sb.toString();
    }

    private String extractGeminiError(String json) {
        int errIdx = json.indexOf("\"message\"");
        if (errIdx < 0) return null;
        int colon = json.indexOf(':', errIdx);
        int startQuote = json.indexOf('"', colon + 1);
        if (startQuote < 0) return null;
        int endQuote = json.indexOf('"', startQuote + 1);
        if (endQuote < 0) return null;
        return json.substring(startQuote + 1, endQuote);
    }

    private String toFriendlyError(String raw, int status) {
        if (raw == null) return "Gemini request failed (HTTP " + status + ")";
        String lower = raw.toLowerCase();
        if (status == 429 || lower.contains("quota") || lower.contains("resource exhausted")) {
            return "Gemini free quota reached. Try again later or use the offline guide.";
        }
        if (lower.contains("api key") || lower.contains("api_key")) {
            return "Invalid Gemini API key. Get a free key at https://aistudio.google.com/apikey";
        }
        return raw;
    }

    private String readStream(InputStream in) throws Exception {
        if (in == null) return "";
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        return sb.toString();
    }

    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r")
                    .replace("\t", "\\t");
    }
}
