package com.example.ticketing.cm.sort;

import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.Signature;
import java.util.Base64;

/**
 * RSA SHA256 서명을 이용한 file_id 앞뒤 소팅(obfuscation) 매니저.
 * - 서버 기동 시 RSA 2048 키 쌍을 1회 생성
 * - "aaa" 서명값(prefix) + 실제 file_id + "bbb" 서명값(suffix) 형태로 노출
 * - prefix/suffix 길이(342자)는 고정이므로 잘라내서 원본 복원 가능
 */
@Component
public class FileIdSortManager {

    private String prefix;
    private String suffix;
    private int prefixLen;
    private int suffixLen;

    @PostConstruct
    public void init() throws Exception {
        KeyPairGenerator kpg = KeyPairGenerator.getInstance("RSA");
        kpg.initialize(2048);
        KeyPair keyPair = kpg.generateKeyPair();

        Signature sig = Signature.getInstance("SHA256withRSA");
        sig.initSign(keyPair.getPrivate());

        sig.update("aaa".getBytes(StandardCharsets.UTF_8));
        prefix = Base64.getUrlEncoder().withoutPadding().encodeToString(sig.sign());

        sig.update("bbb".getBytes(StandardCharsets.UTF_8));
        suffix = Base64.getUrlEncoder().withoutPadding().encodeToString(sig.sign());

        prefixLen = prefix.length();
        suffixLen = suffix.length();
    }

    /** 실제 file_id → prefix + file_id + suffix */
    public String sort(String fileId) {
        if (fileId == null) return null;
        return prefix + fileId + suffix;
    }

    /** prefix + file_id + suffix → 실제 file_id */
    public String unsort(String sorted) {
        if (sorted == null) {
            throw new IllegalArgumentException("file_id가 null입니다.");
        }
        int minLen = prefixLen + suffixLen;
        if (sorted.length() <= minLen) {
            throw new IllegalArgumentException("유효하지 않은 file_id 형식입니다.");
        }
        if (!sorted.startsWith(prefix) || !sorted.endsWith(suffix)) {
            throw new IllegalArgumentException("file_id 서명 검증에 실패했습니다.");
        }
        return sorted.substring(prefixLen, sorted.length() - suffixLen);
    }
}
