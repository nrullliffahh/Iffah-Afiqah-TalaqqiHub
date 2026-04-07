package debug;

import dao.StudentDAO;
import model.Student;

public class CheckStudentPackage {
    public static void main(String[] args) {
        StudentDAO dao = new StudentDAO();
        System.out.println("All students packageId:");
        for (Student s : dao.getAllStudents()) {
            String pkg = null;
            try { pkg = s.getPackageId(); } catch (Throwable t) { pkg = "(no method)"; }
            System.out.printf("%s\t%s\n", s.getStudentId(), pkg);
        }
        System.out.println("\nCheck S010 specifically:");
        Student s = dao.getStudentById("S010");
        if (s != null) {
            String pkg = null;
            try { pkg = s.getPackageId(); } catch (Throwable t) { pkg = "(no method)"; }
            System.out.printf("%s\t%s\n", s.getStudentId(), pkg);
        } else {
            System.out.println("S010 not found");
        }
    }
}
