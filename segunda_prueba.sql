-- Base de datos
DROP DATABASE IF EXISTS banco_nacion;
CREATE DATABASE banco_nacion;
USE banco_nacion;

-- 1. Usuarios
CREATE TABLE usuarios (
    dni VARCHAR(8) PRIMARY KEY,
    nombre VARCHAR(100),
    clave_digital CHAR(6),
    serie_tarjeta VARCHAR(50)
);
CREATE TABLE ocupaciones_usuario (
    id_ocupacion INT PRIMARY KEY AUTO_INCREMENT,
    dni VARCHAR(8),
    ocupacion VARCHAR(100),
    FOREIGN KEY (dni) REFERENCES usuarios(dni)
);
CREATE TABLE contacto (
    id_contacto INT PRIMARY KEY AUTO_INCREMENT,
    dni VARCHAR(8),
    correo VARCHAR(100),
    celular CHAR(9),
    FOREIGN KEY (dni) REFERENCES usuarios(dni)
);
CREATE TABLE direccion_usuario (
    id_direccion INT PRIMARY KEY AUTO_INCREMENT,
    dni VARCHAR(8),
    departamento VARCHAR(100),
    provincia VARCHAR(100),
    distrito VARCHAR(100),
    direccion VARCHAR(255),
    FOREIGN KEY (dni) REFERENCES usuarios(dni)
);

-- 2. Cuentas
CREATE TABLE cuentas (
    num_cuenta VARCHAR(11) PRIMARY KEY ,
    dni VARCHAR(8),
    cci VARCHAR(20) UNIQUE,
    saldo DECIMAL(12,2) DEFAULT 0.00,
    FOREIGN KEY (dni) REFERENCES usuarios(dni)
);

-- 3. Historial de operaciones
CREATE TABLE historial (
    id_historial INT PRIMARY KEY AUTO_INCREMENT,
    num_cuenta VARCHAR(11),
    tipo_operacion varchar(30),
    descripcion TEXT,
    monto DECIMAL(12,2),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (num_cuenta) REFERENCES cuentas(num_cuenta)
);

-- 4. Bancos
CREATE TABLE bancos (
    id_banco INT PRIMARY KEY AUTO_INCREMENT,
    nombre_banco VARCHAR(100) NOT NULL
);

-- 5. Banco-Celular
CREATE TABLE banco_celular (
    id INT PRIMARY KEY AUTO_INCREMENT,
    celular CHAR(9),
    id_banco INT,
    FOREIGN KEY (id_banco) REFERENCES bancos(id_banco)
);

-- 6. CCI afiliados
CREATE TABLE cci_afiliados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cci VARCHAR(20) UNIQUE,
    id_banco INT,
    FOREIGN KEY (id_banco) REFERENCES bancos(id_banco)
);

-- 7. Transferencias por celular
CREATE TABLE transferencias_celular (
    id_transferencia INT PRIMARY KEY AUTO_INCREMENT,
    num_cuenta_origen VARCHAR(11),
    celular_destino CHAR(9),
    id_banco_destino INT,
    monto DECIMAL(12,2),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (num_cuenta_origen) REFERENCES cuentas(num_cuenta),
    FOREIGN KEY (id_banco_destino) REFERENCES bancos(id_banco)
);

-- 8. Giros
CREATE TABLE giros (
    id_giro INT PRIMARY KEY AUTO_INCREMENT,
    num_cuenta_origen VARCHAR(11),
    dni_destino CHAR(8),
    id_banco_destino INT,
    monto DECIMAL(12,2),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (num_cuenta_origen) REFERENCES cuentas(num_cuenta),
    FOREIGN KEY (id_banco_destino) REFERENCES bancos(id_banco)
);

-- 9. Transferencias por cuenta
CREATE TABLE transferencias_cuentas (
    id_transferencia INT PRIMARY KEY AUTO_INCREMENT,
    num_cuenta_origen VARCHAR(11),
    numero_cuenta_destino VARCHAR(13),  -- solo para cuentas internas
    id_banco_destino INT,
    descripcion text,
    monto DECIMAL(12,2),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (num_cuenta_origen) REFERENCES cuentas(num_cuenta),
    FOREIGN KEY (id_banco_destino) REFERENCES bancos(id_banco)
);

CREATE TABLE transferencias_cci (
    id_transferencia INT PRIMARY KEY AUTO_INCREMENT,
    num_cuenta_origen VARCHAR(11),
    destino VARCHAR(20),
    id_banco_destino INT,
    descripcion text,
    monto DECIMAL(12,2),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (num_cuenta_origen) REFERENCES cuentas(num_cuenta),
    FOREIGN KEY (id_banco_destino) REFERENCES bancos(id_banco)
);

-- 10. Empresas de servicios (agua, luz, telefonía)
CREATE TABLE empresas_servicios (
    id_empresa INT PRIMARY KEY AUTO_INCREMENT,
    nombre_empresa VARCHAR(100) NOT NULL,
    tipo_servicio ENUM('AGUA', 'LUZ', 'TELEFONIA') NOT NULL
);

-- 11. Deudas de servicios unificadas
CREATE TABLE deudas_servicios (
    id_deuda INT PRIMARY KEY AUTO_INCREMENT,
    tipo_servicio ENUM('AGUA', 'LUZ', 'TELEFONIA') NOT NULL,
    id_empresa INT NOT NULL,
    codigo_pago VARCHAR(50),
    monto DECIMAL(12,2),
    FOREIGN KEY (id_empresa) REFERENCES empresas_servicios(id_empresa)
);

-- 12. Pagos de servicios
CREATE TABLE pago_servicios (
    id_pago INT PRIMARY KEY AUTO_INCREMENT,
    num_cuenta VARCHAR(11) NOT NULL,
    id_deuda INT NOT NULL,
    fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (num_cuenta) REFERENCES cuentas(num_cuenta),
    FOREIGN KEY (id_deuda) REFERENCES deudas_servicios(id_deuda)
);


CREATE TABLE empresas_recargas (
    id_empresa INT PRIMARY KEY AUTO_INCREMENT,
    nombre_empresa VARCHAR(100) NOT NULL
);
-- 14. Recargas
CREATE TABLE recargas (
    id_recarga INT PRIMARY KEY AUTO_INCREMENT,
    num_cuenta VARCHAR(11),
    id_empresa INT,
    numero CHAR(9),
    monto DECIMAL(12,2),
    fecha_recarga TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (num_cuenta) REFERENCES cuentas(num_cuenta),
    FOREIGN KEY (id_empresa) REFERENCES empresas_recargas(id_empresa)
);


-- 15. Ubicación de bancos
CREATE TABLE ubicaciones_banco (
    id_ubicacion INT PRIMARY KEY AUTO_INCREMENT,
    provincia VARCHAR(100),
    direccion VARCHAR(255)
);

-- 16. Ubicación por usuario
CREATE TABLE ubicacion_usuario (
    id INT PRIMARY KEY AUTO_INCREMENT,
    dni VARCHAR(8),
    id_ubicacion INT,
    FOREIGN KEY (dni) REFERENCES usuarios(dni),
    FOREIGN KEY (id_ubicacion) REFERENCES ubicaciones_banco(id_ubicacion)
);

DELIMITER //

CREATE TRIGGER crear_cuenta_con_cci
AFTER INSERT ON usuarios
FOR EACH ROW
BEGIN
    DECLARE ultimos_6_dni CHAR(6);
    DECLARE numero_cuenta VARCHAR(20);
    DECLARE cci_generado CHAR(20);
    DECLARE codigo_entidad CHAR(3) DEFAULT '009';  -- BBVA Perú (ejemplo)
    DECLARE codigo_oficina CHAR(3) DEFAULT '661';  -- Sucursal (ejemplo)
    DECLARE parte_cuenta CHAR(12);  -- Se llenará con dni y ceros
    DECLARE digitos_control CHAR(2) DEFAULT '01'; -- Simulado
    -- Tomar últimos 6 dígitos del DNI
    SET ultimos_6_dni = RIGHT(NEW.dni, 6);
    -- Crear número de cuenta en formato: 04-000-XXXXXX
    SET numero_cuenta = CONCAT('04000', ultimos_6_dni);
    -- Parte media del CCI: aquí se usa el DNI rellenado a 12 dígitos
    SET parte_cuenta = LPAD(NEW.dni, 12, '0');
    -- Armar CCI completo (20 dígitos)
    SET cci_generado = CONCAT(codigo_entidad, codigo_oficina, parte_cuenta, digitos_control);
    -- Insertar en cuentas
    INSERT INTO cuentas (num_cuenta, dni, cci, saldo)
    VALUES (
        numero_cuenta,
        new.dni,
        cci_generado,
        0.00
    );
END;
//

DELIMITER ;

select * from usuarios;
INSERT INTO usuarios VALUES ('12345678', 'Ana Rivera', 'Ingeniera', 'Calle Falsa 123', 'ana@example.com', '987123456', 'Movistar', '654321', 'TAR654321');
select * from cuentas;
