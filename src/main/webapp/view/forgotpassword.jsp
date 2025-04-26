<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShopEasy - Password Recovery</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Add animate.css for animations -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css">
    <style>
        .recovery-container {
            background-image: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        
        .form-container {
            backdrop-filter: blur(10px);
            background-color: rgba(255, 255, 255, 0.9);
        }
        
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translate3d(0, 40px, 0);
            }
            to {
                opacity: 1;
                transform: translate3d(0, 0, 0);
            }
        }
        
        .animated-form {
            animation: fadeInUp 0.5s ease-out;
        }
        
        .password-strength {
            font-size: 0.8rem;
            margin-top: 0.25rem;
            display: flex;
            flex-direction: column;
            gap: 0.25rem;
        }

        .requirement {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .requirement i.valid {
            color: #10B981;
        }

        .requirement i.invalid {
            color: #EF4444;
        }
    </style>
</head>
<body class="bg-gray-100 h-screen">
    <div class="recovery-container min-h-screen flex items-center justify-center px-4 sm:px-6 lg:px-8">
        <div class="form-container max-w-md w-full space-y-8 p-10 rounded-xl shadow-2xl animated-form">
            <div class="text-center">
                <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900 animate__animated animate__fadeInDown">
                    <i class="fas fa-shopping-cart text-indigo-600"></i> ShopEasy
                </h2>
                <p class="mt-2 text-center text-sm text-gray-600 animate__animated animate__fadeIn animate__delay-1s">
                    Reset Your Password
                </p>
            </div>
            
            <% if (request.getAttribute("error") != null) { %>
                <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 rounded animate__animated animate__headShake" role="alert">
                    <p class="font-bold">Error</p>
                    <p><%= request.getAttribute("error") %></p>
                </div>
            <% } %>
            
            <% if (request.getAttribute("success") != null) { %>
                <div class="bg-green-100 border-l-4 border-green-500 text-green-700 p-4 rounded animate__animated animate__bounceIn" role="alert">
                    <div class="flex items-center">
                        <div class="py-1">
                            <svg class="animate__animated animate__swing animate__delay-1s animate__infinite" 
                                xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" 
                                stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
                                <polyline points="22 4 12 14.01 9 11.01"></polyline>
                            </svg>
                        </div>
                        <div class="ml-3">
                            <p class="font-bold">Success!</p>
                            <p><%= request.getAttribute("success") %></p>
                        </div>
                    </div>
                </div>
            <% } %>

            <%-- Step 1: Enter Phone Number --%>
            <% String step = request.getParameter("step"); 
               if (step == null || step.equals("1") || step.equals("")) { %>
                <form id="phoneForm" class="mt-8 space-y-6" action="forgotPassword" method="POST">
                    <input type="hidden" name="action" value="sendOTP">
                    <input type="hidden" name="username" value="<%= request.getParameter("username") %>">
                    
                    <div class="mb-4">
                        <label for="phoneNumber" class="block text-sm font-medium text-gray-700 mb-2">Enter your number</label>
                        <div class="flex">
                            <div class="w-16">
                                <select id="countryCode" name="countryCode" class="appearance-none rounded-l-md relative block w-full px-2 py-3 border border-gray-300 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
                                    <option value="60">+60</option>
                                    <option value="65">+65</option>
                                    <option value="62">+62</option>
                                    <option value="66">+66</option>
                                    <option value="63">+63</option>
                                    <option value="84">+84</option>
                                    <option value="95">+95</option>
                                    <option value="856">+856</option>
                                    <option value="855">+855</option>
                                    <option value="673">+673</option>
                                    <option value="1">+1</option>
                                    <option value="44">+44</option>
                                    <option value="86">+86</option>
                                    <option value="91">+91</option>
                                    <option value="81">+81</option>
                                    <option value="82">+82</option>
                                    <option value="61">+61</option>
                                </select>
                            </div>
                            <div class="flex-1">
                                <input id="phoneNumber" name="phoneNumber" type="text" required 
                                       class="appearance-none rounded-r-md relative block w-full px-3 py-3 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm" 
                                       placeholder="Phone number">
                            </div>
                        </div>
                    </div>
                    
                    <div>
                        <button type="submit" 
                                class="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition duration-150 ease-in-out">
                            <span class="absolute left-0 inset-y-0 flex items-center pl-3">
                                <i class="fas fa-paper-plane text-indigo-300 group-hover:text-indigo-200"></i>
                            </span>
                            Send OTP
                        </button>
                    </div>
                    
                    <div class="flex items-center justify-between">
                        <div class="text-sm">
                            <a href="login" class="font-medium text-indigo-600 hover:text-indigo-500 transition-colors">
                                Back to login
                            </a>
                        </div>
                    </div>
                </form>
            <% } %>

            <%-- Step 2: Verify OTP --%>
            <% if (step != null && step.equals("2")) { 
                String phoneNumber = (String) request.getAttribute("phoneNumber");
            %>
                <form id="otpForm" class="mt-8 space-y-6" action="forgotPassword" method="POST">
                    <input type="hidden" name="action" value="verifyOTP">
                    <input type="hidden" name="phoneNumber" value="<%= phoneNumber %>">
                    <input type="hidden" name="username" value="<%= request.getAttribute("username") %>">
                    
                    <div class="text-center mb-4">
                        <div class="text-xl font-semibold mb-2">Enter OTP</div>
                        <p class="text-sm text-gray-600">
                            We've sent a one-time password to your phone
                            <br><span class="font-medium"><%= phoneNumber %></span>
                        </p>
                        <div class="mt-2 text-sm text-gray-600">
                            Time remaining: <span id="timer" class="font-bold text-red-500">60</span> seconds
                        </div>
                    </div>
                    
                    <div class="rounded-md shadow-sm">
                        <div class="relative">
                            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <i class="fas fa-key text-gray-400"></i>
                            </div>
                            <input id="otp" name="otp" type="text" required 
                                   class="appearance-none rounded-md relative block w-full pl-10 px-3 py-3 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm" 
                                   placeholder="Enter OTP">
                        </div>
                    </div>
                    
                    <div>
                        <button id="verifyBtn" type="submit" 
                                class="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition duration-150 ease-in-out transform hover:scale-105">
                            <span class="absolute left-0 inset-y-0 flex items-center pl-3">
                                <i class="fas fa-check text-indigo-300 group-hover:text-indigo-200"></i>
                            </span>
                            Verify OTP
                        </button>
                    </div>
                    
                    <div class="flex items-center justify-between">
                        <div class="text-sm">
                            <a href="forgotPassword" class="font-medium text-indigo-600 hover:text-indigo-500 transition-colors">
                                Try with a different number
                            </a>
                        </div>
                        <div class="text-sm">
                            <button id="resendBtn" type="button" disabled
                                    class="font-medium text-gray-400 cursor-not-allowed transition-colors">
                                Resend OTP (<span id="resendTimer">60</span>s)
                            </button>
                        </div>
                    </div>
                </form>
            <% } %>

            <%-- Step 3: Reset Password --%>
            <% if (step != null && step.equals("3")) { 
                String phoneNumber = (String) request.getAttribute("phoneNumber");
            %>
                <form id="resetForm" class="mt-8 space-y-6" action="forgotPassword" method="POST">
                    <input type="hidden" name="action" value="resetPassword">
                    <input type="hidden" name="phoneNumber" value="<%= phoneNumber %>">
                    <input type="hidden" name="username" value="<%= request.getAttribute("username") %>">
                    
                    <div class="rounded-md shadow-sm -space-y-px">
                        <div class="relative">
                            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <i class="fas fa-lock text-gray-400"></i>
                            </div>
                            <input id="newPassword" name="newPassword" type="password" required 
                                   class="appearance-none rounded-t-md relative block w-full pl-10 px-3 py-3 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm" 
                                   placeholder="New Password">
                        </div>
                        
                        <!-- Password requirements display -->
                        <div class="password-strength px-3 py-2 bg-gray-50 border border-gray-300">
                            <div class="requirement" id="length-check">
                                <i class="fas fa-times-circle text-red-500"></i>
                                <span>At least 8 characters</span>
                            </div>
                            <div class="requirement" id="uppercase-check">
                                <i class="fas fa-times-circle text-red-500"></i>
                                <span>At least one uppercase letter</span>
                            </div>
                            <div class="requirement" id="special-check">
                                <i class="fas fa-times-circle text-red-500"></i>
                                <span>At least one special character</span>
                            </div>
                        </div>
                        
                        <div class="relative">
                            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <i class="fas fa-lock text-gray-400"></i>
                            </div>
                            <input id="confirmPassword" name="confirmPassword" type="password" required 
                                   class="appearance-none rounded-b-md relative block w-full pl-10 px-3 py-3 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm" 
                                   placeholder="Confirm Password">
                        </div>
                    </div>
                    
                    <div>
                        <button type="submit" 
                                class="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition duration-150 ease-in-out transform hover:scale-105">
                            <span class="absolute left-0 inset-y-0 flex items-center pl-3">
                                <i class="fas fa-save text-indigo-300 group-hover:text-indigo-200"></i>
                            </span>
                            Reset Password
                        </button>
                    </div>
                </form>
            <% } %>
        </div>
    </div>
 
    <!-- Timer and validation scripts -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const formContainer = document.querySelector('.form-container');
            formContainer.classList.add('animate__animated', 'animate__fadeIn');
            
            // OTP Timer functionality
            const timerElement = document.getElementById('timer');
            const resendTimerElement = document.getElementById('resendTimer');
            const resendBtn = document.getElementById('resendBtn');
            
            if (timerElement && resendBtn) {
                let timeLeft = 60;
                
                const countdown = setInterval(() => {
                    timeLeft--;
                    
                    if (timerElement) timerElement.textContent = timeLeft;
                    if (resendTimerElement) resendTimerElement.textContent = timeLeft;
                    
                    if (timeLeft <= 0) {
                        clearInterval(countdown);
                        if (resendBtn) {
                            resendBtn.classList.remove('text-gray-400', 'cursor-not-allowed');
                            resendBtn.classList.add('text-indigo-600', 'hover:text-indigo-500');
                            resendBtn.disabled = false;
                            resendBtn.textContent = 'Resend OTP';
                        }
                    }
                }, 1000);
                
                // Resend OTP handler
                if (resendBtn) {
                    resendBtn.addEventListener('click', function() {
                        if (!this.disabled) {
                            const phoneForm = document.createElement('form');
                            phoneForm.method = 'POST';
                            phoneForm.action = 'forgotPassword';
                            
                            const actionInput = document.createElement('input');
                            actionInput.type = 'hidden';
                            actionInput.name = 'action';
                            actionInput.value = 'sendOTP';
                            
                            const phoneInput = document.createElement('input');
                            phoneInput.type = 'hidden';
                            phoneInput.name = 'phoneNumber';
                            phoneInput.value = '<%= request.getAttribute("phoneNumber") %>';
                            
                            const usernameInput = document.createElement('input');
                            usernameInput.type = 'hidden';
                            usernameInput.name = 'username';
                            usernameInput.value = '<%= request.getAttribute("username") %>';
                            
                            phoneForm.appendChild(actionInput);
                            phoneForm.appendChild(phoneInput);
                            phoneForm.appendChild(usernameInput);
                            document.body.appendChild(phoneForm);
                            phoneForm.submit();
                        }
                    });
                }
            }
            
            // Password validation functionality
            const newPassword = document.getElementById('newPassword');
            const confirmPassword = document.getElementById('confirmPassword');
            
            if (newPassword) {
                // Password requirement check elements
                const lengthCheck = document.getElementById('length-check').querySelector('i');
                const uppercaseCheck = document.getElementById('uppercase-check').querySelector('i');
                const specialCheck = document.getElementById('special-check').querySelector('i');
                
                // Initial state
                let passwordValid = false;
                
                function validatePassword() {
                    const value = newPassword.value;
                    
                    // Check length
                    const lengthValid = value.length >= 8;
                    updateIcon(lengthCheck, lengthValid);
                    
                    // Check uppercase
                    const uppercaseValid = /[A-Z]/.test(value);
                    updateIcon(uppercaseCheck, uppercaseValid);
                    
                    // Check special character
                    const specialValid = /[!@#$%^&*(),.?":{}|<>]/.test(value);
                    updateIcon(specialCheck, specialValid);
                    
                    // Overall validity
                    passwordValid = lengthValid && uppercaseValid && specialValid;
                    
                    // Update UI based on requirements
                    if (passwordValid) {
                        newPassword.classList.remove('border-red-300');
                        newPassword.classList.add('border-green-300');
                    } else {
                        newPassword.classList.remove('border-green-300');
                        newPassword.classList.add('border-red-300');
                    }
                }
                
                function updateIcon(iconElement, isValid) {
                    if (isValid) {
                        iconElement.classList.remove('fa-times-circle', 'invalid');
                        iconElement.classList.add('fa-check-circle', 'valid');
                    } else {
                        iconElement.classList.remove('fa-check-circle', 'valid');
                        iconElement.classList.add('fa-times-circle', 'invalid');
                    }
                }
                
                function checkPasswordMatch() {
                    if (confirmPassword.value === '') {
                        confirmPassword.setCustomValidity('');
                        return;
                    }
                    
                    if (newPassword.value !== confirmPassword.value) {
                        confirmPassword.setCustomValidity('Passwords do not match');
                        confirmPassword.classList.remove('border-green-300');
                        confirmPassword.classList.add('border-red-300');
                    } else {
                        confirmPassword.setCustomValidity('');
                        confirmPassword.classList.remove('border-red-300');
                        confirmPassword.classList.add('border-green-300');
                    }
                }
                
                // Event listeners
                newPassword.addEventListener('input', validatePassword);
                newPassword.addEventListener('change', checkPasswordMatch);
                confirmPassword.addEventListener('input', checkPasswordMatch);
            }
            
            // Password reset form validation
            const resetForm = document.getElementById('resetForm');
            if (resetForm) {
                resetForm.addEventListener('submit', function(e) {
                    const newPassword = document.getElementById('newPassword').value;
                    const confirmPassword = document.getElementById('confirmPassword').value;
                    
                    // Check password requirements
                    const lengthValid = newPassword.length >= 8;
                    const uppercaseValid = /[A-Z]/.test(newPassword);
                    const specialValid = /[!@#$%^&*(),.?":{}|<>]/.test(newPassword);
                    
                    if (!lengthValid || !uppercaseValid || !specialValid) {
                        e.preventDefault();
                        alert('Password must be at least 8 characters long, include at least one uppercase letter, and one special character.');
                        return false;
                    }
                    
                    if (newPassword !== confirmPassword) {
                        e.preventDefault();
                        alert('Passwords do not match!');
                        return false;
                    }
                    
                    if (newPassword.length < 8) {
                        e.preventDefault();
                        alert('Password must be at least 8 characters long!');
                        return false;
                    }
                });
            }
        });
    </script>
</body>
</html>