package dao;

import model.Package;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class PackageDAO {

    public List<Package> getAllPackages() {
        List<Package> packages = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.err.println("PackageDAO.getAllPackages: DB connection is null.");
                return packages;
            }
            // Discover actual column names in the packages table so we can support
            // both `ageRange` and `rangeAge` (or other casing) and gracefully
            // include optional columns when present.
            java.util.Map<String, String> cols = new java.util.HashMap<>();
            try (ResultSet md = conn.getMetaData().getColumns(null, null, "packages", null)) {
                while (md.next()) {
                    String col = md.getString("COLUMN_NAME");
                    if (col != null) cols.put(col.toLowerCase(), col);
                }
            } catch (SQLException ignore) {}

            // Build SELECT using the actual column names found.
            StringBuilder select = new StringBuilder();
            select.append("SELECT packageId, packageName, packageType, totalSessions");
            String priceCol = cols.get("price");
            String durationCol = cols.get("durationpersession");
            String descCol = cols.get("description");
            String ageCol = cols.containsKey("agerange") ? cols.get("agerange") : cols.get("rangeage");
            String popularCol = cols.containsKey("popular") ? cols.get("popular") : (cols.containsKey("ispopular") ? cols.get("ispopular") : null);
            if (priceCol != null) select.append(", ").append(priceCol);
            if (durationCol != null) select.append(", ").append(durationCol);
            if (descCol != null) select.append(", ").append(descCol);
            if (ageCol != null) select.append(", ").append(ageCol);
            if (popularCol != null) select.append(", ").append(popularCol);
            select.append(" FROM packages ORDER BY packageName");

            String sqlExtended = select.toString();
            try {
                pstmt = conn.prepareStatement(sqlExtended);
                rs = pstmt.executeQuery();
                while (rs.next()) {
                    String pkgIdStr = rs.getString("packageId"); // e.g. 'P001'
                    int pkgId = 0;
                    if (pkgIdStr != null) {
                        String digits = pkgIdStr.replaceAll("\\D+", "");
                        try { pkgId = digits.isEmpty() ? 0 : Integer.parseInt(digits); } catch (NumberFormatException ignore) { pkgId = 0; }
                    }

                    String pkgName = rs.getString("packageName");
                    String pkgType = rs.getString("packageType");
                    int totalSessions = 0;
                    try { totalSessions = rs.getInt("totalSessions"); } catch (Exception ignore) {}

                    Package p = new Package();
                    p.setPackageId(pkgId);
                    p.setDbPackageId(pkgIdStr);
                    p.setPackageName(pkgName);
                    p.setCategory(pkgType);
                    p.setSessions(totalSessions);

                    try { p.setPrice(priceCol != null ? rs.getString(priceCol) : "RM0"); } catch (Exception ignore) { p.setPrice("RM0"); }
                    try { p.setDurationPerSession(durationCol != null ? rs.getInt(durationCol) : 15); } catch (Exception ignore) { p.setDurationPerSession(15); }
                    try { p.setDescription(descCol != null ? rs.getString(descCol) : ""); } catch (Exception ignore) { p.setDescription(""); }
                    try { p.setAgeRange(ageCol != null ? rs.getString(ageCol) : ""); } catch (Exception ignore) { p.setAgeRange(""); }
                    try { if (popularCol != null) p.setPopular(rs.getBoolean(popularCol)); else p.setPopular(false); } catch (Exception ignore) { p.setPopular(false); }

                    // if price or description empty, provide reasonable defaults for known packages
                    if ((p.getPrice() == null || p.getPrice().isEmpty()) && pkgIdStr != null) {
                        switch (pkgIdStr) {
                            case "P003": p.setPrice("RM160"); break;
                            case "P004": p.setPrice("RM300"); break;
                            default: p.setPrice("RM0");
                        }
                    }

                    packages.add(p);
                }
            } catch (SQLException ex) {
                // fallback to minimal, older schema
                try { if (rs != null) rs.close(); } catch (Exception ignore) {}
                try { if (pstmt != null) pstmt.close(); } catch (Exception ignore) {}

                String sqlSimple = "SELECT packageId, packageName, packageType, totalSessions FROM packages ORDER BY packageName";
                pstmt = conn.prepareStatement(sqlSimple);
                rs = pstmt.executeQuery();
                while (rs.next()) {
                    String pkgIdStr = rs.getString("packageId");
                    int pkgId = 0;
                    if (pkgIdStr != null) {
                        String digits = pkgIdStr.replaceAll("\\D+", "");
                        try { pkgId = digits.isEmpty() ? 0 : Integer.parseInt(digits); } catch (NumberFormatException ignore) { pkgId = 0; }
                    }

                    String pkgName = rs.getString("packageName");
                    String pkgType = rs.getString("packageType");
                    int totalSessions = 0;
                    try { totalSessions = rs.getInt("totalSessions"); } catch (Exception ignore) {}

                    Package p = new Package();
                    p.setPackageId(pkgId);
                    p.setDbPackageId(pkgIdStr);
                    p.setPackageName(pkgName);
                    p.setCategory(pkgType);
                    p.setSessions(totalSessions);

                    // Provide reasonable defaults when DB doesn't include extra fields
                    if (pkgIdStr != null) {
                        switch (pkgIdStr) {
                            case "P001": // TalaqqiSpark (Kids)
                                p.setPrice("RM120");
                                p.setDurationPerSession(15);
                                p.setDescription("A gentle introduction to Quran learning for children. Short and focused sessions help kids stay attentive while building confidence step by step.");
                                p.setPopular(false);
                                p.setGradient("linear-gradient(90deg,#3fb79f,#4fd1c5)");
                                p.setAgeRange("");
                                break;
                            case "P002": // TalaqqiSpark+ (Kids)
                                p.setPrice("RM220");
                                p.setDurationPerSession(15);
                                p.setDescription("Perfect for children who need more regular practice. Consistent sessions support better recitation, focus, and learning habits.");
                                p.setAgeRange("");
                                p.setPopular(true);
                                p.setGradient("linear-gradient(90deg,#8b5cf6,#f687b3)");
                                break;
                            case "P003": // TalaqqiPro (Adults)
                                p.setPrice("RM160");
                                p.setDurationPerSession(15);
                                p.setDescription("Suitable for adult learners who want guided Quran learning in short, focused sessions that fit into a busy schedule.");
                                p.setPopular(false);
                                p.setGradient("linear-gradient(90deg,#7c3aed,#f472b6)");
                                break;
                            case "P004": // TalaqqiPro+ (Adults)
                                p.setPrice("RM300");
                                p.setDurationPerSession(15);
                                p.setDescription("Best for adults who want consistent guidance and steady improvement through regular talaqqi sessions and teacher feedback.");
                                p.setPopular(true);
                                p.setGradient("linear-gradient(90deg,#f472b6,#ef476f)");
                                break;
                            default:
                                p.setPrice("RM0");
                                p.setDurationPerSession(15);
                                p.setDescription("");
                                p.setPopular(false);
                                p.setGradient("linear-gradient(90deg,#e6f5f0,#f0edff)");
                        }
                    } else {
                        p.setPrice("RM0");
                        p.setDurationPerSession(15);
                        p.setDescription("");
                        p.setPopular(false);
                        p.setGradient("linear-gradient(90deg,#e6f5f0,#f0edff)");
                    }

                    packages.add(p);
                }
            }

        } catch (SQLException e) {
            System.err.println("Error fetching packages: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
            try { if (pstmt != null) pstmt.close(); } catch (SQLException ignored) {}
            try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
        }

        return packages;
    }

    /**
     * Load a package by its DB id (e.g. "P001"). Tries to read optional columns (price, durationPerSession, description)
     * if they exist; falls back to the existing mapping behavior when optional columns are absent.
     */
    public Package getPackageByDbId(String dbPackageId) {
        if (dbPackageId == null) return null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return null;

            // Discover actual column names and build query accordingly so we support
            // both `ageRange` and `rangeAge` column names.
            java.util.Map<String, String> cols = new java.util.HashMap<>();
            try (ResultSet md = conn.getMetaData().getColumns(null, null, "packages", null)) {
                while (md.next()) {
                    String col = md.getString("COLUMN_NAME");
                    if (col != null) cols.put(col.toLowerCase(), col);
                }
            } catch (SQLException ignore) {}

            String priceCol = cols.get("price");
            String durationCol = cols.get("durationpersession");
            String descCol = cols.get("description");
            String ageCol = cols.containsKey("agerange") ? cols.get("agerange") : cols.get("rangeage");
            String popularCol = cols.containsKey("popular") ? cols.get("popular") : (cols.containsKey("ispopular") ? cols.get("ispopular") : null);

            StringBuilder sql = new StringBuilder();
            sql.append("SELECT packageId, packageName, packageType, totalSessions");
            if (priceCol != null) sql.append(", ").append(priceCol);
            if (durationCol != null) sql.append(", ").append(durationCol);
            if (descCol != null) sql.append(", ").append(descCol);
            if (ageCol != null) sql.append(", ").append(ageCol);
            if (popularCol != null) sql.append(", ").append(popularCol);
            sql.append(" FROM packages WHERE packageId = ?");

            try {
                pstmt = conn.prepareStatement(sql.toString());
                pstmt.setString(1, dbPackageId);
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    Package p = new Package();
                    String pkgIdStr = rs.getString("packageId");
                    int pkgId = 0;
                    if (pkgIdStr != null) {
                        String digits = pkgIdStr.replaceAll("\\D+", "");
                        try { pkgId = digits.isEmpty() ? 0 : Integer.parseInt(digits); } catch (NumberFormatException ignore) { pkgId = 0; }
                    }
                    p.setPackageId(pkgId);
                    p.setPackageName(rs.getString("packageName"));
                    p.setCategory(rs.getString("packageType"));
                    try { p.setSessions(rs.getInt("totalSessions")); } catch (Exception ignore) {}
                    try { p.setPrice(priceCol != null ? rs.getString(priceCol) : null); } catch (Exception ignore) {}
                    try { p.setDurationPerSession(durationCol != null ? rs.getInt(durationCol) : 15); } catch (Exception ignore) {}
                    try { p.setDescription(descCol != null ? rs.getString(descCol) : ""); } catch (Exception ignore) {}
                    try { p.setAgeRange(ageCol != null ? rs.getString(ageCol) : ""); } catch (Exception ignore) {}
                    try { if (popularCol != null) p.setPopular(rs.getBoolean(popularCol)); else p.setPopular(false); } catch (Exception ignore) { p.setPopular(false); }
                    return p;
                }
            } catch (SQLException ex) {
                // optional columns missing; fall back to safe query
                try { if (rs != null) rs.close(); } catch (Exception ignore) {}
                try { if (pstmt != null) pstmt.close(); } catch (Exception ignore) {}
                String simpleSql = "SELECT packageId, packageName, packageType, totalSessions FROM packages WHERE packageId = ?";
                pstmt = conn.prepareStatement(simpleSql);
                pstmt.setString(1, dbPackageId);
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    Package p = new Package();
                    String pkgIdStr = rs.getString("packageId");
                    int pkgId = 0;
                    if (pkgIdStr != null) {
                        String digits = pkgIdStr.replaceAll("\\D+", "");
                        try { pkgId = digits.isEmpty() ? 0 : Integer.parseInt(digits); } catch (NumberFormatException ignore) { pkgId = 0; }
                    }
                    p.setPackageId(pkgId);
                    p.setPackageName(rs.getString("packageName"));
                    p.setCategory(rs.getString("packageType"));
                    try { p.setSessions(rs.getInt("totalSessions")); } catch (Exception ignore) {}
                    // price/duration/description remain defaults in this case
                    return p;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
            try { if (pstmt != null) pstmt.close(); } catch (SQLException ignored) {}
            try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
        }
        return null;
    }

    /**
     * Update package fields in DB. Accepts DB package id (eg "P001"). Will only update optional columns
     * if they exist in the table (checked via DatabaseMetaData).
     */
    public boolean updatePackage(String dbPackageId, Package p) {
        if (dbPackageId == null || p == null) return false;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet cols = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return false;

            // determine which optional columns exist and capture their actual names
            java.util.Map<String, String> existing = new java.util.HashMap<>();
            try {
                cols = conn.getMetaData().getColumns(null, null, "packages", null);
                while (cols.next()) {
                    String colName = cols.getString("COLUMN_NAME");
                    if (colName != null) existing.put(colName.toLowerCase(), colName);
                }
            } catch (SQLException ignore) {
                // ignore and proceed; we'll attempt safe update
            } finally {
                try { if (cols != null) cols.close(); } catch (SQLException ignored) {}
            }

            StringBuilder sb = new StringBuilder();
            sb.append("UPDATE packages SET packageName = ?, totalSessions = ?");
            boolean hasPrice = existing.containsKey("price");
            boolean hasDuration = existing.containsKey("durationpersession");
            boolean hasDesc = existing.containsKey("description");
            boolean hasAge = existing.containsKey("agerange") || existing.containsKey("rangeage");
            String ageCol = existing.containsKey("agerange") ? existing.get("agerange") : existing.get("rangeage");
            boolean hasPopular = existing.containsKey("popular") || existing.containsKey("ispopular");
            String popularCol = existing.containsKey("popular") ? existing.get("popular") : (existing.containsKey("ispopular") ? existing.get("ispopular") : null);
            if (hasPrice) sb.append(", ").append(existing.get("price")).append(" = ?");
            if (hasDuration) sb.append(", ").append(existing.get("durationpersession")).append(" = ?");
            if (hasDesc) sb.append(", ").append(existing.get("description")).append(" = ?");
            if (hasAge && ageCol != null) sb.append(", ").append(ageCol).append(" = ?");
            if (hasPopular && popularCol != null) sb.append(", ").append(popularCol).append(" = ?");
            sb.append(" WHERE packageId = ?");

            // If this update is setting this package as popular, clear the popular
            // flag from other packages in the SAME category only so each category
            // can have its own "most popular" package.
            if (hasPopular && popularCol != null && p.isPopular()) {
                PreparedStatement clearStmt = null;
                try {
                    // Use a derived table in the subquery to avoid MySQL "You can't specify target table for update in FROM clause" error.
                    String clearSql = "UPDATE packages SET " + popularCol + " = ? WHERE packageId <> ? AND packageType = (SELECT t.packageType FROM (SELECT packageType FROM packages WHERE packageId = ?) AS t)";
                    clearStmt = conn.prepareStatement(clearSql);
                    clearStmt.setBoolean(1, false);
                    clearStmt.setString(2, dbPackageId);
                    clearStmt.setString(3, dbPackageId);
                    clearStmt.executeUpdate();
                } catch (SQLException ignore) {
                } finally {
                    try { if (clearStmt != null) clearStmt.close(); } catch (SQLException ignored) {}
                }
            }

            pstmt = conn.prepareStatement(sb.toString());
            int idx = 1;
            pstmt.setString(idx++, p.getPackageName());
            pstmt.setInt(idx++, p.getSessions());
            if (hasPrice) pstmt.setString(idx++, p.getPrice());
            if (hasDuration) pstmt.setInt(idx++, p.getDurationPerSession());
            if (hasDesc) pstmt.setString(idx++, p.getDescription());
            if (hasAge && ageCol != null) pstmt.setString(idx++, p.getAgeRange());
            if (hasPopular && popularCol != null) pstmt.setBoolean(idx++, p.isPopular());
            pstmt.setString(idx++, dbPackageId);

            int updated = pstmt.executeUpdate();
            return updated > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (pstmt != null) pstmt.close(); } catch (SQLException ignored) {}
            try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
        }
    }

    /**
     * Create a new package row. dbPackageId should be like 'P005'.
     */
    public boolean createPackage(String dbPackageId, Package p) {
        if (dbPackageId == null || p == null) return false;
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return false;

            // detect actual optional columns and build insert accordingly
            java.util.Map<String, String> cols = new java.util.HashMap<>();
            try (ResultSet md = conn.getMetaData().getColumns(null, null, "packages", null)) {
                while (md.next()) {
                    String col = md.getString("COLUMN_NAME");
                    if (col != null) cols.put(col.toLowerCase(), col);
                }
            } catch (SQLException ignore) {}

            java.util.List<String> colNames = new java.util.ArrayList<>();
            java.util.List<String> placeholders = new java.util.ArrayList<>();
            java.util.List<Object> values = new java.util.ArrayList<>();

            colNames.add("packageId"); placeholders.add("?"); values.add(dbPackageId);
            colNames.add("packageName"); placeholders.add("?"); values.add(p.getPackageName());
            colNames.add("packageType"); placeholders.add("?"); values.add(p.getCategory());
            colNames.add("totalSessions"); placeholders.add("?"); values.add(p.getSessions());
            colNames.add("managerId"); placeholders.add("?"); values.add(null);

            if (cols.containsKey("price")) { colNames.add(cols.get("price")); placeholders.add("?"); values.add(p.getPrice()); }
            if (cols.containsKey("durationpersession")) { colNames.add(cols.get("durationpersession")); placeholders.add("?"); values.add(p.getDurationPerSession()); }
            if (cols.containsKey("description")) { colNames.add(cols.get("description")); placeholders.add("?"); values.add(p.getDescription()); }
            if (cols.containsKey("agerange") || cols.containsKey("rangeage")) { String a = cols.containsKey("agerange") ? cols.get("agerange") : cols.get("rangeage"); colNames.add(a); placeholders.add("?"); values.add(p.getAgeRange()); }
            String popColName = null;
            if (cols.containsKey("popular") || cols.containsKey("ispopular")) {
                popColName = cols.containsKey("popular") ? cols.get("popular") : cols.get("ispopular");
                colNames.add(popColName); placeholders.add("?"); values.add(p.isPopular());
            }

            // If creating a package and it's marked popular, clear other popular flags
            // only for the same packageType (category) so each category can have
            // its own popular package.
            if (popColName != null && p.isPopular()) {
                PreparedStatement clearStmt = null;
                try {
                    String clearSql = "UPDATE packages SET " + popColName + " = ? WHERE packageType = ?";
                    clearStmt = conn.prepareStatement(clearSql);
                    clearStmt.setBoolean(1, false);
                    clearStmt.setString(2, p.getCategory());
                    clearStmt.executeUpdate();
                } catch (SQLException ignore) {
                } finally {
                    try { if (clearStmt != null) clearStmt.close(); } catch (SQLException ignored) {}
                }
            }

            String sql = "INSERT INTO packages (" + String.join(",", colNames) + ") VALUES (" + String.join(",", placeholders) + ")";
            try {
                pstmt = conn.prepareStatement(sql);
                int idx = 1;
                for (Object v : values) {
                    if (v == null) pstmt.setString(idx++, null);
                    else if (v instanceof Integer) pstmt.setInt(idx++, (Integer) v);
                    else if (v instanceof Boolean) pstmt.setBoolean(idx++, (Boolean) v);
                    else pstmt.setString(idx++, v.toString());
                }
                int inserted = pstmt.executeUpdate();
                return inserted > 0;
            } catch (SQLException ex) {
                // if optional columns missing or insert fails, try minimal insert
                try { if (pstmt != null) pstmt.close(); } catch (Exception ignore) {}
                String simple = "INSERT INTO packages (packageId, packageName, packageType, totalSessions, managerId) VALUES (?,?,?,?,?)";
                pstmt = conn.prepareStatement(simple);
                pstmt.setString(1, dbPackageId);
                pstmt.setString(2, p.getPackageName());
                pstmt.setString(3, p.getCategory());
                pstmt.setInt(4, p.getSessions());
                pstmt.setString(5, null);
                int inserted = pstmt.executeUpdate();
                return inserted > 0;
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (pstmt != null) pstmt.close(); } catch (SQLException ignored) {}
            try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
        }
    }

    /**
     * Return the next package id as PNNN by scanning existing packageId values.
     */
    public String getNextPackageDbId() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int max = 0;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return "P001";
            String sql = "SELECT packageId FROM packages";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                String pid = rs.getString("packageId");
                if (pid != null) {
                    String digits = pid.replaceAll("\\D+", "");
                    try { int n = Integer.parseInt(digits); if (n > max) max = n; } catch (Exception ignore) {}
                }
            }
            int next = max + 1;
            return String.format("P%03d", next);
        } catch (SQLException e) {
            e.printStackTrace();
            return "P001";
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
            try { if (pstmt != null) pstmt.close(); } catch (SQLException ignored) {}
            try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
        }
    }

    /**
     * Delete a package row by DB package id (eg "P005").
     */
    public boolean deletePackage(String dbPackageId) {
        if (dbPackageId == null) return false;
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return false;
            String sql = "DELETE FROM packages WHERE packageId = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, dbPackageId);
            int deleted = pstmt.executeUpdate();
            return deleted > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (pstmt != null) pstmt.close(); } catch (SQLException ignored) {}
            try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
        }
    }

    /**
     * Returns true if this package id is referenced by other tables (e.g. student).
     */
    public boolean hasReferences(String dbPackageId) {
        if (dbPackageId == null) return false;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) return false;
            String sql = "SELECT COUNT(*) AS cnt FROM student WHERE packageId = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, dbPackageId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                int cnt = rs.getInt("cnt");
                return cnt > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return true; // be conservative and assume it has refs on error
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
            try { if (pstmt != null) pstmt.close(); } catch (SQLException ignored) {}
            try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
        }
        return false;
    }
}
