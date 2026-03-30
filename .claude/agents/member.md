# Agent: 회원(mb)

담당: 정경득(가입/탈퇴), 김영윤(회원정보/마이페이지)

## 테이블
- **m_member**: mb_seq(PK), mb_uid(UNIQUE), mb_stts_cd(CHAR4), mb_pass(VARCHAR1000,해시), mb_name(VARCHAR50), mb_addr(VARCHAR1000), mb_telno(VARCHAR100), mb_reside_no(VARCHAR1000,암호화필수), mb_gender(CHAR1), mb_email(UNIQUE,VARCHAR100)
- **login_lock_mng**: lock_seq(PK), mb_uid, fail_cnt(SMALLINT)
- **usr_login_log**: log_seq(PK), mb_uid, login_dt, login_ip, success_yn, usr_agent(NULL) + 공통컬럼
- **t_member_authority**: mb_role_seq+mb_seq+role_seq(복합PK)

## URL
mb/login(GET,POST), mb/logout(POST), mb/join(GET,POST), mb/checkId(GET), mb/mypage(GET), mb/edit(GET,PUT), mb/withdraw(DELETE), mb/rejoin(POST)

## JSP
mbLogin, mbJoin, mbJoinComplete, mbMypage, mbEdit, mbWithdraw

## 핵심 로직

**가입**: mb_uid 중복확인(UNIQUE+AJAX) → mb_email 중복확인(UNIQUE) → 블랙리스트확인 → 탈퇴3개월이내 재가입가능(mb_telno+mb_reside_no+mb_name으로 확인) → mb_pass BCrypt해시, mb_reside_no 암호화 저장. t_member_authority에 기본권한 INSERT.

**로그인**:
1. mb_uid/mb_pass 확인 → mb_stts_cd 상태확인
2. 실패시 login_lock_mng.fail_cnt++, usr_login_log에 success_yn='N' 기록
3. **fail_cnt 3회 → mb_stts_cd 정지변경**
4. 성공시 fail_cnt=0, usr_login_log에 success_yn='Y' 기록, 세션생성
5. 정지해제: mb_telno+mb_reside_no+mb_name 인증

**휴면배치** (매일 01:30): usr_login_log.login_dt 1년미접속 → mb_stts_cd 휴면

**탈퇴**: 비밀번호재확인 → mb_stts_cd 탈퇴(물리삭제X) → del_yn='Y', del_dt 기록 → 3개월이내 재가입가능

**마이페이지**: 내정보, 예매/취소내역, 찜한공연, 쿠폰/포인트, 등급, 문의내역, 리뷰관리, 정보수정, 탈퇴
