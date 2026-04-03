package com.example.ticketing.cm.interceptor;

import com.example.ticketing.cm.service.CmAccessStatsLogService;
import com.example.ticketing.entity.CmAccessStatsLog;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;
import java.util.Map;

@Component
@RequiredArgsConstructor
public class CmLogInterceptor implements HandlerInterceptor {

    private final CmAccessStatsLogService cmAccessStatsLogService;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {

        // 1. IP 추출 (Cloudflare 터널 방식 프록시 고려)
        String reqIp = request.getHeader("X-Forwarded-For");
        if (reqIp == null || reqIp.isEmpty()) {
            reqIp = request.getRemoteAddr();
        }

        // 2. 세션에서 로그인 아이디 추출
        String userId = "GUEST";
        HttpSession session = request.getSession(false);

        if (session != null && session.getAttribute("sessionMap") != null) {
            Map<String, Object> sessionMap = (Map<String, Object>) session.getAttribute("sessionMap");
            String sessionUserId = (String) sessionMap.get("usrId");

            if (sessionUserId != null && !sessionUserId.trim().isEmpty()) {
                userId = sessionUserId;
            }
        }

        //전체 URL 및 쿼리 스트링(파라미터)
        StringBuffer requestUrl = request.getRequestURL(); // http://localhost:8080/cm/testPage
        String queryString = request.getQueryString();     // param=123 (없으면 null)

        // 쿼리 스트링이 존재할 경우에만 ? 와 함께 덧붙임
        if (queryString != null && !queryString.isEmpty()) {
            requestUrl.append("?").append(queryString);
        }

        String url = requestUrl.toString();

        // 3. 엔티티 생성
        CmAccessStatsLog log = CmAccessStatsLog.builder()
                .usrId(userId)                       // 접속자 ID
                .reqUrl(url)    // 요청 URL
                .regId(userId)                       // 등록자 ID (접속자와 동일하게 처리)
                .regIp(reqIp)                       // 접속 IP
                .build();

        // 4. DB 저장
        cmAccessStatsLogService.saveLog(log);

        return true;
    }
}