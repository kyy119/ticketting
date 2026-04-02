package com.example.ticketing.cm.dto;

import lombok.Getter;

@Getter
public class CmApiResponse<T> {

    private final int status;
    private final String message;
    private final T data;

    private CmApiResponse(int status, String message, T data) {
        this.status = status;
        this.message = message;
        this.data = data;
    }

    public static <T> CmApiResponse<T> success(T data) {
        return new CmApiResponse<>(200, "success", data);
    }

    public static <T> CmApiResponse<T> error(int status, String message) {
        return new CmApiResponse<>(status, message, null);
    }
}
