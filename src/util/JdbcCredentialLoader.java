package util;

import java.net.URI;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Base64;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Properties;
import java.util.Set;

/**
 * Loads JDBC URL + credentials for Kerocket/Aiven/XAMPP.
 * <p>
 * Kerocket often injects:
 * <ul>
 *   <li>{@code DB_URL} → Aiven {@code talaqqihub_db}</li>
 *   <li>{@code DATABASE_URL} → internal {@code mysql://kerocket@mysql:3306/app} (wrong for this app)</li>
 * </ul>
 * Never merge internal {@code kerocket} credentials with external Aiven {@code DB_URL}.
 */
public final class JdbcCredentialLoader {

    public static final class CredentialConfig {
        public final String url;
        public final String user;
        public final String password;
        public final boolean production;
        public final String source;

        public CredentialConfig(String url, String user, String password, boolean production, String source) {
            this.url = url;
            this.user = user != null ? user : "";
            this.password = password != null ? password : "";
            this.production = production;
            this.source = source;
        }

        String key() {
            return source + "|" + url + "|" + user;
        }
    }

    private static final Path DEPLOY_PROPERTIES = Paths.get("/usr/local/tomcat/conf/talaqqihub-db.properties");
    private static final Path DEPLOY_URL_FILE = Paths.get("/usr/local/tomcat/conf/db.jdbc.url");
    private static final Path DEPLOY_USER_FILE = Paths.get("/usr/local/tomcat/conf/db.jdbc.user");
    private static final Path DEPLOY_PASSWORD_FILE = Paths.get("/usr/local/tomcat/conf/db.jdbc.password");

    private JdbcCredentialLoader() {
    }

    public static List<CredentialConfig> loadAll() {
        List<CredentialConfig> configs = new ArrayList<>();
        Set<String> seen = new LinkedHashSet<>();

        String dbUrl = firstNonEmpty(getenv("DB_URL"), getProperty("DB_URL"));
        String databaseUrl = firstNonEmpty(getenv("DATABASE_URL"), getProperty("DATABASE_URL"));
        String dbUser = explicitCredentialsUser();
        String dbPassword = explicitCredentialsPassword();

        if (dbUrl != null && isExternalDatabaseUrl(dbUrl)) {
            // Aiven / external DB_URL — only use explicit env creds or external DATABASE_URL (aivencloud.com).
            add(configs, seen, buildAivenConfig(dbUrl, dbUser, dbPassword, databaseUrl));
            add(configs, seen, loadFromDeployFiles());
            add(configs, seen, loadFromPropertiesFile());
            if (databaseUrl != null && isExternalDatabaseUrl(databaseUrl)) {
                add(configs, seen, parseDatabaseUrl(databaseUrl));
            }
            // Do NOT fall back to internal Kerocket mysql/app when DB_URL is Aiven.
        } else {
            if (databaseUrl != null && !isInternalKerocketDatabaseUrl(databaseUrl)) {
                add(configs, seen, parseDatabaseUrl(databaseUrl));
            } else if (databaseUrl != null) {
                add(configs, seen, parseDatabaseUrl(databaseUrl));
            }
            add(configs, seen, buildAivenConfig(dbUrl, dbUser, dbPassword, databaseUrl));
            add(configs, seen, loadFromDeployFiles());
            add(configs, seen, loadFromPropertiesFile());
            if (dbUrl != null) {
                add(configs, seen, new CredentialConfig(
                    ensureJdbcParams(dbUrl),
                    dbUser != null ? dbUser : "root",
                    dbPassword != null ? dbPassword : "",
                    true,
                    "env:DB_URL"
                ));
            }
        }

        String mysqlHost = firstNonEmpty(
            getenv("MYSQLHOST"), getProperty("MYSQLHOST"),
            getenv("MYSQL_HOST"), getProperty("MYSQL_HOST")
        );
        if (mysqlHost != null && dbUrl == null) {
            String mysqlDatabase = firstNonEmpty(
                getenv("MYSQLDATABASE"), getProperty("MYSQLDATABASE"),
                getenv("MYSQL_DATABASE"), getProperty("MYSQL_DATABASE"),
                "talaqqihub_db"
            );
            String port = firstNonEmpty(
                getenv("MYSQLPORT"), getProperty("MYSQLPORT"),
                getenv("MYSQL_PORT"), getProperty("MYSQL_PORT"),
                "3306"
            );
            String url = "jdbc:mysql://" + mysqlHost + ":" + port + "/" + mysqlDatabase
                + "?sslMode=REQUIRED&serverTimezone=UTC&connectTimeout=5000&socketTimeout=10000&allowPublicKeyRetrieval=true";
            add(configs, seen, new CredentialConfig(
                url,
                dbUser != null ? dbUser : "root",
                dbPassword != null ? dbPassword : "",
                true,
                "env:MYSQLHOST"
            ));
        }

        add(configs, seen, new CredentialConfig(
            "jdbc:mysql://127.0.0.1:3306/talaqqihub_db"
                + "?useSSL=false&serverTimezone=UTC&connectTimeout=5000&socketTimeout=10000&allowPublicKeyRetrieval=true",
            "root",
            "admin",
            false,
            "local-default"
        ));

        return configs;
    }

    /** Aiven DB_URL + DB_USER/DB_PASSWORD, or credentials from external DATABASE_URL only. */
    private static CredentialConfig buildAivenConfig(
        String dbUrl, String dbUser, String dbPassword, String databaseUrl
    ) {
        if (dbUrl == null || dbUrl.isEmpty()) {
            return null;
        }

        String user = dbUser;
        String password = dbPassword != null ? dbPassword : "";

        if ((user == null || user.isEmpty()) && databaseUrl != null && isExternalDatabaseUrl(databaseUrl)) {
            CredentialConfig external = parseDatabaseUrl(databaseUrl);
            if (external != null && external.user != null && !external.user.isEmpty()) {
                user = external.user;
                password = external.password;
            }
        }

        if (user == null || user.isEmpty()) {
            return null;
        }

        if (isKerocketPlatformUser(user) && isExternalDatabaseUrl(dbUrl)) {
            System.err.println(
                "JdbcCredentialLoader: refusing kerocket platform user for external Aiven DB_URL — set DB_USER=avnadmin and DB_PASSWORD in Kerocket Deploy tab."
            );
            return null;
        }

        return new CredentialConfig(
            ensureJdbcParams(dbUrl),
            user,
            password,
            true,
            "JdbcCredentialLoader:aiven"
        );
    }

    public static boolean isInternalKerocketDatabaseUrl(String url) {
        if (url == null) {
            return false;
        }
        String lower = url.toLowerCase();
        if (lower.contains("aivencloud.com") || lower.contains("aiven.io")) {
            return false;
        }
        // mysql://kerocket:pass@mysql:3306/app or jdbc:mysql://mysql:3306/app
        if (lower.contains("@mysql:") || lower.contains("@mysql/")) {
            return true;
        }
        if (lower.contains("mysql://mysql:") || lower.contains("mysql://mysql/")
            || lower.contains("jdbc:mysql://mysql:") || lower.contains("jdbc:mysql://mysql/")) {
            return true;
        }
        // database name /app on internal host
        if (lower.contains("/app?") || lower.endsWith("/app") || lower.contains("/app&")) {
            if (lower.contains("@mysql") || lower.contains("://mysql")) {
                return true;
            }
        }
        return false;
    }

    public static boolean isExternalDatabaseUrl(String url) {
        if (url == null) {
            return false;
        }
        if (url.contains("aivencloud.com") || url.contains("aiven.io")) {
            return true;
        }
        if (isInternalKerocketDatabaseUrl(url)) {
            return false;
        }
        return !url.contains("127.0.0.1") && !url.contains("localhost");
    }

    public static boolean isKerocketPlatformUser(String user) {
        return user != null && "kerocket".equalsIgnoreCase(user.trim());
    }

    public static String safeJdbcHost(String jdbcUrl) {
        if (jdbcUrl == null) {
            return "(none)";
        }
        try {
            int start = jdbcUrl.indexOf("://");
            if (start < 0) {
                return "(unparsed)";
            }
            String rest = jdbcUrl.substring(start + 3);
            int slash = rest.indexOf('/');
            String hostPort = slash >= 0 ? rest.substring(0, slash) : rest;
            int at = hostPort.lastIndexOf('@');
            return at >= 0 ? hostPort.substring(at + 1) : hostPort;
        } catch (Exception e) {
            return "(unparsed)";
        }
    }

    public static String safeJdbcDatabase(String jdbcUrl) {
        if (jdbcUrl == null) {
            return "(none)";
        }
        try {
            int start = jdbcUrl.indexOf("://");
            if (start < 0) {
                return "(unparsed)";
            }
            String rest = jdbcUrl.substring(start + 3);
            int slash = rest.indexOf('/');
            if (slash < 0) {
                return "(none)";
            }
            String dbPart = rest.substring(slash + 1);
            int query = dbPart.indexOf('?');
            return query >= 0 ? dbPart.substring(0, query) : dbPart;
        } catch (Exception e) {
            return "(unparsed)";
        }
    }

    public static boolean hasDeployCredentialFiles() {
        return Files.isRegularFile(DEPLOY_URL_FILE);
    }

    private static CredentialConfig loadFromDeployFiles() {
        if (!Files.isRegularFile(DEPLOY_URL_FILE)) {
            return null;
        }
        try {
            String url = Files.readString(DEPLOY_URL_FILE, StandardCharsets.UTF_8).trim();
            if (url.isEmpty()) {
                return null;
            }
            String user = Files.isRegularFile(DEPLOY_USER_FILE)
                ? Files.readString(DEPLOY_USER_FILE, StandardCharsets.UTF_8).trim() : "";
            String password = Files.isRegularFile(DEPLOY_PASSWORD_FILE)
                ? Files.readString(DEPLOY_PASSWORD_FILE, StandardCharsets.UTF_8).trim() : "";
            if (user.isEmpty()) {
                return null;
            }
            if (isKerocketPlatformUser(user) && isExternalDatabaseUrl(url)) {
                return null;
            }
            return new CredentialConfig(ensureJdbcParams(url), user, password, true, "file:jdbc-credentials");
        } catch (Exception e) {
            System.err.println("JdbcCredentialLoader: failed to read deploy files: " + e.getMessage());
            return null;
        }
    }

    private static CredentialConfig loadFromPropertiesFile() {
        if (!Files.isRegularFile(DEPLOY_PROPERTIES)) {
            return null;
        }
        try {
            Properties props = new Properties();
            try (var reader = Files.newBufferedReader(DEPLOY_PROPERTIES, StandardCharsets.UTF_8)) {
                props.load(reader);
            }
            String url = decodeProperty(props, "db.url.b64", "db.url");
            if (url == null || url.isEmpty()) {
                return null;
            }
            String user = decodeProperty(props, "db.user.b64", "db.user");
            String password = decodeProperty(props, "db.password.b64", "db.password");
            if (user == null || user.isEmpty()) {
                return null;
            }
            if (isKerocketPlatformUser(user) && isExternalDatabaseUrl(url)) {
                return null;
            }
            return new CredentialConfig(ensureJdbcParams(url), user, password != null ? password : "", true, "file:properties");
        } catch (Exception e) {
            System.err.println("JdbcCredentialLoader: failed to read properties: " + e.getMessage());
            return null;
        }
    }

    private static CredentialConfig parseDatabaseUrl(String databaseUrl) {
        String raw = databaseUrl.trim();
        if (raw.isEmpty()) {
            return null;
        }
        if (raw.startsWith("jdbc:mysql://") || raw.startsWith("jdbc:mariadb://")) {
            ParsedUrl parsed = parseJdbcUrl(raw);
            if (parsed == null) {
                return null;
            }
            String user = firstNonEmpty(parsed.user, explicitCredentialsUser());
            String password = firstNonEmpty(parsed.password, explicitCredentialsPassword());
            return new CredentialConfig(
                ensureJdbcParams(parsed.jdbcUrl), user, password != null ? password : "", true,
                "env:DATABASE_URL(jdbc)"
            );
        }
        if (raw.startsWith("mysql://") || raw.startsWith("mariadb://")) {
            ParsedUrl parsed = parseMySqlSchemeUrl(raw);
            if (parsed == null) {
                return null;
            }
            return new CredentialConfig(
                ensureJdbcParams(parsed.jdbcUrl), parsed.user, parsed.password != null ? parsed.password : "",
                true, "env:DATABASE_URL(mysql)"
            );
        }
        return null;
    }

    private static ParsedUrl parseMySqlSchemeUrl(String raw) {
        try {
            URI uri = URI.create(raw.replaceFirst("^mysql://", "http://").replaceFirst("^mariadb://", "http://"));
            String userInfo = uri.getUserInfo();
            String user = null;
            String password = null;
            if (userInfo != null && !userInfo.isEmpty()) {
                int split = userInfo.indexOf(':');
                if (split >= 0) {
                    user = decode(userInfo.substring(0, split));
                    password = decode(userInfo.substring(split + 1));
                } else {
                    user = decode(userInfo);
                }
            }
            String host = uri.getHost();
            int port = uri.getPort() > 0 ? uri.getPort() : 3306;
            String path = uri.getPath();
            String database = (path != null && path.length() > 1) ? path.substring(1) : "talaqqihub_db";
            String query = uri.getQuery();
            String jdbcUrl = "jdbc:mysql://" + host + ":" + port + "/" + database;
            if (query != null && !query.isEmpty()) {
                query = query.replace("ssl-mode=", "sslMode=");
                jdbcUrl += "?" + query;
            }
            return new ParsedUrl(jdbcUrl, user, password);
        } catch (Exception e) {
            System.err.println("JdbcCredentialLoader: failed to parse DATABASE_URL: " + e.getMessage());
            return null;
        }
    }

    private static ParsedUrl parseJdbcUrl(String raw) {
        try {
            int schemeEnd = raw.indexOf("://");
            if (schemeEnd < 0) {
                return null;
            }
            int at = raw.indexOf('@', schemeEnd + 3);
            if (at < 0) {
                return new ParsedUrl(raw, null, null);
            }
            String userInfo = raw.substring(schemeEnd + 3, at);
            String remainder = raw.substring(at + 1);
            String user = null;
            String password = null;
            int split = userInfo.indexOf(':');
            if (split >= 0) {
                user = decode(userInfo.substring(0, split));
                password = decode(userInfo.substring(split + 1));
            } else {
                user = decode(userInfo);
            }
            String jdbcUrl = raw.substring(0, schemeEnd + 3) + remainder;
            return new ParsedUrl(jdbcUrl, user, password);
        } catch (Exception e) {
            return null;
        }
    }

    static String ensureJdbcParams(String jdbcUrl) {
        StringBuilder sb = new StringBuilder(jdbcUrl);
        String sep = jdbcUrl.contains("?") ? "&" : "?";
        if (!jdbcUrl.contains("serverTimezone=")) {
            sb.append(sep).append("serverTimezone=UTC");
            sep = "&";
        }
        if (!jdbcUrl.contains("connectTimeout=")) {
            sb.append(sep).append("connectTimeout=5000");
            sep = "&";
        }
        if (!jdbcUrl.contains("socketTimeout=")) {
            sb.append(sep).append("socketTimeout=10000");
            sep = "&";
        }
        if (!jdbcUrl.contains("allowPublicKeyRetrieval=")) {
            sb.append(sep).append("allowPublicKeyRetrieval=true");
            sep = "&";
        }
        if (!jdbcUrl.contains("sslMode=") && !jdbcUrl.contains("useSSL=")) {
            if (jdbcUrl.contains("127.0.0.1") || jdbcUrl.contains("localhost")) {
                sb.append(sep).append("useSSL=false");
            } else {
                sb.append(sep).append("sslMode=REQUIRED");
            }
        }
        return sb.toString();
    }

    /** Only explicit deploy-tab vars — never kerocket from DATABASE_URL. */
    private static String explicitCredentialsUser() {
        return firstNonEmpty(
            getenv("DB_USER"), getProperty("DB_USER"),
            getenv("MYSQLUSER"), getProperty("MYSQLUSER"),
            getenv("MYSQL_USER"), getProperty("MYSQL_USER")
        );
    }

    private static String explicitCredentialsPassword() {
        return firstNonEmpty(
            getenv("DB_PASSWORD"), getProperty("DB_PASSWORD"),
            getenv("MYSQLPASSWORD"), getProperty("MYSQLPASSWORD"),
            getenv("MYSQL_PASSWORD"), getProperty("MYSQL_PASSWORD")
        );
    }

    private static String decodeProperty(Properties props, String b64Key, String plainKey) {
        String b64 = props.getProperty(b64Key);
        if (b64 != null && !b64.trim().isEmpty()) {
            try {
                return new String(Base64.getDecoder().decode(b64.trim()), StandardCharsets.UTF_8);
            } catch (IllegalArgumentException ignored) {
                // fall through
            }
        }
        return props.getProperty(plainKey);
    }

    private static String decode(String value) {
        try {
            return URLDecoder.decode(value, StandardCharsets.UTF_8.name());
        } catch (Exception e) {
            return value;
        }
    }

    private static void add(List<CredentialConfig> configs, Set<String> seen, CredentialConfig config) {
        if (config == null || config.url == null || config.url.isEmpty()) {
            return;
        }
        if (seen.add(config.key())) {
            configs.add(config);
        }
    }

    private static String getenv(String key) {
        String value = System.getenv(key);
        if (value == null) {
            return null;
        }
        value = value.trim();
        return value.isEmpty() ? null : value;
    }

    private static String getProperty(String key) {
        String value = System.getProperty(key);
        if (value == null) {
            return null;
        }
        value = value.trim();
        return value.isEmpty() ? null : value;
    }

    private static String firstNonEmpty(String... values) {
        if (values == null) {
            return null;
        }
        for (String value : values) {
            if (value != null && !value.trim().isEmpty()) {
                return value.trim();
            }
        }
        return null;
    }

    private static final class ParsedUrl {
        final String jdbcUrl;
        final String user;
        final String password;

        ParsedUrl(String jdbcUrl, String user, String password) {
            this.jdbcUrl = jdbcUrl;
            this.user = user;
            this.password = password;
        }
    }
}
