package com.shopeasy.shopeasy.controller;

import com.shopeasy.shopeasy.dao.ProductDAO;
import com.shopeasy.shopeasy.model.Product;
import com.shopeasy.shopeasy.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.UUID;

/**
 * Controller for product management
 * Simplified to use a single JSP for all product operations
 */
@WebServlet(urlPatterns = {"/products", "/product/add", "/product/edit", "/product/delete", "/product/search", "/product/restock"})
@MultipartConfig
public class ProductController extends HttpServlet {
    private ProductDAO productDAO;
    
    // Updated path to store in assets directory
    private static final String UPLOAD_DIR = "view/assets/product-images";
    private static final String PRODUCTS_JSP = "/view/staff/products.jsp";
    
    @Override
    public void init() throws ServletException {
        super.init();
        productDAO = new ProductDAO();
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
                deleteProduct(request, response);
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
        int addStock;
        
        try {
            productId = Integer.parseInt(request.getParameter("productId"));
            addStock = Integer.parseInt(request.getParameter("addStock"));
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
        
        // Calculate new stock level
        int newStock = product.getQuantity() + addStock;
        product.setQuantity(newStock);
        
        // Update product
        boolean success = productDAO.updateProduct(product);
        
        if (success) {
            response.sendRedirect(request.getContextPath() + "/products?success=restocked");
        } else {
            response.sendRedirect(request.getContextPath() + "/products?error=restockfailed");
        }
    }
    
    /**
     * Delete a product
     */
    private void deleteProduct(HttpServletRequest request, HttpServletResponse response) throws IOException {
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
     * UPDATED to fix image path issues
     */
    private String processImageUpload(Part filePart, HttpServletRequest request) {
        try {
            // Get the real application path on the server
            String applicationPath = request.getServletContext().getRealPath("");
            
            // Create the full path to the upload directory
            String uploadPath = applicationPath + File.separator + UPLOAD_DIR;
            
            // Ensure directory exists
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                boolean dirCreated = uploadDir.mkdirs();
                if (!dirCreated) {
                    System.err.println("Failed to create directory: " + uploadPath);
                    // Try to create parent directories
                    File assetsDir = new File(applicationPath + File.separator + "view" + File.separator + "assets");
                    if (!assetsDir.exists()) {
                        assetsDir.mkdirs();
                    }
                    uploadDir.mkdirs();
                }
            }
            
            // Generate a unique filename
            String fileName = UUID.randomUUID().toString() + getFileExtension(filePart);
            
            // Save the file
            InputStream inputStream = filePart.getInputStream();
            Path filePath = Paths.get(uploadPath + File.separator + fileName);
            Files.copy(inputStream, filePath, StandardCopyOption.REPLACE_EXISTING);
            
            // Log debug information
            System.out.println("Image saved to: " + filePath.toString());
            
            // Return the relative path for database storage
            return "assets/product-images/" + fileName;
        } catch (IOException e) {
            System.err.println("Error uploading image: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
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