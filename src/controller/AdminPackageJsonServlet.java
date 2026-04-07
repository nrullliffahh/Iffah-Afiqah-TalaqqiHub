package controller;

import dao.PackageDAO;
import model.Package;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class AdminPackageJsonServlet extends HttpServlet {

    private PackageDAO packageDAO;

    @Override
    public void init() {
        packageDAO = new PackageDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String rawId = request.getParameter("packageId");
        if (rawId == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\":\"missing packageId\"}");
            return;
        }
        String dbId = toDbPackageId(rawId);
        Package p = packageDAO.getPackageByDbId(dbId);
        if (p == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\":\"not found\"}");
            return;
        }

        response.setContentType("application/json;charset=UTF-8");
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"packageId\":\"").append(dbId).append("\",");
        sb.append("\"packageName\":\"").append(escapeJson(p.getPackageName())).append("\",");
        sb.append("\"category\":\"").append(escapeJson(p.getCategory())).append("\",");
        sb.append("\"price\":\"").append(escapeJson(p.getPrice())).append("\",");
        sb.append("\"sessions\":").append(p.getSessions()).append(",");
        sb.append("\"durationPerSession\":").append(p.getDurationPerSession()).append(",");
        sb.append("\"description\":\"").append(escapeJson(p.getDescription())).append("\",");
        sb.append("\"ageRange\":\"").append(escapeJson(p.getAgeRange())).append("\",");
        sb.append("\"popular\":").append(p.isPopular() ? "true" : "false");
        sb.append("}");
        response.getWriter().write(sb.toString());
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }

    private String toDbPackageId(String raw) {
        if (raw == null) return null;
        raw = raw.trim();
        if (raw.toUpperCase().startsWith("P")) return raw.toUpperCase();
        try {
            int n = Integer.parseInt(raw);
            return String.format("P%03d", n);
        } catch (NumberFormatException e) {
            return raw;
        }
    }
}
