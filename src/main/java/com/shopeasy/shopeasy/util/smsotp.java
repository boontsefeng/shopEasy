package com.shopeasy.shopeasy.util;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Random;
import java.util.logging.Level;
import java.util.logging.Logger;

public class smsotp {
    private static final Logger LOGGER = Logger.getLogger(smsotp.class.getName());
    
    private String token = "Vpa8nwcPolzEBFDrjETrYpnODC8KMrb2"; // Updated token
    private String type;
    private Long phoneNumber;
    private String OTP;

    public smsotp(String type, Long phoneNumber, String OTP) {
        this.type = type;
        this.phoneNumber = phoneNumber;
        this.OTP = OTP;
    }
    
    public static String getOTPCode(){
        return generateOTP();
    }

    public boolean sendOTP(smsotp sms) {
        boolean OTPStatus = false;
        
        LOGGER.log(Level.INFO, "Sending OTP to phone number: {0}", sms.phoneNumber);
        
        try {
            // Prepare the URL and open a connection
            URL url = new URL("https://terminal.adasms.com/api/v1/send");
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();

            // Set up the connection properties
            connection.setRequestMethod("POST");
            connection.setRequestProperty("Content-Type", "multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW");
            connection.setDoOutput(true);
            connection.setConnectTimeout(10000); // 10 seconds timeout
            connection.setReadTimeout(10000);

            // Create the message content
            String message = "ShopEasy: " + sms.OTP + " is your one-time password for " + sms.type + ". Do not share to others.";
            LOGGER.log(Level.INFO, "Message content created: {0}", message);

            // Create the POST data
            String data = "------WebKitFormBoundary7MA4YWxkTrZu0gW\r\n" +
                          "Content-Disposition: form-data; name=\"_token\"\r\n\r\n" + sms.token + "\r\n" +
                          "------WebKitFormBoundary7MA4YWxkTrZu0gW\r\n" +
                          "Content-Disposition: form-data; name=\"phone\"\r\n\r\n" + sms.phoneNumber + "\r\n" +
                          "------WebKitFormBoundary7MA4YWxkTrZu0gW\r\n" +
                          "Content-Disposition: form-data; name=\"message\"\r\n\r\n" + message + "\r\n" +
                          "------WebKitFormBoundary7MA4YWxkTrZu0gW--";

            LOGGER.log(Level.INFO, "POST data prepared - Phone: {0}, Token length: {1}", 
                    new Object[]{sms.phoneNumber, sms.token.length()});

            // Write the data to the request
            try (OutputStream os = connection.getOutputStream()) {
                byte[] input = data.getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
                LOGGER.log(Level.INFO, "Data written to connection stream");
            }

            // Check the response code
            int responseCode = connection.getResponseCode();
            LOGGER.log(Level.INFO, "Response code from API: {0}", responseCode);
            
            // Read the response body
            StringBuilder response = new StringBuilder();
            try (BufferedReader br = new BufferedReader(
                    new InputStreamReader(
                            responseCode >= 400 
                                ? connection.getErrorStream() 
                                : connection.getInputStream()))) {
                String line;
                while ((line = br.readLine()) != null) {
                    response.append(line);
                }
            }
            
            LOGGER.log(Level.INFO, "Response body: {0}", response.toString());
            
            if (responseCode == 200) {
                LOGGER.log(Level.INFO, "OTP sent successfully to: {0}", sms.phoneNumber);
                OTPStatus = true;
            } else {
                LOGGER.log(Level.WARNING, "Failed to send OTP. Response code: {0}, Response: {1}", 
                        new Object[]{responseCode, response.toString()});
                OTPStatus = false;
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Exception when sending OTP: {0}", e.getMessage());
            e.printStackTrace();
            OTPStatus = false;
        }

        return OTPStatus;
    }

    private static String generateOTP() {
        Random random = new Random();
        int otp = 100000 + random.nextInt(900000); // Generate a 6-digit OTP
        return String.valueOf(otp);
    }
}