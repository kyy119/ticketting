package com.example.ticketing.cm.controller;

import com.example.ticketing.cm.service.CmAtchService;
import com.example.ticketing.cm.sort.FileIdSortManager;
import com.example.ticketing.entity.CmAtch;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.util.UriUtils;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * sortedFileId를 unsort 후 실제 fileId로 DB 조회, fileUrl(디스크 경로)로 파일 서빙.
 * URL: /cm/atch/download/{sortedFileId}/{savedFileName}
 */
@Controller
@RequestMapping("/cm/atch/download")
@RequiredArgsConstructor
public class CmAtchDownloadController {

    private final FileIdSortManager fileIdSortManager;
    private final CmAtchService cmAtchService;

    @GetMapping("/{sortedFileId}/{savedFileName}")
    public ResponseEntity<Resource> download(@PathVariable String sortedFileId,
                                             @PathVariable String savedFileName) throws Exception {

        // ① sortedFileId → 실제 fileId 복원
        String realFileId = fileIdSortManager.unsort(sortedFileId);

        // ② 실제 fileId + savedFileName으로 DB 조회
        CmAtch atch = cmAtchService.findForDownload(realFileId, savedFileName);

        // ③ fileUrl(실제 디스크 경로)로 파일 읽기
        Path file = Paths.get(atch.getFileUrl());
        Resource resource = new UrlResource(file.toUri());

        if (!resource.exists() || !resource.isReadable()) {
            return ResponseEntity.notFound().build();
        }

        // ④ Content-Type 감지
        String contentType = Files.probeContentType(file);
        if (contentType == null) contentType = "application/octet-stream";

        // ⑤ 원본 파일명으로 다운로드
        String encodedName = UriUtils.encode(atch.getOrignlFileNm(), StandardCharsets.UTF_8);

        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(contentType))
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename*=UTF-8''" + encodedName)
                .body(resource);
    }
}
