package com.shopeasy.shopeasy.controller;

import com.shopeasy.shopeasy.dao.UserDAO;
import com.shopeasy.shopeasy.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet(urlPatterns = {"/login", "/logout", "/dashboard", "/profile"})
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
                
            case "/profile":
                handleProfilePage(request, response);
                break;
                
            default:
                response.sendRedirect(request.getContextPath() + "/login");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String path = request.getServletPath();
        
        switch (path) {
            case "/login":
                handleLogin(request, response);
                break;
                
            case "/profile":
                handleProfileUpdate(request, response);
                break;
                
            default:
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
        
        // Debug message - you should see this in server logs
        System.out.println("Login attempt: " + username);
        
        User user = userDAO.authenticate(username, password);

        if (user != null) {
            // Debug - authentication successful
            System.out.println("Authentication successful for: " + username);
            
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setAttribute("userName", user.getName());
            session.setAttribute("userRole", user.getRole());
            session.setAttribute("userId", user.getUserId());
            
            redirectBasedOnRole(user, request, response);
        } else {
            // Debug - authentication failed
            System.out.println("Authentication failed for: " + username);
            
            request.setAttribute("error", "Invalid username or password");
            request.getRequestDispatcher("/view/login.jsp").forward(request, response);
        }
    }

    private void handleDashboard(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            // Debug - session check failed
            System.out.println("Dashboard access denied - no valid session");
            
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        // Debug - user role check
        System.out.println("Dashboard access attempt by: " + user.getUsername() + " with role: " + user.getRole());
        
        if (isAdminRole(user.getRole())) {
            // Forward to the staff dashboard
            request.getRequestDispatcher("/view/staff/dashboard.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/customer/dashboard");
        }
    }
    
    private void handleProfilePage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        request.setAttribute("userProfile", user);
        
        // Direct to appropriate profile page based on role
        if (isAdminRole(user.getRole())) {
            request.getRequestDispatcher("/view/staff/profile.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/view/customer/profile.jsp").forward(request, response);
        }
    }
    
    private void handleProfileUpdate(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        int userId = user.getUserId();
        
        // Update user information
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String contactNumber = request.getParameter("contactNumber");
        String password = request.getParameter("password");
        
        // Only update password if provided
        if (password != null && !password.trim().isEmpty()) {
            user.setPassword(password); // Note: In production, use proper password hashing
        }
        
        user.setName(name);
        user.setEmail(email);
        user.setContactNumber(contactNumber);
        
        // Save updated user
        boolean success = userDAO.updateUser(user);
        
        if (success) {
            // Update session attributes
            session.setAttribute("user", user);
            session.setAttribute("userName", user.getName());
            
            // Redirect based on role
            if (isAdminRole(user.getRole())) {
                response.sendRedirect(request.getContextPath() + "/profile?success=updated");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/profile?success=updated");
            }
        } else {
            request.setAttribute("error", "Failed to update profile");
            request.setAttribute("userProfile", user);
            
            if (isAdminRole(user.getRole())) {
                request.getRequestDispatcher("/view/staff/profile.jsp").forward(request, response);
            } else {
                request.getRequestDispatcher("/view/customer/profile.jsp").forward(request, response);
            }
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
        // Debug - redirection based on role
        System.out.println("Redirecting user: " + user.getUsername() + " with role: " + user.getRole());
        
        if (isAdminRole(user.getRole())) {
            // Use direct redirection to the servlet path
            response.sendRedirect(request.getContextPath() + "/dashboard");
        } else {
            response.sendRedirect(request.getContextPath() + "/customer/dashboard");
        }
    }

    private boolean isAdminRole(String role) {
        return "manager".equalsIgnoreCase(role) || "staff".equalsIgnoreCase(role);
    }
}