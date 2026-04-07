package controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;

@MultipartConfig
public class UploadProfilePicServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentId") == null) {
            response.sendRedirect(request.getContextPath() + "/student/login");
            return;
        }

        String studentId = (String) session.getAttribute("studentId");
        Part filePart = null;
        try {
            filePart = request.getPart("photo");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/student/profile");
            return;
        }

        if (filePart != null && filePart.getSize() > 0) {
            String submitted = filePart.getSubmittedFileName();
            String ext = "";
            int i = submitted.lastIndexOf('.');
            if (i > 0) ext = submitted.substring(i);

            String profilesDir = getServletContext().getRealPath("/images/profiles");
            File dir = new File(profilesDir);
            if (!dir.exists()) dir.mkdirs();

            String filename = "p_" + studentId + ext;
            File out = new File(dir, filename);
            try (InputStream in = filePart.getInputStream()) {
                Files.copy(in, out.toPath(), java.nio.file.StandardCopyOption.REPLACE_EXISTING);
            }

            // store web path to image in session for display
            String webPath = "/images/profiles/" + filename;
            session.setAttribute("profilePicPath", webPath);
        }

        response.sendRedirect(request.getContextPath() + "/student/profile");
    }
}
