package com.shopeasy.shopeasy.util;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

public class CustomErrorFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization code if needed
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) 
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        try {
            // Try to process the request normally
            chain.doFilter(request, response);
        } catch (Exception e) {
            // If an exception occurs or the resource is not found
            httpResponse.setStatus(HttpServletResponse.SC_NOT_FOUND);
            httpRequest.getRequestDispatcher("/view/error.jsp").forward(request, response);
        }
    }

    @Override
    public void destroy() {
        // Cleanup code if needed
    }
}