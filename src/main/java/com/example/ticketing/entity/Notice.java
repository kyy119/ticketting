package com.example.ticketing.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "t_notice", schema = "nol_2025")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Notice {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "not_seq")
    private Long notSeq;

    @Column(name = "not_no", nullable = false, length = 100)
    private String notNo;

    @Column(name = "not_content", nullable = false, columnDefinition = "TEXT")
    private String notContent;

    @Column(name = "not_dt", nullable = false)
    private LocalDateTime notDt;

    // --- 공통 컬럼 ---
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
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
        this.notDt = now; // 공지일 기본값
        this.regDt = now;
        this.modDt = now;
        this.delYn = "N";

        if (this.modId == null) this.modId = this.regId;
        if (this.modIp == null) this.modIp = this.regIp;
    }

    @PreUpdate
    public void preUpdate() {
        this.modDt = LocalDateTime.now();
    }

    @Builder
    public Notice(String notNo, String notContent, String regId, String regIp) {
        this.notNo = notNo;
        this.notContent = notContent;
        this.regId = regId;
        this.regIp = regIp;
    }
}