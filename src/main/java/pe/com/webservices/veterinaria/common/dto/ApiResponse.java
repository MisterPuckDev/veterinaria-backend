package pe.com.webservices.veterinaria.common.dto;

import java.time.LocalDateTime;

public record ApiResponse <T>(

        boolean sucess,
        String message,
        T data,
        LocalDateTime localDateTime
) {

    public ApiResponse(boolean sucess, String message, T data) {
        this(sucess, message, data, LocalDateTime.now());
    }
}
