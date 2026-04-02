package com.example.ticketing.cm.repository;

import com.example.ticketing.entity.CmAtch;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CmAtchRepository extends JpaRepository<CmAtch, Long> {

    List<CmAtch> findByFileIdAndDelYnOrderBySortNoAsc(String fileId, String delYn);

    List<CmAtch> findByDelYnOrderByFileIdAscSortNoAsc(String delYn);
}
