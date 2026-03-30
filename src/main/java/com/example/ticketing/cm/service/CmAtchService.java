package com.example.ticketing.cm.service;

import com.example.ticketing.cm.repository.CmAtchRepository;
import com.example.ticketing.cm.sort.FileIdDecrypt;
import com.example.ticketing.cm.sort.FileIdEncrypt;
import com.example.ticketing.entity.CmAtch;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CmAtchService {

    private final CmAtchRepository cmAtchRepository;

    @Value("${app.upload.dir}")
    private String uploadDir;

    /** 전체 첨부파일 목록 반환 (file_id AOP 소팅 적용) */
    @FileIdEncrypt
    public List<CmAtch> findAll() {
        return cmAtchRepository.findByDelYnOrderByFileIdAscSortNoAsc("N");
    }

    /** 업로드 후 fileId 소팅 적용 */
    @FileIdEncrypt
    @Transactional
    public Map<String, Object> uploadBatch(List<MultipartFile> files, HttpServletRequest request) throws IOException {
        String fileId = UUID.randomUUID().toString();
        List<CmAtch> saved = new ArrayList<>();
        for (int i = 0; i < files.size(); i++) {
            saved.add(saveSingle(fileId, (long) i, files.get(i), request));
        }
        Map<String, Object> result = new HashMap<>();
        result.put("fileId", fileId);
        result.put("files", saved);
        return result;
    }

    private CmAtch saveSingle(String fileId, long sortNo, MultipartFile file, HttpServletRequest request) throws IOException {
        String orignlFileNm = file.getOriginalFilename();
        String ext = extractExt(orignlFileNm);

        Path dir = Paths.get(uploadDir, fileId);
        Files.createDirectories(dir);

        String savedFileName = UUID.randomUUID() + (ext.isEmpty() ? "" : "." + ext);
        file.transferTo(dir.resolve(savedFileName));

        CmAtch atch = new CmAtch();
        atch.setFileId(fileId);
        atch.setSortNo(sortNo);
        atch.setOrignlFileNm(orignlFileNm);
        atch.setFileUrl(Paths.get(uploadDir, fileId, savedFileName).toString());
        atch.setFileSz(formatSize(file.getSize()));
        atch.setFileType(ext.isEmpty() ? "기타" : ext.toLowerCase());
        atch.setRegId("admin");
        atch.setRegIp(resolveIp(request));
        atch.setModId("admin");
        atch.setModIp(resolveIp(request));

        return cmAtchRepository.save(atch);
    }

    /** 소팅된 fileId를 unsort 후 조회, 반환값 fileId 소팅 적용 */
    @FileIdDecrypt
    @FileIdEncrypt
    public List<CmAtch> findByFileId(String sortedFileId) {
        return cmAtchRepository.findByFileIdAndDelYnOrderBySortNoAsc(sortedFileId, "N");
    }

    /** atch_seq 단건 소프트 삭제 */
    @Transactional
    public void delete(Long atchSeq, HttpServletRequest request) {
        CmAtch atch = cmAtchRepository.findById(atchSeq)
                .orElseThrow(() -> new IllegalArgumentException("파일을 찾을 수 없습니다."));
        softDelete(atch, request);
    }

    /** 소팅된 fileId를 unsort 후 그룹 전체 소프트 삭제 */
    @FileIdDecrypt
    @Transactional
    public void deleteByFileId(String sortedFileId, HttpServletRequest request) {
        List<CmAtch> list = cmAtchRepository.findByFileIdAndDelYnOrderBySortNoAsc(sortedFileId, "N");
        list.forEach(atch -> softDelete(atch, request));
    }

    /** 다운로드용 — AOP 미적용, 실제 fileId + savedFileName으로 원본 레코드 조회 */
    public CmAtch findForDownload(String realFileId, String savedFileName) {
        return cmAtchRepository.findByFileIdAndDelYnOrderBySortNoAsc(realFileId, "N")
                .stream()
                .filter(a -> a.getFileUrl() != null && a.getFileUrl().endsWith(savedFileName))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("파일을 찾을 수 없습니다."));
    }

    private void softDelete(CmAtch atch, HttpServletRequest request) {
        atch.setDelYn("Y");
        atch.setDelDt(LocalDate.now());
        atch.setDelId("admin");
        atch.setDelIp(resolveIp(request));
    }

    private String extractExt(String fileName) {
        if (fileName == null) return "";
        int idx = fileName.lastIndexOf('.');
        return idx >= 0 ? fileName.substring(idx + 1) : "";
    }

    private String formatSize(long bytes) {
        if (bytes < 1024) return bytes + " B";
        if (bytes < 1024 * 1024) return String.format("%.1f KB", bytes / 1024.0);
        return String.format("%.1f MB", bytes / (1024.0 * 1024));
    }

    private String resolveIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip != null && !ip.isBlank()) return ip.split(",")[0].trim();
        return request.getRemoteAddr();
    }
}
