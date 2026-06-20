package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

/**
 * DBConnection Utility Class
 * 
 * This class provides a static method to establish and manage MySQL database connections
 * for the TalaqqiHub application.
 * 
 * Database Details:
 * - Database: talaqqihub_db
 * - Host: 127.0.0.1
 * - Port: 3306
 * - Username: root
 * - Password: admin (override via DB_PASSWORD env var)
 * - Driver: com.mysql.cj.jdbc.Driver
 * 
 * Usage:
 * Connection conn = DBConnection.getConnection();
 * if (conn != null) {
 *     // Use connection
 * } else {
 *     // Handle connection failure
 * }
 */
public class DBConnection {
    
    // Database connection parameters (can be overridden with environment variables or system properties)
    private static final String DB_DRIVER = "com.mysql.cj.jdbc.Driver";
    // Force IPv4 (127.0.0.1) and add connect/socket timeouts to avoid ETIMEDOUT when localhost resolves to ::1
    // Use IPv4 and reasonable connect/socket timeouts. Removed autoReconnect to avoid hidden retry loops.
    private static final String DB_URL = getEnvOrProperty("DB_URL", "jdbc:mysql://127.0.0.1:3306/talaqqihub_db?useSSL=false&serverTimezone=Asia/Kuala_Lumpur&connectTimeout=5000&socketTimeout=10000");
    private static final String DB_USER = getEnvOrProperty("DB_USER", "root");
    // Default to local XAMPP password for developer convenience (override with env/system property)
    private static final String DB_PASSWORD = getEnvOrProperty("DB_PASSWORD", "admin");
    
    /**
     * Establishes and returns a connection to the MySQL database.
     * 
     * This method:
     * 1. Loads the MySQL JDBC driver
     * 2. Attempts to create a connection to the database
     * 3. Returns the connection on success, null on failure
     * 4. Logs exceptions for debugging purposes
     * 
     * @return Connection object if successful, null if connection fails
     */
    public static Connection getConnection() {
        Connection connection = null;
        // First, try to obtain a pooled Connection via JNDI DataSource (preferred)
        try {
            InitialContext ic = new InitialContext();
            DataSource ds = (DataSource) ic.lookup("java:comp/env/jdbc/TalaqqiHubDB");
            if (ds != null) {
                try {
                    connection = ds.getConnection();
                    System.out.println("Database connection obtained from JNDI DataSource.");
                    return connection;
                } catch (SQLException dsEx) {
                    System.err.println("JNDI DataSource lookup succeeded but getConnection() failed: " + dsEx.getMessage());
                }
            }
        } catch (NamingException ne) {
            // JNDI not configured for this webapp or resource not present; fall through to DriverManager
            System.out.println("JNDI DataSource not available: " + ne.getMessage());
        }
        try {
            // Load MySQL JDBC Driver
            Class.forName(DB_DRIVER);

            // First attempt: configured credentials (may be empty)
            try {
                connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                System.out.println("Database connection established successfully using configured credentials.");
                return connection;
            } catch (SQLException firstEx) {
                System.err.println("Primary DB connection attempt failed: " + firstEx.getMessage());
            }

            // Quick fallback: try 'root' with empty password (common local XAMPP setup)
            try {
                connection = DriverManager.getConnection(DB_URL, "root", "");
                System.out.println("Database connection established using 'root' with empty password fallback.");
                return connection;
            } catch (SQLException e) {
                System.err.println("Quick fallback (root, empty password) failed: " + e.getMessage());
            }

            // If we reach here, fail fast and log a concise error for operators to fix credentials/DB.
            throw new SQLException("DB connection failed. Check MySQL is running and DB_URL/DB_USER/DB_PASSWORD are correct.");

        } catch (ClassNotFoundException e) {
            // Driver not found in classpath
            System.err.println("MySQL JDBC Driver not found. Make sure mysql-connector-java JAR is in classpath.");
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        } catch (SQLException e) {
            // Database connection failed after all attempts
            System.err.println("Failed to establish database connection after all attempts.");
            System.err.println("Error: " + e.getMessage());
            System.err.println("DB_URL=" + DB_URL + ", DB_USER=" + DB_USER + ", DB_PASSWORD set? " + (!DB_PASSWORD.isEmpty()));
            e.printStackTrace();
        }
        
        return connection;
    }

    /**
     * Helper to read value from environment variable or system property, with a default.
     */
    private static String getEnvOrProperty(String key, String defaultValue) {
        String v = System.getenv(key);
        if (v != null) {
            v = v.trim();
            if (!v.isEmpty()) return v;
        }
        v = System.getProperty(key);
        if (v != null) {
            v = v.trim();
            if (!v.isEmpty()) return v;
        }
        return defaultValue;
    }
    
    /**
     * Closes a database connection safely.
     * 
     * @param connection The Connection object to close
     */
    public static void closeConnection(Connection connection) {
        if (connection != null) {
            try {
                connection.close();
                System.out.println("Database connection closed.");
            } catch (SQLException e) {
                System.err.println("Error closing database connection: " + e.getMessage());
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Main method for testing the database connection.
     * Run this to verify that the database connection is working properly.
     * 
     * @param args Command line arguments (not used)
     */
    public static void main(String[] args) {
        Connection conn = getConnection();
        
        if (conn != null) {
            System.out.println("\n✓ Connection test PASSED!");
            System.out.println("Database: talaqqihub_db is accessible.");
            closeConnection(conn);
        } else {
            System.out.println("\n✗ Connection test FAILED!");
            System.out.println("Please verify database credentials and MySQL server status.");
        }
    }
}

