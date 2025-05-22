DROP DATABASE IF EXISTS banco;
CREATE DATABASE IF NOT EXISTS banco;
USE banco;

-- 1. Usuarios
CREATE TABLE usuarios (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    dni CHAR(8) UNIQUE NOT NULL,
    nombre VARCHAR(100),
    direccion VARCHAR(255),
    correo VARCHAR(100),
    celular CHAR(9),
    clave_digital CHAR(6),
    codigo_tarjeta VARCHAR(50)
);

-- 2. Bancos (solo para transferencias y giros a otros bancos)
CREATE TABLE bancos (
    id_banco INT PRIMARY KEY AUTO_INCREMENT,
    nombre_banco VARCHAR(100) NOT NULL
);

-- 3. Cuentas (asumimos que todas son del Banco de la Nación)
CREATE TABLE cuentas (
    id_cuenta INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT,
    cci VARCHAR(20) UNIQUE,
    saldo DECIMAL(12,2) DEFAULT 0.00,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);

-- 4. Historial de operaciones
CREATE TABLE historial (
    id_historial INT PRIMARY KEY AUTO_INCREMENT,
    id_cuenta INT,
    tipo_operacion ENUM('GIRO', 'TRANSFERENCIA', 'PAGO_SERVICIO', 'RECARGA'),
    descripcion TEXT,
    monto DECIMAL(12,2),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cuenta) REFERENCES cuentas(id_cuenta)
);

-- 5. Celulares afiliados a bancos
CREATE TABLE celulares_afiliados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    celular CHAR(9),
    id_banco INT,
    id_usuario INT,
    FOREIGN KEY (id_banco) REFERENCES bancos(id_banco),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);

-- 6. CCI afiliados a bancos
CREATE TABLE cci_afiliados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cci VARCHAR(20),
    id_banco INT,
    id_usuario INT,
    FOREIGN KEY (id_banco) REFERENCES bancos(id_banco),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);

-- 7. Giros (con DNI del destinatario y banco destino)
CREATE TABLE giros (
    id_giro INT PRIMARY KEY AUTO_INCREMENT,
    id_cuenta_origen INT,
    dni_destino CHAR(8),
    id_banco_destino INT,
    monto DECIMAL(12,2),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cuenta_origen) REFERENCES cuentas(id_cuenta),
    FOREIGN KEY (id_banco_destino) REFERENCES bancos(id_banco)
);

-- 8. Transferencias (unificadas: por celular o CCI)
CREATE TABLE transferencias (
    id_transferencia INT PRIMARY KEY AUTO_INCREMENT,
    id_cuenta_origen INT,
    tipo_destino ENUM('CELULAR', 'CCI') NOT NULL,
    destino VARCHAR(20) NOT NULL, -- celular o cci
    id_banco_destino INT,
    monto DECIMAL(12,2),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cuenta_origen) REFERENCES cuentas(id_cuenta),
    FOREIGN KEY (id_banco_destino) REFERENCES bancos(id_banco)
);

-- 9. Empresas de servicio
CREATE TABLE empresas_servicio (
    id_empresa INT PRIMARY KEY AUTO_INCREMENT,
    nombre_empresa VARCHAR(100) NOT NULL,
    codigo_empresa CHAR(10) UNIQUE,
    tipo_servicio ENUM('AGUA', 'LUZ', 'TELEFONIA') NOT NULL
);

-- 10. Servicios ofrecidos
CREATE TABLE servicios (
    id_servicio INT PRIMARY KEY AUTO_INCREMENT,
    id_empresa INT,
    nombre_servicio VARCHAR(100),
    FOREIGN KEY (id_empresa) REFERENCES empresas_servicio(id_empresa)
);

-- 11. Pagos de servicios
CREATE TABLE pagos_servicios (
    id_pago INT PRIMARY KEY AUTO_INCREMENT,
    id_cuenta INT,
    id_servicio INT,
    codigo_cliente VARCHAR(50),
    monto DECIMAL(12,2),
    fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cuenta) REFERENCES cuentas(id_cuenta),
    FOREIGN KEY (id_servicio) REFERENCES servicios(id_servicio)
);

-- 12. Recargas de celular
CREATE TABLE recargas (
    id_recarga INT PRIMARY KEY AUTO_INCREMENT,
    id_cuenta INT,
    operador ENUM('CLARO', 'MOVISTAR', 'ENTEL', 'BITEL'),
    numero CHAR(9),
    monto DECIMAL(12,2),
    fecha_recarga TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cuenta) REFERENCES cuentas(id_cuenta)
);
