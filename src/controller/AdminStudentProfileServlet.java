package controller;

import dao.StudentDAO;
import dao.PackageDAO;
import dao.SessionDAO;
import model.Package;
import model.Student;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class AdminStudentProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        String studentId = request.getParameter("studentId");
        if (studentId == null || studentId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-students");
            return;
        }

        StudentDAO dao = new StudentDAO();
        Student student = dao.getStudentById(studentId);

        // resolve package name from PackageDAO if packageId present
        String packageName = "-";
        if (student != null && student.getPackageId() != null) {
            try {
                String studentPkgRaw = student.getPackageId(); // e.g. 'P003' or '3'
                String digits = studentPkgRaw.replaceAll("\\D+", "");
                int studentPkgInt = digits.isEmpty() ? -1 : Integer.parseInt(digits);

                PackageDAO pdao = new PackageDAO();
                for (Package p : pdao.getAllPackages()) {
                    if (studentPkgInt != -1 && p.getPackageId() == studentPkgInt) {
                        packageName = p.getPackageName();
                        break;
                    }
                    // also allow direct string match if packageId stored as plain number string
                    if (String.valueOf(p.getPackageId()).equals(studentPkgRaw)) {
                        packageName = p.getPackageName();
                        break;
                    }
                }
            } catch (Exception ignore) {
                // leave packageName as '-'
            }
        }

        // session statistics: total sessions from package, used from session records
        int totalSessions = 0;
        int usedSessions = 0;
        int remainingSessions = 0;
        int upcomingSessions = 0;
        int progressPercentage = 0;

        try {
            if (student != null && student.getPackageId() != null) {
                String studentPkgRaw = student.getPackageId();
                String digits = studentPkgRaw.replaceAll("\\D+", "");
                int studentPkgInt = digits.isEmpty() ? -1 : Integer.parseInt(digits);

                PackageDAO pdao = new PackageDAO();
                for (Package p : pdao.getAllPackages()) {
                    if (studentPkgInt != -1 && p.getPackageId() == studentPkgInt) {
                        totalSessions = p.getSessions();
                        break;
                    }
                    if (String.valueOf(p.getPackageId()).equals(studentPkgRaw)) {
                        totalSessions = p.getSessions();
                        break;
                    }
                }
            }

            SessionDAO sdao = new SessionDAO();
            if (student != null) {
                usedSessions = sdao.getCompletedSessionCount(student.getStudentId());
                upcomingSessions = sdao.getUpcomingSessionCount(student.getStudentId());
            }

            remainingSessions = Math.max(0, totalSessions - usedSessions);
            progressPercentage = totalSessions > 0 ? (int) Math.round((usedSessions * 100.0) / totalSessions) : 0;
        } catch (Exception ignore) {}

        request.setAttribute("student", student);
        request.setAttribute("packageName", packageName);
        request.setAttribute("totalSessions", totalSessions);
        request.setAttribute("usedSessions", usedSessions);
        request.setAttribute("remainingSessions", remainingSessions);
        request.setAttribute("upcomingSessions", upcomingSessions);
        request.setAttribute("progressPercentage", progressPercentage);

        request.getRequestDispatcher("/WEB-INF/views/adminStudentProfile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }
}
