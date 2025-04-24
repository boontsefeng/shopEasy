<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<%@ include file="dashboard-template.jsp" %>

<!-- Reports Styles -->
<style>
    .tab-button {
        padding: 0.75rem 1.5rem;
        font-weight: 500;
        border-radius: 0.5rem;
        transition: all 0.3s ease;
    }
    
    .tab-button.active {
        background-color: #4F46E5;
        color: white;
    }
    
    .tab-button:not(.active) {
        background-color: #EEF2FF;
        color: #4F46E5;
    }
    
    .tab-button:hover:not(.active) {
        background-color: #E0E7FF;
    }
    
    .chart-container {
        height: 400px;
        width: 100%;
        position: relative;
    }
    
    .loading-overlay {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(255, 255, 255, 0.8);
        display: flex;
        justify-content: center;
        align-items: center;
        z-index: 10;
    }
</style>

<!-- Set page title -->
<script>
    document.addEventListener('DOMContentLoaded', function() {
        setPageTitle('Sales Reports');
    });
</script>

<!-- Report Content -->
<div class="bg-white rounded-lg shadow-md overflow-hidden mb-8 animate-section">
    <div class="p-4 bg-indigo-500 text-white flex justify-between items-center">
        <h2 class="text-xl font-semibold">Sales Reports</h2>
        <div>
            <span id="currentDate" class="text-sm bg-white text-indigo-500 py-1 px-3 rounded-full"></span>
        </div>
    </div>
    
    <!-- Error message if any -->
    <c:if test="${not empty error}">
        <div class="p-4 bg-red-100 text-red-700">
            ${error}
        </div>
    </c:if>
    
    <!-- Time Period Tabs -->
    <div class="p-4 flex items-center space-x-4 border-b border-gray-200">
        <button id="weeklyTab" class="tab-button active" onclick="switchTab('weekly')">Weekly</button>
        <button id="monthlyTab" class="tab-button" onclick="switchTab('monthly')">Monthly</button>
        <button id="yearlyTab" class="tab-button" onclick="switchTab('yearly')">Yearly</button>
        
        <div class="ml-auto flex items-center space-x-2">
            <button id="exportBtn" class="text-gray-600 hover:text-indigo-500" onclick="exportReport()">
                <i class="fas fa-download"></i> Export
            </button>
            <button id="printBtn" class="text-gray-600 hover:text-indigo-500" onclick="printReport()">
                <i class="fas fa-print"></i> Print
            </button>
        </div>
    </div>
    
    <!-- Report Content -->
    <div class="p-6">
        <!-- Summary Cards -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
            <div class="bg-blue-50 p-4 rounded-lg">
                <div class="text-blue-500 font-medium">Total Orders</div>
                <div class="text-2xl font-bold" id="totalOrdersValue">${orderCount}</div>
                <div class="text-sm text-blue-400" id="totalOrdersChange">+0% from previous period</div>
            </div>
            
            <div class="bg-green-50 p-4 rounded-lg">
                <div class="text-green-500 font-medium">Total Revenue</div>
                <div class="text-2xl font-bold" id="totalRevenueValue">$<fmt:formatNumber value="${totalRevenue}" pattern="#,##0.00"/></div>
                <div class="text-sm text-green-400" id="totalRevenueChange">+0% from previous period</div>
            </div>
            
            <div class="bg-purple-50 p-4 rounded-lg">
                <div class="text-purple-500 font-medium">Average Order Value</div>
                <div class="text-2xl font-bold" id="avgOrderValue">$<fmt:formatNumber value="${avgOrderValue}" pattern="#,##0.00"/></div>
                <div class="text-sm text-purple-400" id="avgOrderChange">+0% from previous period</div>
            </div>
        </div>
        
        <!-- Charts -->
        <div class="space-y-8">
            <!-- Sales Trend Chart -->
            <div class="bg-gray-50 p-4 rounded-lg">
                <h3 class="text-lg font-medium mb-4" id="salesTrendTitle">Sales Trend (Weekly)</h3>
                <div class="chart-container">
                    <div id="salesTrendChartLoader" class="loading-overlay">
                        <div class="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-indigo-500"></div>
                    </div>
                    <canvas id="salesTrendChart"></canvas>
                </div>
            </div>
            
            <!-- Revenue by Category Chart -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div class="bg-gray-50 p-4 rounded-lg">
                    <h3 class="text-lg font-medium mb-4">Revenue by Category</h3>
                    <div class="chart-container" style="height: 300px;">
                        <div id="categoryChartLoader" class="loading-overlay">
                            <div class="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-indigo-500"></div>
                        </div>
                        <canvas id="categoryChart"></canvas>
                    </div>
                </div>
                
                <div class="bg-gray-50 p-4 rounded-lg">
                    <h3 class="text-lg font-medium mb-4">Top Products</h3>
                    <div class="chart-container" style="height: 300px;">
                        <div id="topProductsChartLoader" class="loading-overlay">
                            <div class="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-indigo-500"></div>
                        </div>
                        <canvas id="topProductsChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Include Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<!-- Reports JavaScript -->
<script>
// Current date
document.addEventListener('DOMContentLoaded', function() {
    const now = new Date();
    document.getElementById('currentDate').textContent = now.toLocaleDateString('en-US', { 
        year: 'numeric', 
        month: 'long', 
        day: 'numeric' 
    });
    
    // Check if Chart is defined
    if (typeof Chart === 'undefined') {
        console.error('Chart.js is not loaded! Adding it dynamically...');
        
        // Dynamically add Chart.js
        var script = document.createElement('script');
        script.src = 'https://cdn.jsdelivr.net/npm/chart.js';
        script.onload = function() {
            console.log('Chart.js loaded successfully');
            // Initialize with weekly view
            loadWeeklyData();
        };
        document.head.appendChild(script);
    } else {
        console.log('Chart.js is properly loaded');
        // Initialize with weekly view
        loadWeeklyData();
    }
});

// Tab switching
function switchTab(tab) {
    // Remove active class from all tabs
    document.querySelectorAll('.tab-button').forEach(button => {
        button.classList.remove('active');
    });
    
    // Add active class to selected tab
    document.getElementById(tab + 'Tab').classList.add('active');
    
    // Update chart title
    document.getElementById('salesTrendTitle').textContent = 'Sales Trend (' + tab.charAt(0).toUpperCase() + tab.slice(1) + ')';
    
    // Load data based on selected tab
    if (tab === 'weekly') {
        loadWeeklyData();
    } else if (tab === 'monthly') {
        loadMonthlyData();
    } else if (tab === 'yearly') {
        loadYearlyData();
    }
}

// Chart instances
let salesTrendChart;
let categoryChart;
let topProductsChart;

// Show/hide loading state
function showLoading(chartId) {
    document.getElementById(chartId + 'Loader').style.display = 'flex';
}

function hideLoading(chartId) {
    document.getElementById(chartId + 'Loader').style.display = 'none';
}

// Load data from server
function loadData(period) {
    showLoading('salesTrendChart');
    
    console.log(`Loading ${period} data...`);
    
    return fetch(`${pageContext.request.contextPath}/reports`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: `action=getData&period=${period}`
    })
    .then(response => {
        if (!response.ok) {
            console.error(`Server responded with status: ${response.status}`);
            throw new Error(`Server responded with status: ${response.status}`);
        }
        
        // Debug response
        return response.text().then(text => {
            console.log(`${period} data response:`, text);
            try {
                return JSON.parse(text);
            } catch (e) {
                console.error('Error parsing JSON:', e);
                throw new Error('Invalid JSON response from server');
            }
        });
    })
    .catch(error => {
        console.error(`Error loading ${period} data:`, error);
        hideLoading('salesTrendChart');
        alert(`Error loading ${period} report data: ${error.message}`);
        throw error;
    });
}

// Load category data
function loadCategoryData() {
    showLoading('categoryChart');
    
    console.log('Loading category data...');
    
    return fetch(`${pageContext.request.contextPath}/reports`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'action=getData&type=categories'
    })
    .then(response => {
        if (!response.ok) {
            console.error(`Server responded with status: ${response.status}`);
            throw new Error(`Server responded with status: ${response.status}`);
        }
        
        // Debug response
        return response.text().then(text => {
            console.log('Category data response:', text);
            try {
                return JSON.parse(text);
            } catch (e) {
                console.error('Error parsing JSON:', e);
                throw new Error('Invalid JSON response from server');
            }
        });
    })
    .catch(error => {
        console.error('Error loading category data:', error);
        hideLoading('categoryChart');
        alert('Error loading category data: ' + error.message);
        throw error;
    });
}

// Load top products data
function loadTopProductsData() {
    showLoading('topProductsChart');
    
    console.log('Loading top products data...');
    
    return fetch(`${pageContext.request.contextPath}/reports`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'action=getData&type=topProducts'
    })
    .then(response => {
        if (!response.ok) {
            console.error(`Server responded with status: ${response.status}`);
            throw new Error(`Server responded with status: ${response.status}`);
        }
        
        // Debug response
        return response.text().then(text => {
            console.log('Top products data response:', text);
            try {
                return JSON.parse(text);
            } catch (e) {
                console.error('Error parsing JSON:', e);
                throw new Error('Invalid JSON response from server');
            }
        });
    })
    .catch(error => {
        console.error('Error loading top products data:', error);
        hideLoading('topProductsChart');
        alert('Error loading top products data: ' + error.message);
        throw error;
    });
}

// Load weekly data
function loadWeeklyData() {
    showLoading('salesTrendChart');
    showLoading('categoryChart');
    showLoading('topProductsChart');
    
    console.log('Initiating weekly data loading...');
    
    loadData('weekly')
        .then(data => {
            console.log('Weekly data received:', data);
            hideLoading('salesTrendChart');
            
            // Validate data structure
            if (!data) throw new Error('No data received from server');
            if (!data.labels) throw new Error('No labels array in data');
            if (!data.orders) throw new Error('No orders array in data');
            if (!data.revenue) throw new Error('No revenue array in data');
            if (!data.summary) throw new Error('No summary object in data');
            
            updateSummary(data.summary);
            renderSalesTrendChart(data.labels, data.orders, data.revenue);
            
            return Promise.all([
                loadCategoryData(),
                loadTopProductsData()
            ]);
        })
        .then(([categoryData, topProductsData]) => {
            console.log('Category data:', categoryData);
            console.log('Top products data:', topProductsData);
            
            hideLoading('categoryChart');
            hideLoading('topProductsChart');
            
            if (categoryData.categories && categoryData.categories.labels && categoryData.categories.data) {
                renderCategoryChart(categoryData.categories.labels, categoryData.categories.data);
            } else {
                console.error('Invalid category data structure:', categoryData);
                throw new Error('Invalid category data structure');
            }
            
            if (topProductsData.topProducts && topProductsData.topProducts.labels && topProductsData.topProducts.data) {
                renderTopProductsChart(topProductsData.topProducts.labels, topProductsData.topProducts.data);
            } else {
                console.error('Invalid top products data structure:', topProductsData);
                throw new Error('Invalid top products data structure');
            }
        })
        .catch(error => {
            hideLoading('salesTrendChart');
            hideLoading('categoryChart');
            hideLoading('topProductsChart');
            console.error('Error in loadWeeklyData:', error);
            alert('Error loading weekly data: ' + error.message);
        });
}

// Load monthly data
function loadMonthlyData() {
    showLoading('salesTrendChart');
    
    console.log('Initiating monthly data loading...');
    
    loadData('monthly')
        .then(data => {
            console.log('Monthly data received:', data);
            hideLoading('salesTrendChart');
            
            // Validate data structure
            if (!data) throw new Error('No data received from server');
            if (!data.labels) throw new Error('No labels array in data');
            if (!data.orders) throw new Error('No orders array in data');
            if (!data.revenue) throw new Error('No revenue array in data');
            if (!data.summary) throw new Error('No summary object in data');
            
            updateSummary(data.summary);
            renderSalesTrendChart(data.labels, data.orders, data.revenue);
        })
        .catch(error => {
            hideLoading('salesTrendChart');
            console.error('Error in loadMonthlyData:', error);
            alert('Error loading monthly data: ' + error.message);
        });
}

// Load yearly data
function loadYearlyData() {
    showLoading('salesTrendChart');
    
    console.log('Initiating yearly data loading...');
    
    loadData('yearly')
        .then(data => {
            console.log('Yearly data received:', data);
            hideLoading('salesTrendChart');
            
            // Validate data structure
            if (!data) throw new Error('No data received from server');
            if (!data.labels) throw new Error('No labels array in data');
            if (!data.orders) throw new Error('No orders array in data');
            if (!data.revenue) throw new Error('No revenue array in data');
            if (!data.summary) throw new Error('No summary object in data');
            
            updateSummary(data.summary);
            renderSalesTrendChart(data.labels, data.orders, data.revenue);
        })
        .catch(error => {
            hideLoading('salesTrendChart');
            console.error('Error in loadYearlyData:', error);
            alert('Error loading yearly data: ' + error.message);
        });
}

// Update summary cards
function updateSummary(data) {
    if (!data) {
        console.error('No summary data provided');
        return;
    }
    
    console.log('Updating summary with data:', data);
    
    document.getElementById('totalOrdersValue').textContent = data.orders.toLocaleString();
    document.getElementById('totalRevenueValue').textContent = '$' + data.revenue.toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2});
    document.getElementById('avgOrderValue').textContent = '$' + data.avg.toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2});
    
    // Use actual percentage changes if provided, otherwise use placeholder
    document.getElementById('totalOrdersChange').textContent = data.ordersChange 
        ? (data.ordersChange > 0 ? '+' : '') + data.ordersChange.toFixed(1) + '% from previous period'
        : '+0% from previous period';
        
    document.getElementById('totalRevenueChange').textContent = data.revenueChange
        ? (data.revenueChange > 0 ? '+' : '') + data.revenueChange.toFixed(1) + '% from previous period'
        : '+0% from previous period';
        
    document.getElementById('avgOrderChange').textContent = data.avgChange
        ? (data.avgChange > 0 ? '+' : '') + data.avgChange.toFixed(1) + '% from previous period'
        : '+0% from previous period';
}

// Define consistent category colors
const categoryColors = {
    'Electronics': '#4F46E5', // Indigo
    'Home & Garden': '#10B981', // Green
    'Clothing': '#F59E0B', // Amber/Yellow
    'Sports': '#EF4444', // Red
    'Books': '#8B5CF6', // Purple
    'Toys': '#EC4899', // Pink
    'Beauty': '#06B6D4', // Cyan
    'Health': '#84CC16', // Lime
    'Jewelry': '#7C3AED' // Violet
};

// Default colors for fallback
const defaultCategoryColors = [
    '#4F46E5', '#10B981', '#F59E0B', '#EF4444', 
    '#8B5CF6', '#EC4899', '#06B6D4', '#84CC16', '#7C3AED'
];

// Render sales trend chart
function renderSalesTrendChart(labels, orders, revenue) {
    if (!labels || !orders || !revenue) {
        console.error('Missing data for sales trend chart');
        return;
    }
    
    console.log('Rendering sales trend chart with:', { labels, orders, revenue });
    
    const ctx = document.getElementById('salesTrendChart').getContext('2d');
    if (!ctx) {
        console.error('Could not get canvas context for sales trend chart');
        return;
    }
    
    // Destroy previous chart if it exists
    if (salesTrendChart) {
        salesTrendChart.destroy();
    }
    
    salesTrendChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [
                {
                    label: 'Orders',
                    data: orders,
                    borderColor: '#4F46E5',
                    backgroundColor: 'rgba(79, 70, 229, 0.1)',
                    yAxisID: 'y',
                    tension: 0.3,
                    fill: true,
                    pointBackgroundColor: '#4F46E5',
                    pointRadius: 4,
                    pointHoverRadius: 6
                },
                {
                    label: 'Revenue ($)',
                    data: revenue,
                    borderColor: '#10B981',
                    backgroundColor: 'rgba(16, 185, 129, 0.1)',
                    yAxisID: 'y1',
                    tension: 0.3,
                    fill: true,
                    pointBackgroundColor: '#10B981',
                    pointRadius: 4,
                    pointHoverRadius: 6
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: {
                mode: 'index',
                intersect: false
            },
            scales: {
                y: {
                    type: 'linear',
                    display: true,
                    position: 'left',
                    title: {
                        display: true,
                        text: 'Orders',
                        font: {
                            weight: 'bold'
                        }
                    },
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    }
                },
                y1: {
                    type: 'linear',
                    display: true,
                    position: 'right',
                    grid: {
                        drawOnChartArea: false
                    },
                    title: {
                        display: true,
                        text: 'Revenue ($)',
                        font: {
                            weight: 'bold'
                        }
                    }
                }
            },
            plugins: {
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            let label = context.dataset.label || '';
                            let value = context.raw || 0;
                            
                            if (label.includes('Revenue')) {
                                return `${label}: $${value.toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2})}`;
                            } else {
                                return `${label}: ${value.toLocaleString()}`;
                            }
                        }
                    }
                }
            }
        }
    });
}

// Render category chart with consistent colors
function renderCategoryChart(labels, data) {
    if (!labels || !data) {
        console.error('Missing data for category chart');
        return;
    }
    
    console.log('Rendering category chart with:', { labels, data });
    
    const ctx = document.getElementById('categoryChart').getContext('2d');
    if (!ctx) {
        console.error('Could not get canvas context for category chart');
        return;
    }
    
    // Destroy previous chart if it exists
    if (categoryChart) {
        categoryChart.destroy();
    }
    
    // Generate background colors based on category names
    const backgroundColors = labels.map((category, index) => {
        // Use predefined color if available, otherwise use a color from the default array
        return categoryColors[category] || defaultCategoryColors[index % defaultCategoryColors.length];
    });
    
    categoryChart = new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: labels,
            datasets: [{
                data: data,
                backgroundColor: backgroundColors,
                borderWidth: 1,
                borderColor: '#fff'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            cutout: '60%',
            plugins: {
                legend: {
                    position: 'right',
                    labels: {
                        padding: 15,
                        usePointStyle: true,
                        pointStyle: 'circle',
                        font: {
                            size: 12
                        }
                    }
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            const label = context.label || '';
                            const value = context.raw || 0;
                            return `${label}: ${value.toFixed(1)}%`;
                        }
                    }
                }
            }
        }
    });
}

// Render top products chart
function renderTopProductsChart(labels, data) {
    if (!labels || !data) {
        console.error('Missing data for top products chart');
        return;
    }
    
    console.log('Rendering top products chart with:', { labels, data });
    
    const ctx = document.getElementById('topProductsChart').getContext('2d');
    if (!ctx) {
        console.error('Could not get canvas context for top products chart');
        return;
    }
    
    // Destroy previous chart if it exists
    if (topProductsChart) {
        topProductsChart.destroy();
    }
    
    topProductsChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Sales Percentage',
                data: data,
                backgroundColor: '#4F46E5',
                barPercentage: 0.7,
                categoryPercentage: 0.8,
                borderRadius: 3
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            indexAxis: 'y', // Horizontal bar chart for better readability of product names
            scales: {
                x: {
                    beginAtZero: true,
                    title: {
                        display: true,
                        text: 'Percentage (%)',
                        font: {
                            weight: 'bold'
                        }
                    },
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    }
                },
                y: {
                    grid: {
                        display: false
                    },
                    ticks: {
                        font: {
                            size: 11
                        }
                    }
                }
            },
            plugins: {
                legend: {
                    display: true,
                    position: 'top'
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            const label = context.dataset.label || '';
                            const value = context.raw || 0;
                            return `${label}: ${value.toFixed(1)}%`;
                        }
                    }
                }
            }
        }
    });
}

// Export functionality
function exportReport() {
    // Get the current tab
    const activeTab = document.querySelector('.tab-button.active').id.replace('Tab', '');
    
    // Create URL with parameters
    const url = `${pageContext.request.contextPath}/reports?action=export&period=${activeTab}`;
    
    // Open in new window/tab
    window.open(url, '_blank');
}

// Print functionality
function printReport() {
    // First hide any elements you don't want to print
    const originalContent = document.body.innerHTML;
    
    // Get the report container
    const reportContent = document.querySelector('.bg-white.rounded-lg.shadow-md').innerHTML;
    
    // Set the body content to just the report
    document.body.innerHTML = `
        <div style="padding: 20px;">
            <h1 style="text-align: center; margin-bottom: 20px;">ShopEasy Sales Report</h1>
            ${reportContent}
        </div>
    `;
    
    // Print
    window.print();
    
    // Restore original content
    document.body.innerHTML = originalContent;
    
    // Reinitialize charts and event handlers
    document.addEventListener('DOMContentLoaded', function() {
        const activeTab = document.querySelector('.tab-button.active').id.replace('Tab', '') || 'weekly';
        switchTab(activeTab);
    });
}
</script>