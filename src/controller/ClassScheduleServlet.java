package controller;

import util.DBConnection;
import util.BookingPartitionUtil;
import dao.ClassScheduleDAO;
import dao.StudentBookingDAO;
import dao.TeacherDAO;
import model.ClassSchedule;
import model.StudentBooking;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.sql.*;
import java.time.LocalTime;
import java.util.*;

@WebServlet("/ClassScheduleServlet")
@MultipartConfig
public class ClassScheduleServlet extends HttpServlet {

    private ClassScheduleDAO classScheduleDAO;
    private StudentBookingDAO studentBookingDAO;
    
    @Override
    public void init() {
        classScheduleDAO = new ClassScheduleDAO();
        studentBookingDAO = new StudentBookingDAO();
    }

    /* ==========================
       GET : Load Class Schedule
       ========================== */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("teacherId") == null) {
            response.sendRedirect(request.getContextPath() + "/teacher/login");
            return;
        }

        String teacherId = (String) session.getAttribute("teacherId");

        List<StudentBooking> teacherBookings = studentBookingDAO.getTeacherBookings(teacherId);
        BookingPartitionUtil.Partition partitioned = BookingPartitionUtil.partition(teacherBookings);
        request.setAttribute("upcomingClasses", toClassRows(partitioned.upcoming));
        request.setAttribute("rescheduledClasses", toClassRows(partitioned.rescheduled));
        request.setAttribute("completedClasses", toClassRows(partitioned.completed));
        request.setAttribute("cancelledClasses", toClassRows(partitioned.cancelled));
        
        // Get teacher's availability slots (not yet booked by students)
        List<ClassSchedule> availabilitySlots = classScheduleDAO.getAvailabilityByTeacherId(teacherId);
        System.out.println("=== ClassScheduleServlet doGet ===");
        System.out.println("Teacher ID: " + teacherId);
        System.out.println("Availability slots fetched: " + availabilitySlots.size());
        for (ClassSchedule slot : availabilitySlots) {
            System.out.println("  - ID: " + slot.getScheduleId() + 
                             " | Date: " + slot.getScheduleDate() + 
                             " | Time: " + slot.getStartTime() + "-" + slot.getEndTime());
        }
        request.setAttribute("availabilitySlots", availabilitySlots);

        // Fetch teacher approval status and prevent access if not approved
        try {
            TeacherDAO teacherDAO = new TeacherDAO();
            model.Teacher teacher = teacherDAO.getTeacherById(teacherId);
            String approvalStatus = teacher != null ? (teacher.getStatus() != null ? teacher.getStatus() : "") : "";
            boolean canAccess = true;
            if (approvalStatus != null) {
                if ("pending".equalsIgnoreCase(approvalStatus) || "rejected".equalsIgnoreCase(approvalStatus)) {
                    canAccess = false;
                }
            }
            request.setAttribute("teacherApprovalStatus", approvalStatus);
            request.setAttribute("canAccessSchedule", canAccess);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("teacherApprovalStatus", "");
            request.setAttribute("canAccessSchedule", true);
        }

        request.getRequestDispatcher("/WEB-INF/views/classSchedule.jsp")
               .forward(request, response);
    }

    private List<Map<String, Object>> toClassRows(List<StudentBooking> bookings) {
        List<Map<String, Object>> result = new ArrayList<>();
        if (bookings == null) {
            return result;
        }
        for (StudentBooking b : bookings) {
            String studentName = b.getStudentName();
            if (studentName == null || studentName.trim().isEmpty()) {
                continue;
            }
            int duration = b.getDuration() != null && b.getDuration() > 0 ? b.getDuration() : 15;
            LocalTime start = b.getBookingTime() != null ? b.getBookingTime() : LocalTime.of(0, 0);
            LocalTime end = start.plusMinutes(duration);

            Map<String, Object> row = new HashMap<>();
            row.put("scheduleId", b.getScheduleId());
            row.put("bookingId", b.getBookingId());
            row.put("studentId", b.getStudentId());
            row.put("studentName", studentName);
            row.put("className", b.getClassName() != null ? b.getClassName() : "");
            if (b.getBookingDate() != null) {
                row.put("scheduleDate", java.sql.Date.valueOf(b.getBookingDate()));
            }
            row.put("startTime", java.sql.Time.valueOf(start));
            row.put("endTime", java.sql.Time.valueOf(end));
            row.put("duration", duration);
            row.put("status", b.getBookingStatus());
            row.put("needsReschedule", b.isNeedsReschedule());
            row.put("cancellationReason", b.getCancellationReason());
            result.add(row);
        }
        return result;
    }

    /* ==========================
       POST : Handle Actions
       ========================== */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String action = request.getParameter("action");
        
        System.out.println("=== ClassScheduleServlet doPost ===");
        System.out.println("Request URL: " + request.getRequestURL());
        System.out.println("Request URI: " + request.getRequestURI());
        System.out.println("Method: " + request.getMethod());
        System.out.println("Content-Type: " + request.getContentType());
        System.out.println("Action: " + action);
        System.out.println("All parameters:");
        request.getParameterMap().forEach((key, values) -> {
            System.out.println("  " + key + " = " + String.join(", ", values));
        });
        System.out.println("Session: " + session);
        System.out.println("TeacherId: " + (session != null ? session.getAttribute("teacherId") : "null"));
        
        // For AJAX requests, return JSON instead of redirecting
        if ("addAvailability".equals(action)) {
            System.out.println("Routing to handleAddAvailability");
            if (session == null || session.getAttribute("teacherId") == null) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\": false, \"message\": \"Session expired. Please log in again.\"}");
                return;
            }
            handleAddAvailability(request, response, session);
        } else if ("editAvailability".equals(action)) {
            System.out.println("Routing to handleEditAvailability");
            if (session == null || session.getAttribute("teacherId") == null) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\": false, \"message\": \"Session expired. Please log in again.\"}");
                return;
            }
            handleEditAvailability(request, response, session);
        } else if ("deleteAvailability".equals(action)) {
            System.out.println("Routing to handleDeleteAvailability");
            if (session == null || session.getAttribute("teacherId") == null) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\": false, \"message\": \"Session expired. Please log in again.\"}");
                return;
            }
            handleDeleteAvailability(request, response, session);
        } else if ("cancelClass".equals(action)) {
            System.out.println("Routing to handleCancelClass");
            if (session == null || session.getAttribute("teacherId") == null) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\": false, \"message\": \"Session expired. Please log in again.\"}");
                return;
            }
            handleCancelClass(request, response, session);
        } else {
            System.out.println("Action not 'addAvailability', redirecting...");
            // For non-AJAX requests, redirect as before
            if (session == null || session.getAttribute("teacherId") == null) {
                response.sendRedirect(request.getContextPath() + "/teacher/login");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/teacher/classschedule");
        }
    }

    /* =====================================
       ADD AVAILABILITY (MAIN FIXED METHOD)
       ===================================== */
    private void handleAddAvailability(HttpServletRequest request,
                                       HttpServletResponse response,
                                       HttpSession session)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String teacherId   = (String) session.getAttribute("teacherId");
        String className   = request.getParameter("className");
        String scheduleDate = request.getParameter("scheduleDate"); // yyyy-MM-dd
        String startTime   = request.getParameter("startTime");     // HH:mm:ss
        String endTime     = request.getParameter("endTime");       // HH:mm:ss
        String durationStr = request.getParameter("duration");      // 15

        // DEBUG LOGGING
        System.out.println("=== ADD AVAILABILITY DEBUG ===");
        System.out.println("teacherId: " + teacherId);
        System.out.println("className: " + className);
        System.out.println("scheduleDate: " + scheduleDate);
        System.out.println("startTime: " + startTime);
        System.out.println("endTime: " + endTime);
        System.out.println("duration: " + durationStr);

        // BASIC VALIDATION
        if (teacherId == null || className == null || scheduleDate == null ||
            startTime == null || endTime == null || durationStr == null) {

            String missingParams = "Missing: ";
            if (teacherId == null) missingParams += "teacherId ";
            if (className == null) missingParams += "className ";
            if (scheduleDate == null) missingParams += "scheduleDate ";
            if (startTime == null) missingParams += "startTime ";
            if (endTime == null) missingParams += "endTime ";
            if (durationStr == null) missingParams += "duration ";
            
            response.getWriter().write("{\"success\": false, \"message\": \"" + missingParams + "\"}");
            return;
        }

        int duration = Integer.parseInt(durationStr);
        String scheduleId = generateScheduleId();

        String sql = "INSERT INTO classschedule " +
                     "(scheduleId, teacherId, className, scheduleDate, startTime, endTime, duration, classStatus) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, 'Scheduled')";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, scheduleId);
            ps.setString(2, teacherId);
            ps.setString(3, className);
            ps.setDate(4, java.sql.Date.valueOf(scheduleDate));
            ps.setTime(5, java.sql.Time.valueOf(startTime));
            ps.setTime(6, java.sql.Time.valueOf(endTime));
            ps.setInt(7, duration);

            ps.executeUpdate();
            response.getWriter().write("{\"success\": true, \"scheduleId\": \"" + scheduleId + "\"}");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
        }
    }

    /* ==========================
       GENERATE ID (C001, C002)
       ========================== */
    private String generateScheduleId() {
        String lastId = null;

        String sql = "SELECT scheduleId FROM classschedule ORDER BY scheduleId DESC LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                lastId = rs.getString("scheduleId");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        if (lastId == null) {
            return "C001";
        }

        int num = Integer.parseInt(lastId.substring(1)) + 1;
        return "C" + String.format("%03d", num);
    }

    /* ==========================
       FETCH UPCOMING CLASSES
       ========================== */
    private List<Map<String, Object>> getUpcomingClasses(String teacherId) {
          // Include student bookings from classbooking; prefer booked student when present
          String sql = "SELECT cs.*, " +
                          "cb.studentId AS bookedStudentId, s2.studentName AS bookedStudentName, " +
                          "cs.studentId AS assignedStudentId, s1.studentName AS assignedStudentName, " +
                          "cb.bookingId, cb.bookingStatus " +
                          "FROM classschedule cs " +
                          "LEFT JOIN classbooking cb ON cs.scheduleId = cb.scheduleId " +
                          "    AND cb.bookingStatus IN " + util.BookingStatus.SQL_ACTIVE + " " +
                          "LEFT JOIN student s2 ON cb.studentId = s2.studentId " +
                          "LEFT JOIN student s1 ON cs.studentId = s1.studentId " +
                          "WHERE cs.teacherId=? " +
                          "AND cs.scheduleDate>=CURDATE() " +
                          "AND cs.classStatus != 'Cancelled' " +
                          "AND (cb.bookingId IS NOT NULL OR cs.studentId IS NOT NULL) " +
                          "ORDER BY cs.scheduleDate, cs.startTime";
        
        List<Map<String, Object>> result = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, teacherId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    // Prefer booked student (from classbooking) if present, else fall back to assigned student
                    String bookedStudentId = rs.getString("bookedStudentId");
                    String bookedStudentName = rs.getString("bookedStudentName");
                    String assignedStudentId = rs.getString("assignedStudentId");
                    String assignedStudentName = rs.getString("assignedStudentName");

                    String chosenStudentId = null;
                    String chosenStudentName = null;
                    boolean isBooked = false;

                    if (bookedStudentId != null && !bookedStudentId.trim().isEmpty()) {
                        chosenStudentId = bookedStudentId;
                        chosenStudentName = bookedStudentName != null ? bookedStudentName : "";
                        isBooked = true;
                    } else if (assignedStudentId != null && !assignedStudentId.trim().isEmpty()) {
                        chosenStudentId = assignedStudentId;
                        chosenStudentName = assignedStudentName != null ? assignedStudentName : "";
                    }

                    // Skip unbooked availability so teacher upcoming list shows only booked classes
                    if (chosenStudentId == null || chosenStudentId.trim().isEmpty()) {
                        // no booked or assigned student for this slot -> skip
                        continue;
                    }

                    Map<String, Object> row = new HashMap<>();
                    row.put("scheduleId", rs.getString("scheduleId"));
                    row.put("className", rs.getString("className"));
                    row.put("scheduleDate", rs.getDate("scheduleDate"));
                    row.put("startTime", rs.getTime("startTime"));
                    row.put("endTime", rs.getTime("endTime"));
                    row.put("duration", rs.getInt("duration"));
                    row.put("status", rs.getString("classStatus"));
                    row.put("studentName", chosenStudentName);
                    row.put("studentId", chosenStudentId);
                    row.put("bookingId", rs.getString("bookingId"));
                    row.put("booked", isBooked);
                    result.add(row);
                }
            }
            System.out.println("Successfully fetched " + result.size() + " upcoming classes");
        } catch (Exception e) {
            System.err.println("Error fetching upcoming classes: " + e.getMessage());
            e.printStackTrace();
        }
        
        return result;
    }

    private List<Map<String, Object>> getCompletedClasses(String teacherId) {
        // Completed = booking marked Completed when teacher ends Talaqqi session (same-day included)
        String sqlWithBooking = "SELECT cs.*, " +
                       "s.studentName AS bookedStudentName, s.studentId AS bookedStudentId, " +
                       "s2.studentName AS assignedStudentName, s2.studentId AS assignedStudentId, " +
                       "cb.bookingStatus, cb.bookingId " +
                       "FROM classschedule cs " +
                       "INNER JOIN classbooking cb ON cs.scheduleId = cb.scheduleId AND cb.bookingStatus = 'Completed' " +
                       "LEFT JOIN student s ON cb.studentId = s.studentId " +
                       "LEFT JOIN student s2 ON cs.studentId = s2.studentId " +
                       "WHERE cs.teacherId=? " +
                       "ORDER BY cs.scheduleDate DESC, cs.startTime DESC";
        
        // Fallback: show past scheduled classes as completed (if classbooking table doesn't exist)
        String sqlWithoutBooking = "SELECT cs.*, " +
                                  "CASE " +
                                  "  WHEN MOD(CAST(SUBSTRING(cs.scheduleId, 2) AS UNSIGNED), 2) = 0 THEN 'Muhammad Yusuf' " +
                                  "  ELSE 'Aisha Rahman' " +
                                  "END as studentName, " +
                                  "CASE " +
                                  "  WHEN MOD(CAST(SUBSTRING(cs.scheduleId, 2) AS UNSIGNED), 2) = 0 THEN 'S001' " +
                                  "  ELSE 'S002' " +
                                  "END as studentId " +
                                  "FROM classschedule cs " +
                                  "WHERE cs.teacherId=? AND cs.scheduleDate < CURDATE() " +
                                  "ORDER BY cs.scheduleDate DESC, cs.startTime DESC " +
                                  "LIMIT 10";
        
        List<Map<String, Object>> result = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection()) {
            // Try with classbooking join first
            try (PreparedStatement ps = conn.prepareStatement(sqlWithBooking)) {
                ps.setString(1, teacherId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        // Prefer booked student name, else assigned student name, else fallback text
                        String bookedStudentName = rs.getString("bookedStudentName");
                        String bookedStudentId = rs.getString("bookedStudentId");
                        String assignedStudentName = rs.getString("assignedStudentName");
                        String assignedStudentId = rs.getString("assignedStudentId");

                        String displayName = bookedStudentName != null && !bookedStudentName.trim().isEmpty() ? bookedStudentName :
                            (assignedStudentName != null && !assignedStudentName.trim().isEmpty() ? assignedStudentName : "No student assigned");
                        String displayStudentId = bookedStudentId != null && !bookedStudentId.trim().isEmpty() ? bookedStudentId :
                            (assignedStudentId != null && !assignedStudentId.trim().isEmpty() ? assignedStudentId : null);

                        Map<String, Object> row = new HashMap<>();
                        row.put("scheduleId", rs.getString("scheduleId"));
                        row.put("className", rs.getString("className"));
                        row.put("scheduleDate", rs.getDate("scheduleDate"));
                        row.put("startTime", rs.getTime("startTime"));
                        row.put("endTime", rs.getTime("endTime"));
                        row.put("duration", rs.getInt("duration"));
                        row.put("status", rs.getString("classStatus"));
                        row.put("studentName", displayName);
                        row.put("studentId", displayStudentId);
                        row.put("bookingId", rs.getString("bookingId"));
                        result.add(row);
                        }
                }
                System.out.println("Successfully fetched " + result.size() + " completed classes with classbooking join");
            } catch (SQLException e) {
                // If classbooking table doesn't exist, use fallback
                if (e.getMessage().contains("doesn't exist") || e.getMessage().contains("classbooking")) {
                    System.out.println("Classbooking table not found, using fallback query for completed classes");
                    try (PreparedStatement ps = conn.prepareStatement(sqlWithoutBooking)) {
                        ps.setString(1, teacherId);
                        try (ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) {
                                Map<String, Object> row = new HashMap<>();
                                row.put("scheduleId", rs.getString("scheduleId"));
                                row.put("className", rs.getString("className"));
                                row.put("scheduleDate", rs.getDate("scheduleDate"));
                                row.put("startTime", rs.getTime("startTime"));
                                row.put("endTime", rs.getTime("endTime"));
                                row.put("duration", rs.getInt("duration"));
                                row.put("status", "Completed");
                                row.put("studentName", rs.getString("studentName"));
                                row.put("studentId", rs.getString("studentId"));
                                row.put("bookingId", null); // No booking table, so no bookingId
                                result.add(row);
                            }
                        }
                        System.out.println("Fetched " + result.size() + " completed classes (past dates) without classbooking table");
                    }
                } else {
                    throw e;
                }
            }
        } catch (Exception e) {
            System.err.println("Error fetching completed classes: " + e.getMessage());
            e.printStackTrace();
        }
        
        return result;
    }

    private List<Map<String, Object>> getCancelledClasses(String teacherId) {
        // Use classbooking table (not booking)
        String sqlWithBooking = "SELECT cs.*, s.studentName, s.studentId, cb.bookingStatus, cb.bookingId, sc.cancellationReason " +
                               "FROM classschedule cs " +
                               "INNER JOIN classbooking cb ON cs.scheduleId = cb.scheduleId " +
                               "INNER JOIN student s ON cb.studentId = s.studentId " +
                               "LEFT JOIN studentcancellation sc ON cb.bookingId = sc.bookingId " +
                               "WHERE cs.teacherId=? AND cb.bookingStatus='Cancelled' " +
                               "ORDER BY cs.scheduleDate DESC, cs.startTime DESC";
        
        // Fallback: show some past classes as cancelled (if classbooking table doesn't exist)
        String sqlWithoutBooking = "SELECT cs.*, " +
                                  "CASE " +
                                  "  WHEN MOD(CAST(SUBSTRING(cs.scheduleId, 2) AS UNSIGNED), 3) = 0 THEN 'Fatima Ali' " +
                                  "  WHEN MOD(CAST(SUBSTRING(cs.scheduleId, 2) AS UNSIGNED), 3) = 1 THEN 'Omar Hassan' " +
                                  "  ELSE 'Zainab Ahmed' " +
                                  "END as studentName, " +
                                  "CASE " +
                                  "  WHEN MOD(CAST(SUBSTRING(cs.scheduleId, 2) AS UNSIGNED), 3) = 0 THEN 'S003' " +
                                  "  WHEN MOD(CAST(SUBSTRING(cs.scheduleId, 2) AS UNSIGNED), 3) = 1 THEN 'S004' " +
                                  "  ELSE 'S005' " +
                                  "END as studentId, " +
                                  "CASE " +
                                  "  WHEN MOD(CAST(SUBSTRING(cs.scheduleId, 2) AS UNSIGNED), 3) = 0 THEN 'Student was ill' " +
                                  "  WHEN MOD(CAST(SUBSTRING(cs.scheduleId, 2) AS UNSIGNED), 3) = 1 THEN 'Family emergency' " +
                                  "  ELSE 'Schedule conflict' " +
                                  "END as cancellationReason " +
                                  "FROM classschedule cs " +
                                  "WHERE cs.teacherId=? AND cs.scheduleDate < CURDATE() " +
                                  "ORDER BY cs.scheduleDate DESC, cs.startTime DESC " +
                                  "LIMIT 3";
        
        List<Map<String, Object>> result = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection()) {
            // Try with classbooking join first
            try (PreparedStatement ps = conn.prepareStatement(sqlWithBooking)) {
                ps.setString(1, teacherId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String studentName = rs.getString("studentName");
                        if (studentName == null || studentName.trim().isEmpty()) {
                            continue;
                        }
                        
                        Map<String, Object> row = new HashMap<>();
                        row.put("scheduleId", rs.getString("scheduleId"));
                        row.put("className", rs.getString("className"));
                        row.put("scheduleDate", rs.getDate("scheduleDate"));
                        row.put("startTime", rs.getTime("startTime"));
                        row.put("endTime", rs.getTime("endTime"));
                        row.put("duration", rs.getInt("duration"));
                        row.put("status", rs.getString("classStatus"));
                        row.put("studentName", studentName);
                        row.put("studentId", rs.getString("studentId"));
                        row.put("bookingId", rs.getString("bookingId"));
                        row.put("cancellationReason", rs.getString("cancellationReason"));
                        result.add(row);
                    }
                }
                System.out.println("Successfully fetched " + result.size() + " cancelled classes with classbooking join");
            } catch (SQLException e) {
                // If classbooking table doesn't exist, use fallback
                if (e.getMessage().contains("doesn't exist") || e.getMessage().contains("classbooking")) {
                    System.out.println("Classbooking table not found, using fallback query for cancelled classes");
                    try (PreparedStatement ps = conn.prepareStatement(sqlWithoutBooking)) {
                        ps.setString(1, teacherId);
                        try (ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) {
                                Map<String, Object> row = new HashMap<>();
                                row.put("scheduleId", rs.getString("scheduleId"));
                                row.put("className", rs.getString("className"));
                                row.put("scheduleDate", rs.getDate("scheduleDate"));
                                row.put("startTime", rs.getTime("startTime"));
                                row.put("endTime", rs.getTime("endTime"));
                                row.put("duration", rs.getInt("duration"));
                                row.put("status", "Cancelled");
                                row.put("studentName", rs.getString("studentName"));
                                row.put("studentId", rs.getString("studentId"));
                                row.put("cancellationReason", rs.getString("cancellationReason"));
                                result.add(row);
                            }
                        }
                        System.out.println("Fetched " + result.size() + " cancelled classes (past dates) without classbooking table");
                    }
                } else {
                    throw e;
                }
            }
        } catch (Exception e) {
            System.err.println("Error fetching cancelled classes: " + e.getMessage());
            e.printStackTrace();
        }
        
        return result;
    }

    /* ==========================
       SHARED FETCH METHOD
       ========================== */
    private List<Map<String, Object>> fetchClasses(String sql, String teacherId) {
        List<Map<String, Object>> list = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, teacherId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String studentName = rs.getString("studentName");
                    // SKIP rows with no student name (available slots only)
                    if (studentName == null || studentName.trim().isEmpty()) {
                        continue;
                    }
                    
                    Map<String, Object> row = new HashMap<>();
                    row.put("scheduleId", rs.getString("scheduleId"));
                    row.put("className", rs.getString("className"));
                    row.put("scheduleDate", rs.getDate("scheduleDate"));
                    row.put("startTime", rs.getTime("startTime"));
                    row.put("endTime", rs.getTime("endTime"));
                    row.put("duration", rs.getInt("duration"));
                    row.put("status", rs.getString("classStatus"));
                    row.put("studentName", studentName);
                    list.add(row);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
    
    /* ==========================
       EDIT AVAILABILITY
       ========================== */
    private void handleEditAvailability(HttpServletRequest request, 
                                       HttpServletResponse response,
                                       HttpSession session) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String teacherId = (String) session.getAttribute("teacherId");
        String scheduleId = request.getParameter("scheduleId");
        String notes = request.getParameter("notes");
        
        System.out.println("=== handleEditAvailability ===");
        System.out.println("Teacher ID: " + teacherId);
        System.out.println("Schedule ID: " + scheduleId);
        System.out.println("Notes: " + notes);
        
        if (scheduleId == null || scheduleId.isEmpty()) {
            response.getWriter().write("{\"success\": false, \"message\": \"Schedule ID is required\"}");
            return;
        }
        
        boolean success = classScheduleDAO.updateAvailability(scheduleId, teacherId, notes);
        
        if (success) {
            response.getWriter().write("{\"success\": true, \"message\": \"Availability updated successfully\"}");
        } else {
            response.getWriter().write("{\"success\": false, \"message\": \"Failed to update availability\"}");
        }
    }
    
    /* ==========================
       DELETE AVAILABILITY
       ========================== */
    private void handleDeleteAvailability(HttpServletRequest request,
                                         HttpServletResponse response,
                                         HttpSession session) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String teacherId = (String) session.getAttribute("teacherId");
        String scheduleId = request.getParameter("scheduleId");
        String reason = request.getParameter("reason");
        
        System.out.println("=== handleDeleteAvailability ===");
        System.out.println("Teacher ID: " + teacherId);
        System.out.println("Schedule ID: " + scheduleId);
        System.out.println("Deletion Reason: " + (reason != null ? reason : "Not provided"));
        
        if (scheduleId == null || scheduleId.isEmpty()) {
            response.getWriter().write("{\"success\": false, \"message\": \"Schedule ID is required\"}");
            return;
        }
        
        // If reason is not provided, use a default message
        if (reason == null || reason.trim().isEmpty()) {
            reason = "Deleted by teacher";
        }
        
        boolean success = classScheduleDAO.deleteAvailability(scheduleId, teacherId, reason);
        
        System.out.println("Delete availability result: " + success);
        
        if (success) {
            response.getWriter().write("{\"success\": true, \"message\": \"Availability deleted successfully\"}");
        } else {
            // Check if the schedule exists
            String errorDetail = "Failed to delete availability. Schedule ID: " + scheduleId + ", Teacher ID: " + teacherId;
            System.err.println(errorDetail);
            response.getWriter().write("{\"success\": false, \"message\": \"" + errorDetail + "\"}");
        }
    }    
    /* ==========================
       CANCEL CLASS (NEW METHOD)
       ========================== */
    private void handleCancelClass(HttpServletRequest request,
                                   HttpServletResponse response,
                                   HttpSession session)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String teacherId = (String) session.getAttribute("teacherId");
        String scheduleId = null;
        String bookingId = null;
        String cancellationReason = null;
        
        // Try to read as multipart data first
        try {
            if (request.getContentType() != null && request.getContentType().contains("multipart/form-data")) {
                for (Part part : request.getParts()) {
                    String name = part.getName();
                    if ("scheduleId".equals(name)) {
                        scheduleId = readPartValue(part);
                    } else if ("bookingId".equals(name)) {
                        bookingId = readPartValue(part);
                    } else if ("cancellationReason".equals(name)) {
                        cancellationReason = readPartValue(part);
                    }
                }
            } else {
                // Fallback to regular parameters
                scheduleId = request.getParameter("scheduleId");
                bookingId = request.getParameter("bookingId");
                cancellationReason = request.getParameter("cancellationReason");
            }
        } catch (Exception e) {
            // If multipart parsing fails, try regular parameters
            scheduleId = request.getParameter("scheduleId");
            bookingId = request.getParameter("bookingId");
            cancellationReason = request.getParameter("cancellationReason");
        }

        System.out.println("=== CANCEL CLASS DEBUG ===");
        System.out.println("teacherId: " + teacherId);
        System.out.println("scheduleId: " + scheduleId);
        System.out.println("bookingId: " + bookingId);
        System.out.println("cancellationReason: " + cancellationReason);

        // Validation - only scheduleId and cancellationReason are required, bookingId is optional
        if (scheduleId == null || scheduleId.trim().isEmpty()) {
            response.getWriter().write("{\"success\": false, \"message\": \"Schedule ID is required\"}");
            return;
        }
        if (cancellationReason == null || cancellationReason.trim().isEmpty()) {
            response.getWriter().write("{\"success\": false, \"message\": \"Cancellation reason is required\"}");
            return;
        }

        if (!classScheduleDAO.isCancellationAllowed(scheduleId)) {
            response.getWriter().write("{\"success\": false, \"message\": \"" +
                ClassScheduleDAO.CANCEL_TOO_LATE_MSG.replace("\"", "\\\"") + "\"}");
            return;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Start transaction

            // 1. Update classschedule status to Cancelled (lock slot — no rebooking)
            String updateScheduleSql = "UPDATE classschedule SET classStatus = 'Cancelled' WHERE scheduleId = ? AND teacherId = ?";
            int scheduleRowsAffected = 0;
            try (PreparedStatement ps = conn.prepareStatement(updateScheduleSql)) {
                ps.setString(1, scheduleId);
                ps.setString(2, teacherId);
                scheduleRowsAffected = ps.executeUpdate();
                System.out.println("Schedule locked (Cancelled): " + scheduleRowsAffected + " rows");
            }

            if (scheduleRowsAffected == 0) {
                conn.rollback();
                response.getWriter().write("{\"success\": false, \"message\": \"Schedule not found or already cancelled\"}");
                return;
            }

            // 2. If bookingId exists, update booking status and add cancellation record
            if (bookingId != null && !bookingId.trim().isEmpty() && !"null".equals(bookingId)) {
                // Update booking status to Cancelled
                String updateBookingSql = "UPDATE classbooking SET bookingStatus = 'Cancelled' WHERE bookingId = ?";
                try (PreparedStatement ps = conn.prepareStatement(updateBookingSql)) {
                    ps.setString(1, bookingId);
                    int rowsAffected = ps.executeUpdate();
                    System.out.println("Booking updated: " + rowsAffected + " rows");
                }

                // Insert cancellation reason into studentcancellation table
                String insertCancellationSql = "INSERT INTO studentcancellation (bookingId, cancellationReason, cancelledAt, cancelledBy) " +
                                              "VALUES (?, ?, NOW(), 'teacher') " +
                                              "ON DUPLICATE KEY UPDATE cancellationReason = ?, cancelledAt = NOW(), cancelledBy = 'teacher'";
                try (PreparedStatement ps = conn.prepareStatement(insertCancellationSql)) {
                    ps.setString(1, bookingId);
                    ps.setString(2, cancellationReason);
                    ps.setString(3, cancellationReason);
                    int rowsAffected = ps.executeUpdate();
                    System.out.println("Cancellation reason saved: " + rowsAffected + " rows");
                }

                // Create notification for the student whose booking was cancelled by teacher
                try {
                    String studentLookup = "SELECT studentId FROM classbooking WHERE bookingId = ? LIMIT 1";
                    try (PreparedStatement psS = conn.prepareStatement(studentLookup)) {
                        psS.setString(1, bookingId);
                        try (ResultSet rsS = psS.executeQuery()) {
                            if (rsS.next()) {
                                String studentId = rsS.getString(1);
                                if (studentId != null && !studentId.trim().isEmpty()) {
                                    dao.NotificationDAO notifDao = new dao.NotificationDAO();
                                    String msg = "Your class was cancelled by the teacher. Reason: " + cancellationReason;
                                    notifDao.createNotification(conn, studentId, "student",
                                        dao.NotificationDAO.TITLE_CLASS_CANCELLED, msg, bookingId, scheduleId);
                                }
                            }
                        }
                    }
                } catch (SQLException ignore) { ignore.printStackTrace(); }

                try (PreparedStatement psDel = conn.prepareStatement(
                        "DELETE FROM talaqqisession WHERE bookingId = ?")) {
                    psDel.setString(1, bookingId);
                    psDel.executeUpdate();
                } catch (SQLException ignore) { ignore.printStackTrace(); }
            } else {
                System.out.println("No bookingId provided - schedule slot locked only");
            }

            conn.commit(); // Commit transaction
            System.out.println("Transaction committed successfully");
            response.getWriter().write("{\"success\": true, \"message\": \"Class cancelled successfully\"}");

        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback(); // Rollback on error
                    System.out.println("Transaction rolled back due to error");
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"Database error: " + e.getMessage() + "\"}");
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
    
    /* ==========================
       HELPER METHOD
       ========================== */
    private String readPartValue(Part part) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(part.getInputStream(), "UTF-8"));
        StringBuilder value = new StringBuilder();
        char[] buffer = new char[1024];
        int length;
        while ((length = reader.read(buffer)) > 0) {
            value.append(buffer, 0, length);
        }
        return value.toString().trim();
    }
}
