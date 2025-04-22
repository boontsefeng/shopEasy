<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<%@ include file="dashboard-template.jsp" %>

<!-- Set page title -->
<script>
    document.addEventListener('DOMContentLoaded', function() {
        setPageTitle('Products Management');
    });
</script>

<!-- Debug Information - Only visible with ?debug=true parameter -->
<c:if test="${param.debug != null}">
    <div class="bg-yellow-100 border-l-4 border-yellow-500 text-yellow-700 p-4 mb-6 rounded">
        <div class="flex">
            <div class="py-1"><i class="fas fa-info-circle text-yellow-500 mr-3"></i></div>
            <div>
                <p class="font-bold">Debug Information</p>
                <p>Application Context Path: ${pageContext.request.contextPath}</p>
                <p>Real Path: ${pageContext.servletContext.getRealPath('')}</p>
                <c:if test="${not empty products && products.size() > 0}">
                    <p>First Product Image Path: ${products[0].imagePath}</p>
                    <p>Rendered Image URL: ${pageContext.request.contextPath}/view/${products[0].imagePath}</p>
                </c:if>
            </div>
        </div>
    </div>
</c:if>

<!-- Success/Error Messages -->
<c:if test="${param.success != null}">
    <div class="bg-green-100 border-l-4 border-green-500 text-green-700 p-4 mb-6 rounded animate__animated animate__fadeIn" role="alert">
        <div class="flex">
            <div class="py-1"><i class="fas fa-check-circle text-green-500 mr-3"></i></div>
            <div>
                <p class="font-bold">Success</p>
                <c:choose>
                    <c:when test="${param.success == 'added'}">
                        <p>Product was successfully added.</p>
                    </c:when>
                    <c:when test="${param.success == 'updated'}">
                        <p>Product was successfully updated.</p>
                    </c:when>
                    <c:when test="${param.success == 'deleted'}">
                        <p>Product was successfully deleted.</p>
                    </c:when>
                    <c:when test="${param.success == 'restocked'}">
                        <p>Product was successfully restocked.</p>
                    </c:when>
                    <c:otherwise>
                        <p>Operation completed successfully.</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</c:if>

<c:if test="${param.error != null}">
    <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-6 rounded animate__animated animate__headShake" role="alert">
        <div class="flex">
            <div class="py-1"><i class="fas fa-exclamation-circle text-red-500 mr-3"></i></div>
            <div>
                <p class="font-bold">Error</p>
                <c:choose>
                    <c:when test="${param.error == 'invalid'}">
                        <p>Invalid product data provided.</p>
                    </c:when>
                    <c:when test="${param.error == 'notfound'}">
                        <p>Product not found.</p>
                    </c:when>
                    <c:when test="${param.error == 'deletefailed'}">
                        <p>Failed to delete product.</p>
                    </c:when>
                    <c:otherwise>
                        <p>An error occurred during the operation.</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</c:if>

<!-- Product Management Section -->
<div class="bg-white rounded-lg shadow-md overflow-hidden mb-6 animate-section">
    <div class="p-4 bg-blue-500 text-white flex justify-between items-center">
        <h2 class="text-lg font-semibold">Manage Products</h2>
        <div class="flex space-x-2">
            <button onclick="openAddProductModal()" class="bg-white text-blue-500 hover:bg-blue-50 py-1 px-3 rounded-full text-sm font-medium flex items-center transition-colors">
                <i class="fas fa-plus mr-1"></i> Add New Product
            </button>
        </div>
    </div>
    
    <!-- Search and Filter Bar -->
    <div class="p-4 border-b">
        <div class="flex flex-col md:flex-row gap-4">
            <form action="${pageContext.request.contextPath}/product/search" method="GET" class="flex flex-col sm:flex-row gap-2 flex-grow">
                <div class="relative flex-grow">
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <i class="fas fa-search text-gray-400"></i>
                    </div>
                    <input type="text" name="keyword" value="${searchKeyword}" placeholder="Search products..." 
                           class="appearance-none block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                </div>
                <button type="submit" class="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-500 hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                    Search
                </button>
                <a href="${pageContext.request.contextPath}/products" class="inline-flex justify-center py-2 px-4 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                    Clear
                </a>
            </form>
            
            <!-- Sort/Filter Options -->
            <div class="flex gap-2">
                <div class="relative">
                    <select id="sortOrder" onchange="sortProducts()" class="appearance-none block pl-3 pr-10 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                        <option value="name-asc">Sort by: Name (A-Z)</option>
                        <option value="name-desc">Sort by: Name (Z-A)</option>
                        <option value="price-asc">Sort by: Price (Low-High)</option>
                        <option value="price-desc">Sort by: Price (High-Low)</option>
                        <option value="stock-asc">Sort by: Stock (Low-High)</option>
                        <option value="stock-desc">Sort by: Stock (High-Low)</option>
                    </select>
                    <div class="absolute inset-y-0 right-0 flex items-center px-2 pointer-events-none">
                        <i class="fas fa-chevron-down text-gray-400"></i>
                    </div>
                </div>
                
                <div class="relative">
                    <select id="categoryFilter" onchange="filterByCategory()" class="appearance-none block pl-3 pr-10 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                        <option value="">All Categories</option>
                    </select>
                    <div class="absolute inset-y-0 right-0 flex items-center px-2 pointer-events-none">
                        <i class="fas fa-chevron-down text-gray-400"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Products Table -->
    <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
                <tr>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Image</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase ">
                        Name
                    </th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                        Category
                    </th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                        Price
                    </th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                        Stock
                    </th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                </tr>
            </thead>
            <tbody id="productTableBody" class="bg-white divide-y divide-gray-200">
                <c:if test="${empty products}">
                    <tr>
                        <td colspan="7" class="px-6 py-4 text-center text-sm text-gray-500">
                            <div class="flex flex-col items-center justify-center py-8">
                                <i class="fas fa-box-open text-gray-300 text-5xl mb-4"></i>
                                <p class="text-gray-500 font-medium">No products found</p>
                                <p class="text-gray-400 text-sm">Add a new product to get started</p>
                                <button onclick="openAddProductModal()" class="mt-4 inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-500 hover:bg-blue-600">
                                    <i class="fas fa-plus mr-2"></i> Add New Product
                                </button>
                            </div>
                        </td>
                    </tr>
                </c:if>
                
                <c:forEach var="product" items="${products}">
                    <tr class="hover:bg-gray-50 transition-colors product-row" 
                        data-id="${product.productId}" 
                        data-name="${product.name}" 
                        data-category="${product.category}" 
                        data-price="${product.price}" 
                        data-stock="${product.quantity}">
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${product.productId}</td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <div class="h-12 w-12 rounded overflow-hidden bg-gray-100 flex items-center justify-center">
                                <c:choose>
                                    <c:when test="${not empty product.imagePath}">
                                        <img src="${pageContext.request.contextPath}/view/${product.imagePath}" 
                                             alt="${product.name}" 
                                             class="h-full w-full object-cover"
                                             onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/view/assets/productplaceholder.png'; console.log('Image failed to load: ${product.imagePath}')">
                                    </c:when>
                                    <c:otherwise>
                                        <i class="fas fa-box text-gray-400"></i>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <div class="text-sm font-medium text-gray-900">${product.name}</div>
                            <div class="text-xs text-gray-500 max-w-xs truncate">${product.description}</div>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${product.category}</td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <div class="text-sm text-gray-900">$${product.price / 100}.00</div>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <c:choose>
                                <c:when test="${product.quantity > 10}">
                                    <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                                        ${product.quantity} in stock
                                    </span>
                                </c:when>
                                <c:when test="${product.quantity > 0}">
                                    <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800">
                                        ${product.quantity} in stock
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">
                                        Out of stock
                                    </span>
                                </c:otherwise>
                            </c:choose>
                            <button data-action="restock" 
                                    data-product-id="${product.productId}" 
                                    data-product-name="${product.name}" 
                                    data-product-quantity="${product.quantity}"
                                    class="ml-2 text-indigo-600 hover:text-indigo-900 transition-colors text-xs">
                                <i class="fas fa-plus-circle"></i> Restock
                            </button>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                            <div class="flex space-x-3">
                                <button data-action="quick-edit"
                                        data-product-id="${product.productId}" 
                                        data-product-name="${product.name}" 
                                        data-product-category="${product.category}" 
                                        data-product-price="${product.price}" 
                                        data-product-quantity="${product.quantity}"
                                        class="text-blue-600 hover:text-blue-900 transition-colors fas fa-edit" 
                                        title="Quick Edit">
                                </button>
                                <button data-action="full-edit"
                                        data-product-id="${product.productId}" 
                                        data-product-name="${product.name}" 
                                        data-product-category="${product.category}" 
                                        data-product-price="${product.price}" 
                                        data-product-quantity="${product.quantity}"
                                        data-product-description="${product.description}" 
                                        data-product-image="${product.imagePath}"
                                        class="text-indigo-600 hover:text-indigo-900 transition-colors fas fa-sliders-h" 
                                        title="Full Edit">
                                </button>
                                <button data-action="delete"
                                        data-product-id="${product.productId}" 
                                        data-product-name="${product.name}"
                                        class="text-red-600 hover:text-red-900 transition-colors fas fa-trash" 
                                        title="Delete">
                                </button>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
    
    <!-- Pagination -->
    <c:if test="${not empty products && products.size() > 10}">
        <div class="bg-white px-4 py-3 flex items-center justify-between border-t border-gray-200 sm:px-6">
            <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
                <div>
                    <p class="text-sm text-gray-700" id="pagination-info">
                        Showing <span class="font-medium">1</span> to <span class="font-medium">10</span> of <span class="font-medium">${products.size()}</span> results
                    </p>
                </div>
                <div>
                    <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination" id="pagination-controls">
                        <!-- Pagination controls will be added via JavaScript -->
                    </nav>
                </div>
            </div>
        </div>
    </c:if>
</div>

<!-- Delete Confirmation Modal -->
<div id="deleteModal" class="fixed inset-0 flex items-center justify-center z-50 hidden">
    <div class="modal-overlay absolute inset-0 bg-black opacity-50"></div>
    <div class="modal-container bg-white w-11/12 md:max-w-md mx-auto rounded shadow-lg z-50 overflow-y-auto">
        <div class="modal-content py-4 text-left px-6">
            <div class="flex justify-between items-center pb-3">
                <p class="text-xl font-bold text-red-500">Confirm Delete</p>
                <button id="closeModal" class="modal-close cursor-pointer z-50">
                    <i class="fas fa-times text-gray-500 hover:text-gray-800"></i>
                </button>
            </div>
            <p class="mb-4">Are you sure you want to delete product "<span id="productName" class="font-semibold"></span>"?</p>
            <p class="mb-4 text-sm text-gray-600">This action cannot be undone.</p>
            <div class="flex justify-end pt-2">
                <button id="cancelDelete" class="px-4 py-2 bg-gray-300 text-gray-800 rounded mr-2 hover:bg-gray-400 transition-colors">Cancel</button>
                <a id="confirmDeleteBtn" href="#" class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600 transition-colors">Delete</a>
            </div>
        </div>
    </div>
</div>

<!-- Restock Modal -->
<div id="restockModal" class="fixed inset-0 flex items-center justify-center z-50 hidden">
    <div class="modal-overlay absolute inset-0 bg-black opacity-50"></div>
    <div class="modal-container bg-white w-11/12 md:max-w-md mx-auto rounded shadow-lg z-50 overflow-y-auto">
        <div class="modal-content py-4 text-left px-6">
            <div class="flex justify-between items-center pb-3">
                <p class="text-xl font-bold text-blue-500">Restock Product</p>
                <button id="closeRestockModal" class="modal-close cursor-pointer z-50">
                    <i class="fas fa-times text-gray-500 hover:text-gray-800"></i>
                </button>
            </div>
            <form action="${pageContext.request.contextPath}/product/restock" method="POST" id="restockForm">
                <input type="hidden" id="restockProductId" name="productId" value="">
                
                <p class="mb-4">Restock product: <span id="restockProductName" class="font-semibold"></span></p>
                
                <div class="mb-4">
                    <label for="currentStock" class="block text-sm font-medium text-gray-700 mb-1">Current Stock</label>
                    <input type="number" id="currentStock" class="appearance-none block w-full px-3 py-2 border border-gray-300 bg-gray-100 rounded-md shadow-sm text-gray-500 sm:text-sm" readonly>
                </div>
                
                <div class="mb-4">
                    <label for="addStock" class="block text-sm font-medium text-gray-700 mb-1">Add Stock <span class="text-red-500">*</span></label>
                    <input type="number" id="addStock" name="addStock" min="1" value="1" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                </div>
                
                <div class="mb-4">
                    <label for="newStock" class="block text-sm font-medium text-gray-700 mb-1">New Stock</label>
                    <input type="number" id="newStock" name="newStock" class="appearance-none block w-full px-3 py-2 border border-gray-300 bg-gray-100 rounded-md shadow-sm text-gray-700 font-semibold sm:text-sm" readonly>
                </div>
                
                <div class="flex justify-end pt-2">
                    <button type="button" id="cancelRestock" class="px-4 py-2 bg-gray-300 text-gray-800 rounded mr-2 hover:bg-gray-400 transition-colors">Cancel</button>
                    <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors">
                        <i class="fas fa-save mr-1"></i> Save
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Quick Edit Modal -->
<div id="quickEditModal" class="fixed inset-0 flex items-center justify-center z-50 hidden">
    <div class="modal-overlay absolute inset-0 bg-black opacity-50"></div>
    <div class="modal-container bg-white w-11/12 md:max-w-md mx-auto rounded shadow-lg z-50 overflow-y-auto">
        <div class="modal-content py-4 text-left px-6">
            <div class="flex justify-between items-center pb-3">
                <p class="text-xl font-bold text-blue-500">Quick Edit Product</p>
                <button id="closeQuickEditModal" class="modal-close cursor-pointer z-50">
                    <i class="fas fa-times text-gray-500 hover:text-gray-800"></i>
                </button>
            </div>
            <form action="${pageContext.request.contextPath}/product/edit" method="POST" id="quickEditForm">
                <input type="hidden" id="editProductId" name="productId" value="">
                
                <div class="mb-4">
                    <label for="editName" class="block text-sm font-medium text-gray-700 mb-1">Product Name <span class="text-red-500">*</span></label>
                    <input type="text" id="editName" name="name" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                </div>
                
                <div class="mb-4">
                    <label for="editCategory" class="block text-sm font-medium text-gray-700 mb-1">Category <span class="text-red-500">*</span></label>
                    <select id="editCategory" name="category" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                        <option value="Kitchen Appliances">Kitchen Appliances</option>
                        <option value="Refrigerators & Freezers">Refrigerators & Freezers</option>
                        <option value="Washing Machines">Washing Machines</option>
                        <option value="Air Conditioners">Air Conditioners</option>
                        <option value="Vacuum Cleaners">Vacuum Cleaners</option>
                        <option value="Fans & Air Coolers">Fans & Air Coolers</option>
                        <option value="Water Heaters">Water Heaters</option>
                        <option value="Microwaves & Ovens">Microwaves & Ovens</option>
                        <option value="Dishwashers">Dishwashers</option>
                        <option value="Other Appliances">Other Appliances</option>
                    </select>
                </div>
                
                <div class="mb-4">
                    <label for="editPrice" class="block text-sm font-medium text-gray-700 mb-1">Price ($) <span class="text-red-500">*</span></label>
                    <input type="number" id="editPrice" name="price" min="0" step="0.01" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                </div>
                
                <div class="mb-4">
                    <label for="editQuantity" class="block text-sm font-medium text-gray-700 mb-1">Stock Quantity <span class="text-red-500">*</span></label>
                    <input type="number" id="editQuantity" name="quantity" min="0" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                </div>
                
                <div class="flex justify-end pt-2">
                    <button type="button" id="cancelQuickEdit" class="px-4 py-2 bg-gray-300 text-gray-800 rounded mr-2 hover:bg-gray-400 transition-colors">Cancel</button>
                    <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors">
                        <i class="fas fa-save mr-1"></i> Save Changes
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Add Product Modal -->
<div id="addProductModal" class="fixed inset-0 flex items-center justify-center z-50 hidden">
    <div class="modal-overlay absolute inset-0 bg-black opacity-50"></div>
    <div class="modal-container bg-white w-11/12 md:max-w-md mx-auto rounded shadow-lg z-50 overflow-y-auto">
        <div class="modal-content py-4 text-left px-6">
            <div class="flex justify-between items-center pb-3">
                <p class="text-xl font-bold text-blue-500">Add New Product</p>
                <button id="closeAddProductModal" class="modal-close cursor-pointer z-50">
                    <i class="fas fa-times text-gray-500 hover:text-gray-800"></i>
                </button>
            </div>
            <form action="${pageContext.request.contextPath}/product/add" method="POST" enctype="multipart/form-data" id="addProductForm">
                <div class="mb-4">
                    <label for="addName" class="block text-sm font-medium text-gray-700 mb-1">Product Name <span class="text-red-500">*</span></label>
                    <input type="text" id="addName" name="name" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                </div>
                
                <div class="mb-4">
                    <label for="addDescription" class="block text-sm font-medium text-gray-700 mb-1">Description</label>
                    <textarea id="addDescription" name="description" rows="3" class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"></textarea>
                </div>
                
                <div class="mb-4">
                    <label for="addCategory" class="block text-sm font-medium text-gray-700 mb-1">Category <span class="text-red-500">*</span></label>
                    <select id="addCategory" name="category" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                        <option value="Kitchen Appliances">Kitchen Appliances</option>
                        <option value="Refrigerators & Freezers">Refrigerators & Freezers</option>
                        <option value="Washing Machines">Washing Machines</option>
                        <option value="Air Conditioners">Air Conditioners</option>
                        <option value="Vacuum Cleaners">Vacuum Cleaners</option>
                        <option value="Fans & Air Coolers">Fans & Air Coolers</option>
                        <option value="Water Heaters">Water Heaters</option>
                        <option value="Microwaves & Ovens">Microwaves & Ovens</option>
                        <option value="Dishwashers">Dishwashers</option>
                        <option value="Other Appliances">Other Appliances</option>
                    </select>
                </div>
                
                <div class="mb-4">
                    <label for="addPrice" class="block text-sm font-medium text-gray-700 mb-1">Price ($) <span class="text-red-500">*</span></label>
                    <input type="number" id="addPrice" name="price" min="0" step="0.01" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                </div>
                
                <div class="mb-4">
                    <label for="addQuantity" class="block text-sm font-medium text-gray-700 mb-1">Stock Quantity <span class="text-red-500">*</span></label>
                    <input type="number" id="addQuantity" name="quantity" min="0" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                </div>
                
                <div class="mb-4">
                    <label for="addImage" class="block text-sm font-medium text-gray-700 mb-1">Product Image</label>
                    <input type="file" id="addImage" name="image" accept="image/*" class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                    <p class="mt-1 text-xs text-gray-500">Optional. Max size: 2MB. Formats: JPG, PNG, GIF</p>
                </div>
                
                <div class="flex justify-end pt-2">
                    <button type="button" id="cancelAddProduct" class="px-4 py-2 bg-gray-300 text-gray-800 rounded mr-2 hover:bg-gray-400 transition-colors">Cancel</button>
                    <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors">
                        <i class="fas fa-plus mr-1"></i> Add Product
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Full Edit Modal -->
<div id="fullEditModal" class="fixed inset-0 flex items-center justify-center z-50 hidden">
    <div class="modal-overlay absolute inset-0 bg-black opacity-50"></div>
    <div class="modal-container bg-white w-11/12 md:max-w-lg mx-auto rounded shadow-lg z-50 overflow-y-auto">
        <div class="modal-content py-4 text-left px-6">
            <div class="flex justify-between items-center pb-3">
                <p class="text-xl font-bold text-indigo-500">Full Edit Product</p>
                <button id="closeFullEditModal" class="modal-close cursor-pointer z-50">
                    <i class="fas fa-times text-gray-500 hover:text-gray-800"></i>
                </button>
            </div>
            <form action="${pageContext.request.contextPath}/product/edit" method="POST" enctype="multipart/form-data" id="fullEditForm">
                <input type="hidden" id="fullEditProductId" name="productId" value="">
                <input type="hidden" name="fullEdit" value="true">
                
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <!-- Left column -->
                    <div>
                        <div class="mb-4">
                            <label for="fullEditName" class="block text-sm font-medium text-gray-700 mb-1">Product Name <span class="text-red-500">*</span></label>
                            <input type="text" id="fullEditName" name="name" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
                        </div>
                        
                        <div class="mb-4">
                            <label for="fullEditCategory" class="block text-sm font-medium text-gray-700 mb-1">Category <span class="text-red-500">*</span></label>
                            <select id="fullEditCategory" name="category" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
                                <option value="Kitchen Appliances">Kitchen Appliances</option>
                                <option value="Refrigerators & Freezers">Refrigerators & Freezers</option>
                                <option value="Washing Machines">Washing Machines</option>
                                <option value="Air Conditioners">Air Conditioners</option>
                                <option value="Vacuum Cleaners">Vacuum Cleaners</option>
                                <option value="Fans & Air Coolers">Fans & Air Coolers</option>
                                <option value="Water Heaters">Water Heaters</option>
                                <option value="Microwaves & Ovens">Microwaves & Ovens</option>
                                <option value="Dishwashers">Dishwashers</option>
                                <option value="Other Appliances">Other Appliances</option>
                            </select>
                        </div>
                        
                        <div class="mb-4">
                            <label for="fullEditPrice" class="block text-sm font-medium text-gray-700 mb-1">Price ($) <span class="text-red-500">*</span></label>
                            <input type="number" id="fullEditPrice" name="price" min="0" step="0.01" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
                        </div>
                        
                        <div class="mb-4">
                            <label for="fullEditQuantity" class="block text-sm font-medium text-gray-700 mb-1">Stock Quantity <span class="text-red-500">*</span></label>
                            <input type="number" id="fullEditQuantity" name="quantity" min="0" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
                        </div>
                    </div>
                    
                    <!-- Right column -->
                    <div>
                        <div class="mb-4">
                            <label for="fullEditDescription" class="block text-sm font-medium text-gray-700 mb-1">Description</label>
                            <textarea id="fullEditDescription" name="description" rows="5" class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"></textarea>
                        </div>
                        
                        <div class="mb-4">
                            <label class="block text-sm font-medium text-gray-700 mb-1">Current Image</label>
                            <div id="currentImageContainer" class="h-32 w-32 rounded overflow-hidden bg-gray-100 flex items-center justify-center mb-2">
                                <img id="currentProductImage" src="" alt="Product image" class="h-full w-full object-cover hidden">
                                <i id="noImageIcon" class="fas fa-box text-gray-400 text-4xl"></i>
                            </div>
                        </div>
                        
                        <div class="mb-4">
                            <label for="fullEditImage" class="block text-sm font-medium text-gray-700 mb-1">Change Image</label>
                            <input type="file" id="fullEditImage" name="image" accept="image/*" class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
                            <p class="mt-1 text-xs text-gray-500">Optional. Max size: 2MB. Formats: JPG, PNG, GIF</p>
                        </div>
                    </div>
                </div>
                
                <div class="flex justify-end pt-2">
                    <button type="button" id="cancelFullEdit" class="px-4 py-2 bg-gray-300 text-gray-800 rounded mr-2 hover:bg-gray-400 transition-colors">Cancel</button>
                    <button type="submit" class="px-4 py-2 bg-indigo-500 text-white rounded hover:bg-indigo-600 transition-colors">
                        <i class="fas fa-save mr-1"></i> Save Changes
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
                
<!-- JavaScript for Product Management -->
<script>
    // Store all products to enable client-side filtering and sorting
    let allProducts = [];
    let currentPage = 1;
    const itemsPerPage = 10;
    let currentSortField = 'name';
    let currentSortDirection = 'asc';
    let currentCategoryFilter = '';
    
    // Initialize on page load
    document.addEventListener('DOMContentLoaded', function() {
        // Log application path for debugging
        console.log("Application context path: " + "${pageContext.request.contextPath}");
        
        // Extract unique categories and populate dropdown
        const categories = new Set();
        document.querySelectorAll('.product-row').forEach(row => {
            // Collect products for client-side operations
            const product = {
                id: row.dataset.id,
                name: row.dataset.name,
                category: row.dataset.category,
                price: parseInt(row.dataset.price),
                stock: parseInt(row.dataset.stock),
                element: row
            };
            allProducts.push(product);
            
            // Collect categories
            categories.add(row.dataset.category);
        });
        
        // Populate category filter
        const categoryFilter = document.getElementById('categoryFilter');
        categories.forEach(category => {
            if (category && category.trim() !== '') {
                const option = document.createElement('option');
                option.value = category;
                option.textContent = category;
                categoryFilter.appendChild(option);
            }
        });
        
        // Initialize pagination if needed
        if (allProducts.length > itemsPerPage) {
            setupPagination();
            showPage(1);
        }
    });
    
    // Toggle sort direction when clicking column headers
    function toggleSort(field) {
        if (currentSortField === field) {
            // Toggle direction if same field
            currentSortDirection = currentSortDirection === 'asc' ? 'desc' : 'asc';
        } else {
            // New field, default to ascending
            currentSortField = field;
            currentSortDirection = 'asc';
        }
        
        sortProducts();
    }
    
    // Sort products based on dropdown or column header
    function sortProducts() {
        const sortSelect = document.getElementById('sortOrder');
        const selectedSort = sortSelect.value;
        
        // If called from dropdown, parse the selection
        if (selectedSort) {
            const [field, direction] = selectedSort.split('-');
            currentSortField = field;
            currentSortDirection = direction;
        }
        
        // Sort the products array
        allProducts.sort((a, b) => {
            let comparison = 0;
            
            if (currentSortField === 'name') {
                comparison = a.name.localeCompare(b.name);
            } else if (currentSortField === 'category') {
                comparison = a.category.localeCompare(b.category);
            } else if (currentSortField === 'price') {
                comparison = a.price - b.price;
            } else if (currentSortField === 'stock') {
                comparison = a.stock - b.stock;
            }
            
            return currentSortDirection === 'asc' ? comparison : -comparison;
        });
        
        // Reorder the DOM elements
        const tableBody = document.getElementById('productTableBody');
        
        // Apply current category filter
        let filteredProducts = allProducts;
        if (currentCategoryFilter) {
            filteredProducts = allProducts.filter(product => product.category === currentCategoryFilter);
        }
        
        // Remove all rows
        const rows = document.querySelectorAll('.product-row');
        rows.forEach(row => row.remove());
        
        // Add rows in the new order
        filteredProducts.forEach(product => {
            tableBody.appendChild(product.element);
        });
        
        // Update pagination
        if (filteredProducts.length > itemsPerPage) {
            setupPagination();
            showPage(1);
        }
    }
    
    // Filter products by category
    function filterByCategory() {
        const categoryFilter = document.getElementById('categoryFilter');
        currentCategoryFilter = categoryFilter.value;
        
        // Apply the filter and current sort
        sortProducts();
    }
    
    // Setup pagination controls
    function setupPagination() {
        const paginationControls = document.getElementById('pagination-controls');
        paginationControls.innerHTML = '';
        
        let filteredProducts = allProducts;
        if (currentCategoryFilter) {
            filteredProducts = allProducts.filter(product => product.category === currentCategoryFilter);
        }
        
        const pageCount = Math.ceil(filteredProducts.length / itemsPerPage);
        
        // Previous button
        const prevButton = document.createElement('a');
        prevButton.href = '#';
        prevButton.className = 'relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50';
        prevButton.innerHTML = '<span class="sr-only">Previous</span><i class="fas fa-chevron-left"></i>';
        prevButton.addEventListener('click', function(e) {
            e.preventDefault();
            if (currentPage > 1) {
                showPage(currentPage - 1);
            }
        });
        paginationControls.appendChild(prevButton);
        
        // Page numbers
        for (let i = 1; i <= pageCount; i++) {
            const pageLink = document.createElement('a');
            pageLink.href = '#';
            pageLink.className = i === currentPage 
                ? 'z-10 bg-indigo-50 border-indigo-500 text-indigo-600 relative inline-flex items-center px-4 py-2 border text-sm font-medium'
                : 'bg-white border-gray-300 text-gray-500 hover:bg-gray-50 relative inline-flex items-center px-4 py-2 border text-sm font-medium';
            pageLink.textContent = i;
            pageLink.addEventListener('click', function(e) {
                e.preventDefault();
                showPage(i);
            });
            paginationControls.appendChild(pageLink);
        }
        
        // Next button
        const nextButton = document.createElement('a');
        nextButton.href = '#';
        nextButton.className = 'relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50';
        nextButton.innerHTML = '<span class="sr-only">Next</span><i class="fas fa-chevron-right"></i>';
        nextButton.addEventListener('click', function(e) {
            e.preventDefault();
            if (currentPage < pageCount) {
                showPage(currentPage + 1);
            }
        });
        paginationControls.appendChild(nextButton);
    }
    
    // Show specific page
    function showPage(pageNum) {
        currentPage = pageNum;
        
        // Get filtered products
        let filteredProducts = allProducts;
        if (currentCategoryFilter) {
            filteredProducts = allProducts.filter(product => product.category === currentCategoryFilter);
        }
        
        // Calculate range
        const startIndex = (pageNum - 1) * itemsPerPage;
        const endIndex = Math.min(startIndex + itemsPerPage, filteredProducts.length);
        
        // Hide all products
        document.querySelectorAll('.product-row').forEach(row => {
            row.classList.add('hidden');
        });
        
        // Show only products for this page
        for (let i = startIndex; i < endIndex; i++) {
            filteredProducts[i].element.classList.remove('hidden');
        }
        
        // Update pagination info
        const paginationInfo = document.getElementById('pagination-info');
        if (paginationInfo) {
            paginationInfo.innerHTML = `Showing <span class="font-medium">${startIndex + 1}</span> to <span class="font-medium">${endIndex}</span> of <span class="font-medium">${filteredProducts.length}</span> results`;
        }
        
        // Update pagination controls to highlight current page
        const pageLinks = document.querySelectorAll('#pagination-controls a');
        pageLinks.forEach((link, index) => {
            // Skip first and last (prev/next buttons)
            if (index > 0 && index < pageLinks.length - 1) {
                const pageNum = index;
                if (pageNum === currentPage) {
                    link.className = 'z-10 bg-indigo-50 border-indigo-500 text-indigo-600 relative inline-flex items-center px-4 py-2 border text-sm font-medium';
                } else {
                    link.className = 'bg-white border-gray-300 text-gray-500 hover:bg-gray-50 relative inline-flex items-center px-4 py-2 border text-sm font-medium';
                }
            }
        });
    }
    
    // Delete Confirmation Modal
    function confirmDelete(productId, productName) {
        const modal = document.getElementById('deleteModal');
        const productNameSpan = document.getElementById('productName');
        const confirmBtn = document.getElementById('confirmDeleteBtn');
        
        productNameSpan.textContent = productName;
        confirmBtn.href = "${pageContext.request.contextPath}/product/delete?id=" + productId;
        
        modal.classList.remove('hidden');
    }
    
    // Restock Modal
    function openRestockModal(productId, productName, currentQuantity) {
        const modal = document.getElementById('restockModal');
        const productNameSpan = document.getElementById('restockProductName');
        const productIdInput = document.getElementById('restockProductId');
        const currentStockInput = document.getElementById('currentStock');
        const addStockInput = document.getElementById('addStock');
        const newStockInput = document.getElementById('newStock');
        
        productNameSpan.textContent = productName;
        productIdInput.value = productId;
        currentStockInput.value = currentQuantity;
        addStockInput.value = 1;
        newStockInput.value = currentQuantity + 1;
        
        // Update new stock when add stock changes
        addStockInput.addEventListener('input', function() {
            const addValue = parseInt(this.value) || 0;
            newStockInput.value = currentQuantity + addValue;
        });
        
        modal.classList.remove('hidden');
    }
    
    // Quick Edit Modal
    function openQuickEditModal(productId, productName, category, price, quantity) {
        const modal = document.getElementById('quickEditModal');
        const productIdInput = document.getElementById('editProductId');
        const nameInput = document.getElementById('editName');
        const categorySelect = document.getElementById('editCategory');
        const priceInput = document.getElementById('editPrice');
        const quantityInput = document.getElementById('editQuantity');
        
        productIdInput.value = productId;
        nameInput.value = productName;
        
        // Set the category
        for (let i = 0; i < categorySelect.options.length; i++) {
            if (categorySelect.options[i].value === category) {
                categorySelect.selectedIndex = i;
                break;
            }
        }
        
        // Convert price from cents to dollars for display
        priceInput.value = (price / 100).toFixed(2);
        quantityInput.value = quantity;
        
        modal.classList.remove('hidden');
    }
    
    // Full Edit Modal functionality
    function openFullEditModal(productId, productName, category, price, quantity, description, imagePath) {
        const modal = document.getElementById('fullEditModal');
        const productIdInput = document.getElementById('fullEditProductId');
        const nameInput = document.getElementById('fullEditName');
        const categorySelect = document.getElementById('fullEditCategory');
        const priceInput = document.getElementById('fullEditPrice');
        const quantityInput = document.getElementById('fullEditQuantity');
        const descriptionInput = document.getElementById('fullEditDescription');
        const currentProductImage = document.getElementById('currentProductImage');
        const noImageIcon = document.getElementById('noImageIcon');
        
        // Set form values
        productIdInput.value = productId;
        nameInput.value = productName;
        
        // Set the category
        for (let i = 0; i < categorySelect.options.length; i++) {
            if (categorySelect.options[i].value === category) {
                categorySelect.selectedIndex = i;
                break;
            }
        }
        
        // Convert price from cents to dollars for display
        priceInput.value = (price / 100).toFixed(2);
        quantityInput.value = quantity;
        
        // Set description if available
        if (description) {
            descriptionInput.value = description;
        } else {
            descriptionInput.value = '';
        }
        
        // Show current image if available
        if (imagePath && imagePath !== '') {
            let imageSrc = '${pageContext.request.contextPath}/view/' + imagePath;
            console.log("Loading image: " + imageSrc);
            currentProductImage.src = imageSrc;
            currentProductImage.classList.remove('hidden');
            noImageIcon.classList.add('hidden');
            
            // Add error handling for image
            currentProductImage.onerror = function() {
                console.log("Image failed to load: " + imageSrc);
                this.classList.add('hidden');
                noImageIcon.classList.remove('hidden');
            };
        } else {
            currentProductImage.classList.add('hidden');
            noImageIcon.classList.remove('hidden');
        }
        
        modal.classList.remove('hidden');
    }
    
    // Add Product Modal
    function openAddProductModal() {
        const modal = document.getElementById('addProductModal');
        modal.classList.remove('hidden');
        
        // Clear the form
        document.getElementById('addProductForm').reset();
    }
    
    // Modal close handlers
    document.getElementById('closeModal').addEventListener('click', function() {
        document.getElementById('deleteModal').classList.add('hidden');
    });
    
    document.getElementById('cancelDelete').addEventListener('click', function() {
        document.getElementById('deleteModal').classList.add('hidden');
    });
    
    document.getElementById('closeRestockModal').addEventListener('click', function() {
        document.getElementById('restockModal').classList.add('hidden');
    });
    
    document.getElementById('cancelRestock').addEventListener('click', function() {
        document.getElementById('restockModal').classList.add('hidden');
    });
    
    document.getElementById('closeQuickEditModal').addEventListener('click', function() {
        document.getElementById('quickEditModal').classList.add('hidden');
    });
    
    document.getElementById('cancelQuickEdit').addEventListener('click', function() {
        document.getElementById('quickEditModal').classList.add('hidden');
    });
    
    document.getElementById('closeAddProductModal').addEventListener('click', function() {
        document.getElementById('addProductModal').classList.add('hidden');
    });
    
    document.getElementById('cancelAddProduct').addEventListener('click', function() {
        document.getElementById('addProductModal').classList.add('hidden');
    });
    
    document.getElementById('closeFullEditModal').addEventListener('click', function() {
        document.getElementById('fullEditModal').classList.add('hidden');
    });
    
    document.getElementById('cancelFullEdit').addEventListener('click', function() {
        document.getElementById('fullEditModal').classList.add('hidden');
    });
    
    // Handle form submissions
    document.addEventListener('DOMContentLoaded', function() {
        // Convert price from dollars to cents before submitting quick edit form
        const quickEditForm = document.getElementById('quickEditForm');
        quickEditForm.addEventListener('submit', function(e) {
            e.preventDefault();
            const priceInput = document.getElementById('editPrice');
            const priceInDollars = parseFloat(priceInput.value);
            // Update the price to cents
            priceInput.value = Math.round(priceInDollars * 100);
            this.submit();
        });
        
        // Convert price from dollars to cents before submitting add product form
        const addProductForm = document.getElementById('addProductForm');
        addProductForm.addEventListener('submit', function(e) {
            e.preventDefault();
            const priceInput = document.getElementById('addPrice');
            const priceInDollars = parseFloat(priceInput.value);
            // Update the price to cents
            priceInput.value = Math.round(priceInDollars * 100);
            this.submit();
        });
        
        // Convert price from dollars to cents before submitting full edit form
        const fullEditForm = document.getElementById('fullEditForm');
        fullEditForm.addEventListener('submit', function(e) {
            e.preventDefault();
            const priceInput = document.getElementById('fullEditPrice');
            const priceInDollars = parseFloat(priceInput.value);
            // Update the price to cents
            priceInput.value = Math.round(priceInDollars * 100);
            this.submit();
        });
        
        // Handle restock form
        const restockForm = document.getElementById('restockForm');
        restockForm.addEventListener('submit', function(e) {
            // If the restock endpoint doesn't exist, use the edit endpoint
            e.preventDefault();
            const productId = document.getElementById('restockProductId').value;
            const newStock = document.getElementById('newStock').value;
            
            // Redirect to a URL that will update the stock
            window.location.href = "${pageContext.request.contextPath}/product/edit?id=" + 
                                  productId + "&restock=" + newStock;
        });
    });
    
    // Close modals when clicking outside
    document.addEventListener('click', function(event) {
        const modals = [
            {modal: document.getElementById('deleteModal'), content: '.modal-content', trigger: '[onclick^="confirmDelete"]'},
            {modal: document.getElementById('restockModal'), content: '.modal-content', trigger: '[onclick^="openRestockModal"]'},
            {modal: document.getElementById('quickEditModal'), content: '.modal-content', trigger: '[onclick^="openQuickEditModal"]'},
            {modal: document.getElementById('addProductModal'), content: '.modal-content', trigger: '[onclick^="openAddProductModal"]'},
            {modal: document.getElementById('fullEditModal'), content: '.modal-content', trigger: '[onclick^="openFullEditModal"]'}
        ];
        
        modals.forEach(({modal, content, trigger}) => {
            if (!modal.classList.contains('hidden')) {
                const modalContent = modal.querySelector(content);
                if (!modalContent.contains(event.target) && !event.target.matches(trigger)) {
                    modal.classList.add('hidden');
                }
            }
        });
    });

    // Add event listeners for product action buttons
    document.addEventListener('DOMContentLoaded', function() {
        // Restock buttons
        document.querySelectorAll('[data-action="restock"]').forEach(button => {
            button.addEventListener('click', function() {
                const productId = this.getAttribute('data-product-id');
                const productName = this.getAttribute('data-product-name');
                const quantity = this.getAttribute('data-product-quantity');
                openRestockModal(productId, productName, quantity);
            });
        });
        
        // Quick edit buttons
        document.querySelectorAll('[data-action="quick-edit"]').forEach(button => {
            button.addEventListener('click', function() {
                const productId = this.getAttribute('data-product-id');
                const productName = this.getAttribute('data-product-name');
                const category = this.getAttribute('data-product-category');
                const price = this.getAttribute('data-product-price');
                const quantity = this.getAttribute('data-product-quantity');
                openQuickEditModal(productId, productName, category, price, quantity);
            });
        });
        
        // Full edit buttons
        document.querySelectorAll('[data-action="full-edit"]').forEach(button => {
            button.addEventListener('click', function() {
                const productId = this.getAttribute('data-product-id');
                const productName = this.getAttribute('data-product-name');
                const category = this.getAttribute('data-product-category');
                const price = this.getAttribute('data-product-price');
                const quantity = this.getAttribute('data-product-quantity');
                const description = this.getAttribute('data-product-description');
                const imagePath = this.getAttribute('data-product-image');
                openFullEditModal(productId, productName, category, price, quantity, description, imagePath);
            });
        });
        
        // Delete buttons
        document.querySelectorAll('[data-action="delete"]').forEach(button => {
            button.addEventListener('click', function() {
                const productId = this.getAttribute('data-product-id');
                const productName = this.getAttribute('data-product-name');
                confirmDelete(productId, productName);
            });
        });
    });
</script>