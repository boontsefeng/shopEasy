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

@WebServlet("/api/orders/*")
public class OrderApiServlet extends HttpServlet {
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
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Unauthorized\"}");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        String role = user.getRole().toLowerCase();
        
        // Only allow staff and managers to access order details
        if (role.equals("manager") || role.equals("staff")) {
            try {
                // Get order ID from path
                String pathInfo = request.getPathInfo();
                if (pathInfo == null || pathInfo.equals("/")) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"error\":\"Order ID is required\"}");
                    return;
                }
                
                int orderId = Integer.parseInt(pathInfo.substring(1));
                
                // Get order details
                Order order = orderDAO.getOrderById(orderId);
                if (order == null) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    response.getWriter().write("{\"error\":\"Order not found\"}");
                    return;
                }
                
                // Get customer info
                User customer = userDAO.getUserById(order.getUserId());
                
                // Get order items
                List<OrderItem> items = orderDAO.getOrderItemsByOrderId(orderId);
                
                // Prepare response
                Map<String, Object> responseData = new HashMap<>();
                responseData.put("orderId", order.getOrderId());
                responseData.put("orderDate", order.getOrderDate().getTime());
                responseData.put("totalAmount", order.getTotalAmount());
                responseData.put("status", order.getStatus());
                responseData.put("paymentMethod", order.getPaymentMethod());
                responseData.put("shippingAddress", order.getShippingAddress());
                
                // Add customer info
                responseData.put("customerName", customer.getName());
                responseData.put("customerEmail", customer.getEmail());
                responseData.put("customerPhone", customer.getContactNumber());
                
                // Add order items
                responseData.put("items", items);
                
                // Send JSON response
                response.setContentType("application/json");
                response.getWriter().write(convertToJson(responseData));
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\":\"Invalid order ID\"}");
            } catch (Exception e) {
                System.err.println("Error getting order details: " + e.getMessage());
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
            }
        } else {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("{\"error\":\"Access denied\"}");
        }
    }
    
    /**
     * Convert Map to JSON string
     * @param data Map of data
     * @return JSON string
     */
    private String convertToJson(Map<String, Object> data) {
        // In a real application, use a proper JSON library like Gson or Jackson
        // This is a simplified version for demonstration
        StringBuilder json = new StringBuilder("{");
        
        boolean first = true;
        for (Map.Entry<String, Object> entry : data.entrySet()) {
            if (!first) {
                json.append(",");
            }
            first = false;
            
            json.append("\"").append(entry.getKey()).append("\":");
            
            Object value = entry.getValue();
            if (value instanceof String) {
                json.append("\"").append(value).append("\"");
            } else if (value instanceof Number) {
                json.append(value);
            } else if (value instanceof Boolean) {
                json.append(value);
            } else if (value instanceof List) {
                json.append("[");
                List<?> list = (List<?>) value;
                for (int i = 0; i < list.size(); i++) {
                    if (i > 0) {
                        json.append(",");
                    }
                    // Handle OrderItem objects
                    Object item = list.get(i);
                    if (item instanceof OrderItem) {
                        OrderItem orderItem = (OrderItem) item;
                        json.append("{");
                        json.append("\"productId\":").append(orderItem.getProductId()).append(",");
                        json.append("\"productName\":\"").append(orderItem.getProductName()).append("\",");
                        json.append("\"quantity\":").append(orderItem.getQuantity()).append(",");
                        json.append("\"price\":").append(orderItem.getPrice());
                        json.append("}");
                    } else {
                        json.append("\"").append(item).append("\"");
                    }
                }
                json.append("]");
            } else {
                json.append("null");
            }
        }
        
        json.append("}");
        return json.toString();
    }
}