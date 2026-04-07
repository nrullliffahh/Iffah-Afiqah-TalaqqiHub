package debug;

import dao.SessionDAO;
import java.util.List;
import java.util.Map;

public class TestSessionDAO {
    public static void main(String[] args) {
        try {
            SessionDAO dao = new SessionDAO();
            List<Map<String, Object>> list = dao.getUpcomingClasses("T001", 10);
            System.out.println("Upcoming classes count: " + list.size());
            for (Map<String, Object> m : list) {
                System.out.println(m);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
