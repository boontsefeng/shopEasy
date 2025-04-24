package com.shopeasy.shopeasy.controller;

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
import java.io.IOException;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/orders")
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
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        String role = user.getRole().toLowerCase();
        
        // Only allow staff and managers to update order status
        if (role.equals("manager") || role.equals("staff")) {
            String action = request.getParameter("action");
            
            if ("updateStatus".equals(action)) {
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                String newStatus = request.getParameter("status");
                
                // Update order status
                boolean success = orderDAO.updateOrderStatus(orderId, newStatus);
                
                // Send JSON response
                response.setContentType("application/json");
                if (success) {
                    response.getWriter().write("{\"success\":true,\"message\":\"Order status updated successfully\"}");
                } else {
                    response.getWriter().write("{\"success\":false,\"message\":\"Failed to update order status\"}");
                }
            } else {
                // Forward back to orders page for other actions
                doGet(request, response);
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/dashboard");
        }
    }
}