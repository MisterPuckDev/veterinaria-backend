package pe.com.webservices.veterinaria.modules.owners.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import pe.com.webservices.veterinaria.modules.owners.model.Owner;

import java.util.Optional;
import java.util.UUID;

/**
 * Repositorio para la entidad Owner.
 * Gracias a @Where(clause = "is_active = true") en la entidad,
 * todos los métodos aquí filtrarán automáticamente los registros eliminados.
 */
@Repository
public interface OwnerRepository extends JpaRepository<Owner, UUID> {

    // Búsqueda por email (útil para validaciones de registro)
    Optional<Owner> findByEmail(String email);

}