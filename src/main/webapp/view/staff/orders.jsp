<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<%@ include file="dashboard-template.jsp" %>

<!-- Set context path as JavaScript variable -->
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<!-- Orders Styles -->
<style>
    .status-badge {
        padding: 0.25rem 0.75rem;
        border-radius: 9999px;
        font-size: 0.75rem;
        font-weight: 500;
    }
    
    .status-pending, .status-packaging {
        background-color: #FEF3C7;
        color: #D97706;
    }
    
    .status-processing, .status-shipping {
        background-color: #DBEAFE;
        color: #2563EB;
    }
    
    .status-shipped, .status-delivery {
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

<!-- Define JavaScript functions first -->
<script>
    // Get the application context path from the JSP variable
    const contextPath = "${contextPath}";
    
    // Use base URL from current page location
    const baseUrl = window.location.origin;
    
    // Print debug info
    console.log('Context path is:', contextPath);
    console.log('Base URL is:', baseUrl);
    console.log('Full URL:', window.location.href);
    
    // View order details function - Get data from the table
    function viewOrderDetails(orderId) {
        // Convert orderId to integer
        orderId = parseInt(orderId, 10);
        
        // Validate order ID
        if (isNaN(orderId) || orderId <= 0) {
            console.error('Invalid order ID:', orderId);
            alert('Invalid order ID');
            return;
        }
        
        // Show modal
        document.getElementById('orderDetailsModal').classList.remove('hidden');
        document.getElementById('modalOrderId').textContent = `Order #${orderId}`;
        
        // Display loading spinner
        document.getElementById('orderDetailsContent').innerHTML = `
            <div class="flex justify-center items-center p-10">
                <div class="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-green-500"></div>
            </div>
        `;
        
        // Find the row with the specified order ID
        const rows = document.querySelectorAll('tr[data-order-id]');
        
        let foundRow = null;
        rows.forEach(row => {
            const rowId = row.getAttribute('data-order-id');
            if (rowId == orderId) {
                foundRow = row;
            }
        });
        
        const row = foundRow;
        
        if (!row) {
            console.error("Failed to find row for order ID:", orderId);
            document.getElementById('orderDetailsContent').innerHTML = `
                <div class="p-4 text-red-500">
                    <p>Error: Could not find order data in the table (Order ID: ${orderId})</p>
                    <p class="mt-2 text-gray-600 text-sm">Please try refreshing the page and try again.</p>
                    <button onclick="closeOrderModal()" class="mt-4 px-4 py-2 bg-gray-200 text-gray-800 rounded-md hover:bg-gray-300">
                        Close
                    </button>
                </div>
            `;
            return;
        }
        
        try {
            // Initialize variables with default values
            let customerName = "Not available";
            let customerEmail = "Not available";
            let dateText = "Not available";
            let totalAmount = 0;
            let status = "pending";
            let paymentMethod = "Not available";
            
            // Get customer name and email
            const nameCell = row.querySelector('td:nth-child(2)');
            if (nameCell) {
                const nameDiv = nameCell.querySelector('.text-gray-900');
                const emailDiv = nameCell.querySelector('.text-gray-500');
                
                if (nameDiv) customerName = nameDiv.textContent.trim();
                if (emailDiv) customerEmail = emailDiv.textContent.trim();
            }
            
            // Get date
            const dateCell = row.querySelector('td:nth-child(3)');
            if (dateCell) {
                const dateDiv = dateCell.querySelector('.text-gray-900');
                if (dateDiv) dateText = dateDiv.textContent.trim();
            }
            
            // Get total
            const totalCell = row.querySelector('td:nth-child(4)');
            if (totalCell) {
                const totalDiv = totalCell.querySelector('.text-gray-900');
                if (totalDiv) {
                    const totalText = totalDiv.textContent.trim();
                    totalAmount = parseFloat(totalText.replace('$', '')) || 0;
                }
            }
            
            // Get status
            const statusCell = row.querySelector('td:nth-child(5)');
            if (statusCell) {
                const statusBadge = statusCell.querySelector('.status-badge');
                if (statusBadge) {
                    // Get status from the data attribute first (most reliable)
                    status = row.getAttribute('data-status') || 'pending';
                    
                    // If that doesn't work, try to get from status badge text
                    if (!status) {
                        const badgeText = statusBadge.textContent.trim();
                        if (badgeText) status = badgeText.toLowerCase();
                    }
                }
            }
            
            // Get payment method
            const paymentCell = row.querySelector('td:nth-child(6)');
            if (paymentCell) {
                const paymentDiv = paymentCell.querySelector('.text-gray-900');
                if (paymentDiv) paymentMethod = paymentDiv.textContent.trim();
            }
            
            // Format date for display
            const orderDate = new Date(dateText);
            const formattedDate = orderDate.toString() !== "Invalid Date" ? 
                orderDate.toLocaleDateString('en-US', {
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric'
                }) : dateText;
            
            // Capitalize status for display
            const displayStatus = status.charAt(0).toUpperCase() + status.slice(1);
            
            // Format and display order details
            const orderDetails = document.getElementById('orderDetailsContent');
            
            // Clear existing content
            orderDetails.innerHTML = '';
            
            // Create elements directly instead of using template literals
            const container = document.createElement('div');
            container.className = 'grid grid-cols-1 md:grid-cols-2 gap-6 mb-6';
            
            // Customer Info section
            const customerSection = document.createElement('div');
            const customerTitle = document.createElement('h4');
            customerTitle.className = 'text-sm font-medium text-gray-500 mb-1';
            customerTitle.textContent = 'Customer Info';
            const customerNameP = document.createElement('p');
            customerNameP.className = 'text-sm';
            customerNameP.textContent = customerName;
            const customerEmailP = document.createElement('p');
            customerEmailP.className = 'text-sm';
            customerEmailP.textContent = customerEmail;
            customerSection.appendChild(customerTitle);
            customerSection.appendChild(customerNameP);
            customerSection.appendChild(customerEmailP);
            
            // Order Info section
            const orderInfoSection = document.createElement('div');
            const orderInfoTitle = document.createElement('h4');
            orderInfoTitle.className = 'text-sm font-medium text-gray-500 mb-1';
            orderInfoTitle.textContent = 'Order Info';
            const dateP = document.createElement('p');
            dateP.className = 'text-sm';
            dateP.textContent = "Date: " + (formattedDate || "Not available");
            const paymentP = document.createElement('p');
            paymentP.className = 'text-sm';
            paymentP.textContent = "Payment: " + (paymentMethod || "Not available");
            
            const statusDiv = document.createElement('div');
            statusDiv.className = 'mt-2';
            const statusLabel = document.createElement('label');
            statusLabel.className = 'text-sm font-medium text-gray-500 mr-2';
            statusLabel.textContent = 'Status:';
            const statusBadge = document.createElement('span');
            statusBadge.className = `text-sm status-badge status-${status}`;
            statusBadge.textContent = displayStatus || "Unknown";
            
            statusDiv.appendChild(statusLabel);
            statusDiv.appendChild(statusBadge);
            
            orderInfoSection.appendChild(orderInfoTitle);
            orderInfoSection.appendChild(dateP);
            orderInfoSection.appendChild(paymentP);
            orderInfoSection.appendChild(statusDiv);
            
            // Add all sections to the container
            container.appendChild(customerSection);
            container.appendChild(orderInfoSection);
            
            // Create the total display
            const totalDiv = document.createElement('div');
            totalDiv.className = 'border-t border-gray-200 pt-4 text-right';
            const totalText = document.createElement('div');
            totalText.className = 'text-sm mb-1 font-medium';
            
            // Format the total properly
            let formattedTotal = "$0.00";
            if (totalAmount) {
                formattedTotal = "$" + totalAmount.toFixed(2);
            }
            totalText.textContent = "Total: " + formattedTotal;
            totalDiv.appendChild(totalText);
            
            // Add close button
            const buttonsDiv = document.createElement('div');
            buttonsDiv.className = 'flex justify-end mt-6';
            
            const closeButton = document.createElement('button');
            closeButton.className = 'px-4 py-2 bg-gray-200 text-gray-800 rounded-md hover:bg-gray-300';
            closeButton.textContent = 'Close';
            closeButton.onclick = function() {
                closeOrderModal();
            };
            
            buttonsDiv.appendChild(closeButton);
            
            // Add all components to the order details
            orderDetails.appendChild(container);
            orderDetails.appendChild(totalDiv);
            orderDetails.appendChild(buttonsDiv);
        } catch (error) {
            console.error('Error extracting data:', error);
            document.getElementById('orderDetailsContent').innerHTML = `
                <div class="p-4 text-red-500">
                    <p>Error processing order details: ${error.message}</p>
                    <p class="mt-2 text-gray-600 text-sm">Please try again or contact the IT department if the issue persists.</p>
                    <button onclick="closeOrderModal()" class="mt-4 px-4 py-2 bg-gray-200 text-gray-800 rounded-md hover:bg-gray-300">
                        Close
                    </button>
                </div>
            `;
        }
    }
    
    // Update order status function - Use form submit + target iframe to stay on page
    function updateOrderStatus(orderId, status) {
        // Convert orderId to integer
        orderId = parseInt(orderId, 10);
        
        if (!status) return; // No status selected
        
        console.log("Starting update for order ID:", orderId, "to status:", status);
        
        // Customize confirmation message based on action
        let confirmMessage = `Are you sure you want to update order #${orderId} status to ${status.charAt(0).toUpperCase() + status.slice(1)}?`;
        
        // Show confirmation dialog
        if (confirm(confirmMessage)) {
            // Show loading state
            const row = document.querySelector(`tr[data-order-id="${orderId}"]`);
            console.log("Found row for update:", row);
                
            if (row) {
                const statusCell = row.querySelector('td:nth-child(5) .status-badge');
                if (statusCell) {
                    console.log("Current status display:", statusCell.textContent);
                    statusCell.innerHTML = `<span class="animate-pulse">Updating...</span>`;
                }
            }
            
            // Create iframe if it doesn't exist
            let statusIframe = document.getElementById('statusUpdateIframe');
            if (!statusIframe) {
                statusIframe = document.createElement('iframe');
                statusIframe.id = 'statusUpdateIframe';
                statusIframe.name = 'statusUpdateIframe';
                statusIframe.style.display = 'none';
                document.body.appendChild(statusIframe);
            }
            
            // Create a form to submit
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = `${baseUrl}${contextPath}/orders`;
            form.target = 'statusUpdateIframe'; // Target the hidden iframe
            form.style.display = 'none';
            
            // Add input fields
            const actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'updateStatus';
            form.appendChild(actionInput);
            
            const orderIdInput = document.createElement('input');
            orderIdInput.type = 'hidden';
            orderIdInput.name = 'orderId';
            orderIdInput.value = orderId;
            form.appendChild(orderIdInput);
            
            const statusInput = document.createElement('input');
            statusInput.type = 'hidden';
            statusInput.name = 'status';
            statusInput.value = status;
            form.appendChild(statusInput);
            
            // Log what we're sending
            console.log("Submitting form with data:", {
                action: 'updateStatus',
                orderId: orderId,
                status: status
            });
            
            // Handle iframe load (response)
            statusIframe.onload = function() {
                try {
                    // Try to extract response text from iframe
                    const iframeContent = statusIframe.contentDocument || statusIframe.contentWindow.document;
                    const responseText = iframeContent.body.textContent;
                    
                    console.log("Status update response:", responseText);
                    
                    try {
                        // Try parsing as JSON
                        const jsonResponse = JSON.parse(responseText);
                        console.log("Parsed JSON response:", jsonResponse);
                        
                        if (jsonResponse.success) {
                            console.log("Status update successful!");
                        } else {
                            console.error("Status update failed:", jsonResponse.message);
                            alert("Failed to update status: " + jsonResponse.message);
                            return;
                        }
                    } catch (e) {
                        console.log("Response is not JSON, assuming success");
                    }
                    
                    // Update UI immediately
                    if (row) {
                        // Update data attribute
                        row.setAttribute('data-status', status);
                        console.log("Updated row data-status to:", status);
                        
                        // Update status badge
                        const statusBadge = row.querySelector('td:nth-child(5) .status-badge');
                        if (statusBadge) {
                            // Remove all status classes
                            statusBadge.classList.remove('status-packaging', 'status-shipping', 'status-delivery', 'status-delivered');
                            
                            // Add the new status class
                            statusBadge.classList.add(`status-${status}`);
                            
                            // Update the text with proper capitalization
                            let displayStatus = status;
                            if (status === 'packaging') displayStatus = 'Packaging';
                            else if (status === 'shipping') displayStatus = 'Shipping';
                            else if (status === 'delivery') displayStatus = 'Delivery';
                            else if (status === 'delivered') displayStatus = 'Delivered';
                            else displayStatus = status.charAt(0).toUpperCase() + status.slice(1);
                            
                            statusBadge.textContent = displayStatus;
                            
                            console.log("Updated status badge to:", statusBadge.textContent);
                        }
                        
                        // Show success message
                        alert('Order status updated successfully');
                    }
                } catch (error) {
                    console.error("Error handling iframe response:", error);
                    alert("Error handling status update response");
                }
            };
            
            // Submit form to iframe
            document.body.appendChild(form);
            form.submit();
            document.body.removeChild(form);
            console.log("Form submitted");
        }
    }
    
    // Close order details modal
    function closeOrderModal() {
        document.getElementById('orderDetailsModal').classList.add('hidden');
    }
    
    // Update order status from modal
    function updateOrderStatusFromModal(orderId) {
        // Ensure orderId is an integer
        orderId = parseInt(orderId, 10);
        
        // Get the status from the select element
        const statusSelect = document.getElementById('modalOrderStatus');
        const status = statusSelect.value;
        
        if (!status || status === '') {
            alert('Please select a status');
            return;
        }
        
        console.log(`Updating order #${orderId} to status: ${status}`);
        
        // Close the modal first
        closeOrderModal();
        
        // Then update the status
        updateOrderStatus(orderId, status);
    }
</script>

<!-- Set page title -->
<script>
    document.addEventListener('DOMContentLoaded', function() {
        setPageTitle('Order Management');
        
        // Ensure all status dropdowns have proper event listeners
        document.querySelectorAll('.status-dropdown').forEach(function(dropdown) {
            dropdown.addEventListener('change', function() {
                const orderId = this.getAttribute('data-order-id');
                const status = this.value;
                if (orderId && status) {
                    updateOrderStatus(orderId, status);
                }
            });
        });
        
        // Filter events
        if (document.getElementById('statusFilter')) {
            document.getElementById('statusFilter').addEventListener('change', filterOrders);
        }
        if (document.getElementById('dateFilter')) {
            document.getElementById('dateFilter').addEventListener('change', filterOrders);
        }
        if (document.getElementById('searchOrder')) {
            document.getElementById('searchOrder').addEventListener('input', filterOrders);
        }
    });
</script>

<!-- Orders Content -->
<div class="bg-white rounded-lg shadow-md overflow-hidden mb-8 animate-section">
    <div class="p-4 bg-green-500 text-white flex justify-between items-center">
        <h2 class="text-xl font-semibold">Order Management</h2>
        <div class="flex items-center space-x-2">
            <span id="totalOrders" class="text-sm bg-white text-green-500 py-1 px-3 rounded-full">Total: ${orders.size()} orders</span>     
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
                    <option value="packaging">Packaging (Pending)</option>
                    <option value="shipping">Shipping (Processing)</option>
                    <option value="delivery">Delivery (Shipped)</option>
                    <option value="delivered">Delivered</option>
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
                                            <c:when test="${order.status == 'packaging'}">Packaging</c:when>
                                            <c:when test="${order.status == 'shipping'}">Shipping</c:when>
                                            <c:when test="${order.status == 'delivery'}">Delivery</c:when>
                                            <c:when test="${order.status == 'delivered'}">Delivered</c:when>
                                            <c:otherwise>${order.status}</c:otherwise>
                                        </c:choose>
                                    </span>
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap">
                                    <div class="text-sm text-gray-900">${order.paymentMethod}</div>
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                                    <button data-order-id="${order.orderId}" onclick="viewOrderDetails(this.getAttribute('data-order-id'))" class="text-indigo-600 hover:text-indigo-900 mr-3">
                                        View
                                    </button>
                                    <select data-order-id="${order.orderId}" onchange="updateOrderStatus(this.getAttribute('data-order-id'), this.value)" class="status-dropdown">
                                        <option value="">Update Status</option>
                                        <option value="packaging">Packaging (Pending)</option>
                                        <option value="shipping">Shipping (Processing)</option>
                                        <option value="delivery">Delivery (Shipped)</option>
                                        <option value="delivered">Delivered</option>
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

<script>
// Define filtering variables
let currentPage = 1;
const itemsPerPage = 10;
let filteredOrders = [];

// Filter orders based on selected criteria
function filterOrders() {
    const statusFilter = document.getElementById('statusFilter').value;
    const dateFilter = document.getElementById('dateFilter').value;
    const searchTerm = document.getElementById('searchOrder').value.toLowerCase().trim();
    
    console.log('Filtering orders with:', { status: statusFilter, date: dateFilter, search: searchTerm });
    
    // Get all order rows
    const allRows = Array.from(document.querySelectorAll('#ordersTableBody tr[data-order-id]'));
    
    // Debug log all available statuses in the table
    const availableStatuses = new Set();
    allRows.forEach(row => {
        const status = row.getAttribute('data-status');
        if (status) availableStatuses.add(status);
    });
    console.log('Available statuses in table:', Array.from(availableStatuses));
    
    // If no filters are active and no search term, show all rows
    if (statusFilter === 'all' && dateFilter === 'all' && !searchTerm) {
        filteredOrders = allRows;
        updatePagination(1);
        return;
    }
    
    // Apply filters
    filteredOrders = allRows.filter(row => {
        let matchesStatus = true;
        let matchesDate = true;
        let matchesSearch = true;
        
        // Status filter
        if (statusFilter !== 'all') {
            // Get status from the row's data attribute
            const rowStatus = row.getAttribute('data-status');
            
            // Get status from the badge element as fallback
            let badgeStatus = null;
            const statusBadge = row.querySelector('.status-badge');
            if (statusBadge) {
                // Extract class that starts with 'status-' but isn't 'status-badge'
                const statusClasses = Array.from(statusBadge.classList).filter(cls => 
                    cls.startsWith('status-') && cls !== 'status-badge'
                );
                
                if (statusClasses.length > 0) {
                    // Extract actual status from class name (remove 'status-' prefix)
                    badgeStatus = statusClasses[0].replace('status-', '');
                }
            }
            
            // Use row status if available, otherwise fallback to badge status
            const effectiveStatus = rowStatus || badgeStatus;
            console.log(`Row ${row.getAttribute('data-order-id')} status: ${effectiveStatus}, filter: ${statusFilter}`);
            
            // Check if status matches filter
            matchesStatus = effectiveStatus === statusFilter;
        }
        
        // Date filter
        if (dateFilter !== 'all') {
            const dateCell = row.querySelector('td:nth-child(3) .text-sm');
            if (dateCell) {
                const orderDateStr = dateCell.textContent.trim();
                const orderDate = new Date(orderDateStr);
                const now = new Date();
                
                // Date filtering logic
                if (dateFilter === 'today') {
                    // Check if same day
                    matchesDate = orderDate.toDateString() === now.toDateString();
                } else if (dateFilter === 'week') {
                    // Check if within the last 7 days
                    const oneWeekAgo = new Date(now);
                    oneWeekAgo.setDate(now.getDate() - 7);
                    matchesDate = orderDate >= oneWeekAgo;
                } else if (dateFilter === 'month') {
                    // Check if same month and year
                    matchesDate = 
                        orderDate.getMonth() === now.getMonth() && 
                        orderDate.getFullYear() === now.getFullYear();
                }
            }
        }
        
        // Search term filter
        if (searchTerm) {
            // Search in order ID
            const orderId = row.getAttribute('data-order-id');
            
            // Search in customer name and email
            const customerCell = row.querySelector('td:nth-child(2)');
            const customerName = customerCell ? customerCell.querySelector('.text-gray-900').textContent.toLowerCase() : '';
            const customerEmail = customerCell ? customerCell.querySelector('.text-gray-500').textContent.toLowerCase() : '';
            
            // Combined search
            matchesSearch = 
                orderId.includes(searchTerm) || 
                customerName.includes(searchTerm) || 
                customerEmail.includes(searchTerm);
        }
        
        // Order must match all active filters
        return matchesStatus && matchesDate && matchesSearch;
    });
    
    // Reset to first page when filtering
    updatePagination(1);
}

// Update pagination display and control visibility of rows
function updatePagination(page) {
    // Save current page
    currentPage = page;
    
    // Calculate indices
    const startIndex = (page - 1) * itemsPerPage;
    const endIndex = Math.min(startIndex + itemsPerPage, filteredOrders.length);
    
    // Hide all rows first
    const allRows = document.querySelectorAll('#ordersTableBody tr[data-order-id]');
    allRows.forEach(row => {
        row.style.display = 'none';
    });
    
    // Show filtered rows for current page
    for (let i = startIndex; i < endIndex; i++) {
        if (filteredOrders[i]) {
            filteredOrders[i].style.display = '';
        }
    }
    
    // Handle empty results
    const noOrdersRow = document.getElementById('noOrdersRow');
    if (filteredOrders.length === 0) {
        // If no orders row doesn't exist, create it
        if (!noOrdersRow) {
            const tbody = document.getElementById('ordersTableBody');
            const newRow = document.createElement('tr');
            newRow.id = 'noOrdersRow';
            newRow.innerHTML = `
                <td colspan="7" class="px-6 py-4 text-center text-sm text-gray-500">
                    No orders match your filter criteria
                </td>
            `;
            tbody.appendChild(newRow);
        } else {
            noOrdersRow.style.display = '';
        }
    } else if (noOrdersRow) {
        // Hide the no orders row if we have results
        noOrdersRow.style.display = 'none';
    }
    
    // Update pagination text
    document.getElementById('startCount').textContent = filteredOrders.length > 0 ? startIndex + 1 : 0;
    document.getElementById('endCount').textContent = endIndex;
    document.getElementById('totalCount').textContent = filteredOrders.length;
    
    // Update button states
    const prevButton = document.querySelector('.pagination-prev');
    const nextButton = document.querySelector('.pagination-next');
    
    if (prevButton) {
        prevButton.disabled = page <= 1;
        prevButton.classList.toggle('opacity-50', page <= 1);
    }
    
    if (nextButton) {
        nextButton.disabled = endIndex >= filteredOrders.length;
        nextButton.classList.toggle('opacity-50', endIndex >= filteredOrders.length);
    }
}

// Handle previous page button
function goToPrevPage() {
    if (currentPage > 1) {
        updatePagination(currentPage - 1);
    }
}

// Handle next page button
function goToNextPage() {
    const maxPage = Math.ceil(filteredOrders.length / itemsPerPage);
    if (currentPage < maxPage) {
        updatePagination(currentPage + 1);
    }
}

// Initialize filtering and pagination when the page loads
document.addEventListener('DOMContentLoaded', function() {
    // Setup pagination buttons
    const prevButton = document.querySelector('.flex.space-x-2 button:first-child');
    const nextButton = document.querySelector('.flex.space-x-2 button:last-child');
    
    if (prevButton) {
        prevButton.classList.add('pagination-prev');
        prevButton.addEventListener('click', goToPrevPage);
    }
    
    if (nextButton) {
        nextButton.classList.add('pagination-next');
        nextButton.addEventListener('click', goToNextPage);
    }
    
    // Ensure all status dropdowns have proper event listeners
    document.querySelectorAll('.status-dropdown').forEach(function(dropdown) {
        dropdown.addEventListener('change', function() {
            const orderId = this.getAttribute('data-order-id');
            const status = this.value;
            if (orderId && status) {
                updateOrderStatus(orderId, status);
            }
        });
    });
    
    // Filter events
    if (document.getElementById('statusFilter')) {
        document.getElementById('statusFilter').addEventListener('change', filterOrders);
    }
    if (document.getElementById('dateFilter')) {
        document.getElementById('dateFilter').addEventListener('change', filterOrders);
    }
    if (document.getElementById('searchOrder')) {
        document.getElementById('searchOrder').addEventListener('input', filterOrders);
    }
    
    // Initialize with all orders
    const allRows = Array.from(document.querySelectorAll('#ordersTableBody tr[data-order-id]'));
    filteredOrders = allRows;
    updatePagination(1);
    
    // Set up a MutationObserver to handle dynamic updates to the order table
    const tableObserver = new MutationObserver(function(mutations) {
        // Re-apply current filters when table content changes
        filterOrders();
    });
    
    const orderTableBody = document.getElementById('ordersTableBody');
    if (orderTableBody) {
        tableObserver.observe(orderTableBody, { childList: true, subtree: true });
    }
    
    // Debug function to print all status values in the table
function debugStatusValues() {
  const rows = document.querySelectorAll('#ordersTableBody tr[data-order-id]');
  console.log('---- STATUS DEBUG ----');
  
  // Create a map to count occurrences of each status
  const statusMap = {};
  
  rows.forEach(row => {
    // Get the status from data attribute
    const dataStatus = row.getAttribute('data-status');
    
    // Get the status from the badge class
    const statusBadge = row.querySelector('.status-badge');
    let badgeClass = null;
    if (statusBadge) {
      const classList = Array.from(statusBadge.classList);
      badgeClass = classList.find(cls => cls.startsWith('status-') && cls !== 'status-badge');
      if (badgeClass) badgeClass = badgeClass.replace('status-', '');
    }
    
    // Get the status from the text content
    const statusText = statusBadge ? statusBadge.textContent.trim().toLowerCase() : null;
    
    console.log(`Order #${row.getAttribute('data-order-id')}: data-status="${dataStatus}", badge-class="${badgeClass}", text="${statusText}"`);
    
    // Count occurrences
    if (dataStatus) {
      statusMap[dataStatus] = (statusMap[dataStatus] || 0) + 1;
    }
  });
  
  console.log('Status counts:', statusMap);
  console.log('---- END DEBUG ----');
}

// Fixed filter function
function filterOrders() {
  debugStatusValues(); // Add this line to debug
  
  const statusFilter = document.getElementById('statusFilter').value;
  const dateFilter = document.getElementById('dateFilter').value;
  const searchTerm = document.getElementById('searchOrder').value.toLowerCase().trim();
  
  console.log('Filtering with:', { status: statusFilter, date: dateFilter, search: searchTerm });
  
  // Get all order rows
  const allRows = Array.from(document.querySelectorAll('#ordersTableBody tr[data-order-id]'));
  
  // If no filters are active and no search term, show all rows
  if (statusFilter === 'all' && dateFilter === 'all' && !searchTerm) {
    filteredOrders = allRows;
    updatePagination(1);
    return;
  }
  
  // Apply filters
  filteredOrders = allRows.filter(row => {
    let matchesStatus = true;
    let matchesDate = true;
    let matchesSearch = true;
    
    // Status filter - FIXED to be case insensitive and handle multiple status indicators
    if (statusFilter !== 'all') {
      // Try multiple ways to get the status
      const dataStatus = row.getAttribute('data-status')?.toLowerCase();
      
      // Get badge class as fallback
      let badgeStatus = null;
      const statusBadge = row.querySelector('.status-badge');
      if (statusBadge) {
        const statusClasses = Array.from(statusBadge.classList).filter(cls => 
          cls.startsWith('status-') && cls !== 'status-badge'
        );
        
        if (statusClasses.length > 0) {
          badgeStatus = statusClasses[0].replace('status-', '').toLowerCase();
        }
      }
      
      // Get text content as another fallback
      const statusText = statusBadge ? 
        statusBadge.textContent.trim().toLowerCase() : null;
      
      // Normalize status values for comparison
      // This handles cases like "Delivered" vs "delivered" or "Packaging" vs "packaging"
      const normalizedFilterStatus = statusFilter.toLowerCase();
      
      // Check all possible status indicators
      matchesStatus = (dataStatus === normalizedFilterStatus) || 
                      (badgeStatus === normalizedFilterStatus) ||
                      (statusText === normalizedFilterStatus) ||
                      // Handle special cases like "pending" might be stored as "packaging"
                      (normalizedFilterStatus === 'packaging' && statusText === 'pending') ||
                      (normalizedFilterStatus === 'shipping' && statusText === 'processing') ||
                      (normalizedFilterStatus === 'delivery' && statusText === 'shipped');
      
      console.log(`Row ${row.getAttribute('data-order-id')} status check: data="${dataStatus}", badge="${badgeStatus}", text="${statusText}", filter="${normalizedFilterStatus}", matches=${matchesStatus}`);
    }
    
    // Date filter (unchanged)
    if (dateFilter !== 'all') {
      const dateCell = row.querySelector('td:nth-child(3) .text-sm');
      if (dateCell) {
        const orderDateStr = dateCell.textContent.trim();
        const orderDate = new Date(orderDateStr);
        const now = new Date();
        
        if (dateFilter === 'today') {
          matchesDate = orderDate.toDateString() === now.toDateString();
        } else if (dateFilter === 'week') {
          const oneWeekAgo = new Date(now);
          oneWeekAgo.setDate(now.getDate() - 7);
          matchesDate = orderDate >= oneWeekAgo;
        } else if (dateFilter === 'month') {
          matchesDate = 
            orderDate.getMonth() === now.getMonth() && 
            orderDate.getFullYear() === now.getFullYear();
        }
      }
    }
    
    // Search term filter (unchanged)
    if (searchTerm) {
      const orderId = row.getAttribute('data-order-id');
      const customerCell = row.querySelector('td:nth-child(2)');
      const customerName = customerCell ? customerCell.querySelector('.text-gray-900').textContent.toLowerCase() : '';
      const customerEmail = customerCell ? customerCell.querySelector('.text-gray-500').textContent.toLowerCase() : '';
      
      matchesSearch = 
        orderId.includes(searchTerm) || 
        customerName.includes(searchTerm) || 
        customerEmail.includes(searchTerm);
    }
    
    return matchesStatus && matchesDate && matchesSearch;
  });
  
  console.log(`Filter results: ${filteredOrders.length} matching rows`);
  updatePagination(1);
}

// Function to fix the status dropdown
function fixStatusDropdown() {
  const statusDropdown = document.getElementById('statusFilter');
  if (!statusDropdown) return;
  
  // Clear existing options
  statusDropdown.innerHTML = '';
  
  // Add correct options
  const options = [
    { value: 'all', text: 'All' },
    { value: 'packaging', text: 'Packaging (Pending)' },
    { value: 'shipping', text: 'Shipping (Processing)' },
    { value: 'delivery', text: 'Delivery (Shipped)' },
    { value: 'delivered', text: 'Delivered' }
  ];
  
  options.forEach(option => {
    const optElement = document.createElement('option');
    optElement.value = option.value;
    optElement.textContent = option.text;
    statusDropdown.appendChild(optElement);
  });
  
  // Fix status classes on all badges
  const allStatusBadges = document.querySelectorAll('.status-badge');
  allStatusBadges.forEach(badge => {
    // Get current status
    const text = badge.textContent.trim().toLowerCase();
    
    // Remove all status classes
    badge.classList.forEach(cls => {
      if (cls.startsWith('status-') && cls !== 'status-badge') {
        badge.classList.remove(cls);
      }
    });
    
    // Add correct class based on text
    if (text === 'pending' || text === 'packaging') {
      badge.classList.add('status-packaging');
    } else if (text === 'processing' || text === 'shipping') {
      badge.classList.add('status-shipping');
    } else if (text === 'shipped' || text === 'delivery') {
      badge.classList.add('status-delivery');
    } else if (text === 'delivered') {
      badge.classList.add('status-delivered');
    }
  });
  
  // Re-attach event listener
  statusDropdown.addEventListener('change', filterOrders);
}

// Run when page loads
document.addEventListener('DOMContentLoaded', function() {
  // Fix the status dropdown
  fixStatusDropdown();
  
  // Re-attach event listeners for other filters
  if (document.getElementById('dateFilter')) {
    document.getElementById('dateFilter').addEventListener('change', filterOrders);
  }
  if (document.getElementById('searchOrder')) {
    document.getElementById('searchOrder').addEventListener('input', filterOrders);
  }
  
  // Debug current status values
  debugStatusValues();
  
  // Initialize filtering
  filterOrders();
});
});
</script>