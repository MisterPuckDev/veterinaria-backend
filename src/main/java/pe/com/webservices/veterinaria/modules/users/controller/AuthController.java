package pe.com.webservices.veterinaria.modules.users.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import pe.com.webservices.veterinaria.common.dto.ApiResponse;
import pe.com.webservices.veterinaria.modules.users.dto.AuthResponse;
import pe.com.webservices.veterinaria.modules.users.dto.LoginRequest;
import pe.com.webservices.veterinaria.modules.users.dto.RegisterRequest;
import pe.com.webservices.veterinaria.modules.users.service.impl.AuthServiceImpl;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthServiceImpl authService;

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.ok(ApiResponse.success(authService.register(request), "Usuario registrado exitosamente"));
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> authenticate(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(ApiResponse.success(authService.authenticate(request), "Login correcto"));
    }
}