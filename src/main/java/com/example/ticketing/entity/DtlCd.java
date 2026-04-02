package com.example.ticketing.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Entity
@Table(name = "t_dtl_cd")
@IdClass(DtlCdId.class)
@Getter @Setter
@NoArgsConstructor
public class DtlCd {

    @Id
    @Column(name = "grp_cd", length = 30)
    private String grpCd;

    @Id
    @Column(name = "dtl_cd", length = 30)
    private String dtlCd;

    @Column(name = "dtl_cd_nm", length = 100, nullable = false)
    private String dtlCdNm;

    @Column(name = "sort_no")
    private Integer sortNo;

    @Column(name = "use_yn", length = 1)
    private String useYn;

    @Column(name = "remark", length = 1000)
    private String remark;

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

        if (this.useYn == null) this.useYn = "Y";
        if (this.delYn == null) this.delYn = "N";
    }

    @PreUpdate
    public void preUpdate() {
        this.modDt = LocalDate.now();
    }
}