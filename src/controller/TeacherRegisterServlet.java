package controller;

import dao.TeacherDAO;
import model.Teacher;
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
import java.nio.file.StandardCopyOption;
import java.time.LocalDate;

@MultipartConfig(fileSizeThreshold = 1024 * 1024, // 1MB
    maxFileSize = 10 * 1024 * 1024,      // 10MB
    maxRequestSize = 15 * 1024 * 1024)   // 15MB
public class TeacherRegisterServlet extends HttpServlet {
    private TeacherDAO teacherDAO;

    @Override
    public void init() {
        teacherDAO = new TeacherDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/teacherRegister.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Support multipart form for file upload
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String dateOfBirth = request.getParameter("dateOfBirth");
        String qualification = request.getParameter("qualification");
        String specialty = request.getParameter("specialty");
        String experienceYears = request.getParameter("experienceYears");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String securityQuestion = request.getParameter("securityQuestion");
        String securityAnswer = request.getParameter("securityAnswer");

        // Handle certification file (optional)
        Part certPart = null;
        String certPath = null;
        try {
            certPart = request.getPart("certification");
        } catch (IllegalStateException | IOException | ServletException e) {
            certPart = null;
        }

        if (password == null || confirmPassword == null || !password.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Passwords do not match");
            request.getRequestDispatcher("/WEB-INF/views/teacherRegister.jsp").forward(request, response);
            return;
        }

        if (teacherDAO == null) {
            teacherDAO = new TeacherDAO();
        }

        if (email != null && teacherDAO.isEmailExists(email)) {
            request.setAttribute("errorMessage", "Email already registered");
            request.getRequestDispatcher("/WEB-INF/views/teacherRegister.jsp").forward(request, response);
            return;
        }

        Teacher teacher = new Teacher();
        teacher.setFullName(fullName);
        teacher.setEmail(email);
        teacher.setPhone(phone);
        try {
            if (dateOfBirth != null && !dateOfBirth.isEmpty()) {
                teacher.setDateOfBirth(LocalDate.parse(dateOfBirth));
            }
        } catch (Exception e) {
            // leave dateOfBirth null if parse fails
        }
        teacher.setQualification(qualification);
        teacher.setSpecialty(specialty);
        try {
            teacher.setExperienceYears(Integer.parseInt(experienceYears));
        } catch (Exception e) {
            teacher.setExperienceYears(0);
        }
        teacher.setPassword(password);
        teacher.setSecurityQuestion(securityQuestion);
        teacher.setSecurityAnswer(securityAnswer);

        // Save uploaded certification file if provided
        if (certPart != null && certPart.getSize() > 0) {
            String uploadsDir = getServletContext().getRealPath("/uploads/certifications");
            File uploads = new File(uploadsDir);
            if (!uploads.exists()) uploads.mkdirs();

            String submitted = certPart.getSubmittedFileName();
            String ext = "";
            int idx = submitted != null ? submitted.lastIndexOf('.') : -1;
            if (idx > 0) ext = submitted.substring(idx);

            String fileName = "cert_" + System.currentTimeMillis() + ext;
            File file = new File(uploads, fileName);
            try (InputStream in = certPart.getInputStream()) {
                Files.copy(in, file.toPath(), StandardCopyOption.REPLACE_EXISTING);
                certPath = "uploads/certifications/" + fileName;
                teacher.setCertificationPath(certPath);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        boolean success = teacherDAO.registerTeacher(teacher);

        if (success) {
            HttpSession session = request.getSession();
            util.SessionRoleUtil.bindTeacher(session, teacher.getTeacherId(), teacher.getFullName(), teacher.getEmail());
            
            // Redirect to teacher dashboard
            response.sendRedirect(request.getContextPath() + "/teacher/teacherdashboard");
        } else {
            request.setAttribute("errorMessage", "Registration failed. Please try again.");
            request.getRequestDispatcher("/WEB-INF/views/teacherRegister.jsp").forward(request, response);
        }
    }
}
