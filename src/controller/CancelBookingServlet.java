package controller;

import dao.ClassScheduleDAO;
import dao.StudentBookingDAO;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;

@WebServlet("/student/cancel-booking")
public class CancelBookingServlet extends HttpServlet {
    private StudentBookingDAO bookingDAO = new StudentBookingDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String studentId = (String) session.getAttribute("studentId");
        
        if (studentId == null) {
            response.sendRedirect(request.getContextPath() + "/student/login");
            return;
        }

        String bookingId = request.getParameter("bookingId");
        String reason = request.getParameter("reason");

        if (reason == null || reason.trim().isEmpty()) {
            reason = "No reason provided";
        }

        ClassScheduleDAO scheduleDAO = new ClassScheduleDAO();
        if (!scheduleDAO.isCancellationAllowedByBookingId(bookingId)) {
            session.setAttribute("errorMessage", ClassScheduleDAO.CANCEL_TOO_LATE_MSG);
        } else {
            boolean success = bookingDAO.cancelBooking(bookingId, reason);
            if (success) {
                session.setAttribute("successMessage", "Booking cancelled successfully!");
            } else {
                session.setAttribute("errorMessage", "Failed to cancel booking. Please try again.");
            }
        }

        response.sendRedirect(request.getContextPath() + "/student/class-booking");
    }
}
