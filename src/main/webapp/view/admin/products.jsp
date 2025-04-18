<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<%@ include file="admin-template.jsp" %>

<!-- Set page title -->
<script>
    document.addEventListener('DOMContentLoaded', function() {
        setPageTitle('Products Management');
    });
</script>

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
        <a href="${pageContext.request.contextPath}/product/add" class="bg-white text-blue-500 hover:bg-blue-50 py-1 px-3 rounded-full text-sm font-medium flex items-center transition-colors">
            <i class="fas fa-plus mr-1"></i> Add New Product
        </a>
    </div>
    
    <!-- Search Bar -->
    <div class="p-4 border-b">
        <form action="${pageContext.request.contextPath}/product/search" method="GET" class="flex flex-col sm:flex-row gap-2">
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
    </div>
    
    <!-- Products Table -->
    <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
                <tr>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Image</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Category</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Price</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Stock</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
                <c:if test="${empty products}">
                    <tr>
                        <td colspan="7" class="px-6 py-4 text-center text-sm text-gray-500">
                            <div class="flex flex-col items-center justify-center py-8">
                                <i class="fas fa-box-open text-gray-300 text-5xl mb-4"></i>
                                <p class="text-gray-500 font-medium">No products found</p>
                                <p class="text-gray-400 text-sm">Add a new product to get started</p>
                                <a href="${pageContext.request.contextPath}/product/add" class="mt-4 inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-500 hover:bg-blue-600">
                                    <i class="fas fa-plus mr-2"></i> Add New Product
                                </a>
                            </div>
                        </td>
                    </tr>
                </c:if>
                
                <c:forEach var="product" items="${products}">
                    <tr class="hover:bg-gray-50 transition-colors">
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${product.productId}</td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <div class="h-10 w-10 rounded-full overflow-hidden bg-gray-100 flex items-center justify-center">
                                <c:choose>
                                    <c:when test="${not empty product.imagePath}">
                                        <img src="${pageContext.request.contextPath}/${product.imagePath}" alt="${product.name}" class="h-full w-full object-cover">
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
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                            <div class="flex space-x-2">
                                <a href="${pageContext.request.contextPath}/product/edit?id=${product.productId}" class="text-indigo-600 hover:text-indigo-900 transition-colors" title="Edit">
                                    <i class="fas fa-edit"></i>
                                </a>
                                <a href="#" onclick="confirmDelete(${product.productId}, '${product.name}')" class="text-red-600 hover:text-red-900 transition-colors" title="Delete">
                                    <i class="fas fa-trash"></i>
                                </a>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
    
    <!-- Pagination -->
    <c:if test="${not empty products}">
        <div class="bg-white px-4 py-3 flex items-center justify-between border-t border-gray-200 sm:px-6">
            <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
                <div>
                    <p class="text-sm text-gray-700">
                        Showing <span class="font-medium">1</span> to <span class="font-medium">${products.size()}</span> of <span class="font-medium">${products.size()}</span> results
                    </p>
                </div>
                <div>
                    <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
                        <a href="#" class="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50">
                            <span class="sr-only">Previous</span>
                            <i class="fas fa-chevron-left"></i>
                        </a>
                        <a href="#" aria-current="page" class="z-10 bg-indigo-50 border-indigo-500 text-indigo-600 relative inline-flex items-center px-4 py-2 border text-sm font-medium">
                            1
                        </a>
                        <a href="#" class="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50">
                            <span class="sr-only">Next</span>
                            <i class="fas fa-chevron-right"></i>
                        </a>
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

<!-- JavaScript for Delete Confirmation -->
<script>
    function confirmDelete(productId, productName) {
        const modal = document.getElementById('deleteModal');
        const productNameSpan = document.getElementById('productName');
        const confirmBtn = document.getElementById('confirmDeleteBtn');
        
        productNameSpan.textContent = productName;
        confirmBtn.href = "${pageContext.request.contextPath}/product/delete?id=" + productId;
        
        modal.classList.remove('hidden');
    }
    
    document.getElementById('closeModal').addEventListener('click', function() {
        document.getElementById('deleteModal').classList.add('hidden');
    });
    
    document.getElementById('cancelDelete').addEventListener('click', function() {
        document.getElementById('deleteModal').classList.add('hidden');
    });
    
    // Close modal when clicking outside
    document.addEventListener('click', function(event) {
        const modal = document.getElementById('deleteModal');
        const modalContent = document.querySelector('.modal-content');
        
        if (modal && !modal.classList.contains('hidden') && !modalContent.contains(event.target) && !event.target.matches('[onclick^="confirmDelete"]')) {
            modal.classList.add('hidden');
        }
    });
</script>

<jsp:include page="admin-template.jsp">
    <jsp:param name="section" value="footer" />
</jsp:include>