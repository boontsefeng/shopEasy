package com.shopeasy.shopeasy.controller;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.List;

import com.shopeasy.shopeasy.dao.ProductDAO;
import com.shopeasy.shopeasy.model.Product;
import com.shopeasy.shopeasy.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

/**
 * Controller for product management
 * Simplified to use a single JSP for all product operations
 */
@WebServlet(urlPatterns = {"/products", "/product/add", "/product/edit", "/product/delete", "/product/search", "/product/restock"})
@MultipartConfig
public class ProductController extends HttpServlet {
    private ProductDAO productDAO;
    
    // Updated path to store in assets directory
    private static final String UPLOAD_DIR = "assets";
    private static final String PRODUCTS_JSP = "/view/staff/products.jsp";
    
    @Override
    public void init() throws ServletException {
        super.init();
        productDAO = new ProductDAO();
        
        // Initialize the images directory in the webapp
        initializeImageDirectories();
    }
    
    /**
     * Initialize the images directory in the webapp
     */
    private void initializeImageDirectories() {
        try {
            // Define path to webapp assets directory
            String webappRoot = getServletContext().getRealPath("/");
            String webappAssetsPath = webappRoot + UPLOAD_DIR;
            
            // Create assets directory if it doesn't exist
            File webappAssetsDir = new File(webappAssetsPath);
            if (!webappAssetsDir.exists()) {
                webappAssetsDir.mkdirs();
                System.out.println("Created webapp assets directory: " + webappAssetsPath);
            } else {
                System.out.println("Webapp assets directory exists at: " + webappAssetsPath);
            }
            
        } catch (Exception e) {
            System.err.println("Error initializing images directory: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        
        // Check if user is logged in and has appropriate role
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        // Only manager and staff can access these endpoints
        if (!"manager".equals(user.getRole()) && !"staff".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        switch (path) {
            case "/products":
                // Get all products and display them
                List<Product> products = productDAO.getAllProducts();
                request.setAttribute("products", products);
                request.getRequestDispatcher(PRODUCTS_JSP).forward(request, response);
                break;
                
            case "/product/add":
                // Set action mode to 'add' for the JSP to show the add form
                request.setAttribute("actionMode", "add");
                request.getRequestDispatcher(PRODUCTS_JSP).forward(request, response);
                break;
                
            case "/product/edit":
                // Get product by ID and set action mode to 'edit'
                String productIdStr = request.getParameter("id");
                if (productIdStr != null && !productIdStr.isEmpty()) {
                    try {
                        int productId = Integer.parseInt(productIdStr);
                        Product product = productDAO.getProductById(productId);
                        if (product != null) {
                            request.setAttribute("product", product);
                            request.setAttribute("actionMode", "edit");
                            request.getRequestDispatcher(PRODUCTS_JSP).forward(request, response);
                            return;
                        }
                    } catch (NumberFormatException e) {
                        // Invalid product ID
                    }
                }
                
                // Handle restock via GET request if needed
                String restockParam = request.getParameter("restock");
                if (productIdStr != null && restockParam != null) {
                    try {
                        int productId = Integer.parseInt(productIdStr);
                        int newStock = Integer.parseInt(restockParam);
                        
                        Product product = productDAO.getProductById(productId);
                        if (product != null) {
                            product.setQuantity(newStock);
                            boolean success = productDAO.updateProduct(product);
                            if (success) {
                                response.sendRedirect(request.getContextPath() + "/products?success=restocked");
                                return;
                            }
                        }
                    } catch (NumberFormatException e) {
                        // Invalid parameters
                    }
                }
                
                // Redirect to products page if product not found or ID is invalid
                response.sendRedirect(request.getContextPath() + "/products");
                break;
                
            case "/product/delete":
                // Delete product
                deleteProductGet(request, response);
                break;
                
            case "/product/search":
                // Search products
                String keyword = request.getParameter("keyword");
                List<Product> searchResults = productDAO.searchProducts(keyword);
                request.setAttribute("products", searchResults);
                request.setAttribute("searchKeyword", keyword);
                request.getRequestDispatcher(PRODUCTS_JSP).forward(request, response);
                break;
                
            case "/product/restock":
                // Set action mode to 'restock' to show restock form
                productIdStr = request.getParameter("id");
                if (productIdStr != null && !productIdStr.isEmpty()) {
                    try {
                        int productId = Integer.parseInt(productIdStr);
                        Product product = productDAO.getProductById(productId);
                        if (product != null) {
                            request.setAttribute("product", product);
                            request.setAttribute("actionMode", "restock");
                            request.getRequestDispatcher(PRODUCTS_JSP).forward(request, response);
                            return;
                        }
                    } catch (NumberFormatException e) {
                        // Invalid product ID
                    }
                }
                response.sendRedirect(request.getContextPath() + "/products");
                break;
                
            default:
                response.sendRedirect(request.getContextPath() + "/products");
                break;
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        
        // Check if user is logged in and has appropriate role
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        // Only manager and staff can access these endpoints
        if (!"manager".equals(user.getRole()) && !"staff".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Log the request content type and path for debugging
        System.out.println("Request Content Type: " + request.getContentType());
        System.out.println("Processing POST request for path: " + path);
        
        switch (path) {
            case "/product/add":
                // Add new product
                addProduct(request, response);
                break;
                
            case "/product/edit":
                // Update existing product
                updateProduct(request, response);
                break;
                
            case "/product/restock":
                // Handle restock form submission
                restockProduct(request, response);
                break;
                
            case "/product/delete":
                // Handle delete form submission directly in post (as alternative to GET method)
                deleteProductPost(request, response);
                break;
                
            default:
                response.sendRedirect(request.getContextPath() + "/products");
                break;
        }
    }
    
    /**
     * Add a new product
     */
    private void addProduct(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        // Get form data
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        String category = request.getParameter("category");
        int price = 0;
        int quantity = 0;
        
        try {
            // Convert price from dollars to cents if needed
            String priceStr = request.getParameter("price");
            if (priceStr.contains(".")) {
                // If price is in dollars (e.g., 19.99), convert to cents
                double priceDouble = Double.parseDouble(priceStr);
                price = (int)(priceDouble * 100);
            } else {
                // If price is already in cents
                price = Integer.parseInt(priceStr);
            }
            
            quantity = Integer.parseInt(request.getParameter("quantity"));
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid price or quantity");
            request.setAttribute("actionMode", "add");
            
            // Send back the form data that was entered
            Product formData = new Product();
            formData.setName(name);
            formData.setDescription(description);
            formData.setCategory(category);
            try { formData.setPrice(Integer.parseInt(request.getParameter("price"))); } catch (Exception ex) {}
            try { formData.setQuantity(quantity); } catch (Exception ex) {}
            request.setAttribute("formData", formData);
            
            request.getRequestDispatcher(PRODUCTS_JSP).forward(request, response);
            return;
        }
        
        // Handle image upload
        Part filePart = request.getPart("image");
        String imagePath = "";
        
        if (filePart != null && filePart.getSize() > 0) {
            imagePath = processImageUpload(filePart, request);
            if (imagePath == null) {
                request.setAttribute("error", "Failed to upload image");
                request.setAttribute("actionMode", "add");
                request.getRequestDispatcher(PRODUCTS_JSP).forward(request, response);
                return;
            }
        }
        
        // Create and save new product
        Product newProduct = new Product();
        newProduct.setName(name);
        newProduct.setDescription(description);
        newProduct.setCategory(category);
        newProduct.setPrice(price);
        newProduct.setQuantity(quantity);
        newProduct.setImagePath(imagePath);
        
        int productId = productDAO.createProduct(newProduct);
        
        if (productId > 0) {
            // Product added successfully
            response.sendRedirect(request.getContextPath() + "/products?success=added");
        } else {
            // Failed to add product
            request.setAttribute("error", "Failed to add product");
            request.setAttribute("actionMode", "add");
            request.getRequestDispatcher(PRODUCTS_JSP).forward(request, response);
        }
    }
    
    /**
     * Update an existing product
     */
    private void updateProduct(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        // Get form data
        int productId = 0;
        try {
            productId = Integer.parseInt(request.getParameter("productId"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/products?error=invalid");
            return;
        }
        
        // Get existing product
        Product product = productDAO.getProductById(productId);
        if (product == null) {
            response.sendRedirect(request.getContextPath() + "/products?error=notfound");
            return;
        }
        
        // Update product information
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        String category = request.getParameter("category");
        int price = 0;
        int quantity = 0;
        
        try {
            // Convert price from dollars to cents if needed
            String priceStr = request.getParameter("price");
            if (priceStr.contains(".")) {
                // If price is in dollars (e.g., 19.99), convert to cents
                double priceDouble = Double.parseDouble(priceStr);
                price = (int)(priceDouble * 100);
            } else {
                // If price is already in cents
                price = Integer.parseInt(priceStr);
            }
            
            quantity = Integer.parseInt(request.getParameter("quantity"));
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid price or quantity");
            request.setAttribute("product", product);
            request.setAttribute("actionMode", "edit");
            request.getRequestDispatcher(PRODUCTS_JSP).forward(request, response);
            return;
        }
        
        // Handle image upload if provided
        Part filePart = request.getPart("image");
        String imagePath = product.getImagePath(); // Keep existing image by default
        
        if (filePart != null && filePart.getSize() > 0) {
            String newImagePath = processImageUpload(filePart, request);
            if (newImagePath != null) {
                imagePath = newImagePath;
            }
        }
        
        // Update product object
        product.setName(name);
        product.setDescription(description);
        product.setCategory(category);
        product.setPrice(price);
        product.setQuantity(quantity);
        product.setImagePath(imagePath);
        
        // Save updated product
        boolean success = productDAO.updateProduct(product);
        
        if (success) {
            // Product updated successfully
            response.sendRedirect(request.getContextPath() + "/products?success=updated");
        } else {
            // Failed to update product
            request.setAttribute("error", "Failed to update product");
            request.setAttribute("product", product);
            request.setAttribute("actionMode", "edit");
            request.getRequestDispatcher(PRODUCTS_JSP).forward(request, response);
        }
    }
    
    /**
     * Restock a product
     */
    private void restockProduct(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        int productId;
        int newStock = 0;
        
        try {
            productId = Integer.parseInt(request.getParameter("productId"));
            
            // Check if we have addStock or newStock parameter
            String addStockStr = request.getParameter("addStock");
            String newStockStr = request.getParameter("newStock");
            
            if (addStockStr != null && !addStockStr.isEmpty()) {
                // We have addStock - need to get current stock and add to it
                int addStock = Integer.parseInt(addStockStr);
                
                // Get existing product
                Product product = productDAO.getProductById(productId);
                if (product == null) {
                    response.sendRedirect(request.getContextPath() + "/products?error=notfound");
                    return;
                }
                
                // Calculate new stock level
                newStock = product.getQuantity() + addStock;
            } else if (newStockStr != null && !newStockStr.isEmpty()) {
                // We have newStock - use it directly
                newStock = Integer.parseInt(newStockStr);
            } else {
                // Neither parameter was provided
                response.sendRedirect(request.getContextPath() + "/products?error=invalid");
                return;
            }
            
            // Get existing product
            Product product = productDAO.getProductById(productId);
            if (product == null) {
                response.sendRedirect(request.getContextPath() + "/products?error=notfound");
                return;
            }
            
            // Log current and new stock 
            System.out.println("Restocking Product ID: " + productId + " - Current stock: " + product.getQuantity() + " - New stock: " + newStock);
            
            // Update product stock
            product.setQuantity(newStock);
            
            // Update product in database
            boolean success = productDAO.updateProduct(product);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/products?success=restocked");
            } else {
                response.sendRedirect(request.getContextPath() + "/products?error=restockfailed");
            }
        } catch (NumberFormatException e) {
            System.err.println("Error parsing restock parameters: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/products?error=invalid");
        }
    }
    
    /**
     * Delete a product through POST request
     */
    private void deleteProductPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String productIdStr = request.getParameter("productId");
        if (productIdStr != null && !productIdStr.isEmpty()) {
            try {
                int productId = Integer.parseInt(productIdStr);
                boolean success = productDAO.deleteProduct(productId);
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/products?success=deleted");
                    return;
                }
            } catch (NumberFormatException e) {
                // Invalid product ID
                System.err.println("Invalid product ID format: " + e.getMessage());
            }
        }
        // Redirect with error if deletion failed or ID was invalid
        response.sendRedirect(request.getContextPath() + "/products?error=deletefailed");
    }
    
    /**
     * Delete a product through GET request (used by the delete link in the UI)
     */
    private void deleteProductGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String productIdStr = request.getParameter("id");
        if (productIdStr != null && !productIdStr.isEmpty()) {
            try {
                int productId = Integer.parseInt(productIdStr);
                boolean success = productDAO.deleteProduct(productId);
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/products?success=deleted");
                    return;
                }
            } catch (NumberFormatException e) {
                // Invalid product ID
            }
        }
        // Redirect with error if deletion failed or ID was invalid
        response.sendRedirect(request.getContextPath() + "/products?error=deletefailed");
    }
    
    /**
     * Process image upload and return the path
     * UPDATED to save to assets directory without hardcoded paths
     */
    private String processImageUpload(Part filePart, HttpServletRequest request) {
        try {
            // Get the original filename without modification
            String fileName = getOriginalFileName(filePart);
            
            // Create logs for debugging purposes
            System.out.println("Processing image upload for file: " + fileName);
            
            // 1. First, save to the deployed directory which is guaranteed to exist and work
            String deployedPath = getServletContext().getRealPath("/") + UPLOAD_DIR;
            // Ensure directory exists
            File deployedDir = new File(deployedPath);
            if (!deployedDir.exists()) {
                deployedDir.mkdirs();
                System.out.println("Created deployed assets directory: " + deployedPath);
            }
            
            // Save to deployed directory
            InputStream inputStream = filePart.getInputStream();
            File deployedFile = new File(deployedDir, fileName);
            Files.copy(inputStream, deployedFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
            System.out.println("Image saved to deployed directory: " + deployedFile.getAbsolutePath());
            
            // 2. Try to save to the source directory using multiple strategies
            boolean savedToSource = false;
            
            try {
                // Try method 1: Get canonical path of webapp root and navigate back to source
                String webappRoot = getServletContext().getRealPath("/");
                String possibleProjectRoot = null;
                
                // Look for 'target' in the path to identify project root
                File currentDir = new File(webappRoot);
                while (currentDir != null && possibleProjectRoot == null) {
                    if (currentDir.getName().equals("target")) {
                        possibleProjectRoot = currentDir.getParent();
                    }
                    currentDir = currentDir.getParentFile();
                }
                
                if (possibleProjectRoot != null) {
                    File srcAssetsDir = new File(possibleProjectRoot, 
                                               "src" + File.separator + "main" + File.separator + 
                                               "webapp" + File.separator + UPLOAD_DIR);
                    
                    if (!srcAssetsDir.exists()) {
                        srcAssetsDir.mkdirs();
                    }
                    
                    // If directory exists or was created successfully
                    if (srcAssetsDir.exists()) {
                        File destFile = new File(srcAssetsDir, fileName);
                        Files.copy(deployedFile.toPath(), destFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                        System.out.println("Image saved to source directory (method 1): " + destFile.getAbsolutePath());
                        savedToSource = true;
                    }
                }
            } catch (Exception e) {
                System.out.println("Method 1 failed to save to source: " + e.getMessage());
            }
            
            // Try method 2 if method 1 failed: Use relative path from current directory
            if (!savedToSource) {
                try {
                    String currentDir = System.getProperty("user.dir");
                    File projectDir = new File(currentDir);
                    
                    // Try to navigate to project root by looking for pom.xml
                    while (projectDir != null && !new File(projectDir, "pom.xml").exists()) {
                        projectDir = projectDir.getParentFile();
                    }
                    
                    if (projectDir != null) {
                        File srcAssetsDir = new File(projectDir, 
                                                   "src" + File.separator + "main" + File.separator + 
                                                   "webapp" + File.separator + UPLOAD_DIR);
                        
                        if (!srcAssetsDir.exists()) {
                            srcAssetsDir.mkdirs();
                        }
                        
                        if (srcAssetsDir.exists()) {
                            File destFile = new File(srcAssetsDir, fileName);
                            Files.copy(deployedFile.toPath(), destFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                            System.out.println("Image saved to source directory (method 2): " + destFile.getAbsolutePath());
                            savedToSource = true;
                        }
                    }
                } catch (Exception e) {
                    System.out.println("Method 2 failed to save to source: " + e.getMessage());
                }
            }
            
            // Return the path for database storage - whether or not we saved to source directory
            // The application will still work with just the deployed copy
            return UPLOAD_DIR + "/" + fileName;
            
        } catch (Exception e) {
            System.err.println("Error saving uploaded file: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Get the original filename from Part
     */
    private String getOriginalFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        
        for (String item : items) {
            if (item.trim().startsWith("filename")) {
                String filename = item.substring(item.indexOf("=") + 2, item.length() - 1);
                // Remove any path information (for IE which sends full path)
                filename = filename.substring(Math.max(filename.lastIndexOf('/'), 
                                             filename.lastIndexOf('\\')) + 1);
                return filename;
            }
        }
        // In case no filename is found, generate one with extension
        return "product_" + System.currentTimeMillis() + getFileExtension(part);
    }
    
    /**
     * Get file extension from Part
     */
    private String getFileExtension(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        
        for (String item : items) {
            if (item.trim().startsWith("filename")) {
                String fileName = item.substring(item.indexOf("=") + 2, item.length() - 1);
                int dotIndex = fileName.lastIndexOf(".");
                return (dotIndex > 0) ? fileName.substring(dotIndex) : "";
            }
        }
        return "";
    }
}