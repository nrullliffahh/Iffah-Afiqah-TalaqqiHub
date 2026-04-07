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
                boolean success = bookingDAO.bookSession(studentId, scheduleId, bookingDate, bookingTime);
                    if (success) {
                        // If this booking is part of a reschedule flow, cancel the old booking
                        String rescheduleBookingId = request.getParameter("rescheduleBookingId");
                        if (rescheduleBookingId != null && !rescheduleBookingId.trim().isEmpty()) {
                            try {
                                System.out.println("[BookingActionServlet] received rescheduleBookingId=" + rescheduleBookingId);
                                boolean resOk = bookingDAO.rescheduleBooking(rescheduleBookingId, "Rescheduled to " + bookingDateStr);
                                System.out.println("[BookingActionServlet] rescheduleBooking result=" + resOk + " for bookingId=" + rescheduleBookingId);
                                if (!resOk) {
                                    // Inform user/admin that marking old booking failed
                                    session.setAttribute("errorMessage", "Booked new slot but failed to mark previous booking as rescheduled. Please contact support.");
                                }
                            } catch (Exception ee) {
                                // non-fatal if reschedule flag fails; log and set message
                                ee.printStackTrace();
                                session.setAttribute("errorMessage", "Booked new slot but failed to update the previous booking status.");
                            }
                        }
                        session.setAttribute("successMessage", "Class booked successfully!");
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
