/**
 * FormUtils — name 속성 기반 공통 폼 유틸리티
 *
 * ────────────────────────────────────────────
 * formSetting 구조
 * ────────────────────────────────────────────
 * const formSetting = {
 *   fieldName: { default: '기본값' },   // 생략 시 default: ''
 *   ...
 * };
 *
 * ────────────────────────────────────────────
 * 지원 태그 / type
 * ────────────────────────────────────────────
 * input[type=text|number|hidden|date|email…]  → value
 * input[type=checkbox] (단일)                 → boolean (checked)
 * input[type=checkbox] (복수, 같은 name)       → 선택된 value 배열
 * input[type=radio]    (복수, 같은 name)       → 선택된 value 문자열
 * select               (단일 선택)             → value
 * select[multiple]                            → 선택된 value 배열
 * textarea                                    → value
 *
 * ────────────────────────────────────────────
 * API
 * ────────────────────────────────────────────
 * FormUtils.getValues(formSetting)            → { fieldName: value, … }
 * FormUtils.setValues(formSetting, data)      → form 에 data 값 반영
 * FormUtils.clearValues(formSetting)          → default 값으로 초기화
 */
const FormUtils = (() => {

    /* ── 내부: name 으로 요소 목록 반환 ── */
    function _els(name) {
        return Array.from(document.querySelectorAll('[name="' + name + '"]'));
    }

    /* ── 내부: 단일 필드 값 취득 ── */
    function _get(name) {
        const els = _els(name);
        if (!els.length) return undefined;

        const first = els[0];
        const type  = (first.type || '').toLowerCase();

        // radio: 선택된 value 반환
        if (type === 'radio') {
            const checked = els.find(e => e.checked);
            return checked ? checked.value : '';
        }

        // checkbox 복수: 선택된 value 배열 반환
        if (type === 'checkbox' && els.length > 1) {
            return els.filter(e => e.checked).map(e => e.value);
        }

        // checkbox 단일: boolean 반환
        if (type === 'checkbox') {
            return first.checked;
        }

        // select[multiple]: 선택된 value 배열 반환
        if (first.tagName === 'SELECT' && first.multiple) {
            return Array.from(first.selectedOptions).map(o => o.value);
        }

        // input / select / textarea: value 반환
        return first.value;
    }

    /* ── 내부: 단일 필드 값 세팅 ── */
    function _set(name, value) {
        const els = _els(name);
        if (!els.length) return;

        const first = els[0];
        const type  = (first.type || '').toLowerCase();

        if (type === 'radio') {
            const target = String(value ?? '');
            els.forEach(e => { e.checked = e.value === target; });
            return;
        }

        if (type === 'checkbox' && els.length > 1) {
            const targets = (Array.isArray(value) ? value : [value]).map(String);
            els.forEach(e => { e.checked = targets.includes(e.value); });
            return;
        }

        if (type === 'checkbox') {
            first.checked = !!value;
            return;
        }

        if (first.tagName === 'SELECT' && first.multiple) {
            const targets = (Array.isArray(value) ? value : [value]).map(String);
            Array.from(first.options).forEach(o => { o.selected = targets.includes(o.value); });
            return;
        }

        first.value = value != null ? value : '';
    }

    /* ── 내부: 단일 필드 초기화 ── */
    function _clear(name, defaultValue) {
        const els = _els(name);
        if (!els.length) return;

        const first = els[0];
        const type  = (first.type || '').toLowerCase();

        if (type === 'checkbox' || type === 'radio') {
            if (defaultValue !== undefined && defaultValue !== '') {
                _set(name, defaultValue);
            } else {
                els.forEach(e => { e.checked = false; });
            }
            return;
        }

        first.value = defaultValue !== undefined ? defaultValue : '';
    }

    /* ────────────────────────────────────────
     * 공개 API
     * ──────────────────────────────────────── */

    /**
     * formSetting 에 정의된 필드의 현재 값을 객체로 반환
     *
     * @param  {object} setting
     * @returns {object} { fieldName: value, … }
     */
    function getValues(setting) {
        return Object.keys(setting).reduce((acc, name) => {
            acc[name] = _get(name);
            return acc;
        }, {});
    }

    /**
     * formSetting 에 정의된 필드에 data 값을 세팅
     * data 에 없는 필드는 건드리지 않는다.
     *
     * @param {object} setting
     * @param {object} data    { fieldName: value, … }
     */
    function setValues(setting, data) {
        if (!data) return;
        Object.keys(setting).forEach(name => {
            if (data[name] !== undefined) _set(name, data[name]);
        });
    }

    /**
     * formSetting 에 정의된 필드를 default 값으로 초기화
     * default 가 없으면 '' / false / [] 로 초기화
     *
     * @param {object} setting
     */
    function clearValues(setting) {
        Object.keys(setting).forEach(name => {
            const def = setting[name] != null ? setting[name].default : undefined;
            _clear(name, def);
        });
    }

    return { getValues, setValues, clearValues };
})();

/* ════════════════════════════════════════════════════════════════
 * AppAjax — jQuery $.ajax 공통 래퍼
 *
 * 사용 예)
 *   // 1) form serializeObject 로 조회
 *   AppAjax.request({
 *     url  : '/cm/code/list',
 *     data : $('#searchForm').serializeObject(),
 *     success: function(res) { console.log(res.data); }
 *   });
 *
 *   // 2) 객체 직접 전달로 저장
 *   AppAjax.request({
 *     url  : '/cm/code/save',
 *     data : FormUtils.getValues(formSetting),
 *     success: function(res) { alert('저장되었습니다.'); }
 *   });
 *
 *   // 3) 에러 핸들러 직접 지정
 *   AppAjax.request({
 *     url      : '/cm/code/delete',
 *     data     : { grpCd: 'CD001' },
 *     errorOff : true,          // 공통 에러 alert 숨김
 *     onError  : function(info) { console.error(info); },
 *     success  : function() { location.reload(); }
 *   });
 *
 * 옵션 (obj):
 *   url        {string}   요청 URL (필수)
 *   data       {object|string}  전송 데이터
 *   type       {string}   HTTP 메서드 (기본 'POST')
 *   async      {boolean}  비동기 여부 (기본 true)
 *   loadingOff {boolean}  로딩 인디케이터 숨김 (기본 false)
 *   errorOff   {boolean}  공통 에러 alert 숨김 (기본 false)
 *   onError    {function} 에러 콜백 (errorInfo, response)
 *   success    {function} 성공 콜백 (responseData)
 *   그 외 $.ajax 옵션은 그대로 전달됨
 * ════════════════════════════════════════════════════════════════ */
const AppAjax = (() => {

    /* ── 로딩 인디케이터 (요소가 없으면 무시) ── */
    function _loadingOn() {
        const el = document.getElementById('loadingOverlay');
        if (el) el.style.display = 'flex';
    }
    function _loadingOff() {
        const el = document.getElementById('loadingOverlay');
        if (el) el.style.display = 'none';
    }

    /* ── 에러 alert (브라우저 기본 alert 사용, 필요 시 교체) ── */
    function _alert(msg) {
        alert(msg);
    }

    /**
     * 공통 Ajax 요청
     * @param {object} obj
     */
    function request(obj) {
        const param = $.extend({
            type    : 'POST',
            cache   : false,
            async   : obj.async !== false,
            beforeSend: function () {
                if (!obj.loadingOff) _loadingOn();
            },
            error: function (response) {
                if (response.status === 401) {
                    _alert('로그인 정보가 존재하지 않습니다.');
                } else if (response.status === 404) {
                    _alert('호출 정보를 찾을 수 없습니다. (404)');
                } else {
                    var errorInfo = null;
                    try {
                        errorInfo = response.responseJSON
                            || (response.responseText ? JSON.parse(response.responseText) : null);
                    } catch (_) {}

                    if (!obj.errorOff) {
                        _alert(errorInfo && errorInfo.message
                            ? errorInfo.message
                            : '처리 중 오류가 발생하였습니다.');
                    }
                    if (typeof obj.onError === 'function') {
                        obj.onError(errorInfo, response);
                    }
                }
            },
            complete: function () {
                _loadingOff();
            }
        }, obj);

        $.ajax(param);
    }

    return { request };
})();

/* ════════════════════════════════════════════════════════════════
 * jQuery 플러그인 — serializeObject
 *
 * <form> 요소에 사용하여 name/value 쌍을 객체로 반환합니다.
 * 같은 name 이 여러 개이면 배열로 수집합니다.
 *
 * 사용 예)
 *   var params = $('#searchForm').serializeObject();
 *   // { grpCd: 'CD001', useYn: 'Y' }
 * ════════════════════════════════════════════════════════════════ */
$.fn.serializeObject = function () {
    var obj = {};
    try {
        var tag = this[0] && this[0].tagName;
        if (!tag || tag.toUpperCase() !== 'FORM') return obj;

        this.serializeArray().forEach(function (item) {
            if (Object.prototype.hasOwnProperty.call(obj, item.name)) {
                // 이미 존재하면 배열로 변환 후 추가
                if (!Array.isArray(obj[item.name])) {
                    obj[item.name] = [obj[item.name]];
                }
                obj[item.name].push(item.value);
            } else {
                obj[item.name] = item.value;
            }
        });
    } catch (e) {
        console.error('[serializeObject]', e.message);
    }
    return obj;
};
