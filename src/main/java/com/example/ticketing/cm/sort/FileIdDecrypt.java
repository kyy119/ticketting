package com.example.ticketing.cm.sort;

import java.lang.annotation.*;

/**
 * String 타입 파라미터 중 소팅된 file_id를 원본으로 복원.
 * file_id를 인자로 받는 서비스 메서드에 적용.
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface FileIdDecrypt {
}
