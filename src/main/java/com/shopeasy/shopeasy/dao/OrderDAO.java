package com.shopeasy.shopeasy.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

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
            stmt.setBigDecimal(3, java.math.BigDecimal.valueOf(order.getTotalAmount()));
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
                case "card on delivery":
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
     * Update order status
     * @param orderId Order ID
     * @param status New status
     * @return true if successful, false otherwise
     */
    public boolean updateOrderStatus(int orderId, String status) {
        // Map the status from our app to the database enum values
        String dbStatus;
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
            case "delivered":
                dbStatus = "delivered";
                break;
            default:
                dbStatus = "packaging";
        }
        
        String sql = "UPDATE orders SET order_status = ? WHERE order_id = ?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, dbStatus);
            stmt.setInt(2, orderId);
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("Error updating order status: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Update order tracking number
     * @param orderId Order ID
     * @param trackingNumber New tracking number
     * @return true if successful, false otherwise
     */
    public boolean updateTrackingNumber(int orderId, String trackingNumber) {
        String sql = "UPDATE orders SET tracking_number = ? WHERE order_id = ?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, trackingNumber);
            stmt.setInt(2, orderId);
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("Error updating tracking number: " + e.getMessage());
            e.printStackTrace();
            return false;
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
        order.setTotalAmount(rs.getBigDecimal("total_amount").intValue());
        order.setShippingAddress(rs.getString("shipping_address"));
        
        // Map the database status to our app status
        String dbStatus = rs.getString("order_status");
        String appStatus;
        switch(dbStatus) {
            case "packaging":
                appStatus = "Pending";
                break;
            case "shipping":
                appStatus = "Processing";
                break;
            case "delivery":
                appStatus = "Shipped";
                break;
            case "delivered":
                appStatus = "Delivered";
                break;
            default:
                appStatus = "Pending";
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
                appPaymentMethod = "Card on Delivery";
                break;
            case "e-wallet":
                appPaymentMethod = "UPI Payment";
                break;
            default:
                appPaymentMethod = "Cash on Delivery";
        }
        order.setPaymentMethod(appPaymentMethod);
        
        // Set tracking number if exists (may be null)
        order.setTrackingNumber(rs.getString("tracking_number"));
        return order;
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
} 