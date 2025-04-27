<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<%@ include file="dashboard-template.jsp" %>

<!-- Main content -->
<div class="p-6">
    <h2 class="text-xl font-semibold mb-4">Sales Reports</h2>
    
    <!-- Error Alert -->
    <div class="bg-red-100 text-red-700 p-4 rounded mb-4 hidden" id="error-alert"></div>
    
    <!-- Report Form -->
    <div class="bg-white rounded shadow-md p-5 mb-6">
        <form id="report-form" onsubmit="return generateReport(event)">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                <div>
                    <label for="startDate" class="block text-sm font-medium text-gray-700 mb-1">Start Date</label>
                    <input type="date" id="startDate" name="startDate" required
                        class="w-full border border-gray-300 rounded px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500">
                </div>
                <div>
                    <label for="endDate" class="block text-sm font-medium text-gray-700 mb-1">End Date</label>
                    <input type="date" id="endDate" name="endDate" required
                        class="w-full border border-gray-300 rounded px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500">
                </div>
            </div>
            <div class="flex justify-end">
                <button type="submit" class="bg-indigo-600 hover:bg-indigo-700 text-white py-2 px-4 rounded">
                    Generate Report
                </button>
            </div>
        </form>
    </div>
    
    <!-- Report Content -->
    <div id="report-content" class="hidden">
        <!-- Summary Cards -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
            <div class="bg-white rounded shadow p-4">
                <h5 class="text-gray-600 text-sm mb-1">Total Revenue</h5>
                <div class="text-2xl font-bold" id="totalRevenue">$0.00</div>
            </div>
            <div class="bg-white rounded shadow p-4">
                <h5 class="text-gray-600 text-sm mb-1">Total Orders</h5>
                <div class="text-2xl font-bold" id="totalOrders">0</div>
            </div>
            <div class="bg-white rounded shadow p-4">
                <h5 class="text-gray-600 text-sm mb-1">Total Items Sold</h5>
                <div class="text-2xl font-bold" id="totalItems">0</div>
            </div>
            <div class="bg-white rounded shadow p-4">
                <h5 class="text-gray-600 text-sm mb-1">Avg. Order Value</h5>
                <div class="text-2xl font-bold" id="avgOrderValue">$0.00</div>
            </div>
        </div>
        
        <!-- Charts and Tables -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
            <div class="lg:col-span-2 bg-white rounded shadow p-4">
                <h4 class="text-lg font-medium mb-4">Revenue Over Time</h4>
                <div style="height: 350px">
                    <canvas id="revenueChart"></canvas>
                </div>
            </div>
            <div class="bg-white rounded shadow p-4">
                <h4 class="text-lg font-medium mb-4">Top Products</h4>
                <div id="popularProducts" class="space-y-3">
                    <!-- Products will be populated here -->
                </div>
            </div>
        </div>
    </div>
    
    <!-- Loading Spinner -->
    <div id="loading-spinner" class="hidden flex justify-center my-10">
        <div class="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-indigo-500"></div>
    </div>
</div>

<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script>
    // Set default dates
    document.addEventListener('DOMContentLoaded', function() {
        // Set page title if function exists
        if (typeof setPageTitle === 'function') {
            setPageTitle('Sales Reports');
        }
        
        // Set default date range (last 30 days)
        const today = new Date();
        const lastMonth = new Date();
        lastMonth.setDate(today.getDate() - 30);
        
        document.getElementById('endDate').valueAsDate = today;
        document.getElementById('startDate').valueAsDate = lastMonth;
    });
    
    // Chart variable
    let revenueChart = null;
    
    // Generate report function
    function generateReport(event) {
        event.preventDefault();
        
        const startDate = document.getElementById('startDate').value;
        const endDate = document.getElementById('endDate').value;
        
        // Validate dates
        if (!startDate || !endDate) {
            showError('Please select both start and end dates.');
            return false;
        }
        
        if (new Date(startDate) > new Date(endDate)) {
            showError('Start date cannot be after end date.');
            return false;
        }
        
        // Calculate date difference
        const diffTime = Math.abs(new Date(endDate) - new Date(startDate));
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        
        if (diffDays < 7) {
            showError('Date range must be at least one week.');
            return false;
        }
        
        // Show loading spinner
        document.getElementById('error-alert').classList.add('hidden');
        document.getElementById('report-content').classList.add('hidden');
        document.getElementById('loading-spinner').classList.remove('hidden');
        
        // Make AJAX request
        const xhr = new XMLHttpRequest();
        xhr.open('GET', '${pageContext.request.contextPath}/reports/data?startDate=' + startDate + '&endDate=' + endDate, true);
        
        xhr.onload = function() {
            if (xhr.status >= 200 && xhr.status < 300) {
                try {
                    const data = JSON.parse(xhr.responseText);
                    
                    if (data.error) {
                        showError(data.error);
                        document.getElementById('loading-spinner').classList.add('hidden');
                        return;
                    }
                    
                    // Update UI with report data
                    updateReportUI(data);
                    
                    // Hide spinner and show report
                    document.getElementById('loading-spinner').classList.add('hidden');
                    document.getElementById('report-content').classList.remove('hidden');
                } catch (e) {
                    console.error('Error parsing JSON:', e);
                    showError('Error processing report data.');
                    document.getElementById('loading-spinner').classList.add('hidden');
                }
            } else {
                console.error('Request failed with status:', xhr.status);
                showError('Failed to generate report. Please try again.');
                document.getElementById('loading-spinner').classList.add('hidden');
            }
        };
        
        xhr.onerror = function() {
            showError('Network error. Please check your connection and try again.');
            document.getElementById('loading-spinner').classList.add('hidden');
        };
        
        xhr.send();
        return false;
    }
    
    function showError(message) {
        const errorAlert = document.getElementById('error-alert');
        errorAlert.textContent = message;
        errorAlert.classList.remove('hidden');
    }
    
    function updateReportUI(data) {
        // Update summary data
        document.getElementById('totalRevenue').textContent = formatCurrencyJS(data.salesSummary.totalRevenue);
        document.getElementById('totalOrders').textContent = data.salesSummary.totalOrders;
        document.getElementById('totalItems').textContent = data.salesSummary.totalItems;
        document.getElementById('avgOrderValue').textContent = formatCurrencyJS(data.salesSummary.avgOrderValue);
        
        // Create revenue chart
        createRevenueChart(data.revenueData);
        
        // Display popular products
        displayPopularProducts(data.popularProducts);
    }
    
    function createRevenueChart(revenueData) {
        const labels = Object.keys(revenueData);
        const values = Object.values(revenueData);
        
        // Sort dates
        const sortedData = labels.map((label, index) => {
            return { date: label, value: values[index] };
        }).sort((a, b) => new Date(a.date) - new Date(b.date));
        
        const sortedLabels = sortedData.map(item => item.date);
        const sortedValues = sortedData.map(item => item.value);
        
        const ctx = document.getElementById('revenueChart').getContext('2d');
        
        // Destroy previous chart if it exists
        if (revenueChart) {
            revenueChart.destroy();
        }
        
        revenueChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: sortedLabels,
                datasets: [{
                    label: 'Daily Revenue',
                    data: sortedValues,
                    backgroundColor: 'rgba(79, 70, 229, 0.2)',
                    borderColor: 'rgba(79, 70, 229, 1)',
                    borderWidth: 2,
                    tension: 0.3,
                    fill: true
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return 'Revenue: ' + formatCurrencyJS(context.raw);
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) {
                                return formatCurrencyJS(value);
                            }
                        }
                    }
                }
            }
        });
    }
    
    // Updated function to display popular products without images
    function displayPopularProducts(products) {
        const container = document.getElementById('popularProducts');
        container.innerHTML = '';
        
        if (!products || products.length === 0) {
            container.innerHTML = '<p class="text-gray-500 text-center">No product data available for the selected period.</p>';
            return;
        }
        
        // For each product, create a clean display row
        products.forEach(function(product) {
            // Create the container for each product
            const productRow = document.createElement('div');
            productRow.className = 'border-b border-gray-200 py-3 last:border-0';
            
            // Create the name element with proper styling
            const nameElement = document.createElement('div');
            nameElement.className = 'font-semibold text-gray-800 text-lg mb-1';
            nameElement.textContent = product.name;
            
            // Get the product stats
            const quantity = product.totalQuantity || 0;
            const revenue = formatCurrencyJS(product.totalRevenue || 0);
            
            // Create the details div with two spans
            const detailsDiv = document.createElement('div');
            detailsDiv.className = 'flex justify-between text-sm text-gray-600';
            
            // Create and append quantity span
            const quantitySpan = document.createElement('span');
            quantitySpan.textContent = quantity + ' units';
            detailsDiv.appendChild(quantitySpan);
            
            // Create and append revenue span
            const revenueSpan = document.createElement('span');
            revenueSpan.textContent = revenue;
            detailsDiv.appendChild(revenueSpan);
            
            // Add elements to the product row
            productRow.appendChild(nameElement);
            productRow.appendChild(detailsDiv);
            
            // Add the complete product row to the container
            container.appendChild(productRow);
        });
    }
    
    // Pure JavaScript currency formatter
    function formatCurrencyJS(value) {
        if (value === null || value === undefined) {
            return '$0.00';
        }
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 2
        }).format(value);
    }
</script>