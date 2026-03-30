package com.example.ticketing.cm.sort;

import java.lang.annotation.*;

/**
 * 반환값에 포함된 CmAtch.fileId를 RSA 소팅(obfuscation) 처리.
 * List<CmAtch> 또는 Map(fileId + files) 반환 메서드에 적용.
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface FileIdEncrypt {
}
