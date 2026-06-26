package controller;

import util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * DB diagnostic servlet.
 * GET /admin/packages/dbcheck
 */
public class AdminPackageDbCheckServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");

        String source = DBConnection.getConfigSource();
        String host = DBConnection.getConfigHost();
        String database = DBConnection.getConfigDatabase();
        boolean production = DBConnection.isProductionConfig();

        Connection conn = null;
        Statement stmt = null;
        ResultSet md = null;
        ResultSet countRs = null;
        PrintWriter out = response.getWriter();

        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                writeJson(out, false, source, host, database, production, -1, false, null,
                    DBConnection.getLastConnectionError().isEmpty()
                        ? "Database connection is null"
                        : DBConnection.getLastConnectionError());
                return;
            }

            boolean hasPopular = false;
            String foundColumn = null;
            try {
                md = conn.getMetaData().getColumns(null, null, "packages", null);
                while (md.next()) {
                    String col = md.getString("COLUMN_NAME");
                    if (col == null) {
                        continue;
                    }
                    String lower = col.toLowerCase();
                    if ("popular".equals(lower) || "ispopular".equals(lower)) {
                        hasPopular = true;
                        foundColumn = col;
                        break;
                    }
                }
            } catch (SQLException ignored) {
                // packages table may not exist yet
            } finally {
                if (md != null) {
                    try {
                        md.close();
                    } catch (SQLException ignored) {
                    }
                }
            }

            int studentCount = -1;
            try {
                stmt = conn.createStatement();
                countRs = stmt.executeQuery("SELECT COUNT(*) AS cnt FROM student");
                if (countRs.next()) {
                    studentCount = countRs.getInt("cnt");
                }
            } catch (SQLException e) {
                writeJson(out, false, source, host, database, production, -1, hasPopular, foundColumn,
                    "Connected but student table missing or unreadable: " + e.getMessage());
                return;
            }

            String message = studentCount == 0
                ? "Connected but student table is empty — import db/talaqqihub_backup.sql"
                : "OK";
            writeJson(out, true, source, host, database, production, studentCount, hasPopular, foundColumn, message);

        } finally {
            try {
                if (countRs != null) {
                    countRs.close();
                }
                if (stmt != null) {
                    stmt.close();
                }
            } catch (SQLException ignored) {
            }
            DBConnection.closeConnection(conn);
        }
    }

    private static void writeJson(
        PrintWriter out,
        boolean ok,
        String source,
        String host,
        String database,
        boolean production,
        int studentCount,
        boolean hasPopular,
        String popularColumn,
        String message
    ) {
        out.print("{\"ok\":");
        out.print(ok);
        out.print(",\"source\":\"");
        out.print(escapeJson(source));
        out.print("\",\"host\":\"");
        out.print(escapeJson(host));
        out.print("\",\"database\":\"");
        out.print(escapeJson(database));
        out.print("\",\"production\":");
        out.print(production);
        out.print(",\"studentCount\":");
        out.print(studentCount);
        out.print(",\"hasPopular\":");
        out.print(hasPopular);
        if (popularColumn != null) {
            out.print(",\"popularColumn\":\"");
            out.print(escapeJson(popularColumn));
            out.print("\"");
        }
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
