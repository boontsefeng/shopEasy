package com.shopeasy.shopeasy.util;

/**
 * Simple utility class for JSON string handling
 */
public class JsonUtil {
    
    /**
     * Escape special characters in a string for JSON compatibility
     * @param input String to escape
     * @return Escaped string safe for JSON inclusion
     */
    public static String escapeJson(String input) {
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
     * Build a simple JSON success response
     * @param message Success message
     * @return JSON string with success flag and message
     */
    public static String buildSuccessJson(String message) {
        return "{\"success\":true,\"message\":\"" + escapeJson(message) + "\"}";
    }
    
    /**
     * Build a simple JSON error response
     * @param message Error message
     * @return JSON string with error flag and message
     */
    public static String buildErrorJson(String message) {
        return "{\"success\":false,\"message\":\"" + escapeJson(message) + "\"}";
    }
}