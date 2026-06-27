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
import java.util.ArrayList;
import java.util.Collections;
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
        Map<String, Map<String, Integer>> weeklyTrend = dao.getWeeklyAttendanceTrend(studentId);

        List<Integer> presentTrend = new ArrayList<>();
        List<Integer> absentTrend = new ArrayList<>();
        List<Integer> lateTrend = new ArrayList<>();
        for (int w = 1; w <= 4; w++) {
            Map<String, Integer> counts = weeklyTrend.getOrDefault("Week " + w, Collections.emptyMap());
            presentTrend.add(counts.getOrDefault("Present", 0));
            absentTrend.add(counts.getOrDefault("Absent", 0));
            lateTrend.add(counts.getOrDefault("Late", 0));
        }

        request.setAttribute("records", records);
        request.setAttribute("total", total);
        request.setAttribute("present", present);
        request.setAttribute("absent", absent);
        request.setAttribute("late", late);
        request.setAttribute("rate", (int) rate);
        request.setAttribute("trendDetails", trendDetails);
        request.setAttribute("presentTrendJson", toJsonArray(presentTrend));
        request.setAttribute("absentTrendJson", toJsonArray(absentTrend));
        request.setAttribute("lateTrendJson", toJsonArray(lateTrend));

        request.getRequestDispatcher("/WEB-INF/views/studentAttendance.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    private static String toJsonArray(List<Integer> values) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < values.size(); i++) {
            if (i > 0) {
                sb.append(',');
            }
            sb.append(values.get(i));
        }
        sb.append(']');
        return sb.toString();
    }
}
