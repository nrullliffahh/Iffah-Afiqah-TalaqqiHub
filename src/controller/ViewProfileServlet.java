package controller;

import dao.PackageDAO;
import dao.StudentDAO;
import model.Package;
import model.Student;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class ViewProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentId") == null) {
            response.sendRedirect(request.getContextPath() + "/student/login");
            return;
        }

        String studentId = (String) session.getAttribute("studentId");

        StudentDAO sdao = new StudentDAO();
        Student student = sdao.getStudentById(studentId);

        // normalize fields for the view: ensure fullName and email are populated
        if (student != null) {
            try {
                if ((student.getFullName() == null || student.getFullName().trim().isEmpty()) && student.getStudentName() != null) {
                    student.setFullName(student.getStudentName());
                }
            } catch (Exception ignore) {}
            try {
                if ((student.getEmail() == null || student.getEmail().trim().isEmpty()) && student.getStudentEmail() != null) {
                    student.setEmail(student.getStudentEmail());
                }
            } catch (Exception ignore) {}
        }

        String initials = "U";
        if (student != null) {
            String name = student.getFullName();
            if (name == null || name.trim().isEmpty()) name = student.getName();
            if (name == null || name.trim().isEmpty()) name = student.getStudentName();
            if (name != null && !name.trim().isEmpty()) {
                String[] parts = name.trim().split("\\s+");
                StringBuilder sb = new StringBuilder();
                for (String p : parts) {
                    if (p.length() > 0) sb.append(Character.toUpperCase(p.charAt(0)));
                    if (sb.length() >= 2) break;
                }
                if (sb.length() > 0) initials = sb.toString();
            }
        }

        // resolve package display name
        String selectedPackage = "-";
        try {
            if (student != null && student.getPackageId() != null) {
                String raw = student.getPackageId();
                String digits = raw.replaceAll("\\D+", "");
                int pkgInt = digits.isEmpty() ? -1 : Integer.parseInt(digits);

                PackageDAO pdao = new PackageDAO();
                for (Package p : pdao.getAllPackages()) {
                    if (pkgInt != -1 && p.getPackageId() == pkgInt) { selectedPackage = p.getPackageName(); break; }
                    if (String.valueOf(p.getPackageId()).equals(raw)) { selectedPackage = p.getPackageName(); break; }
                }
            }
        } catch (Exception ignore) {}

        // account status preference
        String accountStatus = "Inactive";
        if (student != null) {
            if (student.getStudentStatus() != null && !student.getStudentStatus().trim().isEmpty()) accountStatus = student.getStudentStatus();
            else if (student.getStatus() != null && !student.getStatus().trim().isEmpty()) accountStatus = student.getStatus();
        }

        request.setAttribute("student", student);
        request.setAttribute("initials", initials);
        request.setAttribute("selectedPackage", selectedPackage);
        request.setAttribute("accountStatus", accountStatus);

        request.getRequestDispatcher("/WEB-INF/views/viewProfile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }
}
