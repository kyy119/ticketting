package com.example.ticketing.cm.controller;

import com.example.ticketing.cm.service.CmCodeService;
import com.example.ticketing.cm.dto.CmApiResponse;
import com.example.ticketing.entity.DtlCd;
import com.example.ticketing.entity.GrpCd;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/cm/code")
@RequiredArgsConstructor
public class CmCodeRestController {

    private final CmCodeService cmCodeService;

    @GetMapping("/grp/next")
    public CmApiResponse<String> nextGrpCd(@RequestParam String prefix) {
        return CmApiResponse.success(cmCodeService.generateNextGrpCd(prefix));
    }

    @PostMapping("/grp")
    public CmApiResponse<Void> saveGrpCd(@RequestBody Map<String, Object> body) {
        String prefix = (String) body.get("grpCdPrefix");
        GrpCd grpCd = new GrpCd();
        grpCd.setGrpCdNm((String) body.get("grpCdNm"));
        grpCd.setUseYn((String) body.getOrDefault("useYn", "Y"));
        grpCd.setRemark((String) body.get("remark"));
        cmCodeService.saveGrpCd(prefix, grpCd);
        return CmApiResponse.success(null);
    }

    @GetMapping("/dtl")
    public CmApiResponse<List<DtlCd>> getDtlCds(@RequestParam String grpCd) {
        return CmApiResponse.success(cmCodeService.findDtlCdsByGrpCd(grpCd));
    }

    @PostMapping("/dtl")
    public CmApiResponse<Void> saveDtlCd(@RequestBody DtlCd dtlCd) {
        try {
            cmCodeService.saveDtlCd(dtlCd);
            return CmApiResponse.success(null);
        } catch (IllegalArgumentException e) {
            return CmApiResponse.error(409, e.getMessage());
        }
    }

    @PutMapping("/dtl")
    public CmApiResponse<Void> updateDtlCd(@RequestBody DtlCd dtlCd) {
        try {
            cmCodeService.updateDtlCd(dtlCd);
            return CmApiResponse.success(null);
        } catch (IllegalArgumentException e) {
            return CmApiResponse.error(404, e.getMessage());
        }
    }
}
