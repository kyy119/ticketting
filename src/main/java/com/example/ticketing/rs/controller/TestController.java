package com.example.ticketing.rs.controller;

import com.example.ticketing.cm.dto.CmApiResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TestController {

    @GetMapping("/")
    public CmApiResponse<String> home() {
        return CmApiResponse.success("🎉 티켓팅 서버가 정상적으로 실행 중입니다! (모든 보안 설정 개방 완료)");
    }

    // localhost:8080/test 로 접속했을 때 보여줄 내용
    @GetMapping("/test")
    public CmApiResponse<String> test() {
        return CmApiResponse.success("여기는 테스트용 임시 화면입니다. 🚀");
    }
}