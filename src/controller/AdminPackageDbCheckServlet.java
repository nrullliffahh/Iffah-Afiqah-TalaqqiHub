package controller;

import util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Small diagnostic servlet to check whether the `packages` table has a `popular` (or `isPopular`) column.
 * Call: GET /admin/packages/dbcheck
 * Returns JSON: {"hasPopular":true,"column":"popular"}
 */
public class AdminPackageDbCheckServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        Connection conn = null;
        ResultSet md = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\":\"db connection failed\"}");
                return;
            }

            boolean hasPopular = false;
            String foundColumn = null;
            try {
                md = conn.getMetaData().getColumns(null, null, "packages", null);
                while (md.next()) {
                    String col = md.getString("COLUMN_NAME");
                    if (col == null) continue;
                    String lower = col.toLowerCase();
                    if ("popular".equals(lower) || "ispopular".equals(lower)) {
                        hasPopular = true;
                        foundColumn = col;
                        break;
                    }
                }
            } catch (SQLException e) {
                // ignore and return no
            } finally {
                try { if (md != null) md.close(); } catch (SQLException ignored) {}
            }

            StringBuilder sb = new StringBuilder();
            sb.append('{');
            sb.append("\"hasPopular\":").append(hasPopular ? "true" : "false");
            if (foundColumn != null) sb.append(",\"column\":\"").append(foundColumn).append("\"");
            sb.append('}');
            response.getWriter().write(sb.toString());

        } finally {
            try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
        }
    }
}
