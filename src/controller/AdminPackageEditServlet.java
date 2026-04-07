package controller;

import dao.PackageDAO;
import model.Package;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class AdminPackageEditServlet extends HttpServlet {

    private PackageDAO packageDAO;

    @Override
    public void init() {
        packageDAO = new PackageDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String rawId = request.getParameter("packageId");
        if (rawId == null) {
            response.sendRedirect(request.getContextPath() + "/admin/packages");
            return;
        }

        String dbId = toDbPackageId(rawId);
        Package pkg = packageDAO.getPackageByDbId(dbId);
        if (pkg == null) {
            response.sendRedirect(request.getContextPath() + "/admin/packages?notfound=1");
            return;
        }

        request.setAttribute("pkg", pkg);
        request.getRequestDispatcher("/WEB-INF/views/adminEditPackage.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String dbId = toDbPackageId(request.getParameter("packageId"));
        if (dbId == null) {
            response.sendRedirect(request.getContextPath() + "/admin/packages");
            return;
        }

        String name = request.getParameter("packageName");
        String sessionsStr = request.getParameter("sessions");
        String durationStr = request.getParameter("durationPerSession");
        String price = request.getParameter("price");
        String description = request.getParameter("description");
        String ageRange = request.getParameter("ageRange");

        int sessions = 0;
        int duration = 0;
        try { sessions = Integer.parseInt(sessionsStr); } catch (Exception ignore) {}
        try { duration = Integer.parseInt(durationStr); } catch (Exception ignore) {}

        Package p = new Package();
        // set numeric id if possible (for model consistency)
        try {
            String digits = dbId.replaceAll("\\D+", "");
            if (!digits.isEmpty()) p.setPackageId(Integer.parseInt(digits));
        } catch (Exception ignore) {}
        p.setPackageName(name);
        p.setSessions(sessions);
        p.setDurationPerSession(duration);
        p.setPrice(price);
        p.setDescription(description);
        p.setAgeRange(ageRange);
        String popularParam = request.getParameter("popular");
        p.setPopular(popularParam != null && (popularParam.equals("1") || popularParam.equalsIgnoreCase("on") || popularParam.equalsIgnoreCase("true")));

        boolean ok = packageDAO.updatePackage(dbId, p);
        if (ok) {
            response.sendRedirect(request.getContextPath() + "/admin/packages?updated=1");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/packages?updated=0");
        }
    }

    private String toDbPackageId(String raw) {
        if (raw == null) return null;
        raw = raw.trim();
        if (raw.toUpperCase().startsWith("P")) return raw.toUpperCase();
        // if numeric like "1" or "001" -> convert to P001
        try {
            int n = Integer.parseInt(raw);
            return String.format("P%03d", n);
        } catch (NumberFormatException e) {
            // unknown format
            return raw;
        }
    }
}
