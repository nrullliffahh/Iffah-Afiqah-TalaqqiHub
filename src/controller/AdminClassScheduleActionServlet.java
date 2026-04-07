package controller;

import dao.ClassScheduleDAO;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class AdminClassScheduleActionServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        String action = request.getParameter("action");
        String scheduleId = request.getParameter("scheduleId");

        ClassScheduleDAO dao = new ClassScheduleDAO();

        if (action == null || scheduleId == null) {
            response.sendRedirect(request.getContextPath() + "/admin/class-schedule");
            return;
        }

        switch (action) {
            case "changeStatus":
                String newStatus = request.getParameter("newStatus");
                if (newStatus != null && !newStatus.trim().isEmpty()) {
                    dao.updateClassStatus(scheduleId, newStatus);
                }
                break;
            case "reschedule":
                try {
                    String date = request.getParameter("newDate");
                    String start = request.getParameter("newStart");
                    String end = request.getParameter("newEnd");
                    LocalDate d = LocalDate.parse(date);
                    LocalTime s = LocalTime.parse(start);
                    LocalTime e = LocalTime.parse(end);
                    dao.rescheduleClass(scheduleId, d, s, e);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
                break;
            default:
                // unknown action
                break;
        }

        response.sendRedirect(request.getContextPath() + "/admin/class-schedule");
    }
}
