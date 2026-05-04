package pe.com.webservices.veterinaria.modules.owners.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import pe.com.webservices.veterinaria.modules.owners.dto.OwnerRequestDTO;
import pe.com.webservices.veterinaria.modules.owners.dto.OwnerResponseDTO;
import pe.com.webservices.veterinaria.modules.owners.service.OwnerService;

import java.util.List;
import java.util.UUID;

/**
 * Controlador REST para la gestión de Dueños.
 * Sigue las convenciones de nombres de recursos en plural.
 */
@RestController
@RequestMapping("/owners")
@RequiredArgsConstructor
public class OwnerController {

    private final OwnerService ownerService;

    @GetMapping
    public ResponseEntity<List<OwnerResponseDTO>> getAll() {
        return ResponseEntity.ok(ownerService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<OwnerResponseDTO> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(ownerService.findById(id));
    }

    @PostMapping
    public ResponseEntity<OwnerResponseDTO> create(@Valid @RequestBody OwnerRequestDTO request) {
        return new ResponseEntity<>(ownerService.create(request), HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<OwnerResponseDTO> update(
            @PathVariable UUID id,
            @Valid @RequestBody OwnerRequestDTO request) {
        return ResponseEntity.ok(ownerService.update(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        ownerService.delete(id);
        return ResponseEntity.noContent().build();
    }

}
