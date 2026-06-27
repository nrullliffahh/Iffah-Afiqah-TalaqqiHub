package util;

import java.sql.Connection;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

/**
 * Startup diagnostic — delegates to {@link JdbcCredentialLoader} + {@link DBConnection}.
 */
public class DbStartupListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println(
            "DbStartupListener: deployCredentialFiles=" + JdbcCredentialLoader.hasDeployCredentialFiles()
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
                "DbStartupListener: database connection FAILED. lastError="
                    + DBConnection.getLastConnectionError()
                    + " — set DB_USER=avnadmin and DB_PASSWORD in Kerocket Deploy tab."
            );
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // no-op
    }
}
