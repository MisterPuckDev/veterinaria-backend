package pe.com.webservices.veterinaria.infrastructure.security.filter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import pe.com.webservices.veterinaria.infrastructure.security.jwt.JwtService;

import java.io.IOException;
import java.util.Collections;

@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtService jwtService;

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain
    ) throws ServletException, IOException {

        final String authHeader = request.getHeader("Authorization");
        final String jwt;
        final String userUuid;
        final String userRole;

        // Si no hay token o no empieza con Bearer, cedemos el control al siguiente filtro (ej. endpoints públicos)
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        jwt = authHeader.substring(7);

        try {
            userUuid = jwtService.extractUserId(jwt);
            userRole = jwtService.extractRole(jwt);

            // Si validamos el token y aún no hay autenticación en el contexto
            if (userUuid != null && SecurityContextHolder.getContext().getAuthentication() == null) {

                if (jwtService.isTokenValid(jwt)) {
                    // Creamos el token de autenticación pasándole el UUID como "Principal"
                    UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                            userUuid,
                            null,
                            Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + userRole))
                    );

                    authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

                    // Inyectamos el usuario en el contexto de seguridad de Spring
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                }
            }
        } catch (Exception ex) {
            // Token inválido, expirado o manipulado. Se limpia el contexto por seguridad.
            SecurityContextHolder.clearContext();
        }

        filterChain.doFilter(request, response);
    }

}