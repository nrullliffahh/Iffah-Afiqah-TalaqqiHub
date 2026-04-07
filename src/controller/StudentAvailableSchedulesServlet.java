package controller;

import dao.StudentBookingDAO;
import model.ClassSchedule;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@WebServlet("/student/api/available-schedules")
public class StudentAvailableSchedulesServlet extends HttpServlet {
    private StudentBookingDAO bookingDAO = new StudentBookingDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String selectedDate = req.getParameter("selectedDate");
        String monthParam = req.getParameter("month");
        String yearParam = req.getParameter("year");
        resp.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = resp.getWriter()) {
            // If month/year provided, return list of dates in that month that have availability
            if (monthParam != null && yearParam != null && !monthParam.isEmpty() && !yearParam.isEmpty()) {
                try {
                    int month = Integer.parseInt(monthParam);
                    int year = Integer.parseInt(yearParam);
                    String mode = req.getParameter("mode");
                    List<String> dates;
                    if ("booked".equalsIgnoreCase(mode)) {
                        // Prefer student-specific booked dates so highlight is visible only to the student who booked
                        String sessionStudentId = null;
                        try {
                            Object sid = req.getSession().getAttribute("studentId");
                            if (sid != null) sessionStudentId = sid.toString();
                        } catch (Exception ignore) {}

                        if (sessionStudentId != null && !sessionStudentId.trim().isEmpty()) {
                            dates = bookingDAO.getBookedDatesForMonthForStudent(year, month, sessionStudentId);
                        } else {
                            dates = bookingDAO.getBookedDatesForMonth(year, month);
                        }
                    } else {
                        dates = bookingDAO.getAvailableDatesForMonth(year, month);
                    }
                    // write JSON array of strings
                    out.write("[");
                    for (int i = 0; i < dates.size(); i++) {
                        if (i > 0) out.write(",");
                        out.write('"' + escapeJson(dates.get(i)) + '"');
                    }
                    out.write("]");
                    return;
                } catch (NumberFormatException nfe) {
                    out.write("[]");
                    return;
                }
            }

            if (selectedDate == null || selectedDate.isEmpty()) {
                out.write("[]");
                return;
            }

            LocalDate date = LocalDate.parse(selectedDate);
            // Use DAO method that includes booking info so UI can render booked slots as disabled
            List<Map<String, Object>> schedules = bookingDAO.getSchedulesWithBookingInfoByDate(date);

            StringBuilder sb = new StringBuilder();
            sb.append('[');
            boolean first = true;
            for (Map<String, Object> s : schedules) {
                if (!first) sb.append(',');
                first = false;
                sb.append('{');
                sb.append("\"scheduleId\":\"").append(escapeJson(String.valueOf(s.get("scheduleId")))).append("\"");
                sb.append(',');
                sb.append("\"startTime\":\"").append(escapeJson(String.valueOf(s.get("startTime")))).append("\"");
                sb.append(',');
                sb.append("\"endTime\":\"").append(escapeJson(String.valueOf(s.get("endTime")))).append("\"");
                sb.append(',');
                sb.append("\"duration\":").append(s.get("duration") != null ? s.get("duration") : 15);
                sb.append(',');
                sb.append("\"teacherName\":\"").append(escapeJson(String.valueOf(s.get("teacherName")))).append("\"");
                sb.append(',');
                sb.append("\"teacherId\":\"").append(escapeJson(String.valueOf(s.get("teacherId")))).append("\"");
                sb.append(',');
                // robustly determine booked boolean (could be Boolean or string/number)
                Object bookedObj = s.get("booked");
                boolean bookedFlag = false;
                if (bookedObj instanceof Boolean) {
                    bookedFlag = (Boolean) bookedObj;
                } else if (bookedObj != null) {
                    String bs = String.valueOf(bookedObj);
                    bookedFlag = "1".equals(bs) || "true".equalsIgnoreCase(bs);
                }
                sb.append("\"booked\":").append(bookedFlag);
                sb.append(',');
                sb.append("\"bookingId\":\"").append(escapeJson(String.valueOf(s.get("bookingId")))).append("\"");
                sb.append(',');
                sb.append("\"bookingStudentId\":\"").append(escapeJson(String.valueOf(s.get("bookingStudentId")))).append("\"");
                sb.append(',');
                sb.append("\"bookingStatus\":\"").append(escapeJson(String.valueOf(s.get("bookingStatus")))).append("\"");
                sb.append('}');
            }
            sb.append(']');
            out.write(sb.toString());
        } catch (Exception e) {
            resp.setStatus(500);
            resp.getWriter().write("[]");
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\","\\\\").replace("\"","\\\"").replace("\n","\\n").replace("\r","\\r");
    }
}
