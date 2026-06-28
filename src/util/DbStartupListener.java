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
        // Kerocket injects manual env file into JVM here — not always into docker-entrypoint.sh.
        JdbcCredentialLoader.logJvmEnvPresence();
        JdbcCredentialLoader.materializeDeployFilesFromJvmEnv();

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
            TalaqqiSchemaUtil.ensureClassAyahEndColumn(conn);
            TalaqqiSchemaUtil.ensureQuranDisplayAyahEndColumn(conn);
            System.out.println("DbStartupListener: talaqqi session table="
                + TalaqqiSchemaUtil.sessionTable(conn)
                + ", link="
                + (TalaqqiSchemaUtil.usesBookingIdLink(conn) ? "bookingId" : "scheduleId")
                + ", timing="
                + (TalaqqiSchemaUtil.hasSessionTimingColumns(conn) ? "yes" : "no")
                + ", classAyahEnd="
                + (TalaqqiSchemaUtil.hasClassAyahEnd(conn) ? "yes" : "no"));
            DBConnection.closeConnection(conn);
        } else {
            System.err.println(
                "DbStartupListener: database connection FAILED. lastError="
                    + DBConnection.getLastConnectionError()
                    + " — embed avnadmin:PASSWORD in DB_URL if Kerocket does not inject DB_USER/DB_PASSWORD."
            );
        }
        JitsiConfig.logStartupConfig();
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // no-op
    }
}
