package util;

import java.net.URI;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

/**
 * Database connections for TalaqqiHub.
 *
 * Resolution order:
 * 1. JNDI DataSource (java:comp/env/jdbc/TalaqqiHubDB) — used on Kerocket/Tomcat with docker-entrypoint.sh
 * 2. DATABASE_URL environment variable (mysql:// or jdbc:mysql://)
 * 3. DB_URL / DB_USER / DB_PASSWORD or MYSQLHOST / MYSQLUSER / MYSQLPASSWORD / MYSQLDATABASE
 * 4. Local XAMPP defaults for development only
 */
public class DBConnection {

    private static final String DB_DRIVER = "com.mysql.cj.jdbc.Driver";
    private static final String JNDI_NAME = "java:comp/env/jdbc/TalaqqiHubDB";
    private static final String JDBC_SUFFIX =
            "?useSSL=false&serverTimezone=UTC&connectTimeout=5000&socketTimeout=10000&allowPublicKeyRetrieval=true";

    private static final DbConfig CONFIG = resolveConfig();

    private static final class DbConfig {
        final String url;
        final String user;
        final String password;
        final boolean production;

        DbConfig(String url, String user, String password, boolean production) {
            this.url = url;
            this.user = user != null ? user : "";
            this.password = password != null ? password : "";
            this.production = production;
        }
    }

    public static Connection getConnection() {
        Connection connection = tryJndiConnection();
        if (connection != null) {
            return connection;
        }

        try {
            Class.forName(DB_DRIVER);
            connection = DriverManager.getConnection(CONFIG.url, CONFIG.user, CONFIG.password);
            System.out.println("Database connection established using environment configuration.");
            return connection;
        } catch (ClassNotFoundException e) {
            System.err.println("MySQL JDBC Driver not found: " + e.getMessage());
            e.printStackTrace();
        } catch (SQLException e) {
            System.err.println("Database connection failed: " + e.getMessage());
            System.err.println("Configured host/database from env; user=" + safeUser(CONFIG.user));
            e.printStackTrace();

            if (!CONFIG.production) {
                connection = tryLocalDevFallback();
            }
        }

        return connection;
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
            System.err.println("JNDI DataSource getConnection() failed: " + dsEx.getMessage());
        }
        return null;
    }

    private static Connection tryLocalDevFallback() {
        String localUrl = "jdbc:mysql://127.0.0.1:3306/talaqqihub_db" + JDBC_SUFFIX;

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
            System.err.println("Local fallback (root/empty) failed: " + secondEx.getMessage());
        }

        return null;
    }

    private static DbConfig resolveConfig() {
        // Prefer explicit Deploy-tab JDBC vars (e.g. Aiven DB_URL with sslMode=REQUIRED).
        String dbUrl = firstNonEmpty(getenv("DB_URL"), getProperty("DB_URL"));
        String dbUser = firstNonEmpty(
                getenv("DB_USER"), getProperty("DB_USER"),
                getenv("MYSQLUSER"), getProperty("MYSQLUSER"),
                getenv("MYSQL_USER"), getProperty("MYSQL_USER")
        );
        String dbPassword = firstNonEmpty(
                getenv("DB_PASSWORD"), getProperty("DB_PASSWORD"),
                getenv("MYSQLPASSWORD"), getProperty("MYSQLPASSWORD"),
                getenv("MYSQL_PASSWORD"), getProperty("MYSQL_PASSWORD")
        );
        if (dbUrl != null) {
            return new DbConfig(ensureJdbcParams(dbUrl), dbUser != null ? dbUser : "root", dbPassword != null ? dbPassword : "", true);
        }

        String databaseUrl = firstNonEmpty(
                getenv("DATABASE_URL"),
                getProperty("DATABASE_URL")
        );

        if (databaseUrl != null) {
            DbConfig parsed = parseDatabaseUrl(databaseUrl);
            if (parsed != null) {
                return parsed;
            }
        }

        String mysqlHost = firstNonEmpty(getenv("MYSQLHOST"), getProperty("MYSQLHOST"), getenv("MYSQL_HOST"), getProperty("MYSQL_HOST"));
        String mysqlDatabase = firstNonEmpty(
                getenv("MYSQLDATABASE"), getProperty("MYSQLDATABASE"),
                getenv("MYSQL_DATABASE"), getProperty("MYSQL_DATABASE"),
                "talaqqihub_db"
        );

        if (mysqlHost != null) {
            String port = firstNonEmpty(getenv("MYSQLPORT"), getProperty("MYSQLPORT"), getenv("MYSQL_PORT"), getProperty("MYSQL_PORT"), "3306");
            String url = "jdbc:mysql://" + mysqlHost + ":" + port + "/" + mysqlDatabase + JDBC_SUFFIX;
            return new DbConfig(url, dbUser != null ? dbUser : "root", dbPassword != null ? dbPassword : "", true);
        }

        return new DbConfig(
                "jdbc:mysql://127.0.0.1:3306/talaqqihub_db" + JDBC_SUFFIX,
                "root",
                "admin",
                false
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
            String user = firstNonEmpty(
                    parsed.user,
                    getenv("DB_USER"), getProperty("DB_USER"),
                    getenv("MYSQLUSER"), getProperty("MYSQLUSER"),
                    getenv("MYSQL_USER"), getProperty("MYSQL_USER")
            );
            String password = firstNonEmpty(
                    parsed.password,
                    getenv("DB_PASSWORD"), getProperty("DB_PASSWORD"),
                    getenv("MYSQLPASSWORD"), getProperty("MYSQLPASSWORD"),
                    getenv("MYSQL_PASSWORD"), getProperty("MYSQL_PASSWORD")
            );
            return new DbConfig(ensureJdbcParams(parsed.jdbcUrl), user, password, true);
        }

        if (raw.startsWith("mysql://") || raw.startsWith("mariadb://")) {
            ParsedUrl parsed = parseMySqlSchemeUrl(raw);
            if (parsed == null) {
                return null;
            }
            return new DbConfig(ensureJdbcParams(parsed.jdbcUrl), parsed.user, parsed.password, true);
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
            String jdbcUrl = "jdbc:mysql://" + host + ":" + port + "/" + database;
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
        if (jdbcUrl.contains("connectTimeout=") || jdbcUrl.contains("socketTimeout=")) {
            return jdbcUrl;
        }
        return jdbcUrl + (jdbcUrl.contains("?") ? "&" : "?") + JDBC_SUFFIX.substring(1);
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
            System.out.println("Connection test FAILED.");
        }
    }
}
