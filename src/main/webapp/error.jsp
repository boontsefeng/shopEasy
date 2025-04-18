<%@ page contentType="text/html" pageEncoding="UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShopEasy - Error Occurred</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Animate.css -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css">
    <style>
        .error-container {
            background-image: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        
        .error-box {
            backdrop-filter: blur(10px);
            background-color: rgba(255, 255, 255, 0.9);
        }
        
        @keyframes float {
            0% { transform: translateY(0px); }
            50% { transform: translateY(-20px); }
            100% { transform: translateY(0px); }
        }
        
        .float-animation {
            animation: float 6s ease-in-out infinite;
        }
    </style>
</head>
<body class="bg-gray-100 h-screen">
    <div class="error-container min-h-screen flex items-center justify-center px-4 sm:px-6 lg:px-8">
        <div class="error-box max-w-md w-full space-y-8 p-10 rounded-xl shadow-2xl animate__animated animate__fadeIn">
            <!-- Error Icon -->
            <div class="text-center">
                <div class="inline-block text-red-500 float-animation">
                    <i class="fas fa-exclamation-circle text-8xl"></i>
                </div>
                <h1 class="mt-6 text-center text-3xl font-extrabold text-gray-900 animate__animated animate__fadeInDown">
                    <i class="fas fa-shopping-cart text-indigo-600 mr-2"></i> ShopEasy
                </h1>
                
                <%
                    // Get error information
                    Integer statusCode = (Integer)request.getAttribute("jakarta.servlet.error.status_code");
                    String errorMessage = (String)request.getAttribute("jakarta.servlet.error.message");
                    String servletName = (String)request.getAttribute("jakarta.servlet.error.servlet_name");
                    String requestUri = (String)request.getAttribute("jakarta.servlet.error.request_uri");
                    
                    if (statusCode == null) {
                        statusCode = response.getStatus();
                    }
                    
                    if (errorMessage == null || errorMessage.isEmpty()) {
                        switch (statusCode) {
                            case 404:
                                errorMessage = "The page you're looking for doesn't exist.";
                                break;
                            case 500:
                                errorMessage = "Internal server error occurred.";
                                break;
                            case 403:
                                errorMessage = "Access denied - you don't have permission to access this resource.";
                                break;
                            default:
                                errorMessage = "An unexpected error occurred.";
                        }
                    }
                    
                    if (requestUri == null) {
                        requestUri = "Unknown location";
                    }
                %>
                
                <div class="mt-4 text-6xl font-bold text-red-500"><%= statusCode %></div>
                <p class="mt-2 text-center text-xl font-semibold text-gray-800">
                    Oops! Something went wrong
                </p>
            </div>
            
            <div class="bg-red-50 border-l-4 border-red-500 text-red-700 p-4 rounded animate__animated animate__fadeIn animate__delay-1s">
                <div class="flex">
                    <div class="py-1"><i class="fas fa-exclamation-triangle text-red-500 mr-3"></i></div>
                    <div>
                        <p class="font-bold">Error Details</p>
                        <p class="text-sm"><%= errorMessage %></p>
                        
                        <% if (statusCode == 404) { %>
                            <p class="text-sm mt-2">
                                <span class="font-semibold">Requested URL:</span><br/>
                                <span class="font-mono text-xs break-all"><%= requestUri %></span>
                            </p>
                        <% } %>
                        
                        <% if (statusCode == 500 && exception != null) { %>
                            <p class="text-sm mt-2">
                                <span class="font-semibold">Exception:</span><br/>
                                <span class="font-mono text-xs break-all"><%= exception.getClass().getName() %></span>
                            </p>
                        <% } %>
                    </div>
                </div>
            </div>
            
            <div class="flex flex-col items-center justify-center space-y-4 animate__animated animate__fadeIn animate__delay-2s">
                <a href="${pageContext.request.contextPath}/login" 
                   class="group relative flex justify-center py-3 px-6 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition duration-150 ease-in-out transform hover:scale-105">
                    <span class="absolute left-0 inset-y-0 flex items-center pl-3">
                        <i class="fas fa-arrow-left text-indigo-300 group-hover:text-indigo-200"></i>
                    </span>
                    Back to Login
                </a>
                
                <button onclick="window.history.back()" class="text-indigo-600 hover:text-indigo-800 text-sm">
                    <i class="fas fa-chevron-left mr-1"></i> Go Back
                </button>
            </div>
        </div>
    </div>
</body>
</html>