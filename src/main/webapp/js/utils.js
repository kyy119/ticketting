/**
 * CmAtch 첨부파일 공통 유틸리티
 *
 * 사용하는 페이지에 #toastContainer 요소가 있어야 showToast가 동작합니다.
 */
const CmAtchUtils = (() => {

    /* ── XSS 방지 ── */
    function esc(str) {
        if (str == null) return '';
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g,  '&lt;')
            .replace(/>/g,  '&gt;')
            .replace(/"/g,  '&quot;');
    }

    /* ── 파일 크기 포맷 ── */
    function formatSize(bytes) {
        if (bytes < 1024)             return bytes + ' B';
        if (bytes < 1024 * 1024)      return (bytes / 1024).toFixed(1) + ' KB';
        return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
    }

    /* ── 파일 유형 색상 ── */
    function typeToColor(ext) {
        const map = {
            pdf:  { bg: '#fde8e8', fg: '#c53030' },
            jpg:  { bg: '#fef3c7', fg: '#92400e' },
            jpeg: { bg: '#fef3c7', fg: '#92400e' },
            png:  { bg: '#fef3c7', fg: '#92400e' },
            gif:  { bg: '#fef3c7', fg: '#92400e' },
            xlsx: { bg: '#e6f6ef', fg: '#276749' },
            xls:  { bg: '#e6f6ef', fg: '#276749' },
            docx: { bg: '#ebf4ff', fg: '#2b6cb0' },
            doc:  { bg: '#ebf4ff', fg: '#2b6cb0' },
            zip:  { bg: '#f0f2f8', fg: '#4a5568' },
        };
        return map[(ext || '').toLowerCase()] || { bg: '#f0f2f8', fg: '#4a5568' };
    }

    /* ── Toast 알림 ── */
    function showToast(msg, type) {
        const container = document.getElementById('toastContainer');
        if (!container) return;
        const el = document.createElement('div');
        el.className = 'toast toast--' + (type === 'error' ? 'error' : 'success');
        el.textContent = msg;
        container.appendChild(el);
        setTimeout(() => el.remove(), 3000);
    }

    /**
     * 파일 업로드 (XHR 기반, 진행률 콜백 지원)
     *
     * @param {File[]} files       업로드할 File 배열
     * @param {object} callbacks
     *   @param {function(number)} [callbacks.onProgress] - 진행률 0~100
     *   @param {function(object)} [callbacks.onSuccess]  - res.data 전달
     *   @param {function(string)} [callbacks.onError]    - 오류 메시지 전달
     */
    function upload(files, { onProgress, onSuccess, onError } = {}) {
        const fd = new FormData();
        files.forEach(f => fd.append('files', f));

        const xhr = new XMLHttpRequest();

        if (onProgress) {
            xhr.upload.addEventListener('progress', e => {
                if (e.lengthComputable) onProgress(Math.round((e.loaded / e.total) * 100));
            });
        }

        xhr.addEventListener('load', () => {
            try {
                const res = JSON.parse(xhr.responseText);
                if (res.status === 200) {
                    onSuccess && onSuccess(res.data);
                } else {
                    onError && onError(res.message || '업로드 중 오류가 발생했습니다.');
                }
            } catch (_) {
                onError && onError('서버 응답 처리 중 오류가 발생했습니다.');
            }
        });

        xhr.addEventListener('error', () => onError && onError('서버 오류가 발생했습니다.'));
        xhr.open('POST', '/cm/atch/upload');
        xhr.send(fd);
    }

    /**
     * 전체 첨부파일 목록 조회
     *
     * @param {object} callbacks
     *   @param {function(Array)} [callbacks.onSuccess] - CmAtch 배열 전달
     *   @param {function(string)} [callbacks.onError]
     */
    function loadAllFiles({ onSuccess, onError } = {}) {
        fetch('/cm/atch/list/all')
            .then(r => r.json())
            .then(res => onSuccess && onSuccess(res.data || []))
            .catch(() => onError && onError('목록 조회 중 오류가 발생했습니다.'));
    }

    /**
     * 단건 소프트 삭제 (atch_seq 기준)
     *
     * @param {number} atchSeq
     * @param {object} callbacks
     *   @param {function()}       [callbacks.onSuccess]
     *   @param {function(string)} [callbacks.onError]
     */
    function deleteFile(atchSeq, { onSuccess, onError } = {}) {
        fetch('/cm/atch/' + atchSeq, { method: 'DELETE' })
            .then(r => r.json())
            .then(res => {
                if (res.status === 200) {
                    onSuccess && onSuccess();
                } else {
                    onError && onError(res.message || '삭제 중 오류가 발생했습니다.');
                }
            })
            .catch(() => onError && onError('서버 오류가 발생했습니다.'));
    }

    /**
     * 그룹 전체 소프트 삭제 (소팅된 file_id 기준)
     *
     * @param {string} sortedFileId - AOP로 인코딩된 file_id
     * @param {object} callbacks
     *   @param {function()}       [callbacks.onSuccess]
     *   @param {function(string)} [callbacks.onError]
     */
    function deleteGroup(sortedFileId, { onSuccess, onError } = {}) {
        fetch('/cm/atch/group/' + encodeURIComponent(sortedFileId), { method: 'DELETE' })
            .then(r => r.json())
            .then(res => {
                if (res.status === 200) {
                    onSuccess && onSuccess();
                } else {
                    onError && onError(res.message || '삭제 중 오류가 발생했습니다.');
                }
            })
            .catch(() => onError && onError('서버 오류가 발생했습니다.'));
    }

    /**
     * 파일 다운로드 (숨겨진 <a> 클릭 방식)
     *
     * @param {string} url       다운로드 URL (/cm/atch/download/...)
     * @param {string} [fileName] 저장 파일명 (생략 시 서버 헤더 따름)
     */
    function downloadFile(url, fileName) {
        const a = document.createElement('a');
        a.href = url;
        if (fileName) a.download = fileName;
        a.style.display = 'none';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
    }

    /**
     * formSetting 기반 공통 테이블 렌더링
     *
     * @param {Array}  list     서버에서 받은 데이터 배열
     * @param {object} setting  테이블 렌더링 설정
     *
     * setting 구조:
     * {
     *   containerId:  'fileListArea',         // 렌더링 대상 요소 id (필수)
     *   countBadgeId: 'fileCountBadge',        // 건수 표시 요소 id (선택)
     *   groupBy:      'fileId',                // 그룹핑 기준 필드명 (선택)
     *   emptyText:    '데이터가 없습니다.',      // 빈 목록 안내 문구 (선택)
     *   columns: [                             // 컬럼 정의 배열 (필수)
     *     {
     *       header:    '컬럼명',               // 헤더 텍스트
     *       width:     '80px',                 // 헤더 고정 너비 (선택)
     *       indent:    true,                   // 셀 좌측 들여쓰기 (선택)
     *       type:      'text',                 // 셀 타입 (아래 참고, 기본 'text')
     *
     *       // type: 'text'  (기본)
     *       field:     'fieldName',            // row 에서 읽을 필드명
     *
     *       // type: 'download'
     *       urlField:  'fileUrl',              // 다운로드 URL 필드명
     *       nameField: 'orignlFileNm',         // 표시·저장 파일명 필드명
     *
     *       // type: 'badge'
     *       field:     'fileType',             // typeToColor() 에 넘길 값 필드명
     *
     *       // type: 'actions'
     *       actions: [
     *         {
     *           label:   '삭제',               // 버튼 텍스트
     *           style:   'ghost',              // btn--{style} CSS 클래스 접미사
     *           onclick: row => '...'          // 버튼 onclick 문자열 반환 함수
     *         }
     *       ]
     *     }
     *   ]
     * }
     */
    function renderTable(list, setting) {
        const area = document.getElementById(setting.containerId);
        if (!area) return;

        if (setting.countBadgeId) {
            const badge = document.getElementById(setting.countBadgeId);
            if (badge) badge.textContent = list.length + '개';
        }

        if (!list.length) {
            area.innerHTML =
                '<div class="cm-empty">' +
                '<div class="cm-empty__icon">📂</div>' +
                '<div class="cm-empty__text">' + esc(setting.emptyText || '데이터가 없습니다.') + '</div>' +
                '</div>';
            return;
        }

        // 그룹핑 처리
        const groups   = [];
        const groupMap = {};
        if (setting.groupBy) {
            list.forEach(item => {
                const key = item[setting.groupBy];
                if (!groupMap[key]) { groupMap[key] = []; groups.push(key); }
                groupMap[key].push(item);
            });
        } else {
            groups.push('__all__');
            groupMap['__all__'] = list;
        }

        // 헤더 생성
        const headers = setting.columns.map(col =>
            '<th style="' + (col.width ? 'width:' + col.width + ';' : '') + '">' +
            esc(col.header || '') + '</th>'
        ).join('');

        // 데이터 행 생성
        let rows = '';
        groups.forEach(key => {
            groupMap[key].forEach(row => {
                const cells = setting.columns.map(col => _buildCell(row, col)).join('');
                rows += '<tr>' + cells + '</tr>';
            });
        });

        area.innerHTML =
            '<table class="cm-table">' +
            '<thead><tr>' + headers + '</tr></thead>' +
            '<tbody>' + rows + '</tbody>' +
            '</table>';
    }

    /**
     * 컬럼 설정에 따라 <td> 하나를 생성
     *
     * download 타입은 data-* 속성 방식으로 onclick 내 XSS 를 방지한다.
     * actions 타입의 onclick 은 개발자가 정의한 함수 반환값을 그대로 사용한다.
     */
    function _buildCell(row, col) {
        const tdStyle = col.indent ? ' style="padding-left:28px;"' : '';
        let content   = '';

        switch (col.type) {
            case 'download':
                content =
                    '<a class="file-name-link" href="javascript:void(0)"' +
                    ' data-url="'  + esc(row[col.urlField])  + '"' +
                    ' data-name="' + esc(row[col.nameField]) + '"' +
                    ' onclick="CmAtchUtils.downloadFile(this.dataset.url, this.dataset.name)"' +
                    ' title="' + esc(row[col.nameField]) + '">' +
                    esc(row[col.nameField]) +
                    '</a>';
                break;

            case 'badge': {
                const tc = typeToColor(row[col.field]);
                content =
                    '<span class="file-type-badge"' +
                    ' style="background:' + tc.bg + ';color:' + tc.fg + '">' +
                    esc(row[col.field]) + '</span>';
                break;
            }

            case 'actions':
                content = (col.actions || []).map(action =>
                    '<button class="btn btn--' + (action.style || 'ghost') + ' btn--sm"' +
                    ' onclick="' + action.onclick(row) + '">' +
                    esc(action.label) + '</button>'
                ).join('');
                break;

            default:
                content = esc(row[col.field] != null ? String(row[col.field]) : '');
        }

        return '<td' + tdStyle + '>' + content + '</td>';
    }

    return {
        esc, formatSize, typeToColor, showToast,
        upload, loadAllFiles, deleteFile, deleteGroup, downloadFile,
        renderTable,
    };
})();
