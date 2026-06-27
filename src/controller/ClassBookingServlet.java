package controller;

import dao.ClassScheduleDAO;
import dao.StudentBookingDAO;
import model.StudentBooking;
import model.ClassSchedule;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@WebServlet("/student/class-booking")
public class ClassBookingServlet extends HttpServlet {
    private StudentBookingDAO bookingDAO = new StudentBookingDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String studentId = (String) session.getAttribute("studentId");

        // Debug/test override: allow viewing another student's bookings by passing ?asStudent=ID
        String asStudent = request.getParameter("asStudent");
        if (asStudent != null && !asStudent.isEmpty()) {
            // Use the provided student id for this request only (does not replace session unless you want to)
            studentId = asStudent;
        }

        if (studentId == null) {
            response.sendRedirect(request.getContextPath() + "/student/login");
            return;
        }

        Map<String, Object> summary = bookingDAO.getBookingSummary(studentId);
        List<StudentBooking> myBookings = bookingDAO.getMyBookingsByMonth(studentId);

        ClassScheduleDAO scheduleDAO = new ClassScheduleDAO();
        if (myBookings != null) {
            for (StudentBooking booking : myBookings) {
                if (booking.getBookingId() != null) {
                    booking.setCancellationAllowed(
                        scheduleDAO.isCancellationAllowedByBookingId(booking.getBookingId()));
                }
            }
        }

        // Partition bookings: Upcoming, Completed, then Cancelled/Rescheduled
        java.util.List<StudentBooking> upcomingBookings = new java.util.ArrayList<>();
        java.util.List<StudentBooking> completedBookings = new java.util.ArrayList<>();
        java.util.List<StudentBooking> cancelledBookings = new java.util.ArrayList<>();
        if (myBookings != null) {
            for (StudentBooking b : myBookings) {
                String status = b.getBookingStatus();
                if (status == null) {
                    status = "";
                }
                switch (status) {
                    case "Completed":
                        if (b.isFutureSession()) {
                            upcomingBookings.add(b);
                        } else {
                            completedBookings.add(b);
                        }
                        break;
                    case "Cancelled":
                    case "Rescheduled":
                        cancelledBookings.add(b);
                        break;
                    default:
                        upcomingBookings.add(b);
                        break;
                }
            }
        }
        
        String selectedDate = request.getParameter("selectedDate");
        List<ClassSchedule> availableSchedules = null;
        
        if (selectedDate != null && !selectedDate.isEmpty()) {
            try {
                LocalDate date = LocalDate.parse(selectedDate);
                availableSchedules = bookingDAO.getAvailableSchedulesByDate(date);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        request.setAttribute("summary", summary);
        request.setAttribute("myBookings", myBookings);
        request.setAttribute("upcomingBookings", upcomingBookings);
        request.setAttribute("completedBookings", completedBookings);
        request.setAttribute("cancelledBookings", cancelledBookings);
        request.setAttribute("availableSchedules", availableSchedules);
        request.setAttribute("selectedDate", selectedDate);
        
        // Forward to the real JSP
        request.getRequestDispatcher("/WEB-INF/views/classBooking.jsp").forward(request, response);
    }
}