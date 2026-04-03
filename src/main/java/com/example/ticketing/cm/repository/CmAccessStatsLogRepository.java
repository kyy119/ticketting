package com.example.ticketing.cm.repository;

import com.example.ticketing.entity.CmAccessStatsLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CmAccessStatsLogRepository extends JpaRepository<CmAccessStatsLog, Long> {
}