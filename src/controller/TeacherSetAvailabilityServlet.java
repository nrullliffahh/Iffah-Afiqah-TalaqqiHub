package controller;

import dao.ClassScheduleDAO;
import model.ClassSchedule;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.BufferedReader;
import java.io.PrintWriter;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class TeacherSetAvailabilityServlet extends HttpServlet {
    
    private ClassScheduleDAO classScheduleDAO;
    
    @Override
    public void init() {
        classScheduleDAO = new ClassScheduleDAO();
    }

    // Try to normalize various time input formats into HH:mm:ss (or HH:mm)
    private String normalizeTime(String t) {
        if (t == null) return null;
        String s = t.trim();
        // If already HH:mm or HH:mm:ss, return as-is (pad seconds if missing will happen later)
        if (s.matches("\\d{2}:\\d{2}(:\\d{2})?")) {
            return s;
        }

        // Try parsing common patterns like "8:30 am", "8:30pm", "8:30"
        java.time.LocalTime lt = null;
        java.time.format.DateTimeFormatter[] fmts = new java.time.format.DateTimeFormatter[] {
            java.time.format.DateTimeFormatter.ofPattern("h:mm a"),
            java.time.format.DateTimeFormatter.ofPattern("hh:mm a"),
            java.time.format.DateTimeFormatter.ofPattern("H:mm"),
            java.time.format.DateTimeFormatter.ofPattern("HH:mm")
        };

        // Uppercase AM/PM for parsing
        String candidate = s.replaceAll("\\s+", " ").toUpperCase();
        for (java.time.format.DateTimeFormatter fmt : fmts) {
            try {
                lt = java.time.LocalTime.parse(candidate, fmt);
                break;
            } catch (Exception ex) {
                // ignore and try next
            }
        }

        if (lt != null) {
            return lt.toString(); // yields HH:mm[:ss]
        }

        return s; // return original if unable to parse
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set response content type to JSON
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("teacherId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\": false, \"message\": \"Not authenticated\"}");
            return;
        }
        
        String teacherId = (String) session.getAttribute("teacherId");
        String contentType = request.getContentType();
        
        System.out.println("=== Request Info ===");
        System.out.println("Content-Type: " + contentType);
        System.out.println("Teacher ID: " + teacherId);
        
        String scheduleDate = null;
        String startTime = null;
        String endTime = null;
        String className = null;
        
        try {
            // Read the raw request body first
            StringBuilder rawBody = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                rawBody.append(line);
            }
            
            String bodyContent = rawBody.toString();
            System.out.println("Raw body: " + bodyContent);
            
            // Check if request is JSON
            if (contentType != null && contentType.toLowerCase().contains("application/json")) {
                // Simple JSON parsing without external library
                scheduleDate = extractJsonValue(bodyContent, "scheduleDate");
                startTime = extractJsonValue(bodyContent, "startTime");
                endTime = extractJsonValue(bodyContent, "endTime");
                className = extractJsonValue(bodyContent, "className");
                
                System.out.println("Parsed values - Date: " + scheduleDate + ", Start: " + startTime + ", End: " + endTime + ", Class: " + className);
            } else {
                // If not JSON, try to parse as form data (fallback)
                System.out.println("Not JSON, checking for form parameters");
                scheduleDate = request.getParameter("scheduleDate");
                startTime = request.getParameter("startTime");
                endTime = request.getParameter("endTime");
                className = request.getParameter("className");
            }
            
            // Validate required fields
            if (scheduleDate == null || startTime == null || endTime == null || className == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"message\": \"Missing required fields. Got: date=" + scheduleDate + ", start=" + startTime + ", end=" + endTime + ", class=" + className + "\"}");
                return;
            }
            
            // Validate date format - check for malformed data
            if (scheduleDate.contains("--") || scheduleDate.equals("null") || scheduleDate.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"message\": \"Invalid date format: " + scheduleDate + ". Please select a valid date.\"}");
                return;
            }
            
            // Normalize time formats server-side (accept "8:30 am", "08:30", "8:30", or HH:mm:ss)
            System.out.println("Raw times from client - startTime: '" + startTime + "', endTime: '" + endTime + "'");

            startTime = normalizeTime(startTime);
            endTime = normalizeTime(endTime);

            System.out.println("Normalized times - startTime: '" + startTime + "', endTime: '" + endTime + "'");

            // Validate time format - must now be HH:mm or HH:mm:ss
            if (startTime == null || startTime.contains("--") || startTime.isEmpty() || !startTime.matches("\\d{2}:\\d{2}(:\\d{2})?")) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"message\": \"Invalid start time format: " + startTime + ". Expected HH:mm:ss format.\"}");
                return;
            }

            if (endTime == null || endTime.contains("--") || endTime.isEmpty() || !endTime.matches("\\d{2}:\\d{2}(:\\d{2})?")) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"message\": \"Invalid end time format: " + endTime + ". Expected HH:mm:ss format.\"}");
                return;
            }
            
            ClassSchedule schedule = new ClassSchedule();
            // Generate sequential ID (C001, C002, C003, etc.)
            String scheduleId = classScheduleDAO.generateNextScheduleId();
            schedule.setScheduleId(scheduleId);
            schedule.setClassName(className);
            schedule.setScheduleDate(scheduleDate);
            schedule.setStartTime(startTime);
            schedule.setEndTime(endTime);
            schedule.setDuration(15);
            schedule.setClassStatus("Scheduled");
            schedule.setTeacherId(teacherId);
            
            System.out.println("Attempting to insert availability with ID: " + scheduleId + " for teacher: " + teacherId);
            boolean success = classScheduleDAO.insertAvailability(schedule);
            System.out.println("Insert result: " + success);
            
            PrintWriter out = response.getWriter();
            if (!success) {
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                out.write("{\"success\": false, \"message\": \"This time slot is already available.\"}");
                return;
            }
            response.setStatus(HttpServletResponse.SC_OK);
            out.write("{\"success\": true, \"message\": \"Availability added successfully\", \"scheduleId\": \"" + scheduleId + "\"}");
        } catch (Exception e) {
            System.err.println("Error in servlet: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            String errorMsg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Unknown error";
            response.getWriter().write("{\"success\": false, \"message\": \"Error: " + errorMsg + "\"}");
        }
    }
    
    // Simple JSON value extractor
    private String extractJsonValue(String json, String key) {
        Pattern pattern = Pattern.compile("\"" + key + "\"\\s*:\\s*\"([^\"]+)\"");
        Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }
}
