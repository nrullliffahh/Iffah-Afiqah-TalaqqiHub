package controller;

import dao.StudentDAO;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class ChoosePackageActionServlet extends HttpServlet {

    private StudentDAO studentDAO;

    @Override
    public void init() {
        studentDAO = new StudentDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String packageId = request.getParameter("packageId");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentId") == null) {
            // Not logged in - redirect to login
            response.sendRedirect(request.getContextPath() + "/student/login");
            return;
        }

        String studentId = (String) session.getAttribute("studentId");

        boolean ok = studentDAO.updateStudentPackage(studentId, packageId);
        if (ok) {
            // update session student object if present
            Object sObj = session.getAttribute("student");
            if (sObj instanceof model.Student) {
                ((model.Student) sObj).setPackageId(packageId);
                session.setAttribute("student", sObj);
            }
            response.sendRedirect(request.getContextPath() + "/student/dashboard");
        } else {
            request.setAttribute("errorMessage", "Failed to set package. Please try again.");
            request.getRequestDispatcher("/WEB-INF/views/choosePackages.jsp").forward(request, response);
        }
    }
}
