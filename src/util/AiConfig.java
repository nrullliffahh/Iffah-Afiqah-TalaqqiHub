package util;

import java.io.File;
import java.io.FileInputStream;
import java.util.Properties;

/**
 * Loads AI provider settings from WEB-INF/openai.properties.
 */
public class AiConfig {

    private static final String PROPERTIES_FILE = "openai.properties";
    private static volatile Properties cached;

    public static String getProvider() {
        String provider = getProperty("ai.provider", "gemini");
        return provider == null ? "gemini" : provider.trim().toLowerCase();
    }

    public static String getGeminiApiKey() {
        return getValidKey(getProperty("gemini.api.key", null));
    }

    public static String getOpenAiApiKey() {
        return getValidKey(getProperty("openai.api.key", null));
    }

    public static String getGeminiModel() {
        String model = getProperty("gemini.model", "gemini-2.5-flash");
        return (model == null || model.trim().isEmpty()) ? "gemini-2.5-flash" : model.trim();
    }

    private static String getProperty(String key, String defaultValue) {
        Properties props = loadProperties();
        String envKey = key.toUpperCase().replace('.', '_');
        String env = System.getenv(envKey);
        if (isValidKey(env)) return env.trim();
        String sys = System.getProperty(envKey);
        if (isValidKey(sys)) return sys.trim();
        if (props != null) {
            String val = props.getProperty(key);
            if (val != null && !val.trim().isEmpty()) return val.trim();
        }
        return defaultValue;
    }

    private static Properties loadProperties() {
        if (cached != null) return cached;
        Properties props = new Properties();
        for (String path : buildPropertiesPaths()) {
            File file = new File(path);
            if (!file.isFile()) continue;
            try (FileInputStream in = new FileInputStream(file)) {
                props.load(in);
                cached = props;
                System.out.println("AiConfig: loaded from " + file.getAbsolutePath());
                return props;
            } catch (Exception e) {
                System.err.println("AiConfig: could not read " + path + ": " + e.getMessage());
            }
        }
        cached = props;
        return props;
    }

    private static String[] buildPropertiesPaths() {
        String catalinaBase = System.getProperty("catalina.base", "");
        String catalinaHome = System.getProperty("catalina.home", "");
        return new String[] {
            catalinaBase + "/webapps/TalaqqiHub/WEB-INF/" + PROPERTIES_FILE,
            catalinaHome + "/webapps/TalaqqiHub/WEB-INF/" + PROPERTIES_FILE,
            "WEB-INF/" + PROPERTIES_FILE,
            PROPERTIES_FILE
        };
    }

    private static String getValidKey(String key) {
        if (!isValidKey(key)) return null;
        return key.trim();
    }

    private static boolean isValidKey(String key) {
        if (key == null || key.trim().isEmpty()) return false;
        String k = key.trim();
        return !k.startsWith("sk-your-key")
                && !k.equals("YOUR_OPENAI_API_KEY_HERE")
                && !k.equals("YOUR_GEMINI_API_KEY_HERE");
    }
}
