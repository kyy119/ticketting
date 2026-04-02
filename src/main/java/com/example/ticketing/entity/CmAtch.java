package com.example.ticketing.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;

@Entity
@Table(schema = "nol_2025", name = "t_cm_atch")
@Getter
@Setter
@NoArgsConstructor
public class CmAtch {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "atch_seq")
    private Long atchSeq;

    @Column(name = "file_id", length = 50, nullable = false)
    private String fileId;

    @Column(name = "sort_no", nullable = false)
    private Long sortNo;

    @Column(name = "orignl_file_nm", length = 100, nullable = false)
    private String orignlFileNm;

    @Column(name = "file_url", length = 1000, nullable = false)
    private String fileUrl;

    @Column(name = "file_sz", length = 50, nullable = false)
    private String fileSz;

    @Column(name = "file_type", length = 10, nullable = false)
    private String fileType;

    @Column(name = "reg_dt", nullable = false, updatable = false)
    private LocalDate regDt;

    @Column(name = "reg_id", length = 50, nullable = false, updatable = false)
    private String regId;

    @Column(name = "reg_ip", length = 50, nullable = false, updatable = false)
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
        if (this.sortNo == null) this.sortNo = 0L;
    }

    @PreUpdate
    public void preUpdate() {
        this.modDt = LocalDate.now();
    }
}
