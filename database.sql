-- =============================================================
-- SISTEMA VETERINARIO - ESQUEMA Y ESTRUCTURA CENTRAL
-- Autor: Architect Vet-Fullstack
-- =============================================================

-- 1. CREACIÓN DEL ESQUEMA
CREATE SCHEMA IF NOT EXISTS veterinaria;

-- 2. FUNCIÓN DE AUDITORÍA (updated_at)
-- Se aloja dentro del esquema para mantener la encapsulación
CREATE OR REPLACE FUNCTION veterinaria.fn_update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

-- =============================================================
-- 3. TABLA: owners (Dueños)
-- =============================================================
CREATE TABLE veterinaria.owners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    -- Auditoría y Borrado Lógico
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    -- Constraints
    CONSTRAINT chk_owner_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE TRIGGER tr_owners_updated_at
BEFORE UPDATE ON veterinaria.owners
FOR EACH ROW EXECUTE FUNCTION veterinaria.fn_update_updated_at();

-- Índices parciales para optimizar búsquedas ignorando eliminados
CREATE INDEX idx_owners_search_name ON veterinaria.owners (last_name, first_name) WHERE is_active = TRUE;
CREATE INDEX idx_owners_active_status ON veterinaria.owners (is_active);

-- =============================================================
-- 4. TABLA: pets (Mascotas)
-- =============================================================
CREATE TABLE veterinaria.pets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL,
    name VARCHAR(100) NOT NULL,
    species VARCHAR(50) NOT NULL,
    breed VARCHAR(100),
    birth_date DATE,
    weight_kg DECIMAL(5,2),
    -- Auditoría y Borrado Lógico
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    -- Relaciones
    CONSTRAINT fk_pets_owner FOREIGN KEY (owner_id) 
        REFERENCES veterinaria.owners(id) ON DELETE RESTRICT
);

CREATE TRIGGER tr_pets_updated_at
BEFORE UPDATE ON veterinaria.pets
FOR EACH ROW EXECUTE FUNCTION veterinaria.fn_update_updated_at();

CREATE INDEX idx_pets_name_active ON veterinaria.pets (name) WHERE is_active = TRUE;
CREATE INDEX idx_pets_owner_id ON veterinaria.pets (owner_id);

-- =============================================================
-- 5. TABLA: appointments (Citas)
-- =============================================================
CREATE TABLE veterinaria.appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pet_id UUID NOT NULL,
    reason TEXT NOT NULL,
    scheduled_at TIMESTAMP WITH TIME ZONE NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDIENTE', -- PENDIENTE, EN_CURSO, COMPLETADA, CANCELADA
    notes TEXT,
    -- Auditoría y Borrado Lógico
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    -- Relaciones
    CONSTRAINT fk_appointments_pet FOREIGN KEY (pet_id) 
        REFERENCES veterinaria.pets(id) ON DELETE RESTRICT
);

CREATE TRIGGER tr_appointments_updated_at
BEFORE UPDATE ON veterinaria.appointments
FOR EACH ROW EXECUTE FUNCTION veterinaria.fn_update_updated_at();

CREATE INDEX idx_appointments_date ON veterinaria.appointments (scheduled_at);
CREATE INDEX idx_appointments_status_active ON veterinaria.appointments (status, is_active);

-- =============================================================
-- 6. TABLA: diagnoses (Diagnósticos / Historia Clínica)
-- =============================================
CREATE TABLE veterinaria.diagnoses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    appointment_id UUID NOT NULL,
    clinical_findings TEXT NOT NULL,
    main_diagnosis TEXT NOT NULL,
    treatment_plan TEXT NOT NULL,
    prescribed_medication TEXT,
    -- Auditoría y Borrado Lógico
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    -- Relaciones
    CONSTRAINT fk_diagnoses_appointment FOREIGN KEY (appointment_id) 
        REFERENCES veterinaria.appointments(id) ON DELETE RESTRICT
);

-- REGLA DE INMUTABILIDAD: No se permite modificar diagnósticos una vez creados.
CREATE OR REPLACE FUNCTION veterinaria.fn_prevent_diagnosis_update()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Regla de Negocio: Los diagnósticos clínicos son registros inmutables y no permiten modificaciones.';
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER tr_diagnoses_immutable
BEFORE UPDATE ON veterinaria.diagnoses
FOR EACH ROW EXECUTE FUNCTION veterinaria.fn_prevent_diagnosis_update();

CREATE INDEX idx_diagnoses_appointment_id ON veterinaria.diagnoses (appointment_id);

-- =============================================================
-- NOTAS DE IMPLEMENTACIÓN:
-- 1. Se ha forzado ON DELETE RESTRICT para evitar borrados accidentales en cascada.
-- 2. El borrado físico se reemplaza por 'is_active = false' en la capa de aplicación.
-- 3. Todos los objetos están encapsulados bajo el esquema 'veterinaria'.
-- =============================================================
								
-- =============================================================
-- TABLA: users (Usuarios del Sistema / Personal)
-- =============================================================
CREATE TABLE veterinaria.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL, -- ADMIN, VETERINARIAN, RECEPTIONIST
    -- Auditoría y Borrado Lógico (Heredado de BaseAudit)
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(150),
    updated_by VARCHAR(150),
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TRIGGER tr_users_updated_at
BEFORE UPDATE ON veterinaria.users
FOR EACH ROW EXECUTE FUNCTION veterinaria.fn_update_updated_at();

CREATE INDEX idx_users_email ON veterinaria.users(email) WHERE is_active = TRUE;