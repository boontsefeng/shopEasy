<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShopEasy - Login</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Add animate.css for animations -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');

        body, html {
            font-family: 'Poppins', sans-serif
        }

        * {
            font-family: 'Poppins', sans-serif
        }
        .login-container {
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
    </style>
</head>
<body class="bg-gray-100 h-screen">
    <div class="login-container min-h-screen flex items-center justify-center px-4 sm:px-6 lg:px-8">
        <div class="form-container max-w-md w-full space-y-8 p-10 rounded-xl shadow-2xl animated-form">
            <div class="text-center">
                <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900 animate__animated animate__fadeInDown">
                    <i class="fas fa-shopping-cart text-indigo-600"></i> ShopEasy
                </h2>
                <p class="mt-2 text-center text-sm text-gray-600 animate__animated animate__fadeIn animate__delay-1s">
                    Sign in to your account
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
            
            <form class="mt-8 space-y-6" action="login" method="POST">
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
                               class="appearance-none rounded-none relative block w-full pl-10 px-3 py-3 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-b-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm" 
                               placeholder="Password">
                    </div>
                </div>

                <div>
                    <button type="submit" 
                            class="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition duration-150 ease-in-out transform hover:scale-105">
                        <span class="absolute left-0 inset-y-0 flex items-center pl-3">
                            <i class="fas fa-sign-in-alt text-indigo-300 group-hover:text-indigo-200"></i>
                        </span>
                        Sign in
                    </button>
                </div>
                
                <div class="flex items-center justify-between">
                    <div class="text-sm">
                        <a href="register" class="font-medium text-indigo-600 hover:text-indigo-500 transition-colors">
                            Don't have an account? Register
                        </a>
                    </div>
                    <div class="text-sm">
                        <a href="#" id="forgotPasswordLink" class="font-medium text-indigo-600 hover:text-indigo-500 transition-colors">
                            Forgot password?
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
            
            // Forgot password link handler - pass the username to the forgot password page
            const forgotPasswordLink = document.getElementById('forgotPasswordLink');
            if (forgotPasswordLink) {
                forgotPasswordLink.addEventListener('click', function(e) {
                    e.preventDefault();
                    const username = document.getElementById('username').value;
                    window.location.href = 'forgotPassword' + (username ? '?username=' + encodeURIComponent(username) : '');
                });
            }
        });
    </script>
</body>
</html>