package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import util.JdbcCredentialLoader.CredentialConfig;

/**
 * Opens JDBC connections using configs from {@link JdbcCredentialLoader}.
 */
public class DBConnection {

    private static final String DB_DRIVER = "com.mysql.cj.jdbc.Driver";
    private static final String JNDI_NAME = "java:comp/env/jdbc/TalaqqiHubDB";
    private static final AtomicBoolean LOGGED_CONFIG = new AtomicBoolean(false);
    private static volatile String lastConnectionError = "";

    public static Connection getConnection() {
        lastConnectionError = "";
        boolean anyProduction = false;

        for (CredentialConfig config : JdbcCredentialLoader.loadAll()) {
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
        List<CredentialConfig> configs = JdbcCredentialLoader.loadAll();
        return configs.isEmpty() ? "none" : configs.get(0).source;
    }

    public static String getConfigHost() {
        List<CredentialConfig> configs = JdbcCredentialLoader.loadAll();
        return configs.isEmpty() ? "(none)" : JdbcCredentialLoader.safeJdbcHost(configs.get(0).url);
    }

    public static String getConfigDatabase() {
        List<CredentialConfig> configs = JdbcCredentialLoader.loadAll();
        return configs.isEmpty() ? "(none)" : JdbcCredentialLoader.safeJdbcDatabase(configs.get(0).url);
    }

    public static boolean isProductionConfig() {
        for (CredentialConfig config : JdbcCredentialLoader.loadAll()) {
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
        return JdbcCredentialLoader.hasDeployCredentialFiles();
    }

    private static void logConfigOnce(CredentialConfig config) {
        if (LOGGED_CONFIG.compareAndSet(false, true)) {
            System.out.println(
                "DBConnection initialized: source=" + config.source
                    + ", production=" + config.production
                    + ", user=" + safeUser(config.user)
                    + ", jdbcHost=" + JdbcCredentialLoader.safeJdbcHost(config.url)
                    + ", database=" + JdbcCredentialLoader.safeJdbcDatabase(config.url)
                    + ", deployFiles=" + hasDeployCredentialFiles()
            );
        }
    }

    private static Connection tryDirectConnection(CredentialConfig config) {
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
            System.err.println(
                "JDBC user=" + safeUser(config.user)
                    + ", url host=" + JdbcCredentialLoader.safeJdbcHost(config.url)
                    + ", database=" + JdbcCredentialLoader.safeJdbcDatabase(config.url)
            );
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

    private static String safeUser(String user) {
        return user == null || user.isEmpty() ? "(empty)" : user;
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
