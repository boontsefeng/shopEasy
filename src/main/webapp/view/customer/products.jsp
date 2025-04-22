<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShopEasy - Products</title>
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
    </style>
</head>
<body class="bg-gray-100">
    <!-- Navigation -->
    <jsp:include page="../includes/customer-nav.jsp" />
    
    <!-- Main Content -->
    <main class="container mx-auto px-4 py-8">
        <!-- Page Header -->
        <div class="flex justify-between items-center mb-6">
            <h1 class="text-3xl font-bold text-gray-800">Products</h1>
            <div class="text-sm text-gray-600">
                <span>${products.size()} products found</span>
                <c:if test="${not empty keyword}">
                    <span class="ml-2">for "${keyword}"</span>
                </c:if>
                <c:if test="${not empty currentCategory}">
                    <span class="ml-2">in "${currentCategory}"</span>
                </c:if>
            </div>
        </div>
        
        <!-- Alert Messages -->
        <c:if test="${param.success eq 'added'}">
            <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative mb-4" role="alert">
                <strong class="font-bold">Success!</strong>
                <span class="block sm:inline">Product added to cart successfully.</span>
            </div>
        </c:if>
        
        <c:if test="${param.error eq 'insufficient_stock'}">
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4" role="alert">
                <strong class="font-bold">Error!</strong>
                <span class="block sm:inline">Insufficient stock available.</span>
            </div>
        </c:if>
        
        <!-- Products Grid with Sidebar -->
        <div class="flex flex-col md:flex-row gap-6">
            <!-- Sidebar: Categories -->
            <div class="w-full md:w-1/4 lg:w-1/5">
                <div class="bg-white rounded-lg shadow p-4">
                    <h2 class="text-lg font-semibold mb-4 text-gray-800">Categories</h2>
                    <ul class="space-y-2">
                        <li>
                            <a href="${pageContext.request.contextPath}/customer/products" 
                               class="block p-2 rounded hover:bg-indigo-50 ${empty currentCategory ? 'bg-indigo-100 text-indigo-700 font-medium' : 'text-gray-700'}">
                                All Products
                            </a>
                        </li>
                        <c:forEach items="${categories}" var="category">
                            <li>
                                <a href="${pageContext.request.contextPath}/customer/product/category?category=${category}" 
                                   class="block p-2 rounded hover:bg-indigo-50 ${category eq currentCategory ? 'bg-indigo-100 text-indigo-700 font-medium' : 'text-gray-700'}">
                                    ${category}
                                </a>
                            </li>
                        </c:forEach>
                    </ul>
                </div>
            </div>
            
            <!-- Products Grid -->
            <div class="w-full md:w-3/4 lg:w-4/5">
                <c:choose>
                    <c:when test="${empty products}">
                        <div class="bg-white rounded-lg shadow p-8 text-center">
                            <i class="fas fa-shopping-basket text-gray-400 text-5xl mb-4"></i>
                            <h3 class="text-xl font-semibold text-gray-600 mb-2">No Products Found</h3>
                            <p class="text-gray-500 mb-4">We couldn't find any products matching your criteria.</p>
                            <a href="${pageContext.request.contextPath}/customer/products" 
                               class="inline-block bg-indigo-600 text-white px-4 py-2 rounded font-medium hover:bg-indigo-700 transition">
                                Browse All Products
                            </a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                            <c:forEach items="${products}" var="product">
                                <div class="product-card bg-white rounded-lg shadow overflow-hidden h-full flex flex-col">
                                    <a href="${pageContext.request.contextPath}/customer/product/details?id=${product.productId}" class="block">
                                        <img src="${pageContext.request.contextPath}/${product.imagePath}" 
                                             alt="${product.name}" 
                                             class="w-full h-48 object-cover">
                                    </a>
                                    <div class="p-4 flex-grow">
                                        <a href="${pageContext.request.contextPath}/customer/product/details?id=${product.productId}" 
                                           class="block">
                                            <h3 class="text-lg font-medium text-gray-800 mb-2">${product.name}</h3>
                                        </a>
                                        <p class="text-gray-600 text-sm mb-3 line-clamp-2">${product.description}</p>
                                        <div class="mt-auto">
                                            <div class="flex justify-between items-center mt-4">
                                                <span class="text-indigo-600 font-bold">RM${product.price}</span>
                                                <form action="${pageContext.request.contextPath}/customer/cart/add" method="post">
                                                    <input type="hidden" name="productId" value="${product.productId}">
                                                    <input type="hidden" name="quantity" value="1">
                                                    <input type="hidden" name="redirect" value="cart">
                                                    <button type="submit" 
                                                            class="bg-indigo-600 text-white px-3 py-1 rounded text-sm hover:bg-indigo-700 transition">
                                                        <i class="fas fa-cart-plus mr-1"></i> Add to Cart
                                                    </button>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </main>
    
    <!-- Footer -->
    <jsp:include page="../includes/footer.jsp" />
</body>
</html> 