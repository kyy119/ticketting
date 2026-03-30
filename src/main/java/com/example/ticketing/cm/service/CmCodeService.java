package com.example.ticketing.cm.service;

import com.example.ticketing.cm.repository.CmDtlCdRepository;
import com.example.ticketing.cm.repository.CmGrpCdRepository;
import com.example.ticketing.entity.DtlCd;
import com.example.ticketing.entity.DtlCdId;
import com.example.ticketing.entity.GrpCd;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CmCodeService {

    private final CmGrpCdRepository grpCdRepository;
    private final CmDtlCdRepository dtlCdRepository;

    public String generateNextGrpCd(String prefix) {
        int maxNum = grpCdRepository.findAll().stream()
                .map(g -> g.getGrpCd().replaceAll("^[A-Za-z]+", ""))
                .filter(s -> s.matches("\\d+"))
                .mapToInt(Integer::parseInt)
                .max()
                .orElse(0);
        return prefix.toUpperCase() + String.format("%03d", maxNum + 1);
    }

    @Transactional
    public void saveGrpCd(String prefix, GrpCd grpCd) {
        grpCd.setGrpCd(generateNextGrpCd(prefix));
        grpCd.setRegId("admin");
        grpCd.setRegIp("127.0.0.1");
        grpCd.setModId("admin");
        grpCd.setModIp("127.0.0.1");
        grpCd.setDelYn("N");
        grpCdRepository.save(grpCd);
    }

    @Transactional
    public void saveDtlCd(DtlCd dtlCd) {
        DtlCdId id = new DtlCdId(dtlCd.getGrpCd(), dtlCd.getDtlCd());
        if (dtlCdRepository.existsById(id)) {
            throw new IllegalArgumentException("이미 등록되어 있는 코드입니다.");
        }
        dtlCd.setRegId("admin");
        dtlCd.setRegIp("127.0.0.1");
        dtlCd.setModId("admin");
        dtlCd.setModIp("127.0.0.1");
        dtlCd.setDelYn("N");
        dtlCdRepository.save(dtlCd);
    }

    @Transactional
    public void updateDtlCd(DtlCd dtlCd) {
        DtlCdId id = new DtlCdId(dtlCd.getGrpCd(), dtlCd.getDtlCd());
        DtlCd existing = dtlCdRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 코드입니다."));
        existing.setDtlCdNm(dtlCd.getDtlCdNm());
        existing.setSortNo(dtlCd.getSortNo());
        existing.setUseYn(dtlCd.getUseYn());
        existing.setRemark(dtlCd.getRemark());
        existing.setModId("admin");
        existing.setModIp("127.0.0.1");
    }

    public List<GrpCd> findAllGrpCds() {
        return grpCdRepository.findAll();
    }

    public List<DtlCd> findDtlCdsByGrpCd(String grpCd) {
        return dtlCdRepository.findByGrpCdAndDelYnOrderBySortNoAsc(grpCd, "N");
    }
}
