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
 */
@WebServlet(urlPatterns = {"/products", "/product/add", "/product/edit", "/product/delete", "/product/search"})
@MultipartConfig
public class ProductController extends HttpServlet {
    private ProductDAO productDAO;
    private static final String UPLOAD_DIR = "product-images";
    
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
                request.getRequestDispatcher("/view/admin/products.jsp").forward(request, response);
                break;
                
            case "/product/add":
                // Forward to add product page
                request.getRequestDispatcher("/view/admin/add-product.jsp").forward(request, response);
                break;
                
            case "/product/edit":
                // Get product by ID and forward to edit page
                String productIdStr = request.getParameter("id");
                if (productIdStr != null && !productIdStr.isEmpty()) {
                    try {
                        int productId = Integer.parseInt(productIdStr);
                        Product product = productDAO.getProductById(productId);
                        if (product != null) {
                            request.setAttribute("product", product);
                            request.getRequestDispatcher("/view/admin/edit-product.jsp").forward(request, response);
                            return;
                        }
                    } catch (NumberFormatException e) {
                        // Invalid product ID
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
                request.getRequestDispatcher("/view/admin/products.jsp").forward(request, response);
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
            price = Integer.parseInt(request.getParameter("price"));
            quantity = Integer.parseInt(request.getParameter("quantity"));
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid price or quantity");
            request.getRequestDispatcher("/view/admin/add-product.jsp").forward(request, response);
            return;
        }
        
        // Handle image upload
        Part filePart = request.getPart("image");
        String imagePath = "";
        
        if (filePart != null && filePart.getSize() > 0) {
            imagePath = processImageUpload(filePart, request);
            if (imagePath == null) {
                request.setAttribute("error", "Failed to upload image");
                request.getRequestDispatcher("/view/admin/add-product.jsp").forward(request, response);
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
            request.getRequestDispatcher("/view/admin/add-product.jsp").forward(request, response);
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
            price = Integer.parseInt(request.getParameter("price"));
            quantity = Integer.parseInt(request.getParameter("quantity"));
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid price or quantity");
            request.setAttribute("product", product);
            request.getRequestDispatcher("/view/admin/edit-product.jsp").forward(request, response);
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
            request.getRequestDispatcher("/view/admin/edit-product.jsp").forward(request, response);
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
     */
    private String processImageUpload(Part filePart, HttpServletRequest request) {
        try {
            // Create the upload directory if it doesn't exist
            String applicationPath = request.getServletContext().getRealPath("");
            String uploadPath = applicationPath + File.separator + UPLOAD_DIR;
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            
            // Generate a unique filename
            String fileName = UUID.randomUUID().toString() + getFileExtension(filePart);
            
            // Save the file
            InputStream inputStream = filePart.getInputStream();
            Path filePath = Paths.get(uploadPath + File.separator + fileName);
            Files.copy(inputStream, filePath, StandardCopyOption.REPLACE_EXISTING);
            
            // Return the relative path
            return UPLOAD_DIR + "/" + fileName;
        } catch (IOException e) {
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