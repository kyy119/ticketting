package com.example.ticketing.cm.controller;

import com.example.ticketing.cm.service.CmAtchService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/cm/atch")
@RequiredArgsConstructor
public class CmAtchController {

    private final CmAtchService cmAtchService;

    @GetMapping
    public String index() {
        return "cm/cmAtch";
    }
}
