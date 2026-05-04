package pe.com.webservices.veterinaria.common.exception;

import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import pe.com.webservices.veterinaria.common.dto.ApiResponse;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<String>> handleGeneralException(Exception ex) {
        log.error("Error no controlado: ", ex);
        ApiResponse<String> response = new ApiResponse<>(
                false,
                "Ha ocurrido un error interno en el servidor",
                ex.getMessage()
        );
        return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    @ExceptionHandler(org.springframework.security.access.AccessDeniedException.class)
    public ResponseEntity<ApiResponse<String>> handleAccessDenied() {
        log.warn("Intento de acceso no autorizado detectado");
        ApiResponse<String> response = new ApiResponse<>(
                false,
                "No tienes permisos para acceder a este recurso",
                null
        );
        return new ResponseEntity<>(response, HttpStatus.FORBIDDEN);
    }
}