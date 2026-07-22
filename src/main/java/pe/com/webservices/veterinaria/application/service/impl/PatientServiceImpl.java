package pe.com.webservices.veterinaria.application.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import pe.com.webservices.veterinaria.application.dto.PatientResponseDTO;
import pe.com.webservices.veterinaria.application.dto.PatientSaveDTO;
import pe.com.webservices.veterinaria.application.service.PatientService;
import pe.com.webservices.veterinaria.domain.model.Patient;
import pe.com.webservices.veterinaria.domain.repository.PatientRepository;
import pe.com.webservices.veterinaria.infrastructure.exception.ResourceNotFoundException;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PatientServiceImpl implements PatientService {

    private final PatientRepository patientRepository;

    @Override
    @Transactional(readOnly = true)
    public Page<PatientResponseDTO> getAllPatients(Pageable pageable) {
        return patientRepository.findAll(pageable).map(this::mapToResponseDTO);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<PatientResponseDTO> getPatientsByClient(UUID clientId, Pageable pageable) {
        return patientRepository.findByClientId(clientId, pageable).map(this::mapToResponseDTO);
    }

    @Override
    @Transactional(readOnly = true)
    public PatientResponseDTO getPatientById(UUID id) {
        Patient patient = patientRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Paciente no encontrado con el ID proporcionado."));
        return mapToResponseDTO(patient);
    }

    @Override
    @Transactional
    public PatientResponseDTO createPatient(PatientSaveDTO dto, UUID authenticatedUserId) {
        Patient patient = Patient.builder()
                .clientId(dto.getClientId())
                .name(dto.getName())
                .species(dto.getSpecies())
                .breed(dto.getBreed())
                .gender(dto.getGender())
                .dateOfBirth(dto.getDateOfBirth())
                .weight(dto.getWeight())
                .medicalNotes(dto.getMedicalNotes())
                .createdBy(authenticatedUserId)
                .updatedBy(authenticatedUserId)
                .build();

        Patient savedPatient = patientRepository.save(patient);
        return mapToResponseDTO(savedPatient);
    }

    @Override
    @Transactional
    public PatientResponseDTO updatePatient(UUID id, PatientSaveDTO dto, UUID authenticatedUserId) {
        Patient patient = patientRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Paciente no encontrado para actualizar."));

        patient.setName(dto.getName());
        patient.setSpecies(dto.getSpecies());
        patient.setBreed(dto.getBreed());
        patient.setGender(dto.getGender());
        patient.setDateOfBirth(dto.getDateOfBirth());
        patient.setWeight(dto.getWeight());
        patient.setMedicalNotes(dto.getMedicalNotes());
        patient.setUpdatedBy(authenticatedUserId);

        Patient updatedPatient = patientRepository.save(patient);
        return mapToResponseDTO(updatedPatient);
    }

    @Override
    @Transactional
    public void deletePatient(UUID id, UUID authenticatedUserId) {
        Patient patient = patientRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Paciente no encontrado para eliminar."));

        // Seteamos el usuario que ejecuta la eliminación lógica antes de lanzar el delete de JPA
        patient.setUpdatedBy(authenticatedUserId);
        patientRepository.saveAndFlush(patient);

        patientRepository.delete(patient);
    }

    private PatientResponseDTO mapToResponseDTO(Patient patient) {
        return PatientResponseDTO.builder()
                .id(patient.getId())
                .clientId(patient.getClientId())
                .name(patient.getName())
                .species(patient.getSpecies())
                .breed(patient.getBreed())
                .gender(patient.getGender())
                .dateOfBirth(patient.getDateOfBirth())
                .weight(patient.getWeight())
                .medicalNotes(patient.getMedicalNotes())
                .createdAt(patient.getCreatedAt())
                .updatedAt(patient.getUpdatedAt())
                .createdBy(patient.getCreatedBy())
                .updatedBy(patient.getUpdatedBy())
                .build();
    }

}