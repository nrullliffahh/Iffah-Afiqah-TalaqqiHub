package debug;

import dao.StudentDAO;
import dao.PackageDAO;
import model.Student;
import model.Package;

public class ResolvePackageForStudent {
    public static void main(String[] args) {
        StudentDAO sdao = new StudentDAO();
        PackageDAO pdao = new PackageDAO();
        Student s = sdao.getStudentById("S010");
        System.out.println("studentId=" + (s==null?"null":s.getStudentId()));
        System.out.println("student.packageId=" + (s==null?"null":s.getPackageId()));
        String packageName = "-";
        if (s != null && s.getPackageId() != null) {
            String raw = s.getPackageId();
            String digits = raw.replaceAll("\\D+", "");
            int sid = digits.isEmpty() ? -1 : Integer.parseInt(digits);
            for (Package p : pdao.getAllPackages()) {
                if (sid != -1 && p.getPackageId() == sid) { packageName = p.getPackageName(); break; }
                if (String.valueOf(p.getPackageId()).equals(raw)) { packageName = p.getPackageName(); break; }
            }
        }
        System.out.println("resolved packageName=" + packageName);
    }
}
