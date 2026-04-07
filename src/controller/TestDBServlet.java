package controller;

import util.DBConnection;
import java.io.IOException;
import java.sql.Connection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


@WebServlet("/testDB")
public class TestDBServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain");
        response.setCharacterEncoding("UTF-8");

        try {
            Connection conn = DBConnection.getConnection();

            if (conn != null) {
                response.getWriter().println("SUCCESS: DATABASE CONNECTED SUCCESSFULLY");
                conn.close();
            } else {
                response.getWriter().println("FAILED: DATABASE CONNECTION FAILED");
            }

        } catch (Exception e) {
            response.getWriter().println("ERROR: DATABASE CONNECTION ERROR");
            response.getWriter().println(e.getMessage());
            e.printStackTrace();
        }
    }
}
