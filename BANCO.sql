-- Base de datos
DROP DATABASE IF EXISTS banco_nacion;
CREATE DATABASE banco_nacion;
USE banco_nacion;

-- 1. Usuarios
CREATE TABLE usuarios (
    dni VARCHAR(8) PRIMARY KEY,
    nombre VARCHAR(100),
    apellidos varchar(50),
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
    id_empresa INT NOT NULL,
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
    departamento varchar(20),
    distrito VARCHAR(100),
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
CREATE TABLE IF NOT EXISTS deposito (
    id_deposito INT PRIMARY KEY AUTO_INCREMENT,
    num_cuenta VARCHAR(11),
    monto DECIMAL(12,2),
    saldo_anterior DECIMAL(12,2),
    saldo_nuevo DECIMAL(12,2),
    fecha_hora DATETIME
);
CREATE TABLE retiro (
    id_retiro INT PRIMARY KEY AUTO_INCREMENT,
    num_cuenta VARCHAR(11),
    monto DECIMAL(12,2),
    fecha_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (num_cuenta) REFERENCES cuentas(num_cuenta)
);

-- funciones
delimiter //
CREATE FUNCTION calcular_comision_transferencia(
    p_id_banco_origen INT,
    p_id_banco_destino INT,
    p_monto DECIMAL(12,2)
)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE tarifa DECIMAL(12,2);
    IF p_id_banco_origen = p_id_banco_destino THEN
        SET tarifa = 0.00;
    ELSE
        SET tarifa = ROUND(p_monto * 0.005, 2);
        IF tarifa < 1.00 THEN
            SET tarifa = 1.00;
        ELSEIF tarifa > 25.00 THEN
            SET tarifa = 25.00;
        END IF;
    END IF;
    RETURN tarifa;
END//
delimiter ;
delimiter //
CREATE FUNCTION calcular_nuevo_saldo(
    p_num_cuenta VARCHAR(11),
    p_monto DECIMAL(12,2)
)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE saldo_actual DECIMAL(12,2);
    SELECT saldo INTO saldo_actual
      FROM cuentas
     WHERE num_cuenta = p_num_cuenta;
    IF saldo_actual IS NULL THEN
        RETURN NULL; -- Cuenta no existe
    END IF;
    RETURN ROUND(saldo_actual + p_monto, 2);
END//
delimiter ;
delimiter //
CREATE FUNCTION obtener_saldo_actual(p_num_cuenta VARCHAR(11))
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE s DECIMAL(12,2);
    SELECT saldo INTO s
      FROM cuentas
     WHERE num_cuenta = p_num_cuenta;
    RETURN s;
END//
delimiter ;
delimiter //
CREATE FUNCTION formatear_numero_cuenta(p_num_cuenta VARCHAR(11))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE prefijo CHAR(2);
    DECLARE medio CHAR(3);
    DECLARE sufijo CHAR(6);
    IF LENGTH(p_num_cuenta) <> 11 THEN
        RETURN NULL; -- Formato incorrecto
    END IF;
    SET prefijo = LEFT(p_num_cuenta, 2);
    SET medio   = MID(p_num_cuenta, 3, 3);
    SET sufijo  = RIGHT(p_num_cuenta, 6);
    RETURN CONCAT(prefijo, '-', medio, '-', sufijo);
END//
delimiter ;
delimiter //
CREATE FUNCTION tiene_saldo_suficiente(
    p_num_cuenta VARCHAR(11),
    p_id_banco_origen INT,
    p_id_banco_destino INT,
    p_monto DECIMAL(12,2)
)
RETURNS bool
DETERMINISTIC
BEGIN
    DECLARE saldo_actual DECIMAL(12,2);
    DECLARE comision DECIMAL(12,2);
    -- Obtener el saldo actual
    SELECT saldo INTO saldo_actual
      FROM cuentas
     WHERE num_cuenta = p_num_cuenta;
    IF saldo_actual IS NULL THEN
        RETURN NULL; /* cuenta no existe */
    END IF;
    -- Calcular comisión según banco origen/destino
    SET comision = calcular_comision_transferencia(p_id_banco_origen, p_id_banco_destino, p_monto);
    IF saldo_actual >= (p_monto + comision) THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END//
delimiter ;
DELIMITER //

CREATE FUNCTION existe_cuenta(p_num_cuenta VARCHAR(11))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_existe INT;

    SELECT COUNT(*) INTO v_existe
    FROM cuentas
    WHERE num_cuenta = p_num_cuenta;

    RETURN v_existe > 0;
END//

DELIMITER //

CREATE FUNCTION obtener_banco_por_cci(p_cci VARCHAR(20))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_id_banco INT;
    SELECT id_banco
    INTO v_id_banco
    FROM cci_afiliados
    WHERE cci = p_cci
    LIMIT 1;

    RETURN v_id_banco;
END//
DELIMITER ;
DELIMITER //
CREATE FUNCTION obtener_banco_por_celular(p_celular CHAR(9))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_id_banco INT;
    SELECT id_banco
    INTO v_id_banco
    FROM banco_celular
    WHERE celular = p_celular
    LIMIT 1;
    RETURN v_id_banco;
END//
DELIMITER ;
-- -----------------------------------------------------------
-- procedimientos
DELIMITER //
CREATE PROCEDURE login_usuario(
    IN p_dni VARCHAR(8),
    IN p_clave CHAR(6)
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM usuarios
        WHERE dni = p_dni AND clave_digital = p_clave
    ) THEN
        SELECT 'Login exitoso' AS mensaje;
    ELSE
        SELECT 'Credenciales incorrectas' AS mensaje;
    END IF;
END//
DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE ver_saldo(
    IN p_dni VARCHAR(8)
)
BEGIN
    SELECT num_cuenta, saldo
    FROM cuentas
    WHERE dni = p_dni;
END//
DELIMITER ;
-- -----------------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE transferir_por_celular(
  IN p_cuenta_origen VARCHAR(11),
  IN p_celular_destino CHAR(9),
  IN p_monto DECIMAL(12,2)
)
BEGIN

  DECLARE id_banco_destino INT;
  -- Manejo de errores
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error en la transferencia por celular';
  END;
  START TRANSACTION;
  SET id_banco_destino = obtener_banco_por_celular(p_celular_destino);
  IF id_banco_destino IS NULL THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El banco del celular destino no está afiliado.';
  END IF;
  IF tiene_saldo_suficiente(p_cuenta_origen, 1, id_banco_destino, p_monto) THEN
    INSERT INTO transferencias_celular (num_cuenta_origen, celular_destino, id_banco_destino, monto)
    VALUES (p_cuenta_origen, p_celular_destino, id_banco_destino, p_monto);
    -- Descontar saldo
    UPDATE cuentas SET saldo = saldo - p_monto
    WHERE num_cuenta = p_cuenta_origen;
    COMMIT;
  ELSE
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo insuficiente para transferencia por celular';
  END IF;
END//
DELIMITER ;
-- -----------------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE transferir_cuenta_a_cuenta(
  IN p_cuenta_origen VARCHAR(11),
  IN p_cuenta_destino VARCHAR(11),
  IN p_monto DECIMAL(12,2),
  IN p_descripcion TEXT
)
BEGIN
  DECLARE id_banco_origen INT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error en la transferencia cuenta a cuenta';
  END;
  START TRANSACTION;
  IF tiene_saldo_suficiente(p_cuenta_origen, 1, 1, p_monto) THEN
    INSERT INTO transferencias_cuentas (num_cuenta_origen, numero_cuenta_destino, id_banco_destino, descripcion, monto)
    VALUES (p_cuenta_origen, p_cuenta_destino, 1, p_descripcion, p_monto);
    UPDATE cuentas SET saldo = saldo - p_monto WHERE num_cuenta = p_cuenta_origen;
    UPDATE cuentas SET saldo = saldo + p_monto WHERE num_cuenta = p_cuenta_destino;
    COMMIT;
  ELSE
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo insuficiente para transferencia cuenta a cuenta';
  END IF;
END//
DELIMITER //

CREATE PROCEDURE transferir_cci(
  IN p_cuenta_origen VARCHAR(11),
  IN p_destino_cci VARCHAR(20),
  IN p_monto DECIMAL(12,2),
  IN p_descripcion TEXT
)
BEGIN
  DECLARE id_banco_destino INT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error en la transferencia CCI';
  END;
  START TRANSACTION;
  -- Obtener banco de destino usando la función
  SET id_banco_destino = obtener_banco_por_cci(p_destino_cci);
  IF id_banco_destino IS NULL THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CCI de destino inválido';
  END IF;
  -- Verificar si tiene saldo suficiente
  IF tiene_saldo_suficiente(p_cuenta_origen, 1, id_banco_destino, p_monto) THEN
    INSERT INTO transferencias_cci (num_cuenta_origen, destino, id_banco_destino, descripcion, monto)
    VALUES (p_cuenta_origen, p_destino_cci, id_banco_destino, p_descripcion, p_monto);
    UPDATE cuentas
    SET saldo = saldo - (p_monto + calcular_comision_transferencia(1, id_banco_destino, p_monto))
    WHERE num_cuenta = p_cuenta_origen;
    COMMIT;
  ELSE
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo insuficiente para transferencia CCI';
  END IF;
END//
DELIMITER ;

-- --------------------------------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE hacer_recarga(
    IN p_cuenta VARCHAR(11),
    IN p_id_empresa INT,
    IN p_numero CHAR(9),
    IN p_monto DECIMAL(12,2)
)
BEGIN
    DECLARE saldo_actual DECIMAL(12,2);
    SELECT saldo INTO saldo_actual FROM cuentas WHERE num_cuenta = p_cuenta;
    IF saldo_actual >= p_monto THEN
        -- Insertar recarga
        INSERT INTO recargas (num_cuenta, id_empresa, numero, monto)
        VALUES (p_cuenta, p_id_empresa, p_numero, p_monto);
        -- Actualizar saldo
        UPDATE cuentas SET saldo = saldo - p_monto WHERE num_cuenta = p_cuenta;
        -- Insertar en historial
        INSERT INTO historial (num_cuenta, tipo_operacion, descripcion, monto)
        VALUES (p_cuenta, 'Recarga', CONCAT('Recarga a ', p_numero), p_monto);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo insuficiente para recarga';
    END IF;
END//
-- --------------------------------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE pagar_servicio(
    IN p_cuenta VARCHAR(11),
    IN p_id_deuda INT
)
BEGIN
    DECLARE monto_a_pagar DECIMAL(12,2);
    SELECT monto INTO monto_a_pagar FROM deudas_servicios WHERE id_deuda = p_id_deuda;
    IF (SELECT saldo FROM cuentas WHERE num_cuenta = p_cuenta) >= monto_a_pagar THEN
        -- Registrar pago
        INSERT INTO pago_servicios (num_cuenta, id_deuda)
        VALUES (p_cuenta, p_id_deuda);
        -- Actualizar saldo
        UPDATE cuentas SET saldo = saldo - monto_a_pagar WHERE num_cuenta = p_cuenta;
        -- Insertar en historial
        INSERT INTO historial (num_cuenta, tipo_operacion, descripcion, monto)
        VALUES (p_cuenta, 'Pago de Servicio', CONCAT('Pago deuda ID ', p_id_deuda), monto_a_pagar);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo insuficiente para pago de servicio';
    END IF;
END//
DELIMITER ;

DELIMITER //

CREATE PROCEDURE realizar_giro(
  IN p_cuenta_origen VARCHAR(11),
  IN p_dni_destino CHAR(8),
  IN p_monto DECIMAL(12,2)
)
BEGIN
  DECLARE id_banco_origen INT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error al realizar el giro';
  END;
  START TRANSACTION;
  IF tiene_saldo_suficiente(p_cuenta_origen, 1, 1, p_monto) THEN
    -- Insertamos el giro
    INSERT INTO giros (num_cuenta_origen, dni_destino, monto)
    VALUES (p_cuenta_origen, p_dni_destino, p_monto);
    UPDATE cuentas SET saldo = saldo - p_monto WHERE num_cuenta = p_cuenta_origen;
    COMMIT;
  ELSE
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo insuficiente para realizar el giro';
  END IF;
END//
DELIMITER ;
DELIMITER //
CREATE PROCEDURE registrar_usuario_completo(
    IN p_dni VARCHAR(8),
    IN p_nombre VARCHAR(100),
    IN p_apellidos VARCHAR(50),
    IN p_clave_digital CHAR(6),
    IN p_serie_tarjeta VARCHAR(50),
    IN p_ocupacion VARCHAR(100),
    IN p_correo VARCHAR(100),
    IN p_celular CHAR(9),
    IN p_departamento VARCHAR(100),
    IN p_provincia VARCHAR(100),
    IN p_distrito VARCHAR(100),
    IN p_direccion VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error al registrar el usuario';
    END;
    START TRANSACTION;
    -- Insertar en la tabla usuarios
    INSERT INTO usuarios (dni, nombre, apellidos, clave_digital, serie_tarjeta)
    VALUES (p_dni, p_nombre, p_apellidos, p_clave_digital, p_serie_tarjeta);
    -- Insertar ocupación
    INSERT INTO ocupaciones_usuario (dni, ocupacion)
    VALUES (p_dni, p_ocupacion);
    -- Insertar contacto
    INSERT INTO contacto (dni, correo, celular)
    VALUES (p_dni, p_correo, p_celular);
    -- Insertar dirección
    INSERT INTO direccion_usuario (dni, departamento, provincia, distrito, direccion)
    VALUES (p_dni, p_departamento, p_provincia, p_distrito, p_direccion);
    COMMIT;
END//
DELIMITER ;
DELIMITER //
CREATE PROCEDURE sp_deposito (
    IN p_num_cuenta VARCHAR(11),
    IN p_monto DECIMAL(12,2)
)
BEGIN
    DECLARE v_saldo_anterior DECIMAL(12,2);
    DECLARE v_saldo_nuevo DECIMAL(12,2);
    IF NOT EXISTS (SELECT 1 FROM cuentas WHERE num_cuenta = p_num_cuenta) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cuenta no existe';
    END IF;
    SELECT saldo INTO v_saldo_anterior FROM cuentas WHERE num_cuenta = p_num_cuenta;
    SET v_saldo_nuevo = v_saldo_anterior + p_monto;
    UPDATE cuentas SET saldo = v_saldo_nuevo WHERE num_cuenta = p_num_cuenta;
END//
DELIMITER ;
DELIMITER //

CREATE PROCEDURE realizar_retiro(
    IN p_num_cuenta VARCHAR(11),
    IN p_monto DECIMAL(12,2)
)
BEGIN
    DECLARE v_saldo_actual DECIMAL(12,2);
    -- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error al realizar el retiro';
    END;
    START TRANSACTION;
    -- Verificar si la cuenta existe
    IF NOT existe_cuenta(p_num_cuenta) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cuenta no existe';
    END IF;
    -- Obtener saldo actual
    SELECT saldo INTO v_saldo_actual FROM cuentas WHERE num_cuenta = p_num_cuenta;
    -- Verificar saldo suficiente
    IF v_saldo_actual < p_monto THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo insuficiente para realizar el retiro';
    END IF;
    -- Actualizar saldo en la cuenta
    UPDATE cuentas SET saldo = saldo - p_monto WHERE num_cuenta = p_num_cuenta;
    -- Registrar el retiro (el trigger se encargará del historial)
    INSERT INTO retiro (num_cuenta, monto)
    VALUES (p_num_cuenta, p_monto);
    COMMIT;
END//
DELIMITER ;
-- ----------------------------------------------------------------------------
-- trigger 
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
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_historial_transferencia_celular
AFTER INSERT ON transferencias_celular
FOR EACH ROW
BEGIN
  INSERT INTO historial (num_cuenta, tipo_operacion, descripcion, monto)
  VALUES (
    NEW.num_cuenta_origen,
    'Transferencia por Celular',
    CONCAT('Transferencia a celular ', NEW.celular_destino),
    NEW.monto
  );
END//

CREATE TRIGGER tr_historial_transferencia_cuentas
AFTER INSERT ON transferencias_cuentas
FOR EACH ROW
BEGIN
  INSERT INTO historial (num_cuenta, tipo_operacion, descripcion, monto)
  VALUES (
    NEW.num_cuenta_origen,
    'Transferencia Cuenta a Cuenta',
    NEW.descripcion,
    NEW.monto
  );
END//

CREATE TRIGGER tr_historial_transferencia_cci
AFTER INSERT ON transferencias_cci
FOR EACH ROW
BEGIN
  INSERT INTO historial (num_cuenta, tipo_operacion, descripcion, monto)
  VALUES (
    NEW.num_cuenta_origen,
    'Transferencia CCI',
    NEW.descripcion,
    NEW.monto
  );
END//

CREATE TRIGGER tr_historial_recarga
AFTER INSERT ON recargas
FOR EACH ROW
BEGIN
  INSERT INTO historial (num_cuenta, tipo_operacion, descripcion, monto)
  VALUES (
    NEW.num_cuenta,
    'Recarga',
    CONCAT('Recarga a ', NEW.numero),
    NEW.monto
  );
END//

CREATE TRIGGER tr_historial_pago_servicio
AFTER INSERT ON pago_servicios
FOR EACH ROW
BEGIN
  DECLARE monto_pago DECIMAL(12,2);
  SELECT monto INTO monto_pago FROM deudas_servicios WHERE id_deuda = NEW.id_deuda;
  INSERT INTO historial (num_cuenta, tipo_operacion, descripcion, monto)
  VALUES (
    NEW.num_cuenta,
    'Pago de Servicio',
    CONCAT('Pago deuda ID ', NEW.id_deuda),
    monto_pago
  );
END//

CREATE TRIGGER tr_historial_giros
AFTER INSERT ON giros
FOR EACH ROW
BEGIN
  DECLARE monto_pago DECIMAL(12,2);
  SELECT monto INTO monto_pago FROM giros WHERE id_giro = NEW.id_giro;
  INSERT INTO historial (num_cuenta, tipo_operacion, descripcion, monto)
  VALUES (
    NEW.num_cuenta_origen,
    'Giro',
    CONCAT('Se hizo un giro a', NEW.id_giro),
    monto_pago
  );
END//
DELIMITER ;
DELIMITER //

CREATE TRIGGER trg_after_update_cuentas
AFTER UPDATE ON cuentas
FOR EACH ROW
BEGIN
    -- Solo si el saldo aumentó (depósito)
    IF NEW.saldo > OLD.saldo THEN
        INSERT INTO deposito (num_cuenta, monto, saldo_anterior, saldo_nuevo, fecha_hora)
        VALUES (NEW.num_cuenta, NEW.saldo - OLD.saldo, OLD.saldo, NEW.saldo, NOW());

        INSERT INTO historial (num_cuenta, tipo_operacion, descripcion, monto, fecha)
        VALUES (NEW.num_cuenta, 'Depósito',"CORRECTO", NEW.saldo, NOW());
    END IF;
END//
CREATE TRIGGER trg_insertar_ubicaciones_usuario
AFTER INSERT ON direccion_usuario
FOR EACH ROW
BEGIN
  INSERT INTO ubicacion_usuario (dni, id_ubicacion)
  SELECT NEW.dni, ub.id_ubicacion
  FROM ubicaciones_banco ub
  WHERE ub.departamento = NEW.departamento;
END//
DELIMITER ;
DELIMITER //
CREATE TRIGGER tr_historial_retiro
AFTER INSERT ON retiro
FOR EACH ROW
BEGIN
    -- Registrar en el historial
    INSERT INTO historial (num_cuenta, tipo_operacion, descripcion, monto)
    VALUES (
        NEW.num_cuenta,
        'Retiro',
        'Retiro',
        NEW.monto
    );
END//
DELIMITER ;
