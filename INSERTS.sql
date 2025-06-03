CALL registrar_usuario_completo(
    '87654321', 'Mario', 'Huamani', '123456', 'ST987654',
    'Estudiante', 'mario@gmail.com', '912345678',
    'Puno', 'San Román', 'Juliaca', 'Av. Aviación 789'
);
CALL registrar_usuario_completo(
    '12345678', 'logan', 'Huamani', '123456', 'ST987654',
    'Estudiante', 'mario@gmail.com', '912345678',
    'Arequipa', 'Arequipa', 'Arequipa', 'Av. Aviación'
);
insert into bancos (nombre_banco) values ("BANCO DE LA NACION");
insert into bancos (nombre_banco) values ("ABACO");
insert into bancos (nombre_banco) values ("BBVA");
insert into bancos (nombre_banco) values ("BANBIF");
insert into bancos (nombre_banco) values ("BANCO INTERBANK");
insert into bancos (nombre_banco) values ("BANCO PICHINCHA");
insert into bancos (nombre_banco) values ("BANCO SCOTIABANK");
insert into bancos (nombre_banco) values ("BANCO FALABELLA");
insert into bancos (nombre_banco) values ("BANCO RIPLEY");
insert into bancos (nombre_banco) values ("CAJA METROPOLITANA");
insert into bancos (nombre_banco) values ("BANCO DE COMERCIO");
insert into bancos (nombre_banco) values ("LOS ANDES");
insert into bancos (nombre_banco) values ("CMAC AREQUIPA");
insert into bancos (nombre_banco) values ("CMAC CREDISCOTIA");
insert into bancos (nombre_banco) values ("CMAC HUANCAYO");
insert into bancos (nombre_banco) values ("CMAC CUSCO");
insert into bancos (nombre_banco) values ("CMAC TRUJILLO");
insert into bancos (nombre_banco) values ("MI BANCO");
insert into bancos (nombre_banco) values ("PREXPE");
insert into bancos (nombre_banco) values ("FINANCIERA EFECTIVA");
insert into bancos (nombre_banco) values ("LIGO");
INSERT INTO banco_celular (celular, id_banco) VALUES
('923456781', 3),('954321987', 6),('912345678', 15),('987654321', 7),('901234567', 2),('934567890', 13),('945612378', 8),('976543210', 14),
('923123456', 5),('956789432', 12),('989898989', 9),('912938475', 4),('934982374', 10),('998877665', 11),('943212345', 6),('978645321', 3),('922112233', 13),
('933344455', 7),('977766655', 15),('911223344', 5),('988776655', 9),('955667788', 14),('966778899', 8),('977889900', 4),('933221100', 12),('900111222', 2),
('988123456', 10),('966334455', 11),('987112233', 6),('945678912', 3),('923456789', 13),('901987654', 5),('999888777', 15),('934556677', 7),('976512389', 14),('955443322', 4),
('922334455', 9),('944556677', 12),('911122233', 8),('988765432', 10);
INSERT INTO cci_afiliados (cci, id_banco) VALUES
('60000123456789000001', 3),('60000123456789000002', 5),('60000123456789000003', 14),('60000123456789000004', 8),('60000123456789000005', 2),('60000123456789000006', 13),('60000123456789000007', 6),('60000123456789000008', 12),('60000123456789000009', 15),('60000123456789000010', 4),('60000123456789000011', 9),('60000123456789000012', 7),('60000123456789000013', 11),('60000123456789000014', 10),('60000123456789000015', 2),('60000123456789000016', 14),('60000123456789000017', 6),('60000123456789000018', 3),('60000123456789000019', 13),('60000123456789000020', 5),('60000123456789000021', 15),('60000123456789000022', 7),('60000123456789000023', 8),('60000123456789000024', 9),('60000123456789000025', 10),('60000123456789000026', 11),('60000123456789000027', 12),('60000123456789000028', 4),('60000123456789000029', 13),('60000123456789000030', 14),('60000123456789000031', 2),('60000123456789000032', 3),('60000123456789000033', 5),('60000123456789000034', 6),('60000123456789000035', 7),('60000123456789000036', 8),('60000123456789000037', 9),('60000123456789000038', 10),('60000123456789000039', 11),('60000123456789000040', 12);

INSERT INTO empresas_servicios (nombre_empresa, tipo_servicio) VALUES
('Electronoroeste S.A.', 'LUZ'),
('Electronorte S.A.', 'LUZ'),
('Hidrandina S.A.', 'LUZ'),
('Electrocentro S.A.', 'LUZ'),
('Electro Pangoa S.A.', 'LUZ'),
('Electro Puno S.A.', 'LUZ'),
('Consorcio Eléctrico de Villacuri S.A.C.', 'LUZ');
INSERT INTO empresas_servicios (nombre_empresa, tipo_servicio) VALUES
('AT&T Inc.', 'TELEFONIA'),
('Entel Perú', 'TELEFONIA'),
('Telefónica del Perú (Movistar)', 'TELEFONIA'),
('Claro Perú', 'TELEFONIA'),
('Global Fiber Perú', 'TELEFONIA'),
('Gilat Satellite Networks Ltd.', 'TELEFONIA'),
('Viettel Perú SAC', 'TELEFONIA');
INSERT INTO empresas_servicios (nombre_empresa, tipo_servicio) VALUES
('EPS SEDALIB', 'AGUA'),
('EPS SEDAPAR', 'AGUA'),
('EPS Ayacucho', 'AGUA'),
('EPSEL', 'AGUA'),
('EPS Grau', 'AGUA'),
('EPS SEDACUSCO', 'AGUA'),
('SEDAM Huancayo S.A.', 'AGUA'),
('EPS Tacna S.A.', 'AGUA'),
('EPS SEDALORETO S.A.', 'AGUA'),
('SEDACHIMBOTE', 'AGUA'),
('EMAPISCO S.A.', 'AGUA'),
('EMSAPUNO', 'AGUA'),
('EPS SEDACAJ', 'AGUA'),
('EMAPA San Martín', 'AGUA'),
('EPS EMAPACOP', 'AGUA'),
('EPS EMAPICA', 'AGUA'),
('SEDAHUANUCO', 'AGUA'),
('SEMAPACH', 'AGUA'),
('EPS SEDAJULIACA', 'AGUA'),
('EMAPA Cañete S.A.', 'AGUA'),
('EPS ILO', 'AGUA'),
('EPS EMAPA HUACHO S.A.', 'AGUA'),
('EPS CHAVIN S.A.', 'AGUA'),
('EPS EMAPAT SRL', 'AGUA'),
('EPS Selva Central', 'AGUA'),
('EPS Moquegua S.A.', 'AGUA'),
('EPS Moyobamba S.R.L.', 'AGUA'),
('EMAPA Huaral', 'AGUA'),
('EMUSAP Abancay', 'AGUA'),
('EPS Mantaro', 'AGUA'),
('SEMAPA Barranca', 'AGUA'),
('EMUSAP S.R.L.', 'AGUA'),
('EPS Sierra Central', 'AGUA'),
('EMAPAVIGSSA', 'AGUA'),
('EMPSSAPAL S.A.', 'AGUA'),
('EMAPA Chancay', 'AGUA'),
('EMAPAB', 'AGUA'),
('EMAPA Huancavelica', 'AGUA'),
('EPSSMU S.R.L.', 'AGUA'),
('EMAQ', 'AGUA'),
('EPS NOR PUNO', 'AGUA'),
('EMSAPA YAULI', 'AGUA'),
('EPS Aguas del Altiplano', 'AGUA'),
('Empresa Municipal de Agua Potable y Alcantarillado de Pasco S.A.', 'AGUA'),
('Empresa Municipal de Agua Potable y Alcantarillado de Pativilca', 'AGUA'),
('Empresa Municipal de Agua Potable Y Alcantarillado de Salas', 'AGUA'),
('EPS Chanka S.R.LTDA.', 'AGUA'),
('EPS Jaen-Perú', 'AGUA'),
('EPS Yunguyo S.R.LTDA.', 'AGUA'),
('EPS Calca S.R.LTDA.', 'AGUA'),
('EPS Acobamba', 'AGUA'),
('EPS Jucusbamba S.R.L.', 'AGUA'),
('EPS Rioja SRL', 'AGUA');
INSERT INTO deudas_servicios (id_empresa, monto) 
VALUES (35, 320.24),(15, 250.08), (3, 357.82), (48, 104.79),(36, 482.93),(29, 90.48),(51, 140.09),(49, 176.4),(41, 398.41),(38, 86.87),(57, 431.79),(2, 180.05),(40, 138.43),(11, 359.78),(37, 217.06),(30, 443.07),(45, 293.11),(27, 320.37),(7, 178.25),(45, 372.36);
INSERT INTO ubicaciones_banco (departamento, distrito, direccion) VALUES ('Amazonas', 'Chachapoyas', 'Jr. Ayacucho N 801');
INSERT INTO ubicaciones_banco (departamento, distrito, direccion) VALUES ('Amazonas La', 'Peca', 'Jr. 28 de Julio N° 501');
INSERT INTO ubicaciones_banco (departamento, distrito, direccion) VALUES ('Ancash', 'Caraz', 'Jr. Raymondi s/n');
INSERT INTO ubicaciones_banco (departamento, distrito, direccion) VALUES ('Ancash', 'Chimbote', 'José Galvez N° 200');
INSERT INTO ubicaciones_banco (departamento, distrito, direccion) VALUES ('Ancash', 'Huaraz', 'Av. Luzuriaga N° 669 - 673 - Mza. Conjunto Comercial Lote 09');
INSERT INTO ubicaciones_banco (departamento, distrito, direccion) VALUES ('Apurimac', 'Abancay', 'Jr. Lima N° 216 - 218');
INSERT INTO ubicaciones_banco (departamento, distrito, direccion) VALUES ('Apurimac', 'Abancay', 'Avenida Argentina N° 200 Centro Poblado Menor Las Américas');
INSERT INTO ubicaciones_banco (departamento, distrito, direccion) VALUES ('Apurimac Ancco', 'Huallo', 'Av. Ricardo Palma s/n - Plaza de Armas');
INSERT INTO ubicaciones_banco (departamento, distrito, direccion) VALUES ('Apurimac', 'Andahuaylas', 'Jr. Constitución Esquina con Jr. Bolívar N° 254');
INSERT INTO ubicaciones_banco (departamento, distrito, direccion) VALUES ('Apurimac', 'Huaccana', 'Av. 12 de Junio Cercado Huaccana');
INSERT INTO ubicaciones_banco (departamento, distrito, direccion) VALUES ('Apurimac San', 'Jeronimo', 'Av. Leoncio Prado N° 104');
INSERT INTO ubicaciones_banco (departamento, distrito, direccion) VALUES ('Arequipa', 'Aplao', 'Calle 3 S/N, Manzana P1, Lote N° 3');
INSERT INTO ubicaciones_banco (departamento, distrito, direccion) VALUES ('Arequipa', 'Arequipa', 'Calle Piérola N° 110 - 112');
INSERT INTO ubicaciones_banco (departamento, distrito, direccion) VALUES ('Arequipa', 'Arequipa', 'Calle Rivero N° 107 - A');
INSERT INTO ubicaciones_banco (departamento, distrito, direccion) VALUES ('Arequipa', 'Camana', 'Boulevard 28 de Julio N° 167');
INSERT INTO ubicaciones_banco (departamento, distrito, direccion) VALUES ('Arequipa', 'Cayma', 'Av. Cayma N° 618');
INSERT INTO ubicaciones_banco (departamento, distrito, direccion) VALUES ('Arequipa', 'J.L. Bustamante', 'Av. Nuevo Peru 103');
INSERT INTO ubicaciones_banco (departamento, distrito, direccion) VALUES ('Arequipa', 'Miraflores', 'Av. Mariscal Castilla N° 612 - 618');
INSERT INTO ubicaciones_banco (departamento, distrito, direccion) VALUES ('Arequipa', 'Mollendo', 'Calle Comercio N° 140');
INSERT INTO ubicaciones_banco (departamento, distrito, direccion) VALUES ('Arequipa', 'Paucarpata', 'Av. Porongoche N° 500');
INSERT INTO ubicaciones_banco (departamento, distrito, direccion) VALUES ('Arequipa', 'Yura', 'Av. Asociación Ciudad de Dios Zona 3 Sector B, Centro Cívico MDY. - Km 15.5');
INSERT INTO ubicaciones_banco (departamento, distrito, direccion) VALUES ('Ucayali', 'Yarinacocha', 'Av. Centenario No. 1642, Centro Comercial Real, Plaza Pucallpa');