package pe.com.webservices.veterinaria.config.audit;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.domain.AuditorAware;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

/**
 * Configuración central para activar la auditoría de JPA.
 */
@Configuration
@EnableJpaAuditing(auditorAwareRef = "auditorProvider")
public class AuditConfig {

    /**
     * Definimos el Bean que proveerá el nombre del usuario para la auditoría.
     * El nombre "auditorProvider" debe coincidir con el valor de 'auditorAwareRef' en @EnableJpaAuditing.
     */
    @Bean
    public AuditorAware<String> auditorProvider() {
        return new AuditorAwareImpl();
    }
}