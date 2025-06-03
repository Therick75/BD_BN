DROP DATABASE IF EXISTS banco;
CREATE DATABASE banco;
USE banco;

-- Tabla de bancos (incluyendo Banco de la Nación)
CREATE TABLE bancos (
    id_banco INT PRIMARY KEY AUTO_INCREMENT,
    nombre_banco VARCHAR(100) NOT NULL UNIQUE,
    codigo_entidad CHAR(3) NOT NULL UNIQUE
);

-- Tabla principal de usuarios
CREATE TABLE usuarios (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    dni CHAR(8) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    direccion VARCHAR(255),
    correo VARCHAR(100) UNIQUE NOT NULL,
    celular CHAR(9) UNIQUE NOT NULL,
    clave_digital CHAR(60) NOT NULL, -- Almacenamiento seguro (hash)
    intentos_fallidos TINYINT DEFAULT 0,
    cuenta_bloqueada BOOLEAN DEFAULT FALSE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de cuentas bancarias
CREATE TABLE cuentas (
    id_cuenta INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    id_banco INT NOT NULL DEFAULT 1, -- 1 = Banco de la Nación
    numero_cuenta CHAR(15) UNIQUE NOT NULL,
    cci CHAR(20) UNIQUE NOT NULL,
    saldo DECIMAL(15,2) DEFAULT 0.00,
    tipo_cuenta ENUM('AHORROS', 'CORRIENTE') NOT NULL,
    fecha_apertura DATE NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_banco) REFERENCES bancos(id_banco)
);

-- Tabla de contactos externos (billeteras digitales, otros bancos)
CREATE TABLE contactos_externos (
    id_contacto INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    tipo_contacto ENUM('CELULAR', 'CCI', 'CARNET') NOT NULL,
    valor_contacto VARCHAR(20) NOT NULL,
    id_banco INT,
    alias VARCHAR(50),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_banco) REFERENCES bancos(id_banco),
    UNIQUE KEY (tipo_contacto, valor_contacto)
);

-- Tabla unificada de transacciones
CREATE TABLE transacciones (
    id_transaccion BIGINT PRIMARY KEY AUTO_INCREMENT,
    id_cuenta_origen INT NOT NULL,
    id_contacto_destino INT,
    tipo_transaccion ENUM(
        'TRANSFERENCIA_CCI', 
        'TRANSFERENCIA_CELULAR',
        'PAGO_SERVICIO',
        'RECARGA',
        'GIRO'
    ) NOT NULL,
    monto DECIMAL(15,2) NOT NULL,
    moneda CHAR(3) DEFAULT 'PEN',
    concepto VARCHAR(200),
    estado ENUM('PENDIENTE', 'COMPLETADA', 'RECHAZADA') DEFAULT 'PENDIENTE',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_completada TIMESTAMP NULL,
    FOREIGN KEY (id_cuenta_origen) REFERENCES cuentas(id_cuenta),
    FOREIGN KEY (id_contacto_destino) REFERENCES contactos_externos(id_contacto)
);

-- Tabla de empresas de servicios
CREATE TABLE empresas_servicio (
    id_empresa INT PRIMARY KEY AUTO_INCREMENT,
    nombre_empresa VARCHAR(100) NOT NULL UNIQUE,
    codigo_empresa CHAR(10) UNIQUE NOT NULL,
    tipo_servicio ENUM('AGUA', 'LUZ', 'TELEFONIA', 'INTERNET', 'TV', 'GAS') NOT NULL
);

-- Tabla de servicios contratados
CREATE TABLE servicios_contratados (
    id_servicio INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    id_empresa INT NOT NULL,
    codigo_contrato VARCHAR(50) NOT NULL,
    alias VARCHAR(50),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_empresa) REFERENCES empresas_servicio(id_empresa),
    UNIQUE KEY (id_empresa, codigo_contrato)
);

-- Tabla de recargas
CREATE TABLE recargas (
    id_recarga INT PRIMARY KEY AUTO_INCREMENT,
    id_transaccion BIGINT NOT NULL,
    operador ENUM('CLARO', 'MOVISTAR', 'ENTEL', 'BITEL') NOT NULL,
    numero CHAR(9) NOT NULL,
    FOREIGN KEY (id_transaccion) REFERENCES transacciones(id_transaccion)
);

-- Tabla de giros
CREATE TABLE giros (
    id_giro INT PRIMARY KEY AUTO_INCREMENT,
    id_transaccion BIGINT NOT NULL,
    dni_destinatario CHAR(8) NOT NULL,
    nombre_destinatario VARCHAR(150) NOT NULL,
    FOREIGN KEY (id_transaccion) REFERENCES transacciones(id_transaccion)
);

-- Tabla de tokens de seguridad
CREATE TABLE tokens_seguridad (
    id_token INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    token CHAR(6) NOT NULL,
    tipo_token ENUM('LOGIN', 'TRANSACCION') NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valido_hasta TIMESTAMP NOT NULL,
    utilizado BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);

-- Índices para mejor rendimiento
CREATE INDEX idx_cuentas_usuario ON cuentas(id_usuario);
CREATE INDEX idx_transacciones_cuenta ON transacciones(id_cuenta_origen);
CREATE INDEX idx_transacciones_fecha ON transacciones(fecha_creacion);
CREATE INDEX idx_contactos_usuario ON contactos_externos(id_usuario);
CREATE INDEX idx_servicios_usuario ON servicios_contratados(id_usuario);

-- Triggers para mantener la integridad
DELIMITER //

-- Trigger para actualizar saldo en transferencias
CREATE TRIGGER after_transaccion_completada
AFTER UPDATE ON transacciones
FOR EACH ROW
BEGIN
    IF NEW.estado = 'COMPLETADA' AND OLD.estado != 'COMPLETADA' THEN
        -- Actualizar saldo cuenta origen
        UPDATE cuentas 
        SET saldo = saldo - NEW.monto
        WHERE id_cuenta = NEW.id_cuenta_origen;
        
        -- Si es transferencia a cuenta propia o interno banco
        IF NEW.id_contacto_destino IS NOT NULL THEN
            UPDATE cuentas c
            JOIN contactos_externos co ON c.id_cuenta = co.id_contacto
            SET c.saldo = c.saldo + NEW.monto
            WHERE co.id_contacto = NEW.id_contacto_destino;
        END IF;
    END IF;
END//

-- Trigger para validar saldo suficiente
CREATE TRIGGER before_transaccion_insert
BEFORE INSERT ON transacciones
FOR EACH ROW
BEGIN
    DECLARE v_saldo DECIMAL(15,2);
    
    SELECT saldo INTO v_saldo
    FROM cuentas
    WHERE id_cuenta = NEW.id_cuenta_origen;
    
    IF v_saldo < NEW.monto THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Saldo insuficiente para realizar la transacción';
    END IF;
END//

-- Trigger para encriptar clave digital
CREATE TRIGGER before_usuario_insert
BEFORE INSERT ON usuarios
FOR EACH ROW
BEGIN
    -- En la práctica usaría AES_ENCRYPT o similar
    SET NEW.clave_digital = SHA2(CONCAT(NEW.dni, NEW.clave_digital), 256);
END//

DELIMITER ;

-- Procedimientos almacenados
DELIMITER //

-- Procedimiento para transferencias
CREATE PROCEDURE realizar_transferencia(
    IN p_id_cuenta_origen INT,
    IN p_tipo_destino ENUM('CELULAR', 'CCI'),
    IN p_valor_destino VARCHAR(20),
    IN p_monto DECIMAL(15,2),
    IN p_concepto VARCHAR(200)
)
BEGIN
    DECLARE v_id_contacto INT;
    
    -- Buscar contacto destino
    SELECT id_contacto INTO v_id_contacto
    FROM contactos_externos
    WHERE tipo_contacto = p_tipo_destino
    AND valor_contacto = p_valor_destino;
    
    -- Insertar transacción
    INSERT INTO transacciones (
        id_cuenta_origen,
        id_contacto_destino,
        tipo_transaccion,
        monto,
        concepto
    ) VALUES (
        p_id_cuenta_origen,
        v_id_contacto,
        CONCAT('TRANSFERENCIA_', p_tipo_destino),
        p_monto,
        p_concepto
    );
    
    -- Completar transacción
    UPDATE transacciones 
    SET estado = 'COMPLETADA', 
        fecha_completada = CURRENT_TIMESTAMP
    WHERE id_transaccion = LAST_INSERT_ID();
END//

-- Procedimiento para pagos de servicios
CREATE PROCEDURE pagar_servicio(
    IN p_id_cuenta INT,
    IN p_id_servicio INT,
    IN p_monto DECIMAL(15,2)
)
BEGIN
    -- Insertar transacción
    INSERT INTO transacciones (
        id_cuenta_origen,
        tipo_transaccion,
        monto,
        concepto
    ) VALUES (
        p_id_cuenta,
        'PAGO_SERVICIO',
        p_monto,
        (SELECT CONCAT('Pago servicio ', nombre_empresa) 
         FROM empresas_servicio 
         WHERE id_empresa = (
             SELECT id_empresa 
             FROM servicios_contratados 
             WHERE id_servicio = p_id_servicio
         ))
    );
    
    -- Completar transacción
    UPDATE transacciones 
    SET estado = 'COMPLETADA', 
        fecha_completada = CURRENT_TIMESTAMP
    WHERE id_transaccion = LAST_INSERT_ID();
END//

-- Procedimiento para recargas
CREATE PROCEDURE recargar_celular(
    IN p_id_cuenta INT,
    IN p_operador ENUM('CLARO', 'MOVISTAR', 'ENTEL', 'BITEL'),
    IN p_numero CHAR(9),
    IN p_monto DECIMAL(15,2)
)
BEGIN
    DECLARE v_id_transaccion BIGINT;
    
    -- Insertar transacción
    INSERT INTO transacciones (
        id_cuenta_origen,
        tipo_transaccion,
        monto
    ) VALUES (
        p_id_cuenta,
        'RECARGA',
        p_monto
    );
    
    SET v_id_transaccion = LAST_INSERT_ID();
    
    -- Insertar datos específicos de recarga
    INSERT INTO recargas (
        id_transaccion,
        operador,
        numero
    ) VALUES (
        v_id_transaccion,
        p_operador,
        p_numero
    );
    
    -- Completar transacción
    UPDATE transacciones 
    SET estado = 'COMPLETADA', 
        fecha_completada = CURRENT_TIMESTAMP
    WHERE id_transaccion = v_id_transaccion;
END//

DELIMITER ;

-- Datos iniciales
INSERT INTO bancos (nombre_banco, codigo_entidad) VALUES 
('Banco de la Nación', 'BN'),
('BBVA', 'BBV'),
('BCP', 'BCP'),
('Interbank', 'INT'),
('Scotiabank', 'SCO');

-- Insertar usuario inicial
INSERT INTO usuarios (dni, nombre, apellido, correo, celular, clave_digital) 
VALUES ('12345678', 'Juan', 'Perez', 'juan@example.com', '987654321', 'clave123');

-- Insertar cuenta asociada
INSERT INTO cuentas (id_usuario, numero_cuenta, cci, saldo, tipo_cuenta, fecha_apertura)
VALUES (1, '001-123456789', '002BN00112345678912345', 5000.00, 'AHORROS', '2023-01-15');