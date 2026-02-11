-- ============================================================
-- TABLAS PRINCIPALES
-- ============================================================
-- Tabla de Administradores
CREATE TABLE IF NOT EXISTS administradores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
-- Tabla de Empleados/Barberos
CREATE TABLE IF NOT EXISTS empleados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    cedula VARCHAR(20) UNIQUE NOT NULL,
    foto VARCHAR(255),
    activo BOOLEAN DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
-- Tabla de Servicios
CREATE TABLE IF NOT EXISTS servicios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    duracion INT DEFAULT 60 COMMENT 'DuraciÃ³n en minutos (siempre 60)',
    precio DECIMAL(10, 2) NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
-- Tabla de Horarios de trabajo de empleados
CREATE TABLE IF NOT EXISTS horarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empleado_id INT NOT NULL,
    dia_semana ENUM(
        'lunes',
        'martes',
        'miercoles',
        'jueves',
        'viernes',
        'sabado',
        'domingo'
    ) NOT NULL,
    hora_inicio TIME DEFAULT '10:00:00',
    hora_fin TIME DEFAULT '18:00:00',
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (empleado_id) REFERENCES empleados(id) ON DELETE CASCADE,
    UNIQUE KEY unique_empleado_dia (empleado_id, dia_semana)
);
-- Tabla de Bloqueos (vacaciones, dÃ­as libres)
CREATE TABLE IF NOT EXISTS bloqueos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empleado_id INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    motivo ENUM('vacaciones', 'dia_libre', 'otro') NOT NULL,
    descripcion TEXT,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empleado_id) REFERENCES empleados(id) ON DELETE CASCADE
);
-- Tabla de Citas
CREATE TABLE IF NOT EXISTS citas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_nombre VARCHAR(100) NOT NULL,
    cliente_cedula VARCHAR(20) NOT NULL,
    cliente_email VARCHAR(100) NOT NULL,
    cliente_telefono VARCHAR(20) NOT NULL,
    servicio_id INT NOT NULL,
    empleado_id INT NOT NULL,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    estado ENUM(
        'pendiente',
        'confirmada',
        'cancelada',
        'completada'
    ) DEFAULT 'pendiente',
    recordatorio_enviado BOOLEAN DEFAULT FALSE,
    email_confirmacion_enviado BOOLEAN DEFAULT FALSE,
    email_recibo_enviado BOOLEAN DEFAULT FALSE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (servicio_id) REFERENCES servicios(id),
    FOREIGN KEY (empleado_id) REFERENCES empleados(id),
    UNIQUE KEY unique_cita (empleado_id, fecha, hora)
);
-- Tabla de dÃ­as festivos
CREATE TABLE IF NOT EXISTS dias_festivos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE UNIQUE NOT NULL,
    descripcion VARCHAR(100) NOT NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Tabla de Ventas (registro de ingresos por cita completada)
CREATE TABLE IF NOT EXISTS ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cita_id INT NOT NULL,
    empleado_id INT NOT NULL,
    servicio_id INT NOT NULL,
    fecha DATE NOT NULL,
    monto DECIMAL(10, 2) NOT NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cita_id) REFERENCES citas(id) ON DELETE CASCADE,
    FOREIGN KEY (empleado_id) REFERENCES empleados(id),
    FOREIGN KEY (servicio_id) REFERENCES servicios(id),
    UNIQUE KEY unique_venta_cita (cita_id)
);
-- ============================================================
-- ÃNDICES PARA OPTIMIZACIÃ“N
-- ============================================================
CREATE INDEX idx_citas_fecha ON citas(fecha);
CREATE INDEX idx_citas_estado ON citas(estado);
CREATE INDEX idx_citas_empleado ON citas(empleado_id);
CREATE INDEX idx_bloqueos_fechas ON bloqueos(fecha_inicio, fecha_fin);
CREATE INDEX idx_dias_festivos_fecha ON dias_festivos(fecha);
CREATE INDEX idx_ventas_fecha ON ventas(fecha);
CREATE INDEX idx_ventas_empleado ON ventas(empleado_id);
-- ============================================================
-- DATOS INICIALES
-- ============================================================
-- Administrador por defecto
-- Usuario: admin
-- ContraseÃ±a: admin123 (hasheado con bcrypt)
INSERT INTO administradores (usuario, password, nombre, email)
VALUES (
        'admin',
        '$2b$10$UuTvgUGo3c7gNOdrVNjPa.DiA0vB3b4Hxb4WN9ye6FCNS.lhy1ruG',
        'Administrador Principal',
        'admin@barberia.com'
    ) ON DUPLICATE KEY
UPDATE password = '$2b$10$UuTvgUGo3c7gNOdrVNjPa.DiA0vB3b4Hxb4WN9ye6FCNS.lhy1ruG';
-- Empleados de ejemplo
INSERT INTO empleados (nombre, cedula, foto)
VALUES ('Carlos RodrÃ­guez', '1234567890', 'carlos.jpg'),
    (
        'Miguel Ãngel Torres',
        '0987654321',
        'miguel.jpg'
    ),
    ('Juan Pablo GÃ³mez', '1122334455', 'juan.jpg') ON DUPLICATE KEY
UPDATE nombre =
VALUES(nombre);
-- Servicios de ejemplo
INSERT INTO servicios (nombre, descripcion, precio)
VALUES (
        'Corte de Cabello',
        'Corte de cabello clÃ¡sico con mÃ¡quina y tijera. Incluye shampoo y masaje capilar relajante',
        25000.00
    ),
    (
        'Corte + Barba',
        'Corte de cabello mÃ¡s arreglo de barba completo. Incluye shampoo y masaje capilar relajante',
        40000.00
    ),
    (
        'Afeitado ClÃ¡sico',
        'Afeitado tradicional con navaja, vapor facial, toalla caliente y aceites esenciales para un acabado suave y refrescante',
        30000.00
    ),
    (
        'Corte Infantil',
        'Corte de cabello para niÃ±os hasta 12 aÃ±os. Incluye shampoo y masaje capilar relajante',
        20000.00
    ),
    (
        'DiseÃ±o de Barba',
        'DiseÃ±o y perfilado de barba con tÃ©cnicas profesionales',
        25000.00
    ) ON DUPLICATE KEY
UPDATE descripcion =
VALUES(descripcion),
    precio =
VALUES(precio);
-- Horarios de trabajo (Lunes a SÃ¡bado para todos los barberos)
INSERT INTO horarios (empleado_id, dia_semana, hora_inicio, hora_fin)
VALUES -- Carlos
    (1, 'lunes', '10:00:00', '18:00:00'),
    (1, 'martes', '10:00:00', '18:00:00'),
    (1, 'miercoles', '10:00:00', '18:00:00'),
    (1, 'jueves', '10:00:00', '18:00:00'),
    (1, 'viernes', '10:00:00', '18:00:00'),
    (1, 'sabado', '10:00:00', '18:00:00'),
    -- Miguel
    (2, 'lunes', '10:00:00', '18:00:00'),
    (2, 'martes', '10:00:00', '18:00:00'),
    (2, 'miercoles', '10:00:00', '18:00:00'),
    (2, 'jueves', '10:00:00', '18:00:00'),
    (2, 'viernes', '10:00:00', '18:00:00'),
    (2, 'sabado', '10:00:00', '18:00:00'),
    -- Juan
    (3, 'lunes', '10:00:00', '18:00:00'),
    (3, 'martes', '10:00:00', '18:00:00'),
    (3, 'miercoles', '10:00:00', '18:00:00'),
    (3, 'jueves', '10:00:00', '18:00:00'),
    (3, 'viernes', '10:00:00', '18:00:00'),
    (3, 'sabado', '10:00:00', '18:00:00') ON DUPLICATE KEY
UPDATE hora_inicio =
VALUES(hora_inicio),
    hora_fin =
VALUES(hora_fin);
SELECT COUNT(*) AS total_empleados
FROM empleados;
SELECT COUNT(*) AS total_servicios
FROM servicios;
SELECT COUNT(*) AS total_horarios
FROM horarios;
-- Días festivos de Argentina 2025
INSERT INTO dias_festivos (fecha, descripcion)
VALUES ('2025-01-01', 'Año Nuevo'),
    ('2025-03-03', 'Carnaval'),
    ('2025-03-04', 'Carnaval'),
    (
        '2025-03-24',
        'Día Nacional de la Memoria por la Verdad y la Justicia'
    ),
    (
        '2025-04-02',
        'Día del Veterano y de los Caídos en la Guerra de Malvinas'
    ),
    ('2025-04-18', 'Viernes Santo'),
    ('2025-05-01', 'Día del Trabajador'),
    ('2025-05-25', 'Día de la Revolución de Mayo'),
    (
        '2025-06-16',
        'Paso a la Inmortalidad del Gral. Güemes'
    ),
    (
        '2025-06-20',
        'Paso a la Inmortalidad del Gral. Manuel Belgrano'
    ),
    ('2025-07-09', 'Día de la Independencia'),
    (
        '2025-08-15',
        'Paso a la Inmortalidad del Gral. José de San Martín'
    ),
    (
        '2025-10-13',
        'Día del Respeto a la Diversidad Cultural'
    ),
    ('2025-11-20', 'Día de la Soberanía Nacional'),
    (
        '2025-12-08',
        'Día de la Inmaculada Concepción de María'
    ),
    ('2025-12-25', 'Navidad') ON DUPLICATE KEY
UPDATE descripcion =
VALUES(descripcion);
SELECT COUNT(*) AS total_dias_festivos
FROM dias_festivos;
-- ============================================================
-- INSTRUCCIONES DE USO
-- ============================================================
-- 1. Ejecutar este script completo en MySQL
-- 2. Usuario administrador por defecto:
--    Usuario: admin
--    ContraseÃ±a: admin123
-- 3. Configurar .env en el backend con las credenciales de MySQL
-- 4. Iniciar el servidor backend: npm start
-- 5. Iniciar el frontend: npm run dev
-- ============================================================