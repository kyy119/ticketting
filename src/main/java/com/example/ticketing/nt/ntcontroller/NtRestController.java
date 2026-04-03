package com.example.ticketing.nt.ntcontroller;

import com.example.ticketing.cm.dto.CmApiResponse;
import com.example.ticketing.entity.Notice;
import com.example.ticketing.nt.ntservice.NtService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("nt/notice")
@RequiredArgsConstructor
public class NtRestController {

    private final NtService ntService;

    @GetMapping("/list")
    public CmApiResponse<List<Notice>> list() {
        return CmApiResponse.success(ntService.findAll());
    }

    // form-encoded POST → XssEscapeFilter의 getParameter() 경유
    @PostMapping("/save")
    public CmApiResponse<Notice> save(@RequestParam String notNo,
                                      @RequestParam String notContent,
                                      HttpServletRequest request) {
        String ip     = resolveIp(request);
        String userId = resolveUserId(request);
        return CmApiResponse.success(ntService.save(notNo, notContent, userId, ip));
    }

    @DeleteMapping("/{notSeq}")
    public CmApiResponse<Void> delete(@PathVariable Long notSeq, HttpServletRequest request) {
        try {
            ntService.delete(notSeq, resolveUserId(request), resolveIp(request));
            return CmApiResponse.success(null);
        } catch (IllegalArgumentException e) {
            return CmApiResponse.error(404, e.getMessage());
        }
    }

    private String resolveIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip != null && !ip.isBlank()) return ip.split(",")[0].trim();
        return request.getRemoteAddr();
    }

    @SuppressWarnings("unchecked")
    private String resolveUserId(HttpServletRequest request) {
        var session = request.getSession(false);
        if (session != null && session.getAttribute("sessionMap") != null) {
            var map = (java.util.Map<String, Object>) session.getAttribute("sessionMap");
            var id  = (String) map.get("usrId");
            if (id != null && !id.isBlank()) return id;
        }
        return "GUEST";
    }
}
