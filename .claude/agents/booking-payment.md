# Agent: 예매(bk) & 결제(py)

예매플로우(대기열→좌석→결제→완료)와 결제처리. 전원 각자 개발.

## 관련 테이블
- **⚠️ 전부 미설계**: m_seat, t_booking, t_payment → DB 설계 우선
- **t_cpn / t_m_cpn**: 결제시 쿠폰적용. t_m_cpn(m_cpn_seq+cpn_seq+mb_seq 복합PK), cpn_valid_end_dt로 유효기간체크

## URL - 예매(bk)
bk/queue/{csId}(GET), bk/schedule/{ctId}(GET), bk/seat/{csId}(GET), bk/payment/{bkId}(GET), bk/complete/{bkId}(GET), bk/history(GET), bk/enterQueue(POST), bk/queueStatus(GET), bk/seatStatus/{csId}(GET), bk/holdSeat(POST), bk/releaseSeat(DELETE), bk/confirm(POST), bk/cancel/{bkId}(POST)

## URL - 결제(py)
py/verify(POST), py/cancel/{pyId}(POST)

## JSP
bkQueue, bkSchedule, bkSeat, bkPayment, bkComplete, bkFail, bkHistory

## 전체플로우 (하나의 트랜잭션)
```
[예매하기] → 대기열(Redis) → 날짜/시간선택 → 좌석선택 → 결제(포트원) → 완료/실패
```

**대기열**: Redis Sorted Set `queue:{csId}`. 폴링3초. 10분초과제거. 동시허용설정값(예:100명).
**날짜/시간**: 캘린더→회차AJAX. 매진불가. 잔여석표시.
**좌석선택**: holdSeat 임시선점(10분TTL). 폴링5초 실시간. 1인최대4매.
**결제**: `IMP.request_pay()` → 포트원 → `py/verify`(imp_uid,merchant_uid) → 서버금액검증 → 확정. 쿠폰시 t_m_cpn.del_yn='Y'.
**결제수단**: 카카오페이, 네이버페이, 토스 (포트원 통일)
**취소**: D-7무료/D-3 10%/D-1 30%. 포트원취소→쿠폰환원(del_yn='N')→좌석복원.
**대기정리배치**: 15분초과미결제→자동취소+좌석해제 (매15분)

## 동시성: Redis Lock 또는 DB비관적락. 1인4매 양쪽검증. 대기열우회방지.
