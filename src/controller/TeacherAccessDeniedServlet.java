package controller;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * TeacherAccessDeniedServlet
 * 
 * Displays an access denied page for teachers whose applications have been rejected.
 * This page appears when a rejected teacher tries to access the system.
 */
public class TeacherAccessDeniedServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is already logged in with rejected status
        HttpSession session = request.getSession(false);
        
        // Allow display of this page if teacher has pending or rejected status
        if (session != null && session.getAttribute("teacherId") != null) {
            String approvalStatus = (String) session.getAttribute("teacherApprovalStatus");
            
            if ("Approved".equalsIgnoreCase(approvalStatus)) {
                // If approved, redirect to dashboard
                response.sendRedirect(request.getContextPath() + "/teacher/teacherdashboard");
                return;
            }
            
            // For pending or rejected, allow viewing this page
            if ("Pending".equalsIgnoreCase(approvalStatus)) {
                // Pending teachers should go to pending approval page instead
                response.sendRedirect(request.getContextPath() + "/teacher/pending-approval");
                return;
            }
        }
        
        // Forward to access denied page
        request.getRequestDispatcher("/WEB-INF/views/teacherAccessDenied.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}
