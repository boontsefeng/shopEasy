<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShopEasy - Order #${order.orderId}</title>
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
        <!-- Success Message on Order Placement -->
        <c:if test="${param.success eq 'placed'}">
            <div class="bg-green-100 border border-green-400 text-green-700 px-6 py-4 rounded-lg mb-6" role="alert">
                <div class="flex">
                    <div class="flex-shrink-0">
                        <i class="fas fa-check-circle text-2xl"></i>
                    </div>
                    <div class="ml-4">
                        <p class="font-bold">Order Placed Successfully!</p>
                        <p>Thank you for your order. We'll process it as soon as possible.</p>
                    </div>
                </div>
            </div>
        </c:if>
        
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
                        <a href="${pageContext.request.contextPath}/customer/orders" 
                           class="text-gray-700 hover:text-indigo-600 transition">
                            Orders
                        </a>
                    </div>
                </li>
                <li aria-current="page">
                    <div class="flex items-center">
                        <i class="fas fa-chevron-right text-gray-400 mx-2 text-sm"></i>
                        <span class="text-gray-500">Order #${order.orderId}</span>
                    </div>
                </li>
            </ol>
        </nav>
        
        <!-- Order Details Header -->
        <div class="bg-white rounded-lg shadow-lg overflow-hidden mb-6">
            <div class="p-6 md:flex md:justify-between md:items-center">
                <div>
                    <h1 class="text-2xl font-bold text-gray-800">Order #${order.orderId}</h1>
                    <p class="text-gray-600 mt-1">
                        Placed on <fmt:formatDate value="${order.orderDate}" pattern="dd MMM yyyy, hh:mm a" />
                    </p>
                </div>
                <div class="mt-4 md:mt-0">
                    <div class="inline-flex items-center bg-gray-100 px-4 py-2 rounded-full">
                        <c:choose>
                            <c:when test="${order.status eq 'Pending'}">
                                <span class="w-3 h-3 rounded-full bg-yellow-400 mr-2"></span>
                                <span class="text-gray-800 font-medium">Pending</span>
                            </c:when>
                            <c:when test="${order.status eq 'Processing'}">
                                <span class="w-3 h-3 rounded-full bg-blue-500 mr-2"></span>
                                <span class="text-gray-800 font-medium">Processing</span>
                            </c:when>
                            <c:when test="${order.status eq 'Shipped'}">
                                <span class="w-3 h-3 rounded-full bg-indigo-500 mr-2"></span>
                                <span class="text-gray-800 font-medium">Shipped</span>
                            </c:when>
                            <c:when test="${order.status eq 'Delivered'}">
                                <span class="w-3 h-3 rounded-full bg-green-500 mr-2"></span>
                                <span class="text-gray-800 font-medium">Delivered</span>
                            </c:when>
                            <c:when test="${order.status eq 'Cancelled'}">
                                <span class="w-3 h-3 rounded-full bg-red-500 mr-2"></span>
                                <span class="text-gray-800 font-medium">Cancelled</span>
                            </c:when>
                            <c:otherwise>
                                <span class="w-3 h-3 rounded-full bg-gray-500 mr-2"></span>
                                <span class="text-gray-800 font-medium">${order.status}</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Order Information -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
            <!-- Shipping Info -->
            <div class="bg-white rounded-lg shadow p-6">
                <h2 class="text-lg font-semibold text-gray-800 mb-4">Shipping Information</h2>
                <div class="text-gray-700">
                    <p class="mb-1 whitespace-pre-line">${order.shippingAddress}</p>
                </div>
                
                <c:if test="${order.status eq 'Shipped' && not empty order.trackingNumber}">
                    <div class="mt-4 pt-4 border-t border-gray-200">
                        <h3 class="text-md font-medium text-gray-800 mb-2">Tracking Information</h3>
                        <p class="text-gray-700">
                            <span class="font-medium">Tracking #:</span> ${order.trackingNumber}
                        </p>
                    </div>
                </c:if>
            </div>
            
            <!-- Payment Info -->
            <div class="bg-white rounded-lg shadow p-6">
                <h2 class="text-lg font-semibold text-gray-800 mb-4">Payment Information</h2>
                <div class="text-gray-700">
                    <p class="mb-1">
                        <span class="font-medium">Method:</span> ${order.paymentMethod}
                    </p>
                    <p class="mb-1">
                        <span class="font-medium">Total:</span> RM${order.totalAmount}
                    </p>
                </div>
            </div>
            
            <!-- Order Summary -->
            <div class="bg-white rounded-lg shadow p-6">
                <h2 class="text-lg font-semibold text-gray-800 mb-4">Order Summary</h2>
                <div class="text-gray-700">
                    <div class="flex justify-between mb-2">
                        <span>Subtotal:</span>
                        <span>RM${order.totalAmount}</span>
                    </div>
                    <div class="flex justify-between mb-2">
                        <span>Shipping:</span>
                        <span>FREE</span>
                    </div>
                    <div class="flex justify-between mb-2">
                        <span>Tax:</span>
                        <span>Included</span>
                    </div>
                    <div class="flex justify-between text-lg font-bold border-t border-gray-200 pt-2 mt-2">
                        <span>Total:</span>
                        <span class="text-indigo-600">RM${order.totalAmount}</span>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Order Items -->
        <div class="bg-white rounded-lg shadow-lg overflow-hidden mb-8">
            <div class="px-6 py-4 border-b border-gray-200">
                <h2 class="text-lg font-semibold text-gray-800">Order Items</h2>
            </div>
            
            <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                        <tr>
                            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                Product
                            </th>
                            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                Price
                            </th>
                            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                Quantity
                            </th>
                            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                Total
                            </th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                        <c:forEach items="${orderItems}" var="item">
                            <tr>
                                <td class="px-6 py-4 whitespace-nowrap">
                                    <div class="flex items-center">
                                        <div class="flex-shrink-0 h-16 w-16">
                                            <img class="h-16 w-16 object-cover rounded" 
                                                 src="${pageContext.request.contextPath}/${item.productImage}" 
                                                 alt="${item.productName}">
                                        </div>
                                        <div class="ml-4">
                                            <div class="text-sm font-medium text-gray-900">${item.productName}</div>
                                        </div>
                                    </div>
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap">
                                    <div class="text-sm text-gray-900">RM${item.price}</div>
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap">
                                    <div class="text-sm text-gray-900">${item.quantity}</div>
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap">
                                    <div class="text-sm font-medium text-gray-900">RM${item.totalPrice}</div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
        
        <!-- Back to Orders Button -->
        <div class="text-center">
            <a href="${pageContext.request.contextPath}/customer/orders" 
               class="inline-block text-indigo-600 hover:text-indigo-800 transition font-medium">
                <i class="fas fa-arrow-left mr-2"></i> Back to Orders
            </a>
        </div>
    </main>
    
    <!-- Footer -->
    <jsp:include page="../includes/footer.jsp" />
</body>
</html> 