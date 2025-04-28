package com.shopeasy.shopeasy.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import com.shopeasy.shopeasy.dao.CartDAO;
import com.shopeasy.shopeasy.dao.OrderDAO;
import com.shopeasy.shopeasy.dao.ProductDAO;
import com.shopeasy.shopeasy.dao.UserDAO;
import com.shopeasy.shopeasy.model.Cart;
import com.shopeasy.shopeasy.model.Order;
import com.shopeasy.shopeasy.model.OrderItem;
import com.shopeasy.shopeasy.model.Product;
import com.shopeasy.shopeasy.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Controller for customer side features
 */
@WebServlet(urlPatterns = {
    "/customer/dashboard", 
    "/customer/products", 
    "/customer/product/details", 
    "/customer/product/category",
    "/customer/cart",
    "/customer/cart/add",
    "/customer/cart/update",
    "/customer/cart/remove",
    "/customer/checkout",
    "/customer/payment",
    "/customer/payment/process",
    "/customer/order/place",
    "/customer/orders",
    "/customer/order/details",
    "/customer/profile",
    "/customer/raya-discounts"
})
public class CustomerController extends HttpServlet {
    private ProductDAO productDAO;
    private CartDAO cartDAO;
    private OrderDAO orderDAO;
    private UserDAO userDAO;

    // Add this set as a class variable to track discounted product IDs
    private final Set<Integer> discountedProductIds = Set.of(3, 4, 6, 8); // T-shirt, Mug, Lamp, Yoga Mat

    @Override
    public void init() throws ServletException {
        super.init();
        productDAO = new ProductDAO();
        cartDAO = new CartDAO();
        orderDAO = new OrderDAO();
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String path = request.getServletPath();
        
        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        // Only customers can access these endpoints
        if ("manager".equals(user.getRole()) || "staff".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        
        // Set cart count for all pages
        int cartCount = cartDAO.getCartItemCount(user.getUserId());
        request.setAttribute("cartCount", cartCount);
        
        switch (path) {
            case "/customer/dashboard":
                handleDashboard(request, response);
                break;
                
            case "/customer/products":
                handleProductsPage(request, response);
                break;
                
            case "/customer/product/details":
                handleProductDetails(request, response);
                break;
                
            case "/customer/product/category":
                handleProductCategory(request, response);
                break;
                
            case "/customer/cart":
                handleCartPage(request, response);
                break;
                
            case "/customer/checkout":
                handleCheckoutPage(request, response);
                break;
                
            case "/customer/payment":
                handlePaymentPage(request, response);
                break;
                
            case "/customer/orders":
                handleOrdersPage(request, response);
                break;
                
            case "/customer/order/details":
                handleOrderDetails(request, response);
                break;
                
            case "/customer/profile":
                handleProfilePage(request, response);
                break;
                
            case "/customer/raya-discounts":
                doGetRayaDiscounts(request, response);
                break;
                
            default:
                response.sendRedirect(request.getContextPath() + "/customer/dashboard");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String path = request.getServletPath();
        
        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        // Only customers can access these endpoints
        if ("manager".equals(user.getRole()) || "staff".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        
        switch (path) {
            case "/customer/cart/add":
                handleAddToCart(request, response);
                break;
                
            case "/customer/cart/update":
                handleUpdateCart(request, response);
                break;
                
            case "/customer/cart/remove":
                handleRemoveFromCart(request, response);
                break;
                
            case "/customer/order/place":
                handlePlaceOrder(request, response);
                break;
                
            case "/customer/payment/process":
                handlePaymentProcess(request, response);
                break;
                
            case "/customer/profile":
                handleProfileUpdate(request, response);
                break;
                
            default:
                response.sendRedirect(request.getContextPath() + "/customer/dashboard");
                break;
        }
    }
    
    /**
     * Handle customer dashboard
     */
    private void handleDashboard(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Get featured products for dashboard
        List<Product> allProducts = productDAO.getAllProducts();
        List<Product> featuredProducts = new ArrayList<>();
        
        // Get first 8 products for featured section
        int count = 0;
        for (Product product : allProducts) {
            if (product.getQuantity() > 0) { // Only show in-stock products
                featuredProducts.add(product);
                count++;
                if (count >= 8) {
                    break;
                }
            }
        }
        
        // Apply discounts to featured products
        applyDiscounts(featuredProducts);
        
        // Get all product categories
        Set<String> categories = new HashSet<>();
        for (Product product : allProducts) {
            categories.add(product.getCategory());
        }
        
        request.setAttribute("featuredProducts", featuredProducts);
        request.setAttribute("categories", categories);
        request.getRequestDispatcher("/view/customer/dashboard.jsp").forward(request, response);
    }
    
    /**
     * Handle all products page
     */
    private void handleProductsPage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        List<Product> products;
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            // Search for products
            products = productDAO.searchProducts(keyword);
            request.setAttribute("keyword", keyword);
        } else {
            // Get all products
            products = productDAO.getAllProducts();
        }
        
        // Filter out out-of-stock products
        List<Product> availableProducts = new ArrayList<>();
        for (Product product : products) {
            if (product.getQuantity() > 0) {
                availableProducts.add(product);
            }
        }
        
        // Apply discounts to products
        applyDiscounts(availableProducts);
        
        // Get all product categories
        Set<String> categories = new HashSet<>();
        for (Product product : products) {
            categories.add(product.getCategory());
        }
        
        request.setAttribute("products", availableProducts);
        request.setAttribute("categories", categories);
        request.getRequestDispatcher("/view/customer/products.jsp").forward(request, response);
    }
    
    /**
     * Handle product details page
     */
    private void handleProductDetails(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String productIdStr = request.getParameter("id");
        
        if (productIdStr != null && !productIdStr.isEmpty()) {
            try {
                int productId = Integer.parseInt(productIdStr);
                Product product = productDAO.getProductById(productId);
                
                if (product != null) {
                    // Apply discount if applicable
                    if (discountedProductIds.contains(productId)) {
                        product.setOriginalPrice(product.getPrice());
                        product.setPrice(product.getPrice() / 2);
                        product.setDiscounted(true);
                    }
                    
                    // Check if product is in user's cart
                    HttpSession session = request.getSession(false);
                    User user = (User) session.getAttribute("user");
                    boolean inCart = cartDAO.isProductInCart(user.getUserId(), productId);
                    
                    // Get related products (same category)
                    List<Product> relatedProducts = productDAO.getProductsByCategory(product.getCategory());
                    List<Product> filteredRelatedProducts = new ArrayList<>();
                    
                    // Remove current product and out-of-stock products
                    for (Product relatedProduct : relatedProducts) {
                        if (relatedProduct.getProductId() != productId && relatedProduct.getQuantity() > 0) {
                            // Apply discounts to related products
                            if (discountedProductIds.contains(relatedProduct.getProductId())) {
                                relatedProduct.setOriginalPrice(relatedProduct.getPrice());
                                relatedProduct.setPrice(relatedProduct.getPrice() / 2);
                                relatedProduct.setDiscounted(true);
                            }
                            filteredRelatedProducts.add(relatedProduct);
                        }
                    }
                    
                    request.setAttribute("product", product);
                    request.setAttribute("inCart", inCart);
                    request.setAttribute("relatedProducts", filteredRelatedProducts);
                    request.getRequestDispatcher("/view/customer/product-details.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException e) {
                // Invalid product ID
            }
        }
        
        // Product not found or invalid ID
        response.sendRedirect(request.getContextPath() + "/customer/products");
    }
    
    /**
     * Handle products by category
     */
    private void handleProductCategory(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String category = request.getParameter("category");
        
        if (category != null && !category.isEmpty()) {
            List<Product> products = productDAO.getProductsByCategory(category);
            
            // Filter out out-of-stock products
            List<Product> availableProducts = new ArrayList<>();
            for (Product product : products) {
                if (product.getQuantity() > 0) {
                    availableProducts.add(product);
                }
            }
            
            // Apply discounts to products
            applyDiscounts(availableProducts);
            
            // Get all product categories
            List<Product> allProducts = productDAO.getAllProducts();
            Set<String> categories = new HashSet<>();
            for (Product product : allProducts) {
                categories.add(product.getCategory());
            }
            
            request.setAttribute("products", availableProducts);
            request.setAttribute("categories", categories);
            request.setAttribute("currentCategory", category);
            request.getRequestDispatcher("/view/customer/products.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/customer/products");
        }
    }
    
    /**
     * Handle cart page
     */
    private void handleCartPage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");
        
        List<Cart> cartItems = cartDAO.getUserCart(user.getUserId());
        int cartTotal = cartDAO.getCartTotal(user.getUserId());
        
        request.setAttribute("cartItems", cartItems);
        request.setAttribute("cartTotal", cartTotal);
        request.getRequestDispatcher("/view/customer/cart.jsp").forward(request, response);
    }
    
    /**
     * Handle checkout page
     */
    private void handleCheckoutPage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");
        
        List<Cart> cartItems = cartDAO.getUserCart(user.getUserId());
        
        // Check if cart is empty
        if (cartItems.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/cart?error=empty");
            return;
        }
        
        int cartTotal = cartDAO.getCartTotal(user.getUserId());
        
        request.setAttribute("cartItems", cartItems);
        request.setAttribute("cartTotal", cartTotal);
        request.setAttribute("user", user);
        request.getRequestDispatcher("/view/customer/checkout.jsp").forward(request, response);
    }
    
    /**
     * Handle orders page
     */
    private void handleOrdersPage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");
        
        List<Order> orders = orderDAO.getOrdersByUserId(user.getUserId());
        
        request.setAttribute("orders", orders);
        request.getRequestDispatcher("/view/customer/orders.jsp").forward(request, response);
    }
    
    /**
     * Handle order details page
     */
    private void handleOrderDetails(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String orderIdStr = request.getParameter("id");
        
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                Order order = orderDAO.getOrderById(orderId);
                
                if (order != null) {
                    // Make sure user owns this order
                    HttpSession session = request.getSession(false);
                    User user = (User) session.getAttribute("user");
                    
                    if (order.getUserId() == user.getUserId()) {
                        List<OrderItem> orderItems = orderDAO.getOrderItemsByOrderId(orderId);
                        
                        request.setAttribute("order", order);
                        request.setAttribute("orderItems", orderItems);
                        request.getRequestDispatcher("/view/customer/order-details.jsp").forward(request, response);
                        return;
                    }
                }
            } catch (NumberFormatException e) {
                // Invalid order ID
            }
        }
        
        // Order not found or invalid ID
        response.sendRedirect(request.getContextPath() + "/customer/orders");
    }
    
    /**
     * Handle profile page
     */
    private void handleProfilePage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");
        
        request.setAttribute("userProfile", user);
        request.getRequestDispatcher("/view/customer/profile.jsp").forward(request, response);
    }
    
    /**
     * Handle add to cart
     */
    private void handleAddToCart(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String productIdStr = request.getParameter("productId");
        String quantityStr = request.getParameter("quantity");
        
        if (productIdStr != null && !productIdStr.isEmpty() && quantityStr != null && !quantityStr.isEmpty()) {
            try {
                int productId = Integer.parseInt(productIdStr);
                int quantity = Integer.parseInt(quantityStr);
                
                // Validate quantity
                if (quantity <= 0) {
                    quantity = 1;
                }
                
                // Check if product exists and has sufficient stock
                Product product = productDAO.getProductById(productId);
                if (product != null && product.getQuantity() >= quantity) {
                    HttpSession session = request.getSession(false);
                    User user = (User) session.getAttribute("user");
                    
                    // Since we're showing discounted prices in the UI but need to store original in cart
                    // If this is a discounted product, we need to restore the original price before adding to cart
                    if (discountedProductIds.contains(productId)) {
                       product.setPrice(product.getPrice()* 0.5);
                       productDAO.updateProductPrice(productId,product.getPrice());
                    }
                    
                    Cart cart = new Cart(user.getUserId(), productId, quantity);
                    boolean success = cartDAO.addToCart(cart);
                    
                    if (success) {
                        // Redirect to cart page or product details based on request parameter
                        String redirect = request.getParameter("redirect");
                        if ("cart".equals(redirect)) {
                            response.sendRedirect(request.getContextPath() + "/customer/cart?success=added");
                        } else if ("raya-discounts".equals(redirect)) {
                            response.sendRedirect(request.getContextPath() + "/customer/raya-discounts?success=added");
                        } else {
                            response.sendRedirect(request.getContextPath() + 
                                                 "/customer/product/details?id=" + productId + "&success=added");
                        }
                        return;
                    } else {
                        response.sendRedirect(request.getContextPath() + 
                                             "/customer/product/details?id=" + productId + "&error=add_failed");
                        return;
                    }
                } else {
                    response.sendRedirect(request.getContextPath() + 
                                         "/customer/product/details?id=" + productId + "&error=insufficient_stock");
                    return;
                }
            } catch (NumberFormatException e) {
                // Invalid parameters
            }
        }
        
        // Invalid parameters
        response.sendRedirect(request.getContextPath() + "/customer/products");
    }
    
    /**
     * Handle update cart
     */
    private void handleUpdateCart(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String cartIdStr = request.getParameter("cartId");
        String quantityStr = request.getParameter("quantity");
        
        if (cartIdStr != null && !cartIdStr.isEmpty() && quantityStr != null && !quantityStr.isEmpty()) {
            try {
                int cartId = Integer.parseInt(cartIdStr);
                int quantity = Integer.parseInt(quantityStr);
                
                // Validate quantity
                if (quantity <= 0) {
                    // If quantity is 0 or negative, remove the item
                    cartDAO.removeFromCart(cartId);
                } else {
                    // Update the quantity
                    cartDAO.updateCartItemQuantity(cartId, quantity);
                }
                
                response.sendRedirect(request.getContextPath() + "/customer/cart?success=updated");
                return;
            } catch (NumberFormatException e) {
                // Invalid parameters
            }
        }
        
        // Invalid parameters
        response.sendRedirect(request.getContextPath() + "/customer/cart?error=update_failed");
    }
    
    /**
     * Handle remove from cart
     */
    private void handleRemoveFromCart(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String cartIdStr = request.getParameter("cartId");
        
        if (cartIdStr != null && !cartIdStr.isEmpty()) {
            try {
                int cartId = Integer.parseInt(cartIdStr);
                boolean success = cartDAO.removeFromCart(cartId);
                
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/customer/cart?success=removed");
                } else {
                    response.sendRedirect(request.getContextPath() + "/customer/cart?error=remove_failed");
                }
                return;
            } catch (NumberFormatException e) {
                // Invalid cart ID
            }
        }
        
        // Invalid parameters
        response.sendRedirect(request.getContextPath() + "/customer/cart?error=remove_failed");
    }
    
    /**
     * Handle place order
     */
    private void handlePlaceOrder(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");
        
        // Get cart items
        List<Cart> cartItems = cartDAO.getUserCart(user.getUserId());
        
        // Check if cart is empty
        if (cartItems.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/cart?error=empty");
            return;
        }
        
        // Get form data
        String shippingAddress = request.getParameter("shippingAddress");
        String paymentMethod = request.getParameter("paymentMethod");
        
        if (shippingAddress == null || shippingAddress.trim().isEmpty() || 
            paymentMethod == null || paymentMethod.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/checkout?error=missing_fields");
            return;
        }
        
        // Create order
        Order order = new Order(
            user.getUserId(),
            new Date(),
            cartDAO.getCartTotal(user.getUserId()),
            shippingAddress,
            "Pending", // Initial status
            paymentMethod
        );
        
        int orderId = orderDAO.createOrder(order);
        
        if (orderId > 0) {
            // Create order items
            boolean allItemsAdded = true;
            
            for (Cart item : cartItems) {
                // Get product to verify stock and get current price
                Product product = productDAO.getProductById(item.getProductId());
                
                if (product != null && product.getQuantity() >= item.getQuantity()) {
                    // Create order item
                    OrderItem orderItem = new OrderItem(
                        orderId,
                        item.getProductId(),
                        item.getQuantity(),
                        product.getPrice()
                    );
                    
                    boolean itemAdded = orderDAO.addOrderItem(orderItem);
                    
                    if (itemAdded) {
                        // Update product stock
                        int newQuantity = product.getQuantity() - item.getQuantity();
                        productDAO.updateProductStock(item.getProductId(), newQuantity);
                    } else {
                        allItemsAdded = false;
                    }
                } else {
                    allItemsAdded = false;
                }
            }
            
            if (allItemsAdded) {
                // Clear cart
                cartDAO.clearCart(user.getUserId());
                
                // Redirect to order details
                response.sendRedirect(request.getContextPath() + "/customer/order/details?id=" + orderId + "&success=placed");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/checkout?error=items_failed");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/customer/checkout?error=order_failed");
        }
    }
    
    /**
     * Handle profile update
     */
    private void handleProfileUpdate(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");
        
        // Get form data
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String contactNumber = request.getParameter("contactNumber");
        String password = request.getParameter("password");
        
        // Update user information
        boolean updatePassword = password != null && !password.trim().isEmpty();
        if (updatePassword) {
            user.setPassword(password);
        }
        
        user.setName(name);
        user.setEmail(email);
        user.setContactNumber(contactNumber);
        
        // Save updated user with appropriate method based on password update
        boolean success = updatePassword ? 
                userDAO.updateUser(user, true) : 
                userDAO.updateUser(user);
        
        if (success) {
            // Update session attributes
            session.setAttribute("user", user);
            session.setAttribute("userName", user.getName());
            
            response.sendRedirect(request.getContextPath() + "/customer/profile?success=updated");
        } else {
            request.setAttribute("error", "Failed to update profile");
            request.setAttribute("userProfile", user);
            request.getRequestDispatcher("/view/customer/profile.jsp").forward(request, response);
        }
    }

    /**
     * Display the Raya Special Discounts page
     */
    private void doGetRayaDiscounts(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Get the discounted products
        List<Product> discountedProducts = new ArrayList<>();
        for (Integer productId : discountedProductIds) {
            Product product = productDAO.getProductById(productId);
            if (product != null && product.getQuantity() > 0) {
                // Apply the discount for display
                product.setOriginalPrice(product.getPrice());
                product.setPrice(product.getPrice() / 2);
                product.setDiscounted(true);
                discountedProducts.add(product);
            }
        }
        
        // Set cart count for the navigation
        User user = (User) session.getAttribute("user");
        int cartCount = cartDAO.getCartItemCount(user.getUserId());
        request.setAttribute("cartCount", cartCount);
        
        // Pass the products to the JSP
        request.setAttribute("discountedProducts", discountedProducts);
        
        // Forward to the Raya discounts page
        request.getRequestDispatcher("/view/customer/raya-discounts.jsp").forward(request, response);
    }

    /**
     * Handle payment page
     */
    private void handlePaymentPage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");
        
        // Debug log
        System.out.println("Payment page accessed by user: " + user.getName());
        
        // Get cart items and total
        List<Cart> cartItems = cartDAO.getUserCart(user.getUserId());
        
        // Check if cart is empty
        if (cartItems.isEmpty()) {
            System.out.println("Cart is empty, redirecting to cart page");
            response.sendRedirect(request.getContextPath() + "/customer/cart?error=empty");
            return;
        }
        
        int cartTotal = cartDAO.getCartTotal(user.getUserId());
        
        request.setAttribute("cartItems", cartItems);
        request.setAttribute("cartTotal", cartTotal);
        request.setAttribute("user", user);
        
        // Get shipping address from request parameter first
        String shippingAddress = request.getParameter("shippingAddress");
        
        // If not in request, check session attribute
        if (shippingAddress == null || shippingAddress.isEmpty()) {
            shippingAddress = (String) session.getAttribute("shippingAddress");
            System.out.println("Got shipping address from session: " + shippingAddress);
        }
        
        if (shippingAddress != null && !shippingAddress.isEmpty()) {
            // Store in session for later use
            session.setAttribute("shippingAddress", shippingAddress);
            request.setAttribute("shippingAddress", shippingAddress);
            System.out.println("Setting shipping address in request: " + shippingAddress);
        } else {
            System.out.println("No shipping address found in session or request");
        }
        
        System.out.println("Forwarding to payment.jsp");
        request.getRequestDispatcher("/view/customer/payment.jsp").forward(request, response);
    }

    /**
     * Handle payment processing
     */
    private void handlePaymentProcess(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");
        
        System.out.println("Payment processing started for user: " + user.getName());
        
        // Get cart items
        List<Cart> cartItems = cartDAO.getUserCart(user.getUserId());
        
        // Check if cart is empty
        if (cartItems.isEmpty()) {
            System.out.println("Cart is empty, redirecting to cart page");
            response.sendRedirect(request.getContextPath() + "/customer/cart?error=empty");
            return;
        }
        
        // Get shipping address from request or session
        String shippingAddress = request.getParameter("shippingAddress");
        System.out.println("Shipping address from request: " + shippingAddress);
        
        if (shippingAddress == null || shippingAddress.trim().isEmpty()) {
            shippingAddress = (String) session.getAttribute("shippingAddress");
            System.out.println("Shipping address from session: " + shippingAddress);
            
            if (shippingAddress == null || shippingAddress.trim().isEmpty()) {
                System.out.println("No shipping address found, redirecting to checkout");
                response.sendRedirect(request.getContextPath() + "/customer/checkout?error=missing_fields");
                return;
            }
        } else {
            // Store in session for future use
            session.setAttribute("shippingAddress", shippingAddress);
        }
        
        // Log card information (in a real app, this would be sent to a payment processor)
        String cardNumber = request.getParameter("cardNumber");
        String cardHolderName = request.getParameter("nameOnCard");
        
        if (cardNumber != null) {
            // Mask the card number for logging
            String maskedCardNumber = cardNumber.replaceAll("\\d(?=\\d{4})", "*");
            System.out.println("Processing payment with card: " + maskedCardNumber);
            System.out.println("Card holder: " + cardHolderName);
        }
        
        System.out.println("Card payment successful! Creating order.");
        
        // For simplicity, we'll assume the payment was successful
        // In a real application, you would integrate with a payment gateway here
        
        // Create order
        Order order = new Order(
            user.getUserId(),
            new Date(),
            cartDAO.getCartTotal(user.getUserId()),
            shippingAddress,
            "Paid", // Status is "Paid" for card payments
            "Credit/Debit Card" // Payment method
        );
        
        int orderId = orderDAO.createOrder(order);
        System.out.println("Created order with ID: " + orderId);
        
        if (orderId > 0) {
            // Create order items
            boolean allItemsAdded = true;
            
            for (Cart item : cartItems) {
                // Get product to verify stock and get current price
                Product product = productDAO.getProductById(item.getProductId());
                
                if (product != null && product.getQuantity() >= item.getQuantity()) {
                    // Create order item
                    OrderItem orderItem = new OrderItem(
                        orderId,
                        item.getProductId(),
                        item.getQuantity(),
                        product.getPrice()
                    );
                    
                    boolean itemAdded = orderDAO.addOrderItem(orderItem);
                    
                    if (itemAdded) {
                        // Update product stock
                        int newQuantity = product.getQuantity() - item.getQuantity();
                        productDAO.updateProductStock(item.getProductId(), newQuantity);
                        System.out.println("Added item: " + product.getName() + " x" + item.getQuantity());
                    } else {
                        allItemsAdded = false;
                        System.out.println("Failed to add item: " + product.getName());
                    }
                } else {
                    allItemsAdded = false;
                    System.out.println("Insufficient stock for: " + (product != null ? product.getName() : "Unknown product"));
                }
            }
            
            if (allItemsAdded) {
                // Clear cart
                cartDAO.clearCart(user.getUserId());
                System.out.println("Cart cleared, redirecting to order details");
                
                // Redirect to order details
                response.sendRedirect(request.getContextPath() + "/customer/order/details?id=" + orderId + "&success=paid");
            } else {
                System.out.println("Some items failed to be added to the order");
                response.sendRedirect(request.getContextPath() + "/customer/checkout?error=items_failed");
            }
        } else {
            System.out.println("Failed to create order");
            response.sendRedirect(request.getContextPath() + "/customer/checkout?error=order_failed");
        }
    }

    // Add this helper method
    /**
     * Apply discounts to products in the list
     * @param products List of products to check for discounts
     */
    private void applyDiscounts(List<Product> products) {
        for (Product product : products) {
            if (discountedProductIds.contains(product.getProductId())) {
                // Apply 50% discount to the price displayed (but keep original price in database)
                product.setOriginalPrice(product.getPrice());
                product.setPrice(product.getPrice() / 2);
                product.setDiscounted(true);
            }
        }
    }
}