package com.example.ticketing.config;

import com.example.ticketing.cm.interceptor.CmLogInterceptor;
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

    private final CmLogInterceptor cmLogInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(cmLogInterceptor)
                .addPathPatterns("/**")
                .excludePathPatterns("/css/**", "/images/**", "/js/**", "/favicon.ico", "/error");
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
