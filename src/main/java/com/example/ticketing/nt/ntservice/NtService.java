package com.example.ticketing.nt.ntservice;

import com.example.ticketing.entity.Notice;
import com.example.ticketing.nt.ntrepository.NtRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class NtService {

    private final NtRepository ntRepository;

    public List<Notice> findAll() {
        return ntRepository.findByDelYnOrderByNotSeqDesc("N");
    }

    @Transactional
    public Notice save(String notNo, String notContent, String regId, String regIp) {
        return ntRepository.save(Notice.builder()
                .notNo(notNo)
                .notContent(notContent)
                .regId(regId)
                .regIp(regIp)
                .build());
    }

    @Transactional
    public void delete(Long notSeq, String delId, String delIp) {
        if (!ntRepository.existsById(notSeq)) {
            throw new IllegalArgumentException("공지사항을 찾을 수 없습니다.");
        }
        ntRepository.softDelete(notSeq, LocalDateTime.now(), delId, delIp);
    }
}
