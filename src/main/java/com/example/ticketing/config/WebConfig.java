package com.example.ticketing.config;

import com.example.ticketing.ac.log.interceptor.AccessLogInterceptor;
import com.example.ticketing.config.xss.XssEscapeFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
@EnableAsync
@RequiredArgsConstructor
public class WebConfig implements WebMvcConfigurer {

    private final AccessLogInterceptor accessLogInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(accessLogInterceptor)
                .addPathPatterns("/**");
    }

    @Bean
    public FilterRegistrationBean<XssEscapeFilter> xssEscapeFilter() {
        FilterRegistrationBean<XssEscapeFilter> bean = new FilterRegistrationBean<>();
        bean.setFilter(new XssEscapeFilter());
        bean.addUrlPatterns("/*");
        bean.setOrder(1);
        bean.setName("xssEscapeFilter");
        return bean;
    }
}
