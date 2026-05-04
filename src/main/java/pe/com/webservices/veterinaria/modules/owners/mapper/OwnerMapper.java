package pe.com.webservices.veterinaria.modules.owners.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import pe.com.webservices.veterinaria.modules.owners.dto.OwnerRequestDTO;
import pe.com.webservices.veterinaria.modules.owners.dto.OwnerResponseDTO;
import pe.com.webservices.veterinaria.modules.owners.model.Owner;

/**
 * Mapper de MapStruct para convertir entre Entidades y DTOs.
 * La implementación se genera automáticamente en tiempo de compilación.
 */
@Mapper(componentModel = "spring")
public interface OwnerMapper {

    OwnerResponseDTO toResponseDto(Owner owner);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "pets", ignore = true)
    @Mapping(target = "active", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "deletedAt", ignore = true)
    Owner toEntity(OwnerRequestDTO requestDto);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "pets", ignore = true)
    void updateEntityFromDto(OwnerRequestDTO dto, @MappingTarget Owner entity);

}