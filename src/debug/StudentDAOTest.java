package debug;

import dao.StudentDAO;
import model.Student;
import java.util.List;

public class StudentDAOTest {
    public static void main(String[] args) {
        try {
            StudentDAO dao = new StudentDAO();
            List<Student> students = dao.getAllStudents();
            System.out.println("Found students: " + (students == null ? 0 : students.size()));
            if (students != null) {
                for (Student s : students) {
                    System.out.printf("%s\t%s\t%s\t%s\n",
                            s.getStudentId(),
                            s.getStudentName() != null ? s.getStudentName() : s.getName(),
                            s.getStudentEmail() != null ? s.getStudentEmail() : s.getEmail(),
                            s.getStudentStatus() != null ? s.getStudentStatus() : s.getStatus()
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
