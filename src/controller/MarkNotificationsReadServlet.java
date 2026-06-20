package controller;

import util.DBConnection;
import util.NotificationAuthUtil;

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

        String role = req.getParameter("role");
        String notifId = req.getParameter("id");

        NotificationAuthUtil.NotificationUser user = NotificationAuthUtil.resolve(session, role);
        if (user == null) {
            resp.setStatus(401);
            return;
        }
        String uid = user.userId;
        String userType = user.userType;

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) { resp.setStatus(500); return; }

            if (notifId != null && !notifId.trim().isEmpty()) {
                String sql = "UPDATE notifications SET isRead = 1 WHERE id = ? AND userId = ? AND userType = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, notifId);
                    ps.setString(2, uid);
                    ps.setString(3, userType);
                    ps.executeUpdate();
                }
            } else {
                String sql = "UPDATE notifications SET isRead = 1 WHERE userId = ? AND userType = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, uid);
                    ps.setString(2, userType);
                    ps.executeUpdate();
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
