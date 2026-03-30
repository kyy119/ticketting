# Agent: 공통모듈 & 보안

담당: 김영윤, 강성준

## 패키지
```
config/          SecurityConfig, WebMvcConfig, BatchConfig, XssFilter
common/util/     IpUtil, DateUtil, FileUtil
common/interceptor/  AccessLogInterceptor(→access_stats_log)
common/exception/    GlobalExceptionHandler, BusinessException, ErrorCode
common/dto/      ApiResponse<T>
```

## 보안
**XSS**: Servlet Filter+HttpServletRequestWrapper. HTML이스케이프.  
**SQL인젝션**: JPA PreparedStatement + NativeQuery 파라미터바인딩필수.  
**권한**: t_authority + t_member_authority(복합PK:mb_role_seq+mb_seq+role_seq). 개발중 permitAll → 배포시 `/ad/**` ADMIN.

## 배치

| 작업 | 시간 | 테이블 | 내용 |
|------|------|--------|------|
| 휴면 | 매일01:30 | m_member, usr_login_log | login_dt 1년미접속→mb_stts_cd휴면 |
| 쿠폰만료 | 매일00:30 | t_m_cpn | cpn_valid_end_dt경과→del_yn='Y' |
| 등급쿠폰 | 매월1일 | t_cpn, t_m_cpn | GOLD/VIP 월간자동발급 |
| 결제대기 | 매15분 | t_booking(미설계) | 15분초과→자동취소+좌석해제 |
| 블랙만료 | 매일00:00 | m_blacklist(미설계) | 기간종료→해제 |

## 접속로그
access_stats_log: 인터셉터에서 usr_id+req_url+reg_dt+reg_ip 자동기록.

## 유틸
**IpUtil**: X-Forwarded-For→Proxy-Client-IP→RemoteAddr  
**FileUtil**: t_cm_atch 연동. UUID+확장자화이트리스트  
**ApiResponse<T>**: `{status, message, data}`  
**GlobalExceptionHandler**: `@RestControllerAdvice`

## 프론트JS
**ajax.js**: `ajaxCall(url, method, data, successCb, errorCb)`  
**common.js**: `debounce(fn, wait)`, `formatNumber(n)`, `formatDate(str)`

## CI/CD
GitHub Actions + Jenkins(git→war→재기동) + 무중단배포(추후)
