package com.example.ticketing.cm.controller;

import com.example.ticketing.cm.service.CmCodeService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/cm/code")
@RequiredArgsConstructor
public class CmCodeController {

    private final CmCodeService cmCodeService;

    @GetMapping
    public String codePage(Model model) {
        model.addAttribute("grpCdList", cmCodeService.findAllGrpCds());
        return "cm/cmCode";
    }
}
