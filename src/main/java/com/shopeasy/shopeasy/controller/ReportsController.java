package com.shopeasy.shopeasy.controller;

import com.shopeasy.shopeasy.dao.OrderDAO;
import com.shopeasy.shopeasy.dao.ProductDAO;
import com.shopeasy.shopeasy.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;
import java.util.HashMap;
import java.util.List;

@WebServlet("/reports")
public class ReportsController extends HttpServlet {
    private OrderDAO orderDAO;
    private ProductDAO productDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        orderDAO = new OrderDAO();
        productDAO = new ProductDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Check authorization
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        String role = user.getRole().toLowerCase();
        
        // Only allow staff and managers to access reports
        if (role.equals("manager") || role.equals("staff")) {
            try {
                // Get basic stats for dashboard
                int orderCount = orderDAO.getOrderCount();
                double totalRevenue = orderDAO.getTotalRevenue();
                double avgOrderValue = orderCount > 0 ? totalRevenue / orderCount : 0;
                
                // Set request attributes
                request.setAttribute("orderCount", orderCount);
                request.setAttribute("totalRevenue", totalRevenue);
                request.setAttribute("avgOrderValue", avgOrderValue);
                
                // Forward to reports page
                request.getRequestDispatcher("/view/staff/reports.jsp").forward(request, response);
            } catch (Exception e) {
                System.err.println("Error loading report data: " + e.getMessage());
                e.printStackTrace();
                
                // Set default values if there's an error
                request.setAttribute("orderCount", 0);
                request.setAttribute("totalRevenue", 0.0);
                request.setAttribute("avgOrderValue", 0.0);
                request.setAttribute("error", "Failed to load report data: " + e.getMessage());
                
                request.getRequestDispatcher("/view/staff/reports.jsp").forward(request, response);
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/dashboard");
        }
    }
    
        @Override
        protected void doPost(HttpServletRequest request, HttpServletResponse response) 
                throws ServletException, IOException {
            // Check authorization
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("user") == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            User user = (User) session.getAttribute("user");
            String role = user.getRole().toLowerCase();

            // Only allow staff and managers to access reports
            if (role.equals("manager") || role.equals("staff")) {
                String action = request.getParameter("action");

                if ("getData".equals(action)) {
                    // Get period parameter
                    String period = request.getParameter("period");
                    String type = request.getParameter("type");

                    try {
                        Map<String, Object> reportData;

                        if (type != null && "categories".equals(type)) {
                            // Initialize reportData to avoid null pointer
                            reportData = new HashMap<>();
                            reportData.put("categories", orderDAO.getCategoryData());
                        } else if (type != null && "topProducts".equals(type)) {
                            // Initialize reportData to avoid null pointer
                            reportData = new HashMap<>();
                            reportData.put("topProducts", orderDAO.getTopProductsData());
                        } else if ("weekly".equals(period)) {
                            reportData = orderDAO.getWeeklyReportData();
                        } else if ("monthly".equals(period)) {
                            reportData = orderDAO.getMonthlyReportData();
                        } else if ("yearly".equals(period)) {
                            reportData = orderDAO.getYearlyReportData();
                        } else {
                            // Instead of fallback, throw error for invalid period
                            throw new IllegalArgumentException("Invalid report period: " + period);
                        }

                        // Send JSON response
                        response.setContentType("application/json");
                        response.getWriter().write(convertToJson(reportData));
                    } catch (Exception e) {
                        System.err.println("Error generating report data: " + e.getMessage());
                        e.printStackTrace();

                        // Send error response
                        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                        response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
                    }
                } else if ("export".equals(action)) {
                    // Export report functionality
                    String period = request.getParameter("period");

                    try {
                        Map<String, Object> reportData;

                        // Get data based on period
                        if ("weekly".equals(period)) {
                            reportData = orderDAO.getWeeklyReportData();
                        } else if ("monthly".equals(period)) {
                            reportData = orderDAO.getMonthlyReportData();
                        } else if ("yearly".equals(period)) {
                            reportData = orderDAO.getYearlyReportData();
                        } else {
                            // Instead of fallback, throw error for invalid period
                            throw new IllegalArgumentException("Invalid report period for export: " + period);
                        }

                        // Set response headers for CSV download
                        response.setContentType("text/csv");
                        response.setHeader("Content-Disposition", "attachment; filename=\"shopeasy_" + period + "_report.csv\"");

                        // Generate CSV content
                        PrintWriter writer = response.getWriter();

                        // Write CSV header
                        writer.println("Date,Orders,Revenue");

                        // Extract data
                        String[] labels = (String[]) reportData.get("labels");
                        int[] orders = (int[]) reportData.get("orders");
                        double[] revenue = (double[]) reportData.get("revenue");

                        // Write data rows
                        for (int i = 0; i < labels.length; i++) {
                            writer.println(labels[i] + "," + orders[i] + "," + revenue[i]);
                        }

                        writer.flush();
                        writer.close();
                    } catch (Exception e) {
                        System.err.println("Error exporting report: " + e.getMessage());
                        e.printStackTrace();

                        // Send error response
                        response.setContentType("text/plain");
                        response.getWriter().write("Error exporting report: " + e.getMessage());
                    }
                } else {
                    // Forward back to reports page for other actions
                    doGet(request, response);
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/dashboard");
            }
        }
    /**
     * Convert Map to JSON string
     * @param data Map of data
     * @return JSON string
     */
    private String convertToJson(Map<String, Object> data) {
        StringBuilder json = new StringBuilder("{");

        boolean first = true;
        for (Map.Entry<String, Object> entry : data.entrySet()) {
            if (!first) {
                json.append(",");
            }
            first = false;

            json.append("\"").append(entry.getKey()).append("\":");

            Object value = entry.getValue();
            if (value == null) {
                json.append("null");
            } else if (value instanceof String) {
                json.append("\"").append(value).append("\"");
            } else if (value instanceof Number) {
                json.append(value);
            } else if (value instanceof Boolean) {
                json.append(value);
            } else if (value instanceof String[]) {
                appendJsonArray(json, (String[]) value);
            } else if (value instanceof int[]) {
                appendJsonArray(json, (int[]) value);
            } else if (value instanceof double[]) {
                appendJsonArray(json, (double[]) value);
            } else if (value instanceof List) {
                appendJsonList(json, (List<?>) value);
            } else if (value instanceof Map) {
                json.append(convertToJson((Map<String, Object>) value));
            } else {
                json.append("\"").append(value.toString()).append("\"");
            }
        }

        json.append("}");
        return json.toString();
    }

    private void appendJsonArray(StringBuilder json, String[] array) {
        json.append("[");
        for (int i = 0; i < array.length; i++) {
            if (i > 0) {
                json.append(",");
            }
            json.append("\"").append(array[i]).append("\"");
        }
        json.append("]");
    }

    private void appendJsonArray(StringBuilder json, int[] array) {
        json.append("[");
        for (int i = 0; i < array.length; i++) {
            if (i > 0) {
                json.append(",");
            }
            json.append(array[i]);
        }
        json.append("]");
    }

    private void appendJsonArray(StringBuilder json, double[] array) {
        json.append("[");
        for (int i = 0; i < array.length; i++) {
            if (i > 0) {
                json.append(",");
            }
            json.append(array[i]);
        }
        json.append("]");
    }

    private void appendJsonList(StringBuilder json, List<?> list) {
        json.append("[");
        for (int i = 0; i < list.size(); i++) {
            if (i > 0) {
                json.append(",");
            }
            Object item = list.get(i);
            if (item == null) {
                json.append("null");
            } else if (item instanceof String) {
                json.append("\"").append(item).append("\"");
            } else if (item instanceof Number || item instanceof Boolean) {
                json.append(item);
            } else if (item instanceof Map) {
                json.append(convertToJson((Map<String, Object>) item));
            } else {
                json.append("\"").append(item.toString()).append("\"");
            }
        }
        json.append("]");
    }
}