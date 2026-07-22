package pe.com.webservices.veterinaria.application.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PatientSaveDTO {

    @NotNull(message = "El ID del cliente es obligatorio")
    private UUID clientId;

    @NotBlank(message = "El nombre del paciente es obligatorio")
    @Size(max = 100, message = "El nombre no puede superar los 100 caracteres")
    private String name;

    @NotBlank(message = "La especie es obligatoria")
    @Size(max = 50, message = "La especie no puede superar los 50 caracteres")
    private String species;

    @Size(max = 100, message = "La raza no puede superar los 100 caracteres")
    private String breed;

    @NotBlank(message = "El género es obligatorio")
    private String gender;

    private LocalDate dateOfBirth;

    @Positive(message = "El peso debe ser un número positivo")
    private BigDecimal weight;

    private String medicalNotes;

}