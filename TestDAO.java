import dao.EvaluationDAO;
import dao.TeacherDAO;
import java.util.List;
import java.util.Map;

public class TestDAO {
    public static void main(String[] args) {
        String teacherId = args.length > 0 ? args[0] : "T002";
        try {
            EvaluationDAO ed = new EvaluationDAO();
            System.out.println("Calling getAverageRatings():");
            System.out.println(ed.getAverageRatings());

            System.out.println("Calling getRecentFeedback():");
            List<Map<String,Object>> fb = ed.getRecentFeedback(teacherId, 3);
            System.out.println("Recent feedback size: " + fb.size());
            for (Map<String,Object> m : fb) {
                System.out.println(m);
            }

            TeacherDAO td = new TeacherDAO();
            System.out.println("Teacher average rating: " + td.getAverageRating(teacherId));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
