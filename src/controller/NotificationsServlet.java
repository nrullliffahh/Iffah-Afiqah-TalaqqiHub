package controller;

import dao.NotificationDAO;
import util.NotificationAuthUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;

@WebServlet("/api/notifications")
public class NotificationsServlet extends HttpServlet {

    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.getWriter().write("{\"unreadCount\":0,\"count\":0,\"items\":[]}");
            return;
        }

        String role = req.getParameter("role");
        NotificationAuthUtil.NotificationUser user = NotificationAuthUtil.resolve(session, role);
        if (user == null) {
            resp.getWriter().write("{\"unreadCount\":0,\"count\":0,\"items\":[]}");
            return;
        }
        String userId = user.userId;
        String userType = user.userType;

        if ("student".equals(userType)) {
            notificationDAO.syncStudentNotifications(userId);
        } else {
            notificationDAO.syncTeacherNotifications(userId);
        }

        notificationDAO.deleteExpiredNotifications();

        List<Map<String, Object>> items = notificationDAO.getNotifications(userId, userType, 20);
        int unreadCount = notificationDAO.getUnreadCount(userId, userType);

        try (PrintWriter out = resp.getWriter()) {
            StringBuilder sb = new StringBuilder();
            sb.append('{');
            sb.append("\"unreadCount\":").append(unreadCount).append(',');
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
                    String v = e.getValue() == null ? "" : e.getValue().toString()
                            .replace("\\","\\\\").replace("\"","\\\"").replace("\n","\\n");
                    sb.append('"').append(v).append('"');
                }
                sb.append('}');
            }
            sb.append("]}");
            out.write(sb.toString());
        }
    }
}
