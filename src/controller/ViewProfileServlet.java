package controller;

import dao.StudentDAO;
import model.Student;
import util.StudentProfilePicUtil;

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

        try {
            StudentDAO sdao = new StudentDAO();
            Student student = sdao.getStudentById(studentId);

            if (student == null) {
                response.sendRedirect(request.getContextPath() + "/student/edit-profile");
                return;
            }

            normalizeStudentFields(student);

            String initials = buildInitials(student);
            String selectedPackage = sdao.getPackageNameById(student.getPackageId());
            String accountStatus = resolveAccountStatus(student);

            request.setAttribute("student", student);
            request.setAttribute("initials", initials);
            request.setAttribute("selectedPackage", selectedPackage);
            request.setAttribute("accountStatus", accountStatus);
            request.setAttribute("saved", "1".equals(request.getParameter("saved")));

            StudentProfilePicUtil.bindToSession(session, getServletContext(), studentId);

            request.getRequestDispatcher("/WEB-INF/views/viewProfile.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("ViewProfileServlet error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/student/edit-profile?saved=1");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }

    private void normalizeStudentFields(Student student) {
        if (student == null) return;
        if ((student.getFullName() == null || student.getFullName().trim().isEmpty())
                && student.getStudentName() != null) {
            student.setFullName(student.getStudentName());
        }
        if ((student.getEmail() == null || student.getEmail().trim().isEmpty())
                && student.getStudentEmail() != null) {
            student.setEmail(student.getStudentEmail());
        }
    }

    private String buildInitials(Student student) {
        String initials = "U";
        if (student == null) return initials;
        String name = student.getFullName();
        if (name == null || name.trim().isEmpty()) name = student.getName();
        if (name == null || name.trim().isEmpty()) name = student.getStudentName();
        if (name != null && !name.trim().isEmpty()) {
            String[] parts = name.trim().split("\\s+");
            StringBuilder sb = new StringBuilder();
            for (String p : parts) {
                if (!p.isEmpty()) sb.append(Character.toUpperCase(p.charAt(0)));
                if (sb.length() >= 2) break;
            }
            if (sb.length() > 0) initials = sb.toString();
        }
        return initials;
    }

    private String resolveAccountStatus(Student student) {
        if (student == null) return "Inactive";
        if (student.getStudentStatus() != null && !student.getStudentStatus().trim().isEmpty()) {
            return student.getStudentStatus();
        }
        if (student.getStatus() != null && !student.getStatus().trim().isEmpty()) {
            return student.getStatus();
        }
        return "Inactive";
    }
}
