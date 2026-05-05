package pe.com.webservices.veterinaria.modules.users.service;

import pe.com.webservices.veterinaria.modules.users.dto.AuthResponse;
import pe.com.webservices.veterinaria.modules.users.dto.LoginRequest;
import pe.com.webservices.veterinaria.modules.users.dto.RegisterRequest;

public interface AuthService {

    AuthResponse register(RegisterRequest request);

    AuthResponse authenticate(LoginRequest request);
}
