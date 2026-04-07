package debug;

import dao.StudentBookingDAO;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public class TestAvailableSchedules {
    public static void main(String[] args) {
        try {
            StudentBookingDAO dao = new StudentBookingDAO();
            LocalDate d = LocalDate.of(2026, 1, 22);
            List<Map<String, Object>> list = dao.getSchedulesWithBookingInfoByDate(d);
            System.out.println("Schedules count: " + list.size());
            for (Map<String, Object> m : list) {
                System.out.println(m);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
