<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<header class="bg-white shadow">
    <div class="container mx-auto px-4">
        <div class="flex justify-between items-center py-4">
            <!-- Logo -->
            <a href="${pageContext.request.contextPath}/customer/dashboard" class="flex items-center">
                <span class="text-2xl font-bold text-indigo-600">ShopEasy</span>
                <span class="ml-2 text-gray-700 text-sm">Customer Portal</span>
            </a>
            
            <!-- Search Bar (Medium and larger screens) -->
            <div class="hidden md:block flex-grow mx-16">
                <form action="${pageContext.request.contextPath}/customer/products" method="get" class="relative">
                    <input type="text" name="keyword" placeholder="Search products..." 
                           class="w-full py-2 pl-10 pr-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <i class="fas fa-search text-gray-400"></i>
                    </div>
                </form>
            </div>
            
            <!-- Navigation Links -->
            <nav class="hidden md:flex items-center space-x-8">
                <a href="${pageContext.request.contextPath}/customer/dashboard" class="text-gray-600 hover:text-indigo-600 transition">
                    <i class="fas fa-home mr-1"></i> Home
                </a>
                <a href="${pageContext.request.contextPath}/customer/products" class="text-gray-600 hover:text-indigo-600 transition">
                    <i class="fas fa-shopping-bag mr-1"></i> Products
                </a>
                <a href="${pageContext.request.contextPath}/customer/orders" class="text-gray-600 hover:text-indigo-600 transition">
                    <i class="fas fa-clipboard-list mr-1"></i> Orders
                </a>
                
                <!-- Cart with Badge -->
                <a href="${pageContext.request.contextPath}/customer/cart" class="text-gray-600 hover:text-indigo-600 transition relative">
                    <i class="fas fa-shopping-cart mr-1"></i> Cart
                    <c:if test="${cartCount > 0}">
                        <span class="absolute -top-2 -right-2 bg-red-500 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center">
                            ${cartCount}
                        </span>
                    </c:if>
                </a>
                
                <!-- User Dropdown -->
                <div class="relative inline-block text-left">
                    <button type="button" 
                            class="user-dropdown-btn inline-flex items-center px-2 py-1 border border-transparent rounded-full text-gray-600 hover:text-indigo-600 focus:outline-none transition">
                        <i class="fas fa-user-circle text-xl"></i>
                        <span class="ml-1">${sessionScope.userName}</span>
                        <i class="fas fa-chevron-down ml-1 text-xs"></i>
                    </button>
                    
                    <div class="user-dropdown-menu origin-top-right absolute right-0 mt-2 w-48 rounded-md shadow-lg bg-white ring-1 ring-black ring-opacity-5 divide-y divide-gray-100 hidden">
                        <div class="py-1">
                            <a href="${pageContext.request.contextPath}/customer/profile" class="block px-4 py-2 text-sm text-gray-700 hover:bg-indigo-50">
                                <i class="fas fa-user mr-2"></i> My Profile
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/orders" class="block px-4 py-2 text-sm text-gray-700 hover:bg-indigo-50">
                                <i class="fas fa-clipboard-list mr-2"></i> My Orders
                            </a>
                        </div>
                        <div class="py-1">
                            <a href="${pageContext.request.contextPath}/logout" class="block px-4 py-2 text-sm text-red-600 hover:bg-red-50">
                                <i class="fas fa-sign-out-alt mr-2"></i> Logout
                            </a>
                        </div>
                    </div>
                </div>
            </nav>
            
            <!-- Mobile Menu Button -->
            <div class="flex md:hidden items-center space-x-4">
                <a href="${pageContext.request.contextPath}/customer/cart" class="text-gray-600 hover:text-indigo-600 transition relative">
                    <i class="fas fa-shopping-cart text-xl"></i>
                    <c:if test="${cartCount > 0}">
                        <span class="absolute -top-2 -right-2 bg-red-500 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center">
                            ${cartCount}
                        </span>
                    </c:if>
                </a>
                <button type="button" class="mobile-menu-btn text-gray-600 hover:text-indigo-600 focus:outline-none">
                    <i class="fas fa-bars text-xl"></i>
                </button>
            </div>
        </div>
        
        <!-- Mobile Search Bar -->
        <div class="md:hidden pb-4">
            <form action="${pageContext.request.contextPath}/customer/products" method="get" class="relative">
                <input type="text" name="keyword" placeholder="Search products..." 
                       class="w-full py-2 pl-10 pr-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <i class="fas fa-search text-gray-400"></i>
                </div>
            </form>
        </div>
        
        <!-- Mobile Menu (Hidden by default) -->
        <div class="mobile-menu md:hidden hidden pb-4">
            <nav class="flex flex-col space-y-2">
                <a href="${pageContext.request.contextPath}/customer/dashboard" class="text-gray-600 hover:text-indigo-600 transition py-2">
                    <i class="fas fa-home mr-2"></i> Home
                </a>
                <a href="${pageContext.request.contextPath}/customer/products" class="text-gray-600 hover:text-indigo-600 transition py-2">
                    <i class="fas fa-shopping-bag mr-2"></i> Products
                </a>
                <a href="${pageContext.request.contextPath}/customer/orders" class="text-gray-600 hover:text-indigo-600 transition py-2">
                    <i class="fas fa-clipboard-list mr-2"></i> Orders
                </a>
                <a href="${pageContext.request.contextPath}/customer/profile" class="text-gray-600 hover:text-indigo-600 transition py-2">
                    <i class="fas fa-user mr-2"></i> My Profile
                </a>
                <a href="${pageContext.request.contextPath}/logout" class="text-red-600 hover:text-red-800 transition py-2">
                    <i class="fas fa-sign-out-alt mr-2"></i> Logout
                </a>
            </nav>
        </div>
    </div>
    
    <!-- Notification Bar -->
    <c:if test="${not empty sessionScope.error}">
        <div class="bg-red-100 border-t-4 border-red-500 text-red-700 px-4 py-3" role="alert">
            <div class="flex">
                <div class="py-1"><i class="fas fa-exclamation-circle"></i></div>
                <div class="ml-3">
                    <p class="font-bold">Error</p>
                    <p class="text-sm">${sessionScope.error}</p>
                </div>
                <button onclick="this.parentElement.parentElement.remove()" class="ml-auto">
                    <i class="fas fa-times"></i>
                </button>
            </div>
        </div>
        <c:remove var="error" scope="session" />
    </c:if>
    
    <c:if test="${not empty sessionScope.success}">
        <div class="bg-green-100 border-t-4 border-green-500 text-green-700 px-4 py-3" role="alert">
            <div class="flex">
                <div class="py-1"><i class="fas fa-check-circle"></i></div>
                <div class="ml-3">
                    <p class="font-bold">Success</p>
                    <p class="text-sm">${sessionScope.success}</p>
                </div>
                <button onclick="this.parentElement.parentElement.remove()" class="ml-auto">
                    <i class="fas fa-times"></i>
                </button>
            </div>
        </div>
        <c:remove var="success" scope="session" />
    </c:if>
</header>

<script>
    // Toggle mobile menu
    document.querySelector('.mobile-menu-btn').addEventListener('click', function() {
        document.querySelector('.mobile-menu').classList.toggle('hidden');
    });
    
    // Toggle user dropdown
    document.querySelector('.user-dropdown-btn').addEventListener('click', function() {
        document.querySelector('.user-dropdown-menu').classList.toggle('hidden');
    });
    
    // Close the dropdown if user clicks outside of it
    window.addEventListener('click', function(event) {
        if (!event.target.closest('.user-dropdown-btn')) {
            const dropdown = document.querySelector('.user-dropdown-menu');
            if (!dropdown.classList.contains('hidden')) {
                dropdown.classList.add('hidden');
            }
        }
    });
</script> 