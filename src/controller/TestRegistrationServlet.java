package controller;

import dao.StudentDAO;
import model.Student;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class TestRegistrationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        out.println("<html><body>");
        out.println("<h2>Testing Student Registration</h2>");
        
        try {
            // Create test student
            Student student = new Student();
            student.setFullName("Test Student");
            student.setEmail("test" + System.currentTimeMillis() + "@email.com");
            student.setPhoneNumber("0123456789");
            student.setDateOfBirth("2000-01-01");
            student.setPassword("test123");
            student.setSecurityQuestion("What is your favorite color?");
            student.setSecurityAnswer("Blue");
            
            out.println("<p>Attempting to register student with email: " + student.getEmail() + "</p>");
            
            StudentDAO dao = new StudentDAO();
            boolean result = dao.registerStudent(student);
            
            if (result) {
                out.println("<p style='color:green;'><b>SUCCESS!</b> Student registered successfully.</p>");
            } else {
                out.println("<p style='color:red;'><b>FAILED!</b> Registration returned false.</p>");
            }
            
        } catch (Exception e) {
            out.println("<p style='color:red;'><b>EXCEPTION:</b> " + e.getMessage() + "</p>");
            out.println("<pre>");
            e.printStackTrace(out);
            out.println("</pre>");
        }
        
        out.println("</body></html>");
    }
}
