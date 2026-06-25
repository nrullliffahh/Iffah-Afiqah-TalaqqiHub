package util;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.Connection;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

/**
 * Logs database connectivity when the webapp starts on Kerocket/Tomcat.
 */
public class DbStartupListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        boolean deployFiles = Files.isRegularFile(Paths.get("/usr/local/tomcat/conf/db.jdbc.url"));
        System.out.println(
            "DbStartupListener: deployCredentialFiles=" + deployFiles
                + ", configSource=" + DBConnection.getConfigSource()
                + ", host=" + DBConnection.getConfigHost()
                + ", production=" + DBConnection.isProductionConfig()
        );

        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            System.out.println("DbStartupListener: database connection OK at startup.");
            DBConnection.closeConnection(conn);
        } else {
            System.err.println(
                "DbStartupListener: database connection FAILED at startup. lastError="
                    + DBConnection.getLastConnectionError()
            );
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // no-op
    }
}
