package com.example.ticketing.cm.service;

import com.example.ticketing.cm.repository.CmAccessStatsLogRepository;
import com.example.ticketing.entity.CmAccessStatsLog;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CmAccessStatsLogService {


    private final CmAccessStatsLogRepository cmAccessStatsLogRepository;

    @Transactional
    public void saveLog(CmAccessStatsLog log) {
        cmAccessStatsLogRepository.save(log);
    }
}