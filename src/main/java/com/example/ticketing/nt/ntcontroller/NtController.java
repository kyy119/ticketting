package com.example.ticketing.nt.ntcontroller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("nt")
public class NtController {

    @GetMapping("/notice")
    public String notice() {
        return "nt/ntNotice";
    }
}
