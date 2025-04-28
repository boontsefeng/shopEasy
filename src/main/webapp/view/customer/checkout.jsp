<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ include file="/view/customer/font.jsp" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShopEasy - Checkout</title>
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
        <h1 class="text-3xl font-bold text-gray-800 mb-6">Checkout</h1>
        
        <!-- Alert Messages -->
        <c:if test="${param.error eq 'missing_fields'}">
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4" role="alert">
                <strong class="font-bold">Error!</strong>
                <span class="block sm:inline">Please fill in all required fields.</span>
            </div>
        </c:if>
        
        <c:if test="${param.error eq 'order_failed'}">
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4" role="alert">
                <strong class="font-bold">Error!</strong>
                <span class="block sm:inline">Failed to place your order. Please try again.</span>
            </div>
        </c:if>
        
        <c:if test="${param.error eq 'items_failed'}">
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4" role="alert">
                <strong class="font-bold">Error!</strong>
                <span class="block sm:inline">Some items in your cart are no longer available. Please review your cart.</span>
            </div>
        </c:if>
        
        <!-- Checkout Form -->
        <div class="bg-white rounded-lg shadow-lg overflow-hidden mb-8">
            <div class="p-6 md:p-8">
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <!-- Left Column: Shipping & Payment -->
                    <div class="md:col-span-2">
                        <form action="${pageContext.request.contextPath}/customer/order/place" method="post">
                            <h2 class="text-xl font-semibold text-gray-800 mb-4">Shipping Information</h2>
                            
                            <div class="mb-6">
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <div>
                                        <label for="name" class="block text-sm font-medium text-gray-700 mb-1">Full Name</label>
                                        <input type="text" id="name" name="name" value="${user.name}" readonly
                                               class="w-full p-2 border border-gray-300 rounded-md bg-gray-100">
                                    </div>
                                    <div>
                                        <label for="email" class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                                        <input type="email" id="email" name="email" value="${user.email}" readonly
                                               class="w-full p-2 border border-gray-300 rounded-md bg-gray-100">
                                    </div>
                                </div>
                            </div>
                            
                            <div class="mb-6">
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <div>
                                        <label for="contactNumber" class="block text-sm font-medium text-gray-700 mb-1">Phone Number</label>
                                        <input type="text" id="contactNumber" name="contactNumber" value="${user.contactNumber}" readonly
                                               class="w-full p-2 border border-gray-300 rounded-md bg-gray-100">
                                    </div>
                                </div>
                            </div>
                            
                            <div class="mb-6">
                                <label for="shippingAddress" class="block text-sm font-medium text-gray-700 mb-1">Shipping Address *</label>
                                <textarea id="shippingAddress" name="shippingAddress" rows="3" required
                                          class="w-full p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
                                          placeholder="Enter your full shipping address"></textarea>
                            </div>
                            
                            <h2 class="text-xl font-semibold text-gray-800 mb-4 mt-8">Payment Method</h2>
                            
                            <div class="mb-6">
                                <div class="space-y-3">
                                    <div class="flex items-center">
                                        <input type="radio" id="paymentCOD" name="paymentMethod" value="Cash on Delivery" checked
                                               class="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300">
                                        <label for="paymentCOD" class="ml-3 text-gray-700">
                                            Cash on Delivery (COD)
                                        </label>
                                    </div>
                                    <div class="flex items-center">
                                        <input type="radio" id="paymentUPI" name="paymentMethod" value="UPI Payment"
                                               class="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300">
                                        <label for="paymentUPI" class="ml-3 text-gray-700">
                                            UPI Payment (Pay on Delivery)
                                        </label>
                                    </div>
                                    <div class="flex items-center">
                                        <input type="radio" id="paymentCard" name="paymentMethod" value="Credit/Debit Card"
                                               class="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300">
                                        <label for="paymentCard" class="ml-3 text-gray-700">
                                            Credit/Debit Card
                                        </label>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="mt-6">
                                <button type="submit" id="placeOrderBtn"
                                        class="w-full bg-indigo-600 text-white py-3 px-4 rounded-lg font-medium hover:bg-indigo-700 transition">
                                    Place Order
                                </button>
                                <p class="text-gray-500 text-xs mt-2">
                                    By placing your order, you agree to our <a href="#" class="text-indigo-600 hover:text-indigo-800">Terms and Conditions</a> and <a href="#" class="text-indigo-600 hover:text-indigo-800">Privacy Policy</a>.
                                </p>
                            </div>
                        </form>
                    </div>
                    
                    <!-- Right Column: Order Summary -->
                    <div class="md:col-span-1">
                        <div class="bg-gray-50 p-4 rounded-lg">
                            <h2 class="text-xl font-semibold text-gray-800 mb-4">Order Summary</h2>
                            
                            <div class="mb-4 max-h-80 overflow-y-auto">
                                <c:forEach items="${cartItems}" var="item">
                                    <div class="flex items-center py-2 border-b border-gray-200">
                                        <div class="flex-shrink-0 h-16 w-16">
                                            <img class="h-16 w-16 object-cover rounded" 
                                                 src="${pageContext.request.contextPath}/${item.productImage}" 
                                                 alt="${item.productName}">
                                        </div>
                                        <div class="ml-3 flex-1">
                                            <p class="text-sm font-medium text-gray-900">${item.productName}</p>
                                            <div class="flex justify-between mt-1">
                                                <p class="text-sm text-gray-500">Qty: ${item.quantity}</p>
                                                <p class="text-sm font-medium text-gray-900">RM${item.totalPrice}</p>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                            
                            <div class="border-t border-gray-200 pt-4">
                                <div class="flex justify-between mb-2">
                                    <span class="text-gray-600">Subtotal</span>
                                    <span class="font-medium text-gray-900">RM${cartTotal}</span>
                                </div>
                                <div class="flex justify-between mb-2">
                                    <span class="text-gray-600">Shipping</span>
                                    <span class="font-medium text-gray-900">FREE</span>
                                </div>
                                <div class="flex justify-between mb-2">
                                    <span class="text-gray-600">Tax</span>
                                    <span class="font-medium text-gray-900">Included</span>
                                </div>
                                <div class="flex justify-between font-bold text-lg mt-4 pt-4 border-t border-gray-200">
                                    <span>Total</span>
                                    <span class="text-indigo-600">RM${cartTotal}</span>
                                </div>
                            </div>
                            
                            <div class="mt-6">
                                <a href="${pageContext.request.contextPath}/customer/cart" 
                                   class="block text-center text-indigo-600 hover:text-indigo-800 transition font-medium">
                                    <i class="fas fa-arrow-left mr-2"></i> Back to Cart
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
    
    <!-- Footer -->
    <jsp:include page="../includes/footer.jsp" />
    
    <!-- Add this JavaScript at the end of the file, before </body> -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Get form and relevant elements
            const form = document.querySelector('form');
            const shippingAddressInput = document.getElementById('shippingAddress');
            const paymentCardRadio = document.getElementById('paymentCard');
            const placeOrderBtn = document.getElementById('placeOrderBtn');
            
            // Handle the submit event for the form
            form.addEventListener('submit', function(e) {
                // If shipping address is filled, store it in session storage
                if (shippingAddressInput.value) {
                    sessionStorage.setItem('shippingAddress', shippingAddressInput.value);
                }
                
                // If credit card payment is selected, prevent form submission and redirect
                if (paymentCardRadio.checked) {
                    console.log("Card payment selected - redirecting to payment page");
                    e.preventDefault();
                    window.location.href = '${pageContext.request.contextPath}/customer/payment';
                    return false;
                }
            });
            
            // Make a direct click handler for the Place Order button as well
            placeOrderBtn.addEventListener('click', function(e) {
                // If credit card is selected, redirect to payment page
                if (paymentCardRadio.checked) {
                    console.log("Button click - Card payment selected");
                    e.preventDefault();
                    
                    // Save shipping address
                    if (shippingAddressInput.value) {
                        sessionStorage.setItem('shippingAddress', shippingAddressInput.value);
                    }
                    
                    // Redirect to payment page
                    window.location.href = '${pageContext.request.contextPath}/customer/payment';
                    return false;
                }
            });
            
            // Restore shipping address from session storage if available
            const savedAddress = sessionStorage.getItem('shippingAddress');
            if (savedAddress && !shippingAddressInput.value) {
                shippingAddressInput.value = savedAddress;
            }
            
            // Check if the card payment mode is selected and update button text
            paymentCardRadio.addEventListener('change', function() {
                if (this.checked) {
                    placeOrderBtn.textContent = 'Continue to Payment';
                } else {
                    placeOrderBtn.textContent = 'Place Order';
                }
            });
        });
    </script>
</body>
</html> 