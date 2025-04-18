package com.shopeasy.shopeasy.controller;

import com.shopeasy.shopeasy.dao.UserDAO;
import com.shopeasy.shopeasy.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet(urlPatterns = {"/login", "/logout", "/dashboard"})
public class UserController extends HttpServlet {
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String path = request.getServletPath();
        
        switch (path) {
            case "/login":
                handleLoginPage(request, response);
                break;
                
            case "/logout":
                handleLogout(request, response);
                break;
                
            case "/dashboard":
                handleDashboard(request, response);
                break;
                
            default:
                response.sendRedirect(request.getContextPath() + "/login");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        if (request.getServletPath().equals("/login")) {
            handleLogin(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/login");
        }
    }

    private void handleLoginPage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            redirectBasedOnRole((User) session.getAttribute("user"), request, response);
        } else {
            request.getRequestDispatcher("/view/login.jsp").forward(request, response);
        }
    }

    private void handleLogin(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        User user = userDAO.authenticate(username, password);

        if (user != null) {
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            redirectBasedOnRole(user, request, response);
        } else {
            request.setAttribute("error", "Invalid username or password");
            request.getRequestDispatcher("/view/login.jsp").forward(request, response);
        }
    }

    private void handleDashboard(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (isAdminRole(user.getRole())) {
            request.getRequestDispatcher("/view/admin/dashboard.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/customer/customer.jsp").forward(request, response);
        }
    }

    private void handleLogout(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        response.sendRedirect(request.getContextPath() + "/login");
    }

    private void redirectBasedOnRole(User user, HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        if (isAdminRole(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
        } else {
            response.sendRedirect(request.getContextPath() + "/customer/customer.jsp");
        }
    }

    private boolean isAdminRole(String role) {
        return "manager".equalsIgnoreCase(role) || "staff".equalsIgnoreCase(role);
    }
}