package com.example.ticketing.cm.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class CmTestController {

    // URL 경로 앞에는 패키지명
    @GetMapping("/cm")
    public String testPage(Model model) {
        model.addAttribute("message", "접속 로그 테스트 페이지!");
        return "cm/testPage";
    }
    @GetMapping("/home")
    public String home() {
        return "home";
    }
}