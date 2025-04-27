package com.shopeasy.shopeasy.controller;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Servlet for serving images from the assets directory.
 * This handles image loading for product images.
 */
@WebServlet("/image/*")
public class ImageServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    private static final String ASSETS_DIR = "assets";
    
    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get the image path from the URL
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        
        // Remove leading slash from path
        String imageName = pathInfo.substring(1);
        
        // First try the deployment directory (target)
        String deploymentPath = getServletContext().getRealPath("/") + ASSETS_DIR + File.separator + imageName;
        File imageFile = new File(deploymentPath);
        
        // If not found in deployment directory, try source project directory
        if (!imageFile.exists()) {
            String workspacePath = System.getProperty("user.dir");
            if (workspacePath.contains("target")) {
                workspacePath = new File(workspacePath).getParent();
            }
            
            String srcPath = workspacePath + File.separator + "src" + File.separator + 
                            "main" + File.separator + "webapp" + File.separator + 
                            ASSETS_DIR + File.separator + imageName;
            
            imageFile = new File(srcPath);
            
            // If still not found, try a hardcoded path
            if (!imageFile.exists()) {
                String hardcodedPath = "C:" + File.separator + "Users" + File.separator + 
                                    "samur" + File.separator + "Desktop" + File.separator + 
                                    "ShopEasy" + File.separator + "src" + File.separator + 
                                    "main" + File.separator + "webapp" + File.separator + 
                                    ASSETS_DIR + File.separator + imageName;
                
                imageFile = new File(hardcodedPath);
            }
        }
        
        // Check if the file exists
        if (!imageFile.exists()) {
            // If not found, try to serve a placeholder image
            String placeholder = getServletContext().getRealPath("/") + ASSETS_DIR + File.separator + "productplaceholder.png";
            File placeholderFile = new File(placeholder);
            
            if (placeholderFile.exists()) {
                imageFile = placeholderFile;
                response.setContentType("image/png");
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
        } else {
            // Set content type based on file extension
            String contentType = getServletContext().getMimeType(imageFile.getName());
            if (contentType == null) {
                contentType = "application/octet-stream";
            }
            response.setContentType(contentType);
        }
        
        // Set content length
        response.setContentLength((int) imageFile.length());
        
        // Serve the file
        try (InputStream in = new FileInputStream(imageFile);
             OutputStream out = response.getOutputStream()) {
            
            byte[] buffer = new byte[4096];
            int bytesRead;
            
            while ((bytesRead = in.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
        } catch (IOException e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
} 