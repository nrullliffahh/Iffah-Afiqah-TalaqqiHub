package controller;

import dao.PackageDAO;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class AdminPackageDeleteServlet extends HttpServlet {

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

        System.out.println("AdminPackageDeleteServlet: received packageId='" + rawId + "'");
        String dbId = toDbPackageId(rawId);
        System.out.println("AdminPackageDeleteServlet: converted to dbId='" + dbId + "'");
        boolean ok = false;
        try {
            // Check for references (students etc.) that would block deletion
            if (packageDAO.hasReferences(dbId)) {
                System.out.println("AdminPackageDeleteServlet: package '" + dbId + "' has existing references and cannot be deleted");
                response.sendRedirect(request.getContextPath() + "/admin/packages?deleted=0&reason=referenced");
                return;
            }

            ok = packageDAO.deletePackage(dbId);
            System.out.println("AdminPackageDeleteServlet: deletePackage returned=" + ok + " for dbId='" + dbId + "'");
        } catch (Exception e) {
            System.err.println("AdminPackageDeleteServlet: exception while deleting package: " + e.getMessage());
            e.printStackTrace();
        }

        if (ok) response.sendRedirect(request.getContextPath() + "/admin/packages?deleted=1");
        else response.sendRedirect(request.getContextPath() + "/admin/packages?deleted=0");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
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
