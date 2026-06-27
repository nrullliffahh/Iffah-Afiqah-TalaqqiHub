package util;

import java.io.File;
import java.io.FileInputStream;
import java.util.Properties;

/**
 * Jitsi Meet / 8x8 JaaS settings from WEB-INF/jitsi.properties.
 */
public final class JitsiConfig {

    private static final String PROPERTIES_FILE = "jitsi.properties";
    private static volatile Properties cached;

    private JitsiConfig() {}

    public static boolean isJaas() {
        return "jaas".equalsIgnoreCase(getProvider());
    }

    public static String getProvider() {
        return getProperty("jitsi.provider", "public");
    }

    public static String getDomain() {
        if (isJaas()) {
            return getProperty("jitsi.domain", "8x8.vc");
        }
        return "meet.jit.si";
    }

    public static String getAppId() {
        return getProperty("jitsi.app.id", "");
    }

    /** Full URL to external_api.js (JaaS includes app id in path). */
    public static String getScriptUrl() {
        if (isJaas()) {
            String appId = getAppId();
            if (appId != null && !appId.trim().isEmpty()) {
                return "https://" + getDomain() + "/" + appId.trim() + "/external_api.js";
            }
        }
        return "https://meet.jit.si/external_api.js";
    }

    /** Optional static JWT fallback (prefer {@link JaasJwtGenerator} for JaaS). */
    public static String getJwt() {
        String jwt = getProperty("jitsi.jwt", null);
        if (jwt == null || jwt.trim().isEmpty()) return null;
        return jwt.trim();
    }

    /** API Key ID (kid) from 8x8 Developer Console. Env: {@code JITSI_API_KEY}. */
    public static String getApiKeyId() {
        return getProperty("jitsi.api.key", "");
    }

    /** Inline PEM private key. Env: {@code JITSI_PRIVATE_KEY} (use {@code \\n} for newlines). */
    public static String getPrivateKeyPem() {
        return getProperty("jitsi.private.key", null);
    }

    /** Path to PKCS#8 private key file under WEB-INF. Env: {@code JITSI_PRIVATE_KEY_PATH}. */
    public static String getPrivateKeyPath() {
        return getProperty("jitsi.private.key.path", "");
    }

    public static boolean isSigningConfigured() {
        return JaasJwtGenerator.isConfigured();
    }

    /**
     * Room name passed to JitsiMeetExternalAPI.
     * JaaS format: {appId}/{slug} e.g. vpaas-magic-cookie-.../TalaqqiHub-T003-S012
     */
    public static String buildRoomName(String teacherId, String sessionId) {
        String slug = buildRoomSlug(teacherId, sessionId);
        if (isJaas()) {
            String appId = getAppId();
            if (appId != null && !appId.trim().isEmpty()) {
                return appId.trim() + "/" + slug;
            }
        }
        return slug;
    }

    public static String buildRoomSlug(String teacherId, String sessionId) {
        String tId = (teacherId != null) ? teacherId.replaceAll("[^a-zA-Z0-9]", "") : "T";
        String sid = (sessionId != null) ? sessionId.replaceAll("[^a-zA-Z0-9]", "") : "S";
        return "TalaqqiHub-" + tId + "-" + sid;
    }

    private static String getProperty(String key, String defaultValue) {
        Properties props = loadProperties();
        String envKey = key.toUpperCase().replace('.', '_').replace('-', '_');
        String env = System.getenv(envKey);
        if (env != null && !env.trim().isEmpty()) return env.trim();
        String sys = System.getProperty(envKey);
        if (sys != null && !sys.trim().isEmpty()) return sys.trim();
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
                System.out.println("JitsiConfig: loaded from " + file.getAbsolutePath());
                return props;
            } catch (Exception e) {
                System.err.println("JitsiConfig: could not read " + path + ": " + e.getMessage());
            }
        }
        cached = props;
        return props;
    }

    private static String[] buildPropertiesPaths() {
        String catalinaBase = System.getProperty("catalina.base", "");
        String catalinaHome = System.getProperty("catalina.home", "");
        return new String[] {
            // Kerocket / Docker: WAR deployed as ROOT.war
            catalinaBase + "/webapps/ROOT/WEB-INF/" + PROPERTIES_FILE,
            catalinaHome + "/webapps/ROOT/WEB-INF/" + PROPERTIES_FILE,
            // Local XAMPP Tomcat
            catalinaBase + "/webapps/TalaqqiHub/WEB-INF/" + PROPERTIES_FILE,
            catalinaHome + "/webapps/TalaqqiHub/WEB-INF/" + PROPERTIES_FILE,
            "WEB-INF/" + PROPERTIES_FILE,
            PROPERTIES_FILE
        };
    }

    /** Log resolved settings once at startup (call from DbStartupListener). */
    public static void logStartupConfig() {
        System.out.println("JitsiConfig: provider=" + getProvider()
            + ", domain=" + getDomain()
            + ", scriptUrl=" + getScriptUrl()
            + ", jaasSigning=" + (isJaas() ? isSigningConfigured() : "n/a"));
    }
}
