package com.shopeasy.shopeasy.dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.shopeasy.shopeasy.model.Order;
import com.shopeasy.shopeasy.model.OrderItem;
import com.shopeasy.shopeasy.model.Product;
import com.shopeasy.shopeasy.util.DBUtil;

/**
 * Data Access Object for Order entity
 */
public class OrderDAO {
    private Connection conn;
    private ProductDAO productDAO;
    
    public OrderDAO() {
        try {
            conn = DBUtil.getConnection();
            productDAO = new ProductDAO();
        } catch (SQLException e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Create a new order
     * @param order Order object to create
     * @return Order ID if successful, -1 otherwise
     */
    public int createOrder(Order order) {
        String sql = "INSERT INTO orders (user_id, order_date, total_amount, shipping_address, order_status, payment_method) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, order.getUserId());
            stmt.setTimestamp(2, new Timestamp(order.getOrderDate().getTime()));
            
            //Set Tax Inclusive Amount
            double taxInclusiveAmount = order.getTotalAmount() * 1.06;
            stmt.setBigDecimal(3, java.math.BigDecimal.valueOf(taxInclusiveAmount));
            stmt.setString(4, order.getShippingAddress());
            
            // Map the status from our app to the database enum values
            String dbStatus;
            switch(order.getStatus().toLowerCase()) {
                case "pending":
                    dbStatus = "packaging";
                    break;
                case "processing":
                    dbStatus = "shipping";
                    break;
                case "shipped":
                    dbStatus = "delivery";
                    break;
                case "delivered":
                    dbStatus = "delivered";
                    break;
                default:
                    dbStatus = "packaging";
            }
            stmt.setString(5, dbStatus);
            
            // Map the payment method from our app to the database enum values
            String dbPaymentMethod;
            switch(order.getPaymentMethod().toLowerCase()) {
                case "cash on delivery":
                    dbPaymentMethod = "cash";
                    break;
                case "credit/debit card":
                    dbPaymentMethod = "credit";
                    break;
                case "upi payment":
                    dbPaymentMethod = "e-wallet";
                    break;
                default:
                    dbPaymentMethod = "cash";
            }
            stmt.setString(6, dbPaymentMethod);
            
            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                return -1;
            }
            
            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                } else {
                    return -1;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error creating order: " + e.getMessage());
            e.printStackTrace();
            return -1;
        }
    }
    
    /**
     * Update order status or delete if cancelled
     * @param orderId Order ID
     * @param status New status
     * @return true if successful, false otherwise
     */
    public boolean updateOrderStatus(int orderId, String status) {
        // Map the application status to database status
        String dbStatus;
        System.out.println("Input status value: '" + status + "'");
        
        // Direct mapping without transformation - use exactly what comes from the dropdown
        // The dropdown options are already using the database enum values
        if (status.equals("packaging") || status.equals("shipping") || 
            status.equals("delivery") || status.equals("delivered")) {
            dbStatus = status;
        } else {
            // For backward compatibility, keep the old mapping as fallback
            switch(status.toLowerCase()) {
                case "pending":
                    dbStatus = "packaging";
                    break;
                case "processing":
                    dbStatus = "shipping";
                    break;
                case "shipped":
                    dbStatus = "delivery";
                    break;
                default:
                    System.out.println("Warning: Unknown status '" + status + "' being mapped to 'packaging'");
                    dbStatus = "packaging"; // Default to packaging if unknown status
            }
        }
        
        System.out.println("Mapped status '" + status + "' to DB status '" + dbStatus + "' for update");
        
        // First, verify the order exists
        Order existingOrder = getOrderById(orderId);
        if (existingOrder == null) {
            System.err.println("Cannot update order status: Order #" + orderId + " does not exist");
            return false;
        }
        
        String sql = "UPDATE orders SET order_status = ? WHERE order_id = ?";
        System.out.println("Executing SQL: " + sql + " with parameters: [" + dbStatus + ", " + orderId + "]");
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, dbStatus);
            stmt.setInt(2, orderId);
            
            int rowsAffected = stmt.executeUpdate();
            boolean success = rowsAffected > 0;
            
            if (success) {
                System.out.println("Successfully updated order #" + orderId + " status to '" + dbStatus + "'");
            } else {
                System.err.println("Update statement executed but no rows affected for order #" + orderId);
            }
            
            return success;
        } catch (SQLException e) {
            System.err.println("Database error updating order #" + orderId + " status: " + e.getMessage());
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            System.err.println("Unexpected error updating order #" + orderId + " status: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Delete an order and its associated order items
     * @param orderId Order ID to delete
     * @return true if successful, false otherwise
     */
    public boolean deleteOrder(int orderId) {
        // First delete associated order items (due to foreign key constraints)
        String deleteItemsSql = "DELETE FROM orderitems WHERE order_id = ?";
        
        // Then delete the order
        String deleteOrderSql = "DELETE FROM orders WHERE order_id = ?";
        
        try {
            // Start transaction
            conn.setAutoCommit(false);
            
            // Delete order items
            try (PreparedStatement stmt = conn.prepareStatement(deleteItemsSql)) {
                stmt.setInt(1, orderId);
                stmt.executeUpdate();
            }
            
            // Delete order
            try (PreparedStatement stmt = conn.prepareStatement(deleteOrderSql)) {
                stmt.setInt(1, orderId);
                int affectedRows = stmt.executeUpdate();
                
                // Commit transaction
                conn.commit();
                
                return affectedRows > 0;
            }
        } catch (SQLException e) {
            // Roll back transaction on error
            try {
                conn.rollback();
            } catch (SQLException rollbackEx) {
                System.err.println("Error rolling back transaction: " + rollbackEx.getMessage());
                rollbackEx.printStackTrace();
            }
            
            System.err.println("Error deleting order: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            // Restore auto-commit
            try {
                conn.setAutoCommit(true);
            } catch (SQLException e) {
                System.err.println("Error restoring auto-commit: " + e.getMessage());
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Get order by ID
     * @param orderId Order ID
     * @return Order object if found, null otherwise
     */
    public Order getOrderById(int orderId) {
        String sql = "SELECT * FROM orders WHERE order_id = ?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, orderId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractOrderFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting order by ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Get all orders by user ID
     * @param userId User ID
     * @return List of orders
     */
    public List<Order> getOrdersByUserId(int userId) {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT * FROM orders WHERE user_id = ? ORDER BY order_date DESC";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    orders.add(extractOrderFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting orders by user ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return orders;
    }
    
    /**
     * Get all orders
     * @return List of all orders
     */
    public List<Order> getAllOrders() {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT * FROM orders ORDER BY order_date DESC";
        
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                orders.add(extractOrderFromResultSet(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error getting all orders: " + e.getMessage());
            e.printStackTrace();
        }
        
        return orders;
    }
    
    /**
     * Add order item
     * @param orderItem OrderItem object to add
     * @return true if successful, false otherwise
     */
    public boolean addOrderItem(OrderItem orderItem) {
        String sql = "INSERT INTO orderitems (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, orderItem.getOrderId());
            stmt.setInt(2, orderItem.getProductId());
            stmt.setInt(3, orderItem.getQuantity());
            stmt.setInt(4, orderItem.getPrice());
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("Error adding order item: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Get order items by order ID
     * @param orderId Order ID
     * @return List of order items
     */
    public List<OrderItem> getOrderItemsByOrderId(int orderId) {
        List<OrderItem> orderItems = new ArrayList<>();
        String sql = "SELECT * FROM orderitems WHERE order_id = ?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, orderId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    OrderItem orderItem = extractOrderItemFromResultSet(rs);
                    
                    // Fetch and add product details
                    Product product = productDAO.getProductById(orderItem.getProductId());
                    if (product != null) {
                        orderItem.setProductName(product.getName());
                        orderItem.setProductImage(product.getImagePath());
                    }
                    
                    orderItems.add(orderItem);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting order items by order ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return orderItems;
    }
    
    /**
     * Extract Order object from ResultSet
     * @param rs ResultSet
     * @return Order object
     * @throws SQLException if error occurs
     */
    private Order extractOrderFromResultSet(ResultSet rs) throws SQLException {
        Order order = new Order();
        order.setOrderId(rs.getInt("order_id"));
        order.setUserId(rs.getInt("user_id"));
        order.setOrderDate(new Date(rs.getTimestamp("order_date").getTime()));
        
        // Fix the incompatible types error - handle null values appropriately
        BigDecimal totalAmount = rs.getBigDecimal("total_amount");
        if (totalAmount != null) {
            order.setTotalAmount(totalAmount.intValue());
        } else {
            order.setTotalAmount(0);
        }
        
        order.setShippingAddress(rs.getString("shipping_address"));
        
        // Map the database status to our app status consistently
        String dbStatus = rs.getString("order_status");
        String appStatus;
        if (dbStatus == null) {
            // Handle null status
            appStatus = "pending";
        } else {
            switch(dbStatus) {
                case "packaging":
                    appStatus = "pending";
                    break;
                case "shipping":
                    appStatus = "processing";
                    break;
                case "delivery":
                    appStatus = "shipped";
                    break;
                case "delivered":
                    appStatus = "delivered";
                    break;
                case "cancelled":
                    appStatus = "cancelled";
                    break;
                default:
                    // For any other database status, default to pending
                    appStatus = "pending";
            }
        }
        order.setStatus(appStatus);
        
        // Map the database payment method to our app payment method
        String dbPaymentMethod = rs.getString("payment_method");
        String appPaymentMethod;
        switch(dbPaymentMethod) {
            case "cash":
                appPaymentMethod = "Cash on Delivery";
                break;
            case "credit":
            case "debit":
                appPaymentMethod = "Credit/Debit Card";
                break;
            case "e-wallet":
                appPaymentMethod = "UPI Payment";
                break;
            default:
                appPaymentMethod = "Cash on Delivery";
        }
        order.setPaymentMethod(appPaymentMethod);
        
        // Handle missing tracking_number column
        try {
            String trackingNumber = rs.getString("tracking_number");
            order.setTrackingNumber(trackingNumber);
        } catch (SQLException e) {
            // Column doesn't exist, set tracking number to null
            order.setTrackingNumber(null);
        }
        
        return order;
    }
    
    /**
     * Get the total count of orders
     * @return Total number of orders
     */
    public int getOrderCount() {
        String sql = "SELECT COUNT(*) FROM orders";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("Error getting order count: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Get the total revenue from all orders
     * @return Total revenue
     */
    public double getTotalRevenue() {
        String sql = "SELECT SUM(total_amount) FROM orders";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            System.err.println("Error getting total revenue: " + e.getMessage());
            e.printStackTrace();
        }
        return 0.0;
    }
    
    /**
     * Extract OrderItem object from ResultSet
     * @param rs ResultSet
     * @return OrderItem object
     * @throws SQLException if error occurs
     */
    private OrderItem extractOrderItemFromResultSet(ResultSet rs) throws SQLException {
        OrderItem orderItem = new OrderItem();
        orderItem.setOrderItemId(rs.getInt("order_item_id"));
        orderItem.setOrderId(rs.getInt("order_id"));
        orderItem.setProductId(rs.getInt("product_id"));
        orderItem.setQuantity(rs.getInt("quantity"));
        orderItem.setPrice(rs.getInt("price"));
        return orderItem;
    }
    
    /**
     * Get revenue data between two dates
     * @param startDate Start date
     * @param endDate End date  
     * @return Map with dates as keys and revenue as values
     */
    public Map<String, Double> getRevenueBetweenDates(Date startDate, Date endDate) {
        Map<String, Double> revenueData = new LinkedHashMap<>(); // LinkedHashMap to maintain order
        
        String sql = "SELECT DATE(order_date) as date, SUM(total_amount) as revenue " +
                    "FROM orders " +
                    "WHERE order_date BETWEEN ? AND ? " +
                    "GROUP BY DATE(order_date) " +
                    "ORDER BY date";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setTimestamp(1, new Timestamp(startDate.getTime()));
            stmt.setTimestamp(2, new Timestamp(endDate.getTime()));
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    String date = rs.getDate("date").toString();
                    double revenue = rs.getDouble("revenue");
                    
                    // Print for debugging
                    System.out.printf("Revenue data: %s - $%.2f%n", date, revenue);
                    
                    revenueData.put(date, revenue);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting revenue data: " + e.getMessage());
            e.printStackTrace();
        }
        
        return revenueData;
    }

    /**
     * Get most popular products between two dates
     * @param startDate Start date
     * @param endDate End date
     * @param limit Number of products to return
     * @return List of maps containing product data
     */
    public List<Map<String, Object>> getMostPopularProductsBetweenDates(Date startDate, Date endDate, int limit) {
        List<Map<String, Object>> popularProducts = new ArrayList<>();
        
        String sql = "SELECT p.product_id, p.name, p.image_path, SUM(oi.quantity) as total_quantity, " +
                    "SUM(oi.price * oi.quantity) as total_revenue " +
                    "FROM orderitems oi " +
                    "JOIN products p ON oi.product_id = p.product_id " +
                    "JOIN orders o ON oi.order_id = o.order_id " +
                    "WHERE o.order_date BETWEEN ? AND ? " +
                    "GROUP BY p.product_id, p.name " +
                    "ORDER BY total_quantity DESC " +
                    "LIMIT ?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setTimestamp(1, new Timestamp(startDate.getTime()));
            stmt.setTimestamp(2, new Timestamp(endDate.getTime()));
            stmt.setInt(3, limit);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> product = new HashMap<>();
                    product.put("productId", rs.getInt("product_id"));
                    product.put("name", rs.getString("name"));
                    product.put("imagePath", rs.getString("image_path"));
                    product.put("totalQuantity", rs.getInt("total_quantity"));
                    product.put("totalRevenue", rs.getDouble("total_revenue"));
                    
                    // Print for debugging
                    System.out.printf("Popular product: %s - Qty: %d, Revenue: $%.2f%n", 
                        rs.getString("name"), rs.getInt("total_quantity"), rs.getDouble("total_revenue"));
                    
                    popularProducts.add(product);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting popular products: " + e.getMessage());
            e.printStackTrace();
        }
        
        return popularProducts;
    }

    /**
     * Get total sales info between dates
     * @param startDate Start date
     * @param endDate End date
     * @return Map with sales summary data
     */
    public Map<String, Object> getSalesSummaryBetweenDates(Date startDate, Date endDate) {
        Map<String, Object> summary = new HashMap<>();

        String totalRevenueSql = "SELECT SUM(total_amount) as total_revenue FROM orders WHERE order_date BETWEEN ? AND ?";
        String totalOrdersSql = "SELECT COUNT(*) as total_orders FROM orders WHERE order_date BETWEEN ? AND ?";
        String totalItemsSql = "SELECT SUM(oi.quantity) as total_items FROM orderitems oi " +
                              "JOIN orders o ON oi.order_id = o.order_id " +
                              "WHERE o.order_date BETWEEN ? AND ?";
        String avgOrderValueSql = "SELECT AVG(total_amount) as avg_order FROM orders WHERE order_date BETWEEN ? AND ?";

        try {
            // Get total revenue
            try (PreparedStatement stmt = conn.prepareStatement(totalRevenueSql)) {
                stmt.setTimestamp(1, new Timestamp(startDate.getTime()));
                stmt.setTimestamp(2, new Timestamp(endDate.getTime()));

                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        double totalRevenue = rs.getDouble("total_revenue");
                        summary.put("totalRevenue", totalRevenue);
                        System.out.printf("Total revenue: $%.2f%n", totalRevenue);
                    }
                }
            }

            // Get total orders
            try (PreparedStatement stmt = conn.prepareStatement(totalOrdersSql)) {
                stmt.setTimestamp(1, new Timestamp(startDate.getTime()));
                stmt.setTimestamp(2, new Timestamp(endDate.getTime()));

                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        int totalOrders = rs.getInt("total_orders");
                        summary.put("totalOrders", totalOrders);
                        System.out.printf("Total orders: %d%n", totalOrders);
                    }
                }
            }

            // Get total items sold
            try (PreparedStatement stmt = conn.prepareStatement(totalItemsSql)) {
                stmt.setTimestamp(1, new Timestamp(startDate.getTime()));
                stmt.setTimestamp(2, new Timestamp(endDate.getTime()));

                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        int totalItems = rs.getInt("total_items");
                        summary.put("totalItems", totalItems);
                        System.out.printf("Total items sold: %d%n", totalItems);
                    }
                }
            }

            // Get average order value
            try (PreparedStatement stmt = conn.prepareStatement(avgOrderValueSql)) {
                stmt.setTimestamp(1, new Timestamp(startDate.getTime()));
                stmt.setTimestamp(2, new Timestamp(endDate.getTime()));

                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        double avgOrder = rs.getDouble("avg_order");
                        summary.put("avgOrderValue", avgOrder);
                        System.out.printf("Average order value: $%.2f%n", avgOrder);
                    }
                }
            }

        } catch (SQLException e) {
            System.err.println("Error getting sales summary: " + e.getMessage());
            e.printStackTrace();
        }

        return summary;
    }

    /**
     * Get the count of orders for a specific user
     * @param userId User ID
     * @return Number of orders
     */
    public int getOrderCountByUserId(int userId) {
        String sql = "SELECT COUNT(*) FROM orders WHERE user_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting order count for user: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }
}