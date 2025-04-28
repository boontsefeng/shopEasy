<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShopEasy - Register</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Add animate.css for animations -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');

        body, html {
            font-family: 'Poppins', sans-serifa
        }

        * {
            font-family: 'Poppins', sans-serif
        }
        .register-container {
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
            margin-top: 0.5rem;
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
    <div class="register-container min-h-screen flex items-center justify-center px-4 sm:px-6 lg:px-8">
        <div class="form-container max-w-md w-full space-y-8 p-10 rounded-xl shadow-2xl animated-form my-10">
            <div class="text-center">
                <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900 animate__animated animate__fadeInDown">
                    <i class="fas fa-shopping-cart text-indigo-600"></i> ShopEasy
                </h2>
                <p class="mt-2 text-center text-sm text-gray-600 animate__animated animate__fadeIn animate__delay-1s">
                    Create a new account
                </p>
            </div>
            
            <% if (request.getAttribute("error") != null) { %>
                <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 rounded animate__animated animate__headShake" role="alert">
                    <p class="font-bold">Error</p>
                    <p><%= request.getAttribute("error") %></p>
                </div>
            <% } %>
            
            <form class="mt-8 space-y-6" action="${pageContext.request.contextPath}/register" method="POST" onsubmit="return validateForm()">
                <div class="rounded-md shadow-sm -space-y-px">
                    <div class="relative">
                        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                            <i class="fas fa-user text-gray-400"></i>
                        </div>
                        <input id="username" name="username" type="text" required 
                               class="appearance-none rounded-none relative block w-full pl-10 px-3 py-3 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-t-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm" 
                               placeholder="Username">
                    </div>
                    <div class="relative">
                        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                            <i class="fas fa-lock text-gray-400"></i>
                        </div>
                        <input id="password" name="password" type="password" required 
                               class="appearance-none rounded-none relative block w-full pl-10 px-3 py-3 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm" 
                               placeholder="Password">
                    </div>
                    <!-- Password requirements display -->
                    <div class="password-strength px-3 py-2 bg-gray-50 border border-gray-300">
                        <div class="requirement" id="length-check">
                            <i class="fas fa-times-circle invalid"></i>
                            <span>At least 8 characters</span>
                        </div>
                        <div class="requirement" id="uppercase-check">
                            <i class="fas fa-times-circle invalid"></i>
                            <span>At least one uppercase letter</span>
                        </div>
                        <div class="requirement" id="special-check">
                            <i class="fas fa-times-circle invalid"></i>
                            <span>At least one special character</span>
                        </div>
                    </div>
                    <div class="relative">
                        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                            <i class="fas fa-lock text-gray-400"></i>
                        </div>
                        <input id="confirmPassword" name="confirmPassword" type="password" required 
                               class="appearance-none rounded-none relative block w-full pl-10 px-3 py-3 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm" 
                               placeholder="Confirm Password">
                    </div>
                    <div class="relative">
                        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                            <i class="fas fa-user-tag text-gray-400"></i>
                        </div>
                        <input id="name" name="name" type="text" required 
                               class="appearance-none rounded-none relative block w-full pl-10 px-3 py-3 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm" 
                               placeholder="Full Name">
                    </div>
                    <div class="relative">
                        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                            <i class="fas fa-envelope text-gray-400"></i>
                        </div>
                        <input id="email" name="email" type="email" required 
                               class="appearance-none rounded-none relative block w-full pl-10 px-3 py-3 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm" 
                               placeholder="Email Address">
                    </div>
                    <div class="relative">
                        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                            <i class="fas fa-phone text-gray-400"></i>
                        </div>
                        <input id="contactNumber" name="contactNumber" type="text" required 
                               class="appearance-none rounded-none relative block w-full pl-10 px-3 py-3 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm" 
                               placeholder="Contact Number">
                    </div>
                    <div class="relative">
                        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                            <i class="fas fa-key text-gray-400"></i>
                        </div>
                        <input id="registrationKey" name="registrationKey" type="text"
                               class="appearance-none rounded-none relative block w-full pl-10 px-3 py-3 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-b-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm" 
                               placeholder="Registration Key (Optional)">
                    </div>
                </div>

                <div>
                    <button type="submit" id="registerButton"
                            class="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition duration-150 ease-in-out transform hover:scale-105">
                        <span class="absolute left-0 inset-y-0 flex items-center pl-3">
                            <i class="fas fa-user-plus text-indigo-300 group-hover:text-indigo-200"></i>
                        </span>
                        Register
                    </button>
                </div>
                
                <div class="flex items-center justify-between">
                    <div class="text-sm">
                        <a href="login" class="font-medium text-indigo-600 hover:text-indigo-500 transition-colors">
                            Already have an account? Sign in
                        </a>
                    </div>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Add some animation when page loads -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const formContainer = document.querySelector('.form-container');
            formContainer.classList.add('animate__animated', 'animate__fadeIn');
            
            // Get elements
            const password = document.getElementById('password');
            const confirmPassword = document.getElementById('confirmPassword');
            const registerButton = document.getElementById('registerButton');
            
            // Password requirement check elements
            const lengthCheck = document.getElementById('length-check').querySelector('i');
            const uppercaseCheck = document.getElementById('uppercase-check').querySelector('i');
            const specialCheck = document.getElementById('special-check').querySelector('i');
            
            // Initial state
            let passwordValid = false;
            
            function validatePassword() {
                const value = password.value;
                
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
                    password.classList.remove('border-red-300');
                    password.classList.add('border-green-300');
                } else {
                    password.classList.remove('border-green-300');
                    password.classList.add('border-red-300');
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
                
                if (password.value !== confirmPassword.value) {
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
            password.addEventListener('input', validatePassword);
            password.addEventListener('change', checkPasswordMatch);
            confirmPassword.addEventListener('input', checkPasswordMatch);
        });
        
        // Form validation function
        function validateForm() {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            
            // Check password requirements
            const lengthValid = password.length >= 8;
            const uppercaseValid = /[A-Z]/.test(password);
            const specialValid = /[!@#$%^&*(),.?":{}|<>]/.test(password);
            
            if (!lengthValid || !uppercaseValid || !specialValid) {
                alert('Password must be at least 8 characters long, include at least one uppercase letter, and one special character.');
                return false;
            }
            
            if (password !== confirmPassword) {
                alert('Passwords do not match. Please try again.');
                return false;
            }
            
            return true;
        }
    </script>
</body>
</html>