package com.shopeasy.shopeasy.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.shopeasy.shopeasy.dao.OrderDAO;
import com.shopeasy.shopeasy.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {"/reports", "/reports/data"})
public class ReportsController extends HttpServlet {
    private OrderDAO orderDAO;
    private ObjectMapper objectMapper;
    
    @Override
    public void init() throws ServletException {
        super.init();
        orderDAO = new OrderDAO();
        objectMapper = new ObjectMapper();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (!isAdminRole(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/customer/dashboard");
            return;
        }
        
        String path = request.getServletPath();
        
        if ("/reports".equals(path)) {
            // Show reports page
            request.getRequestDispatcher("/view/staff/reports.jsp").forward(request, response);
        } else if ("/reports/data".equals(path)) {
            // Generate report data as JSON
            generateReportData(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
    
    private void generateReportData(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get parameters
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");
        
        System.out.printf("Report request - Start: %s, End: %s%n", startDateStr, endDateStr);
        
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        
        try {
            Date startDate = dateFormat.parse(startDateStr);
            Date endDate = dateFormat.parse(endDateStr);
            
            // Validate date range (at least one week)
            Calendar calStart = Calendar.getInstance();
            calStart.setTime(startDate);
            
            Calendar calEnd = Calendar.getInstance();
            calEnd.setTime(endDate);
            
            // Calculate difference in days
            long diffMillis = calEnd.getTimeInMillis() - calStart.getTimeInMillis();
            long diffDays = diffMillis / (24 * 60 * 60 * 1000);
            
            if (diffDays < 7) {
                response.setContentType("application/json");
                PrintWriter out = response.getWriter();
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("error", "Date range must be at least one week");
                
                System.out.printf("Validation error: Date range is only %d days%n", diffDays);
                
                out.print(objectMapper.writeValueAsString(errorResponse));
                return;
            }
            
            // Get report data
            Map<String, Double> revenueData = orderDAO.getRevenueBetweenDates(startDate, endDate);
            List<Map<String, Object>> popularProducts = orderDAO.getMostPopularProductsBetweenDates(startDate, endDate, 5);
            Map<String, Object> salesSummary = orderDAO.getSalesSummaryBetweenDates(startDate, endDate);
            
            // Create response
            Map<String, Object> reportData = new HashMap<>();
            reportData.put("revenueData", revenueData);
            reportData.put("popularProducts", popularProducts);
            reportData.put("salesSummary", salesSummary);
            
            // Debug - output the JSON data structure
            String jsonOutput = objectMapper.writeValueAsString(reportData);
            System.out.printf("JSON output: %s%n", jsonOutput);
            
            // Send response
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print(jsonOutput);
            
        } catch (ParseException e) {
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "Invalid date format");
            
            System.out.printf("Parse error: %s%n", e.getMessage());
            
            out.print(objectMapper.writeValueAsString(errorResponse));
        }
    }
    
    private boolean isAdminRole(String role) {
        return "manager".equalsIgnoreCase(role) || "staff".equalsIgnoreCase(role);
    }
}