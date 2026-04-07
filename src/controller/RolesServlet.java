package controller;

import dao.RoleDAO;
import model.Role;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class RolesServlet extends HttpServlet {

    private RoleDAO roleDAO;

    @Override
    public void init() {
        roleDAO = new RoleDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            List<Role> roles = roleDAO.getAllRoles();
            request.setAttribute("roles", roles);
            request.getRequestDispatcher("/WEB-INF/views/roles.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace(); // Log the error to Tomcat logs
            throw new ServletException(e);
        }
    }
}
