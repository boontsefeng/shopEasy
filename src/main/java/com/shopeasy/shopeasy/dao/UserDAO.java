package com.shopeasy.shopeasy.dao;

import com.shopeasy.shopeasy.model.User;
import com.shopeasy.shopeasy.util.DBUtil;
import com.shopeasy.shopeasy.util.PasswordUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for User entity
 */
public class UserDAO {
    private Connection conn;
    
    public UserDAO(){
    try{
        conn = DBUtil.getConnection();
        }catch(SQLException e){
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    
    /**
     * Authenticate user and check credentials
     * @param username Username
     * @param password Password
     * @return User object if authentication successful, null otherwise
     */
    public User authenticate(String username, String password) {
        String sql = "SELECT * FROM users WHERE username = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    User user = extractUserFromResultSet(rs);
                    // Verify the password using the hashing utility
                    if (PasswordUtil.verifyPassword(password, user.getPassword())) {
                        return user;
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Error authenticating user: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Get user by ID
     * @param userId User ID
     * @return User object if found, null otherwise
     */
    public User getUserById(int userId) {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractUserFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting user by ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Get user by username
     * @param username Username
     * @return User object if found, null otherwise
     */
    public User getUserByUsername(String username) {
        String sql = "SELECT * FROM users WHERE username = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractUserFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting user by username: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Get user by email
     * @param email Email address
     * @return User object if found, null otherwise
     */
    public User getUserByEmail(String email) {
        String sql = "SELECT * FROM users WHERE email = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractUserFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting user by email: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Get all users with specific role
     * @param role User role
     * @return List of users with the specified role
     */
    public List<User> getUsersByRole(String role) {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE role = ?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, role);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    users.add(extractUserFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting users by role: " + e.getMessage());
            e.printStackTrace();
        }
        
        return users;
    }
    
    /**
     * Get all users
     * @return List of all users
     */
    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users";
        
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                users.add(extractUserFromResultSet(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error getting all users: " + e.getMessage());
            e.printStackTrace();
        }
        
        return users;
    }
    
    /**
     * Create a new user
     * @param user User object to create
     * @return User ID if successful, -1 otherwise
     */
    public int createUser(User user) {
        String sql = "INSERT INTO users (username, password, role, name, contact_number, email) VALUES (?, ?, ?, ?, ?, ?)";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            // Hash the password before storing
            String hashedPassword = PasswordUtil.hashPasswordWithSalt(user.getPassword());
            
            stmt.setString(1, user.getUsername());
            stmt.setString(2, hashedPassword);
            stmt.setString(3, user.getRole());
            stmt.setString(4, user.getName());
            stmt.setString(5, user.getContactNumber());
            stmt.setString(6, user.getEmail());
            
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
            System.err.println("Error creating user: " + e.getMessage());
            e.printStackTrace();
            return -1;
        }
    }
    
    /**
     * Update an existing user
     * @param user User object to update
     * @param updatePassword Whether to update the password
     * @return true if update successful, false otherwise
     */
    public boolean updateUser(User user, boolean updatePassword) {
        String sql;
        if (updatePassword) {
            sql = "UPDATE users SET username = ?, password = ?, role = ?, name = ?, contact_number = ?, email = ? WHERE user_id = ?";
        } else {
            sql = "UPDATE users SET username = ?, role = ?, name = ?, contact_number = ?, email = ? WHERE user_id = ?";
        }
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, user.getUsername());
            
            if (updatePassword) {
                // Hash the password before storing
                String hashedPassword = PasswordUtil.hashPasswordWithSalt(user.getPassword());
                stmt.setString(2, hashedPassword);
                stmt.setString(3, user.getRole());
                stmt.setString(4, user.getName());
                stmt.setString(5, user.getContactNumber());
                stmt.setString(6, user.getEmail());
                stmt.setInt(7, user.getUserId());
            } else {
                stmt.setString(2, user.getRole());
                stmt.setString(3, user.getName());
                stmt.setString(4, user.getContactNumber());
                stmt.setString(5, user.getEmail());
                stmt.setInt(6, user.getUserId());
            }
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("Error updating user: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Update an existing user (backward compatibility)
     * @param user User object to update
     * @return true if update successful, false otherwise
     */
    public boolean updateUser(User user) {
        return updateUser(user, false);
    }
    
    /**
     * Update a user's password
     * @param userId User ID
     * @param newPassword New password (plaintext)
     * @return true if update successful, false otherwise
     */
    public boolean updatePassword(int userId, String newPassword) {
        String sql = "UPDATE users SET password = ? WHERE user_id = ?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            // Hash the password before storing
            String hashedPassword = PasswordUtil.hashPasswordWithSalt(newPassword);
            stmt.setString(1, hashedPassword);
            stmt.setInt(2, userId);
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("Error updating password: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Delete a user
     * @param userId User ID to delete
     * @return true if deletion successful, false otherwise
     */
    public boolean deleteUser(int userId) {
        String sql = "DELETE FROM users WHERE user_id = ?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("Error deleting user: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Check if username already exists
     * @param username Username to check
     * @return true if username exists, false otherwise
     */
    public boolean usernameExists(String username) {
        String sql = "SELECT COUNT(*) FROM users WHERE username = ?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error checking username existence: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Check if email already exists
     * @param email Email to check
     * @return true if email exists, false otherwise
     */
    public boolean emailExists(String email) {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error checking email existence: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Helper method to extract User from ResultSet
     * @param rs ResultSet
     * @return User object
     * @throws SQLException if a database access error occurs
     */
    private User extractUserFromResultSet(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("user_id"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setRole(rs.getString("role"));
        user.setName(rs.getString("name"));
        user.setContactNumber(rs.getString("contact_number"));
        user.setEmail(rs.getString("email"));
        return user;
    }
    
    //Validate User
       public User validateUser(String username, String password) {
        String sql = "SELECT * FROM users WHERE username = ? AND password = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, username);
            stmt.setString(2, password); // Plain text comparison for now
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setUsername(rs.getString("username"));
                    user.setPassword(rs.getString("password")); 
                    user.setRole(rs.getString("role"));
                    user.setName(rs.getString("name"));
                    user.setContactNumber(rs.getString("contact_number"));
                    user.setEmail(rs.getString("email"));
                    return user;
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

}