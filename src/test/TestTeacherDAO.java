import dao.TeacherDAO;
import model.Teacher;
import java.util.List;

public class TestTeacherDAO {
    public static void main(String[] args) {
        TeacherDAO dao = new TeacherDAO();
        List<Teacher> teachers = dao.getAllTeachers();
        System.out.println("Returned teacher list size: " + (teachers == null ? null : teachers.size()));
        if (teachers != null) {
            for (Teacher t : teachers) {
                System.out.println(t.getTeacherId() + "\t" + t.getFullName());
            }
        }
    }
}
