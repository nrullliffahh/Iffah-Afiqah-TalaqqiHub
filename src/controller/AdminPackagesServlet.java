package controller;

import dao.PackageDAO;
import model.Package;
import util.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class AdminPackagesServlet extends HttpServlet {

    private PackageDAO packageDAO;

    @Override
    public void init() {
        packageDAO = new PackageDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Package> packages = packageDAO.getAllPackages();
        request.setAttribute("packages", packages);
        // dynamically select top 4 packages and their student counts
        List<Map<String,Object>> topPackages = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn != null) {
                // get top 5 packages (ordered by packageName)
                String sqlTop = "SELECT packageId, packageName FROM packages ORDER BY packageName LIMIT 5";
                pstmt = conn.prepareStatement(sqlTop);
                rs = pstmt.executeQuery();
                List<String> ids = new ArrayList<>();
                while (rs.next()) {
                    String pid = rs.getString("packageId");
                    String pname = rs.getString("packageName");
                    Map<String,Object> m = new HashMap<>();
                    m.put("id", pid);
                    m.put("name", pname != null ? pname : pid);
                    m.put("count", 0);
                    topPackages.add(m);
                    if (pid != null) ids.add(pid);
                }
                try { rs.close(); } catch (Exception ignore) {}
                try { pstmt.close(); } catch (Exception ignore) {}

                if (!ids.isEmpty()) {
                    // build placeholders
                    StringBuilder ph = new StringBuilder();
                    for (int i = 0; i < ids.size(); i++) {
                        if (i > 0) ph.append(',');
                        ph.append('?');
                    }
                    String sqlCounts = "SELECT packageId, COUNT(*) AS cnt FROM student WHERE packageId IN (" + ph.toString() + ") GROUP BY packageId";
                    pstmt = conn.prepareStatement(sqlCounts);
                    for (int i = 0; i < ids.size(); i++) pstmt.setString(i+1, ids.get(i));
                    rs = pstmt.executeQuery();
                    while (rs.next()) {
                        String pid = rs.getString("packageId");
                        int cnt = rs.getInt("cnt");
                        for (Map<String,Object> m : topPackages) {
                            if (pid != null && pid.equals(m.get("id"))) {
                                m.put("count", cnt);
                                break;
                            }
                        }
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
            try { if (pstmt != null) pstmt.close(); } catch (SQLException ignored) {}
            try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
        }

        request.setAttribute("topPackages", topPackages);
        request.getRequestDispatcher("/WEB-INF/views/adminManagePackages.jsp").forward(request, response);
    }
}
