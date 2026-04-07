package controller;

import util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
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
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/api/notifications")
public class NotificationsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        HttpSession session = req.getSession(false);
        String studentId = null;
        String teacherId = null;
        if (session != null) {
            Object s = session.getAttribute("studentId");
            Object t = session.getAttribute("teacherId");
            if (s != null) studentId = s.toString();
            if (t != null) teacherId = t.toString();
        }

        List<Map<String, Object>> items = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                resp.getWriter().write("[]");
                return;
            }

            String sql = null;
            PreparedStatement ps = null;

            // Prefer notifications table if present
            if (studentId != null && !studentId.trim().isEmpty()) {
                sql = "SELECT id, title, message, bookingId, relatedScheduleId, isRead, createdAt FROM notifications WHERE userType='student' AND userId = ? ORDER BY createdAt DESC LIMIT 20";
                ps = conn.prepareStatement(sql);
                ps.setString(1, studentId);
            } else if (teacherId != null && !teacherId.trim().isEmpty()) {
                sql = "SELECT id, title, message, bookingId, relatedScheduleId, isRead, createdAt FROM notifications WHERE userType='teacher' AND userId = ? ORDER BY createdAt DESC LIMIT 20";
                ps = conn.prepareStatement(sql);
                ps.setString(1, teacherId);
            } else {
                resp.getWriter().write("[]");
                return;
            }

            try (ResultSet rs = ps.executeQuery()) {
                SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("id", rs.getString("id"));
                    m.put("title", rs.getString("title"));
                    m.put("message", rs.getString("message"));
                    m.put("bookingId", rs.getString("bookingId"));
                    m.put("scheduleId", rs.getString("relatedScheduleId"));
                    m.put("isRead", rs.getString("isRead"));
                    java.sql.Timestamp ts = rs.getTimestamp("createdAt");
                    m.put("time", ts != null ? df.format(ts) : "");
                    items.add(m);
                }
            } finally {
                try { if (ps != null) ps.close(); } catch (SQLException ignored) {}
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        try (PrintWriter out = resp.getWriter()) {
            StringBuilder sb = new StringBuilder();
            sb.append('{');
            sb.append("\"count\":").append(items.size()).append(',');
            sb.append("\"items\":[");
            boolean first = true;
            for (Map<String, Object> it : items) {
                if (!first) sb.append(','); first = false;
                sb.append('{');
                boolean f2 = true;
                for (Map.Entry<String, Object> e : it.entrySet()) {
                    if (!f2) sb.append(','); f2 = false;
                    sb.append('"').append(e.getKey()).append('"').append(':');
                    String v = e.getValue() == null ? "" : e.getValue().toString().replace("\\","\\\\").replace("\"","\\\"").replace("\n","\\n");
                    sb.append('"').append(v).append('"');
                }
                sb.append('}');
            }
            sb.append("]}");
            out.write(sb.toString());
        }
    }
}
