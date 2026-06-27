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

public class EditProfileServlet extends HttpServlet {

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
        normalizeStudentFields(student);

        String initials = "U";
        if (student != null) {
            String name = student.getFullName();
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

        request.setAttribute("student", student);
        request.setAttribute("initials", initials);
        StudentProfilePicUtil.bindToSession(session, getServletContext(), studentId);
        request.getRequestDispatcher("/WEB-INF/views/editProfile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentId") == null) {
            response.sendRedirect(request.getContextPath() + "/student/login");
            return;
        }

        String studentId = request.getParameter("studentId");
        // fallback to session value if form didn't include it
        if (studentId == null || studentId.trim().isEmpty()) {
            studentId = (String) session.getAttribute("studentId");
        }

        String fullName = request.getParameter("fullName");
        String phoneNumber = request.getParameter("phoneNumber");
        String dateOfBirth = request.getParameter("dateOfBirth");

        StudentDAO sdao = new StudentDAO();
        boolean ok = sdao.updateStudentDetails(studentId, fullName, phoneNumber, dateOfBirth);

        if (ok) {
            if (fullName != null && !fullName.trim().isEmpty()) {
                session.setAttribute("studentName", fullName.trim());
            }
            StudentProfilePicUtil.bindToSession(session, getServletContext(), studentId);
            response.sendRedirect(request.getContextPath() + "/student/edit-profile?saved=1");
        } else {
            request.setAttribute("error", "Unable to update profile. Please try again.");
            doGet(request, response);
        }
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
}
