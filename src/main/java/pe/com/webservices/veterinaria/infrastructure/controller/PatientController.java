package pe.com.webservices.veterinaria.infrastructure.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import pe.com.webservices.veterinaria.application.dto.PatientResponseDTO;
import pe.com.webservices.veterinaria.application.dto.PatientSaveDTO;
import pe.com.webservices.veterinaria.application.service.PatientService;

import java.util.UUID;

@RestController
@RequestMapping("/api/patients")
@RequiredArgsConstructor
public class PatientController {

    private final PatientService patientService;

    @GetMapping
    @PreAuthorize("hasAnyRole('VETERINARIO', 'RECEPCIONISTA', 'ADMIN')")
    public ResponseEntity<Page<PatientResponseDTO>> getAll(
            @PageableDefault(size = 10, page = 0) Pageable pageable) {
        return ResponseEntity.ok(patientService.getAllPatients(pageable));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('VETERINARIO', 'RECEPCIONISTA', 'ADMIN')")
    public ResponseEntity<PatientResponseDTO> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(patientService.getPatientById(id));
    }

    @GetMapping("/client/{clientId}")
    @PreAuthorize("hasAnyRole('VETERINARIO', 'RECEPCIONISTA', 'ADMIN', 'CLIENTE')")
    public ResponseEntity<Page<PatientResponseDTO>> getByClientId(
            @PathVariable UUID clientId,
            @PageableDefault(size = 10, page = 0) Pageable pageable) {
        // Nota: Si es CLIENTE, en un caso real se debe validar que el clientId del Path sea el mismo del JWT.
        return ResponseEntity.ok(patientService.getPatientsByClient(clientId, pageable));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('RECEPCIONISTA', 'ADMIN')")
    public ResponseEntity<PatientResponseDTO> create(@Valid @RequestBody PatientSaveDTO dto) {
        PatientResponseDTO response = patientService.createPatient(dto);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('RECEPCIONISTA', 'VETERINARIO', 'ADMIN')")
    public ResponseEntity<PatientResponseDTO> update(
            @PathVariable UUID id,
            @Valid @RequestBody PatientSaveDTO dto) {
        return ResponseEntity.ok(patientService.updatePatient(id, dto));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        patientService.deletePatient(id);
        return ResponseEntity.noContent().build();
    }

}