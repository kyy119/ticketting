package com.example.ticketing.nt.ntrepository;

import com.example.ticketing.entity.Notice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface NtRepository extends JpaRepository<Notice, Long> {

    List<Notice> findByDelYnOrderByNotSeqDesc(String delYn);

    @Modifying
    @Query("UPDATE Notice n SET n.delYn = 'Y', n.delDt = :now, n.delId = :delId, n.delIp = :delIp WHERE n.notSeq = :notSeq")
    void softDelete(@Param("notSeq") Long notSeq,
                    @Param("now") LocalDateTime now,
                    @Param("delId") String delId,
                    @Param("delIp") String delIp);
}
