package controller;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * TeacherPendingApprovalServlet
 * 
 * Displays a pending approval page for teachers whose accounts are awaiting admin review.
 * Only teachers with "Pending" approval status can access this page.
 */
public class TeacherPendingApprovalServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check authentication and approval status
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("teacherId") == null) {
            response.sendRedirect(request.getContextPath() + "/teacher/login");
            return;
        }
        
        String approvalStatus = (String) session.getAttribute("teacherApprovalStatus");
        
        // Only show this page if teacher is in pending status
        if (approvalStatus == null || !"Pending".equalsIgnoreCase(approvalStatus)) {
            // If not pending, redirect to appropriate page
            if ("Approved".equalsIgnoreCase(approvalStatus)) {
                response.sendRedirect(request.getContextPath() + "/teacher/teacherdashboard");
            } else if ("Rejected".equalsIgnoreCase(approvalStatus)) {
                response.sendRedirect(request.getContextPath() + "/teacher/access-denied");
            } else {
                response.sendRedirect(request.getContextPath() + "/teacher/login");
            }
            return;
        }
        
        // Forward to pending approval page
        request.getRequestDispatcher("/WEB-INF/views/teacherPendingApproval.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}
