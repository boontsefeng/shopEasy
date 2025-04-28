package com.shopeasy.shopeasy.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.shopeasy.shopeasy.model.Cart;
import com.shopeasy.shopeasy.model.Product;
import com.shopeasy.shopeasy.util.DBUtil;

/**
 * Data Access Object for Cart entity
 */
public class CartDAO {

    private Connection conn;
    private ProductDAO productDAO;

    public CartDAO() {
        try {
            conn = DBUtil.getConnection();
            productDAO = new ProductDAO();
        } catch (SQLException e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Add item to cart or update quantity if already exists
     *
     * @param cart Cart object to add
     * @return true if successful, false otherwise
     */
    public boolean addToCart(Cart cart) {
        // First check if item already exists in cart
        String checkSql = "SELECT * FROM cartitems WHERE user_id = ? AND product_id = ?";

        try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
            checkStmt.setInt(1, cart.getUserId());
            checkStmt.setInt(2, cart.getProductId());

            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next()) {
                    // Item exists, update quantity
                    int cartId = rs.getInt("cart_item_id");
                    int currentQuantity = rs.getInt("quantity");
                    int newQuantity = currentQuantity + cart.getQuantity();

                    String updateSql = "UPDATE cartitems SET quantity = ? WHERE cart_item_id = ?";
                    try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                        updateStmt.setInt(1, newQuantity);
                        updateStmt.setInt(2, cartId);

                        int affectedRows = updateStmt.executeUpdate();
                        return affectedRows > 0;
                    }
                } else {
                    // Item doesn't exist, insert new
                    String insertSql = "INSERT INTO cartitems (user_id, product_id, quantity) VALUES (?, ?, ?)";
                    try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                        insertStmt.setInt(1, cart.getUserId());
                        insertStmt.setInt(2, cart.getProductId());
                        insertStmt.setInt(3, cart.getQuantity());

                        int affectedRows = insertStmt.executeUpdate();
                        return affectedRows > 0;
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Error adding to cart: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Update cart item quantity
     *
     * @param cartId Cart item ID
     * @param quantity New quantity
     * @return true if successful, false otherwise
     */
    public boolean updateCartItemQuantity(int cartId, int quantity) {
        String sql = "UPDATE cartitems SET quantity = ? WHERE cart_item_id = ?";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, quantity);
            stmt.setInt(2, cartId);

            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("Error updating cart item quantity: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Remove item from cart
     *
     * @param cartId Cart item ID
     * @return true if successful, false otherwise
     */
    public boolean removeFromCart(int cartId) {
        String sql = "DELETE FROM cartitems WHERE cart_item_id = ?";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, cartId);

            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("Error removing from cart: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Clear user's cart
     *
     * @param userId User ID
     * @return true if successful, false otherwise
     */
    public boolean clearCart(int userId) {
        String sql = "DELETE FROM cartitems WHERE user_id = ?";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);

            int affectedRows = stmt.executeUpdate();
            return affectedRows >= 0; // Return true even if no items in cart
        } catch (SQLException e) {
            System.err.println("Error clearing cart: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get user's cart
     *
     * @param userId User ID
     * @return List of cart items with product details
     */
    public List<Cart> getUserCart(int userId) {
        List<Cart> cartItems = new ArrayList<>();
        String sql = "SELECT * FROM cartitems WHERE user_id = ?";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Cart cart = extractCartFromResultSet(rs);

                    // Fetch and add product details
                    Product product = productDAO.getProductById(cart.getProductId());
                    if (product != null) {
                        cart.setProductName(product.getName());
                        cart.setProductPrice(product.getPrice());
                        cart.setProductImage(product.getImagePath());
                    }

                    cartItems.add(cart);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting user cart: " + e.getMessage());
            e.printStackTrace();
        }

        return cartItems;
    }

    /**
     * Get cart total price
     *
     * @param userId User ID
     * @return Total price of all items in cart
     */
    public int getCartTotal(int userId) {
        int total = 0;
        List<Cart> cartItems = getUserCart(userId);

        for (Cart item : cartItems) {
            total += item.getTotalPrice();
        }

        return total;
    }

    /**
     * Get cart item count
     *
     * @param userId User ID
     * @return Number of items in cart
     */
    public int getCartItemCount(int userId) {
        int count = 0;
        String sql = "SELECT COUNT(*) as count FROM cartitems WHERE user_id = ?";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt("count");
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting cart item count: " + e.getMessage());
            e.printStackTrace();
        }

        return count;
    }

    /**
     * Check if product is in cart
     *
     * @param userId User ID
     * @param productId Product ID
     * @return true if product is in cart, false otherwise
     */
    public boolean isProductInCart(int userId, int productId) {
        String sql = "SELECT * FROM cartitems WHERE user_id = ? AND product_id = ?";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, productId);

            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.err.println("Error checking if product is in cart: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Extract Cart object from ResultSet
     *
     * @param rs ResultSet
     * @return Cart object
     * @throws SQLException if error occurs
     */
    private Cart extractCartFromResultSet(ResultSet rs) throws SQLException {
        Cart cart = new Cart();
        cart.setCartId(rs.getInt("cart_item_id"));
        cart.setUserId(rs.getInt("user_id"));
        cart.setProductId(rs.getInt("product_id"));
        cart.setQuantity(rs.getInt("quantity"));
        return cart;
    }
}
