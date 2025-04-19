package com.shopeasy.shopeasy.controller;

import com.shopeasy.shopeasy.dao.RegistrationKeyDAO;
import com.shopeasy.shopeasy.dao.UserDAO;
import com.shopeasy.shopeasy.model.RegistrationKey;
import com.shopeasy.shopeasy.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet(urlPatterns = {"/login", "/logout", "/dashboard", "/profile", "/register"})
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

            case "/register":
                handleRegisterPage(request, response);
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
                
            case "/register":
                handleRegister(request, response);
                break;
                
            default:
                response.sendRedirect(request.getContextPath() + "/login");
        }
    }
    
        private void handleRegisterPage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            // If user is already logged in, redirect based on their role
            redirectBasedOnRole((User) session.getAttribute("user"), request, response);
        } else {
            // Forward to the registration page
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
        }
    }

    private void handleLoginPage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Check for registration success parameter
        if ("true".equals(request.getParameter("registered"))) {
            // Debug to confirm this code is running
            System.out.println("Setting success attribute for registration");
            request.setAttribute("success", "Your account has been successfully registered! You can now log in.");
        }

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
    
    private void handleRegister(HttpServletRequest request, HttpServletResponse response) 
        throws ServletException, IOException {
    // Get form data
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String confirmPassword = request.getParameter("confirmPassword");
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String contactNumber = request.getParameter("contactNumber");
    String registrationKey = request.getParameter("registrationKey");

    // Debug - registration attempt
    System.out.println("Registration attempt for: " + username + " with key: " + registrationKey);

    // Basic validation
    if (!password.equals(confirmPassword)) {
        request.setAttribute("error", "Passwords do not match");
        request.getRequestDispatcher("/view/register.jsp").forward(request, response);
        return;
    }

    // Check if username or email already exists
    if (userDAO.usernameExists(username)) {
        request.setAttribute("error", "Username already exists");
        request.getRequestDispatcher("/view/register.jsp").forward(request, response);
        return;
    }

    if (userDAO.emailExists(email)) {
        request.setAttribute("error", "Email already exists");
        request.getRequestDispatcher("/view/register.jsp").forward(request, response);
        return;
    }

    // Determine role based on registration key
    String role = "customer"; // Default role is customer
    
    if (registrationKey != null && !registrationKey.isEmpty()) {
        // Use RegistrationKeyDAO to validate the key
        RegistrationKeyDAO keyDAO = new RegistrationKeyDAO();
        RegistrationKey key = keyDAO.validateKey(registrationKey);
        
        if (key != null) {
            // Valid key found - use its role
            role = key.getRole();
            System.out.println("Valid registration key found with role: " + role);
            
            // Mark the key as used
            keyDAO.markKeyAsUsed(registrationKey);
        } else {
            // Invalid key
            System.out.println("Invalid registration key: " + registrationKey);
            request.setAttribute("error", "Invalid or expired registration key");
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            return;
        }
    }

    // Create user object
    User newUser = new User();
    newUser.setUsername(username);
    newUser.setPassword(password);
    newUser.setName(name);
    newUser.setEmail(email);
    newUser.setContactNumber(contactNumber);
    newUser.setRole(role);

    System.out.println("Creating new user with role: " + role);
    
    // Add user to database
    int userId = userDAO.createUser(newUser);

    if (userId > 0) {
        // Registration successful, redirect to login
        System.out.println("User registered successfully with ID: " + userId);
        response.sendRedirect(request.getContextPath() + "/login?registered=true");
    } else {
        // Registration failed
        System.out.println("User registration failed");
        request.setAttribute("error", "Registration failed. Please try again.");
        request.getRequestDispatcher("/view/register.jsp").forward(request, response);
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