package controller;

import util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

/**
 * TeacherClassDetailsServlet
 * 
 * Fetches detailed information about a specific class (completed or cancelled)
 * for display in the Class Details modal.
 * 
 * Returns JSON with student info, class details, booking status, and cancellation reason.
 */
public class TeacherClassDetailsServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check authentication: allow either teacher or admin sessions
        HttpSession session = request.getSession(false);
        if (session == null || (session.getAttribute("teacherId") == null && session.getAttribute("adminId") == null)) {
            response.setContentType("application/json");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\":false,\"error\":\"Unauthorized\"}");
            return;
        }

        String teacherId = (String) session.getAttribute("teacherId");
        boolean isAdmin = session.getAttribute("adminId") != null;
        String scheduleId = request.getParameter("scheduleId");
        System.out.println("[TeacherClassDetailsServlet] Incoming request: teacherId=" + teacherId + ", scheduleId=" + scheduleId);
        
        if (scheduleId == null || scheduleId.trim().isEmpty()) {
            response.setContentType("application/json");
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\":false,\"error\":\"Schedule ID is required\"}");
            return;
        }
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            Map<String, Object> classDetails = getClassDetails(scheduleId, teacherId, isAdmin);
            
            if (classDetails == null || classDetails.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"success\":false,\"error\":\"Class not found\"}");
                return;
            }
            
            // Wrap in success response
            PrintWriter out = response.getWriter();
            out.print("{\"success\":true,\"details\":");
            out.print(mapToJson(classDetails));
            out.print("}");
            out.flush();
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false,\"error\":\"Internal server error: " + e.getMessage() + "\"}");
        }
    }
    
    /**
     * Fetch class details from database
     * Uses scheduleId as primary identifier with LEFT JOIN for booking
     * This allows viewing details even if booking record is missing
     */
    private Map<String, Object> getClassDetails(String scheduleId, String teacherId, boolean isAdmin) {
        Map<String, Object> details = new HashMap<>();
        String sql = "SELECT " +
                 "cs.scheduleId, cs.className, cs.duration, cs.classStatus, " +
                 "cs.scheduleDate, cs.startTime, cs.endTime, " +
                 "b.bookingId, b.bookingStatus, b.bookingDate, b.bookingTime, " +
                 "s.studentId, s.studentName, s.studentEmail, " +
                 "t.teacherName, " +
                 "cs.createdAt AS createdAt, b.createdAt AS bookingCreatedAt, " +
                 "sc.cancellationReason, sc.cancelledAt " +
                 "FROM classschedule cs " +
                 "LEFT JOIN classbooking b ON cs.scheduleId = b.scheduleId " +
                 "LEFT JOIN student s ON b.studentId = s.studentId " +
                 "LEFT JOIN teacher t ON cs.teacherId = t.teacherId " +
                     "LEFT JOIN studentcancellation sc ON b.bookingId = sc.bookingId " +
                     (isAdmin ? "WHERE cs.scheduleId = ? OR b.scheduleId = ?" : "WHERE cs.scheduleId = ? AND cs.teacherId = ?");

        System.out.println("[TeacherClassDetailsServlet] [DEBUG] Before DB connection");
        try (Connection conn = DBConnection.getConnection()) {
            // Try primary query first; if the schema lacks cs.createdAt or b.createdAt
            // fall back to a query that returns NULL for those columns.
            String primarySql = sql;
            String fallbackSql = primarySql.replace("cs.createdAt AS createdAt, b.createdAt AS bookingCreatedAt, ",
                                                    "NULL AS createdAt, NULL AS bookingCreatedAt, ");

            PreparedStatement ps = null;
            ResultSet rs = null;
            boolean usedFallback = false;
            try {
                System.out.println("[TeacherClassDetailsServlet] [DEBUG] After DB connection, before primary query");
                ps = conn.prepareStatement(primarySql);
                ps.setString(1, scheduleId);
                if (isAdmin) {
                    ps.setString(2, scheduleId);
                } else {
                    ps.setString(2, teacherId);
                }
                long tQueryStart = System.currentTimeMillis();
                rs = ps.executeQuery();
                long tQueryEnd = System.currentTimeMillis();
                System.out.println("[TeacherClassDetailsServlet] [DEBUG] Primary query executed in " + (tQueryEnd - tQueryStart) + " ms");
            } catch (SQLException se) {
                // Handle missing-column errors by retrying with fallback SQL
                String msg = se.getMessage() != null ? se.getMessage() : "";
                if (msg.contains("Unknown column 'cs.createdAt'") || msg.contains("Unknown column 'b.createdAt'") || msg.contains("Unknown column cs.createdAt") ) {
                    System.out.println("[TeacherClassDetailsServlet] Primary query failed due to missing column; retrying with fallback SQL");
                    if (ps != null) try { ps.close(); } catch (Exception ignore) {}
                    usedFallback = true;
                    ps = conn.prepareStatement(fallbackSql);
                    ps.setString(1, scheduleId);
                    if (isAdmin) {
                        ps.setString(2, scheduleId);
                    } else {
                        ps.setString(2, teacherId);
                    }
                    long tQueryStart = System.currentTimeMillis();
                    rs = ps.executeQuery();
                    long tQueryEnd = System.currentTimeMillis();
                    System.out.println("[TeacherClassDetailsServlet] Fallback query executed in " + (tQueryEnd - tQueryStart) + " ms");
                } else {
                    throw se;
                }
            }

            if (rs != null) {
                if (rs.next()) {
                    // Student information (may be NULL if no booking)
                    String studentName = rs.getString("studentName");
                    String studentId = rs.getString("studentId");
                    
                    details.put("studentId", studentId != null ? studentId : "N/A");
                    details.put("studentName", studentName != null ? studentName : "Unknown");
                    details.put("studentInitials", studentName != null ? getInitials(studentName) : "?");
                    
                    // Class information (from classschedule - always available)
                    details.put("className", rs.getString("className"));
                    details.put("duration", rs.getInt("duration"));
                    
                    // Date and time - format properly for display
                    java.sql.Date scheduleDate = rs.getDate("scheduleDate");
                    java.sql.Time startTime = rs.getTime("startTime");
                    java.sql.Time endTime = rs.getTime("endTime");
                    
                    // Format date as "Day, Month DD, YYYY"
                    if (scheduleDate != null) {
                        java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("EEEE, MMMM d, yyyy");
                        details.put("scheduleDate", dateFormat.format(scheduleDate));
                    } else {
                        details.put("scheduleDate", "N/A");
                    }
                    
                    // Format times as "HH:mm"
                    if (startTime != null) {
                        java.text.SimpleDateFormat timeFormat = new java.text.SimpleDateFormat("HH:mm");
                        details.put("startTime", timeFormat.format(startTime));
                    } else {
                        details.put("startTime", "N/A");
                    }
                    
                    if (endTime != null) {
                        java.text.SimpleDateFormat timeFormat = new java.text.SimpleDateFormat("HH:mm");
                        details.put("endTime", timeFormat.format(endTime));
                    } else {
                        details.put("endTime", "N/A");
                    }
                    
                    // Status - use bookingStatus if present, otherwise classStatus
                    String bookingStatus = rs.getString("bookingStatus");
                    String classStatus = rs.getString("classStatus");
                    String rawStatus = bookingStatus != null ? bookingStatus : classStatus;
                    String displayStatus = normalizeStatus(rawStatus);
                    details.put("status", displayStatus != null ? displayStatus : "Unknown");

                    // History timestamps (best-effort)
                    java.sql.Timestamp createdAtTs = null;
                    java.sql.Timestamp bookingCreatedAtTs = null;
                    try {
                        createdAtTs = rs.getTimestamp("createdAt");
                    } catch (SQLException ignore) {
                        createdAtTs = null;
                    }
                    try {
                        bookingCreatedAtTs = rs.getTimestamp("bookingCreatedAt");
                    } catch (SQLException ignore) {
                        bookingCreatedAtTs = null;
                    }

                    // Format history entries
                    java.text.SimpleDateFormat histFmt = new java.text.SimpleDateFormat("MMM d, yyyy h:mm a");
                    details.put("historyCreatedAt", createdAtTs != null ? histFmt.format(createdAtTs) : "");
                    details.put("historyCreatedNote", "Class slot created by teacher");
                    details.put("historyBookedAt", bookingCreatedAtTs != null ? histFmt.format(bookingCreatedAtTs) : "");
                    details.put("historyBookedNote", rs.getString("studentName") != null ? "Booked by student " + rs.getString("studentName") : "Booked");
                    details.put("historyCancelledAt", rs.getTimestamp("cancelledAt") != null ? histFmt.format(rs.getTimestamp("cancelledAt")) : "");
                    details.put("historyCancelledNote", rs.getString("cancellationReason") != null ? rs.getString("cancellationReason") : "");

                    // Cancellation information (if cancelled)
                    if ("Cancelled".equalsIgnoreCase(displayStatus)) {
                        String cancellationReason = rs.getString("cancellationReason");
                        details.put("cancellationReason", cancellationReason != null ? cancellationReason : "No reason provided");
                        details.put("cancelledAt", rs.getTimestamp("cancelledAt") != null ? 
                                   rs.getTimestamp("cancelledAt").toString() : "");
                    }
                    
                    // BookingId is optional
                    String bookingId = rs.getString("bookingId");
                    details.put("bookingId", bookingId != null ? bookingId : "");
                    // Teacher name
                    details.put("teacherName", rs.getString("teacherName") != null ? rs.getString("teacherName") : "-");
                }
            }
            // If no rows were found (e.g., classschedule row missing), try fallback by querying classbooking directly (admin only)
            if (details.isEmpty() && isAdmin) {
                System.out.println("[TeacherClassDetailsServlet] No rows from primary query — trying booking-centric fallback for scheduleId=" + scheduleId);
                String fallback = "SELECT b.bookingId, b.bookingStatus, b.bookingDate, b.bookingTime, b.createdAt AS bookingCreatedAt, " +
                                  "b.studentId, s.studentName, cs.scheduleId AS cs_scheduleId, cs.className, cs.duration, cs.scheduleDate, cs.startTime, cs.endTime, t.teacherName, sc.cancellationReason, sc.cancelledAt " +
                                  "FROM classbooking b " +
                                  "LEFT JOIN student s ON b.studentId = s.studentId " +
                                  "LEFT JOIN classschedule cs ON b.scheduleId = cs.scheduleId " +
                                  "LEFT JOIN teacher t ON cs.teacherId = t.teacherId " +
                                  "LEFT JOIN studentcancellation sc ON b.bookingId = sc.bookingId " +
                                  "WHERE b.scheduleId = ? LIMIT 1";
                try (PreparedStatement ps2 = conn.prepareStatement(fallback)) {
                    ps2.setString(1, scheduleId);
                    try (ResultSet rs2 = ps2.executeQuery()) {
                        if (rs2.next()) {
                            details.put("studentId", rs2.getString("studentId") != null ? rs2.getString("studentId") : "N/A");
                            details.put("studentName", rs2.getString("studentName") != null ? rs2.getString("studentName") : "Unknown");
                            details.put("studentInitials", rs2.getString("studentName") != null ? getInitials(rs2.getString("studentName")) : "?");
                            details.put("className", rs2.getString("className"));
                            details.put("duration", rs2.getInt("duration"));
                            java.sql.Date scheduleDate2 = rs2.getDate("scheduleDate");
                            java.sql.Time startTime2 = rs2.getTime("startTime");
                            java.sql.Time endTime2 = rs2.getTime("endTime");
                            if (scheduleDate2 != null) {
                                java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("EEEE, MMMM d, yyyy");
                                details.put("scheduleDate", dateFormat.format(scheduleDate2));
                            } else {
                                details.put("scheduleDate", "N/A");
                            }
                            java.text.SimpleDateFormat timeFormat = new java.text.SimpleDateFormat("HH:mm");
                            details.put("startTime", startTime2 != null ? timeFormat.format(startTime2) : "N/A");
                            details.put("endTime", endTime2 != null ? timeFormat.format(endTime2) : "N/A");

                            String bookingStatus2 = rs2.getString("bookingStatus");
                            String displayStatus2 = normalizeStatus(bookingStatus2 != null ? bookingStatus2 : null);
                            details.put("status", displayStatus2 != null ? displayStatus2 : "Unknown");

                            // history
                            java.sql.Timestamp bookingCreated = null;
                            try { bookingCreated = rs2.getTimestamp("bookingCreatedAt"); } catch (Exception ignore) {}
                            java.text.SimpleDateFormat histFmt = new java.text.SimpleDateFormat("MMM d, yyyy h:mm a");
                            details.put("historyCreatedAt", "");
                            details.put("historyCreatedNote", "");
                            details.put("historyBookedAt", bookingCreated != null ? histFmt.format(bookingCreated) : "");
                            details.put("historyBookedNote", rs2.getString("studentName") != null ? "Booked by student " + rs2.getString("studentName") : "Booked");
                            details.put("historyCancelledAt", rs2.getTimestamp("cancelledAt") != null ? histFmt.format(rs2.getTimestamp("cancelledAt")) : "");
                            details.put("historyCancelledNote", rs2.getString("cancellationReason") != null ? rs2.getString("cancellationReason") : "");

                            details.put("teacherName", rs2.getString("teacherName") != null ? rs2.getString("teacherName") : "-");
                            details.put("bookingId", rs2.getString("bookingId") != null ? rs2.getString("bookingId") : "");
                        }
                    }
                } catch (SQLException se) {
                    System.err.println("Fallback booking-centric query failed: " + se.getMessage());
                    se.printStackTrace();
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
        
        return details;
    }

    /**
     * Normalize various internal status values to the admin/teacher-facing labels
     * e.g. 'Booked', 'Scheduled', 'Available', 'Approved' -> 'Upcoming'
     */
    private String normalizeStatus(String status) {
        if (status == null) return null;
        String s = status.trim().toLowerCase();
        if (s.equals("booked") || s.equals("scheduled") || s.equals("available") || s.equals("confirmed") || s.equals("approved") || s.equals("upcoming")) {
            return "Upcoming";
        } else if (s.equals("completed")) {
            return "Completed";
        } else if (s.equals("rescheduled") || s.equals("reschedule")) {
            return "Rescheduled";
        } else if (s.equals("cancelled") || s.equals("canceled")) {
            return "Cancelled";
        } else {
            // Capitalize first letter for unknown values
            if (status.length() == 0) return status;
            return status.substring(0,1).toUpperCase() + (status.length() > 1 ? status.substring(1) : "");
        }
    }
    
    /**
     * Generate initials from student name
     * Example: "Omar Abdullah" -> "OA"
     */
    private String getInitials(String name) {
        if (name == null || name.trim().isEmpty()) {
            return "??";
        }
        
        String[] parts = name.trim().split("\\s+");
        StringBuilder initials = new StringBuilder();
        
        for (int i = 0; i < Math.min(2, parts.length); i++) {
            if (!parts[i].isEmpty()) {
                initials.append(parts[i].charAt(0));
            }
        }
        
        return initials.toString().toUpperCase();
    }
    
    /**
     * Convert Map to JSON string manually (without Gson)
     */
    private String mapToJson(Map<String, Object> map) {
        StringBuilder json = new StringBuilder();
        json.append("{");
        
        boolean first = true;
        for (Map.Entry<String, Object> entry : map.entrySet()) {
            if (!first) {
                json.append(",");
            }
            first = false;
            
            json.append("\"").append(entry.getKey()).append("\":");
            
            Object value = entry.getValue();
            if (value == null) {
                json.append("null");
            } else if (value instanceof String) {
                json.append("\"").append(escapeJson((String) value)).append("\"");
            } else if (value instanceof Number) {
                json.append(value);
            } else {
                json.append("\"").append(value.toString()).append("\"");
            }
        }
        
        json.append("}");
        return json.toString();
    }
    
    /**
     * Escape special characters for JSON
     */
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}
