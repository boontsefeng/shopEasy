<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
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
            transform: translateY(-10px);
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
            
            <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
                <c:forEach items="${featuredProducts}" var="product" end="7">
                    <div class="product-card bg-white rounded-lg shadow overflow-hidden">
                        <img src="${pageContext.request.contextPath}/${product.imagePath}" 
                             alt="${product.name}" 
                             class="w-full h-48 object-cover">
                        <div class="p-4">
                            <h3 class="text-lg font-medium text-gray-800 mb-2">${product.name}</h3>
                            <p class="text-gray-600 text-sm mb-3 line-clamp-2">${product.description}</p>
                            <div class="flex justify-between items-center">
                                <span class="text-indigo-600 font-bold">RM${product.price}</span>
                                <a href="${pageContext.request.contextPath}/customer/product/details?id=${product.productId}" 
                                   class="bg-indigo-600 text-white px-3 py-1 rounded text-sm hover:bg-indigo-700 transition">
                                    View Details
                                </a>
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