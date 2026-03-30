<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>파일 첨부 관리</title>
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

        .cm-wrap { max-width: 1200px; margin: 0 auto; padding: 36px 24px; }

        .cm-page-header { margin-bottom: 28px; }
        .cm-page-header__title { font-size: 22px; font-weight: 700; }
        .cm-page-header__desc { margin-top: 4px; font-size: 13px; color: var(--color-text-sub); }

        /* ─── Panel ─── */
        .cm-panel {
            background: var(--color-white);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            overflow: hidden;
            margin-bottom: 24px;
        }

        .cm-panel__head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 16px 20px;
            border-bottom: 1px solid var(--color-border);
        }

        .cm-panel__title { font-size: 15px; font-weight: 600; }

        /* ─── Drop Zone ─── */
        .drop-zone {
            margin: 20px;
            border: 2px dashed var(--color-border);
            border-radius: var(--radius);
            padding: 36px 20px;
            text-align: center;
            cursor: pointer;
            transition: border-color 0.2s, background 0.2s;
        }

        .drop-zone.is-over { border-color: var(--color-primary); background: #fff5f7; }
        .drop-zone__icon { font-size: 32px; margin-bottom: 8px; }
        .drop-zone__text { font-size: 13px; color: var(--color-text-sub); line-height: 1.8; }
        .drop-zone__text strong { color: var(--color-primary); text-decoration: underline; }
        #fileInput { display: none; }

        /* ─── Selected Files ─── */
        .selected-files { margin: 0 20px 16px; display: none; }
        .selected-files.has-files { display: block; }

        .selected-files__list { list-style: none; display: flex; flex-direction: column; gap: 6px; }

        .selected-files__item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: #f8fafc;
            border: 1px solid var(--color-border);
            border-radius: 6px;
            padding: 8px 12px;
            font-size: 13px;
        }

        .selected-files__name { flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .selected-files__size { color: var(--color-text-sub); font-size: 12px; margin-left: 12px; white-space: nowrap; }
        .selected-files__remove {
            background: none; border: none; cursor: pointer;
            color: var(--color-text-sub); font-size: 16px; margin-left: 8px; line-height: 1; padding: 0 2px;
        }
        .selected-files__remove:hover { color: var(--color-primary); }

        /* ─── Upload Actions ─── */
        .upload-actions { display: flex; justify-content: flex-end; padding: 0 20px 20px; gap: 8px; }

        /* ─── Progress ─── */
        .upload-progress { margin: 0 20px 16px; display: none; }
        .progress-bar-wrap { background: var(--color-border); border-radius: 99px; height: 6px; overflow: hidden; }
        .progress-bar-fill { height: 100%; background: var(--color-primary); border-radius: 99px; transition: width 0.2s; width: 0%; }
        .progress-text { font-size: 12px; color: var(--color-text-sub); margin-top: 6px; text-align: right; }

        /* ─── Buttons ─── */
        .btn {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 7px 14px; border-radius: 6px; font-size: 13px; font-weight: 500;
            cursor: pointer; border: none; font-family: inherit; transition: background 0.15s;
        }
        .btn--primary { background: var(--color-primary); color: #fff; }
        .btn--primary:hover { background: var(--color-primary-hover); }
        .btn--danger { background: #fff0f4; color: var(--color-primary); border: 1px solid #ffd0db; }
        .btn--danger:hover { background: #ffe0e9; }
        .btn--ghost { background: transparent; border: 1px solid var(--color-border); color: var(--color-text); }
        .btn--ghost:hover { background: var(--color-bg); }
        .btn--sm { padding: 5px 10px; font-size: 12px; }
        .btn:disabled { opacity: 0.45; cursor: not-allowed; pointer-events: none; }

        /* ─── Table ─── */
        .cm-table-wrap { overflow-x: auto; }
        .cm-table { width: 100%; border-collapse: collapse; }

        .cm-table thead th {
            position: sticky; top: 0; z-index: 1;
            background: #f8fafc; padding: 10px 14px;
            text-align: left; font-size: 12px; font-weight: 600;
            color: var(--color-text-sub); border-bottom: 1px solid var(--color-border); white-space: nowrap;
        }

        .cm-table tbody td {
            padding: 11px 14px; border-bottom: 1px solid var(--color-border);
            font-size: 13px; vertical-align: middle;
        }

        .cm-table tbody tr:last-child td { border-bottom: none; }
        .cm-table tbody tr:hover td { background: var(--color-row-hover); }

        /* 그룹 헤더 행 */
        .group-row td {
            background: #f8fafc !important;
            font-weight: 600;
            font-size: 12px;
            padding: 8px 14px;
            border-top: 2px solid var(--color-border);
        }

        .group-row:first-child td { border-top: none; }

        .fileid-tag {
            font-family: 'SFMono-Regular', Consolas, monospace;
            font-size: 11px;
            color: var(--color-primary);
            background: #fff0f4;
            padding: 2px 8px;
            border-radius: 4px;
            word-break: break-all;
            display: inline-block;
            max-width: 600px;
        }

        .file-type-badge {
            display: inline-block; padding: 2px 8px; border-radius: 4px;
            font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;
        }

        .file-name-link {
            color: var(--color-text); text-decoration: none;
            max-width: 280px; display: inline-block;
            overflow: hidden; text-overflow: ellipsis; white-space: nowrap; vertical-align: middle;
        }
        .file-name-link:hover { color: var(--color-primary); text-decoration: underline; }

        /* ─── Empty State ─── */
        .cm-empty { padding: 52px 20px; text-align: center; color: var(--color-text-sub); }
        .cm-empty__icon { font-size: 36px; margin-bottom: 10px; }
        .cm-empty__text { font-size: 13px; line-height: 1.7; }

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

<div class="cm-wrap">

    <div class="cm-page-header">
        <h1 class="cm-page-header__title">파일 첨부 관리</h1>
    </div>

    <%-- ════════════ 업로드 패널 ════════════ --%>
    <div class="cm-panel">
        <div class="cm-panel__head">
            <span class="cm-panel__title">파일 업로드</span>
        </div>

        <div class="drop-zone" id="dropZone" onclick="document.getElementById('fileInput').click()">
            <div class="drop-zone__icon">📁</div>
            <div class="drop-zone__text">
                파일을 여기로 드래그하거나 <strong>클릭하여 선택</strong>하세요<br>
                <small>최대 50MB · 여러 파일 동시 선택 가능 · 업로드 시 서버에서 그룹 ID(UUID) 자동 생성</small>
            </div>
        </div>
        <input type="file" id="fileInput" multiple onchange="onFileSelected(this.files)">

        <div class="selected-files" id="selectedFiles">
            <ul class="selected-files__list" id="selectedFileList"></ul>
        </div>

        <div class="upload-progress" id="uploadProgress">
            <div class="progress-bar-wrap">
                <div class="progress-bar-fill" id="progressFill"></div>
            </div>
            <div class="progress-text" id="progressText"></div>
        </div>

        <div class="upload-actions">
            <button class="btn btn--ghost btn--sm" id="clearBtn" onclick="clearSelected()" disabled>선택 초기화</button>
            <button class="btn btn--primary btn--sm" id="uploadBtn" onclick="uploadAll()" disabled>업로드</button>
        </div>
    </div>

    <%-- ════════════ 전체 첨부 목록 패널 ════════════ --%>
    <div class="cm-panel">
        <div class="cm-panel__head">
            <span class="cm-panel__title">전체 첨부 파일 목록</span>
            <span id="fileCountBadge" style="font-size:12px; color:var(--color-text-sub);"></span>
        </div>

        <div class="cm-table-wrap">
            <div id="fileListArea">
                <div class="cm-empty">
                    <div class="cm-empty__icon">⏳</div>
                    <div class="cm-empty__text">목록을 불러오는 중...</div>
                </div>
            </div>
        </div>
    </div>

</div>

<div id="toastContainer"></div>

<script>
    let pendingFiles = [];

    /* ── 드래그 앤 드롭 ── */
    const dropZone = document.getElementById('dropZone');

    dropZone.addEventListener('dragover', e => { e.preventDefault(); dropZone.classList.add('is-over'); });
    dropZone.addEventListener('dragleave', () => dropZone.classList.remove('is-over'));
    dropZone.addEventListener('drop', e => {
        e.preventDefault();
        dropZone.classList.remove('is-over');
        onFileSelected(e.dataTransfer.files);
    });

    /* ── 파일 선택 ── */
    function onFileSelected(files) {
        if (!files || !files.length) return;
        Array.from(files).forEach(f => pendingFiles.push(f));
        renderPendingFiles();
        document.getElementById('fileInput').value = '';
    }

    function renderPendingFiles() {
        const list      = document.getElementById('selectedFileList');
        const wrap      = document.getElementById('selectedFiles');
        const uploadBtn = document.getElementById('uploadBtn');
        const clearBtn  = document.getElementById('clearBtn');

        list.innerHTML = '';
        pendingFiles.forEach((f, i) => {
            const li = document.createElement('li');
            li.className = 'selected-files__item';
            li.innerHTML =
                '<span class="selected-files__name">' + CmAtchUtils.esc(f.name) + '</span>' +
                '<span class="selected-files__size">' + CmAtchUtils.formatSize(f.size) + '</span>' +
                '<button class="selected-files__remove" onclick="removeFile(' + i + ')" title="제거">✕</button>';
            list.appendChild(li);
        });

        const has = pendingFiles.length > 0;
        wrap.classList.toggle('has-files', has);
        uploadBtn.disabled = !has;
        clearBtn.disabled  = !has;
    }

    function removeFile(idx) { pendingFiles.splice(idx, 1); renderPendingFiles(); }
    function clearSelected()  { pendingFiles = []; renderPendingFiles(); }

    /* ── 업로드 ── */
    function uploadAll() {
        if (!pendingFiles.length) return;

        const progressWrap = document.getElementById('uploadProgress');
        const fill         = document.getElementById('progressFill');
        const progressText = document.getElementById('progressText');

        progressWrap.style.display = 'block';
        document.getElementById('uploadBtn').disabled = true;


        CmAtchUtils.upload(pendingFiles, {
            onProgress(pct) {
                fill.style.width = pct + '%';
                progressText.textContent = pct + '%';
            },
            onSuccess() {
                pendingFiles = [];
                renderPendingFiles();
                setTimeout(() => { progressWrap.style.display = 'none'; fill.style.width = '0%'; }, 600);
                CmAtchUtils.showToast('업로드가 완료되었습니다.', 'success');
                refreshList();
            },
            onError(msg) {
                setTimeout(() => { progressWrap.style.display = 'none'; fill.style.width = '0%'; }, 600);
                document.getElementById('uploadBtn').disabled = false;
                CmAtchUtils.showToast(msg, 'error');
            }
        });
    }

    /* ── formSetting: 파일 목록 테이블 컬럼 구조 정의 ── */
    const formSetting = {
        containerId:  'fileListArea',
        countBadgeId: 'fileCountBadge',
        groupBy:      'fileId',
        emptyText:    '업로드된 파일이 없습니다.',
        columns: [
            { header: '순번',   field: 'atchSeq',      width: '70px',  indent: true },
            { header: '파일명', type:  'download',      urlField: 'fileUrl', nameField: 'orignlFileNm' },
            { header: '유형',   field: 'fileType',      width: '70px',  type: 'badge' },
            { header: '크기',   field: 'fileSz',        width: '80px'  },
            { header: '등록일', field: 'regDt',         width: '100px' },
            {
                header: '',
                width:  '70px',
                type:   'actions',
                actions: [
                    { label: '삭제', style: 'ghost', onclick: row => 'deleteFile(' + row.atchSeq + ')' }
                ]
            }
        ]
    };

    /* ── 전체 파일 목록 갱신 ── */
    function refreshList() {
        AppAjax.request({
            type       : 'GET',
            url        : '/cm/atch/list/all',
            loadingOff : true,
            success    : function(res) { CmAtchUtils.renderTable(res.data || [], formSetting); }
        });
    }

    /* ── 단건 삭제 ── */
    function deleteFile(atchSeq) {
        if (!confirm('파일을 삭제하시겠습니까?')) return;
        AppAjax.request({
            type    : 'DELETE',
            url     : '/cm/atch/' + atchSeq,
            success : function() {
                CmAtchUtils.showToast('파일이 삭제되었습니다.', 'success');
                refreshList();
            }
        });
    }

    /* ── 그룹 전체 삭제 ── */
    function deleteGroup(encodedSortedFileId) {
        if (!confirm('이 그룹의 모든 파일을 삭제하시겠습니까?')) return;
        AppAjax.request({
            type    : 'DELETE',
            url     : '/cm/atch/group/' + encodedSortedFileId,
            success : function() {
                CmAtchUtils.showToast('그룹 파일이 모두 삭제되었습니다.', 'success');
                refreshList();
            }
        });
    }

    /* ── 페이지 로드 시 전체 목록 조회 ── */
    refreshList();
</script>

</body>
</html>
