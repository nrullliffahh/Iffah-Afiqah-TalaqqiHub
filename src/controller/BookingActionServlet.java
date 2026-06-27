package controller;

import dao.StudentBookingDAO;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;

@WebServlet("/student/book-session")
public class BookingActionServlet extends HttpServlet {
    private StudentBookingDAO bookingDAO = new StudentBookingDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String studentId = (String) session.getAttribute("studentId");
        
        if (studentId == null) {
            response.sendRedirect(request.getContextPath() + "/student/login");
            return;
        }

        String scheduleId = request.getParameter("scheduleId");
        String bookingDateStr = request.getParameter("bookingDate");
        String bookingTimeStr = request.getParameter("bookingTime");

        try {
            LocalDate bookingDate = LocalDate.parse(bookingDateStr);
            LocalTime bookingTime = LocalTime.parse(bookingTimeStr);

            // Ensure a classschedule record exists for this scheduleId so teacher views can pick it up
            try {
                String teacherIdParam = request.getParameter("teacherId");
                bookingDAO.ensureScheduleExists(scheduleId, bookingDate, bookingTime, teacherIdParam);
            } catch (Exception ee) {
                // ignore — non-fatal
                ee.printStackTrace();
            }

            // Validate schedule is still bookable before attempting insert
            boolean bookable = bookingDAO.isScheduleBookable(scheduleId, bookingDate, bookingTime);
            if (!bookable) {
                session.setAttribute("errorMessage", "Selected slot is no longer available. Please choose another slot.");
            } else {
                String newBookingId = bookingDAO.bookSession(studentId, scheduleId, bookingDate, bookingTime);
                if (newBookingId != null) {
                    String rescheduleBookingId = request.getParameter("rescheduleBookingId");
                    boolean isReschedule = rescheduleBookingId != null && !rescheduleBookingId.trim().isEmpty();
                    if (isReschedule) {
                        try {
                            System.out.println("[BookingActionServlet] received rescheduleBookingId=" + rescheduleBookingId);
                            boolean resOk = bookingDAO.rescheduleBooking(rescheduleBookingId, "Rescheduled to " + bookingDateStr);
                            System.out.println("[BookingActionServlet] rescheduleBooking result=" + resOk + " for bookingId=" + rescheduleBookingId);
                            if (resOk) {
                                session.setAttribute("successMessage", "Class rescheduled successfully!");
                            } else {
                                session.setAttribute("successMessage", "New slot booked successfully.");
                                session.setAttribute("errorMessage", "Could not update your previous booking. Please contact support if the old class still appears.");
                            }
                        } catch (Exception ee) {
                            ee.printStackTrace();
                            session.setAttribute("successMessage", "New slot booked successfully.");
                            session.setAttribute("errorMessage", "Could not update your previous booking. Please contact support if the old class still appears.");
                        }
                    } else {
                        session.setAttribute("successMessage", "Class booked successfully!");
                    }
                } else {
                    session.setAttribute("errorMessage", "Failed to book class. Please try again.");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Invalid date or time format.");
        }

        // Redirect back to booking page and preserve the selected date so the calendar keeps the selection
        if (bookingDateStr != null && !bookingDateStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/student/class-booking?selectedDate=" + bookingDateStr);
        } else {
            response.sendRedirect(request.getContextPath() + "/student/class-booking");
        }
    }
}
