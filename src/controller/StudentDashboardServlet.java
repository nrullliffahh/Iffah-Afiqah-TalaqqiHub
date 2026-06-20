package controller;

import dao.*;
import model.*;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

public class StudentDashboardServlet extends HttpServlet {

    private SessionDAO sessionDAO;
    private AttendanceDAO attendanceDAO;
    private AnnouncementDAO announcementDAO;
    private EvaluationDAO evaluationDAO;

    @Override
    public void init() {
        sessionDAO = new SessionDAO();
        attendanceDAO = new AttendanceDAO();
        announcementDAO = new AnnouncementDAO();
        evaluationDAO = new EvaluationDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        if (session == null || session.getAttribute("studentId") == null) {
            response.sendRedirect(request.getContextPath() + "/student/login");
            return;
        }
        
        String studentId = (String) session.getAttribute("studentId");
        String studentName = (String) session.getAttribute("studentName");
        
        int upcomingClassCount = sessionDAO.getUpcomingSessionCount(studentId);
        double attendanceRate = attendanceDAO.getAttendanceRate(studentId);
        int completedSessions = sessionDAO.getCompletedSessionCountByMonth(studentId);
        int totalSessions = sessionDAO.getTotalSessionCount(studentId);

        // Prefer package-defined total sessions for the student so completed/total align
        try {
            dao.StudentDAO _sdao = new dao.StudentDAO();
            model.Student _studentObj = _sdao.getStudentById(studentId);
            if (_studentObj != null && _studentObj.getPackageId() != null) {
                String studentPkgRaw = _studentObj.getPackageId();
                String digits = studentPkgRaw.replaceAll("\\D+", "");
                int studentPkgInt = digits.isEmpty() ? -1 : Integer.parseInt(digits);

                dao.PackageDAO _pdao = new dao.PackageDAO();
                for (model.Package p : _pdao.getAllPackages()) {
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
        } catch (Exception ignore) {}
        String evaluationResult = evaluationDAO.getLatestEvaluationResult(studentId);
        
        Session nextSession = sessionDAO.getNextUpcomingSession(studentId);
        List<Announcement> announcementList = announcementDAO.getLatestAnnouncements(2);
        int announcementCount = announcementDAO.getAnnouncementCount();

        // Provide demo/fallback values when DAO returns empty or null data (useful for staging/demo)
        if (evaluationResult == null || evaluationResult.trim().isEmpty() || "N/A".equals(evaluationResult)) {
            evaluationResult = "—";
        }

        if (announcementList == null || announcementList.isEmpty()) {
            announcementList = new java.util.ArrayList<>();
            model.Announcement a1 = new model.Announcement();
            a1.setAnnouncementId("A001");
            a1.setTitle("Welcome to TalaqqiHub");
            a1.setDate(java.time.LocalDate.now().toString());
            a1.setDescription("Get started by joining your first Talaqqi session.");
            announcementList.add(a1);

            // only include a single welcome announcement for demo
            announcementCount = announcementList.size();
        }
        
        request.setAttribute("studentName", studentName);
        request.setAttribute("upcomingClassCount", upcomingClassCount);
        request.setAttribute("attendanceRate", String.format("%.0f", attendanceRate));
        request.setAttribute("completedSessions", completedSessions);
        request.setAttribute("totalSessions", totalSessions);
        request.setAttribute("evaluationResult", evaluationResult);
        request.setAttribute("nextSession", nextSession);
        request.setAttribute("announcementList", announcementList);
        request.setAttribute("announcementCount", announcementCount);
        // resolve package name for student (display on dashboard)
        String packageName = "-";
        try {
            dao.StudentDAO sdao = new dao.StudentDAO();
            model.Student studentObj = sdao.getStudentById(studentId);
            if (studentObj != null && studentObj.getPackageId() != null) {
                String studentPkgRaw = studentObj.getPackageId();
                String digits = studentPkgRaw.replaceAll("\\D+", "");
                int studentPkgInt = digits.isEmpty() ? -1 : Integer.parseInt(digits);

                dao.PackageDAO pdao = new dao.PackageDAO();
                for (model.Package p : pdao.getAllPackages()) {
                    if (studentPkgInt != -1 && p.getPackageId() == studentPkgInt) {
                        packageName = p.getPackageName();
                        break;
                    }
                    if (String.valueOf(p.getPackageId()).equals(studentPkgRaw)) {
                        packageName = p.getPackageName();
                        break;
                    }
                }
            }
        } catch (Exception ignore) {
        }

        request.setAttribute("packageName", packageName);
        
        request.getRequestDispatcher("/WEB-INF/views/studentDashboard.jsp").forward(request, response);
    }
}
