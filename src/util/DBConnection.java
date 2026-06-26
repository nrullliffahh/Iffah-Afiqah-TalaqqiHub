package util;

import java.io.Reader;
import java.net.URI;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Base64;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Properties;
import java.util.Set;
import java.util.concurrent.atomic.AtomicBoolean;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

/**
 * Database connections for TalaqqiHub (student, teacher, admin).
 */
public class DBConnection {

    private static final String DB_DRIVER = "com.mysql.cj.jdbc.Driver";
    private static final String JNDI_NAME = "java:comp/env/jdbc/TalaqqiHubDB";
    private static final Path DEPLOY_PROPERTIES = Paths.get("/usr/local/tomcat/conf/talaqqihub-db.properties");
    private static final Path DEPLOY_URL_FILE = Paths.get("/usr/local/tomcat/conf/db.jdbc.url");
    private static final Path DEPLOY_USER_FILE = Paths.get("/usr/local/tomcat/conf/db.jdbc.user");
    private static final Path DEPLOY_PASSWORD_FILE = Paths.get("/usr/local/tomcat/conf/db.jdbc.password");
    private static final AtomicBoolean LOGGED_CONFIG = new AtomicBoolean(false);
    private static volatile String lastConnectionError = "";

    private static final class DbConfig {
        final String url;
        final String user;
        final String password;
        final boolean production;
        final String source;

        DbConfig(String url, String user, String password, boolean production, String source) {
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

    public static Connection getConnection() {
        lastConnectionError = "";
        boolean anyProduction = false;

        for (DbConfig config : resolveAllConfigs()) {
            anyProduction = anyProduction || config.production;
            logConfigOnce(config);
            Connection connection = tryDirectConnection(config);
            if (connection != null) {
                return connection;
            }
        }

        Connection connection = tryJndiConnection();
        if (connection != null) {
            return connection;
        }

        if (!anyProduction) {
            connection = tryLocalDevFallback();
            if (connection != null) {
                return connection;
            }
        }

        System.err.println("DBConnection: all connection methods failed. lastError=" + lastConnectionError);
        return null;
    }

    public static boolean canConnect() {
        Connection conn = getConnection();
        if (conn == null) {
            return false;
        }
        closeConnection(conn);
        return true;
    }

    public static String getConfigSource() {
        List<DbConfig> configs = resolveAllConfigs();
        return configs.isEmpty() ? "none" : configs.get(0).source;
    }

    public static String getConfigHost() {
        List<DbConfig> configs = resolveAllConfigs();
        return configs.isEmpty() ? "(none)" : safeJdbcHost(configs.get(0).url);
    }

    public static boolean isProductionConfig() {
        for (DbConfig config : resolveAllConfigs()) {
            if (config.production) {
                return true;
            }
        }
        return false;
    }

    public static String getLastConnectionError() {
        return lastConnectionError != null ? lastConnectionError : "";
    }

    public static boolean hasDeployCredentialFiles() {
        return Files.isRegularFile(DEPLOY_URL_FILE);
    }

    private static void logConfigOnce(DbConfig config) {
        if (LOGGED_CONFIG.compareAndSet(false, true)) {
            System.out.println(
                "DBConnection initialized: source=" + config.source
                    + ", production=" + config.production
                    + ", user=" + safeUser(config.user)
                    + ", jdbcHost=" + safeJdbcHost(config.url)
                    + ", deployFiles=" + hasDeployCredentialFiles()
            );
        }
    }

    private static Connection tryDirectConnection(DbConfig config) {
        if (config.url == null || config.url.isEmpty()) {
            lastConnectionError = "JDBC URL is empty for " + config.source;
            return null;
        }
        try {
            Class.forName(DB_DRIVER);
            Connection connection = DriverManager.getConnection(config.url, config.user, config.password);
            System.out.println("Database connection established (" + config.source + ").");
            return connection;
        } catch (ClassNotFoundException e) {
            lastConnectionError = "MySQL JDBC Driver not found: " + e.getMessage();
            System.err.println(lastConnectionError);
        } catch (SQLException e) {
            lastConnectionError = config.source + ": " + e.getMessage();
            System.err.println("Database connection failed (" + config.source + "): " + e.getMessage());
            System.err.println("JDBC user=" + safeUser(config.user) + ", url host=" + safeJdbcHost(config.url));
        }
        return null;
    }

    private static Connection tryJndiConnection() {
        try {
            InitialContext ic = new InitialContext();
            DataSource ds = (DataSource) ic.lookup(JNDI_NAME);
            if (ds != null) {
                Connection connection = ds.getConnection();
                System.out.println("Database connection obtained from JNDI DataSource.");
                return connection;
            }
        } catch (NamingException ne) {
            System.out.println("JNDI DataSource not available: " + ne.getMessage());
        } catch (SQLException dsEx) {
            lastConnectionError = "JNDI: " + dsEx.getMessage();
            System.err.println("JNDI DataSource getConnection() failed: " + dsEx.getMessage());
        }
        return null;
    }

    private static Connection tryLocalDevFallback() {
        String localUrl = "jdbc:mysql://127.0.0.1:3306/talaqqihub_db"
            + "?useSSL=false&serverTimezone=UTC&connectTimeout=5000&socketTimeout=10000&allowPublicKeyRetrieval=true";

        try {
            Connection connection = DriverManager.getConnection(localUrl, "root", "admin");
            System.out.println("Database connection established using local XAMPP fallback (root/admin).");
            return connection;
        } catch (SQLException firstEx) {
            System.err.println("Local fallback (root/admin) failed: " + firstEx.getMessage());
        }

        try {
            Connection connection = DriverManager.getConnection(localUrl, "root", "");
            System.out.println("Database connection established using local XAMPP fallback (root/empty).");
            return connection;
        } catch (SQLException secondEx) {
            lastConnectionError = "local fallback: " + secondEx.getMessage();
            System.err.println("Local fallback (root/empty) failed: " + secondEx.getMessage());
        }

        return null;
    }

    private static List<DbConfig> resolveAllConfigs() {
        List<DbConfig> configs = new ArrayList<>();
        Set<String> seen = new LinkedHashSet<>();

        // DATABASE_URL from attached MySQL service has correct Aiven credentials (avnadmin).
        // Kerocket manual DB_USER is often wrong (e.g. 'kerocket') — try service URL first.
        String databaseUrl = firstNonEmpty(getenv("DATABASE_URL"), getProperty("DATABASE_URL"));
        if (databaseUrl != null) {
            addConfig(configs, seen, parseDatabaseUrl(databaseUrl));
        }

        addConfig(configs, seen, buildMergedDbUrlConfig(databaseUrl));

        addConfig(configs, seen, loadFromDeployCredentialFiles());
        addConfig(configs, seen, loadFromDeployPropertiesFile());

        String dbUrl = firstNonEmpty(getenv("DB_URL"), getProperty("DB_URL"));
        String dbUser = credentialsUser();
        String dbPassword = credentialsPassword();
        if (dbUrl != null) {
            addConfig(configs, seen, new DbConfig(
                ensureJdbcParams(dbUrl),
                dbUser != null ? dbUser : "root",
                dbPassword != null ? dbPassword : "",
                true,
                "env:DB_URL"
            ));
        }

        String mysqlHost = firstNonEmpty(
            getenv("MYSQLHOST"), getProperty("MYSQLHOST"),
            getenv("MYSQL_HOST"), getProperty("MYSQL_HOST")
        );
        if (mysqlHost != null) {
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
            addConfig(configs, seen, new DbConfig(
                url,
                dbUser != null ? dbUser : "root",
                dbPassword != null ? dbPassword : "",
                true,
                "env:MYSQLHOST"
            ));
        }

        addConfig(configs, seen, new DbConfig(
            "jdbc:mysql://127.0.0.1:3306/talaqqihub_db"
                + "?useSSL=false&serverTimezone=UTC&connectTimeout=5000&socketTimeout=10000&allowPublicKeyRetrieval=true",
            "root",
            "admin",
            false,
            "local-default"
        ));

        return configs;
    }

    /** DB_URL for database/host + DATABASE_URL for Aiven credentials (avnadmin). */
    private static DbConfig buildMergedDbUrlConfig(String databaseUrl) {
        String dbUrl = firstNonEmpty(getenv("DB_URL"), getProperty("DB_URL"));
        if (dbUrl == null || databaseUrl == null) {
            return null;
        }
        DbConfig service = parseDatabaseUrl(databaseUrl);
        if (service == null || service.user == null || service.user.isEmpty()) {
            return null;
        }
        return new DbConfig(
            ensureJdbcParams(dbUrl),
            service.user,
            service.password != null ? service.password : "",
            true,
            "merged:DB_URL+DATABASE_URL"
        );
    }

    private static void addConfig(List<DbConfig> configs, Set<String> seen, DbConfig config) {
        if (config == null || config.url == null || config.url.isEmpty()) {
            return;
        }
        String key = config.key();
        if (seen.add(key)) {
            configs.add(config);
        }
    }

    private static DbConfig loadFromDeployCredentialFiles() {
        if (!Files.isRegularFile(DEPLOY_URL_FILE)) {
            return null;
        }
        try {
            String url = readSecretFile(DEPLOY_URL_FILE);
            if (url == null || url.isEmpty()) {
                return null;
            }
            String user = readSecretFile(DEPLOY_USER_FILE);
            String password = readSecretFile(DEPLOY_PASSWORD_FILE);
            return new DbConfig(
                ensureJdbcParams(url),
                user != null ? user : "",
                password != null ? password : "",
                true,
                "file:jdbc-credentials"
            );
        } catch (Exception e) {
            System.err.println("Failed to read deploy JDBC credential files: " + e.getMessage());
            return null;
        }
    }

    private static String readSecretFile(Path path) throws Exception {
        if (!Files.isRegularFile(path)) {
            return "";
        }
        return Files.readString(path, StandardCharsets.UTF_8).trim();
    }

    private static DbConfig loadFromDeployPropertiesFile() {
        if (!Files.isRegularFile(DEPLOY_PROPERTIES)) {
            return null;
        }
        try {
            Properties props = new Properties();
            try (Reader reader = Files.newBufferedReader(DEPLOY_PROPERTIES, StandardCharsets.UTF_8)) {
                props.load(reader);
            }

            String url = decodePropertyValue(props, "db.url.b64", "db.url");
            if (url == null || url.isEmpty()) {
                return null;
            }

            String user = decodePropertyValue(props, "db.user.b64", "db.user");
            String password = decodePropertyValue(props, "db.password.b64", "db.password");
            return new DbConfig(
                ensureJdbcParams(url),
                user != null ? user : "",
                password != null ? password : "",
                true,
                "file:properties"
            );
        } catch (Exception e) {
            System.err.println("Failed to read deploy DB properties: " + e.getMessage());
            return null;
        }
    }

    private static String decodePropertyValue(Properties props, String b64Key, String plainKey) {
        String b64 = props.getProperty(b64Key);
        if (b64 != null && !b64.trim().isEmpty()) {
            try {
                return new String(Base64.getDecoder().decode(b64.trim()), StandardCharsets.UTF_8);
            } catch (IllegalArgumentException ignored) {
                // Fall through to plain key.
            }
        }
        return props.getProperty(plainKey);
    }

    private static String credentialsUser() {
        return firstNonEmpty(
            getenv("DB_USER"), getProperty("DB_USER"),
            getenv("MYSQLUSER"), getProperty("MYSQLUSER"),
            getenv("MYSQL_USER"), getProperty("MYSQL_USER")
        );
    }

    private static String credentialsPassword() {
        return firstNonEmpty(
            getenv("DB_PASSWORD"), getProperty("DB_PASSWORD"),
            getenv("MYSQLPASSWORD"), getProperty("MYSQLPASSWORD"),
            getenv("MYSQL_PASSWORD"), getProperty("MYSQL_PASSWORD")
        );
    }

    private static DbConfig parseDatabaseUrl(String databaseUrl) {
        String raw = databaseUrl.trim();
        if (raw.isEmpty()) {
            return null;
        }

        if (raw.startsWith("jdbc:mysql://") || raw.startsWith("jdbc:mariadb://")) {
            ParsedUrl parsed = parseJdbcUrl(raw);
            if (parsed == null) {
                return null;
            }
            String user = firstNonEmpty(parsed.user, credentialsUser());
            String password = firstNonEmpty(parsed.password, credentialsPassword());
            return new DbConfig(ensureJdbcParams(parsed.jdbcUrl), user, password, true, "env:DATABASE_URL(jdbc)");
        }

        if (raw.startsWith("mysql://") || raw.startsWith("mariadb://")) {
            ParsedUrl parsed = parseMySqlSchemeUrl(raw);
            if (parsed == null) {
                return null;
            }
            return new DbConfig(
                ensureJdbcParams(parsed.jdbcUrl),
                parsed.user,
                parsed.password,
                true,
                "env:DATABASE_URL(mysql)"
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
            System.err.println("Failed to parse DATABASE_URL: " + e.getMessage());
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
            System.err.println("Failed to parse JDBC DATABASE_URL: " + e.getMessage());
            return null;
        }
    }

    private static String ensureJdbcParams(String jdbcUrl) {
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

    private static String decode(String value) {
        try {
            return URLDecoder.decode(value, StandardCharsets.UTF_8.name());
        } catch (Exception e) {
            return value;
        }
    }

    private static String safeUser(String user) {
        return user == null || user.isEmpty() ? "(empty)" : user;
    }

    private static String safeJdbcHost(String jdbcUrl) {
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

    public static void closeConnection(Connection connection) {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                System.err.println("Error closing database connection: " + e.getMessage());
            }
        }
    }

    public static void main(String[] args) {
        Connection conn = getConnection();
        if (conn != null) {
            System.out.println("Connection test PASSED.");
            closeConnection(conn);
        } else {
            System.out.println("Connection test FAILED: " + getLastConnectionError());
        }
    }
}
