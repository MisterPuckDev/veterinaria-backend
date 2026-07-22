package pe.com.webservices.veterinaria.application.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import pe.com.webservices.veterinaria.application.dto.PatientResponseDTO;
import pe.com.webservices.veterinaria.application.dto.PatientSaveDTO;

import java.util.UUID;

public interface PatientService {

    Page<PatientResponseDTO> getAllPatients(Pageable pageable);

    Page<PatientResponseDTO> getPatientsByClient(UUID clientId, Pageable pageable);

    PatientResponseDTO getPatientById(UUID id);

    PatientResponseDTO createPatient(PatientSaveDTO dto);

    PatientResponseDTO updatePatient(UUID id, PatientSaveDTO dto);

    void deletePatient(UUID id);

}