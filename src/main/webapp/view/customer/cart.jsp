<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ include file="/view/customer/font.jsp" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShopEasy - Your Cart</title>
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
        <h1 class="text-3xl font-bold text-gray-800 mb-6">Your Shopping Cart</h1>
        
        <!-- Alert Messages -->
        <c:if test="${param.success eq 'added'}">
            <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative mb-4" role="alert">
                <strong class="font-bold">Success!</strong>
                <span class="block sm:inline">Product added to cart successfully.</span>
            </div>
        </c:if>
        
        <c:if test="${param.success eq 'updated'}">
            <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative mb-4" role="alert">
                <strong class="font-bold">Success!</strong>
                <span class="block sm:inline">Cart updated successfully.</span>
            </div>
        </c:if>
        
        <c:if test="${param.success eq 'removed'}">
            <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative mb-4" role="alert">
                <strong class="font-bold">Success!</strong>
                <span class="block sm:inline">Item removed from cart successfully.</span>
            </div>
        </c:if>
        
        <c:if test="${param.error eq 'empty'}">
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4" role="alert">
                <strong class="font-bold">Error!</strong>
                <span class="block sm:inline">Your cart is empty. Add items to proceed.</span>
            </div>
        </c:if>
        
        <!-- Cart Content -->
        <div class="bg-white rounded-lg shadow-lg overflow-hidden mb-8">
            <c:choose>
                <c:when test="${empty cartItems}">
                    <div class="p-8 text-center">
                        <i class="fas fa-shopping-cart text-gray-400 text-5xl mb-4"></i>
                        <h2 class="text-2xl font-semibold text-gray-700 mb-2">Your cart is empty</h2>
                        <p class="text-gray-500 mb-6">Looks like you haven't added any products to your cart yet.</p>
                        <a href="${pageContext.request.contextPath}/customer/products" 
                           class="inline-block bg-indigo-600 text-white px-6 py-3 rounded-lg font-medium hover:bg-indigo-700 transition">
                            Start Shopping
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="overflow-x-auto">
                        <table class="w-full">
                            <thead class="bg-gray-50 text-gray-700">
                                <tr>
                                    <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider">Product</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider">Price</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider">Quantity</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider">Subtotal</th>
                                    <th class="px-6 py-3 text-right text-xs font-medium uppercase tracking-wider">Action</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-200">
                                <c:forEach items="${cartItems}" var="item">
                                    <tr class="text-gray-700">
                                        <td class="px-6 py-4 whitespace-nowrap">
                                            <div class="flex items-center">
                                                <div class="flex-shrink-0 h-16 w-16">
                                                    <img class="h-16 w-16 object-cover rounded" 
                                                         src="${pageContext.request.contextPath}/${item.productImage}" 
                                                         alt="${item.productName}">
                                                </div>
                                                <div class="ml-4">
                                                    <a href="${pageContext.request.contextPath}/customer/product/details?id=${item.productId}" 
                                                       class="text-lg font-medium text-gray-900 hover:text-indigo-600 transition">
                                                        ${item.productName}
                                                    </a>
                                                </div>
                                            </div>
                                        </td>
                                        <td class="px-6 py-4 whitespace-nowrap">
                                            <div class="text-lg font-medium text-gray-900">RM${item.productPrice}</div>
                                        </td>
                                        <td class="px-6 py-4 whitespace-nowrap">
                                            <form action="${pageContext.request.contextPath}/customer/cart/update" method="post" class="flex items-center">
                                                <input type="hidden" name="cartId" value="${item.cartId}">
                                                <div class="custom-number-input h-10 w-32">
                                                    <div class="flex flex-row h-10 w-full rounded-lg relative bg-transparent">
                                                        <button type="button" 
                                                                onclick="updateQuantity(this, -1)" 
                                                                class="bg-gray-200 text-gray-600 hover:text-gray-700 hover:bg-gray-300 h-full w-10 rounded-l cursor-pointer outline-none">
                                                            <span class="m-auto text-lg">−</span>
                                                        </button>
                                                        <input type="number" 
                                                               name="quantity" 
                                                               id="quantity-${item.cartId}" 
                                                               min="1" 
                                                               value="${item.quantity}"
                                                               class="outline-none focus:outline-none text-center w-full bg-gray-100 font-semibold text-md hover:text-black focus:text-black md:text-base cursor-default flex items-center text-gray-700">
                                                        <button type="button" 
                                                                onclick="updateQuantity(this, 1)" 
                                                                class="bg-gray-200 text-gray-600 hover:text-gray-700 hover:bg-gray-300 h-full w-10 rounded-r cursor-pointer outline-none">
                                                            <span class="m-auto text-lg">+</span>
                                                        </button>
                                                    </div>
                                                </div>
                                                <button type="submit" 
                                                        class="ml-2 text-indigo-600 hover:text-indigo-800 transition">
                                                    <i class="fas fa-sync-alt"></i>
                                                </button>
                                            </form>
                                        </td>
                                        <td class="px-6 py-4 whitespace-nowrap">
                                            <div class="text-lg font-medium text-gray-900">RM${item.totalPrice}</div>
                                        </td>
                                        <td class="px-6 py-4 whitespace-nowrap text-right">
                                            <form action="${pageContext.request.contextPath}/customer/cart/remove" method="post">
                                                <input type="hidden" name="cartId" value="${item.cartId}">
                                                <button type="submit" 
                                                        class="text-red-600 hover:text-red-800 transition font-medium">
                                                    <i class="fas fa-trash-alt mr-1"></i> Remove
                                                </button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                    
                    <!-- Cart Summary -->
                    <div class="p-6 bg-gray-50">
                        <div class="flex flex-col md:flex-row justify-between items-start md:items-center">
                            <div class="mb-4 md:mb-0">
                                <a href="${pageContext.request.contextPath}/customer/products" 
                                   class="text-indigo-600 hover:text-indigo-800 transition font-medium">
                                    <i class="fas fa-arrow-left mr-2"></i> Continue Shopping
                                </a>
                            </div>
                            
                            <div class="bg-white p-4 rounded-lg shadow-sm">
                                <div class="flex justify-between mb-3">
                                    <span class="font-medium text-gray-700">Subtotal:</span>
                                    <span class="font-bold text-gray-900">RM${cartTotal}</span>
                                </div>
                                <div class="flex justify-between mb-3">
                                    <span class="font-medium text-gray-700">Shipping:</span>
                                    <span class="font-medium text-gray-900">FREE</span>
                                </div>
                                <div class="flex justify-between text-lg border-t pt-3 border-gray-200">
                                    <span class="font-bold text-gray-900">Total:</span>
                                    <span class="font-bold text-indigo-600">RM${cartTotal}</span>
                                </div>
                                
                                <div class="mt-6">
                                    <a href="${pageContext.request.contextPath}/customer/checkout" 
                                       class="block w-full bg-indigo-600 text-white text-center py-3 px-4 rounded-lg font-medium hover:bg-indigo-700 transition">
                                        Proceed to Checkout
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
    
    <!-- Footer -->
    <jsp:include page="../includes/footer.jsp" />
    
    <script>
        function updateQuantity(button, change) {
            const input = button.parentNode.querySelector('input[type=number]');
            const currentValue = parseInt(input.value);
            const newValue = currentValue + change;
            
            if (newValue >= 1) {
                input.value = newValue;
            }
        }
    </script>
</body>
</html> 