package util;

import java.sql.Connection;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

/**
 * Logs database connectivity when the webapp starts on Kerocket/Tomcat.
 * Uses util.DBConnection — there is only ONE database connection class in this project.
 */
public class DbStartupListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        boolean deployFiles = DBConnection.hasDeployCredentialFiles();
        System.out.println(
            "DbStartupListener: deployCredentialFiles=" + deployFiles
                + ", configSource=" + DBConnection.getConfigSource()
                + ", host=" + DBConnection.getConfigHost()
                + ", database=" + DBConnection.getConfigDatabase()
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
