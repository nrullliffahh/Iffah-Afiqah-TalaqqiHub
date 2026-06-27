package controller;

import dao.StudentAttendanceDAO;
import model.StudentAttendance;
import util.SessionRoleUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;

public class StudentAttendanceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!SessionRoleUtil.isStudentLoggedIn(session)) {
            response.sendRedirect(request.getContextPath() + "/student/login");
            return;
        }

        String studentId = SessionRoleUtil.getStudentId(session);
        StudentAttendanceDAO dao = new StudentAttendanceDAO();

        List<StudentAttendance> records = dao.getAttendanceByStudentByMonth(studentId);
        int total = dao.getTotalSessionsByMonth(studentId);
        int present = dao.getPresentCountByMonth(studentId);
        int absent = dao.getAbsentCountByMonth(studentId);
        int late = dao.getLateCountByMonth(studentId);

        int attended = present + late;
        double rate = (total > 0) ? Math.round(((double) attended / total) * 100) : 0;

        Map<String, Integer> trendDetails = dao.getAttendanceTrendDetails(studentId);

        request.setAttribute("records", records);
        request.setAttribute("total", total);
        request.setAttribute("present", present);
        request.setAttribute("absent", absent);
        request.setAttribute("late", late);
        request.setAttribute("rate", (int) rate);
        request.setAttribute("trendDetails", trendDetails);

        request.getRequestDispatcher("/WEB-INF/views/studentAttendance.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
