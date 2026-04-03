package com.example.ticketing.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "access_stats_log", schema = "nol_2025")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class CmAccessStatsLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "log_seq")
    private Long logSeq;

    @Column(name = "usr_id", nullable = false, length = 50)
    private String usrId;

    @Column(name = "req_url", nullable = false, length = 1000)
    private String reqUrl;

    // --- 공통 컬럼 (로그는 생성 기록만 남김) ---
    @Column(name = "reg_dt", nullable = false, updatable = false)
    private LocalDateTime regDt;

    @Column(name = "reg_id", nullable = false, length = 50, updatable = false)
    private String regId;

    @Column(name = "reg_ip", nullable = false, length = 50, updatable = false)
    private String regIp;

    @PrePersist
    public void prePersist() {
        this.regDt = LocalDateTime.now();
    }

    @Builder
    public CmAccessStatsLog(String usrId, String reqUrl, String regId, String regIp) {
        this.usrId = usrId;
        this.reqUrl = reqUrl;
        this.regId = regId;
        this.regIp = regIp;
    }
}