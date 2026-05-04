package pe.com.webservices.veterinaria.modules.owners.service;

import pe.com.webservices.veterinaria.modules.owners.dto.OwnerRequestDTO;
import pe.com.webservices.veterinaria.modules.owners.dto.OwnerResponseDTO;

import java.util.List;
import java.util.UUID;

public interface OwnerService {

    List<OwnerResponseDTO> findAll();

    OwnerResponseDTO findById(UUID id);

    OwnerResponseDTO create(OwnerRequestDTO request);

    OwnerResponseDTO update(UUID id, OwnerRequestDTO request);

    void delete(UUID id);

}