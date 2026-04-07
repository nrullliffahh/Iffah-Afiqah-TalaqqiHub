package controller;

import dao.PackageDAO;
import model.Package;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class PackagesServlet extends HttpServlet {

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
        request.getRequestDispatcher("/WEB-INF/views/packages.jsp").forward(request, response);
    }
}
