# Agent: 콘서트/공연(ct)

공연 등록/조회, 장르별페이지, 메인홈, 랭킹, 검색. 콘서트등록 우선순위1(김영윤)

## 관련 테이블
- **⚠️ 미설계**: m_concert, m_concert_schedule → 예매 테이블 설계 시 함께 추가
- **t_cm_atch**: 포스터/상세이미지. file_id로 공연 연결.
- **t_comment**: 관람후기탭에서 cmt_type 필터.

## URL
ct/home(GET), ct/genre/{genreCd}(GET), ct/detail/{ctId}(GET), ct/ranking(GET), ct/search(API), ct/rankingData(API), ct/upcoming(API), ct/register(POST관리자), ct/update/{ctId}(PUT), ct/uploadPoster(POST)

## JSP
ctHome, ctGenre(genreCd파라미터), ctDetail, ctRanking, ctSearch

## 메인홈 (위→아래)
1. 배너슬라이더(3~5초,좌우화살표) 2. 티켓오픈예정 3. 실시간랭킹(장르탭,1~10위,↑↓-) 4. 장르별인기공연(탭,카드그리드) 5. 이벤트배너(t_event) 6. MD추천

## 장르 (공통코드 CT001)
뮤지컬(1001), 콘서트(1002), 연극(1003), 클래식/무용(1004), 전시/행사(1005), 아동/가족(1006), 스포츠(1007), 레저/캠핑(1008)

## GNB (header.jsp)
상단: 로고+검색바+로그인/회원가입(또는 마이페이지/로그아웃)
하단: 장르8개 || 랭킹|티켓오픈|혜택존|이벤트

## 장르페이지: 필터(지역/날짜/가격대/상태) + 정렬(인기/최신/종료임박) + 4열카드(모바일2열) + 페이지네이션. 배지: 단독판매(#7B61FF)/좌석우위(#00B4D8)/얼리버드(#FF9500)

## 공연상세: 포스터(좌)+정보(우)+[예매하기][찜♡]. 탭: 공연정보|캐스팅|관람후기(t_comment)|기대평|공연장정보

## 콘서트등록(관리자): 공연명/장르/공연장/기간/회차/관람등급/좌석가격/포스터(t_cm_atch)/상세이미지/캐스팅
