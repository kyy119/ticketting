package com.example.ticketing.cm.sort;

import com.example.ticketing.entity.CmAtch;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import lombok.RequiredArgsConstructor;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.stereotype.Component;

import java.lang.reflect.Method;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;

/**
 * file_id RSA 소팅 AOP.
 *
 * @FileIdDecrypt : 진입 시 String 파라미터(file_id) → unsort → 실제 값으로 치환 후 메서드 실행
 * @FileIdEncrypt : 메서드 실행 후 반환값의 CmAtch.fileId / fileUrl → sort(obfuscation) 처리
 *
 * OSIV(Open Session In View) 환경에서 엔티티가 managed 상태이면 JPA dirty-check 가
 * 소팅된 값(700자)을 varchar(50) 컬럼에 쓰려다 오류가 발생한다.
 * → sortAtch() 호출 전 EntityManager.detach() 로 영속성 컨텍스트에서 분리 후 수정.
 */
@Aspect
@Component
@RequiredArgsConstructor
public class FileIdSortAspect {

    private final FileIdSortManager manager;

    @PersistenceContext
    private EntityManager entityManager;

    @Around("@annotation(com.example.ticketing.cm.sort.FileIdEncrypt)" +
            " || @annotation(com.example.ticketing.cm.sort.FileIdDecrypt)")
    public Object handle(ProceedingJoinPoint pjp) throws Throwable {

        Method method = ((MethodSignature) pjp.getSignature()).getMethod();
        boolean hasDecrypt = method.isAnnotationPresent(FileIdDecrypt.class);
        boolean hasEncrypt = method.isAnnotationPresent(FileIdEncrypt.class);

        // ① Decrypt: String 파라미터를 unsort 처리
        Object[] args = pjp.getArgs();
        if (hasDecrypt) {
            for (int i = 0; i < args.length; i++) {
                if (args[i] instanceof String) {
                    args[i] = manager.unsort((String) args[i]);
                }
            }
        }

        Object result = pjp.proceed(args);

        // ② Encrypt: 반환값의 fileId를 sort 처리
        if (hasEncrypt) {
            applySort(result);
        }

        return result;
    }

    @SuppressWarnings("unchecked")
    private void applySort(Object result) {
        if (result instanceof List<?> list) {
            list.forEach(item -> {
                if (item instanceof CmAtch atch) sortAtch(atch);
            });
        } else if (result instanceof Map<?, ?> map) {
            // uploadBatch 응답: { fileId: "...", files: [...] }
            if (map.get("fileId") instanceof String fileId) {
                ((Map<String, Object>) map).put("fileId", manager.sort(fileId));
            }
            if (map.get("files") instanceof List<?> files) {
                files.forEach(item -> {
                    if (item instanceof CmAtch atch) sortAtch(atch);
                });
            }
        }
    }

    /**
     * CmAtch 하나에 대해 fileId 소팅 + fileUrl 변환.
     * fileUrl: /cm/atch/files/{realFileId}/{savedFileName}
     *       → /cm/atch/download/{sortedFileId}/{savedFileName}
     *
     * 수정 전 detach() 하여 JPA dirty-check 로 varchar(50) 초과값이 DB에 쓰이는 것을 방지.
     */
    private void sortAtch(CmAtch atch) {
        // managed 상태이면 detach → 이후 필드 변경이 DB에 반영되지 않음
        if (entityManager.contains(atch)) {
            entityManager.detach(atch);
        }

        String realFileId   = atch.getFileId();
        String sortedFileId = manager.sort(realFileId);
        atch.setFileId(sortedFileId);

        String fileUrl = atch.getFileUrl();
        if (fileUrl != null) {
            String savedFileName = Paths.get(fileUrl).getFileName().toString();
            atch.setFileUrl("/cm/atch/download/" + sortedFileId + "/" + savedFileName);
        }
    }
}
