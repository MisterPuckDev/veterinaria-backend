package pe.com.webservices.veterinaria.modules.users.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import pe.com.webservices.veterinaria.modules.users.model.User;

import java.util.Optional;
import java.util.UUID;

public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByEmail(String email);

    boolean existsByEmail(String email);
}