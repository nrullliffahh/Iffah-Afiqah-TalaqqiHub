package controller;

import dao.StudentDAO;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class StudentChoosePackageServlet extends HttpServlet {

    private StudentDAO studentDAO;

    @Override
    public void init() {
        studentDAO = new StudentDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentId") == null) {
            // Not logged in - redirect to login
            response.sendRedirect(request.getContextPath() + "/student/login");
            return;
        }

        String studentId = (String) session.getAttribute("studentId");
        String dbPackageId = request.getParameter("dbPackageId");
        if (dbPackageId == null || dbPackageId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/packages");
            return;
        }

        boolean ok = studentDAO.updateStudentPackage(studentId, dbPackageId);
        if (!ok) {
            // could set an error message - for now redirect back
            response.sendRedirect(request.getContextPath() + "/packages?error=update_failed");
            return;
        }

        // update session attribute so dashboard shows package immediately
        session.setAttribute("packageId", dbPackageId);

        response.sendRedirect(request.getContextPath() + "/student/dashboard");
    }
}
