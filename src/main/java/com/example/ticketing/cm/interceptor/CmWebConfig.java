package com.example.ticketing.cm.interceptor;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
@RequiredArgsConstructor
public class CmWebConfig implements WebMvcConfigurer {

    private final CmLogInterceptor cmLogInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(cmLogInterceptor)
                .addPathPatterns("/**") // 모든 경로에 적용
                .excludePathPatterns("/css/**", "/images/**", "/js/**", "/favicon.ico", "/error");
    }
}