# Agent: 부가기능 (쿠폰cp / 이벤트ev / 리뷰rv / 공지nt / 관리자ad)

담당: 김영윤(쿠폰/등급), 현동햄(리뷰/댓글)

---

## 쿠폰/이벤트 (cp, ev) - 김영윤

**테이블**:
- **t_cpn**: cpn_seq(PK), cpn_nm, cpn_no, cpn_type(CHAR4), disc_rt, use_day(BIGINT)
- **t_m_cpn**: m_cpn_seq+cpn_seq+mb_seq(복합PK). cpn_valid_st_dt, cpn_valid_end_dt
- **t_event**: event_seq+cpn_seq(복합PK). event_title, event_content, event_start_dt, event_end_dt(NULL). IDX: cpn_seq, event_start_dt
- **t_event_cpn**: event_cpn_seq+cpn_seq+event_seq(복합PK). event_cpn_amt(수량). IDX: event_seq, cpn_seq
- **⚠️ t_point, m_grade**: 미설계

**URL**: cp/couponList, cp/pointHistory, cp/gradeInfo, cp/availableCoupons(API), cp/useCoupon(POST), cp/usePoint(POST)
**JSP**: cpCoupon, cpPoint, cpGrade

쿠폰: cpn_type 정률/정액. t_m_cpn 회원보유(유효기간). use_day 유효일수. 배치: 만료비활성화(매일), 등급별발급(매월1일).
이벤트: t_event→t_event_cpn 쿠폰연결(event_cpn_amt 수량).
등급: WELCOME→SILVER(연3회)→GOLD(연10회)→VIP(연20회). 트리거 자동변경.

---

## 리뷰/댓글 (rv) - 현동햄

- **t_comment**: cmt_seq(PK), cmt_type, mb_uid, cmt_dt, cmt_view_cnt, cmt_rating(FLOAT), cmt_title, cmt_content. IDX: mb_uid, del_yn
- **t_reply**: rep_seq+cmt_seq(복합PK). mb_uid, rep_content. IDX: cmt_seq, mb_uid

**URL**: rv/list/{ctId}(API), rv/create(POST), rv/update(PUT), rv/delete(DELETE), rv/reply(POST), rv/myReviews(GET)
**JSP**: rvMyReviews (관람후기탭은 ctDetail에서 AJAX)

cmt_type으로 리뷰/기대평 구분. cmt_rating 별점. t_reply(cmt_seq FK) 댓글. 관람완료회원만.

---

## 공지사항 (nt)

- **t_notice**: not_seq(PK), not_no(제목), not_content, not_dt
- **t_cm_atch**: file_id로 첨부파일 연결

**URL**: nt/list, nt/detail/{ntId}, nt/create(POST관리자), nt/update(PUT), nt/delete(DELETE)
**JSP**: ntList, ntDetail

---

## 첨부파일 (t_cm_atch)
atch_seq(PK), file_id(연결키), sort_no, orignl_file_nm, file_url, file_sz, file_type

---

## 관리자 (ad) - 제일 마지막

- **t_authority**: role_seq(PK), role_name, role_content
- **t_member_authority**: mb_role_seq+mb_seq+role_seq(복합PK). IDX: mb_seq, role_seq
- **access_stats_log**: ⚡불변로그. log_seq(PK), usr_id, req_url. reg_dt/reg_id/reg_ip만. IDX: usr_id, reg_dt
- **⚠️ m_blacklist**: 미설계

**URL**: ad/dashboard, ad/concertList, ad/concertReg, ad/memberList, ad/blacklist, ad/gradeManage, ad/couponManage, ad/log, ad/stats
**JSP**: adDashboard 외 9개. **별도레이아웃**: adHeader+adSidebar

대시보드: 매출/예매수/신규회원/활성회원 + 차트. 로그: access_stats_log(INSERT만, 수정/삭제 불가). 권한: t_authority+t_member_authority. 블랙리스트: 미설계→추가필요.
