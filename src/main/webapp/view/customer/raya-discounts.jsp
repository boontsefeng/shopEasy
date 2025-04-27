<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ include file="/view/customer/font.jsp" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShopEasy - Raya Special Discounts</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .product-card {
            transition: all 0.3s ease;
        }
        
        .product-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }
        
        .product-image {
            height: 200px;
            object-fit: contain;
            padding: 10px;
        }
        
        .product-title {
            font-size: 1rem;
            line-height: 1.4;
            margin-bottom: 0.5rem;
            font-weight: 600;
        }
        
        .product-description {
            font-size: 0.85rem;
            line-height: 1.3;
            margin-bottom: 0.5rem;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        
        .discount-badge {
            position: absolute;
            top: 10px;
            right: 10px;
            background-color: #ef4444;
            color: white;
            font-weight: bold;
            padding: 6px 12px;
            border-radius: 9999px;
            font-size: 0.85rem;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            z-index: 10;
        }
        
        .original-price {
            text-decoration: line-through;
            color: #9ca3af;
            font-size: 0.85rem;
        }
        
        .festive-header {
            background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
            border-radius: 1rem;
            padding: 2rem;
            margin-bottom: 2rem;
            color: white;
            position: relative;
            overflow: hidden;
        }
        
        .festive-header::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-image: url("data:image/svg+xml,%3Csvg width='100' height='100' viewBox='0 0 100 100' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M11 18c3.866 0 7-3.134 7-7s-3.134-7-7-7-7 3.134-7 7 3.134 7 7 7zm48 25c3.866 0 7-3.134 7-7s-3.134-7-7-7-7 3.134-7 7 3.134 7 7 7zm-43-7c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zm63 31c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zM34 90c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zm56-76c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zM12 86c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm28-65c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm23-11c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm-6 60c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm29 22c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zM32 63c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm57-13c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm-9-21c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM60 91c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM35 41c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM12 60c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2z' fill='%23ffffff' fill-opacity='0.1' fill-rule='evenodd'/%3E%3C/svg%3E");
            opacity: 0.3;
        }
        
        .countdown-timer {
            background-color: rgba(255, 255, 255, 0.15);
            padding: 0.5rem 1rem;
            border-radius: 0.5rem;
            display: inline-block;
            margin-top: 1rem;
            backdrop-filter: blur(4px);
        }
    </style>
</head>
<body class="bg-gray-100">
    <!-- Navigation -->
    <jsp:include page="../includes/customer-nav.jsp" />
    
    <!-- Main Content -->
    <main class="container mx-auto px-4 py-8">
        <!-- Festive Header Banner -->
        <div class="festive-header">
            <h1 class="text-4xl md:text-5xl font-bold mb-3">Raya Special Discounts</h1>
            <p class="text-lg md:text-xl opacity-90 max-w-2xl">Celebrate this festive season with amazing 50% discounts on selected items!</p>
            <div class="countdown-timer">
                <i class="far fa-clock mr-2"></i>
                <span>Limited time offer - Ends in: <span id="countdown">7 days</span></span>
            </div>
        </div>
        
        <!-- Discount Products Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <c:forEach items="${discountedProducts}" var="product">
                <div class="product-card bg-white rounded-lg shadow overflow-hidden relative">
                    <span class="discount-badge">-50%</span>
                    <a href="${pageContext.request.contextPath}/customer/product/details?id=${product.productId}">
                        <img src="${pageContext.request.contextPath}/${product.imagePath}" 
                             alt="${product.name}" 
                             class="w-full product-image">
                    </a>
                    <div class="p-4">
                        <a href="${pageContext.request.contextPath}/customer/product/details?id=${product.productId}">
                            <h3 class="product-title text-gray-800">${product.name}</h3>
                        </a>
                        <p class="product-description text-gray-600">${product.description}</p>
                        <div class="mt-4 flex items-center justify-between">
                            <div>
                                <div class="original-price">RM${product.originalPrice}</div>
                                <div class="text-red-600 font-bold text-lg">RM${product.price}</div>
                            </div>
                            <form action="${pageContext.request.contextPath}/customer/cart/add" method="post">
                                <input type="hidden" name="productId" value="${product.productId}">
                                <input type="hidden" name="quantity" value="1">
                                <input type="hidden" name="redirect" value="raya-discounts">
                                <button type="submit" class="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded text-sm font-medium transition">
                                    <i class="fas fa-shopping-cart mr-1"></i> Add to Cart
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
        
        <!-- Additional Promotion Information -->
        <div class="mt-12 bg-white rounded-lg shadow p-6">
            <h2 class="text-2xl font-bold text-gray-800 mb-4">Raya Promotion Details</h2>
            <ul class="space-y-3 text-gray-600">
                <li class="flex items-start">
                    <i class="fas fa-check-circle text-green-500 mt-1 mr-2"></i>
                    <span>50% discount on selected items for a limited time only</span>
                </li>
                <li class="flex items-start">
                    <i class="fas fa-check-circle text-green-500 mt-1 mr-2"></i>
                    <span>Free shipping for orders above RM50</span>
                </li>
                <li class="flex items-start">
                    <i class="fas fa-check-circle text-green-500 mt-1 mr-2"></i>
                    <span>Additional 5% off when using promo code: RAYA2024</span>
                </li>
                <li class="flex items-start">
                    <i class="fas fa-check-circle text-green-500 mt-1 mr-2"></i>
                    <span>Promotion valid until 30 June 2024</span>
                </li>
            </ul>
        </div>
    </main>
    
    <!-- Footer -->
    <jsp:include page="../includes/footer.jsp" />
    
    <!-- JavaScript for countdown timer -->
    <script>
        // Set the countdown date (7 days from now)
        const countdownDate = new Date();
        countdownDate.setDate(countdownDate.getDate() + 7);
        
        // Update the countdown every second
        const countdownEl = document.getElementById('countdown');
        const countdownTimer = setInterval(function() {
            const now = new Date().getTime();
            const distance = countdownDate - now;
            
            const days = Math.floor(distance / (1000 * 60 * 60 * 24));
            const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
            const seconds = Math.floor((distance % (1000 * 60)) / 1000);
            
            countdownEl.innerHTML = days + "d " + hours + "h " + minutes + "m " + seconds + "s";
            
            if (distance < 0) {
                clearInterval(countdownTimer);
                countdownEl.innerHTML = "EXPIRED";
            }
        }, 1000);
    </script>
</body>
</html> 