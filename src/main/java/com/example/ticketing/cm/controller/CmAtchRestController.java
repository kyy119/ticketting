package com.example.ticketing.cm.controller;

import com.example.ticketing.cm.dto.CmApiResponse;
import com.example.ticketing.cm.service.CmAtchService;
import com.example.ticketing.entity.CmAtch;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/cm/atch")
@RequiredArgsConstructor
public class CmAtchRestController {

    private final CmAtchService cmAtchService;

    /** 전체 첨부파일 목록 (file_id AOP 소팅 적용) */
    @GetMapping("/list/all")
    public CmApiResponse<List<CmAtch>> listAll() {
        return CmApiResponse.success(cmAtchService.findAll());
    }

    /** 특정 그룹(소팅된 file_id) 파일 목록 */
    @GetMapping("/list")
    public CmApiResponse<List<CmAtch>> list(@RequestParam String fileId) {
        return CmApiResponse.success(cmAtchService.findByFileId(fileId));
    }

    /** 파일 업로드 (서버에서 UUID 생성, file_id AOP 소팅 적용) */
    @PostMapping("/upload")
    public CmApiResponse<Map<String, Object>> upload(@RequestParam("files") List<MultipartFile> files,
                                                     HttpServletRequest request) {
        try {
            return CmApiResponse.success(cmAtchService.uploadBatch(files, request));
        } catch (Exception e) {
            return CmApiResponse.error(500, e.getMessage());
        }
    }

    /** 단건 소프트 삭제 (atch_seq 기준) */
    @DeleteMapping("/{atchSeq}")
    public CmApiResponse<Void> delete(@PathVariable Long atchSeq, HttpServletRequest request) {
        try {
            cmAtchService.delete(atchSeq, request);
            return CmApiResponse.success(null);
        } catch (IllegalArgumentException e) {
            return CmApiResponse.error(404, e.getMessage());
        }
    }

    /** 그룹 전체 소프트 삭제 (소팅된 file_id → AOP unsort → 실제 file_id) */
    @DeleteMapping("/group/{sortedFileId}")
    public CmApiResponse<Void> deleteGroup(@PathVariable String sortedFileId, HttpServletRequest request) {
        try {
            cmAtchService.deleteByFileId(sortedFileId, request);
            return CmApiResponse.success(null);
        } catch (IllegalArgumentException e) {
            return CmApiResponse.error(400, e.getMessage());
        }
    }
}
