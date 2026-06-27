package controller;

import util.StudentProfilePicUtil;

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
            response.sendRedirect(request.getContextPath() + "/student/edit-profile");
            return;
        }

        if (filePart != null && filePart.getSize() > 0) {
            String submitted = filePart.getSubmittedFileName();
            String ext = "";
            if (submitted != null) {
                int i = submitted.lastIndexOf('.');
                if (i > 0) {
                    ext = submitted.substring(i).toLowerCase();
                }
            }
            if (!ext.equals(".jpg") && !ext.equals(".jpeg") && !ext.equals(".png") && !ext.equals(".webp")) {
                ext = ".jpg";
            }

            String profilesDir = getServletContext().getRealPath("/images/profiles");
            if (profilesDir == null) {
                String base = System.getProperty("catalina.base", System.getProperty("user.dir", "."));
                profilesDir = base + "/webapps/ROOT/images/profiles";
            }
            File dir = new File(profilesDir);
            if (!dir.exists() && !dir.mkdirs()) {
                System.err.println("UploadProfilePicServlet: could not create " + profilesDir);
                response.sendRedirect(request.getContextPath() + "/student/edit-profile?photoError=1");
                return;
            }

            // Remove previous extensions so only one avatar file remains
            for (String oldExt : new String[] { ".jpg", ".jpeg", ".png", ".webp", ".gif" }) {
                File old = new File(dir, "p_" + studentId + oldExt);
                if (old.isFile()) old.delete();
            }

            String filename = "p_" + studentId + ext;
            File out = new File(dir, filename);
            try (InputStream in = filePart.getInputStream()) {
                Files.copy(in, out.toPath(), java.nio.file.StandardCopyOption.REPLACE_EXISTING);
            }

            StudentProfilePicUtil.bindToSession(session, getServletContext(), studentId);
        }

        response.sendRedirect(request.getContextPath() + "/student/edit-profile?photoUpdated=1");
    }
}
