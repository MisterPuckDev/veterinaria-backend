package pe.com.webservices.veterinaria.infrastructure.exception;

public class BusinessException extends RuntimeException {

    public BusinessException(String message) {
        super(message);
    }

}