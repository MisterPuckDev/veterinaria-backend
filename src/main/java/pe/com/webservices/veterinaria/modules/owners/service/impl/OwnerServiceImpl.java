package pe.com.webservices.veterinaria.modules.owners.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import pe.com.webservices.veterinaria.modules.owners.dto.OwnerRequestDTO;
import pe.com.webservices.veterinaria.modules.owners.dto.OwnerResponseDTO;
import pe.com.webservices.veterinaria.modules.owners.mapper.OwnerMapper;
import pe.com.webservices.veterinaria.modules.owners.model.Owner;
import pe.com.webservices.veterinaria.modules.owners.repository.OwnerRepository;
import pe.com.webservices.veterinaria.modules.owners.service.OwnerService;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OwnerServiceImpl implements OwnerService {

    private final OwnerRepository ownerRepository;
    private final OwnerMapper ownerMapper;

    @Override
    @Transactional(readOnly = true)
    public List<OwnerResponseDTO> findAll() {
        return ownerRepository.findAll()
                .stream()
                .map(ownerMapper::toResponseDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public OwnerResponseDTO findById(UUID id) {
        Owner owner = ownerRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Dueño no encontrado"));
        return ownerMapper.toResponseDto(owner);
    }

    @Override
    @Transactional
    public OwnerResponseDTO create(OwnerRequestDTO request) {
        if (ownerRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new RuntimeException("El email ya está registrado");
        }
        Owner owner = ownerMapper.toEntity(request);
        return ownerMapper.toResponseDto(ownerRepository.save(owner));
    }

    @Override
    @Transactional
    public OwnerResponseDTO update(UUID id, OwnerRequestDTO request) {
        Owner owner = ownerRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Dueño no encontrado"));

        ownerMapper.updateEntityFromDto(request, owner);
        return ownerMapper.toResponseDto(ownerRepository.save(owner));
    }

    @Override
    @Transactional
    public void delete(UUID id) {
        Owner owner = ownerRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Dueño no encontrado"));
        // Al llamar a delete, Hibernate ejecutará el SQL de @SQLDelete definido en la entidad
        ownerRepository.delete(owner);
    }
}