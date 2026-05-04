package pe.com.webservices.veterinaria.modules.owners.dto;

import lombok.Builder;
import lombok.Data;

import java.util.UUID;

/**
 * DTO para la respuesta de la API.
 */
@Data
@Builder
public class OwnerResponseDTO {

    private UUID id;
    private String firstName;
    private String lastName;
    private String email;
    private String phone;
    private boolean isActive;

}