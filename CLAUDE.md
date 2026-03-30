# NOL Ticketing 프로젝트 규칙

## 기술스택
Java 17, Spring Boot 3.5.11, PostgreSQL 16.6, Spring Data JPA 3.5.11, QueryDSL 5.1.0, Spring Security 6.5.4, JSP + JSTL 3.0.1, Maven(WAR), Lombok, P6Spy, Spring Batch. 추후: Redis, Keycloak 24.x, Prometheus, Grafana.

## 네이밍 절대규칙
**패키지**: `com.example.ticketing.{축약어}` (member→mb, booking→bk, payment→py, concert→ct, inquiry→iq, notice→nt, coupon→cp, review→rv, admin→ad, event→ev)  
**Entity**: `com.example.ticketing.entity`에 집중 배치  
**클래스명**: 축약어 접두사. `MbController`, `MbService`, `MbRepository`, `MbRestController`  
**URL**: 축약어 접두사 필수. `@RequestMapping("mb/login")`  
**JSP**: `WEB-INF/views/{축약어}/{축약어}{기능}.jsp`  
**CSS클래스**: BEM+축약어. `.mb-login__input--error`

## 레이어 구조 (모든 기능 동일)
```
com.example.ticketing.{축약어}/
├── {축약어}controller/{Xx}Controller.java      # @Controller (JSP)
├── {축약어}controller/{Xx}RestController.java   # @RestController (API)
├── {축약어}service/{Xx}Service.java
└── {축약어}repository/{Xx}Repository.java
```

## 트랜잭션
클래스: `@Transactional(readOnly=true)` → 변경 메서드만 `@Transactional` 오버라이드

## DB 공통사항

**PK**: `GENERATED ALWAYS AS IDENTITY`. JPA: `@GeneratedValue(strategy=GenerationType.IDENTITY)`.

**공통컬럼 — BaseEntity 상속** (일반 테이블용):
```
reg_dt DATE NN, reg_id VARCHAR(50) NN, reg_ip VARCHAR(50) NN,
mod_dt DATE NN, mod_id VARCHAR(50) NN, mod_ip VARCHAR(50) NN,
del_yn CHAR(1) DEFAULT 'N' NN, del_dt DATE NULL, del_id VARCHAR(50) NULL, del_ip VARCHAR(50) NULL
```

**불변 로그 테이블** (usr_login_log, access_stats_log): MOD/DEL 컬럼 없음. `reg_dt, reg_id, reg_ip`만. → **BaseEntity 상속하지 않고 별도 매핑**.

**공통코드**: t_grp_cd(grp_cd PK) + t_dtl_cd(dtl_cd+grp_cd 복합PK). grp_cd규칙: 축약어대문자+순번3자리(MB001). 조회: `nol_2025.fn_get_dtl_nm('CM001','1001')`

## Entity 규칙
`@Getter` `@NoArgsConstructor` `@Builder`. `@Setter` 금지. FK는 `FetchType.LAZY`. `ddl-auto` 절대 금지. UNIQUE 제약조건은 `@Table(uniqueConstraints=...)`.

## application.properties
Git 미포함. 수정시 `# [이름] [설명] ([날짜])` 주석 필수.
```properties
spring.application.name=ticketing
spring.datasource.url=jdbc:postgresql://moon-core:5433/NOL
spring.datasource.username=nol_2025
spring.datasource.password=NOL_2025!@#
spring.mvc.view.prefix=/WEB-INF/views/
spring.mvc.view.suffix=.jsp
```
호스트: `221.139.110.149 moon-core`

## Security (개발중)
전체 permitAll. 배포시 `/ad/**`→ROLE_ADMIN. 권한: t_authority + t_member_authority 기반.

## API 응답
`ApiResponse<T>` 공통 래퍼 (status, message, data)

## 프론트 공통
CSS변수(하드코딩금지). 메인컬러 `#FF2656`. Pretendard 폰트. 인라인스타일 금지. header.jsp/footer.jsp include. 관리자는 별도 레이아웃(adSidebar).

## 팀원
정경득(회원가입/탈퇴), 김영윤(예매내역/회원정보/쿠폰/등급/콘서트등록/공통모듈), 현동햄(문의/리뷰/댓글), 강성준(공통모듈), 전원(예매)
