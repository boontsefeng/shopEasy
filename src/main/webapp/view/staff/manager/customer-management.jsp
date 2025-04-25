<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<%@ include file="../dashboard-template.jsp" %>

<!-- Set page title -->
<script>
    document.addEventListener('DOMContentLoaded', function() {
        setPageTitle('Customer Management');
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
                    <c:when test="${param.success == 'updated'}">
                        <p>Customer was successfully updated.</p>
                    </c:when>
                    <c:when test="${param.success == 'deleted'}">
                        <p>Customer was successfully deleted.</p>
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
                        <p>Invalid customer data provided.</p>
                    </c:when>
                    <c:when test="${param.error == 'notfound'}">
                        <p>Customer not found.</p>
                    </c:when>
                    <c:when test="${param.error == 'deletefailed'}">
                        <p>Failed to delete customer.</p>
                    </c:when>
                    <c:otherwise>
                        <p>An error occurred during the operation.</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</c:if>

<!-- Search and Filter Section -->
<div class="bg-white rounded-lg shadow-md overflow-hidden mb-6 animate-section">
    <div class="p-4 bg-blue-500 text-white flex justify-between items-center">
        <h2 class="text-lg font-semibold">Search & Filter</h2>
        <button id="toggleSearch" class="bg-white text-blue-500 hover:bg-blue-50 py-1 px-3 rounded-full text-sm font-medium flex items-center transition-colors">
            <i class="fas fa-filter mr-1"></i> Toggle Filters
        </button>
    </div>
    <div id="searchForm" class="p-4">
        <form action="${pageContext.request.contextPath}/manager/customers" method="GET" class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div class="md:col-span-1">
                <label for="nameSearch" class="block text-sm font-medium text-gray-700 mb-1">Name or Email</label>
                <input type="text" id="nameSearch" name="search" value="${param.search}" placeholder="Search by name or email" class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
            </div>
            
            <div class="md:col-span-1">
                <label for="orderStatus" class="block text-sm font-medium text-gray-700 mb-1">Sort By</label>
                <select id="sortBy" name="sortBy" class="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                    <option value="name" ${param.sortBy == 'name' ? 'selected' : ''}>Name</option>
                    <option value="recent" ${param.sortBy == 'recent' ? 'selected' : ''}>Recently Added</option>
                    <option value="orders" ${param.sortBy == 'orders' ? 'selected' : ''}>Order Count</option>
                </select>
            </div>
            
            <div class="md:col-span-1 flex items-end">
                <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 flex items-center justify-center">
                    <i class="fas fa-search mr-2"></i> Search
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Customer Management Section -->
<div class="bg-white rounded-lg shadow-md overflow-hidden animate-section">
    <div class="p-4 bg-blue-500 text-white flex justify-between items-center">
        <h2 class="text-lg font-semibold">Customer List</h2>
        <div class="flex space-x-2">
            <div class="bg-white text-gray-700 text-sm rounded-full px-3 py-1">
                Total: <span class="font-bold">${customerList.size()}</span>
            </div>
            <button id="exportCsv" class="bg-white text-blue-500 hover:bg-blue-50 py-1 px-3 rounded-full text-sm font-medium flex items-center transition-colors">
                <i class="fas fa-download mr-1"></i> Export
            </button>
        </div>
    </div>
    
    <!-- Customer Table -->
    <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
                <tr>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Contact</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Orders</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Username</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200" id="customerTableBody">
                <c:if test="${empty customerList}">
                    <tr class="empty-message">
                        <td colspan="7" class="px-6 py-4 text-center text-sm text-gray-500">
                            <div class="flex flex-col items-center justify-center py-8">
                                <i class="fas fa-users text-gray-300 text-5xl mb-4"></i>
                                <p class="text-gray-500 font-medium">No customers found</p>
                                <p class="text-gray-400 text-sm">Try changing your search parameters</p>
                            </div>
                        </td>
                    </tr>
                </c:if>
                
                <c:forEach var="customer" items="${customerList}">
                    <tr class="hover:bg-gray-50 transition-colors customer-row">
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${customer.userId}</td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <div class="flex items-center">
                                <div class="flex-shrink-0 h-10 w-10 rounded-full bg-blue-100 flex items-center justify-center">
                                    <i class="fas fa-user text-blue-500"></i>
                                </div>
                                <div class="ml-4">
                                    <div class="text-sm font-medium text-gray-900">${customer.name}</div>
                                    <div class="text-sm text-gray-500">${customer.username}</div>
                                </div>
                            </div>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${customer.email}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${customer.contactNumber}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                            <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                                ${customer.orderCount == null ? '0' : customer.orderCount}
                            </span>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                            ${customer.username}
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                            <div class="flex space-x-3">
                                <a href="#" onclick="viewOrders(${customer.userId}, '${customer.name}')" class="text-blue-600 hover:text-blue-900 transition-colors" title="View Orders">
                                    <i class="fas fa-shopping-bag"></i>
                                </a>
                                <a href="#" onclick="editCustomer(${customer.userId}, '${customer.username}', '${customer.name}', '${customer.email}', '${customer.contactNumber}')" class="text-indigo-600 hover:text-indigo-900 transition-colors" title="Edit">
                                    <i class="fas fa-edit"></i>
                                </a>
                                <a href="#" onclick="confirmDelete(${customer.userId}, '${customer.name}')" class="text-red-600 hover:text-red-900 transition-colors" title="Delete">
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
    <c:if test="${not empty customerList && customerList.size() > 10}">
        <div class="bg-white px-4 py-3 flex items-center justify-between border-t border-gray-200 sm:px-6">
            <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
                <div>
                    <p class="text-sm text-gray-700">
                        Showing <span class="font-medium">1</span> to <span class="font-medium">10</span> of <span class="font-medium">${customerList.size()}</span> results
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
            <p class="mb-4">Are you sure you want to delete customer "<span id="customerName" class="font-semibold"></span>"?</p>
            <p class="mb-4 text-sm text-gray-600">This action cannot be undone. All customer orders and data will be deleted.</p>
            <div class="flex justify-end pt-2">
                <button id="cancelDelete" class="px-4 py-2 bg-gray-300 text-gray-800 rounded mr-2 hover:bg-gray-400 transition-colors">Cancel</button>
                <a id="confirmDeleteBtn" href="#" class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600 transition-colors">Delete</a>
            </div>
        </div>
    </div>
</div>

<!-- Edit Customer Modal -->
<div id="editModal" class="fixed inset-0 flex items-center justify-center z-50 hidden">
    <div class="modal-overlay absolute inset-0 bg-black opacity-50"></div>
    <div class="modal-container bg-white w-11/12 md:max-w-md mx-auto rounded shadow-lg z-50 overflow-y-auto">
        <div class="modal-content py-4 text-left px-6">
            <div class="flex justify-between items-center pb-3">
                <p class="text-xl font-bold text-blue-500">Edit Customer</p>
                <button id="closeEditModal" class="modal-close cursor-pointer z-50">
                    <i class="fas fa-times text-gray-500 hover:text-gray-800"></i>
                </button>
            </div>
            
            <form id="editCustomerForm" action="${pageContext.request.contextPath}/manager/customer/edit" method="post">
                <input type="hidden" id="editUserId" name="userId">
                
                <div class="mb-4">
                    <label for="editUsername" class="block text-sm font-medium text-gray-700 mb-1">Username</label>
                    <input type="text" id="editUsername" name="username" class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm" readonly>
                    <p class="text-xs text-gray-500 mt-1">Username cannot be changed</p>
                </div>
                
                <div class="mb-4">
                    <label for="editName" class="block text-sm font-medium text-gray-700 mb-1">Full Name <span class="text-red-500">*</span></label>
                    <input type="text" id="editName" name="name" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                </div>
                
                <div class="mb-4">
                    <label for="editEmail" class="block text-sm font-medium text-gray-700 mb-1">Email <span class="text-red-500">*</span></label>
                    <input type="email" id="editEmail" name="email" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                </div>
                
                <div class="mb-4">
                    <label for="editContactNumber" class="block text-sm font-medium text-gray-700 mb-1">Contact Number <span class="text-red-500">*</span></label>
                    <input type="text" id="editContactNumber" name="contactNumber" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                </div>
                
                <div class="mb-4">
                    <label for="editPassword" class="block text-sm font-medium text-gray-700 mb-1">New Password</label>
                    <input type="password" id="editPassword" name="password" class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                    <p class="text-xs text-gray-500 mt-1">Leave blank to keep current password</p>
                </div>
                
                <div class="flex justify-end pt-2">
                    <button type="button" id="cancelEdit" class="px-4 py-2 bg-gray-300 text-gray-800 rounded mr-2 hover:bg-gray-400 transition-colors">Cancel</button>
                    <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors">Save Changes</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Customer Orders Detail Modal -->
<div id="ordersModal" class="fixed inset-0 flex items-center justify-center z-50 hidden">
    <div class="modal-overlay absolute inset-0 bg-black opacity-50"></div>
    <div class="modal-container bg-white w-11/12 md:max-w-4xl mx-auto rounded shadow-lg z-50 overflow-y-auto">
        <div class="modal-content py-4 text-left px-6">
            <div class="flex justify-between items-center pb-3">
                <p class="text-xl font-bold text-blue-500">Order History: <span id="orderCustomerName"></span></p>
                <button id="closeOrdersModal" class="modal-close cursor-pointer z-50">
                    <i class="fas fa-times text-gray-500 hover:text-gray-800"></i>
                </button>
            </div>
            
            <div id="customerOrdersContainer" class="mt-2">
                <!-- Orders will be loaded here via AJAX -->
                <div id="loadingOrders" class="text-center py-8 text-gray-500">
                    <i class="fas fa-spinner fa-spin text-3xl mb-3"></i>
                    <p>Loading customer orders...</p>
                </div>
                
                <div id="ordersTable" class="hidden">
                    <div class="overflow-x-auto">
                        <table class="min-w-full divide-y divide-gray-200">
                            <thead class="bg-gray-50">
                                <tr>
                                    <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Order ID</th>
                                    <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Amount</th>
                                    <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                                    <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Payment</th>
                                </tr>
                            </thead>
                            <tbody id="ordersTableBody" class="bg-white divide-y divide-gray-200">
                                <!-- Order rows will be inserted here -->
                            </tbody>
                        </table>
                    </div>
                </div>
                
                <div id="noOrdersMessage" class="hidden text-center py-8 text-gray-500">
                    <i class="fas fa-exclamation-circle text-3xl mb-3"></i>
                    <p>No orders found for this customer.</p>
                </div>
                
                <div id="errorMessage" class="hidden text-center py-8 text-red-500">
                    <i class="fas fa-exclamation-triangle text-3xl mb-3"></i>
                    <p>Error loading orders. Please try again.</p>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- JavaScript for this page -->
<script>
    // Delete confirmation
    function confirmDelete(userId, name) {
        document.getElementById('customerName').textContent = name;
        document.getElementById('confirmDeleteBtn').href = '${pageContext.request.contextPath}/manager/customer/delete?id=' + userId;
        document.getElementById('deleteModal').classList.remove('hidden');
    }
    
    // Edit customer
    function editCustomer(userId, username, name, email, contactNumber) {
        document.getElementById('editUserId').value = userId;
        document.getElementById('editUsername').value = username;
        document.getElementById('editName').value = name;
        document.getElementById('editEmail').value = email;
        document.getElementById('editContactNumber').value = contactNumber;
        document.getElementById('editPassword').value = '';
        document.getElementById('editModal').classList.remove('hidden');
    }
    
    // Handle modal close
    document.getElementById('closeModal').addEventListener('click', function() {
        document.getElementById('deleteModal').classList.add('hidden');
    });
    
    document.getElementById('cancelDelete').addEventListener('click', function() {
        document.getElementById('deleteModal').classList.add('hidden');
    });
    
    document.getElementById('closeEditModal').addEventListener('click', function() {
        document.getElementById('editModal').classList.add('hidden');
    });
    
    document.getElementById('cancelEdit').addEventListener('click', function() {
        document.getElementById('editModal').classList.add('hidden');
    });
    
    // Toggle search form visibility
    document.getElementById('toggleSearch').addEventListener('click', function() {
        const searchForm = document.getElementById('searchForm');
        if (searchForm.classList.contains('hidden')) {
            searchForm.classList.remove('hidden');
        } else {
            searchForm.classList.add('hidden');
        }
    });
    
    // Export to CSV functionality
    document.getElementById('exportCsv').addEventListener('click', function() {
        // Create CSV content
        var csv = 'ID,Name,Username,Email,Contact,Orders\n';
        var rows = document.querySelectorAll('#customerTableBody tr:not(.empty-message)');
        
        for (var i = 0; i < rows.length; i++) {
            var row = rows[i];
            if (!row.classList.contains('empty-message')) {
                var columns = row.querySelectorAll('td');
                var id = columns[0].textContent.trim();
                var nameDiv = columns[1].querySelector('.text-sm.font-medium');
                var usernameDiv = columns[1].querySelector('.text-sm.text-gray-500');
                var name = nameDiv ? nameDiv.textContent.trim() : '';
                var username = columns[5].textContent.trim(); // Now get username from the 6th column
                var email = columns[2].textContent.trim();
                var contact = columns[3].textContent.trim();
                var orders = columns[4].querySelector('.rounded-full').textContent.trim();
                
                csv += id + ',"' + name + '","' + username + '","' + email + '","' + contact + '",' + orders + '\n';
            }
        }
        
        // Create download link
        var blob = new Blob([csv], { type: 'text/csv' });
        var url = window.URL.createObjectURL(blob);
        var a = document.createElement('a');
        a.setAttribute('hidden', '');
        a.setAttribute('href', url);
        a.setAttribute('download', 'customers_export.csv');
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
    });
    
    // Initialize page animations
    document.addEventListener('DOMContentLoaded', function() {
        var sections = document.querySelectorAll('.animate-section');
        for (var i = 0; i < sections.length; i++) {
            (function(index) {
                setTimeout(function() {
                    sections[index].classList.add('animate__animated', 'animate__fadeInUp');
                }, index * 150);
            })(i);
        }
    });

    // Handle modal close for orders modal
    document.getElementById('closeOrdersModal').addEventListener('click', function() {
        document.getElementById('ordersModal').classList.add('hidden');
    });
    
    // Function to view customer orders
    function viewOrders(userId, name) {
        // Show the modal
        document.getElementById('orderCustomerName').textContent = name;
        document.getElementById('ordersModal').classList.remove('hidden');
        
        // Show loading, hide other sections
        document.getElementById('loadingOrders').classList.remove('hidden');
        document.getElementById('ordersTable').classList.add('hidden');
        document.getElementById('noOrdersMessage').classList.add('hidden');
        document.getElementById('errorMessage').classList.add('hidden');
        
        // Fetch orders data
        fetch('${pageContext.request.contextPath}/manager/customer/orders?id=' + userId)
            .then(response => response.json())
            .then(data => {
                // Hide loading
                document.getElementById('loadingOrders').classList.add('hidden');
                
                if (data.error) {
                    // Show error message
                    document.getElementById('errorMessage').classList.remove('hidden');
                    return;
                }
                
                if (!data.orders || data.orders.length === 0) {
                    // Show no orders message
                    document.getElementById('noOrdersMessage').classList.remove('hidden');
                    return;
                }
                
                // Populate orders table
                const tableBody = document.getElementById('ordersTableBody');
                tableBody.innerHTML = ''; // Clear existing rows
                
                data.orders.forEach(order => {
                    // Format the amount as currency
                    const formattedAmount = '$' + order.amount.toLocaleString();
                    
                    // Create row
                    const row = document.createElement('tr');
                    row.className = 'hover:bg-gray-50 transition-colors';
                    
                    // Create order ID cell
                    const idCell = document.createElement('td');
                    idCell.className = 'px-4 py-4 whitespace-nowrap text-sm text-gray-900';
                    idCell.textContent = order.orderId;
                    row.appendChild(idCell);
                    
                    // Create amount cell
                    const amountCell = document.createElement('td');
                    amountCell.className = 'px-4 py-4 whitespace-nowrap text-sm font-medium text-gray-900';
                    amountCell.textContent = formattedAmount;
                    row.appendChild(amountCell);
                    
                    // Create status cell with appropriate color
                    const statusCell = document.createElement('td');
                    statusCell.className = 'px-4 py-4 whitespace-nowrap text-sm';
                    
                    let statusClass;
                    switch(order.status) {
                        case 'pending':
                            statusClass = 'bg-yellow-100 text-yellow-800';
                            break;
                        case 'processing':
                            statusClass = 'bg-blue-100 text-blue-800';
                            break;
                        case 'shipped':
                            statusClass = 'bg-indigo-100 text-indigo-800';
                            break;
                        case 'delivered':
                            statusClass = 'bg-green-100 text-green-800';
                            break;
                        case 'cancelled':
                            statusClass = 'bg-red-100 text-red-800';
                            break;
                        default:
                            statusClass = 'bg-gray-100 text-gray-800';
                    }
                    
                    const statusSpan = document.createElement('span');
                    statusSpan.className = `px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${statusClass} capitalize`;
                    statusSpan.textContent = order.status;
                    statusCell.appendChild(statusSpan);
                    row.appendChild(statusCell);
                    
                    // Create payment method cell
                    const paymentCell = document.createElement('td');
                    paymentCell.className = 'px-4 py-4 whitespace-nowrap text-sm text-gray-500';
                    paymentCell.textContent = order.paymentMethod;
                    row.appendChild(paymentCell);
                    
                    // Add row to table
                    tableBody.appendChild(row);
                });
                
                // Show orders table
                document.getElementById('ordersTable').classList.remove('hidden');
            })
            .catch(error => {
                console.error('Error fetching orders:', error);
                document.getElementById('loadingOrders').classList.add('hidden');
                document.getElementById('errorMessage').classList.remove('hidden');
            });
    }
</script>

<%@ include file="../dashboard-template-footer.jsp" %> 