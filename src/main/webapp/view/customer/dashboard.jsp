<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ include file="/view/customer/font.jsp" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShopEasy - Dashboard</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Add animate.css for animations -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css">
    <style>
        .hero-section {
            background-image: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        
        .category-item:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }
        
        .product-card {
            transition: all 0.3s ease;
        }
        
        .product-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }
        
        .product-image {
            height: 180px; /* Increased from h-48 (192px) but with better proportion */
            object-fit: contain; /* Changed from cover to contain to show full product */
            padding: 10px; /* Add padding to prevent image from touching edges */
        }
        
        .product-title {
            font-size: 0.95rem; /* Smaller than text-lg */
            line-height: 1.3;
            margin-bottom: 0.4rem;
            font-weight: 500;
        }
        
        .product-description {
            font-size: 0.8rem;
            line-height: 1.3;
            margin-bottom: 0.5rem;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        
        .product-price {
            font-size: 0.95rem;
        }
        
        .add-to-cart-btn {
            font-size: 0.75rem;
            padding: 0.3rem 0.75rem;
        }
        
        .discount-badge {
            position: absolute;
            top: 10px;
            right: 10px;
            background-color: #ef4444;
            color: white;
            font-weight: bold;
            padding: 4px 8px;
            border-radius: 9999px;
            font-size: 0.75rem;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            z-index: 10;
        }
        
        .original-price {
            text-decoration: line-through;
            color: #9ca3af;
            font-size: 0.8rem;
            margin-right: 0.5rem;
        }
        
        .sale-banner {
            background: linear-gradient(135deg, #f87171 0%, #ef4444 100%);
            border-radius: 0.5rem;
            overflow: hidden;
            position: relative;
        }
        
        .sale-banner::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url("data:image/svg+xml,%3Csvg width='52' height='26' viewBox='0 0 52 26' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.1'%3E%3Cpath d='M10 10c0-2.21-1.79-4-4-4-3.314 0-6-2.686-6-6h2c0 2.21 1.79 4 4 4 3.314 0 6 2.686 6 6 0 2.21 1.79 4 4 4 3.314 0 6 2.686 6 6 0 2.21 1.79 4 4 4v2c-3.314 0-6-2.686-6-6 0-2.21-1.79-4-4-4-3.314 0-6-2.686-6-6zm25.464-1.95l8.486 8.486-1.414 1.414-8.486-8.486 1.414-1.414z' /%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
            opacity: 0.3;
        }
        
        .sale-badge {
            position: absolute;
            top: -10px;
            right: 30px;
            background-color: #eab308;
            color: white;
            font-weight: bold;
            padding: 8px 16px;
            border-radius: 0 0 8px 8px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            transform: rotate(5deg);
        }
        
        @keyframes pulse-scale {
            0%, 100% {
                transform: scale(1);
            }
            50% {
                transform: scale(1.05);
            }
        }
        
        .pulse-animation {
            animation: pulse-scale 2s infinite;
        }
    </style>
</head>
<body class="bg-gray-100">
    <!-- Navigation -->
    <jsp:include page="../includes/customer-nav.jsp" />
    
    <!-- Main Content -->
    <main class="container mx-auto px-4 py-8">
        <!-- Hero Section -->
        <section class="hero-section rounded-lg p-8 mb-8 text-white">
            <div class="max-w-3xl mx-auto text-center">
                <h1 class="text-4xl font-bold mb-4 animate__animated animate__fadeInDown">Welcome to ShopEasy</h1>
                <p class="text-xl mb-6 animate__animated animate__fadeInUp">Discover amazing products at the best prices!</p>
                <a href="${pageContext.request.contextPath}/customer/products" 
                   class="inline-block bg-white text-indigo-600 px-6 py-3 rounded-full font-medium hover:bg-gray-100 transition duration-300 animate__animated animate__bounceIn animate__delay-1s">
                    Shop Now <i class="fas fa-arrow-right ml-2"></i>
                </a>
            </div>
        </section>
        
        <!-- Raya Sale Banner -->
        <section class="mb-8">
            <div class="sale-banner p-6 relative">
                <div class="sale-badge text-lg">50% OFF</div>
                <div class="flex flex-col md:flex-row items-center justify-between">
                    <div class="mb-4 md:mb-0 md:mr-8">
                        <h2 class="text-3xl font-bold text-white mb-2">Raya Special Deals!</h2>
                        <p class="text-white text-opacity-90 mb-4">Limited time offer on select products. Hurry and grab your favorites before they're gone!</p>
                        <a href="${pageContext.request.contextPath}/customer/raya-discounts" 
                           class="inline-block bg-white text-red-600 px-6 py-2 rounded-full font-medium hover:bg-red-50 transition pulse-animation">
                            Shop Raya Deals <i class="fas fa-tag ml-1"></i>
                        </a>
                    </div>
                    <div class="grid grid-cols-2 gap-2">
                        <img src="${pageContext.request.contextPath}/assets/Men's Cotton T-Shirt.png" alt="T-Shirt" class="w-16 h-16 object-cover rounded-lg border-2 border-white">
                        <img src="${pageContext.request.contextPath}/assets/Ceramic Coffee Mug.jpg" alt="Coffee Mug" class="w-16 h-16 object-cover rounded-lg border-2 border-white">
                        <img src="${pageContext.request.contextPath}/assets/LED Desk Lamp.png" alt="Desk Lamp" class="w-16 h-16 object-cover rounded-lg border-2 border-white">
                        <img src="${pageContext.request.contextPath}/assets/Yoga Mat.jpg" alt="Yoga Mat" class="w-16 h-16 object-cover rounded-lg border-2 border-white">
                    </div>
                </div>
            </div>
        </section>
        
        <!-- Categories Section -->
        <section class="mb-12">
            <h2 class="text-2xl font-bold mb-6 text-gray-800">Shop by Category</h2>
            <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
                <c:forEach items="${categories}" var="category">
                    <a href="${pageContext.request.contextPath}/customer/product/category?category=${category}" 
                       class="category-item bg-white rounded-lg shadow p-6 flex flex-col items-center transition duration-300">
                        <div class="w-16 h-16 bg-indigo-100 rounded-full flex items-center justify-center mb-4">
                            <i class="fas fa-shopping-bag text-indigo-600 text-xl"></i>
                        </div>
                        <h3 class="text-lg font-medium text-gray-800">${category}</h3>
                    </a>
                </c:forEach>
            </div>
        </section>
        
        <!-- Featured Products Section -->
        <section>
            <div class="flex justify-between items-center mb-6">
                <h2 class="text-2xl font-bold text-gray-800">Featured Products</h2>
                <a href="${pageContext.request.contextPath}/customer/products" class="text-indigo-600 hover:text-indigo-800 font-medium">
                    View All <i class="fas fa-chevron-right ml-1"></i>
                </a>
            </div>
            
            <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                <c:forEach items="${featuredProducts}" var="product" end="7">
                    <div class="product-card bg-white rounded-lg shadow overflow-hidden h-full flex flex-col">
                        <a href="${pageContext.request.contextPath}/customer/product/details?id=${product.productId}" class="block relative">
                            <c:if test="${product.discounted}">
                                <span class="discount-badge">-50%</span>
                            </c:if>
                            <img src="${pageContext.request.contextPath}/${product.imagePath}" 
                                 alt="${product.name}" 
                                 class="w-full product-image">
                        </a>
                        <div class="p-3 flex-grow flex flex-col">
                            <a href="${pageContext.request.contextPath}/customer/product/details?id=${product.productId}" 
                               class="block">
                                <h3 class="product-title text-gray-800">${product.name}</h3>
                            </a>
                            <p class="product-description text-gray-600">${product.description}</p>
                            <div class="mt-auto">
                                <div class="flex justify-between items-center mt-2">
                                    <span class="product-price text-indigo-600 font-bold">
                                        <c:if test="${product.discounted}">
                                            <span class="original-price">RM${product.originalPrice}</span>
                                        </c:if>
                                        RM${product.price}
                                    </span>
                                    <a href="${pageContext.request.contextPath}/customer/product/details?id=${product.productId}" 
                                       class="add-to-cart-btn bg-indigo-600 text-white rounded hover:bg-indigo-700 transition">
                                       View Details
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </section>
    </main>
    
    <!-- Footer -->
    <jsp:include page="../includes/footer.jsp" />
    
    <!-- JavaScript -->
    <script>
        // Add any custom JavaScript here
    </script>
</body>
</html>