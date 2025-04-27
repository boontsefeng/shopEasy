<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ include file="/view/customer/font.jsp" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShopEasy - ${product.name}</title>
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
        
        .original-price {
            text-decoration: line-through;
            color: #9ca3af;
            font-size: 1.25rem;
            margin-right: 0.5rem;
        }
        
        .discount-badge {
            display: inline-block;
            background-color: #ef4444;
            color: white;
            font-weight: bold;
            padding: 4px 10px;
            border-radius: 9999px;
            font-size: 0.875rem;
            margin-left: 0.75rem;
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0%, 100% {
                opacity: 1;
            }
            50% {
                opacity: 0.7;
            }
        }
        
        .related-discount-badge {
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
        
        .related-original-price {
            text-decoration: line-through;
            color: #9ca3af;
            font-size: 0.8rem;
            margin-right: 0.5rem;
        }
    </style>
</head>
<body class="bg-gray-100">
    <!-- Navigation -->
    <jsp:include page="../includes/customer-nav.jsp" />
    
    <!-- Main Content -->
    <main class="container mx-auto px-4 py-8">
        <!-- Breadcrumb -->
        <nav class="flex mb-6" aria-label="Breadcrumb">
            <ol class="inline-flex items-center space-x-1 md:space-x-3">
                <li class="inline-flex items-center">
                    <a href="${pageContext.request.contextPath}/customer/dashboard" 
                       class="text-gray-700 hover:text-indigo-600 transition">
                        <i class="fas fa-home mr-1"></i> Home
                    </a>
                </li>
                <li>
                    <div class="flex items-center">
                        <i class="fas fa-chevron-right text-gray-400 mx-2 text-sm"></i>
                        <a href="${pageContext.request.contextPath}/customer/products" 
                           class="text-gray-700 hover:text-indigo-600 transition">
                            Products
                        </a>
                    </div>
                </li>
                <li>
                    <div class="flex items-center">
                        <i class="fas fa-chevron-right text-gray-400 mx-2 text-sm"></i>
                        <a href="${pageContext.request.contextPath}/customer/product/category?category=${product.category}" 
                           class="text-gray-700 hover:text-indigo-600 transition">
                            ${product.category}
                        </a>
                    </div>
                </li>
                <li aria-current="page">
                    <div class="flex items-center">
                        <i class="fas fa-chevron-right text-gray-400 mx-2 text-sm"></i>
                        <span class="text-gray-500">${product.name}</span>
                    </div>
                </li>
            </ol>
        </nav>
        
        <!-- Alert Messages -->
        <c:if test="${param.success eq 'added'}">
            <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative mb-4" role="alert">
                <strong class="font-bold">Success!</strong>
                <span class="block sm:inline">Product added to cart successfully.</span>
                <div class="mt-2">
                    <a href="${pageContext.request.contextPath}/customer/cart" 
                       class="inline-block bg-green-600 text-white px-4 py-2 rounded text-sm hover:bg-green-700 transition">
                        View Cart
                    </a>
                    <button class="inline-block bg-gray-200 text-gray-700 px-4 py-2 rounded text-sm hover:bg-gray-300 transition ml-2"
                            onclick="this.parentNode.parentNode.style.display='none';">
                        Continue Shopping
                    </button>
                </div>
            </div>
        </c:if>
        
        <c:if test="${param.error eq 'insufficient_stock'}">
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4" role="alert">
                <strong class="font-bold">Error!</strong>
                <span class="block sm:inline">Insufficient stock available.</span>
            </div>
        </c:if>
        
        <c:if test="${param.error eq 'add_failed'}">
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4" role="alert">
                <strong class="font-bold">Error!</strong>
                <span class="block sm:inline">Failed to add product to cart. Please try again.</span>
            </div>
        </c:if>
        
        <!-- Product Details Section -->
        <div class="bg-white rounded-lg shadow-lg overflow-hidden mb-8">
            <div class="md:flex">
                <!-- Product Image -->
                <div class="md:w-1/2 p-6">
                    <div class="relative">
                        <c:if test="${product.discounted}">
                            <div class="absolute top-4 right-4 bg-red-600 text-white text-sm font-bold px-3 py-1 rounded-full">
                                50% OFF
                            </div>
                        </c:if>
                        <img src="${pageContext.request.contextPath}/${product.imagePath}" 
                            alt="${product.name}" 
                            class="w-full h-auto object-contain max-h-96">
                    </div>
                </div>
                
                <!-- Product Info -->
                <div class="md:w-1/2 p-6">
                    <div class="text-sm text-indigo-600 mb-2">
                        <span class="uppercase font-medium">${product.category}</span>
                    </div>
                    
                    <h1 class="text-3xl font-bold text-gray-900 mb-4">${product.name}</h1>
                    
                    <div class="mb-6">
                        <div class="flex items-center">
                            <c:choose>
                                <c:when test="${product.discounted}">
                                    <span class="original-price">RM${product.originalPrice}</span>
                                    <span class="text-2xl font-bold text-red-600">RM${product.price}</span>
                                    <span class="discount-badge">50% OFF</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-2xl font-bold text-indigo-600">RM${product.price}</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <c:if test="${product.quantity < 10 && product.quantity > 0}">
                            <span class="mt-2 inline-block text-sm text-orange-600 font-medium">
                                <i class="fas fa-exclamation-circle mr-1"></i> Only ${product.quantity} left in stock
                            </span>
                        </c:if>
                    </div>
                    
                    <div class="border-t border-b border-gray-200 py-6 mb-6">
                        <p class="text-gray-700 leading-relaxed">
                            ${product.description}
                        </p>
                    </div>
                    
                    <c:choose>
                        <c:when test="${product.quantity > 0}">
                            <form action="${pageContext.request.contextPath}/customer/cart/add" method="post" class="mb-6">
                                <input type="hidden" name="productId" value="${product.productId}">
                                <input type="hidden" name="redirect" value="product">
                                
                                <div class="flex items-center mb-4">
                                    <label for="quantity" class="text-gray-700 font-medium mr-4">Quantity:</label>
                                    <div class="custom-number-input h-10 w-32">
                                        <div class="flex flex-row h-10 w-full rounded-lg relative bg-transparent">
                                            <button type="button" 
                                                    onclick="this.parentNode.querySelector('input[type=number]').stepDown()" 
                                                    class="bg-gray-200 text-gray-600 hover:text-gray-700 hover:bg-gray-300 h-full w-10 rounded-l cursor-pointer outline-none">
                                                <span class="m-auto text-lg">−</span>
                                            </button>
                                            <input type="number" 
                                                   name="quantity" 
                                                   id="quantity" 
                                                   min="1" 
                                                   max="${product.quantity}" 
                                                   value="1"
                                                   class="outline-none focus:outline-none text-center w-full bg-gray-100 font-semibold text-md hover:text-black focus:text-black md:text-base cursor-default flex items-center text-gray-700" 
                                                   readonly>
                                            <button type="button" 
                                                    onclick="this.parentNode.querySelector('input[type=number]').stepUp()" 
                                                    class="bg-gray-200 text-gray-600 hover:text-gray-700 hover:bg-gray-300 h-full w-10 rounded-r cursor-pointer outline-none">
                                                <span class="m-auto text-lg">+</span>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="flex space-x-4">
                                    <c:choose>
                                        <c:when test="${inCart}">
                                            <button type="submit" 
                                                    class="flex-1 bg-indigo-600 text-white py-3 px-6 rounded-lg font-medium hover:bg-indigo-700 transition">
                                                <i class="fas fa-cart-plus mr-2"></i> Update Cart
                                            </button>
                                            <a href="${pageContext.request.contextPath}/customer/cart" 
                                               class="bg-gray-800 text-white py-3 px-6 rounded-lg font-medium hover:bg-gray-900 transition">
                                                <i class="fas fa-shopping-cart mr-2"></i> View Cart
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <button type="submit" 
                                                    class="flex-1 bg-indigo-600 text-white py-3 px-6 rounded-lg font-medium hover:bg-indigo-700 transition">
                                                <i class="fas fa-cart-plus mr-2"></i> Add to Cart
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </form>
                        </c:when>
                        <c:otherwise>
                            <div class="mb-6">
                                <div class="bg-red-100 text-red-700 py-3 px-4 rounded-lg">
                                    <i class="fas fa-times-circle mr-2"></i> Out of Stock
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                    
                    <div class="text-gray-600 text-sm">
                        <p><i class="fas fa-shipping-fast mr-2"></i> Fast Delivery Available</p>
                        <p><i class="fas fa-exchange-alt mr-2"></i> 7 Days Replacement Policy</p>
                        <p><i class="fas fa-shield-alt mr-2"></i> 1 Year Warranty</p>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Related Products Section -->
        <c:if test="${not empty relatedProducts}">
            <section class="mb-8">
                <h2 class="text-2xl font-bold text-gray-800 mb-6">Related Products</h2>
                
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                    <c:forEach items="${relatedProducts}" var="relProduct" end="3">
                        <div class="product-card bg-white rounded-lg shadow overflow-hidden">
                            <a href="${pageContext.request.contextPath}/customer/product/details?id=${relProduct.productId}" class="block relative">
                                <c:if test="${relProduct.discounted}">
                                    <span class="related-discount-badge">-50%</span>
                                </c:if>
                                <img src="${pageContext.request.contextPath}/${relProduct.imagePath}" 
                                     alt="${relProduct.name}" 
                                     class="w-full h-48 object-cover">
                            </a>
                            <div class="p-4">
                                <a href="${pageContext.request.contextPath}/customer/product/details?id=${relProduct.productId}" 
                                   class="block">
                                    <h3 class="text-lg font-medium text-gray-800 mb-2">${relProduct.name}</h3>
                                </a>
                                <p class="text-gray-600 text-sm mb-3 line-clamp-2">${relProduct.description}</p>
                                <div class="flex justify-between items-center">
                                    <span class="text-indigo-600 font-bold">
                                        <c:if test="${relProduct.discounted}">
                                            <span class="related-original-price">RM${relProduct.originalPrice}</span>
                                        </c:if>
                                        RM${relProduct.price}
                                    </span>
                                    <a href="${pageContext.request.contextPath}/customer/product/details?id=${relProduct.productId}" 
                                       class="bg-indigo-600 text-white px-3 py-1 rounded text-sm hover:bg-indigo-700 transition">
                                        View Details
                                    </a>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </section>
        </c:if>
    </main>
    
    <!-- Footer -->
    <jsp:include page="../includes/footer.jsp" />
    
    <script>
        // Allow quantity buttons to work properly
        document.querySelectorAll('input[type=number]').forEach(function(input) {
            input.addEventListener('change', function() {
                if (this.value > parseInt(this.getAttribute('max'))) {
                    this.value = this.getAttribute('max');
                }
                if (this.value < parseInt(this.getAttribute('min'))) {
                    this.value = this.getAttribute('min');
                }
            });
        });
    </script>
</body>
</html> 