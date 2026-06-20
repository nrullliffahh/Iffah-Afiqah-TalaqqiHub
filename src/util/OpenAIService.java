package util;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Properties;

/**
 * Server-side OpenAI Chat Completions client (GPT-3.5-turbo).
 *
 * API key resolution order:
 * 1. OPENAI_API_KEY environment variable
 * 2. OPENAI_API_KEY system property
 * 3. WEB-INF/openai.properties (openai.api.key=sk-...)
 *
 * Never expose the key to the browser.
 */
public class OpenAIService {

    private static final String PROPERTIES_FILE = "openai.properties";
    private static volatile String cachedApiKey;

    private static final String API_URL = "https://api.openai.com/v1/chat/completions";
    private static final String MODEL = "gpt-3.5-turbo";
    private static final int CONNECT_MS = 10_000;
    private static final int READ_MS = 30_000;
    private static final int MAX_TOKENS = 500;

    private static final String SYSTEM_PROMPT =
            "You are the AI Learning Assistant for TalaqqiHub, a Quran recitation and Tajweed learning platform. " +
            "Help students with questions about Quran recitation, Tajweed rules, pronunciation (makhraj), " +
            "memorization tips, and general learning guidance. " +
            "Keep answers clear, educational, and encouraging. Use simple examples when explaining Tajweed rules. " +
            "Always remind students that AI responses are for learning support only and important matters " +
            "should be verified with qualified teachers. Do not issue fatwas or legal rulings.";

    public static class ChatResult {
        private final boolean success;
        private final String message;
        private final String error;

        private ChatResult(boolean success, String message, String error) {
            this.success = success;
            this.message = message;
            this.error = error;
        }

        public static ChatResult ok(String message) {
            return new ChatResult(true, message, null);
        }

        public static ChatResult fail(String error) {
            return new ChatResult(false, null, error);
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
        public String getError() { return error; }
    }

    public ChatResult ask(String question) {
        String apiKey = getApiKey();
        if (apiKey == null || apiKey.trim().isEmpty()) {
            return ChatResult.fail(
                    "OpenAI API key is not configured. Add your key to WEB-INF/openai.properties " +
                    "(openai.api.key=sk-...) or set the OPENAI_API_KEY environment variable, then restart Tomcat.");
        }

        if (question == null || question.trim().isEmpty()) {
            return ChatResult.fail("Question cannot be empty.");
        }

        String trimmed = question.trim();
        if (trimmed.length() > 1000) {
            return ChatResult.fail("Question is too long. Please keep it under 1000 characters.");
        }

        HttpURLConnection conn = null;
        try {
            conn = (HttpURLConnection) new URL(API_URL).openConnection();
            conn.setRequestMethod("POST");
            conn.setConnectTimeout(CONNECT_MS);
            conn.setReadTimeout(READ_MS);
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("Authorization", "Bearer " + apiKey.trim());

            String body = buildRequestBody(trimmed);
            try (OutputStream os = conn.getOutputStream()) {
                os.write(body.getBytes(StandardCharsets.UTF_8));
            }

            int status = conn.getResponseCode();
            InputStream stream = status < 400 ? conn.getInputStream() : conn.getErrorStream();
            String responseBody = readStream(stream);

            if (status != 200) {
                String err = extractOpenAIError(responseBody);
                String friendly = toFriendlyError(err, status);
                return ChatResult.fail(friendly != null ? friendly : "OpenAI request failed (HTTP " + status + ")");
            }

            String answer = extractAssistantMessage(responseBody);
            if (answer == null || answer.isEmpty()) {
                return ChatResult.fail("No response received from AI.");
            }

            return ChatResult.ok(answer);

        } catch (Exception e) {
            System.err.println("OpenAIService.ask error: " + e.getMessage());
            e.printStackTrace();
            return ChatResult.fail("Unable to reach AI service. Please try again later.");
        } finally {
            if (conn != null) conn.disconnect();
        }
    }

    private String buildRequestBody(String question) {
        return "{"
                + "\"model\":\"" + MODEL + "\","
                + "\"max_tokens\":" + MAX_TOKENS + ","
                + "\"temperature\":0.7,"
                + "\"messages\":["
                + "{\"role\":\"system\",\"content\":\"" + escapeJson(SYSTEM_PROMPT) + "\"},"
                + "{\"role\":\"user\",\"content\":\"" + escapeJson(question) + "\"}"
                + "]"
                + "}";
    }

    private String extractAssistantMessage(String json) {
        int choicesIdx = json.indexOf("\"choices\"");
        if (choicesIdx < 0) return null;

        int contentKey = json.indexOf("\"content\"", choicesIdx);
        if (contentKey < 0) return null;

        int colon = json.indexOf(':', contentKey);
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
        return sb.toString().trim();
    }

    private String toFriendlyError(String raw, int status) {
        if (raw == null) return null;
        String lower = raw.toLowerCase();
        if (lower.contains("quota") || lower.contains("billing") || lower.contains("insufficient")) {
            return "OpenAI quota exceeded — your API account has no remaining credits. "
                    + "Add billing at platform.openai.com/settings/organization/billing "
                    + "or wait for your usage limit to reset.";
        }
        if (status == 429 || lower.contains("rate limit")) {
            return "Too many requests. Please wait a moment and try again.";
        }
        if (lower.contains("invalid_api_key") || lower.contains("incorrect api key")) {
            return "Invalid OpenAI API key. Update WEB-INF/openai.properties and restart Tomcat.";
        }
        return raw;
    }

    private String extractOpenAIError(String json) {
        int errIdx = json.indexOf("\"message\"");
        if (errIdx < 0) return null;
        int colon = json.indexOf(':', errIdx);
        int startQuote = json.indexOf('"', colon + 1);
        if (startQuote < 0) return null;
        int endQuote = json.indexOf('"', startQuote + 1);
        if (endQuote < 0) return null;
        return json.substring(startQuote + 1, endQuote);
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

    private String getApiKey() {
        if (cachedApiKey != null) return cachedApiKey;

        String key = System.getenv("OPENAI_API_KEY");
        if (isValidKey(key)) {
            cachedApiKey = key.trim();
            return cachedApiKey;
        }

        key = System.getProperty("OPENAI_API_KEY");
        if (isValidKey(key)) {
            cachedApiKey = key.trim();
            return cachedApiKey;
        }

        key = loadKeyFromPropertiesFile();
        if (isValidKey(key)) {
            cachedApiKey = key.trim();
            return cachedApiKey;
        }

        return null;
    }

    private boolean isValidKey(String key) {
        return key != null && !key.trim().isEmpty()
                && !key.trim().startsWith("sk-your-key")
                && !key.trim().equals("YOUR_OPENAI_API_KEY_HERE");
    }

    private String loadKeyFromPropertiesFile() {
        String[] candidates = buildPropertiesPaths();
        for (String path : candidates) {
            if (path == null || path.isEmpty()) continue;
            File file = new File(path);
            if (!file.isFile()) continue;

            try (FileInputStream in = new FileInputStream(file)) {
                Properties props = new Properties();
                props.load(in);
                String key = props.getProperty("openai.api.key");
                if (isValidKey(key)) {
                    System.out.println("OpenAIService: loaded API key from " + file.getAbsolutePath());
                    return key.trim();
                }
            } catch (Exception e) {
                System.err.println("OpenAIService: could not read " + path + ": " + e.getMessage());
            }
        }
        return null;
    }

    private String[] buildPropertiesPaths() {
        String catalinaBase = System.getProperty("catalina.base", "");
        String catalinaHome = System.getProperty("catalina.home", "");
        return new String[] {
            catalinaBase + "/webapps/TalaqqiHub/WEB-INF/" + PROPERTIES_FILE,
            catalinaHome + "/webapps/TalaqqiHub/WEB-INF/" + PROPERTIES_FILE,
            "WEB-INF/" + PROPERTIES_FILE,
            PROPERTIES_FILE
        };
    }
}
