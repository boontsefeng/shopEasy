<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<%@ include file="dashboard-template.jsp" %>

<!-- Set page title -->
<script>
    document.addEventListener('DOMContentLoaded', function() {
        setPageTitle('Dashboard');
    });
</script>

<!-- Dashboard Content -->
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
    <!-- Dashboard Card 1 -->
    <div class="bg-white rounded-lg shadow-md overflow-hidden animate-section">
        <div class="p-4 bg-blue-500 text-white flex justify-between items-center">
            <h2 class="text-lg font-semibold">Products</h2>
            <i class="fas fa-box text-2xl"></i>
        </div>
        <div class="p-4 flex flex-col items-center">
            <div class="text-3xl font-bold text-gray-700 mb-2">${productCount}</div>
            <div class="text-sm text-gray-500">Total Products</div>
            <a href="${pageContext.request.contextPath}/products" class="mt-4 text-blue-500 hover:text-blue-700 transition">
                <i class="fas fa-arrow-right mr-1"></i> View All
            </a>
        </div>
    </div>
    
    <!-- Dashboard Card 2 -->
    <div class="bg-white rounded-lg shadow-md overflow-hidden animate-section">
        <div class="p-4 bg-green-500 text-white flex justify-between items-center">
            <h2 class="text-lg font-semibold">Orders</h2>
            <i class="fas fa-shopping-cart text-2xl"></i>
        </div>
        <div class="p-4 flex flex-col items-center">
            <div class="text-3xl font-bold text-gray-700 mb-2">${orderCount}</div>
            <div class="text-sm text-gray-500">Total Orders</div>
            <a href="${pageContext.request.contextPath}/orders" class="mt-4 text-green-500 hover:text-green-700 transition">
                <i class="fas fa-arrow-right mr-1"></i> View All
            </a>
        </div>
    </div>
    
    <!-- Dashboard Card 3 -->
    <div class="bg-white rounded-lg shadow-md overflow-hidden animate-section">
        <div class="p-4 bg-purple-500 text-white flex justify-between items-center">
            <h2 class="text-lg font-semibold">Customers</h2>
            <i class="fas fa-users text-2xl"></i>
        </div>
        <div class="p-4 flex flex-col items-center">
            <div class="text-3xl font-bold text-gray-700 mb-2">${customerCount}</div>
            <div class="text-sm text-gray-500">Total Customers</div>
            <c:if test="${userRole == 'manager'}">
                <a href="${pageContext.request.contextPath}/manager/customers" class="mt-4 text-purple-500 hover:text-purple-700 transition">
                    <i class="fas fa-arrow-right mr-1"></i> View All
                </a>
            </c:if>
            <c:if test="${userRole != 'manager'}">
                <span class="mt-4 text-gray-400">
                    <i class="fas fa-lock mr-1"></i> Restricted
                </span>
            </c:if>
        </div>
    </div>
    
    <!-- Dashboard Card 4 -->
    <div class="bg-white rounded-lg shadow-md overflow-hidden animate-section">
        <div class="p-4 bg-yellow-500 text-white flex justify-between items-center">
            <h2 class="text-lg font-semibold">Revenue</h2>
            <i class="fas fa-dollar-sign text-2xl"></i>
        </div>
        <div class="p-4 flex flex-col items-center">
            <div class="text-3xl font-bold text-gray-700 mb-2">${totalRevenue}</div>
            <div class="text-sm text-gray-500">Total Revenue</div>
            <a href="${pageContext.request.contextPath}/reports" class="mt-4 text-yellow-500 hover:text-yellow-700 transition">
                <i class="fas fa-arrow-right mr-1"></i> View Reports
            </a>
        </div>
    </div>
</div>

<!-- Quick Actions Section -->
<div class="bg-white rounded-lg shadow-md overflow-hidden mb-8 animate-section">
    <div class="p-4 bg-indigo-500 text-white">
        <h2 class="text-lg font-semibold">Quick Actions</h2>
    </div>
    <div class="p-4 grid grid-cols-2 md:grid-cols-4 gap-4">
        <a href="${pageContext.request.contextPath}/products" class="bg-blue-100 hover:bg-blue-200 p-4 rounded-lg text-center transition-all transform hover:scale-105">
            <i class="fas fa-plus-circle text-blue-500 text-2xl mb-2"></i>
            <div class="text-sm font-medium text-gray-700">View Products</div>
        </a>
        
        <a href="${pageContext.request.contextPath}/orders" class="bg-green-100 hover:bg-green-200 p-4 rounded-lg text-center transition-all transform hover:scale-105">
            <i class="fas fa-truck text-green-500 text-2xl mb-2"></i>
            <div class="text-sm font-medium text-gray-700">View Orders</div>
        </a>
        
        <c:if test="${userRole == 'manager'}">
            <a href="${pageContext.request.contextPath}/manager/staff/add" class="bg-purple-100 hover:bg-purple-200 p-4 rounded-lg text-center transition-all transform hover:scale-105">
                <i class="fas fa-user-plus text-purple-500 text-2xl mb-2"></i>
                <div class="text-sm font-medium text-gray-700">Add Staff</div>
            </a>
            
            <a href="${pageContext.request.contextPath}/reports" class="bg-yellow-100 hover:bg-yellow-200 p-4 rounded-lg text-center transition-all transform hover:scale-105">
                <i class="fas fa-chart-bar text-yellow-500 text-2xl mb-2"></i>
                <div class="text-sm font-medium text-gray-700">Sales Reports</div>
            </a>
        </c:if>
        <c:if test="${userRole != 'manager'}">
        </c:if>
    </div>
</div>


<!-- Recent Activities Section -->
<div class="bg-white rounded-lg shadow-md overflow-hidden animate-section">
    <div class="p-4 bg-indigo-500 text-white flex justify-between items-center">
        <h2 class="text-lg font-semibold">Recent Activities</h2>
        <span class="text-xs bg-white text-indigo-500 py-1 px-2 rounded-full">In This Session:</span>
    </div>
    <div class="p-4">
        <div class="space-y-4" id="recentActivities">
            <div class="flex items-center py-2 border-b border-gray-100">
                <div class="bg-blue-100 p-2 rounded mr-3">
                    <i class="fas fa-box text-blue-500"></i>
                </div>
                <div class="flex-1">
                    <div class="text-sm font-medium">Product "Sample Product" was added</div>
                    <div class="text-xs text-gray-500">Today, 10:30 AM</div>
                </div>
            </div>
            
            <div class="flex items-center py-2 border-b border-gray-100">
                <div class="bg-green-100 p-2 rounded mr-3">
                    <i class="fas fa-shopping-cart text-green-500"></i>
                </div>
                <div class="flex-1">
                    <div class="text-sm font-medium">New order #12345 was received</div>
                    <div class="text-xs text-gray-500">Yesterday, 3:45 PM</div>
                </div>
            </div>
            
            <div class="flex items-center py-2 border-b border-gray-100">
                <div class="bg-yellow-100 p-2 rounded mr-3">
                    <i class="fas fa-dollar-sign text-yellow-500"></i>
                </div>
                <div class="flex-1">
                    <div class="text-sm font-medium">Payment received for order #12344</div>
                    <div class="text-xs text-gray-500">2 days ago</div>
                </div>
            </div>
            
            <div class="flex items-center py-2">
                <div class="bg-purple-100 p-2 rounded mr-3">
                    <i class="fas fa-user text-purple-500"></i>
                </div>
                <div class="flex-1">
                    <div class="text-sm font-medium">New customer "John Doe" registered</div>
                    <div class="text-xs text-gray-500">3 days ago</div>
                </div>
            </div>
        </div>
        
        <div class="mt-4 text-center">
            <button class="text-indigo-500 hover:text-indigo-700 text-sm font-medium focus:outline-none transition">
                View All Activities
            </button>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // The values are now loaded from the server via EL expressions
        // No need to set them with JavaScript
    });
</script>