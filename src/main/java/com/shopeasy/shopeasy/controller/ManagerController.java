package com.shopeasy.shopeasy.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.shopeasy.shopeasy.dao.OrderDAO;
import com.shopeasy.shopeasy.dao.RegistrationKeyDAO;
import com.shopeasy.shopeasy.dao.UserDAO;
import com.shopeasy.shopeasy.model.Order;
import com.shopeasy.shopeasy.model.RegistrationKey;
import com.shopeasy.shopeasy.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Controller for manager-specific functionality
 */
@WebServlet(urlPatterns = {
        "/manager/staff", 
        "/manager/staff/add", 
        "/manager/staff/edit", 
        "/manager/staff/delete",
        "/manager/customers",
        "/manager/customer/edit",
        "/manager/customer/delete",
        "/manager/customer/orders",
        "/manager/keys",
        "/manager/keys/generate",
        "/manager/keys/delete",
        "/manager/keys/rename"
})
public class ManagerController extends HttpServlet {
    private UserDAO userDAO;
    private RegistrationKeyDAO keyDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        userDAO = new UserDAO();
        keyDAO = new RegistrationKeyDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();

        // Check if user is logged in and has manager role
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        // Only managers can access these endpoints
        if (!"manager".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        switch (path) {
            case "/manager/staff":
                // Get all staff members and display them
                List<User> staffList = userDAO.getUsersByRole("staff");
                // Also get manager users for comprehensive staff management
                List<User> managerList = userDAO.getUsersByRole("manager");
                staffList.addAll(managerList);
                request.setAttribute("staffList", staffList);
                request.getRequestDispatcher("/view/staff/manager/staff-management.jsp").forward(request, response);
                break;

            case "/manager/staff/add":
                // Handle add staff directly in staff-management.jsp
                response.sendRedirect(request.getContextPath() + "/manager/staff");
                break;

            case "/manager/staff/edit":
                // Get staff member by ID and return to staff management page
                handleEditStaff(request, response);
                break;

            case "/manager/staff/delete":
                // Delete staff member
                handleDeleteStaff(request, response);
                break;

            case "/manager/customers":
                // Get all customers and forward to customer management page
                List<User> customerList = userDAO.getUsersByRole("customer");
                
                // Get order counts for each customer
                OrderDAO orderDAO = new OrderDAO();
                for (User customer : customerList) {
                    int orderCount = orderDAO.getOrderCountByUserId(customer.getUserId());
                    customer.setOrderCount(orderCount);
                }
                
                // Apply sorting if requested
                String sortBy = request.getParameter("sortBy");
                if (sortBy != null) {
                    if (sortBy.equals("name")) {
                        customerList.sort((c1, c2) -> c1.getName().compareToIgnoreCase(c2.getName()));
                    } else if (sortBy.equals("orders")) {
                        customerList.sort((c1, c2) -> Integer.compare(c2.getOrderCount(), c1.getOrderCount()));
                    }
                    // Default is recent, no sorting needed as database typically returns most recent first
                }
                
                // Apply search filter if provided
                String search = request.getParameter("search");
                if (search != null && !search.trim().isEmpty()) {
                    String searchLower = search.toLowerCase();
                    List<User> filteredList = new ArrayList<>();
                    for (User customer : customerList) {
                        if (customer.getName().toLowerCase().contains(searchLower) ||
                            customer.getEmail().toLowerCase().contains(searchLower)) {
                            filteredList.add(customer);
                        }
                    }
                    customerList = filteredList;
                }
                
                request.setAttribute("customerList", customerList);
                request.getRequestDispatcher("/view/staff/manager/customer-management.jsp").forward(request, response);
                break;

            case "/manager/customer/edit":
                // Get customer by ID and return to customers page
                handleEditCustomer(request, response);
                break;

            case "/manager/customer/delete":
                // Delete customer
                handleDeleteCustomer(request, response);
                break;

            case "/manager/customer/orders":
                // View customer orders
                handleCustomerOrders(request, response);
                break;

            case "/manager/keys":
                // Get all registration keys generated by this manager
                List<RegistrationKey> keyList = keyDAO.getActiveKeysByManager(user.getUserId());
                request.setAttribute("keyList", keyList);
                request.getRequestDispatcher("/view/staff/manager/key-management.jsp").forward(request, response);
                break;

            case "/manager/keys/delete":
                // Delete a registration key
                handleDeleteKey(request, response, user.getUserId());
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/dashboard");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();

        // Check if user is logged in and has manager role
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        // Only managers can access these endpoints
        if (!"manager".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        switch (path) {
            case "/manager/staff/add":
                // Add new staff member
                handleAddStaff(request, response);
                break;

            case "/manager/staff/edit":
                // Update existing staff member
                handleUpdateStaff(request, response);
                break;

            case "/manager/customer/edit":
                // Update existing customer
                handleUpdateCustomer(request, response);
                break;

            case "/manager/keys/generate":
                // Generate a new registration key
                handleGenerateKey(request, response, user.getUserId());
                break;

            case "/manager/keys/rename":
                // Rename a registration key
                handleRenameKey(request, response, user.getUserId());
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/dashboard");
                break;
        }
    }

    /**
     * Handle edit staff member request
     */
    private void handleEditStaff(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userIdStr = request.getParameter("id");
        if (userIdStr != null && !userIdStr.isEmpty()) {
            try {
                int userId = Integer.parseInt(userIdStr);
                User staff = userDAO.getUserById(userId);
                if (staff != null && (staff.getRole().equals("staff") || staff.getRole().equals("manager"))) {
                    request.setAttribute("staff", staff);
                    // Forward back to the staff management page with the staff data
                    request.getRequestDispatcher("/view/staff/manager/staff-management.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException e) {
                // Invalid user ID
            }
        }
        // Redirect to staff management page if staff not found or ID is invalid
        response.sendRedirect(request.getContextPath() + "/manager/staff");
    }

    /**
     * Handle delete staff member request
     */
    private void handleDeleteStaff(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String userIdStr = request.getParameter("id");
        if (userIdStr != null && !userIdStr.isEmpty()) {
            try {
                int userId = Integer.parseInt(userIdStr);
                User staff = userDAO.getUserById(userId);
                if (staff != null && (staff.getRole().equals("staff") || staff.getRole().equals("manager"))) {
                    boolean success = userDAO.deleteUser(userId);
                    if (success) {
                        response.sendRedirect(request.getContextPath() + "/manager/staff?success=deleted");
                        return;
                    }
                }
            } catch (NumberFormatException e) {
                // Invalid user ID
            }
        }
        // Redirect with error if deletion failed or ID was invalid
        response.sendRedirect(request.getContextPath() + "/manager/staff?error=deletefailed");
    }

    /**
     * Handle add staff member request
     */
    private void handleAddStaff(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get form data
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String contactNumber = request.getParameter("contactNumber");
        String role = request.getParameter("role");

        // Validate role (default to staff if not specified or invalid)
        if (role == null || (!role.equals("staff") && !role.equals("manager"))) {
            role = "staff";
        }

        // Check if username already exists
        if (userDAO.usernameExists(username)) {
            request.setAttribute("error", "Username already exists");
            request.getRequestDispatcher("/view/staff/manager/staff-management.jsp").forward(request, response);
            return;
        }

        // Create new staff/manager user
        User newStaff = new User();
        newStaff.setUsername(username);
        newStaff.setPassword(password); // Note: In production, use proper password hashing
        newStaff.setRole(role);
        newStaff.setName(name);
        newStaff.setEmail(email);
        newStaff.setContactNumber(contactNumber);

        int userId = userDAO.createUser(newStaff);

        if (userId > 0) {
            // Staff added successfully
            response.sendRedirect(request.getContextPath() + "/manager/staff?success=added");
        } else {
            // Failed to add staff
            request.setAttribute("error", "Failed to add staff member");
            request.getRequestDispatcher("/view/staff/manager/staff-management.jsp").forward(request, response);
        }
    }

    /**
     * Handle update staff member request
     */
    private void handleUpdateStaff(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get form data
        int userId = 0;
        try {
            userId = Integer.parseInt(request.getParameter("userId"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/manager/staff?error=invalid");
            return;
        }

        // Get existing staff user
        User staff = userDAO.getUserById(userId);
        if (staff == null) {
            response.sendRedirect(request.getContextPath() + "/manager/staff?error=notfound");
            return;
        }

        // Check if this is just a role update
        String updateRole = request.getParameter("updateRole");
        if (updateRole != null && updateRole.equals("true")) {
            String newRole = request.getParameter("role");
            if (newRole != null && (newRole.equals("staff") || newRole.equals("manager"))) {
                staff.setRole(newRole);
                boolean success = userDAO.updateUser(staff);
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/manager/staff?success=updated");
                } else {
                    response.sendRedirect(request.getContextPath() + "/manager/staff?error=updatefailed");
                }
                return;
            }
        }

        // Update staff information
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String contactNumber = request.getParameter("contactNumber");
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        // Set all the non-password fields
        staff.setName(name);
        staff.setEmail(email);
        staff.setContactNumber(contactNumber);
        
        // Only update role if valid
        if (role != null && (role.equals("staff") || role.equals("manager"))) {
            staff.setRole(role);
        }

        boolean success;
        
        // Use different update method based on whether password was provided
        if (password != null && !password.trim().isEmpty()) {
            // Password provided - set it and use updateUser with updatePassword=true
            staff.setPassword(password);
            success = userDAO.updateUser(staff, true);
            System.out.println("Updating password for user: " + staff.getUsername());
        } else {
            // No password - use default updateUser method (which won't update password)
            success = userDAO.updateUser(staff);
            System.out.println("No password update for user: " + staff.getUsername());
        }

        if (success) {
            // Staff updated successfully
            response.sendRedirect(request.getContextPath() + "/manager/staff?success=updated");
        } else {
            // Failed to update staff
            request.setAttribute("error", "Failed to update staff member");
            request.setAttribute("staff", staff);
            request.getRequestDispatcher("/view/staff/manager/staff-management.jsp").forward(request, response);
        }
    }

    /**
     * Handle edit customer request
     */
    private void handleEditCustomer(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userIdStr = request.getParameter("id");
        if (userIdStr != null && !userIdStr.isEmpty()) {
            try {
                int userId = Integer.parseInt(userIdStr);
                User customer = userDAO.getUserById(userId);
                if (customer != null && "customer".equals(customer.getRole())) {
                    request.setAttribute("customer", customer);
                    // Forward to the customer management page with customer data
                    request.getRequestDispatcher("/view/staff/manager/customer-management.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException e) {
                // Invalid user ID
            }
        }
        // Redirect to customer management page if customer not found or ID is invalid
        response.sendRedirect(request.getContextPath() + "/manager/customers");
    }

    /**
     * Handle delete customer request
     */
    private void handleDeleteCustomer(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String userIdStr = request.getParameter("id");
        if (userIdStr != null && !userIdStr.isEmpty()) {
            try {
                int userId = Integer.parseInt(userIdStr);
                User customer = userDAO.getUserById(userId);
                if (customer != null && "customer".equals(customer.getRole())) {
                    boolean success = userDAO.deleteUser(userId);
                    if (success) {
                        response.sendRedirect(request.getContextPath() + "/manager/customers?success=deleted");
                        return;
                    }
                }
            } catch (NumberFormatException e) {
                // Invalid user ID
            }
        }
        // Redirect with error if deletion failed or ID was invalid
        response.sendRedirect(request.getContextPath() + "/manager/customers?error=deletefailed");
    }

    /**
     * Handle update customer request
     */
    private void handleUpdateCustomer(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get form data
        int userId = 0;
        try {
            userId = Integer.parseInt(request.getParameter("userId"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/manager/customers?error=invalid");
            return;
        }

        // Get existing customer
        User customer = userDAO.getUserById(userId);
        if (customer == null || !"customer".equals(customer.getRole())) {
            response.sendRedirect(request.getContextPath() + "/manager/customers?error=notfound");
            return;
        }

        // Update customer information
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String contactNumber = request.getParameter("contactNumber");
        String password = request.getParameter("password");

        // Only update password if provided
        boolean updatePassword = password != null && !password.trim().isEmpty();
        if (updatePassword) {
            customer.setPassword(password);
        }

        customer.setName(name);
        customer.setEmail(email);
        customer.setContactNumber(contactNumber);

        // Save updated customer with appropriate method based on password update
        boolean success = updatePassword ? 
                userDAO.updateUser(customer, true) : 
                userDAO.updateUser(customer);

        if (success) {
            // Customer updated successfully
            response.sendRedirect(request.getContextPath() + "/manager/customers?success=updated");
        } else {
            // Failed to update customer
            request.setAttribute("error", "Failed to update customer");
            request.setAttribute("customer", customer);
            request.getRequestDispatcher("/view/staff/manager/customer-management.jsp").forward(request, response);
        }
    }

    /**
     * Handle generate registration key request
     */
    private void handleGenerateKey(HttpServletRequest request, HttpServletResponse response, int managerId) throws IOException {
       String role = request.getParameter("role");
       String validDaysStr = request.getParameter("validDays");
       String customKey = request.getParameter("customKey");

       // Validate role
       if (!"manager".equals(role) && !"staff".equals(role)) {
           response.sendRedirect(request.getContextPath() + "/manager/keys?error=invalidrole");
           return;
       }

       // Validate valid days
       int validDays = 7; // Default to 7 days
       if (validDaysStr != null && !validDaysStr.isEmpty()) {
           try {
               validDays = Integer.parseInt(validDaysStr);
               if (validDays <= 0) {
                   validDays = 7;
               }
           } catch (NumberFormatException e) {
               // Use default value
           }
       }

       // Determine prefix based on role for consistent key formatting
       String prefix = role.toUpperCase().substring(0, 3);
       String year = "2025"; // Current year

       // Generate key 
       String keyValue;
       if (customKey != null && !customKey.trim().isEmpty()) {
           keyValue = keyDAO.generateCustomKey(role, managerId, validDays, customKey);
       } else {
           // Pass the specific role to ensure correct role insertion
           keyValue = keyDAO.generateFormattedKey(prefix, year, managerId, validDays, role);
       }

       if (keyValue != null) {
           // Key generated successfully
           response.sendRedirect(request.getContextPath() + "/manager/keys?success=generated&key=");
       } else {
           // Failed to generate key
           response.sendRedirect(request.getContextPath() + "/manager/keys?error=generatefailed");
       }
   }

    /**
     * Handle rename registration key request
     */
    private void handleRenameKey(HttpServletRequest request, HttpServletResponse response, int managerId) throws IOException {
        String keyIdStr = request.getParameter("keyId");
        String newValue = request.getParameter("newValue");

        if (keyIdStr != null && !keyIdStr.isEmpty() && newValue != null && !newValue.trim().isEmpty()) {
            try {
                int keyId = Integer.parseInt(keyIdStr);
                boolean success = keyDAO.renameKey(keyId, newValue, managerId);
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/manager/keys?success=renamed");
                    return;
                }
            } catch (NumberFormatException e) {
                // Invalid key ID
            }
        }
        // Redirect with error if rename failed or parameters were invalid
        response.sendRedirect(request.getContextPath() + "/manager/keys?error=renamefailed");
    }

    /**
     * Handle delete registration key request
     */
    private void handleDeleteKey(HttpServletRequest request, HttpServletResponse response, int managerId) throws IOException {
        String keyIdStr = request.getParameter("id");
        if (keyIdStr != null && !keyIdStr.isEmpty()) {
            try {
                int keyId = Integer.parseInt(keyIdStr);
                boolean success = keyDAO.deleteKey(keyId, managerId);
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/manager/keys?success=deleted");
                    return;
                }
            } catch (NumberFormatException e) {
                // Invalid key ID
            }
        }
        // Redirect with error if deletion failed or ID was invalid
        response.sendRedirect(request.getContextPath() + "/manager/keys?error=deletefailed");
    }

    /**
     * Handle viewing customer orders
     */
    private void handleCustomerOrders(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userIdStr = request.getParameter("id");
        if (userIdStr != null && !userIdStr.isEmpty()) {
            try {
                int userId = Integer.parseInt(userIdStr);
                User customer = userDAO.getUserById(userId);
                if (customer != null && "customer".equals(customer.getRole())) {
                    // Get customer orders
                    OrderDAO orderDAO = new OrderDAO();
                    List<Order> customerOrders = orderDAO.getOrdersByUserId(userId);
                    
                    // Set attributes for the JSP
                    request.setAttribute("customer", customer);
                    request.setAttribute("customerOrders", customerOrders);
                    
                    // Forward to a simple JSP to display the orders in JSON format for AJAX
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    
                    // Create a simple JSON response manually
                    StringBuilder json = new StringBuilder();
                    json.append("{\n");
                    json.append("  \"customer\": {\n");
                    json.append("    \"id\": ").append(customer.getUserId()).append(",\n");
                    json.append("    \"name\": \"").append(customer.getName()).append("\",\n");
                    json.append("    \"email\": \"").append(customer.getEmail()).append("\"\n");
                    json.append("  },\n");
                    json.append("  \"orders\": [\n");
                    
                    for (int i = 0; i < customerOrders.size(); i++) {
                        Order order = customerOrders.get(i);
                        json.append("    {\n");
                        json.append("      \"orderId\": ").append(order.getOrderId()).append(",\n");
                        json.append("      \"date\": \"").append(order.getOrderDate()).append("\",\n");
                        json.append("      \"amount\": ").append(order.getTotalAmount()).append(",\n");
                        json.append("      \"status\": \"").append(order.getStatus()).append("\",\n");
                        json.append("      \"paymentMethod\": \"").append(order.getPaymentMethod()).append("\"\n");
                        json.append("    }");
                        if (i < customerOrders.size() - 1) {
                            json.append(",");
                        }
                        json.append("\n");
                    }
                    
                    json.append("  ]\n");
                    json.append("}");
                    
                    response.getWriter().write(json.toString());
                    return;
                }
            } catch (NumberFormatException e) {
                // Invalid user ID
            }
        }
        
        // Return an empty JSON object if customer not found or ID is invalid
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write("{ \"error\": \"Customer not found or invalid ID\" }");
    }
}