package controller;

import util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/api/notifications/mark-read")
public class MarkNotificationsReadServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null) { resp.setStatus(401); return; }
        String studentId = (String) session.getAttribute("studentId");
        String teacherId = (String) session.getAttribute("teacherId");

        String notifId = req.getParameter("id");

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) { resp.setStatus(500); return; }

            if (notifId != null && !notifId.trim().isEmpty()) {
                // mark single id, but ensure it belongs to this user
                String sql = "UPDATE notifications SET isRead = 1 WHERE id = ? AND userId = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, notifId);
                    String uid = studentId != null ? studentId : teacherId;
                    ps.setString(2, uid);
                    ps.executeUpdate();
                }
            } else {
                // mark all for this user
                String uid = studentId != null ? studentId : teacherId;
                if (uid != null) {
                    String sql = "UPDATE notifications SET isRead = 1 WHERE userId = ?";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setString(1, uid);
                        ps.executeUpdate();
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(500);
            return;
        }

        resp.setStatus(200);
    }
}
