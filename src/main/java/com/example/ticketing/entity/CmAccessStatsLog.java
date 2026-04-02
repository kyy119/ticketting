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

    // --- 공통 컬럼 ---
    @Column(name = "reg_dt", nullable = false, updatable = false)
    private LocalDateTime regDt;

    @Column(name = "reg_id", nullable = false, length = 50, updatable = false)
    private String regId;

    @Column(name = "reg_ip", nullable = false, length = 50, updatable = false)
    private String regIp;

    @Column(name = "mod_dt", nullable = false)
    private LocalDateTime modDt;

    @Column(name = "mod_id", nullable = false, length = 50)
    private String modId;

    @Column(name = "mod_ip", nullable = false, length = 50)
    private String modIp;

    @Column(name = "del_yn", nullable = false, length = 1)
    private String delYn;

    @Column(name = "del_dt")
    private LocalDateTime delDt;

    @Column(name = "del_id", length = 50)
    private String delId;

    @Column(name = "del_ip", length = 50)
    private String delIp;

    @PrePersist
    public void prePersist() {
        LocalDateTime now = LocalDateTime.now();
        this.regDt = now;
        this.modDt = now;
        this.delYn = "N"; // 초기 저장 시 삭제 여부는 무조건 'N'

        // 수정자 정보는 초기 생성 시 등록자와 동일하게 세팅 (NOT NULL 에러 방지)
        if (this.modId == null) this.modId = this.regId;
        if (this.modIp == null) this.modIp = this.regIp;
    }

    @Builder
    public CmAccessStatsLog(String usrId, String reqUrl, String regId, String regIp) {
        this.usrId = usrId;
        this.reqUrl = reqUrl;
        this.regId = regId;
        this.regIp = regIp;
    }
}