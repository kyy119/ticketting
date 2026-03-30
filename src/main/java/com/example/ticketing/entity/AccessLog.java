package com.example.ticketing.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;

@Entity
@Table(schema = "nol_2025", name = "access_stats_log")
@Getter @Setter
@NoArgsConstructor
public class AccessLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "log_seq")
    private Long logSeq;

    @Column(name = "usr_id", length = 50, nullable = false)
    private String usrId;

    @Column(name = "req_url", length = 1000, nullable = false)
    private String reqUrl;

    @Column(name = "reg_dt", nullable = false)
    private LocalDate regDt;

    @Column(name = "reg_id", length = 50, nullable = false)
    private String regId;

    @Column(name = "reg_ip", length = 50, nullable = false)
    private String regIp;

    @Column(name = "mod_dt", nullable = false)
    private LocalDate modDt;

    @Column(name = "mod_id", length = 50, nullable = false)
    private String modId;

    @Column(name = "mod_ip", length = 50, nullable = false)
    private String modIp;

    @Column(name = "del_yn", length = 1, nullable = false)
    private String delYn;

    @Column(name = "del_dt")
    private LocalDate delDt;

    @Column(name = "del_id", length = 50)
    private String delId;

    @Column(name = "del_ip", length = 50)
    private String delIp;

    @PrePersist
    public void prePersist() {
        LocalDate now = LocalDate.now();
        this.regDt = now;
        this.modDt = now;
        if (this.delYn == null) this.delYn = "N";
    }
}
