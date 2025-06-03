select * from usuarios;
select * from cuentas;
select * from ubicacion_usuario;
select * from historial;
call ver_saldo("87654321");

SHOW PROCEDURE STATUS WHERE db ="banco";
call transferir_cuenta_a_cuenta("04000654321","04000345678", 100, "Para tu pollo");
call transferir_cci("04000654321","60000123456789000002",100,"no se");
CALL realizar_retiro("04000654321",100);
show tables;
select * from historial;
select * from ubicacion_usuario; 
use banco;
select * from cuentas;

-- ejemplo
call sp_deposito("04000654321",500.00);
SELECT * FROM empresas_servicios;
select * from deudas_servicios;
-- Ver saldo antes del pago (usando la cuenta 04000654321 como ejemplo)
SELECT num_cuenta, saldo FROM cuentas WHERE num_cuenta = '04000654321';
-- Pagar la factura de luz (suponiendo que id_deuda = 1)
CALL pagar_servicio(
    '04000654321',  -- Número de cuenta que realiza el pago
    1               -- ID de la deuda a pagar (obtenido de la consulta anterior)
);

    select * from historial;

-- Ver saldo actualizado de la cuenta
SELECT num_cuenta, saldo FROM cuentas WHERE num_cuenta = '04000654321';

-- Ver el pago registrado
SELECT 
    ps.id_pago,
    ps.num_cuenta,
    es.nombre_empresa,
    ds.tipo_servicio,
    ds.codigo_pago,
    ds.monto,
    ps.fecha_pago
FROM 
    pago_servicios ps
JOIN 
    deudas_servicios ds ON ps.id_deuda = ds.id_deuda
JOIN 
    empresas_servicios es ON ds.id_empresa = es.id_empresa
ORDER BY 
    ps.fecha_pago DESC
LIMIT 1;

-- Ver en el historial de operaciones
SELECT 
    id_historial,
    num_cuenta,
    tipo_operacion,
    descripcion,
    monto,
    fecha
FROM 
    historial
WHERE 
    num_cuenta = '04000654321'
ORDER BY 
    fecha DESC
LIMIT 3;
