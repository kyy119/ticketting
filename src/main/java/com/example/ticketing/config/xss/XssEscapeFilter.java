package com.example.ticketing.config.xss;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;

public class XssEscapeFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        if (request instanceof HttpServletRequest httpRequest) {
            chain.doFilter(new XssEscapeRequestWrapper(httpRequest), response);
        } else {
            chain.doFilter(request, response);
        }
    }
}
