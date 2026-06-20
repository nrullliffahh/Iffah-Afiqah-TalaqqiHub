package controller;

import dao.TeacherDAO;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

/**
 * AdminUpdateTeacherCertificationServlet
 * 
 * Allows admin to upload or update a teacher's certification file.
 * Accepts file uploads and stores certification path in database.
 */
public class AdminUpdateTeacherCertificationServlet extends HttpServlet {
    
    private TeacherDAO teacherDAO;
    
    @Override
    public void init() throws ServletException {
        teacherDAO = new TeacherDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check admin authentication
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("Unauthorized");
            return;
        }
        
        String teacherId = request.getParameter("teacherId");
        
        if (teacherId == null || teacherId.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Teacher ID is required");
            return;
        }
        
        try {
            // Get certification file from request
            Part certPart = request.getPart("certification");
            
            if (certPart == null || certPart.getSize() == 0) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("No file uploaded");
                return;
            }
            
            // Create uploads directory if it doesn't exist
            String uploadsDir = getServletContext().getRealPath("/uploads/certifications");
            File uploads = new File(uploadsDir);
            if (!uploads.exists()) {
                uploads.mkdirs();
            }
            
            // Get file extension
            String submitted = certPart.getSubmittedFileName();
            String ext = "";
            int idx = submitted != null ? submitted.lastIndexOf('.') : -1;
            if (idx > 0) {
                ext = submitted.substring(idx);
            }
            
            // Create unique filename
            String fileName = "cert_" + System.currentTimeMillis() + ext;
            File file = new File(uploads, fileName);
            
            // Save file to disk
            try (InputStream in = certPart.getInputStream()) {
                Files.copy(in, file.toPath(), StandardCopyOption.REPLACE_EXISTING);
            }
            
            // Update certification path in database
            String certPath = "uploads/certifications/" + fileName;
            boolean success = teacherDAO.updateCertificationPath(teacherId, certPath);
            
            if (success) {
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("{\"success\": true, \"message\": \"Certification updated successfully\", \"path\": \"" + certPath + "\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"success\": false, \"message\": \"Failed to update certification in database\"}");
            }
        } catch (IllegalStateException | ServletException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\": false, \"message\": \"Invalid request: " + e.getMessage() + "\"}");
        } catch (IOException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\": false, \"message\": \"File upload failed: " + e.getMessage() + "\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\": false, \"message\": \"Error: " + e.getMessage() + "\"}");
        }
    }
}
