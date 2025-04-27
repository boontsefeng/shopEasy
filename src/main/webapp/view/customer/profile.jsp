<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ include file="/view/customer/font.jsp" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShopEasy - My Profile</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="bg-gray-100">
    <!-- Navigation -->
    <jsp:include page="../includes/customer-nav.jsp" />
    
    <!-- Main Content -->
    <main class="container mx-auto px-4 py-8">
        <!-- Page Header -->
        <h1 class="text-3xl font-bold text-gray-800 mb-6">My Profile</h1>
        
        <!-- Alert Messages -->
        <c:if test="${param.success eq 'updated'}">
            <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative mb-4" role="alert">
                <strong class="font-bold">Success!</strong>
                <span class="block sm:inline">Your profile has been updated successfully.</span>
            </div>
        </c:if>
        
        <c:if test="${not empty error}">
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4" role="alert">
                <strong class="font-bold">Error!</strong>
                <span class="block sm:inline">${error}</span>
            </div>
        </c:if>
        
        <!-- Profile Form -->
        <div class="bg-white rounded-lg shadow-lg overflow-hidden mb-8">
            <div class="p-6">
                <form action="${pageContext.request.contextPath}/customer/profile" method="post">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <!-- Personal Information -->
                        <div>
                            <h2 class="text-xl font-semibold text-gray-800 mb-4">Personal Information</h2>
                            
                            <div class="mb-4">
                                <label for="name" class="block text-sm font-medium text-gray-700 mb-1">Full Name</label>
                                <input type="text" id="name" name="name" value="${userProfile.name}" required
                                       class="w-full p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
                            </div>
                            
                            <div class="mb-4">
                                <label for="email" class="block text-sm font-medium text-gray-700 mb-1">Email Address</label>
                                <input type="email" id="email" name="email" value="${userProfile.email}" required
                                       class="w-full p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
                            </div>
                            
                            <div class="mb-4">
                                <label for="contactNumber" class="block text-sm font-medium text-gray-700 mb-1">Phone Number</label>
                                <input type="text" id="contactNumber" name="contactNumber" value="${userProfile.contactNumber}" required
                                       class="w-full p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
                            </div>
                        </div>
                        
                        <!-- Account Information -->
                        <div>
                            <h2 class="text-xl font-semibold text-gray-800 mb-4">Account Information</h2>
                            
                            <div class="mb-4">
                                <label for="username" class="block text-sm font-medium text-gray-700 mb-1">Username</label>
                                <input type="text" id="username" value="${userProfile.username}" readonly
                                       class="w-full p-2 border border-gray-300 rounded-md bg-gray-100">
                                <p class="mt-1 text-xs text-gray-500">Username cannot be changed to ensure account security and maintain system data integrity. It serves as your unique identifier in the system.</p>
                            </div>
                            
                            <div class="mb-4">
                                <label for="password" class="block text-sm font-medium text-gray-700 mb-1">New Password</label>
                                <input type="password" id="password" name="password"
                                       class="w-full p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
                                <p class="mt-1 text-xs text-gray-500">Leave blank to keep current password.</p>
                            </div>
                            
                            <div class="mb-4">
                                <label for="confirmPassword" class="block text-sm font-medium text-gray-700 mb-1">Confirm New Password</label>
                                <input type="password" id="confirmPassword" name="confirmPassword"
                                       class="w-full p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
                            </div>
                        </div>
                    </div>
                    
                    <div class="mt-6 text-right">
                        <button type="submit" 
                                class="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                            <i class="fas fa-save mr-2"></i> Save Changes
                        </button>
                    </div>
                </form>
            </div>
        </div>
        
        <!-- Quick Links -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
            <div class="bg-white rounded-lg shadow p-6 text-center">
                <i class="fas fa-shopping-bag text-indigo-600 text-3xl mb-3"></i>
                <h3 class="text-lg font-medium text-gray-800 mb-2">My Orders</h3>
                <p class="text-gray-600 mb-4">View your order history and track current orders.</p>
                <a href="${pageContext.request.contextPath}/customer/orders" 
                   class="text-indigo-600 hover:text-indigo-800 transition font-medium">
                    View Orders <i class="fas fa-arrow-right ml-1"></i>
                </a>
            </div>
            
            <div class="bg-white rounded-lg shadow p-6 text-center">
                <i class="fas fa-shopping-cart text-indigo-600 text-3xl mb-3"></i>
                <h3 class="text-lg font-medium text-gray-800 mb-2">My Cart</h3>
                <p class="text-gray-600 mb-4">View items in your cart and proceed to checkout.</p>
                <a href="${pageContext.request.contextPath}/customer/cart" 
                   class="text-indigo-600 hover:text-indigo-800 transition font-medium">
                    View Cart <i class="fas fa-arrow-right ml-1"></i>
                </a>
            </div>
            
            <div class="bg-white rounded-lg shadow p-6 text-center">
                <i class="fas fa-store text-indigo-600 text-3xl mb-3"></i>
                <h3 class="text-lg font-medium text-gray-800 mb-2">Continue Shopping</h3>
                <p class="text-gray-600 mb-4">Browse our products and find something you like.</p>
                <a href="${pageContext.request.contextPath}/customer/products" 
                   class="text-indigo-600 hover:text-indigo-800 transition font-medium">
                    Shop Now <i class="fas fa-arrow-right ml-1"></i>
                </a>
            </div>
        </div>
    </main>
    
    <!-- Footer -->
    <jsp:include page="../includes/footer.jsp" />
    
    <script>
        // Password validation
        document.querySelector('form').addEventListener('submit', function(e) {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            
            if (password && password !== confirmPassword) {
                e.preventDefault();
                alert('Passwords do not match.');
            }
        });
    </script>
</body>
</html> 