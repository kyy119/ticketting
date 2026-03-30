# Agent: Entity & DB 설계

## 확정 테이블 16개 (최종 DDL 기준)

### m_member (회원)
PK: mb_seq(IDENTITY). UNIQUE: mb_uid, mb_email.  
mb_uid(VARCHAR50), mb_stts_cd(CHAR4,DEFAULT'Y'), mb_pass(VARCHAR1000,해시필수), mb_name(VARCHAR50), mb_addr(VARCHAR1000), mb_telno(VARCHAR100), mb_reside_no(VARCHAR1000,암호화필수), mb_gender(CHAR1), mb_email(VARCHAR100) + 공통컬럼  
IDX: idx_m_member_del_yn(del_yn)

### login_lock_mng (로그인 잠금)
PK: lock_seq(IDENTITY). mb_uid(VARCHAR50), fail_cnt(SMALLINT) + 공통컬럼  
IDX: idx_lock_mng_mb_uid(mb_uid)

### usr_login_log (로그인 로그)
PK: log_seq(IDENTITY). mb_uid(VARCHAR50), login_dt(DATE), login_ip(VARCHAR50), success_yn(CHAR1), usr_agent(VARCHAR500,NULL) + 공통컬럼  
IDX: idx_login_log_mb_uid(mb_uid), idx_login_log_dt(login_dt)

### access_stats_log (접속 통계)
PK: log_seq(IDENTITY). usr_id(VARCHAR50), req_url(VARCHAR1000) + 공통컬럼  
IDX: idx_access_stats_usr(usr_id), idx_access_stats_dt(reg_dt)

### t_authority (권한)
PK: role_seq(IDENTITY). role_name(VARCHAR50), role_content(VARCHAR100) + 공통컬럼

### t_member_authority (회원-권한)
복합PK: mb_role_seq(IDENTITY)+mb_seq+role_seq + 공통컬럼  
IDX: idx_member_authority_mb(mb_seq), idx_member_authority_role(role_seq)

### t_cpn (쿠폰)
PK: cpn_seq(IDENTITY). cpn_nm(VARCHAR100), cpn_no(VARCHAR1000), cpn_type(CHAR4), disc_rt(VARCHAR100), use_day(BIGINT) + 공통컬럼

### t_m_cpn (회원-쿠폰)
복합PK: m_cpn_seq(IDENTITY)+cpn_seq+mb_seq. cpn_valid_st_dt(DATE), cpn_valid_end_dt(DATE) + 공통컬럼  
IDX: idx_m_cpn_mb(mb_seq), idx_m_cpn_cpn(cpn_seq)

### t_event (이벤트)
복합PK: event_seq(IDENTITY)+cpn_seq. event_title(VARCHAR1000), event_content(VARCHAR1000), event_start_dt(DATE), event_end_dt(DATE,NULL) + 공통컬럼  
IDX: idx_event_cpn_seq(cpn_seq), idx_event_start_dt(event_start_dt)

### t_event_cpn (이벤트-쿠폰)
복합PK: event_cpn_seq(IDENTITY)+cpn_seq+event_seq. event_cpn_amt(BIGINT) + 공통컬럼  
IDX: idx_event_cpn_event(event_seq), idx_event_cpn_cpn(cpn_seq)

### t_comment (평가/리뷰)
PK: cmt_seq(IDENTITY). cmt_type(VARCHAR10), mb_uid(VARCHAR50), cmt_dt(DATE), cmt_view_cnt(BIGINT), cmt_rating(FLOAT), cmt_title(VARCHAR1000), cmt_content(VARCHAR1000) + 공통컬럼  
IDX: idx_comment_mb_uid(mb_uid), idx_comment_del_yn(del_yn)

### t_reply (댓글)
복합PK: rep_seq(IDENTITY)+cmt_seq. mb_uid(VARCHAR50), rep_content(VARCHAR1000) + 공통컬럼  
IDX: idx_reply_cmt(cmt_seq), idx_reply_mb_uid(mb_uid)

### t_notice (공지사항)
PK: not_seq(IDENTITY). not_no(VARCHAR100,제목), not_content(VARCHAR1000), not_dt(DATE) + 공통컬럼

### t_cm_atch (첨부파일)
PK: atch_seq(IDENTITY). file_id(VARCHAR50), sort_no(BIGINT), orignl_file_nm(VARCHAR100), file_url(VARCHAR1000), file_sz(VARCHAR50), file_type(VARCHAR10) + 공통컬럼

### t_grp_cd (그룹코드)
PK: grp_cd(VARCHAR30). grp_cd_nm(VARCHAR100), use_yn(CHAR1,DEFAULT'Y',NULL), remark(VARCHAR1000,NULL) + 공통컬럼

### t_dtl_cd (상세코드)
복합PK: dtl_cd(VARCHAR30)+grp_cd(VARCHAR30). dtl_cd_nm(VARCHAR100), sort_no(SMALLINT,NULL), use_yn(CHAR1,DEFAULT'Y',NULL), remark(VARCHAR1000,NULL) + 공통컬럼  
IDX: idx_dtl_cd_grp(grp_cd)

## ⚠️ 미설계 (예매 영역)
m_concert, m_concert_schedule, m_seat, t_booking, t_payment, t_point, m_grade, m_blacklist, t_inquiry

## 복합PK JPA: `@IdClass` 방식 사용.
