package com.shopeasy.shopeasy.dao;

import com.shopeasy.shopeasy.model.RegistrationKey;
import com.shopeasy.shopeasy.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.UUID;

/**
 * Data Access Object for RegistrationKey entity
 */
public class RegistrationKeyDAO {
    private Connection conn;
    
    public RegistrationKeyDAO(){
        try{
            conn = DBUtil.getConnection();
        }catch(SQLException e){
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Generate a new registration key
     * @param role Role for the key (manager, staff)
     * @param generatedBy User ID of the manager who generated the key
     * @param validDays Number of days the key will be valid
     * @return The generated key value if successful, null otherwise
     */
    public String generateKey(String role, int generatedBy, int validDays) {
        String keyValue = UUID.randomUUID().toString().replace("-", "");
        String sql = "INSERT INTO registration_keys (key_value, role, is_used, generated_by, expires_at) VALUES (?, ?, 0, ?, IF(? > 0, DATE_ADD(NOW(), INTERVAL ? DAY), '2030-12-31 23:59:59'))";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, keyValue);
            stmt.setString(2, role);
            stmt.setInt(3, generatedBy);
            stmt.setInt(4, validDays); // First use: for the IF condition
            stmt.setInt(5, validDays); // Second use: for the INTERVAL
            
            int affectedRows = stmt.executeUpdate();
            if (affectedRows > 0) {
                return keyValue;
            }
        } catch (SQLException e) {
            System.err.println("Error generating registration key: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Generate a custom registration key
     * @param role Role for the key (manager, staff)
     * @param generatedBy User ID of the manager who generated the key
     * @param validDays Number of days the key will be valid
     * @param customKeyValue The custom key value to use
     * @return The generated key value if successful, null otherwise
     */
    public String generateCustomKey(String role, int generatedBy, int validDays, String customKeyValue) {
        // Check if the custom key already exists
        String checkSql = "SELECT COUNT(*) FROM registration_keys WHERE key_value = ?";
        
        try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
            checkStmt.setString(1, customKeyValue);
            
            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    // Key already exists, generate a unique one instead
                    return generateKey(role, generatedBy, validDays);
                }
            }
            
            // Custom key doesn't exist, proceed with insertion
            String sql = "INSERT INTO registration_keys (key_value, role, is_used, generated_by, expires_at) " +
                         "VALUES (?, ?, 0, ?, IF(? > 0, DATE_ADD(NOW(), INTERVAL ? DAY), '2030-12-31 23:59:59'))";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, customKeyValue);
                stmt.setString(2, role);
                stmt.setInt(3, generatedBy);
                stmt.setInt(4, validDays); // First use: for the IF condition
                stmt.setInt(5, validDays); // Second use: for the INTERVAL
                
                int affectedRows = stmt.executeUpdate();
                if (affectedRows > 0) {
                    return customKeyValue;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error generating custom registration key: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Generate a formatted registration key with pattern like MGR-KEY-2025-XYZ999
     * @param prefix Role prefix (e.g., MGR, STF)
     * @param year Current year
     * @param generatedBy User ID of the manager who generated the key
     * @param validDays Number of days the key will be valid
     * @return The generated key value if successful, null otherwise
     */
    public String generateFormattedKey(String prefix, String year, int generatedBy, int validDays, String specifiedRole) {
     // Generate random suffix (3 letters and 3 numbers)
     String suffix = generateRandomSuffix();

     // Create the formatted key
     String keyValue = prefix + "-KEY-" + year + "-" + suffix;

     // Insert into database
     String sql = "INSERT INTO registration_keys (key_value, role, is_used, generated_by, expires_at) " +
                  "VALUES (?, ?, 0, ?, IF(? > 0, DATE_ADD(NOW(), INTERVAL ? DAY), '2030-12-31 23:59:59'))";

     try (PreparedStatement stmt = conn.prepareStatement(sql)) {
         // Use the specified role directly
         stmt.setString(1, keyValue);
         stmt.setString(2, specifiedRole);
         stmt.setInt(3, generatedBy);
         stmt.setInt(4, validDays);
         stmt.setInt(5, validDays);

         int affectedRows = stmt.executeUpdate();
         if (affectedRows > 0) {
             return keyValue;
         }
     } catch (SQLException e) {
         System.err.println("Error generating formatted registration key: " + e.getMessage());
         e.printStackTrace();
     }

     return null;
 }

    
    /**
     * Rename an existing registration key
     * @param keyId Key ID to rename
     * @param newValue New key value
     * @param managerId Manager user ID (for security - only the manager who created the key can rename it)
     * @return true if renaming successful, false otherwise
     */
    public boolean renameKey(int keyId, String newValue, int managerId) {
        // Check if the new key value already exists
        String checkSql = "SELECT COUNT(*) FROM registration_keys WHERE key_value = ? AND key_id != ?";
        
        try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
            checkStmt.setString(1, newValue);
            checkStmt.setInt(2, keyId);
            
            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    // New key value already exists
                    return false;
                }
            }
            
            // Proceed with update
            String sql = "UPDATE registration_keys SET key_value = ? WHERE key_id = ? AND generated_by = ? AND is_used = 0";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, newValue);
                stmt.setInt(2, keyId);
                stmt.setInt(3, managerId);
                
                int affectedRows = stmt.executeUpdate();
                return affectedRows > 0;
            }
        } catch (SQLException e) {
            System.err.println("Error renaming registration key: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Get all keys generated by a manager, including used and expired keys
     * @param managerId Manager user ID
     * @return List of all registration keys
     */
    public List<RegistrationKey> getAllKeysByManager(int managerId) {
        List<RegistrationKey> keys = new ArrayList<>();
        String sql = "SELECT * FROM registration_keys WHERE generated_by = ? ORDER BY created_at DESC";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, managerId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    keys.add(extractKeyFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting all keys by manager: " + e.getMessage());
            e.printStackTrace();
        }
        
        return keys;
    }
    
    /**
     * Validate a registration key
     * @param keyValue Key value to validate
     * @return RegistrationKey object if valid, null otherwise
     */
    public RegistrationKey validateKey(String keyValue) {
        // Note: The default expiration date '2030-12-31 23:59:59' will pass the expires_at > NOW() check until that date
        String sql = "SELECT * FROM registration_keys WHERE key_value = ? AND is_used = 0 AND expires_at > NOW()";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, keyValue);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractKeyFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error validating registration key: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Mark a key as used
     * @param keyValue Key value to mark as used
     * @return true if successful, false otherwise
     */
    public boolean markKeyAsUsed(String keyValue) {
        String sql = "UPDATE registration_keys SET is_used = 1 WHERE key_value = ?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, keyValue);
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("Error marking key as used: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Get all active keys generated by a manager
     * @param managerId Manager user ID
     * @return List of active registration keys
     */
    public List<RegistrationKey> getActiveKeysByManager(int managerId) {
        List<RegistrationKey> keys = new ArrayList<>();
        // This will include keys with the default '2030-12-31 23:59:59' expiration date
        String sql = "SELECT * FROM registration_keys WHERE generated_by = ? ORDER BY created_at DESC";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, managerId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    keys.add(extractKeyFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting active keys by manager: " + e.getMessage());
            e.printStackTrace();
        }
        
        return keys;
    }
    
    /**
     * Delete an unused key
     * @param keyId Key ID to delete
     * @param managerId Manager user ID (for security - only the manager who created the key can delete it)
     * @return true if deletion successful, false otherwise
     */
    public boolean deleteKey(int keyId, int managerId) {
        String sql = "DELETE FROM registration_keys WHERE key_id = ? AND generated_by = ? AND is_used = 0";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, keyId);
            stmt.setInt(2, managerId);
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("Error deleting registration key: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Helper method to extract RegistrationKey from ResultSet
     * @param rs ResultSet
     * @return RegistrationKey object
     * @throws SQLException if a database access error occurs
     */
    private RegistrationKey extractKeyFromResultSet(ResultSet rs) throws SQLException {
        RegistrationKey key = new RegistrationKey();
        key.setKeyId(rs.getInt("key_id"));
        key.setKeyValue(rs.getString("key_value"));
        key.setRole(rs.getString("role"));
        key.setUsed(rs.getBoolean("is_used"));
        key.setGeneratedBy(rs.getInt("generated_by"));
        key.setCreatedAt(rs.getTimestamp("created_at"));
        key.setExpiresAt(rs.getTimestamp("expires_at"));
        return key;
    }
    
    /**
     * Generate a random suffix for formatted keys (3 letters followed by 3 numbers)
     * @return Random suffix string
     */
    private String generateRandomSuffix() {
        Random random = new Random();
        StringBuilder suffix = new StringBuilder();
        
        // Add 3 random uppercase letters
        for (int i = 0; i < 3; i++) {
            char randomChar = (char) (random.nextInt(26) + 'A');
            suffix.append(randomChar);
        }
        
        // Add 3 random numbers
        for (int i = 0; i < 3; i++) {
            int randomDigit = random.nextInt(10);
            suffix.append(randomDigit);
        }
        
        return suffix.toString();
    }
}