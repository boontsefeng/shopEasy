package com.shopeasy.shopeasy.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * Utility class for password hashing and verification
 */
public class PasswordUtil {
    
    // Algorithm to use for hashing (SHA-256 is widely supported)
    private static final String HASH_ALGORITHM = "SHA-256";
    
    // Length of the salt in bytes
    private static final int SALT_LENGTH = 16;
    
    /**
     * Generate a random salt
     * @return Base64 encoded salt string
     */
    private static String generateSalt() {
        SecureRandom random = new SecureRandom();
        byte[] salt = new byte[SALT_LENGTH];
        random.nextBytes(salt);
        return Base64.getEncoder().encodeToString(salt);
    }
    
    /**
     * Hash a password with a given salt
     * @param password The plain text password
     * @param salt The salt as a Base64 string
     * @return Base64 encoded hashed password
     * @throws NoSuchAlgorithmException If the hashing algorithm is not available
     */
    private static String hashPassword(String password, String salt) throws NoSuchAlgorithmException {
        MessageDigest md = MessageDigest.getInstance(HASH_ALGORITHM);
        md.update(Base64.getDecoder().decode(salt));
        byte[] hashedPassword = md.digest(password.getBytes());
        return Base64.getEncoder().encodeToString(hashedPassword);
    }
    
    /**
     * Hash a password with a new random salt
     * @param password The plain text password
     * @return salt:hashedPassword (both Base64 encoded, separated by colon)
     */
    public static String hashPasswordWithSalt(String password) {
        try {
            String salt = generateSalt();
            String hashedPassword = hashPassword(password, salt);
            return salt + ":" + hashedPassword;
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error hashing password: " + e.getMessage(), e);
        }
    }
    
    /**
     * Verify a password against a stored hash
     * @param password The plain text password to verify
     * @param storedHash The stored hash in format salt:hashedPassword
     * @return true if the password matches, false otherwise
     */
    public static boolean verifyPassword(String password, String storedHash) {
        try {
            String[] parts = storedHash.split(":");
            if (parts.length != 2) {
                return false;
            }
            
            String salt = parts[0];
            String storedHashedPassword = parts[1];
            
            String computedHash = hashPassword(password, salt);
            return computedHash.equals(storedHashedPassword);
            
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error verifying password: " + e.getMessage(), e);
        }
    }
}