<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    // Get the section parameter to determine which part to render
    String section = request.getParameter("section");
    boolean isHeader = "header".equals(section) || section == null;
    boolean isFooter = "footer".equals(section) || section == null;
    
    // Get user details from session (only needed for header)
    if (isHeader) {
        com.shopeasy.shopeasy.model.User currentUser = (com.shopeasy.shopeasy.model.User) session.getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String userRole = currentUser.getRole();
        String userName = currentUser.getName();
        int userId = currentUser.getUserId();
        
        // Check if user is allowed to access admin pages
        if (!"manager".equals(userRole) && !"staff".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        pageContext.setAttribute("userRole", userRole);
        pageContext.setAttribute("userName", userName);
        pageContext.setAttribute("userId", userId);
    }
%>

<% if (isHeader) { %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShopEasy - Admin Dashboard</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Add animate.css for animations -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css">
        <!-- Add Poppins Font -->
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');

        body, html {
            font-family: 'Poppins', sans-serif
        }

        * {
            font-family: 'Poppins', sans-serif
        }
    </style>
    <style>
    
        .sidebar {
            transition: all 0.3s ease-in-out;
        }
        
        @media (max-width: 768px) {
            .sidebar {
                transform: translateX(-100%);
            }
            .sidebar.active {
                transform: translateX(0);
            }
        }
        
        .nav-item {
            transition: all 0.2s ease;
        }
        
        .nav-item:hover {
            transform: translateX(5px);
        }
        
        .page-transition {
            animation: fadeIn 0.5s ease-in-out;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
    </style>
</head>
<body class="bg-gray-100 min-h-screen">
    <!-- Mobile Header -->
    <div class="md:hidden bg-indigo-600 text-white py-4 px-6 flex justify-between items-center">
        <div class="flex items-center">
            <i class="fas fa-shopping-cart text-2xl mr-2"></i>
            <h1 class="text-xl font-bold">ShopEasy</h1>
        </div>
        <button id="sidebarToggle" class="text-white focus:outline-none">
            <i class="fas fa-bars text-2xl"></i>
        </button>
    </div>

    <div class="flex h-screen pt-0 md:pt-0">
        <!-- Sidebar -->
        <div id="sidebar" class="sidebar bg-indigo-800 text-white w-64 space-y-6 py-7 px-2 absolute inset-y-0 left-0 transform md:relative md:translate-x-0 z-20 shadow-lg">
            <div class="flex items-center justify-between px-4">
                <div class="flex items-center space-x-2">
                    <i class="fas fa-shopping-cart text-2xl"></i>
                    <span class="text-2xl font-semibold">ShopEasy</span>
                </div>
                <button id="closeSidebar" class="md:hidden focus:outline-none">
                    <i class="fas fa-times text-2xl"></i>
                </button>
            </div>
            
            <nav class="mt-10">
                <div class="px-4 py-2 text-gray-300 uppercase text-xs font-semibold">
                    Main
                </div>
                
                <a href="${pageContext.request.contextPath}/dashboard" class="nav-item block py-2.5 px-4 rounded transition duration-200 hover:bg-indigo-700 flex items-center">
                    <i class="fas fa-home w-6"></i>
                    <span>Dashboard</span>
                </a>
                
                <a href="${pageContext.request.contextPath}/products" class="nav-item block py-2.5 px-4 rounded transition duration-200 hover:bg-indigo-700 flex items-center">
                    <i class="fas fa-box w-6"></i>
                    <span>Products</span>
                </a>
                
                <c:if test="${userRole == 'manager'}">
                    <div class="px-4 py-2 text-gray-300 uppercase text-xs font-semibold mt-6">
                        Management
                    </div>
                    
                    <a href="${pageContext.request.contextPath}/manager/staff" class="nav-item block py-2.5 px-4 rounded transition duration-200 hover:bg-indigo-700 flex items-center">
                        <i class="fas fa-users w-6"></i>
                        <span>Staff Management</span>
                    </a>
                    
                    <a href="${pageContext.request.contextPath}/manager/customers" class="nav-item block py-2.5 px-4 rounded transition duration-200 hover:bg-indigo-700 flex items-center">
                        <i class="fas fa-user-friends w-6"></i>
                        <span>Customer Management</span>
                    </a>
                    
                    <a href="${pageContext.request.contextPath}/manager/keys" class="nav-item block py-2.5 px-4 rounded transition duration-200 hover:bg-indigo-700 flex items-center">
                        <i class="fas fa-key w-6"></i>
                        <span>Registration Keys</span>
                    </a>
                </c:if>
            </nav>
            
            <div class="absolute bottom-0 w-full left-0 px-4 py-6">
                <div class="flex items-center px-4 py-2 text-gray-300">
                    <i class="fas fa-user-circle text-2xl mr-2"></i>
                    <div>
                        <div class="text-sm font-medium">${userName}</div>
                        <div class="text-xs">${userRole}</div>
                    </div>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="block w-full text-center py-2 px-4 bg-red-600 hover:bg-red-700 rounded text-white mt-2 transition duration-200">
                    <i class="fas fa-sign-out-alt mr-1"></i> Logout
                </a>
            </div>
        </div>

        <!-- Main Content -->
        <div class="flex-1 overflow-auto">
            <!-- Top Navbar -->
            <div class="bg-white shadow-md h-16 hidden md:flex items-center justify-between px-6">
                <div class="flex items-center">
                    <h1 class="text-2xl font-semibold text-gray-800">
                        <!-- Page title will be inserted here by each page -->
                        <span id="pageTitle">Dashboard</span>
                    </h1>
                </div>
                <div class="flex items-center space-x-4">
                    <span class="text-gray-600">Welcome, ${userName}</span>
                    <span class="bg-indigo-100 text-indigo-800 py-1 px-3 rounded-full text-sm font-medium capitalize">${userRole}</span>
                    <a href="${pageContext.request.contextPath}/logout" class="text-red-600 hover:text-red-800 flex items-center transition duration-200">
                        <i class="fas fa-sign-out-alt mr-1"></i> Logout
                    </a>
                </div>
            </div>
            
            <!-- Page Content -->
            <div class="p-6 page-transition">
<% } %>
