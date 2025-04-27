<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ include file="/view/customer/font.jsp" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShopEasy - Payment</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .cc-number-input {
            width: 100%;
            position: relative;
        }
        
        .cc-number-input input {
            padding-left: 3.5rem;
        }
        
        .cc-icon {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            height: 24px;
        }
        
        .card-brand {
            width: 38px;
            height: 24px;
            display: inline-block;
            background-size: contain;
            background-repeat: no-repeat;
            background-position: center;
            margin-right: 8px;
        }
        
        .visa {
            background-image: url('https://raw.githubusercontent.com/aaronfagan/svg-credit-card-payment-icons/master/flat-rounded/visa.svg');
        }
        
        .mastercard {
            background-image: url('https://raw.githubusercontent.com/aaronfagan/svg-credit-card-payment-icons/master/flat-rounded/mastercard.svg');
        }
        
        .amex {
            background-image: url('https://raw.githubusercontent.com/aaronfagan/svg-credit-card-payment-icons/master/flat-rounded/amex.svg');
        }
        
        .maestro {
            background-image: url('https://raw.githubusercontent.com/aaronfagan/svg-credit-card-payment-icons/master/flat-rounded/maestro.svg');
        }
        
        .check-mark {
            width: 20px;
            height: 20px;
            background-color: #10b981;
            color: white;
            border-radius: 9999px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-left: auto;
            font-size: 0.75rem;
        }
    </style>
</head>
<body class="bg-gray-100">
    <!-- Navigation -->
    <jsp:include page="../includes/customer-nav.jsp" />
    
    <!-- Main Content -->
    <main class="container mx-auto px-4 py-8">
        <!-- Page Header -->
        <div class="flex items-center mb-8">
            <h1 class="text-3xl font-bold text-gray-800">Payment Gateway Integration</h1>
        </div>
        
        <div class="bg-white rounded-lg shadow-lg overflow-hidden mb-8 max-w-4xl mx-auto">
            <div class="p-6 md:p-8">
                <!-- Payment Method Selection -->
                <div class="mb-8">
                    <h2 class="text-2xl font-bold mb-6 text-center">Payment Method</h2>
                    
                    <div class="bg-gray-50 rounded-lg p-8">
                        <!-- Credit/Debit Card Form -->
                        <div class="mb-6">
                            <div class="flex items-center mb-4">
                                <h3 class="text-xl font-bold text-gray-800 uppercase">Credit / Debit Card</h3>
                                <div class="ml-auto flex space-x-2">
                                    <span class="card-brand visa"></span>
                                    <span class="card-brand mastercard"></span>
                                    <span class="card-brand amex"></span>
                                    <span class="card-brand maestro"></span>
                                </div>
                            </div>
                            <p class="text-gray-500 mb-6">You may be directed to your bank's 3D secure process to authenticate your information.</p>
                            
                            <form id="paymentForm" action="${pageContext.request.contextPath}/customer/payment/process" method="post">
                                <!-- Hidden shipping address field -->
                                <input type="hidden" id="shippingAddress" name="shippingAddress" value="${shippingAddress}">
                                
                                <!-- Card Number -->
                                <div class="mb-6">
                                    <label for="cardNumber" class="block text-sm font-medium text-gray-600 mb-1">Card number</label>
                                    <div class="cc-number-input">
                                        <span class="cc-icon" id="cardIcon">
                                            <i class="fa-regular fa-credit-card text-gray-400"></i>
                                        </span>
                                        <input type="text" id="cardNumber" name="cardNumber" 
                                            class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
                                            placeholder="5*** **** **** 6789"
                                            pattern="[0-9 ]+"
                                            maxlength="19"
                                            required>
                                    </div>
                                </div>
                                
                                <div class="grid grid-cols-2 gap-4">
                                    <!-- Expiry Date -->
                                    <div class="mb-6">
                                        <label for="expiryDate" class="block text-sm font-medium text-gray-600 mb-1">Expiry date</label>
                                        <div class="relative">
                                            <input type="text" id="expiryDate" name="expiryDate" 
                                                class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
                                                placeholder="MM/YY"
                                                pattern="[0-9/]+"
                                                maxlength="5"
                                                required>
                                            <div class="check-mark absolute right-3 top-1/2 transform -translate-y-1/2 hidden" id="expiryCheck">
                                                <i class="fas fa-check"></i>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <!-- CVC/CVV -->
                                    <div class="mb-6">
                                        <label for="cvv" class="block text-sm font-medium text-gray-600 mb-1">CVC / CVV</label>
                                        <div class="relative">
                                            <input type="text" id="cvv" name="cvv" 
                                                class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
                                                placeholder="345"
                                                pattern="[0-9]+"
                                                maxlength="4"
                                                required>
                                            <div class="check-mark absolute right-3 top-1/2 transform -translate-y-1/2 hidden" id="cvvCheck">
                                                <i class="fas fa-check"></i>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                
                                <!-- Name on Card -->
                                <div class="mb-8">
                                    <label for="nameOnCard" class="block text-sm font-medium text-gray-600 mb-1">Name on card</label>
                                    <div class="relative">
                                        <input type="text" id="nameOnCard" name="nameOnCard" 
                                            class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
                                            placeholder="Samanta Smith"
                                            required>
                                        <div class="check-mark absolute right-3 top-1/2 transform -translate-y-1/2 hidden" id="nameCheck">
                                            <i class="fas fa-check"></i>
                                        </div>
                                    </div>
                                </div>
                                
                                <!-- Order Summary -->
                                <div class="mt-8 border-t border-gray-200 pt-6">
                                    <h3 class="text-lg font-semibold mb-4">Order Summary</h3>
                                    <div class="flex justify-between mb-2">
                                        <span class="text-gray-600">Subtotal</span>
                                        <span class="font-medium">RM${cartTotal}</span>
                                    </div>
                                    <div class="flex justify-between mb-2">
                                        <span class="text-gray-600">Shipping</span>
                                        <span class="font-medium">FREE</span>
                                    </div>
                                    <div class="flex justify-between mb-2">
                                        <span class="text-gray-600">Tax (6% GST)</span>
                                        <span class="font-medium">RM${cartTotal * 0.06}</span>
                                    </div>
                                    <div class="flex justify-between font-bold text-lg mt-4 pt-4 border-t border-gray-200">
                                        <span>Total</span>
                                        <span class="text-indigo-600">RM${cartTotal * 1.06}</span>
                                    </div>
                                </div>
                                
                                <!-- Submit Button -->
                                <div class="mt-6">
                                    <button type="submit" 
                                            class="w-full bg-indigo-600 text-white py-4 px-4 rounded-lg font-medium hover:bg-indigo-700 transition">
                                        Pay RM${cartTotal * 1.06}
                                    </button>
                                    <p class="text-center text-gray-500 text-xs mt-4">
                                        Your payment will be processed securely. Your card details will not be stored.
                                    </p>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
    
    <!-- Footer -->
    <jsp:include page="../includes/footer.jsp" />
    
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            console.log("Payment page loaded");
            
            const cardNumberInput = document.getElementById('cardNumber');
            const expiryDateInput = document.getElementById('expiryDate');
            const cvvInput = document.getElementById('cvv');
            const nameOnCardInput = document.getElementById('nameOnCard');
            const cardIcon = document.getElementById('cardIcon');
            const expiryCheck = document.getElementById('expiryCheck');
            const cvvCheck = document.getElementById('cvvCheck');
            const nameCheck = document.getElementById('nameCheck');
            const shippingAddressInput = document.getElementById('shippingAddress');
            
            console.log("Current shipping address:", shippingAddressInput.value);
            
            // If shipping address is not set in the form, try to get it from session storage
            if (!shippingAddressInput.value) {
                const savedAddress = sessionStorage.getItem('shippingAddress');
                if (savedAddress) {
                    console.log("Got shipping address from session storage:", savedAddress);
                    shippingAddressInput.value = savedAddress;
                } else {
                    console.log("No shipping address found in session storage");
                }
            }
            
            // Demo test value for card number if needed
            // Uncomment for testing
            // cardNumberInput.value = "5555 5555 5555 4444";
            // expiryDateInput.value = "12/25";
            // cvvInput.value = "123";
            // nameOnCardInput.value = "Test User";
            
            // Format card number with spaces
            cardNumberInput.addEventListener('input', function(e) {
                let value = this.value.replace(/\D/g, '');
                let formattedValue = '';
                
                for (let i = 0; i < value.length; i++) {
                    if (i > 0 && i % 4 === 0) {
                        formattedValue += ' ';
                    }
                    formattedValue += value[i];
                }
                
                this.value = formattedValue;
                
                // Change card icon based on card type
                if (value.startsWith('4')) {
                    cardIcon.innerHTML = '<span class="card-brand visa"></span>';
                } else if (value.startsWith('5')) {
                    cardIcon.innerHTML = '<span class="card-brand mastercard"></span>';
                } else if (value.startsWith('3')) {
                    cardIcon.innerHTML = '<span class="card-brand amex"></span>';
                } else if (value.startsWith('6')) {
                    cardIcon.innerHTML = '<span class="card-brand maestro"></span>';
                } else {
                    cardIcon.innerHTML = '<i class="fa-regular fa-credit-card text-gray-400"></i>';
                }
            });
            
            // Format expiry date MM/YY
            expiryDateInput.addEventListener('input', function(e) {
                let value = this.value.replace(/\D/g, '');
                
                if (value.length > 2) {
                    this.value = value.substring(0, 2) + '/' + value.substring(2);
                } else {
                    this.value = value;
                }
                
                // Show check mark if valid
                if (/^(0[1-9]|1[0-2])\/([0-9]{2})$/.test(this.value)) {
                    expiryCheck.classList.remove('hidden');
                } else {
                    expiryCheck.classList.add('hidden');
                }
            });
            
            // Show check mark for CVV when valid
            cvvInput.addEventListener('input', function() {
                if (this.value.length >= 3 && /^\d+$/.test(this.value)) {
                    cvvCheck.classList.remove('hidden');
                } else {
                    cvvCheck.classList.add('hidden');
                }
            });
            
            // Show check mark for name when valid
            nameOnCardInput.addEventListener('input', function() {
                if (this.value.length > 3 && /^[A-Za-z\s]+$/.test(this.value)) {
                    nameCheck.classList.remove('hidden');
                } else {
                    nameCheck.classList.add('hidden');
                }
            });
            
            // Form submission
            document.getElementById('paymentForm').addEventListener('submit', function(e) {
                // For demo purposes, we're accepting any valid-looking input
                // In a real implementation, you would validate through a payment gateway
                
                console.log("Payment form submitted");
                
                // Save shipping address in session storage
                if (shippingAddressInput.value) {
                    console.log("Saving shipping address to session storage:", shippingAddressInput.value);
                    sessionStorage.setItem('shippingAddress', shippingAddressInput.value);
                } else {
                    console.error("No shipping address to save!");
                    e.preventDefault();
                    alert("Please go back and enter a shipping address before proceeding.");
                    return false;
                }
            });
        });
    </script>
</body>
</html> 