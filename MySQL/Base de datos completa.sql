/*
CONSIGNAS DE LA ACTIVIDAD:

Crear la base de datos denominada RH en un motor de base de datos.

2. Crear las tablas del modelo de datos obtenido a partir del diagrama de entidad relación.

a. Tener en cuenta las siguientes consideraciones:
b. Especificar todos los atributos del modelo.
c. Definir las restricciones correspondientes establecidas para cada atributo. (Ejemplo: Valor nulo, restricciones de dominio)
d. Crear las claves primarias (PK) correspondientes. 
e. Crear las claves foráneas (FK) correspondientes.

3. Poblar la base de datos creada ingresando un conjunto de datos de acuerdo al siguiente detalle:

	-Ingresar 3 regiones.
	-Ingresar 6 provincias.
	-Ingresar 2 localidades por provincia.
	-Ingresar al menos una sucursal por localidad
	-Ingresar no menos de 3 cargos posibles definidos para la organización.
	-Ingresar no menos de 6 empleados. 4 asignados a cargos y sucursal. 2 sin asignación de puesto cargo.  
	
4. Realizar las siguientes consultas sobre la base de datos:

	-Detalle de empleados (apellido, nombres, DNI, correo electrónico).
	-etalle de empleados sin destino y cargo asignado (apellido, nombres, DNI, correo electrónico).
	-Cantidad de empleados por sucursal (nombre sucursal, cantidad empleados).
	-Cantidad de empleados por región (nombre sucursal, cantidad empleados)
	-Detalle de Empleados ingresados en un período determinado (entre fechas).
	-Crear una vista que permita consultar el siguiente detalle de datos: Apellido, nombres, correo electrónico, nombre cargo, nombre sucursal, provincia.
	-Obtener el listado de cargos disponibles en la organización, indicando el salario mínimo y máximo definido para cada uno.

5. Crear un procedimiento almacenado que permita actualizar los salarios de los empleados en un porcentaje determinado. 

6. Crear un procedimiento almacenado que permita insertar un nuevo cargo. 

7. Crear un procedimiento almacenado que permita asignar un empleado a un nuevo cargo (cambio de cargo dentro de la empresa).

8. Crear un trigger que permita registrar el cargo anterior de un empleado, al momento de ser reasignado a otro cargo dentro de la organización. Por ejemplo: 

	-Empleado 1
	-Desempeño actual: supervisor.
	-Desempeño nuevo: gerente. 

Se debe registrar en la tabla de movimientos internos del personal (histórico de cargos por empleado) el cargo que abandona (supervisor). 

9. Crear una función que permita determinar la antigüedad de un empleado.

*/


-- **************************************** SECCION 1 - Crear una base de datos denominada 'RH' en un motor de Base de datos
-- **************************************** 			NOTA: Se utilizará MySQL para la gestión de la BD
DROP DATABASE If EXISTS `rh`;
CREATE DATABASE `rh`;

-- **************************************** SECCION 2 - Crear las tablas del modelo de datos obtenido a partir del diagrama de Entidad-Relacion
-- Tabla RUBROS 
DROP TABLE IF EXISTS `rh`.`rubros`;
CREATE TABLE `rh`.`rubros`
(
  rubid integer NOT NULL,
  rubnombre character(70) NOT NULL,
  PRIMARY KEY (`rubid`)
);

-- Tabla CARGOS
DROP TABLE IF EXISTS `rh`.`cargos`;
CREATE TABLE `rh`.`cargos`
(
  carid smallint NOT NULL,
  carnombre character(70) NOT NULL,
  carsalariominimo numeric(9,2) NOT NULL,
  carsalariomaximo numeric(9,2) NOT NULL,
  PRIMARY KEY (`carid`)
);

-- Tabla REGIONES
DROP TABLE IF EXISTS `rh`.`regiones`;
CREATE TABLE `rh`.`regiones`
(
  regid smallint NOT NULL,
  regnombre character(40) NOT NULL,
  PRIMARY KEY (`regid`) 
);

-- Tabla PROVINCIAS
DROP TABLE IF EXISTS `rh`.`provincias`;
CREATE TABLE `rh`.`provincias`
(
  proid smallint NOT NULL, 
  pronombre character(40) NOT NULL,
  regid smallint NOT NULL,
  PRIMARY KEY (`proid`),
  CONSTRAINT `fk_provincia1` FOREIGN KEY (`regid`) REFERENCES `regiones` (`regid`) ON DELETE RESTRICT ON UPDATE CASCADE   
);

-- Tabla LOCALIDADES
DROP TABLE IF EXISTS `rh`.`localidades`;
CREATE TABLE `rh`.`localidades`
(
  locid smallint NOT NULL,
  locnombre character(70) NOT NULL,
  proid smallint NOT NULL,
  PRIMARY KEY (`locid`),
  CONSTRAINT `fk_localidad1` FOREIGN KEY (`proid`) REFERENCES `provincias` (`proid`) ON DELETE RESTRICT ON UPDATE CASCADE  
);

-- Tabla SUCURSALES
DROP TABLE IF EXISTS `rh`.`sucursales`;
CREATE TABLE `rh`.`sucursales`
(
  sucid smallint NOT NULL,
  sucnombre character(70) NOT NULL,  
  sucdireccion character(70) NOT NULL,  
  sucempleados smallint NOT NULL,
  locid smallint NOT NULL,
  PRIMARY KEY (`sucid`),
  CONSTRAINT `fk_sucursal1` FOREIGN KEY (`locid`) REFERENCES `localidades` (`locid`) ON DELETE RESTRICT ON UPDATE CASCADE   
);

-- Tabla ARTICULOS
DROP TABLE IF EXISTS `rh`.`articulos`;
CREATE TABLE `rh`.`articulos`
(
  artid bigint NOT NULL,
  artnombre character(70) NOT NULL,
  rubid integer NOT NULL,  
  artmarca character(70) NOT NULL,
  arteficelec character(1) NOT NULL,
  artmaterial character(70) NOT NULL,
  artorigen character(70) NOT NULL,
  artantiguo character(1) NOT NULL,
  artmemoria integer NOT NULL,
  artdescuento smallint NOT NULL,
  artgarantia smallint NOT NULL,
  artprecio numeric(11,2) NOT NULL,
  PRIMARY KEY (`artid`),
  CONSTRAINT `fk_articulos1` FOREIGN KEY (`rubid`) REFERENCES `rubros` (`rubid`) ON DELETE RESTRICT ON UPDATE CASCADE
);
 
-- Tabla EMPLEADOS
DROP TABLE IF EXISTS `rh`.`empleados`;
CREATE TABLE `rh`.`empleados`
(
  empdni integer NOT NULL,
  empnombre character(70) NOT NULL,
  empapellido character(70) NOT NULL,
  emptelefono bigint NOT NULL,
  empemail character(70) NOT NULL,
  empfechaingreso date NOT NULL,
  sucid smallint,  
  carid smallint,  
  empsalarioinicial numeric(9,2),
  PRIMARY KEY (`empdni`),
  CONSTRAINT `fk_empleados1` FOREIGN KEY (`sucid`) REFERENCES `sucursales` (`sucid`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_empleados2` FOREIGN KEY (`carid`) REFERENCES `cargos` (`carid`) ON DELETE RESTRICT ON UPDATE CASCADE
); 

-- Tabla HISTORIALCARGOS
DROP TABLE IF EXISTS `rh`.`historialcargos`;
CREATE TABLE `rh`.`historialcargos`
(
  empdni integer NOT NULL,
  carid smallint NOT NULL,
  hisfechadesde date NOT NULL,
  hisfechahasta date,
  
  PRIMARY KEY (`empdni`, `carid`, `hisfechadesde`),
  CONSTRAINT `fk_hiscar1` FOREIGN KEY (`empdni`) REFERENCES `empleados` (`empdni`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_hiscar2` FOREIGN KEY (`carid`) REFERENCES `cargos` (`carid`) ON DELETE RESTRICT ON UPDATE CASCADE  
);

 -- Tabla ARTXSUCURSAL
DROP TABLE IF EXISTS `rh`.`artxsucursal`;
CREATE TABLE `rh`.`artxsucursal`
(
  sucid smallint NOT NULL,
  artid bigint NOT NULL,
  axsstock smallint NOT NULL,
  PRIMARY KEY (`sucid`, `artid`),
  CONSTRAINT `fk_artxsuc1` FOREIGN KEY (`sucid`) REFERENCES `sucursales` (`sucid`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_artxsuc2` FOREIGN KEY (`artid`) REFERENCES `articulos` (`artid`) ON DELETE RESTRICT ON UPDATE CASCADE  
);

-- **************************************** SECCION 3 - Poblar la base de datos
-- Tabla REGIONES (3 registros)
INSERT INTO `rh`.`regiones`(regid, regnombre) VALUES (1, 'Centro');
INSERT INTO `rh`.`regiones`(regid, regnombre) VALUES (2, 'NOA');
INSERT INTO `rh`.`regiones`(regid, regnombre) VALUES (3, 'Cuyo');

-- Tabla PROVINCIAS (6 registros)
INSERT INTO `rh`.`provincias`(proid, pronombre, regid) VALUES (1, 'Buenos Aires', 1);
INSERT INTO `rh`.`provincias`(proid, pronombre, regid) VALUES (2, 'Entre Ríos', 1);
INSERT INTO `rh`.`provincias`(proid, pronombre, regid) VALUES (3, 'Jujuy', 2);
INSERT INTO `rh`.`provincias`(proid, pronombre, regid) VALUES (4, 'Tucumán', 2);
INSERT INTO `rh`.`provincias`(proid, pronombre, regid) VALUES (5, 'Mendoza', 3);
INSERT INTO `rh`.`provincias`(proid, pronombre, regid) VALUES (6, 'San Luis', 3);

-- Tabla LOCALIDADES (2 registros por provincia)
INSERT INTO `rh`.`localidades`(locid, locnombre, proid) VALUES (1, 'Avellaneda', 1);
INSERT INTO `rh`.`localidades`(locid, locnombre, proid) VALUES (2, 'Lanús', 1);
INSERT INTO `rh`.`localidades`(locid, locnombre, proid) VALUES (3, 'Paraná', 2);
INSERT INTO `rh`.`localidades`(locid, locnombre, proid) VALUES (4, 'Gualeguay' ,2);
INSERT INTO `rh`.`localidades`(locid, locnombre, proid) VALUES (5, 'San Salvador', 3);
INSERT INTO `rh`.`localidades`(locid, locnombre, proid) VALUES (6, 'Tilcara', 3);
INSERT INTO `rh`.`localidades`(locid, locnombre, proid) VALUES (7, 'San Miguel', 4);
INSERT INTO `rh`.`localidades`(locid, locnombre, proid) VALUES (8, 'Tafi Viejo', 4);
INSERT INTO `rh`.`localidades`(locid, locnombre, proid) VALUES (9, 'Mendoza', 5);
INSERT INTO `rh`.`localidades`(locid, locnombre, proid) VALUES (10, 'Godoy Cruz', 5);
INSERT INTO `rh`.`localidades`(locid, locnombre, proid) VALUES (11, 'San Luis', 6);
INSERT INTO `rh`.`localidades`(locid, locnombre, proid) VALUES (12, 'Villa Mercedes', 6);

-- Tabla SUCURSALES (1 o más por localidad)
INSERT INTO `rh`.`sucursales`(sucid, sucdireccion, sucempleados, sucnombre, locid) VALUES (1,'Díaz Vélez 500',2,'Avellaneda',1);
INSERT INTO `rh`.`sucursales`(sucid, sucdireccion, sucempleados, sucnombre, locid) VALUES (2,'La Rioja 3150',2,'Lanús',2);
INSERT INTO `rh`.`sucursales`(sucid, sucdireccion, sucempleados, sucnombre, locid) VALUES (3,'Av. Ramírez 2360',1,'Paraná',3);
INSERT INTO `rh`.`sucursales`(sucid, sucdireccion, sucempleados, sucnombre, locid) VALUES (4,'Belgrano 800',1,'Gualeguay',4);
INSERT INTO `rh`.`sucursales`(sucid, sucdireccion, sucempleados, sucnombre, locid) VALUES (5,'Av. Yrigoyen 130',1,'San Salvador',5);
INSERT INTO `rh`.`sucursales`(sucid, sucdireccion, sucempleados, sucnombre, locid) VALUES (6,'Rivadavia 620',1,'Tilcara',6);
INSERT INTO `rh`.`sucursales`(sucid, sucdireccion, sucempleados, sucnombre, locid) VALUES (7,'Viamonte 1200',1,'San Miguel',7);
INSERT INTO `rh`.`sucursales`(sucid, sucdireccion, sucempleados, sucnombre, locid) VALUES (8,'Paysandú 1140',1,'Tafí Viejo',8);
INSERT INTO `rh`.`sucursales`(sucid, sucdireccion, sucempleados, sucnombre, locid) VALUES (9,'Patricias Mendocinas 1150',1,'Mendoza',9);
INSERT INTO `rh`.`sucursales`(sucid, sucdireccion, sucempleados, sucnombre, locid) VALUES (10,'Av. Cipoletti 400',1,'Godoy Cruz',10);
INSERT INTO `rh`.`sucursales`(sucid, sucdireccion, sucempleados, sucnombre, locid) VALUES (11,'San Martín 340',1,'San Luis',11);
INSERT INTO `rh`.`sucursales`(sucid, sucdireccion, sucempleados, sucnombre, locid) VALUES (12,'Guayaquil 950',1,'Villa Mercedes',12);

-- Tabla CARGOS (3 o más en la empresa)
INSERT INTO `rh`.`cargos`(carid, carnombre, carsalariominimo, carsalariomaximo) VALUES (1,'Vendedor', 10000, 20000);
INSERT INTO `rh`.`cargos`(carid, carnombre, carsalariominimo, carsalariomaximo) VALUES (2,'Supervisor', 20000, 35000);
INSERT INTO `rh`.`cargos`(carid, carnombre, carsalariominimo, carsalariomaximo) VALUES (3,'Gerente', 40000, 60000);

-- Tabla EMPLEADOS (6 o más empleados, 4 con cargo y sucursal, 2 sin puesto de trabajo asignado)
INSERT INTO `rh`.`empleados`(empdni, empnombre, empapellido, emptelefono, empemail, empfechaingreso, carid, empsalarioinicial, sucid) VALUES (25847559, 'Sybil', 'Fulton',15554156244,'sfulton@avellaneda.com','2020-12-15',1,15000,1);
INSERT INTO `rh`.`empleados`(empdni, empnombre, empapellido, emptelefono, empemail, empfechaingreso, carid, empsalarioinicial, sucid) VALUES (18424357, 'Vanna', 'Vazquez',15264417645,'vvazquez@avellaneda.com','2020-12-15',2,28000,1);
INSERT INTO `rh`.`empleados`(empdni, empnombre, empapellido, emptelefono, empemail, empfechaingreso, carid, empsalarioinicial, sucid) VALUES (30778130, 'Baker', 'Payne',15397417275,'bpayne@lanus.com','2018-07-14',1,15000,2);
INSERT INTO `rh`.`empleados`(empdni, empnombre, empapellido, emptelefono, empemail, empfechaingreso, carid, empsalarioinicial, sucid) VALUES (25763374, 'Leo', 'Pittman',12687991355,'lpittman@lanus.com','2018-08-25',2,28000,2);
INSERT INTO `rh`.`empleados`(empdni, empnombre, empapellido, emptelefono, empemail, empfechaingreso, carid, empsalarioinicial, sucid) VALUES (16396396, 'Julie', 'Huff',17731723185,'jhuff@parana.com','2021-01-05',1,15000,3);
INSERT INTO `rh`.`empleados`(empdni, empnombre, empapellido, emptelefono, empemail, empfechaingreso, carid, empsalarioinicial, sucid) VALUES (18540102, 'Grahan', 'Mullen',11647398771,'gmullen@gualeguay.com','2017-06-04',1,15000,4);
INSERT INTO `rh`.`empleados`(empdni, empnombre, empapellido, emptelefono, empemail, empfechaingreso, carid, empsalarioinicial, sucid) VALUES (22674880, 'Warren', 'Parsons',12914161738,'wparsons@sansalvador.com','2017-03-11',null,15000,null);
INSERT INTO `rh`.`empleados`(empdni, empnombre, empapellido, emptelefono, empemail, empfechaingreso, carid, empsalarioinicial, sucid) VALUES (15474970, 'Norman', 'Preston',6554456,'wparsons@tilcara.com','2019-10-27',null,15000,null);
INSERT INTO `rh`.`empleados`(empdni, empnombre, empapellido, emptelefono, empemail, empfechaingreso, carid, empsalarioinicial, sucid) VALUES (34717799, 'Griffith', 'Leon',17667119776,'gleon@sanmiguel.com','2018-08-04',1,15000,7);
INSERT INTO `rh`.`empleados`(empdni, empnombre, empapellido, emptelefono, empemail, empfechaingreso, carid, empsalarioinicial, sucid) VALUES (29051811, 'John', 'Chen',6665842,'jchen@tafiviejo.com','2021-07-03',1,15000,8);
INSERT INTO `rh`.`empleados`(empdni, empnombre, empapellido, emptelefono, empemail, empfechaingreso, carid, empsalarioinicial, sucid) VALUES (35684453, 'Nero', 'Hoffman',3035670,'nhoffman@mendoza.com','2022-03-01',1,15000,9);
INSERT INTO `rh`.`empleados`(empdni, empnombre, empapellido, emptelefono, empemail, empfechaingreso, carid, empsalarioinicial, sucid) VALUES (37177996, 'Sylvia', 'Carr',18394722858,'scarr@godoycruz.com','2019-12-01',1,15000,10);
INSERT INTO `rh`.`empleados`(empdni, empnombre, empapellido, emptelefono, empemail, empfechaingreso, carid, empsalarioinicial, sucid) VALUES (38013150, 'Lane', 'Harrington',18574531243,'lharrington@sanluis.com','2021-06-04',1,15000,11);
INSERT INTO `rh`.`empleados`(empdni, empnombre, empapellido, emptelefono, empemail, empfechaingreso, carid, empsalarioinicial, sucid) VALUES (17128446, 'Philip', 'Yates',3570368,'pyates@villamercedes.com','2020-01-05',1,15000,12);

-- **************************************** SECCION 4. Realizar las siguientes consultas sobre la base de datos
-- Detalle de empleados (apellido, nombres, DNI, correo electrónico). 
SELECT 
	empapellido AS 'Apellido',
    empnombre AS 'Nombres',
    empdni AS 'DNI',
    empemail AS 'EMail'
FROM `rh`.`empleados`;

-- Detalle de empleados sin destino y cargo asignado (apellido, nombres, DNI, correo electrónico).
SELECT 
	empapellido AS 'Apellido',
    empnombre AS 'Nombres',
    empdni AS 'DNI',
    empemail AS 'EMail'
FROM `rh`.`empleados` 
WHERE isnull(sucid) AND isnull(carid);

-- Cantidad de empleados por sucursal (nombre sucursal, cantidad empleados).
SELECT 
	sucnombre AS 'Sucursal', 
    sum(sucempleados) AS 'Empleados'
FROM `rh`.`sucursales` 
GROUP BY sucid;

-- Cantidad de empleados por región (nombre región, cantidad empleados)
SELECT 
	regnombre AS 'Región', 
    sum(sucempleados) AS 'Empleados'
FROM `rh`.`sucursales` 
JOIN `rh`.`localidades` ON `rh`.`localidades`.locid = `rh`.`sucursales`.locid
JOIN `rh`.`provincias` ON `rh`.`provincias`.proid = `rh`.`localidades`.proid
JOIN `rh`.`regiones` ON `rh`.`regiones`.regid = `rh`.`provincias`.regid
GROUP BY `rh`.`regiones`.regid;

-- Detalle de Empleados ingresados en un período determinado (entre fechas).
SELECT 
	empdni AS 'DNI',
	empapellido AS 'Apellido',
	empnombre AS 'Nombres',
	emptelefono AS 'Teléfono',
	empemail AS 'E-Mail',
	empfechaingreso AS 'Fecha de Ingreso',
	sucid AS 'Sucursal',
	carid AS 'Cargo',
	empsalarioinicial AS 'Salario Inicial'
FROM `rh`.`empleados` 
WHERE `empfechaingreso`>='2020-01-01' AND `empfechaingreso`<='2020-12-31';

-- Crear una vista que permita consultar el siguiente detalle de datos: Apellido, nombres, correo electrónico, nombre cargo, nombre sucursal, provincia.
DROP VIEW IF EXISTS `rh`.`datos_empleados`;
CREATE VIEW `rh`.`datos_empleados` AS
    SELECT 
        `rh`.`empleados`.`empapellido` AS `Apellido`,
        `rh`.`empleados`.`empnombre` AS `Nombre`,
        `rh`.`empleados`.`empemail` AS `E-Mail`,
        `rh`.`cargos`.`carnombre` AS `Cargo`,
        `rh`.`sucursales`.`sucnombre` AS `Sucursal`,
        `rh`.`provincias`.`pronombre` AS `Provincia`
		-- JOIN provincias ON provincias.proid = localidades.proid
    FROM
        ((`rh`.`empleados`
        JOIN `rh`.`cargos` ON ((`rh`.`cargos`.`carid` = `rh`.`empleados`.`carid`)))
        JOIN `rh`.`sucursales` ON ((`rh`.`sucursales`.`sucid` = `rh`.`empleados`.`sucid`))
        JOIN `rh`.`localidades` ON `rh`.`localidades`.`locid` = `rh`.`sucursales`.`locid`
        JOIN `rh`.`provincias` ON `rh`.`provincias`.`proid` = `rh`.`localidades`.`proid`
        );
        
-- Obtener el listado de cargos disponibles en la organización, indicando el salario mínimo y máximo definido para cada uno.
SELECT 
	carnombre AS 'Cargo', 
    carsalariominimo AS 'Salario Mínimo', 
    carsalariomaximo AS 'Salario Máximo' 
FROM `rh`.`cargos`;



												/*Punto n°1*/
/*Crear un procedimiento almacenado que permita actualizar los salarios de los empleados en un porcentaje determinado*/

USE `rh`;
DROP procedure IF EXISTS `Actualizar_salario`;

USE `rh`;
DROP procedure IF EXISTS `rh`.`Actualizar_salario`;
;

DELIMITER $$
USE `rh`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Actualizar_salario`(IN porc INT)
BEGIN
UPDATE empleados SET empsalarioinicial = empsalarioinicial * (1+(porc/100))
where empdni <>0;
END$$

DELIMITER ;
;



                                                /*Punto n°2*/
/*Crear un procedimiento almacenado que permita insertar un nuevo cargo*/

USE `rh`;
DROP procedure IF EXISTS `Insertar_Nuevo_Cargo`;

DELIMITER $$
USE `rh`$$
CREATE PROCEDURE `Insertar_Nuevo_Cargo` (in val int, in nomb varchar(30), in salariominimo int, in salariomaximo int)
BEGIN
insert into cargos(carid,carnombre,carsalariominimo,carsalariomaximo) values(val,nomb,salariominimo,salariomaximo);
END$$

DELIMITER ;



                                              /*Punto n°3*/
/*Crear un procedimiento almacenado que permita asignar un empleado a un nuevo cargo (cambio de cargo dentro de la empresa)*/
USE `rh`;
DROP procedure IF EXISTS `Empleado_Cambio_Cargo`;

DELIMITER $$
USE `rh`$$
CREATE PROCEDURE `Empleado_Cambio_Cargo` (in dni int, in nuevocargo int)
BEGIN
update empleados set carid = nuevocargo 
where empdni = dni; 
END$$

DELIMITER ;



											  /*Punto n°4*/
									   /*Se creo una nueva tabla*/

CREATE TABLE `rh`.`registro_cargos` (
  `dni_empleado` INT NULL DEFAULT NULL,
  `cargo_actual` INT NULL DEFAULT NULL,
  `cargo_nuevo` INT NULL DEFAULT NULL);
  
  /*Crear un trigger que permita registrar el cargo anterior de un empleado, al momento de ser reasignado a otro cargo dentro de la organización.*/
  
 create trigger movimientos_internos after update on  empleados for each row 
insert into registro_cargos (dni_empleado,cargo_actual,cargo_nuevo) values(old.empdni,old.carid,new.carid)

 
  DELIMITER $$
										    /*Punto n°5*/
/*Crear una función que permita determinar la antigüedad de un empleado*/
USE `rh`;
DROP function IF EXISTS `Antiguedad`;

DELIMITER $$
USE `rh`$$
CREATE FUNCTION `Antiguedad` (i date)
RETURNS INT deterministic 
BEGIN

RETURN truncate(((current_date()-i))/(365*24),0); 

END$$

DELIMITER ;

/*Este codigo es para llamar a la funcion Antiguedad la cual calcula el tiempor que lleva el empleado en la empresa*/
select empdni, rh.Antiguedad(empfechaingreso) as Antiguedad from empleados 






