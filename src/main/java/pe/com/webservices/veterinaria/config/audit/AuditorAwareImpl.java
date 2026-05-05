package pe.com.webservices.veterinaria.config.audit;

import org.springframework.data.domain.AuditorAware;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.util.Optional;

/**
 * Implementación para obtener el usuario actual desde el contexto de seguridad.
 * Este valor se inyectará automáticamente en los campos markedos con @CreatedBy y @LastModifiedBy.
 */
@Component
public class AuditorAwareImpl implements AuditorAware<String> {

    @Override
    public Optional<String> getCurrentAuditor() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        // Verificamos que haya una autenticación válida y no sea anónima
        if (authentication == null ||
                !authentication.isAuthenticated() ||
                authentication instanceof AnonymousAuthenticationToken) {
            return Optional.of("SYSTEM"); // Usuario por defecto para acciones del sistema o registros iniciales
        }

        // Retornamos el nombre del usuario (normalmente el email en tu configuración de JWT)
        return Optional.ofNullable(authentication.getName());
    }

}