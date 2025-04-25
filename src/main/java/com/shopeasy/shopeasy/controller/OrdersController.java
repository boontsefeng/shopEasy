package com.shopeasy.shopeasy.controller;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.shopeasy.shopeasy.dao.OrderDAO;
import com.shopeasy.shopeasy.dao.UserDAO;
import com.shopeasy.shopeasy.model.Order;
import com.shopeasy.shopeasy.model.OrderItem;
import com.shopeasy.shopeasy.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/orders/*")
public class OrdersController extends HttpServlet {
    private OrderDAO orderDAO;
    private UserDAO userDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        orderDAO = new OrderDAO();
        userDAO = new UserDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        
        // If there's a path info, it's an API request for order details
        if (pathInfo != null && !pathInfo.equals("/")) {
            handleApiRequest(request, response, pathInfo);
            return;
        }
        
        // Otherwise, handle the main orders page request
        handleOrdersPageRequest(request, response);
    }
    
    /**
     * Handle API requests for order details
     */
    private void handleApiRequest(HttpServletRequest request, HttpServletResponse response, String pathInfo) 
            throws ServletException, IOException {
        
        // Set content type for JSON response
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        // Check authorization
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            String errorJson = "{\"error\":\"Unauthorized access. Please log in again.\",\"success\":false}";
            response.setContentLength(errorJson.getBytes("UTF-8").length);
            response.getWriter().write(errorJson);
            return;
        }
        
        User user = (User) session.getAttribute("user");
        String role = user.getRole().toLowerCase();
        
        // Only allow staff and managers to access order details
        if (role.equals("manager") || role.equals("staff")) {
            try {
                // Get order ID from path
                if (pathInfo == null || pathInfo.equals("/")) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    String errorJson = "{\"error\":\"Order ID is required\",\"success\":false}";
                    response.setContentLength(errorJson.getBytes("UTF-8").length);
                    response.getWriter().write(errorJson);
                    return;
                }
                
                // Clean up the path before parsing
                String orderIdStr = pathInfo.substring(1).trim();
                // Remove any trailing slashes
                while (orderIdStr.endsWith("/")) {
                    orderIdStr = orderIdStr.substring(0, orderIdStr.length() - 1);
                }
                
                if (orderIdStr.isEmpty()) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    String errorJson = "{\"error\":\"Invalid order ID format\",\"success\":false}";
                    response.setContentLength(errorJson.getBytes("UTF-8").length);
                    response.getWriter().write(errorJson);
                    return;
                }
                
                System.out.println("Parsed order ID: " + orderIdStr); // Debugging
                
                int orderId = Integer.parseInt(orderIdStr);
                
                // Get order details
                Order order = orderDAO.getOrderById(orderId);
                if (order == null) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    String errorJson = "{\"error\":\"Order not found\",\"success\":false}";
                    response.setContentLength(errorJson.getBytes("UTF-8").length);
                    response.getWriter().write(errorJson);
                    return;
                }
                
                // Get customer info
                User customer = userDAO.getUserById(order.getUserId());
                if (customer == null) {
                    // Handle missing customer data gracefully
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    String errorJson = "{\"error\":\"Customer data not found for this order\",\"success\":false}";
                    response.setContentLength(errorJson.getBytes("UTF-8").length);
                    response.getWriter().write(errorJson);
                    return;
                }
                
                // Get order items
                List<OrderItem> items = orderDAO.getOrderItemsByOrderId(orderId);
                
                // Create JSON response manually to avoid dependency issues
                StringBuilder jsonBuilder = new StringBuilder();
                jsonBuilder.append("{");
                jsonBuilder.append("\"success\":true,");
                jsonBuilder.append("\"orderId\":").append(order.getOrderId()).append(",");
                jsonBuilder.append("\"orderDate\":").append(order.getOrderDate().getTime()).append(",");
                jsonBuilder.append("\"totalAmount\":").append(order.getTotalAmount()).append(",");
                jsonBuilder.append("\"status\":\"").append(escapeJson(order.getStatus())).append("\",");
                jsonBuilder.append("\"paymentMethod\":\"").append(escapeJson(order.getPaymentMethod())).append("\",");
                jsonBuilder.append("\"shippingAddress\":\"").append(escapeJson(order.getShippingAddress())).append("\",");
                
                // Add customer info
                jsonBuilder.append("\"customerName\":\"").append(escapeJson(customer.getName())).append("\",");
                jsonBuilder.append("\"customerEmail\":\"").append(escapeJson(customer.getEmail())).append("\",");
                jsonBuilder.append("\"customerPhone\":\"").append(escapeJson(customer.getContactNumber())).append("\",");
                
                // Add order items
                jsonBuilder.append("\"items\":[");
                for (int i = 0; i < items.size(); i++) {
                    OrderItem item = items.get(i);
                    if (i > 0) {
                        jsonBuilder.append(",");
                    }
                    jsonBuilder.append("{");
                    jsonBuilder.append("\"productId\":").append(item.getProductId()).append(",");
                    jsonBuilder.append("\"productName\":\"").append(escapeJson(item.getProductName())).append("\",");
                    jsonBuilder.append("\"quantity\":").append(item.getQuantity()).append(",");
                    jsonBuilder.append("\"price\":").append(item.getPrice());
                    jsonBuilder.append("}");
                }
                jsonBuilder.append("]");
                
                jsonBuilder.append("}");
                
                // Get the final JSON string
                String jsonResponse = jsonBuilder.toString();
                
                // Set content length and send JSON response
                response.setContentLength(jsonResponse.getBytes("UTF-8").length);
                response.getWriter().write(jsonResponse);
                
            } catch (NumberFormatException e) {
                System.err.println("Error parsing order ID: " + e.getMessage());
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                String errorJson = "{\"error\":\"Invalid order ID format: " + e.getMessage() + "\",\"success\":false}";
                response.setContentLength(errorJson.getBytes("UTF-8").length);
                response.getWriter().write(errorJson);
            } catch (Exception e) {
                System.err.println("Error getting order details: " + e.getMessage());
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                String errorJson = "{\"error\":\"Internal server error: " + e.getMessage() + "\",\"success\":false}";
                response.setContentLength(errorJson.getBytes("UTF-8").length);
                response.getWriter().write(errorJson);
            }
        } else {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            String errorJson = "{\"error\":\"Access denied. Only staff and managers can view order details.\",\"success\":false}";
            response.setContentLength(errorJson.getBytes("UTF-8").length);
            response.getWriter().write(errorJson);
        }
    }
    
    /**
     * Escape special characters in JSON strings
     */
    private String escapeJson(String input) {
        if (input == null) {
            return "";
        }
        return input.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\b", "\\b")
                   .replace("\f", "\\f")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }
    
    /**
     * Handle main orders page request
     */
    private void handleOrdersPageRequest(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Check authorization
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        String role = user.getRole().toLowerCase();
        
        // Only allow staff and managers to access the order management page
        if (role.equals("manager") || role.equals("staff")) {
            try {
                // Get all orders
                List<Order> orders = orderDAO.getAllOrders();
                
                // Get customer info for each order
                Map<Integer, User> customerInfo = new HashMap<>();
                for (Order order : orders) {
                    int userId = order.getUserId();
                    if (!customerInfo.containsKey(userId)) {
                        User customer = userDAO.getUserById(userId);
                        customerInfo.put(userId, customer);
                    }
                }
                
                request.setAttribute("orders", orders);
                request.setAttribute("customerInfo", customerInfo);
                
                // Forward to orders page
                request.getRequestDispatcher("/view/staff/orders.jsp").forward(request, response);
            } catch (Exception e) {
                System.err.println("Error getting orders: " + e.getMessage());
                e.printStackTrace();
                
                // Set empty list if there's an error
                request.setAttribute("orders", List.of());
                request.setAttribute("error", "Failed to load orders: " + e.getMessage());
                request.getRequestDispatcher("/view/staff/orders.jsp").forward(request, response);
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/dashboard");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Check authorization
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            String errorJson = "{\"success\":false,\"message\":\"Unauthorized. Please log in.\"}";
            response.setContentLength(errorJson.getBytes("UTF-8").length);
            response.getWriter().write(errorJson);
            return;
        }
        
        User user = (User) session.getAttribute("user");
        String role = user.getRole().toLowerCase();
        
        // Only allow staff and managers to update order status
        if (role.equals("manager") || role.equals("staff")) {
            String action = request.getParameter("action");
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
            if ("updateStatus".equals(action)) {
                try {
                    String orderIdParam = request.getParameter("orderId");
                    String newStatus = request.getParameter("status");
                    
                    if (orderIdParam == null || newStatus == null || orderIdParam.trim().isEmpty() || newStatus.trim().isEmpty()) {
                        String errorJson = "{\"success\":false,\"message\":\"Missing order ID or status\"}";
                        response.setContentLength(errorJson.getBytes("UTF-8").length);
                        response.getWriter().write(errorJson);
                        return;
                    }
                    
                    int orderId = Integer.parseInt(orderIdParam);
                    
                    // Update order status
                    boolean success = orderDAO.updateOrderStatus(orderId, newStatus);
                    
                    if (success) {
                        String successJson = "{\"success\":true,\"message\":\"Order status updated successfully\"}";
                        response.setContentLength(successJson.getBytes("UTF-8").length);
                        response.getWriter().write(successJson);
                    } else {
                        String errorJson = "{\"success\":false,\"message\":\"Failed to update order status\"}";
                        response.setContentLength(errorJson.getBytes("UTF-8").length);
                        response.getWriter().write(errorJson);
                    }
                } catch (NumberFormatException e) {
                    String errorJson = "{\"success\":false,\"message\":\"Invalid order ID format\"}";
                    response.setContentLength(errorJson.getBytes("UTF-8").length);
                    response.getWriter().write(errorJson);
                } catch (Exception e) {
                    System.err.println("Error updating order status: " + e.getMessage());
                    e.printStackTrace();
                    String errorJson = "{\"success\":false,\"message\":\"Server error: " + escapeJson(e.getMessage()) + "\"}";
                    response.setContentLength(errorJson.getBytes("UTF-8").length);
                    response.getWriter().write(errorJson);
                }
            } else {
                // Forward back to orders page for other actions
                doGet(request, response);
            }
        } else {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            String errorJson = "{\"success\":false,\"message\":\"Access denied. Only staff and managers can update orders.\"}";
            response.setContentLength(errorJson.getBytes("UTF-8").length);
            response.getWriter().write(errorJson);
        }
    }
}