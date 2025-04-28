package com.shopeasy.shopeasy.controller;

import com.shopeasy.shopeasy.dao.UserDAO;
import com.shopeasy.shopeasy.model.User;
import com.shopeasy.shopeasy.util.smsotp;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "ForgotPasswordServlet", urlPatterns = {"/forgotPassword"})
public class ForgotPasswordServlet extends HttpServlet {
    // Logger for diagnostic information
    private static final Logger LOGGER = Logger.getLogger(ForgotPasswordServlet.class.getName());
    
    // Store OTPs with phone numbers and expiration times
    private static final Map<String, OtpData> otpStorage = new HashMap<>();
    
    // Inner class to store OTP data with expiration
    private static class OtpData {
        private final String otp;
        private final long expirationTime;
        
        public OtpData(String otp) {
            this.otp = otp;
            // OTP expires in 60 seconds
            this.expirationTime = System.currentTimeMillis() + 60000;
        }
        
        public boolean isValid(String inputOtp) {
            return otp.equals(inputOtp) && System.currentTimeMillis() < expirationTime;
        }
        
        public boolean isExpired() {
            return System.currentTimeMillis() >= expirationTime;
        }
        
        public String getOtp() {
            return otp;
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Just forward to the forgot password JSP
        request.getRequestDispatcher("/view/forgotpassword.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if (action == null) {
            // Default to showing the initial form
            request.getRequestDispatcher("/view/forgotpassword.jsp").forward(request, response);
            return;
        }
        
        switch (action) {
            case "sendOTP":
                handleSendOTP(request, response);
                break;
                
            case "verifyOTP":
                handleVerifyOTP(request, response);
                break;
                
            case "resetPassword":
                handleResetPassword(request, response);
                break;
                
            default:
                request.getRequestDispatcher("/view/forgotpassword.jsp").forward(request, response);
                break;
        }
    }
    
    private void handleSendOTP(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String phoneNumber = request.getParameter("phoneNumber");
        String countryCode = request.getParameter("countryCode");
        String username = request.getParameter("username");
        
        LOGGER.log(Level.INFO, "OTP request - Phone: {0}, Country Code: {1}, Username: {2}", 
                new Object[]{phoneNumber, countryCode, username});
        
        // Validate phone number format
        if (phoneNumber == null || phoneNumber.trim().isEmpty()) {
            LOGGER.log(Level.WARNING, "Phone number is empty or null");
            request.setAttribute("error", "Phone number is required");
            request.getRequestDispatcher("/view/forgotpassword.jsp").forward(request, response);
            return;
        }
        
        if (countryCode == null || countryCode.trim().isEmpty()) {
            LOGGER.log(Level.WARNING, "Country code is empty or null");
            request.setAttribute("error", "Country code is required");
            request.getRequestDispatcher("/view/forgotpassword.jsp").forward(request, response);
            return;
        }
        
        // Remove any non-digit characters from the phone number
        phoneNumber = phoneNumber.replaceAll("\\D", "");
        
        // Format the complete international number
        String rawPhoneNumber = phoneNumber; // Keep a copy for database lookup
        String formattedPhoneNumber = countryCode + phoneNumber;
        
        LOGGER.log(Level.INFO, "Formatted phone number: {0}", formattedPhoneNumber);
        
        // First, try to find user by username if provided
        UserDAO userDAO = new UserDAO();
        User user = null;
        
        if (username != null && !username.trim().isEmpty()) {
            user = userDAO.getUserByUsername(username);
            LOGGER.log(Level.INFO, "Looking up user by username: {0}, found: {1}", 
                    new Object[]{username, (user != null)});
        }
        
        // If username lookup failed or wasn't provided, try phone number
        if (user == null) {
            // Check if phone number exists in the database - try different formats
            user = userDAO.getUserByPhoneNumber(rawPhoneNumber);
            
            if (user == null) {
                // Try with country code
                user = userDAO.getUserByPhoneNumber(formattedPhoneNumber);
            }
            
            if (user == null) {
                // Try with + prefix
                user = userDAO.getUserByPhoneNumber("+" + countryCode + rawPhoneNumber);
            }
        }
        
        if (user == null) {
            LOGGER.log(Level.WARNING, "No user found with phone number: {0} or username: {1}", 
                    new Object[]{formattedPhoneNumber, username});
            request.setAttribute("error", "No account found with this phone number or username");
            request.getRequestDispatcher("/view/forgotpassword.jsp").forward(request, response);
            return;
        }
        
        LOGGER.log(Level.INFO, "User found: {0} with phone: {1}", new Object[]{user.getUsername(), user.getContactNumber()});
        
        // Store username for subsequent requests
        request.setAttribute("username", user.getUsername());
        
        // Generate OTP
        String otp = smsotp.getOTPCode();
        LOGGER.log(Level.INFO, "Generated OTP: {0} for phone: {1}", new Object[]{otp, formattedPhoneNumber});
        
        // Store OTP in the map with expiration
        otpStorage.put(user.getUsername(), new OtpData(otp));
        
        try {
            // Send OTP via SMS
            LOGGER.log(Level.INFO, "Attempting to send OTP to: {0}", formattedPhoneNumber);
            smsotp smsService = new smsotp("Password Reset", Long.parseLong(formattedPhoneNumber), otp);
            boolean otpSent = smsService.sendOTP(smsService);
            
            if (otpSent) {
                LOGGER.log(Level.INFO, "OTP sent successfully to: {0}", formattedPhoneNumber);
                // Move to the OTP verification step
                request.setAttribute("phoneNumber", formattedPhoneNumber);
                request.setAttribute("username", user.getUsername());
                request.setAttribute("step", "2");
                request.getRequestDispatcher("/view/forgotpassword.jsp?step=2").forward(request, response);
            } else {
                LOGGER.log(Level.WARNING, "OTP sending failed to: {0}", formattedPhoneNumber);
                request.setAttribute("error", "Failed to send OTP. Please try again.");
                request.getRequestDispatcher("/view/forgotpassword.jsp").forward(request, response);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Exception when sending OTP: {0}", e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "System error when sending OTP: " + e.getMessage());
            request.getRequestDispatcher("/view/forgotpassword.jsp").forward(request, response);
        }
    }
    
    private void handleVerifyOTP(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String phoneNumber = request.getParameter("phoneNumber");
        String username = request.getParameter("username");
        String inputOtp = request.getParameter("otp");
        
        LOGGER.log(Level.INFO, "Verifying OTP - Phone: {0}, Username: {1}", new Object[]{phoneNumber, username});
        
        if (inputOtp == null) {
            LOGGER.log(Level.WARNING, "OTP is null or empty");
            request.setAttribute("error", "OTP is required");
            request.getRequestDispatcher("/view/forgotpassword.jsp").forward(request, response);
            return;
        }
        
        // We're using username as the key for OTP storage now
        if (username == null || username.trim().isEmpty()) {
            LOGGER.log(Level.WARNING, "Username is missing for OTP verification");
            request.setAttribute("error", "Session data is missing. Please try again.");
            request.getRequestDispatcher("/view/forgotpassword.jsp").forward(request, response);
            return;
        }
        
        // Validate OTP
        OtpData otpData = otpStorage.get(username);
        
        if (otpData == null) {
            LOGGER.log(Level.WARNING, "No OTP was requested for username: {0}", username);
            request.setAttribute("error", "No OTP was requested for this user or session expired");
            request.getRequestDispatcher("/view/forgotpassword.jsp").forward(request, response);
            return;
        }
        
        if (otpData.isExpired()) {
            LOGGER.log(Level.WARNING, "OTP expired for username: {0}", username);
            otpStorage.remove(username);
            request.setAttribute("error", "OTP has expired. Please request a new one.");
            request.getRequestDispatcher("/view/forgotpassword.jsp").forward(request, response);
            return;
        }
        
        if (!otpData.isValid(inputOtp)) {
            LOGGER.log(Level.WARNING, "Invalid OTP entered for username: {0}. Expected: {1}, Got: {2}", 
                    new Object[]{username, otpData.getOtp(), inputOtp});
            request.setAttribute("error", "Invalid OTP. Please try again.");
            request.setAttribute("phoneNumber", phoneNumber);
            request.setAttribute("username", username);
            request.setAttribute("step", "2");
            request.getRequestDispatcher("/view/forgotpassword.jsp?step=2").forward(request, response);
            return;
        }
        
        LOGGER.log(Level.INFO, "OTP verified successfully for username: {0}", username);
        
        // OTP is valid, move to password reset step
        request.setAttribute("phoneNumber", phoneNumber);
        request.setAttribute("username", username);
        request.setAttribute("step", "3");
        request.getRequestDispatcher("/view/forgotpassword.jsp?step=3").forward(request, response);
    }
    
    private void handleResetPassword(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String phoneNumber = request.getParameter("phoneNumber");
        String username = request.getParameter("username");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        
        LOGGER.log(Level.INFO, "Password reset request for username: {0}, phone: {1}", 
                new Object[]{username, phoneNumber});
        
        if (newPassword == null || confirmPassword == null) {
            LOGGER.log(Level.WARNING, "Password fields are empty");
            request.setAttribute("error", "All fields are required");
            request.getRequestDispatcher("/view/forgotpassword.jsp").forward(request, response);
            return;
        }
        
        // Validate passwords match
        if (!newPassword.equals(confirmPassword)) {
            LOGGER.log(Level.WARNING, "Passwords do not match");
            request.setAttribute("error", "Passwords do not match");
            request.setAttribute("phoneNumber", phoneNumber);
            request.setAttribute("username", username);
            request.setAttribute("step", "3");
            request.getRequestDispatcher("/view/forgotpassword.jsp?step=3").forward(request, response);
            return;
        }
        
        // Validate password complexity
        boolean lengthValid = newPassword.length() >= 8;
        boolean uppercaseValid = newPassword.matches(".*[A-Z].*");
        boolean specialCharValid = newPassword.matches(".*[!@#$%^&*(),.?\":{}|<>].*");
        
        if (!lengthValid || !uppercaseValid || !specialCharValid) {
            LOGGER.log(Level.WARNING, "Password does not meet complexity requirements");
            StringBuilder errorMsg = new StringBuilder("Password must ");
            if (!lengthValid) errorMsg.append("be at least 8 characters long, ");
            if (!uppercaseValid) errorMsg.append("contain at least one uppercase letter, ");
            if (!specialCharValid) errorMsg.append("contain at least one special character, ");
            errorMsg.delete(errorMsg.length() - 2, errorMsg.length()); // Remove trailing comma and space
            
            request.setAttribute("error", errorMsg.toString());
            request.setAttribute("phoneNumber", phoneNumber);
            request.setAttribute("username", username);
            request.setAttribute("step", "3");
            request.getRequestDispatcher("/view/forgotpassword.jsp?step=3").forward(request, response);
            return;
        }
        
        // Get user by username (preferred) or phone number
        UserDAO userDAO = new UserDAO();
        User user = null;
        
        if (username != null && !username.trim().isEmpty()) {
            user = userDAO.getUserByUsername(username);
            LOGGER.log(Level.INFO, "Looking up user by username: {0}, found: {1}", 
                    new Object[]{username, (user != null)});
        }
        
        if (user == null && phoneNumber != null && !phoneNumber.trim().isEmpty()) {
            user = userDAO.getUserByPhoneNumber(phoneNumber);
            LOGGER.log(Level.INFO, "Looking up user by phone: {0}, found: {1}", 
                    new Object[]{phoneNumber, (user != null)});
        }
        
        if (user == null) {
            LOGGER.log(Level.WARNING, "User not found for reset");
            request.setAttribute("error", "User not found");
            request.getRequestDispatcher("/view/forgotpassword.jsp").forward(request, response);
            return;
        }
        
        // Update password
        boolean updated = userDAO.updatePassword(user.getUserId(), newPassword);
        
        if (updated) {
            LOGGER.log(Level.INFO, "Password updated successfully for user: {0}", user.getUsername());
            // Clean up OTP storage
            otpStorage.remove(username);
            
            // Show success message on login page
            request.setAttribute("success", "Your password has been reset successfully. You can now log in with your new password.");
            request.getRequestDispatcher("/view/login.jsp").forward(request, response);
        } else {
            LOGGER.log(Level.WARNING, "Password update failed for user: {0}", user.getUsername());
            request.setAttribute("error", "Failed to update password. Please try again.");
            request.setAttribute("phoneNumber", phoneNumber);
            request.setAttribute("username", username);
            request.setAttribute("step", "3");
            request.getRequestDispatcher("/view/forgotpassword.jsp?step=3").forward(request, response);
        }
    }
}