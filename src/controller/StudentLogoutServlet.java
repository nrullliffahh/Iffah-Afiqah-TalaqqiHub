package controller;

import util.SessionRoleUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class StudentLogoutServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session != null) {
            SessionRoleUtil.clearStudent(session);
            if (!SessionRoleUtil.hasAnyPortal(session)) {
                session.invalidate();
            }
        }
        
        response.sendRedirect(request.getContextPath() + "/home");
    }
}
