<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>공통코드 관리</title>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="/js/utils.js"></script>
    <script src="/js/form-utils.js"></script>
    <link rel="stylesheet" as="style" crossorigin
          href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css"/>
    <style>
        :root {
            --color-primary: #FF2656;
            --color-primary-hover: #e01f4a;
            --color-bg: #f4f6fb;
            --color-white: #ffffff;
            --color-border: #e2e8f0;
            --color-text: #1a202c;
            --color-text-sub: #718096;
            --color-row-hover: #fff5f7;
            --color-row-selected: #ffe0e9;
            --color-success: #38a169;
            --radius: 10px;
            --shadow: 0 1px 4px rgba(0,0,0,0.08);
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: var(--color-bg);
            color: var(--color-text);
            font-size: 14px;
            line-height: 1.5;
        }

        /* ─── Layout ─── */
        .cm-wrap {
            max-width: 1320px;
            margin: 0 auto;
            padding: 36px 24px;
        }

        .cm-page-header {
            margin-bottom: 28px;
        }

        .cm-page-header__title {
            font-size: 22px;
            font-weight: 700;
        }

        .cm-page-header__desc {
            margin-top: 4px;
            font-size: 13px;
            color: var(--color-text-sub);
        }

        .cm-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
            align-items: start;
        }

        /* ─── Panel ─── */
        .cm-panel {
            background: var(--color-white);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            overflow: hidden;
        }

        .cm-panel__head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 16px 20px;
            border-bottom: 1px solid var(--color-border);
        }

        .cm-panel__title {
            font-size: 15px;
            font-weight: 600;
        }

        .cm-panel__badge {
            font-size: 12px;
            color: var(--color-primary);
            font-weight: 600;
            background: #fff0f4;
            padding: 2px 10px;
            border-radius: 99px;
        }

        /* ─── Buttons ─── */
        .btn {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 7px 14px;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 500;
            cursor: pointer;
            border: none;
            font-family: inherit;
            transition: background 0.15s, opacity 0.15s;
        }

        .btn--primary {
            background: var(--color-primary);
            color: #fff;
        }

        .btn--primary:hover { background: var(--color-primary-hover); }

        .btn--ghost {
            background: transparent;
            border: 1px solid var(--color-border);
            color: var(--color-text);
        }

        .btn--ghost:hover { background: var(--color-bg); }

        .btn--sm { padding: 5px 12px; font-size: 12px; }

        .btn:disabled { opacity: 0.45; cursor: not-allowed; pointer-events: none; }

        /* ─── Reg Form ─── */
        .cm-form {
            padding: 16px 20px;
            background: #fafbfd;
            border-bottom: 1px solid var(--color-border);
            display: none;
        }

        .cm-form.is-open { display: block; }

        .cm-form__grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }

        .cm-form__field {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .cm-form__field--full { grid-column: 1 / -1; }

        .cm-form__label {
            font-size: 12px;
            font-weight: 500;
            color: var(--color-text-sub);
        }

        .cm-form__label em {
            color: var(--color-primary);
            font-style: normal;
        }

        .cm-form__input,
        .cm-form__select {
            padding: 8px 10px;
            border: 1px solid var(--color-border);
            border-radius: 6px;
            font-size: 13px;
            font-family: inherit;
            outline: none;
            background: #fff;
            transition: border-color 0.15s;
        }

        .cm-form__input:focus,
        .cm-form__select:focus { border-color: var(--color-primary); }

        .cm-form__actions {
            display: flex;
            justify-content: flex-end;
            gap: 8px;
            margin-top: 4px;
            grid-column: 1 / -1;
        }

        /* ─── Table ─── */
        .cm-table-wrap {
            overflow-x: auto;
            max-height: 480px;
            overflow-y: auto;
        }

        .cm-table {
            width: 100%;
            border-collapse: collapse;
        }

        .cm-table thead th {
            position: sticky;
            top: 0;
            z-index: 1;
            background: #f8fafc;
            padding: 10px 14px;
            text-align: left;
            font-size: 12px;
            font-weight: 600;
            color: var(--color-text-sub);
            border-bottom: 1px solid var(--color-border);
            white-space: nowrap;
        }

        .cm-table tbody td {
            padding: 11px 14px;
            border-bottom: 1px solid var(--color-border);
            font-size: 13px;
            vertical-align: middle;
        }

        .cm-table tbody tr:last-child td { border-bottom: none; }

        .cm-table tbody tr.is-clickable { cursor: pointer; }

        .cm-table tbody tr.is-clickable:hover { background: var(--color-row-hover); }

        .cm-table tbody tr.is-selected { background: var(--color-row-selected) !important; }

        code {
            font-family: 'SFMono-Regular', Consolas, monospace;
            background: #f0f2f8;
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 12px;
        }

        /* ─── Badge ─── */
        .badge {
            display: inline-block;
            padding: 2px 9px;
            border-radius: 99px;
            font-size: 11px;
            font-weight: 600;
        }

        .badge--y { background: #e6f6ef; color: #276749; }
        .badge--n { background: #f0f2f5; color: #888; }

        /* ─── Prefix Preview ─── */
        .cm-prefix-wrap {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .cm-prefix-input { flex: 1; }

        .cm-prefix-arrow {
            color: var(--color-text-sub);
            font-size: 13px;
            flex-shrink: 0;
        }

        .cm-prefix-preview {
            font-family: 'SFMono-Regular', Consolas, monospace;
            font-size: 13px;
            font-weight: 600;
            color: var(--color-primary);
            background: #fff0f4;
            padding: 2px 10px;
            border-radius: 6px;
            min-width: 72px;
            text-align: center;
            flex-shrink: 0;
        }

        /* ─── Empty State ─── */
        .cm-empty {
            padding: 52px 20px;
            text-align: center;
            color: var(--color-text-sub);
        }

        .cm-empty__icon { font-size: 36px; margin-bottom: 10px; }
        .cm-empty__text { font-size: 13px; line-height: 1.7; }

        /* ─── Toast ─── */
        #toastContainer {
            position: fixed;
            bottom: 28px;
            right: 28px;
            display: flex;
            flex-direction: column;
            gap: 8px;
            z-index: 9999;
        }

        .toast {
            padding: 12px 20px;
            border-radius: 8px;
            color: #fff;
            font-size: 13px;
            font-weight: 500;
            box-shadow: 0 4px 16px rgba(0,0,0,0.15);
            animation: toastIn 0.2s ease;
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

<div class="cm-wrap">

    <div class="cm-page-header">
        <h1 class="cm-page-header__title">공통코드 관리</h1>
        <p class="cm-page-header__desc">그룹코드와 상세코드를 등록·관리합니다.</p>
    </div>

    <div class="cm-grid">

        <%-- ════════════ 그룹코드 패널 ════════════ --%>
        <div class="cm-panel">
            <div class="cm-panel__head">
                <span class="cm-panel__title">그룹코드</span>
                <button class="btn btn--primary btn--sm" onclick="toggleGrpForm()">+ 그룹코드 등록</button>
            </div>

            <form class="cm-form" id="grpForm" onsubmit="return false;">
                <div class="cm-form__grid">
                    <div class="cm-form__field">
                        <label class="cm-form__label">그룹코드 접두어 <em>*</em></label>
                        <div class="cm-prefix-wrap">
                            <input type="text" class="cm-form__input cm-prefix-input" id="grpCdPrefix" name="grpCdPrefix"
                                   placeholder="예: MB" maxlength="10"
                                   oninput="this.value=this.value.toUpperCase()"
                                   onblur="previewNextCode()">
                            <span class="cm-prefix-arrow">→</span>
                            <span class="cm-prefix-preview" id="grpCdPreview">—</span>
                        </div>
                    </div>
                    <div class="cm-form__field">
                        <label class="cm-form__label">그룹코드명 <em>*</em></label>
                        <input type="text" class="cm-form__input" id="grpCdNm" name="grpCdNm" placeholder="예: 회원 상태" maxlength="100">
                    </div>
                    <div class="cm-form__field">
                        <label class="cm-form__label">사용여부</label>
                        <select class="cm-form__select" id="grpUseYn" name="useYn">
                            <option value="Y">사용</option>
                            <option value="N">미사용</option>
                        </select>
                    </div>
                    <div class="cm-form__field">
                        <label class="cm-form__label">비고</label>
                        <input type="text" class="cm-form__input" id="grpRemark" name="remark" placeholder="선택사항" maxlength="1000">
                    </div>
                    <div class="cm-form__actions">
                        <button class="btn btn--ghost btn--sm" onclick="toggleGrpForm()">취소</button>
                        <button class="btn btn--primary btn--sm" onclick="saveGrpCd()">저장</button>
                    </div>
                </div>
            </form>

            <div class="cm-table-wrap">
                <table class="cm-table">
                    <thead>
                        <tr>
                            <th>그룹코드</th>
                            <th>그룹코드명</th>
                            <th>사용여부</th>
                            <th>등록일</th>
                        </tr>
                    </thead>
                    <tbody id="grpTableBody">
                    <c:choose>
                        <c:when test="${empty grpCdList}">
                            <tr>
                                <td colspan="4">
                                    <div class="cm-empty">
                                        <div class="cm-empty__icon">📂</div>
                                        <div class="cm-empty__text">등록된 그룹코드가 없습니다.</div>
                                    </div>
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="g" items="${grpCdList}">
                                <tr class="is-clickable"
                                    onclick="selectGrpCd('${g.grpCd}', '${g.grpCdNm}', this)">
                                    <td><code>${g.grpCd}</code></td>
                                    <td>${g.grpCdNm}</td>
                                    <td>
                                        <span class="badge ${g.useYn == 'Y' ? 'badge--y' : 'badge--n'}">
                                            ${g.useYn == 'Y' ? '사용' : '미사용'}
                                        </span>
                                    </td>
                                    <td>${g.regDt}</td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>
        </div>

        <%-- ════════════ 상세코드 패널 ════════════ --%>
        <div class="cm-panel">
            <div class="cm-panel__head">
                <div style="display:flex; align-items:center; gap:10px;">
                    <span class="cm-panel__title">상세코드</span>
                    <span class="cm-panel__badge" id="selectedGrpLabel" style="display:none"></span>
                </div>
                <button class="btn btn--primary btn--sm" id="dtlAddBtn"
                        onclick="toggleDtlForm()" disabled>+ 상세코드 등록</button>
            </div>

            <form class="cm-form" id="dtlForm" onsubmit="return false;">
                <div class="cm-form__grid">
                    <div class="cm-form__field">
                        <label class="cm-form__label" id="dtlCdLabel">상세코드 <em>*</em></label>
                        <input type="text" class="cm-form__input" id="dtlCd" name="dtlCd" placeholder="예: 1001" maxlength="30">
                    </div>
                    <div class="cm-form__field">
                        <label class="cm-form__label">상세코드명 <em>*</em></label>
                        <input type="text" class="cm-form__input" id="dtlCdNm" name="dtlCdNm" placeholder="예: 정상" maxlength="100">
                    </div>
                    <div class="cm-form__field">
                        <label class="cm-form__label">정렬순서</label>
                        <input type="number" class="cm-form__input" id="dtlSortNo" name="sortNo" placeholder="1" min="1">
                    </div>
                    <div class="cm-form__field">
                        <label class="cm-form__label">사용여부</label>
                        <select class="cm-form__select" id="dtlUseYn" name="useYn">
                            <option value="Y">사용</option>
                            <option value="N">미사용</option>
                        </select>
                    </div>
                    <div class="cm-form__field cm-form__field--full">
                        <label class="cm-form__label">비고</label>
                        <input type="text" class="cm-form__input" id="dtlRemark" name="remark" placeholder="선택사항" maxlength="1000">
                    </div>
                    <div class="cm-form__actions">
                        <button class="btn btn--ghost btn--sm" onclick="closeDtlForm()">취소</button>
                        <button class="btn btn--primary btn--sm" id="dtlSaveBtn" onclick="submitDtlForm()">저장</button>
                    </div>
                </div>
            </form>

            <div class="cm-table-wrap">
                <div id="dtlContent">
                    <div class="cm-empty">
                        <div class="cm-empty__icon">👈</div>
                        <div class="cm-empty__text">좌측에서 그룹코드를 선택하면<br>상세코드 목록이 표시됩니다.</div>
                    </div>
                </div>
            </div>
        </div>

    </div><%-- /cm-grid --%>
</div><%-- /cm-wrap --%>

<div id="toastContainer"></div>

<script>
    let currentGrpCd = null;
    let dtlEditMode  = false; // false = 등록, true = 수정

    /* ── formSetting 정의 (name 속성과 일치) ── */
    const grpFormSetting = {
        grpCdPrefix: { default: '' },
        grpCdNm:     { default: '' },
        useYn:       { default: 'Y' },
        remark:      { default: '' }
    };

    const dtlFormSetting = {
        dtlCd:   { default: '' },
        dtlCdNm: { default: '' },
        sortNo:  { default: '' },
        useYn:   { default: 'Y' },
        remark:  { default: '' }
    };

    /* ── 그룹코드 폼 토글 ── */
    function toggleGrpForm() {
        const form = document.getElementById('grpForm');
        const open = form.classList.toggle('is-open');
        if (!open) {
            FormUtils.clearValues(grpFormSetting);
            document.getElementById('grpCdPreview').textContent = '—';
        }
    }

    /* ── 상세코드 폼 열기 (등록 모드) ── */
    function toggleDtlForm() {
        const form   = document.getElementById('dtlForm');
        const isOpen = form.classList.contains('is-open');
        if (isOpen && !dtlEditMode) { closeDtlForm(); } else { openDtlFormAsCreate(); }
    }

    function openDtlFormAsCreate() {
        dtlEditMode = false;
        FormUtils.clearValues(dtlFormSetting);
        document.getElementById('dtlCd').readOnly = false;
        document.getElementById('dtlCdLabel').innerHTML = '상세코드 <em>*</em>';
        document.getElementById('dtlSaveBtn').textContent = '저장';
        document.getElementById('dtlForm').classList.add('is-open');
        clearDtlRowSelection();
    }

    function openDtlFormAsEdit(d) {
        dtlEditMode = true;
        FormUtils.setValues(dtlFormSetting, {
            dtlCd:   d.dtlCd,
            dtlCdNm: d.dtlCdNm || '',
            sortNo:  d.sortNo  != null ? d.sortNo : '',
            useYn:   d.useYn   || 'Y',
            remark:  d.remark  || ''
        });
        document.getElementById('dtlCd').readOnly = true;
        document.getElementById('dtlCdLabel').innerHTML = '상세코드';
        document.getElementById('dtlSaveBtn').textContent = '수정';
        document.getElementById('dtlForm').classList.add('is-open');
    }

    function closeDtlForm() {
        document.getElementById('dtlForm').classList.remove('is-open');
        FormUtils.clearValues(dtlFormSetting);
        dtlEditMode = false;
        clearDtlRowSelection();
    }

    function clearDtlRowSelection() {
        document.querySelectorAll('#dtlContent tr').forEach(tr => tr.classList.remove('is-selected'));
    }

    /* ── 접두어 입력 시 다음 코드 미리보기 ── */
    function previewNextCode() {
        const prefix  = document.getElementById('grpCdPrefix').value.trim();
        const preview = document.getElementById('grpCdPreview');
        if (!prefix) { preview.textContent = '—'; return; }

        AppAjax.request({
            type       : 'GET',
            url        : '/cm/code/grp/next',
            data       : { prefix: prefix },
            loadingOff : true,
            errorOff   : true,
            success    : function(res) { preview.textContent = res.data || '—'; },
            onError    : function()    { preview.textContent = '—'; }
        });
    }

    /* ── 그룹코드 저장 ── */
    function saveGrpCd() {
        var formData = $('#grpForm').serializeObject();
        if (!formData.grpCdPrefix || !formData.grpCdNm) {
            CmAtchUtils.showToast('접두어와 그룹코드명은 필수입니다.', 'error');
            return;
        }

        AppAjax.request({
            url         : '/cm/code/grp',
            contentType : 'application/json',
            data        : JSON.stringify(formData),
            success     : function() {
                CmAtchUtils.showToast('그룹코드가 등록되었습니다.', 'success');
                setTimeout(function() { location.reload(); }, 800);
            }
        });
    }

    /* ── 그룹코드 행 선택 ── */
    function selectGrpCd(grpCd, grpCdNm, row) {
        document.querySelectorAll('#grpTableBody tr').forEach(tr => tr.classList.remove('is-selected'));
        row.classList.add('is-selected');

        currentGrpCd = grpCd;

        const label = document.getElementById('selectedGrpLabel');
        label.textContent  = grpCd + ' · ' + grpCdNm;
        label.style.display = 'inline-block';

        document.getElementById('dtlAddBtn').disabled = false;
        loadDtlList(grpCd);
    }

    /* ── 상세코드 목록 로드 ── */
    function loadDtlList(grpCd) {
        AppAjax.request({
            type    : 'GET',
            url     : '/cm/code/dtl',
            data    : { grpCd: grpCd },
            success : function(res) { renderDtlTable(res.data || []); }
        });
    }

    /* ── 상세코드 테이블 렌더링 ── */
    function renderDtlTable(list) {
        const container = document.getElementById('dtlContent');
        if (!list.length) {
            container.innerHTML =
                '<div class="cm-empty">' +
                '<div class="cm-empty__icon">📭</div>' +
                '<div class="cm-empty__text">등록된 상세코드가 없습니다.</div>' +
                '</div>';
            return;
        }

        let rows = '';
        list.forEach(d => {
            const badge = d.useYn === 'Y'
                ? '<span class="badge badge--y">사용</span>'
                : '<span class="badge badge--n">미사용</span>';
            const dataAttrs =
                'data-dtl-cd="'    + CmAtchUtils.esc(d.dtlCd)              + '" ' +
                'data-dtl-cd-nm="' + CmAtchUtils.esc(d.dtlCdNm)            + '" ' +
                'data-sort-no="'   + (d.sortNo != null ? d.sortNo : '')     + '" ' +
                'data-use-yn="'    + CmAtchUtils.esc(d.useYn)               + '" ' +
                'data-remark="'    + CmAtchUtils.esc(d.remark || '')        + '"';
            rows +=
                '<tr class="is-clickable" ' + dataAttrs + ' onclick="selectDtlRow(this)">' +
                '<td><code>' + CmAtchUtils.esc(d.dtlCd)    + '</code></td>' +
                '<td>'       + CmAtchUtils.esc(d.dtlCdNm)  + '</td>' +
                '<td>'       + (d.sortNo != null ? d.sortNo : '-') + '</td>' +
                '<td>'       + badge + '</td>' +
                '<td>'       + (d.regDt || '') + '</td>' +
                '</tr>';
        });

        container.innerHTML =
            '<table class="cm-table">' +
            '<thead><tr>' +
            '<th>상세코드</th><th>상세코드명</th><th>정렬</th><th>사용여부</th><th>등록일</th>' +
            '</tr></thead>' +
            '<tbody>' + rows + '</tbody>' +
            '</table>';
    }

    /* ── 상세코드 행 선택 → 수정 폼 오픈 ── */
    function selectDtlRow(row) {
        document.querySelectorAll('#dtlContent tr').forEach(tr => tr.classList.remove('is-selected'));
        row.classList.add('is-selected');
        openDtlFormAsEdit({
            dtlCd  : row.dataset.dtlCd,
            dtlCdNm: row.dataset.dtlCdNm,
            sortNo : row.dataset.sortNo !== '' ? row.dataset.sortNo : null,
            useYn  : row.dataset.useYn,
            remark : row.dataset.remark
        });
    }

    /* ── 상세코드 저장 / 수정 ── */
    function submitDtlForm() {
        if (!currentGrpCd) {
            CmAtchUtils.showToast('그룹코드를 먼저 선택하세요.', 'error');
            return;
        }

        var formData = $('#dtlForm').serializeObject();
        if (!(formData.dtlCd || '').trim() || !(formData.dtlCdNm || '').trim()) {
            CmAtchUtils.showToast('상세코드와 상세코드명은 필수입니다.', 'error');
            return;
        }

        formData.grpCd = currentGrpCd;
        formData.sortNo = formData.sortNo ? parseInt(formData.sortNo) : null;

        var method     = dtlEditMode ? 'PUT'  : 'POST';
        var successMsg = dtlEditMode ? '상세코드가 수정되었습니다.' : '상세코드가 등록되었습니다.';

        AppAjax.request({
            url         : '/cm/code/dtl',
            type        : method,
            contentType : 'application/json',
            data        : JSON.stringify(formData),
            success     : function() {
                CmAtchUtils.showToast(successMsg, 'success');
                closeDtlForm();
                loadDtlList(currentGrpCd);
            }
        });
    }
</script>

</body>
</html>
