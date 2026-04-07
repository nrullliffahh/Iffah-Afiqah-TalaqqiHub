package controller;

import dao.PackageDAO;
import model.Package;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class AdminPackageAddServlet extends HttpServlet {

    private PackageDAO packageDAO;

    @Override
    public void init() {
        packageDAO = new PackageDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/adminAddPackage.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String name = request.getParameter("packageName");
        String category = request.getParameter("category");
        String sessionsStr = request.getParameter("sessions");
        String durationStr = request.getParameter("durationPerSession");
        String price = request.getParameter("price");
        String description = request.getParameter("description");
        String ageRange = request.getParameter("ageRange");

        int sessions = 0;
        int duration = 15;
        try { sessions = Integer.parseInt(sessionsStr); } catch (Exception ignore) {}
        try { duration = Integer.parseInt(durationStr); } catch (Exception ignore) {}

        Package p = new Package();
        p.setPackageName(name);
        p.setCategory(category);
        p.setSessions(sessions);
        p.setDurationPerSession(duration);
        p.setPrice(price);
        p.setDescription(description);
        p.setAgeRange(ageRange);
        // popular flag (checkbox may send "on" or "1")
        String popularParam = request.getParameter("popular");
        p.setPopular(popularParam != null && (popularParam.equals("1") || popularParam.equalsIgnoreCase("on") || popularParam.equalsIgnoreCase("true")));

        String dbId = packageDAO.getNextPackageDbId();
        boolean ok = packageDAO.createPackage(dbId, p);
        if (ok) response.sendRedirect(request.getContextPath() + "/admin/packages?added=1");
        else response.sendRedirect(request.getContextPath() + "/admin/packages?added=0");
    }
}
