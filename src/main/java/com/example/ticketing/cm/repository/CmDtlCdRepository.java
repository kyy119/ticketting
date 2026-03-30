package com.example.ticketing.cm.repository;

import com.example.ticketing.entity.DtlCd;
import com.example.ticketing.entity.DtlCdId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CmDtlCdRepository extends JpaRepository<DtlCd, DtlCdId> {

    List<DtlCd> findByGrpCdAndDelYnOrderBySortNoAsc(String grpCd, String delYn);
}
