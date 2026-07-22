-- =================================================================================
-- VET SYSTEM DATABASE SCHEMA - V2 (Con Soft Delete, Auditoría Total y Seeders)
-- Motor: PostgreSQL
-- Arquitectura: Relacional Normalizada con UUIDs
-- =================================================================================

-- Habilitar la extensión para generar UUIDs de forma nativa
--CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================
-- 1. CREACIÓN DE TABLAS BASE
-- ==========================================

CREATE TABLE veterinaria.roles (
                                   id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                                   name VARCHAR(50) UNIQUE NOT NULL,
                                   description VARCHAR(255),
                                   is_active BOOLEAN DEFAULT TRUE,
                                   deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
                                   created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                   updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                   created_by UUID, -- FK agregada más adelante
                                   updated_by UUID  -- FK agregada más adelante
);

CREATE TABLE veterinaria.users (
                                   id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                                   role_id UUID NOT NULL,
                                   first_name VARCHAR(100) NOT NULL,
                                   last_name VARCHAR(100) NOT NULL,
                                   email VARCHAR(255) UNIQUE NOT NULL,
                                   password_hash VARCHAR(255) NOT NULL,
                                   is_active BOOLEAN DEFAULT TRUE,
                                   deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
                                   created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                   updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                   created_by UUID,
                                   updated_by UUID,
                                   FOREIGN KEY (role_id) REFERENCES veterinaria.roles(id) ON DELETE RESTRICT,
                                   FOREIGN KEY (created_by) REFERENCES veterinaria.users(id) ON DELETE SET NULL,
                                   FOREIGN KEY (updated_by) REFERENCES veterinaria.users(id) ON DELETE SET NULL
);

-- Ahora que `users` existe, agregamos las constraints de auditoría a `roles`
ALTER TABLE veterinaria.roles ADD CONSTRAINT fk_roles_created_by FOREIGN KEY (created_by) REFERENCES veterinaria.users(id) ON DELETE SET NULL;
ALTER TABLE veterinaria.roles ADD CONSTRAINT fk_roles_updated_by FOREIGN KEY (updated_by) REFERENCES veterinaria.users(id) ON DELETE SET NULL;

CREATE TABLE veterinaria.clients (
                                     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                                     user_id UUID UNIQUE,
                                     first_name VARCHAR(100) NOT NULL,
                                     last_name VARCHAR(100) NOT NULL,
                                     document_number VARCHAR(50) UNIQUE NOT NULL,
                                     email VARCHAR(255) UNIQUE NOT NULL,
                                     phone VARCHAR(20),
                                     address TEXT,
                                     is_active BOOLEAN DEFAULT TRUE,
                                     deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
                                     created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                     updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                     created_by UUID,
                                     updated_by UUID,
                                     FOREIGN KEY (user_id) REFERENCES veterinaria.users(id) ON DELETE SET NULL,
                                     FOREIGN KEY (created_by) REFERENCES veterinaria.users(id) ON DELETE SET NULL,
                                     FOREIGN KEY (updated_by) REFERENCES veterinaria.users(id) ON DELETE SET NULL
);

CREATE TABLE veterinaria.patients (
                                      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                                      client_id UUID NOT NULL,
                                      name VARCHAR(100) NOT NULL,
                                      species VARCHAR(50) NOT NULL,
                                      breed VARCHAR(100),
                                      gender VARCHAR(20) CHECK (gender IN ('MALE', 'FEMALE', 'UNKNOWN')),
                                      date_of_birth DATE,
                                      weight DECIMAL(5,2) CHECK (weight > 0),
                                      medical_notes TEXT,
                                      is_active BOOLEAN DEFAULT TRUE,
                                      deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
                                      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                      updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                      created_by UUID,
                                      updated_by UUID,
                                      FOREIGN KEY (client_id) REFERENCES veterinaria.clients(id) ON DELETE CASCADE,
                                      FOREIGN KEY (created_by) REFERENCES veterinaria.users(id) ON DELETE SET NULL,
                                      FOREIGN KEY (updated_by) REFERENCES veterinaria.users(id) ON DELETE SET NULL
);

CREATE TABLE veterinaria.appointments (
                                          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                                          patient_id UUID NOT NULL,
                                          veterinarian_id UUID NOT NULL,
                                          receptionist_id UUID,
                                          appointment_date TIMESTAMP WITH TIME ZONE NOT NULL,
                                          reason VARCHAR(255) NOT NULL,
                                          status VARCHAR(50) DEFAULT 'SCHEDULED' CHECK (status IN ('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
                                          notes TEXT,
                                          is_active BOOLEAN DEFAULT TRUE,
                                          deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
                                          created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                          updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                          created_by UUID,
                                          updated_by UUID,
                                          FOREIGN KEY (patient_id) REFERENCES veterinaria.patients(id) ON DELETE CASCADE,
                                          FOREIGN KEY (veterinarian_id) REFERENCES veterinaria.users(id) ON DELETE RESTRICT,
                                          FOREIGN KEY (receptionist_id) REFERENCES veterinaria.users(id) ON DELETE SET NULL,
                                          FOREIGN KEY (created_by) REFERENCES veterinaria.users(id) ON DELETE SET NULL,
                                          FOREIGN KEY (updated_by) REFERENCES veterinaria.users(id) ON DELETE SET NULL
);

CREATE TABLE veterinaria.medical_records (
                                             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                                             patient_id UUID NOT NULL,
                                             veterinarian_id UUID NOT NULL,
                                             appointment_id UUID,
                                             diagnosis TEXT NOT NULL,
                                             treatment TEXT NOT NULL,
                                             internal_notes TEXT,
                                             is_active BOOLEAN DEFAULT TRUE,
                                             deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
                                             created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                             updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                             created_by UUID,
                                             updated_by UUID,
                                             FOREIGN KEY (patient_id) REFERENCES veterinaria.patients(id) ON DELETE CASCADE,
                                             FOREIGN KEY (veterinarian_id) REFERENCES veterinaria.users(id) ON DELETE RESTRICT,
                                             FOREIGN KEY (appointment_id) REFERENCES veterinaria.appointments(id) ON DELETE SET NULL,
                                             FOREIGN KEY (created_by) REFERENCES veterinaria.users(id) ON DELETE SET NULL,
                                             FOREIGN KEY (updated_by) REFERENCES veterinaria.users(id) ON DELETE SET NULL
);

CREATE TABLE veterinaria.prescriptions (
                                           id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                                           medical_record_id UUID NOT NULL,
                                           medication_name VARCHAR(200) NOT NULL,
                                           dosage VARCHAR(100) NOT NULL,
                                           frequency VARCHAR(100) NOT NULL,
                                           duration VARCHAR(100) NOT NULL,
                                           special_instructions TEXT,
                                           is_active BOOLEAN DEFAULT TRUE,
                                           deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
                                           created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                           updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                           created_by UUID,
                                           updated_by UUID,
                                           FOREIGN KEY (medical_record_id) REFERENCES veterinaria.medical_records(id) ON DELETE CASCADE,
                                           FOREIGN KEY (created_by) REFERENCES veterinaria.users(id) ON DELETE SET NULL,
                                           FOREIGN KEY (updated_by) REFERENCES veterinaria.users(id) ON DELETE SET NULL
);

CREATE TABLE veterinaria.product_categories (
                                                id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                                                name VARCHAR(100) UNIQUE NOT NULL,
                                                description TEXT,
                                                is_active BOOLEAN DEFAULT TRUE,
                                                deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
                                                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                                updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                                created_by UUID,
                                                updated_by UUID,
                                                FOREIGN KEY (created_by) REFERENCES veterinaria.users(id) ON DELETE SET NULL,
                                                FOREIGN KEY (updated_by) REFERENCES veterinaria.users(id) ON DELETE SET NULL
);

CREATE TABLE veterinaria.products (
                                      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                                      category_id UUID NOT NULL,
                                      sku VARCHAR(50) UNIQUE NOT NULL,
                                      name VARCHAR(200) NOT NULL,
                                      description TEXT,
                                      price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
                                      stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
                                      min_stock_level INTEGER NOT NULL DEFAULT 5,
                                      is_active BOOLEAN DEFAULT TRUE,
                                      deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
                                      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                      updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                      created_by UUID,
                                      updated_by UUID,
                                      FOREIGN KEY (category_id) REFERENCES veterinaria.product_categories(id) ON DELETE RESTRICT,
                                      FOREIGN KEY (created_by) REFERENCES veterinaria.users(id) ON DELETE SET NULL,
                                      FOREIGN KEY (updated_by) REFERENCES veterinaria.users(id) ON DELETE SET NULL
);

CREATE TABLE veterinaria.invoices (
                                      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                                      client_id UUID NOT NULL,
                                      cashier_id UUID NOT NULL,
                                      issue_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                      subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
                                      tax_amount DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (tax_amount >= 0),
                                      total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
                                      status VARCHAR(50) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'PAID', 'CANCELLED')),
                                      payment_method VARCHAR(50),
                                      is_active BOOLEAN DEFAULT TRUE,
                                      deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
                                      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                      updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                      created_by UUID,
                                      updated_by UUID,
                                      FOREIGN KEY (client_id) REFERENCES veterinaria.clients(id) ON DELETE RESTRICT,
                                      FOREIGN KEY (cashier_id) REFERENCES veterinaria.users(id) ON DELETE RESTRICT,
                                      FOREIGN KEY (created_by) REFERENCES veterinaria.users(id) ON DELETE SET NULL,
                                      FOREIGN KEY (updated_by) REFERENCES veterinaria.users(id) ON DELETE SET NULL
);

-- Los detalles de factura son inmutables por naturaleza contable. Si se anula la factura, su estado cambia, no se hace soft delete a la línea.
CREATE TABLE veterinaria.invoice_details (
                                             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                                             invoice_id UUID NOT NULL,
                                             product_id UUID,
                                             description VARCHAR(200) NOT NULL,
                                             quantity INTEGER NOT NULL CHECK (quantity > 0),
                                             unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
                                             line_total DECIMAL(10,2) NOT NULL CHECK (line_total >= 0),
                                             FOREIGN KEY (invoice_id) REFERENCES veterinaria.invoices(id) ON DELETE CASCADE,
                                             FOREIGN KEY (product_id) REFERENCES veterinaria.products(id) ON DELETE SET NULL
);

-- ==========================================
-- 2. ÍNDICES DE RENDIMIENTO (Performance)
-- ==========================================

-- Índices cruciales para acelerar las consultas que filtran datos borrados
CREATE INDEX idx_users_active ON veterinaria.users(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_patients_active ON veterinaria.patients(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_appointments_active ON veterinaria.appointments(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_products_active ON veterinaria.products(is_active) WHERE is_active = TRUE;

-- Búsquedas de negocio
CREATE INDEX idx_users_email ON veterinaria.users(email);
CREATE INDEX idx_clients_document ON veterinaria.clients(document_number);
CREATE INDEX idx_appointments_date ON veterinaria.appointments(appointment_date);
CREATE INDEX idx_products_sku ON veterinaria.products(sku);

-- ==========================================
-- 3. DATOS DE PRUEBA (SEEDERS) CORREGIDOS
-- Rango hexadecimal válido garantizado (0-9, a-f)
-- ==========================================

-- ROLES
INSERT INTO veterinaria.roles (id, name, description) VALUES
                                                          ('11111111-1111-1111-1111-111111111111', 'ADMIN', 'Control total del sistema'),
                                                          ('22222222-2222-2222-2222-222222222222', 'VETERINARIO', 'Acceso a módulo clínico'),
                                                          ('33333333-3333-3333-3333-333333333333', 'RECEPCIONISTA', 'Caja, citas y clientes');

-- USUARIOS (Pass: 'admin123' hasheado con bcrypt)
INSERT INTO veterinaria.users (id, role_id, first_name, last_name, email, password_hash) VALUES
                                                                                             ('aaaa0000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'Super', 'Admin', 'admin@vet.com', '$2a$10$Xb...'),
                                                                                             ('aaaa0000-0000-0000-0000-000000000002', '22222222-2222-2222-2222-222222222222', 'Dr. Carlos', 'Mendoza', 'carlos.vet@vet.com', '$2a$10$Xb...'),
                                                                                             ('aaaa0000-0000-0000-0000-000000000003', '33333333-3333-3333-3333-333333333333', 'Ana', 'Lopez', 'recepcion@vet.com', '$2a$10$Xb...');

-- CLIENTES
INSERT INTO veterinaria.clients (id, first_name, last_name, document_number, email, phone, address, created_by) VALUES
                                                                                                                    ('bbbb0000-0000-0000-0000-000000000001', 'Juan', 'Perez', '12345678', 'juan.perez@email.com', '987654321', 'Av. Siempre Viva 123', 'aaaa0000-0000-0000-0000-000000000003'),
                                                                                                                    ('bbbb0000-0000-0000-0000-000000000002', 'Maria', 'Gomez', '87654321', 'maria.g@email.com', '912345678', 'Calle Falsa 456', 'aaaa0000-0000-0000-0000-000000000003');

-- PACIENTES (Mascotas)
INSERT INTO veterinaria.patients (id, client_id, name, species, breed, gender, date_of_birth, weight, created_by) VALUES
                                                                                                                      ('cccc0000-0000-0000-0000-000000000001', 'bbbb0000-0000-0000-0000-000000000001', 'Firulais', 'Canino', 'Mestizo', 'MALE', '2020-05-10', 12.5, 'aaaa0000-0000-0000-0000-000000000003'),
                                                                                                                      ('cccc0000-0000-0000-0000-000000000002', 'bbbb0000-0000-0000-0000-000000000001', 'Michi', 'Felino', 'Siamés', 'FEMALE', '2021-08-15', 4.2, 'aaaa0000-0000-0000-0000-000000000003'),
                                                                                                                      ('cccc0000-0000-0000-0000-000000000003', 'bbbb0000-0000-0000-0000-000000000002', 'Rocky', 'Canino', 'Bulldog', 'MALE', '2019-12-01', 22.0, 'aaaa0000-0000-0000-0000-000000000003');

-- CITAS MÉDICAS (AgendaView)
INSERT INTO veterinaria.appointments (id, patient_id, veterinarian_id, receptionist_id, appointment_date, reason, status, created_by) VALUES
                                                                                                                                          ('dddd0000-0000-0000-0000-000000000001', 'cccc0000-0000-0000-0000-000000000001', 'aaaa0000-0000-0000-0000-000000000002', 'aaaa0000-0000-0000-0000-000000000003', CURRENT_TIMESTAMP + INTERVAL '1 day', 'Vacunación Anual', 'SCHEDULED', 'aaaa0000-0000-0000-0000-000000000003'),
                                                                                                                                          ('dddd0000-0000-0000-0000-000000000002', 'cccc0000-0000-0000-0000-000000000003', 'aaaa0000-0000-0000-0000-000000000002', 'aaaa0000-0000-0000-0000-000000000003', CURRENT_TIMESTAMP - INTERVAL '2 days', 'Control Dermatológico', 'COMPLETED', 'aaaa0000-0000-0000-0000-000000000003');

-- HISTORIALES CLÍNICOS
INSERT INTO veterinaria.medical_records (id, patient_id, veterinarian_id, appointment_id, diagnosis, treatment, created_by) VALUES
    ('eeee0000-0000-0000-0000-000000000001', 'cccc0000-0000-0000-0000-000000000003', 'aaaa0000-0000-0000-0000-000000000002', 'dddd0000-0000-0000-0000-000000000002', 'Dermatitis atópica severa', 'Baños medicados y antibióticos', 'aaaa0000-0000-0000-0000-000000000002');

-- INVENTARIO (Categorías y Productos para POSCatalog)
INSERT INTO veterinaria.product_categories (id, name, description) VALUES
                                                                       ('ffff0000-0000-0000-0000-000000000001', 'Alimentos', 'Croquetas y comida húmeda'),
                                                                       ('ffff0000-0000-0000-0000-000000000002', 'Medicamentos', 'Fármacos de uso veterinario');

-- (CORRECCIÓN APLICADA: '7777...' en lugar de 'gggg...')
INSERT INTO veterinaria.products (id, category_id, sku, name, price, stock_quantity, created_by) VALUES
                                                                                                     ('77770000-0000-0000-0000-000000000001', 'ffff0000-0000-0000-0000-000000000001', 'ALIM-001', 'Dog Chow Adultos 15kg', 120.50, 25, 'aaaa0000-0000-0000-0000-000000000001'),
                                                                                                     ('77770000-0000-0000-0000-000000000002', 'ffff0000-0000-0000-0000-000000000002', 'MED-001', 'Bravecto 10-20kg', 85.00, 10, 'aaaa0000-0000-0000-0000-000000000001');

-- FACTURACIÓN (POSCart / BillingDashboard)
-- (CORRECCIÓN APLICADA: '8888...' en lugar de 'hhhh...')
INSERT INTO veterinaria.invoices (id, client_id, cashier_id, subtotal, tax_amount, total_amount, status, payment_method, created_by) VALUES
    ('88880000-0000-0000-0000-000000000001', 'bbbb0000-0000-0000-0000-000000000001', 'aaaa0000-0000-0000-0000-000000000003', 102.12, 18.38, 120.50, 'PAID', 'TARJETA_CREDITO', 'aaaa0000-0000-0000-0000-000000000003');

-- (CORRECCIÓN APLICADA: '9999...' en lugar de 'iiii...')
INSERT INTO veterinaria.invoice_details (id, invoice_id, product_id, description, quantity, unit_price, line_total) VALUES
    ('99990000-0000-0000-0000-000000000001', '88880000-0000-0000-0000-000000000001', '77770000-0000-0000-0000-000000000001', 'Dog Chow Adultos 15kg', 1, 120.50, 120.50);