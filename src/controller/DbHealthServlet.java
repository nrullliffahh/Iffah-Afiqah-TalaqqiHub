package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import util.DBConnection;

/**
 * Diagnostic endpoint for Kerocket/production — check DB connectivity without logging in.
 * Mapped in WEB-INF/web.xml: /api/db-health and /health/db
 */
public class DbHealthServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");

        String source = DBConnection.getConfigSource();
        String host = DBConnection.getConfigHost();
        boolean production = DBConnection.isProductionConfig();

        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                writeJson(response.getWriter(), false, source, host, production, -1,
                    DBConnection.getLastConnectionError().isEmpty()
                        ? "Database connection is null"
                        : DBConnection.getLastConnectionError());
                return;
            }

            stmt = conn.createStatement();
            rs = stmt.executeQuery("SELECT COUNT(*) AS cnt FROM student");
            int studentCount = rs.next() ? rs.getInt("cnt") : 0;

            writeJson(
                response.getWriter(),
                true,
                source,
                host,
                production,
                studentCount,
                studentCount == 0
                    ? "Connected but student table is empty — import db/talaqqihub_backup.sql into Aiven"
                    : "OK"
            );
        } catch (Exception e) {
            writeJson(
                response.getWriter(),
                false,
                source,
                host,
                production,
                -1,
                e.getMessage() != null ? e.getMessage() : e.getClass().getSimpleName()
            );
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (stmt != null) {
                    stmt.close();
                }
            } catch (Exception ignored) {
                // ignore
            }
            DBConnection.closeConnection(conn);
        }
    }

    private static void writeJson(
        PrintWriter out,
        boolean ok,
        String source,
        String host,
        boolean production,
        int studentCount,
        String message
    ) {
        out.print("{\"ok\":");
        out.print(ok);
        out.print(",\"source\":\"");
        out.print(escapeJson(source));
        out.print("\",\"host\":\"");
        out.print(escapeJson(host));
        out.print("\",\"production\":");
        out.print(production);
        out.print(",\"studentCount\":");
        out.print(studentCount);
        out.print(",\"message\":\"");
        out.print(escapeJson(message));
        out.print("\"}");
    }

    private static String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value
            .replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\n", "\\n")
            .replace("\r", "\\r");
    }
}
