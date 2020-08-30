#FINAL SACO_ROTO

#DDL
#EJERCICIO 1

#DML
#EJERCICIO 2
#Listado de prendas sin confeccionar: Listado de prendas que aún no se han terminado de confeccionar. Mostrar:
#Nombre y apellido de la persona, descripción de la prenda, fecha del pedido, fecha fin estimada de la prenda,
#fecha_entrega_requerida y cantidad de días de demora en función de la fecha requerida a hoy (función DATEDIFF).
SELECT p.nombre, p.apellido, tp.desc_tipo_prenda, ped.fecha_hora_pedido, pr.fecha_fin_est, pr.fecha_entrega,
		datediff(current_date(),pr.fecha_entrega) dias_demora
FROM prendas pr
inner join personas p on pr.nro_persona = p.nro_persona
inner join tipos_prendas tp on pr.cod_tipo_prenda = tp.cod_tipo_prenda
inner join pedidos ped on pr.nro_pedido = ped.nro_pedido
where pr.fecha_fin_real is null;

#EJERCICIO 3
#Estadística de tipos de prendas: Mostrar los tipos de prendas que nunca se han vendido. Indicando código del
#tipo de prenda y descripción.
SELECT tp.cod_tipo_prenda
from tipos_prendas tp
where tp.cod_tipo_prenda not in (select p.cod_tipo_prenda from prendas p);

#EJERCICIO 4
#Última fecha de prueba: Realizar el procedimiento "ult_prueba" que dada una fecha muestre por cada persona y
#tipo de prenda, cuál fue la última prueba realizada.
#Mostrar número y nombres de las personas, tipo de prenda, descripción del tipo de prenda y fecha de última prueba.
#Si una persona tiene varias pruebas del mismo tipo de prenda el mismo día mostrar una sola vez.
#Ordenar por fecha en forma descendente y por apellido en forma ascendente.
#Probar el procedimiento con la fecha: 5/11/2013 
USE `saco_roto`;
DROP procedure IF EXISTS `ult_fecha_prueba`;

DELIMITER $$
USE `saco_roto`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ult_fecha_prueba`()
BEGIN
drop temporary table if exists maxi;
create temporary table maxi
SELECT nro_persona, cod_tipo_prenda, max(fecha_prueba) ult_fecha
from pruebas
where fecha_prueba <= fecha_in
group by  1,2;

select p.apellido, p.nombre, pr.cod_tipo_prenda, desc_tipo_prenda,ult_fecha
from personas p 
inner join maxi on p.nro_persona = maxi.nro_persona
inner join pruebas pr on p.nro_persona = pr.nro_persona 
                      and pr.cod_tipo_prenda = maxi.cod_tipo_prenda 
                      and pr.fecha_prueba = ult_fecha
inner join tipos_prendas tp on pr.cod_tipo_prenda = tp.cod_tipo_prenda
order by ult_fecha desc, apellido asc;
END$$

DELIMITER ;

call `ult_fecha_prueba`("2013-11-05");


#5.a
#a) Crear la tabla: UNIDADES_MEDIDA con los atributos cod_unidad (clave primaria) y desc_unidad. Nota: Se sugiere
#indicar el atributo cod_unidad como auto-incremental
CREATE TABLE `saco_roto`.`unidades_medida` (
  `cod_unidad` INT NOT NULL AUTO_INCREMENT,
  `desc_unidad` VARCHAR(45) NULL,
  PRIMARY KEY (`cod_unidad`));
  
#b) Registrar en la tabla UNIDADES_MEDIDA creada las diferentes unidades de medida que existan en la tabla de
#MATERIALES
start transaction;
	insert into unidades_medida (desc_unidad)
    select distinct mat.unidad
    from materiales mat;
commit;
 
 #c) Agregar el atributo cod_unidad a la tabla de MATERIALES 
ALTER TABLE `saco_roto`.`materiales` 
ADD COLUMN `cod_unidad` INT NULL AFTER `unidad`;

#d) d) Actualizar el atributo cod_unidad de la tabla de MATERIALES con el correspondiente cod_unidad de la tabla
#UNIDADES_MEDIDA 

start transaction;
    update materiales
    SET cod_unidad = (select um.cod_unidad from unidades_medida um where um.desc_unidad = materiales.unidad);
commit;

#e) 

ALTER TABLE `saco_roto`.`materiales` 
ADD INDEX `cod_unidad_idx` (`cod_unidad` ASC) VISIBLE;
;
ALTER TABLE `saco_roto`.`materiales` 
ADD CONSTRAINT `cod_unidad`
  FOREIGN KEY (`cod_unidad`)
  REFERENCES `saco_roto`.`unidades_medida` (`cod_unidad`)
  ON DELETE RESTRICT
  ON UPDATE CASCADE;
