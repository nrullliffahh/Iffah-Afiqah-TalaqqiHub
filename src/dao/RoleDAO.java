package dao;

import model.Role;
import java.util.ArrayList;
import java.util.List;

public class RoleDAO {
    
    public List<Role> getAllRoles() {
        List<Role> roles = new ArrayList<>();
        
        roles.add(new Role(
            1,
            "Student",
            "Join Quran classes, follow your schedule, check your attendance, and see your learning progress",
            "/student/login",
            "/images/students.png",
            "var(--gradient-feature-green)"
        ));
        
        roles.add(new Role(
            2,
            "Teacher",
            "Manage classes, guide students during talaqqi sessions, record attendance, and provide evaluations.",
            "/teacher/login",
            "/images/teachers.png",
            "var(--gradient-feature-purple)"
        ));
        
        return roles;
    }
}
