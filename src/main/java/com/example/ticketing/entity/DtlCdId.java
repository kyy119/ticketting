package com.example.ticketing.entity;

import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import java.io.Serializable;

@EqualsAndHashCode
@NoArgsConstructor
@AllArgsConstructor
public class DtlCdId implements Serializable{
    private String grpCd;
    private String dtlCd;
}