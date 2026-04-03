<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>공지사항 XSS 필터 테스트</title>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="/js/utils.js"></script>
    <script src="/js/form-utils.js"></script>
    <link rel="stylesheet" crossorigin
          href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css"/>
    <style>
        :root {
            --color-primary:       #FF2656;
            --color-primary-hover: #e01f4a;
            --color-bg:            #f4f6fb;
            --color-white:         #ffffff;
            --color-border:        #e2e8f0;
            --color-text:          #1a202c;
            --color-text-sub:      #718096;
            --color-row-hover:     #fff5f7;
            --color-success:       #38a169;
            --color-warn:          #d69e2e;
            --radius:  10px;
            --shadow:  0 1px 4px rgba(0,0,0,0.08);
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: var(--color-bg);
            color: var(--color-text);
            font-size: 14px;
            line-height: 1.5;
        }

        .nt-wrap { max-width: 1100px; margin: 0 auto; padding: 36px 24px; }

        .nt-page-header { margin-bottom: 28px; }
        .nt-page-header__title { font-size: 22px; font-weight: 700; }
        .nt-page-header__desc  { margin-top: 4px; font-size: 13px; color: var(--color-text-sub); }

        /* ─── Panel ─── */
        .nt-panel {
            background: var(--color-white);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            overflow: hidden;
            margin-bottom: 24px;
        }
        .nt-panel__head {
            display: flex; align-items: center; justify-content: space-between;
            padding: 16px 20px; border-bottom: 1px solid var(--color-border);
        }
        .nt-panel__title { font-size: 15px; font-weight: 600; }

        /* ─── Form ─── */
        .nt-form { padding: 20px; display: flex; flex-direction: column; gap: 14px; }

        .nt-form__row { display: flex; flex-direction: column; gap: 6px; }
        .nt-form__label { font-size: 12px; font-weight: 600; color: var(--color-text-sub); }

        .nt-form__input,
        .nt-form__textarea {
            width: 100%; padding: 9px 12px; border: 1px solid var(--color-border);
            border-radius: 6px; font-family: inherit; font-size: 13px;
            transition: border-color 0.15s;
        }
        .nt-form__input:focus,
        .nt-form__textarea:focus  { outline: none; border-color: var(--color-primary); }
        .nt-form__textarea        { height: 90px; resize: vertical; }

        /* ─── XSS 테스트 버튼 ─── */
        .xss-payload-bar {
            background: #fffbeb;
            border: 1px solid #fde68a;
            border-radius: 8px;
            padding: 12px 16px;
        }
        .xss-payload-bar__title {
            font-size: 11px; font-weight: 700; color: var(--color-warn);
            text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 8px;
        }
        .xss-payload-bar__btns { display: flex; flex-wrap: wrap; gap: 6px; }

        .xss-badge {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 4px 10px; border-radius: 4px; font-size: 11px; font-weight: 500;
            cursor: pointer; border: 1px solid #fde68a; background: #fef3c7;
            color: #92400e; font-family: 'SFMono-Regular', Consolas, monospace;
            transition: background 0.15s;
        }
        .xss-badge:hover { background: #fde68a; }

        /* ─── 마지막 저장 결과 박스 ─── */
        .nt-result-box {
            display: none;
            background: #f0fff4; border: 1px solid #9ae6b4;
            border-radius: 8px; padding: 14px 16px; font-size: 12px;
        }
        .nt-result-box.show { display: block; }
        .nt-result-box__title { font-weight: 700; color: var(--color-success); margin-bottom: 10px; }
        .nt-result-box__row   { display: flex; gap: 8px; margin-bottom: 6px; }
        .nt-result-box__key   { width: 80px; flex-shrink: 0; color: var(--color-text-sub); font-weight: 600; }
        .nt-result-box__val   {
            font-family: 'SFMono-Regular', Consolas, monospace;
            word-break: break-all; color: var(--color-text);
            background: #fff; border: 1px solid var(--color-border);
            border-radius: 4px; padding: 3px 8px; flex: 1;
        }
        .nt-result-box__val--highlight { color: var(--color-success); font-weight: 700; }

        /* ─── Form Actions ─── */
        .nt-form__actions { display: flex; justify-content: flex-end; gap: 8px; }

        /* ─── Buttons ─── */
        .btn {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 7px 14px; border-radius: 6px; font-size: 13px; font-weight: 500;
            cursor: pointer; border: none; font-family: inherit; transition: background 0.15s;
        }
        .btn--primary { background: var(--color-primary); color: #fff; }
        .btn--primary:hover { background: var(--color-primary-hover); }
        .btn--ghost { background: transparent; border: 1px solid var(--color-border); color: var(--color-text); }
        .btn--ghost:hover { background: var(--color-bg); }
        .btn--sm { padding: 5px 10px; font-size: 12px; }
        .btn:disabled { opacity: 0.45; cursor: not-allowed; pointer-events: none; }

        /* ─── Table ─── */
        .nt-table-wrap { overflow-x: auto; }
        .nt-table { width: 100%; border-collapse: collapse; }

        .nt-table thead th {
            position: sticky; top: 0; z-index: 1;
            background: #f8fafc; padding: 10px 14px;
            text-align: left; font-size: 12px; font-weight: 600;
            color: var(--color-text-sub); border-bottom: 1px solid var(--color-border);
        }
        .nt-table tbody td {
            padding: 11px 14px; border-bottom: 1px solid var(--color-border);
            font-size: 13px; vertical-align: middle;
        }
        .nt-table tbody tr:last-child td { border-bottom: none; }
        .nt-table tbody tr:hover td { background: var(--color-row-hover); }

        .nt-table .cell-title   { max-width: 280px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .nt-table .cell-content { max-width: 400px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; color: var(--color-text-sub); }
        .nt-table .cell-safe    { color: var(--color-success); font-size: 11px; font-weight: 600; }

        /* ─── Empty State ─── */
        .nt-empty { padding: 52px 20px; text-align: center; color: var(--color-text-sub); }
        .nt-empty__icon { font-size: 36px; margin-bottom: 10px; }
        .nt-empty__text { font-size: 13px; line-height: 1.7; }

        /* ─── Toast ─── */
        #toastContainer {
            position: fixed; bottom: 28px; right: 28px;
            display: flex; flex-direction: column; gap: 8px; z-index: 9999;
        }
        .toast {
            padding: 12px 20px; border-radius: 8px; color: #fff;
            font-size: 13px; font-weight: 500;
            box-shadow: 0 4px 16px rgba(0,0,0,0.15); animation: toastIn 0.2s ease;
        }
        .toast--success { background: var(--color-success); }
        .toast--error   { background: var(--color-primary); }

        @keyframes toastIn {
            from { transform: translateX(30px); opacity: 0; }
            to   { transform: translateX(0);    opacity: 1; }
        }
    </style>
</head>
<body>

<div class="nt-wrap">

    <div class="nt-page-header">
        <h1 class="nt-page-header__title">공지사항 XSS 필터 테스트</h1>
        <p class="nt-page-header__desc">
            서버 사이드 XSS 필터(XssEscapeFilter) 동작 검증 페이지입니다.
            아래 XSS 페이로드 버튼을 눌러 입력 후 저장하면, 서버가 수신한 값이 어떻게 이스케이프됐는지 확인할 수 있습니다.
        </p>
    </div>

    <%-- ════════════ 입력 패널 ════════════ --%>
    <div class="nt-panel">
        <div class="nt-panel__head">
            <span class="nt-panel__title">공지 등록</span>
        </div>

        <div class="nt-form">

            <%-- XSS 페이로드 테스트 버튼 모음 --%>
            <div class="xss-payload-bar">
                <div class="xss-payload-bar__title">⚠ XSS 테스트 페이로드 — 버튼을 누르면 제목에 자동 입력됩니다</div>
                <div class="xss-payload-bar__btns">
                    <button class="xss-badge" data-payload="<script>alert('XSS')</script>" onclick="fillPayload(this.dataset.payload)">script alert</button>
                    <button class="xss-badge" data-payload="<img src=x onerror=alert(1)>" onclick="fillPayload(this.dataset.payload)">img onerror</button>
                    <button class="xss-badge" data-payload="<svg onload=alert(1)>" onclick="fillPayload(this.dataset.payload)">svg onload</button>
                    <button class="xss-badge" data-payload="&quot;><script>alert(document.cookie)</script>" onclick="fillPayload(this.dataset.payload)">cookie steal</button>
                    <button class="xss-badge" data-payload="' OR 1=1 --" onclick="fillPayload(this.dataset.payload)">SQL Injection</button>
                    <button class="xss-badge" data-payload="javascript:alert(1)" onclick="fillPayload(this.dataset.payload)">javascript URI</button>
                </div>
            </div>

            <div class="nt-form__row">
                <label class="nt-form__label">제목 (not_no)</label>
                <input type="text" id="notNo" class="nt-form__input" placeholder="공지 제목을 입력하세요">
            </div>

            <div class="nt-form__row">
                <label class="nt-form__label">내용 (not_content)</label>
                <textarea id="notContent" class="nt-form__textarea" placeholder="공지 내용을 입력하세요"></textarea>
            </div>

            <%-- 저장 결과 표시 박스 --%>
            <div class="nt-result-box" id="resultBox">
                <div class="nt-result-box__title">서버 수신 및 저장 결과</div>
                <div class="nt-result-box__row">
                    <span class="nt-result-box__key">입력 제목</span>
                    <span class="nt-result-box__val" id="rawTitle"></span>
                </div>
                <div class="nt-result-box__row">
                    <span class="nt-result-box__key">저장 제목</span>
                    <span class="nt-result-box__val nt-result-box__val--highlight" id="savedTitle"></span>
                </div>
                <div class="nt-result-box__row">
                    <span class="nt-result-box__key">입력 내용</span>
                    <span class="nt-result-box__val" id="rawContent"></span>
                </div>
                <div class="nt-result-box__row">
                    <span class="nt-result-box__key">저장 내용</span>
                    <span class="nt-result-box__val nt-result-box__val--highlight" id="savedContent"></span>
                </div>
            </div>

            <div class="nt-form__actions">
                <button class="btn btn--ghost btn--sm" onclick="clearForm()">초기화</button>
                <button class="btn btn--primary btn--sm" id="saveBtn" onclick="saveNotice()">저장</button>
            </div>
        </div>
    </div>

    <%-- ════════════ 목록 패널 ════════════ --%>
    <div class="nt-panel">
        <div class="nt-panel__head">
            <span class="nt-panel__title">공지 목록</span>
            <span id="noticeCountBadge" style="font-size:12px; color:var(--color-text-sub);"></span>
        </div>

        <div class="nt-table-wrap">
            <div id="noticeListArea">
                <div class="nt-empty">
                    <div class="nt-empty__icon">⏳</div>
                    <div class="nt-empty__text">목록을 불러오는 중...</div>
                </div>
            </div>
        </div>
    </div>

</div>

<div id="toastContainer"></div>

<script>
    /* ── XSS 페이로드 자동 입력 ── */
    function fillPayload(text) {
        document.getElementById('notNo').value = text;
        document.getElementById('notContent').value = text + ' (내용 테스트)';
    }

    /* ── 폼 초기화 ── */
    function clearForm() {
        document.getElementById('notNo').value      = '';
        document.getElementById('notContent').value = '';
        document.getElementById('resultBox').classList.remove('show');
    }

    /* ── 공지 저장 (form-encoded POST → XSS 필터 통과) ── */
    function saveNotice() {
        const notNo      = document.getElementById('notNo').value.trim();
        const notContent = document.getElementById('notContent').value.trim();

        if (!notNo) { CmAtchUtils.showToast('제목을 입력해주세요.', 'error'); return; }
        if (!notContent) { CmAtchUtils.showToast('내용을 입력해주세요.', 'error'); return; }

        document.getElementById('saveBtn').disabled = true;

        /* $.ajax 기본 contentType = application/x-www-form-urlencoded
           → XssEscapeFilter의 getParameter() 경유 → 서버에서 이스케이프됨 */
        AppAjax.request({
            type       : 'POST',
            url        : '/nt/notice/save',
            data       : { notNo: notNo, notContent: notContent },
            loadingOff : true,
            success    : function(res) {
                const saved = res.data;

                /* 입력값 vs 저장값 비교 표시 */
                document.getElementById('rawTitle').textContent    = notNo;
                document.getElementById('savedTitle').textContent  = saved.notNo;
                document.getElementById('rawContent').textContent  = notContent;
                document.getElementById('savedContent').textContent = saved.notContent;
                document.getElementById('resultBox').classList.add('show');

                CmAtchUtils.showToast('저장되었습니다.', 'success');
                clearForm();
                refreshList();
            },
            onError: function() {
                document.getElementById('saveBtn').disabled = false;
            }
        });
        document.getElementById('saveBtn').disabled = false;
    }

    /* ── 공지 삭제 ── */
    function deleteNotice(notSeq) {
        if (!confirm('공지사항을 삭제하시겠습니까?')) return;
        AppAjax.request({
            type       : 'DELETE',
            url        : '/nt/notice/' + notSeq,
            loadingOff : true,
            success    : function() {
                CmAtchUtils.showToast('삭제되었습니다.', 'success');
                refreshList();
            }
        });
    }

    /* ── 목록 조회 및 렌더링 ── */
    function refreshList() {
        AppAjax.request({
            type       : 'GET',
            url        : '/nt/notice/list',
            loadingOff : true,
            success    : function(res) {
                renderNoticeTable(res.data || []);
            }
        });
    }

    function renderNoticeTable(list) {
        const area  = document.getElementById('noticeListArea');
        const badge = document.getElementById('noticeCountBadge');
        if (badge) badge.textContent = list.length + '개';

        if (!list.length) {
            area.innerHTML =
                '<div class="nt-empty">' +
                '<div class="nt-empty__icon">📋</div>' +
                '<div class="nt-empty__text">등록된 공지사항이 없습니다.</div>' +
                '</div>';
            return;
        }

        let rows = '';
        list.forEach(function(n) {
            const title   = CmAtchUtils.esc(n.notNo      || '');
            const content = CmAtchUtils.esc(n.notContent || '');
            const regDt   = CmAtchUtils.esc(n.regDt      || '');
            rows +=
                '<tr>' +
                '<td>' + CmAtchUtils.esc(String(n.notSeq)) + '</td>' +
                '<td class="cell-title" title="' + title   + '">' + title   + '</td>' +
                '<td class="cell-content" title="' + content + '">' + content + '</td>' +
                '<td class="cell-safe">✔ 이스케이프됨</td>' +
                '<td>' + regDt + '</td>' +
                '<td><button class="btn btn--ghost btn--sm" onclick="deleteNotice(' + n.notSeq + ')">삭제</button></td>' +
                '</tr>';
        });

        area.innerHTML =
            '<table class="nt-table">' +
            '<thead><tr>' +
              '<th style="width:60px">번호</th>' +
              '<th>제목</th>' +
              '<th>내용</th>' +
              '<th style="width:100px">XSS 상태</th>' +
              '<th style="width:100px">등록일</th>' +
              '<th style="width:70px"></th>' +
            '</tr></thead>' +
            '<tbody>' + rows + '</tbody>' +
            '</table>';
    }

    /* ── 페이지 로드 ── */
    refreshList();
</script>

</body>
</html>
