package util;

import org.json.JSONObject;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.security.KeyFactory;
import java.security.PrivateKey;
import java.security.Signature;
import java.security.spec.PKCS8EncodedKeySpec;
import java.util.Base64;

/**
 * Signs short-lived JWTs for 8x8 JaaS (RS256).
 * Requires {@code jitsi.api.key} and a PKCS#8 private key from the 8x8 Developer Console.
 */
public final class JaasJwtGenerator {

    private static volatile PrivateKey cachedKey;

    private JaasJwtGenerator() {}

    public static boolean isConfigured() {
        return JitsiConfig.isJaas()
                && !JitsiConfig.getApiKeyId().isEmpty()
                && loadPrivateKey() != null;
    }

    /** Moderator token for the teacher (opens the room). */
    public static String createModeratorToken(String userId, String name, String email, String roomSlug) {
        return createToken(userId, name, email, roomSlug, true);
    }

    /** Participant token for a student (no moderator rights). */
    public static String createParticipantToken(String userId, String name, String email, String roomSlug) {
        return createToken(userId, name, email, roomSlug, false);
    }

    public static String createToken(String userId, String name, String email,
                                     String roomSlug, boolean moderator) {
        if (!JitsiConfig.isJaas()) return null;

        PrivateKey key = loadPrivateKey();
        String apiKeyId = JitsiConfig.getApiKeyId();
        String appId = JitsiConfig.getAppId();
        if (key == null || apiKeyId.isEmpty() || appId.isEmpty()) {
            return null;
        }

        long nowSec = System.currentTimeMillis() / 1000L;
        String room = (roomSlug != null && !roomSlug.trim().isEmpty()) ? roomSlug.trim() : "*";

        JSONObject user = new JSONObject();
        user.put("id", safe(userId));
        user.put("name", safe(name));
        user.put("email", safe(email));
        user.put("moderator", moderator ? "true" : "false");

        JSONObject context = new JSONObject();
        context.put("user", user);

        JSONObject payload = new JSONObject();
        payload.put("aud", "jitsi");
        payload.put("iss", "chat");
        payload.put("sub", appId);
        payload.put("room", room);
        payload.put("context", context);
        payload.put("iat", nowSec);
        payload.put("nbf", nowSec - 5);
        payload.put("exp", nowSec + 7200);

        JSONObject header = new JSONObject();
        header.put("alg", "RS256");
        header.put("typ", "JWT");
        header.put("kid", apiKeyId);

        try {
            return sign(header.toString(), payload.toString(), key);
        } catch (Exception e) {
            System.err.println("JaasJwtGenerator: signing failed: " + e.getMessage());
            return null;
        }
    }

    private static String sign(String headerJson, String payloadJson, PrivateKey key) throws Exception {
        String header = base64Url(headerJson.getBytes(StandardCharsets.UTF_8));
        String payload = base64Url(payloadJson.getBytes(StandardCharsets.UTF_8));
        String signingInput = header + "." + payload;

        Signature signature = Signature.getInstance("SHA256withRSA");
        signature.initSign(key);
        signature.update(signingInput.getBytes(StandardCharsets.UTF_8));
        return signingInput + "." + base64Url(signature.sign());
    }

    private static String base64Url(byte[] data) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(data);
    }

    private static PrivateKey loadPrivateKey() {
        if (cachedKey != null) return cachedKey;

        String pem = JitsiConfig.getPrivateKeyPem();
        if (pem == null || pem.isEmpty()) {
            pem = readPemFile(JitsiConfig.getPrivateKeyPath());
        }
        if (pem == null || pem.isEmpty()) {
            return null;
        }

        try {
            cachedKey = parsePkcs8Pem(pem);
            return cachedKey;
        } catch (Exception e) {
            System.err.println("JaasJwtGenerator: invalid private key: " + e.getMessage());
            return null;
        }
    }

    private static String readPemFile(String path) {
        if (path == null || path.trim().isEmpty()) return null;
        File file = new File(path.trim());
        if (!file.isFile()) {
            String catalinaBase = System.getProperty("catalina.base", "");
            file = new File(catalinaBase + "/webapps/ROOT/WEB-INF/" + path.trim());
        }
        if (!file.isFile()) {
            file = new File("WEB-INF/" + path.trim());
        }
        if (!file.isFile()) return null;
        try {
            return Files.readString(file.toPath(), StandardCharsets.UTF_8);
        } catch (IOException e) {
            System.err.println("JaasJwtGenerator: could not read " + file.getAbsolutePath());
            return null;
        }
    }

    private static PrivateKey parsePkcs8Pem(String pem) throws Exception {
        String normalized = pem.replace("\\n", "\n").trim();
        String stripped = normalized
                .replace("-----BEGIN PRIVATE KEY-----", "")
                .replace("-----END PRIVATE KEY-----", "")
                .replaceAll("\\s", "");
        byte[] decoded = Base64.getDecoder().decode(stripped);
        PKCS8EncodedKeySpec spec = new PKCS8EncodedKeySpec(decoded);
        return KeyFactory.getInstance("RSA").generatePrivate(spec);
    }

    private static String safe(String value) {
        return value != null ? value.trim() : "";
    }
}
