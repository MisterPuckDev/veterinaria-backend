package pe.com.webservices.veterinaria.infrastructure.security.config;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import pe.com.webservices.veterinaria.infrastructure.security.filter.JwtAuthenticationFilter;

import java.util.Arrays;
import java.util.List;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthFilter;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // 1. Deshabilitar CSRF: Seguro en APIs REST sin cookies de sesión, ya que usamos JWT en Headers.
                .csrf(AbstractHttpConfigurer::disable)
                // 2. Configurar CORS para permitir peticiones desde tu frontend (Vite/React)
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                // 3. Establecer reglas de autorización (RBAC) basadas en el esquema de base de datos
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/api/auth/**").permitAll() // Login público
                        .requestMatchers("/api/portal/**").hasAnyRole("CLIENTE", "ADMIN")
                        .requestMatchers("/api/clinical/**").hasAnyRole("VETERINARIO", "ADMIN")
                        .requestMatchers("/api/reception/**").hasAnyRole("RECEPCIONISTA", "ADMIN")
                        .requestMatchers("/api/billing/**").hasAnyRole("RECEPCIONISTA", "ADMIN")
                        .requestMatchers("/api/admin/**").hasRole("ADMIN") // Rutas críticas solo Admin
                        .anyRequest().authenticated()
                )
                // 4. Configurar manejo de sesiones Stateless (No se guarda estado en el servidor de Java)
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                // 5. Insertar nuestro filtro JWT antes del filtro de autenticación por defecto de Spring
                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        // En producción real, reemplazar "*" por "https://tudominio.com"
        configuration.setAllowedOrigins(List.of("*"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("Authorization", "Content-Type", "X-Requested-With"));
        configuration.setExposedHeaders(List.of("Authorization"));

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

}