<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<%@ include file="dashboard-template.jsp" %>

<!-- Orders Styles -->
<style>
    .status-badge {
        padding: 0.25rem 0.75rem;
        border-radius: 9999px;
        font-size: 0.75rem;
        font-weight: 500;
    }
    
    .status-pending {
        background-color: #FEF3C7;
        color: #D97706;
    }
    
    .status-processing {
        background-color: #DBEAFE;
        color: #2563EB;
    }
    
    .status-shipped {
        background-color: #E0E7FF;
        color: #4F46E5;
    }
    
    .status-delivered {
        background-color: #D1FAE5;
        color: #10B981;
    }
    
    .status-cancelled {
        background-color: #FEE2E2;
        color: #EF4444;
    }
    
    .table-row {
        transition: all 0.2s;
    }
    
    .table-row:hover {
        background-color: #F9FAFB;
    }
    
    .status-dropdown {
        padding: 0.5rem;
        border-radius: 0.375rem;
        border: 1px solid #E5E7EB;
        background-color: white;
        font-size: 0.875rem;
        cursor: pointer;
    }
</style>

<!-- Set page title -->
<script>
    document.addEventListener('DOMContentLoaded', function() {
        setPageTitle('Order Management');
    });
</script>

<!-- Orders Content -->
<div class="bg-white rounded-lg shadow-md overflow-hidden mb-8 animate-section">
    <div class="p-4 bg-green-500 text-white flex justify-between items-center">
        <h2 class="text-xl font-semibold">Order Management</h2>
        <div class="flex items-center space-x-2">
            <span id="totalOrders" class="text-sm bg-white text-green-500 py-1 px-3 rounded-full">Total: ${orders.size()} orders</span>
            <button class="bg-white text-green-500 py-1 px-3 rounded-full text-sm hover:bg-green-100 transition">
                <i class="fas fa-file-export mr-1"></i> Export
            </button>
        </div>
    </div>
    
    <!-- Error message if any -->
    <c:if test="${not empty error}">
        <div class="p-4 bg-red-100 text-red-700">
            ${error}
        </div>
    </c:if>
    
    <!-- Filter and Search -->
    <div class="p-4 border-b border-gray-200 bg-gray-50 flex flex-wrap items-center justify-between gap-3">
        <div class="flex items-center space-x-3">
            <div>
                <label for="statusFilter" class="text-sm text-gray-600 mr-2">Status:</label>
                <select id="statusFilter" class="rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring focus:ring-green-200 focus:ring-opacity-50">
                    <option value="all">All</option>
                    <option value="pending">Pending</option>
                    <option value="processing">Processing</option>
                    <option value="shipped">Shipped</option>
                    <option value="delivered">Delivered</option>
                    <option value="cancelled">Cancelled</option>
                </select>
            </div>
            
            <div>
                <label for="dateFilter" class="text-sm text-gray-600 mr-2">Date:</label>
                <select id="dateFilter" class="rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring focus:ring-green-200 focus:ring-opacity-50">
                    <option value="all">All Time</option>
                    <option value="today">Today</option>
                    <option value="week">This Week</option>
                    <option value="month">This Month</option>
                </select>
            </div>
        </div>
        
        <div class="relative">
            <input type="text" id="searchOrder" placeholder="Search by ID, customer, or product..." class="pl-10 pr-4 py-2 rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring focus:ring-green-200 focus:ring-opacity-50 w-80">
            <div class="absolute left-3 top-2.5 text-gray-400">
                <i class="fas fa-search"></i>
            </div>
        </div>
    </div>
    
    <!-- Orders Table -->
    <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
                <tr>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Order ID
                    </th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Customer
                    </th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Date
                    </th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Total
                    </th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Status
                    </th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Payment
                    </th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Actions
                    </th>
                </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200" id="ordersTableBody">
                <c:choose>
                    <c:when test="${empty orders}">
                        <tr id="noOrdersRow">
                            <td colspan="7" class="px-6 py-4 text-center text-sm text-gray-500">
                                No orders found
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach items="${orders}" var="order">
                            <tr class="table-row" data-status="${order.status}" data-order-id="${order.orderId}">
                                <td class="px-6 py-4 whitespace-nowrap">
                                    <div class="text-sm font-medium text-gray-900">#${order.orderId}</div>
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap">
                                    <div class="text-sm text-gray-900">${customerInfo[order.userId].name}</div>
                                    <div class="text-sm text-gray-500">${customerInfo[order.userId].email}</div>
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap">
                                    <div class="text-sm text-gray-900">
                                        <fmt:formatDate value="${order.orderDate}" pattern="MMM d, yyyy" />
                                    </div>
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap">
                                    <div class="text-sm text-gray-900">$${order.totalAmount}</div>
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap">
                                    <span class="status-badge status-${order.status}">
                                        <c:choose>
                                            <c:when test="${order.status == 'pending'}">Pending</c:when>
                                            <c:when test="${order.status == 'processing'}">Processing</c:when>
                                            <c:when test="${order.status == 'shipped'}">Shipped</c:when>
                                            <c:when test="${order.status == 'delivered'}">Delivered</c:when>
                                            <c:when test="${order.status == 'cancelled'}">Cancelled</c:when>
                                            <c:otherwise>${order.status}</c:otherwise>
                                        </c:choose>
                                    </span>
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap">
                                    <div class="text-sm text-gray-900">${order.paymentMethod}</div>
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                                    <button onclick="viewOrderDetails(${order.orderId})" class="text-indigo-600 hover:text-indigo-900 mr-3">
                                        View
                                    </button>
                                    <select onchange="updateOrderStatus(${order.orderId}, this.value)" class="status-dropdown">
                                        <option value="">Update Status</option>
                                        <option value="pending">Pending</option>
                                        <option value="processing">Processing</option>
                                        <option value="shipped">Shipped</option>
                                        <option value="delivered">Delivered</option>
                                        <option value="cancelled">Cancelled</option>
                                    </select>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
    
    <!-- Pagination -->
    <div class="px-6 py-3 flex items-center justify-between border-t border-gray-200">
        <div class="text-sm text-gray-700">
            Showing <span id="startCount">1</span> to <span id="endCount">${orders.size() > 10 ? 10 : orders.size()}</span> of <span id="totalCount">${orders.size()}</span> orders
        </div>
        <div class="flex space-x-2">
            <button class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50">
                Previous
            </button>
            <button class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50">
                Next
            </button>
        </div>
    </div>
</div>

<!-- Order Details Modal -->
<div id="orderDetailsModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 hidden">
    <div class="bg-white rounded-lg shadow-xl w-full max-w-4xl max-h-screen overflow-y-auto">
        <div class="p-4 bg-green-500 text-white flex justify-between items-center">
            <h3 class="text-lg font-semibold" id="modalOrderId">Order Details</h3>
            <button onclick="closeOrderModal()" class="text-white hover:text-gray-200">
                <i class="fas fa-times"></i>
            </button>
        </div>
        
        <div class="p-6">
            <div id="orderDetailsContent">
                <!-- Order details will be loaded here -->
                <div class="flex justify-center items-center p-10">
                    <div class="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-green-500"></div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Orders JavaScript -->
<script>
    // Initialize on document load
    document.addEventListener('DOMContentLoaded', function() {
        // Filter events
        document.getElementById('statusFilter').addEventListener('change', filterOrders);
        document.getElementById('dateFilter').addEventListener('change', filterOrders);
        document.getElementById('searchOrder').addEventListener('input', filterOrders);
        
        // Initialize counters
        updateCounters();
        
        // Add data-order-id attribute to each row on page load
        const rows = document.querySelectorAll('#ordersTableBody tr:not(#noOrdersRow)');
        rows.forEach(row => {
            const orderIdCell = row.querySelector('td:first-child div');
            if (orderIdCell) {
                const orderId = orderIdCell.textContent.replace('#', '').trim();
                row.setAttribute('data-order-id', orderId);
            }
        });
    });
    
    // Filter orders based on status, date, and search
    function filterOrders() {
        const statusFilter = document.getElementById('statusFilter').value;
        const dateFilter = document.getElementById('dateFilter').value;
        const searchFilter = document.getElementById('searchOrder').value.toLowerCase();
        
        const rows = document.querySelectorAll('#ordersTableBody tr:not(#noOrdersRow)');
        let visibleCount = 0;
        
        rows.forEach(row => {
            let shouldShow = true;
            
            // Filter by status
            if (statusFilter !== 'all') {
                const rowStatus = row.getAttribute('data-status');
                if (statusFilter !== rowStatus) {
                    shouldShow = false;
                }
            }
            
            // Filter by date
            if (dateFilter !== 'all' && shouldShow) {
                const dateCell = row.querySelector('td:nth-child(3) .text-sm').textContent.trim();
                const orderDate = new Date(dateCell);
                const today = new Date();
                
                if (dateFilter === 'today') {
                    if (orderDate.toDateString() !== today.toDateString()) {
                        shouldShow = false;
                    }
                } else if (dateFilter === 'week') {
                    // Get start of week (Sunday)
                    const startOfWeek = new Date(today);
                    startOfWeek.setDate(today.getDate() - today.getDay());
                    startOfWeek.setHours(0, 0, 0, 0);
                    
                    if (orderDate < startOfWeek) {
                        shouldShow = false;
                    }
                } else if (dateFilter === 'month') {
                    // Get start of month
                    const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
                    
                    if (orderDate < startOfMonth) {
                        shouldShow = false;
                    }
                }
            }
            
            // Filter by search
            if (searchFilter && shouldShow) {
                const orderIdCell = row.querySelector('td:nth-child(1)').textContent.toLowerCase();
                const customerNameCell = row.querySelector('td:nth-child(2) div:first-child').textContent.toLowerCase();
                const customerEmailCell = row.querySelector('td:nth-child(2) div:last-child').textContent.toLowerCase();
                
                if (!orderIdCell.includes(searchFilter) && 
                    !customerNameCell.includes(searchFilter) && 
                    !customerEmailCell.includes(searchFilter)) {
                    shouldShow = false;
                }
            }
            
            // Show or hide row
            if (shouldShow) {
                row.classList.remove('hidden');
                visibleCount++;
            } else {
                row.classList.add('hidden');
            }
        });
        
        // Show or hide "No orders found" message
        const noOrdersRow = document.getElementById('noOrdersRow');
        if (!noOrdersRow) {
            // Create "No orders found" row if it doesn't exist
            if (visibleCount === 0) {
                const tbody = document.getElementById('ordersTableBody');
                const newRow = document.createElement('tr');
                newRow.id = 'noOrdersRow';
                newRow.innerHTML = `
                    <td colspan="7" class="px-6 py-4 text-center text-sm text-gray-500">
                        No orders found matching your filters
                    </td>
                `;
                tbody.appendChild(newRow);
            }
        } else {
            // Toggle existing row
            noOrdersRow.classList.toggle('hidden', visibleCount > 0);
        }
        
        // Update counters
        updateCounters(visibleCount);
    }
    
    // Update counter displays
    function updateCounters(visibleCount) {
        const rows = document.querySelectorAll('#ordersTableBody tr:not(#noOrdersRow):not(.hidden)');
        visibleCount = visibleCount || rows.length;
        
        document.getElementById('totalOrders').textContent = `Total: ${visibleCount} orders`;
        document.getElementById('startCount').textContent = visibleCount > 0 ? '1' : '0';
        document.getElementById('endCount').textContent = Math.min(10, visibleCount);
        document.getElementById('totalCount').textContent = visibleCount;
    }
    
    // View order details
    function viewOrderDetails(orderId) {
        // Show modal
        document.getElementById('orderDetailsModal').classList.remove('hidden');
        document.getElementById('modalOrderId').textContent = `Order #${orderId}`;
        
        // Display loading spinner
        document.getElementById('orderDetailsContent').innerHTML = `
            <div class="flex justify-center items-center p-10">
                <div class="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-green-500"></div>
            </div>
        `;
        
        // Load order details via AJAX
const apiUrl = `${window.location.origin}${window.location.pathname.substring(0, window.location.pathname.lastIndexOf('/orders'))}/orders/${orderId}`;

        fetch(apiUrl)
            .then(response => {
                if (!response.ok) {
                    throw new Error(`Failed to load order details (Status: ${response.status})`);
                }
                return response.json();
            })
            .then(data => {
                // Format and display order details
                const orderDetails = document.getElementById('orderDetailsContent');
                
                // Format date
                const orderDate = new Date(data.orderDate);
                const formattedDate = orderDate.toLocaleDateString('en-US', {
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric'
                });
                
                // Store the current status to set selected option after rendering
                
                // Build the HTML for order details
                let itemsHtml = '';
                let subtotal = 0;
                
                if (data.items && data.items.length > 0) {
                    data.items.forEach(item => {
                        const itemTotal = item.price * item.quantity;
                        subtotal += itemTotal;
                        
                        itemsHtml += `
                            <tr>
                                <td class="px-4 py-2 whitespace-nowrap">
                                    <div class="text-sm text-gray-900">${item.productName}</div>
                                </td>
                                <td class="px-4 py-2 whitespace-nowrap">
                                    <div class="text-sm text-gray-900">$${item.price.toFixed(2)}</div>
                                </td>
                                <td class="px-4 py-2 whitespace-nowrap">
                                    <div class="text-sm text-gray-900">${item.quantity}</div>
                                </td>
                                <td class="px-4 py-2 whitespace-nowrap">
                                    <div class="text-sm text-gray-900">$${itemTotal.toFixed(2)}</div>
                                </td>
                            </tr>
                        `;
                    });
                } else {
                    itemsHtml = `
                        <tr>
                            <td colspan="4" class="px-4 py-2 text-center text-sm text-gray-500">
                                No items found for this order
                            </td>
                        </tr>
                    `;
                }
                
                orderDetails.innerHTML = `
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
                        <div>
                            <h4 class="text-sm font-medium text-gray-500 mb-1">Customer Info</h4>
                            <p class="text-sm">${data.customerName}</p>
                            <p class="text-sm">${data.customerEmail}</p>
                            <p class="text-sm">${data.customerPhone || 'No phone provided'}</p>
                        </div>
                        
                        <div>
                            <h4 class="text-sm font-medium text-gray-500 mb-1">Shipping Address</h4>
                            <p class="text-sm">${data.shippingAddress}</p>
                        </div>
                        
                        <div>
                            <h4 class="text-sm font-medium text-gray-500 mb-1">Order Info</h4>
                            <p class="text-sm">Date: ${formattedDate}</p>
                            <p class="text-sm">Payment: ${data.paymentMethod}</p>
                            <div class="mt-2">
                                <label for="modalOrderStatus" class="text-sm font-medium text-gray-500 mr-2">Status:</label>
                                <select id="modalOrderStatus" class="rounded text-sm border-gray-300 focus:border-green-500 focus:ring focus:ring-green-200 focus:ring-opacity-50">
                                    <option value="pending">Pending</option>
                                    <option value="processing">Processing</option>
                                    <option value="shipped">Shipped</option>
                                    <option value="delivered">Delivered</option>
                                    <option value="cancelled">Cancelled</option>
                                </select>
                                <button onclick="updateOrderStatusFromModal(${data.orderId})" class="ml-2 px-3 py-1 text-sm bg-green-500 text-white rounded hover:bg-green-600">
                                    Update
                                </button>
                            </div>
                        </div>
                    </div>
                    
                    <div class="border-t border-gray-200 pt-4 mb-4">
                        <h4 class="font-medium text-gray-700 mb-3">Order Items</h4>
                        <div class="overflow-x-auto">
                            <table class="min-w-full divide-y divide-gray-200">
                                <thead class="bg-gray-50">
                                    <tr>
                                        <th scope="col" class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                            Product
                                        </th>
                                        <th scope="col" class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                            Price
                                        </th>
                                        <th scope="col" class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                            Quantity
                                        </th>
                                        <th scope="col" class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                            Total
                                        </th>
                                    </tr>
                                </thead>
                                <tbody class="bg-white divide-y divide-gray-200">
                                    ${itemsHtml}
                                </tbody>
                            </table>
                        </div>
                    </div>
                    
                    <div class="border-t border-gray-200 pt-4 flex justify-between">
                        <div></div>
                        <div class="text-right">
                            <div class="text-sm mb-1">Subtotal: $${data.totalAmount.toFixed(2)}</div>
                            <div class="text-sm mb-1">Shipping: $0.00</div>
                            <div class="text-lg font-semibold">Total: $${data.totalAmount.toFixed(2)}</div>
                        </div>
                    </div>
                    
                    <div class="flex justify-end mt-6">
                        <button onclick="closeOrderModal()" class="px-4 py-2 bg-gray-200 text-gray-800 rounded-md hover:bg-gray-300 mr-2">
                            Close
                        </button>
                        <button onclick="printOrderInvoice(${data.orderId})" class="px-4 py-2 bg-green-500 text-white rounded-md hover:bg-green-600">
                            <i class="fas fa-print mr-1"></i> Print Invoice
                        </button>
                    </div>
                `;
                
                // Set the selected option in the status dropdown
                setTimeout(() => {
                    const statusSelect = document.getElementById('modalOrderStatus');
                    if (statusSelect && data.status) {
                        // Find and select the option matching the current status
                        for (let i = 0; i < statusSelect.options.length; i++) {
                            if (statusSelect.options[i].value === data.status) {
                                statusSelect.selectedIndex = i;
                                break;
                            }
                        }
                    }
                }, 0);
            })
            .catch(error => {
                console.error('Error:', error);
                document.getElementById('orderDetailsContent').innerHTML = `
                    <div class="p-4 text-red-500">
                        <p>Error loading order details: ${error.message}</p>
                        <p class="mt-2 text-gray-600 text-sm">Please try again or contact the IT department if the issue persists.</p>
                        <button onclick="closeOrderModal()" class="mt-4 px-4 py-2 bg-gray-200 text-gray-800 rounded-md hover:bg-gray-300">
                            Close
                        </button>
                    </div>
                `;
            });
    }
    
    // Close order details modal
    function closeOrderModal() {
        document.getElementById('orderDetailsModal').classList.add('hidden');
    }
    
    // Update order status
    function updateOrderStatus(orderId, status) {
        if (!status) return; // No status selected
        
        // Customize confirmation message based on action
        let confirmMessage = `Are you sure you want to update order #${orderId} status to ${status.charAt(0).toUpperCase() + status.slice(1)}?`;
        
        if (status === 'cancelled') {
            confirmMessage = `Are you sure you want to cancel order #${orderId}? This will permanently delete the order from the system.`;
        }
        
        // Show confirmation dialog
        if (confirm(confirmMessage)) {
            // Show loading state
            const row = document.querySelector(`tr[data-order-id="${orderId}"]`) || 
                       Array.from(document.querySelectorAll('#ordersTableBody tr')).find(row => 
                           row.querySelector('td:first-child').textContent.includes(`#${orderId}`)
                       );
                
            if (row) {
                const statusCell = row.querySelector('td:nth-child(5) .status-badge');
                if (statusCell) {
                    statusCell.innerHTML = `<span class="animate-pulse">Updating...</span>`;
                }
            }
            
            // Get the context path
            const contextPath = window.location.pathname.substring(0, window.location.pathname.lastIndexOf('/orders'));
            
            // Send AJAX request to update status
            fetch(`${contextPath}/orders`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: `action=updateStatus&orderId=${orderId}&status=${status}`
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error(`Failed to update order status (Status: ${response.status})`);
                }
                return response.json();
            })
            .then(data => {
                if (data.success) {
                    // For cancelled orders, remove the row immediately
                    if (status === 'cancelled') {
                        if (row) {
                            // Fade out animation before removal
                            row.style.transition = 'opacity 0.5s ease-out';
                            row.style.opacity = '0';
                            
                            // Remove after animation completes
                            setTimeout(() => {
                                row.remove();
                                updateCounters();
                                
                                // Check if we need to show "No orders found" message
                                const visibleRows = document.querySelectorAll('#ordersTableBody tr:not(.hidden):not(#noOrdersRow)');
                                if (visibleRows.length === 0) {
                                    const tbody = document.getElementById('ordersTableBody');
                                    const noOrdersRow = document.getElementById('noOrdersRow') || document.createElement('tr');
                                    
                                    if (!document.getElementById('noOrdersRow')) {
                                        noOrdersRow.id = 'noOrdersRow';
                                        noOrdersRow.innerHTML = `
                                            <td colspan="7" class="px-6 py-4 text-center text-sm text-gray-500">
                                                No orders found matching your filters
                                            </td>
                                        `;
                                        tbody.appendChild(noOrdersRow);
                                    } else {
                                        noOrdersRow.classList.remove('hidden');
                                    }
                                }
                            }, 500);
                            
                            // Show success message
                            alert('Order has been cancelled and removed from the system');
                        } else {
                            // If row not found, refresh the page
                            window.location.reload();
                        }
                    } else {
                        // Regular status update (not cancellation)
                        if (row) {
                            // Update data attribute
                            row.setAttribute('data-status', status);
                            
                            // Update status badge
                            const statusBadge = row.querySelector('.status-badge');
                            if (statusBadge) {
                                // Remove all status classes
                                statusBadge.classList.remove('status-pending', 'status-processing', 'status-shipped', 'status-delivered', 'status-cancelled');
                                
                                // Add the new status class
                                statusBadge.classList.add(`status-${status}`);
                                
                                // Update the text
                                statusBadge.textContent = status.charAt(0).toUpperCase() + status.slice(1);
                            }
                            
                            // Show success message
                            alert('Order status updated successfully');
                            
                            // Apply filters after update
                            filterOrders();
                        } else {
                            // If row not found, refresh the page
                            window.location.reload();
                        }
                    }
                } else {
                    alert(`Failed to update order status: ${data.message || 'Unknown error'}`);
                    // Refresh the page to show current data
                    window.location.reload();
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert(`An error occurred while updating the order status: ${error.message}`);
                // Refresh the page to show current data
                window.location.reload();
            });
        }
    }
    
    // Update order status from modal
    function updateOrderStatusFromModal(orderId) {
        const status = document.getElementById('modalOrderStatus').value;
        
        // Special handling for cancellation from modal
        if (status === 'cancelled') {
            if (confirm('Are you sure you want to cancel this order? This will permanently delete the order from the system.')) {
                // Close the modal first
                closeOrderModal();
                
                // Then process the cancellation
                updateOrderStatus(orderId, status);
            }
        } else {
            updateOrderStatus(orderId, status);
            
            // Also update the status in the modal
            const statusSelect = document.getElementById('modalOrderStatus');
            if (statusSelect) {
                const statusText = statusSelect.options[statusSelect.selectedIndex].text;
                
                // Add a temporary message
                const label = statusSelect.previousElementSibling;
                const originalText = label.textContent;
                label.innerHTML = `${originalText} <span class="text-green-500">(Updated!)</span>`;
                
                // Remove the message after 2 seconds
                setTimeout(() => {
                    label.textContent = originalText;
                }, 2000);
            }
        }
    }
    
    // Print order invoice
    function printOrderInvoice(orderId) {
        // Get the context path
        const contextPath = window.location.pathname.substring(0, window.location.pathname.lastIndexOf('/orders'));
        
        // Redirect to invoice page
        window.open(`${contextPath}/invoice?orderId=${orderId}`, '_blank');
    }
</script>