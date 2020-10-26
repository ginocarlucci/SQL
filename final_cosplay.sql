#DDL:
#1. (Evaluación: Esta consigna es eliminatoria). Desarrolle las sentencias DDL requeridas para
#completar la definición de las tablas EMPLEADO, COSTO_HORA_ARTESANO y ESPECIALIDAD y
#sus relaciones con otras tablas.
CREATE TABLE `cosplay`.`empleado` (
  `legajo` INT NOT NULL,
  `tipo` VARCHAR(45) NULL,
  `email` VARCHAR(45) NULL,
  `direccion` VARCHAR(45) NULL,
  `telefono` INT NULL,
  `apellido` VARCHAR(45) NULL,
  `nombre` VARCHAR(45) NULL,
  `cuil` INT NULL,
  PRIMARY KEY (`legajo`));


CREATE TABLE `cosplay`.`costo_hora_artesano` (
  `legajo_empleado` INT NOT NULL,
  `fecha_valor` DATETIME NOT NULL,
  `valor_hora` DECIMAL NULL,
  PRIMARY KEY (`legajo_empleado`, `fecha_valor`),
  CONSTRAINT `fk_costo_hora_artesano_empleado`
    FOREIGN KEY (`legajo_empleado`)
    REFERENCES `cosplay`.`empleado` (`legajo`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE);


CREATE TABLE `cosplay`.`especialidad` (
  `codigo` INT NOT NULL,
  `descripcion` VARCHAR(45) NULL,
  PRIMARY KEY (`codigo`));

CREATE TABLE `cosplay`.`artesano_especialidad` (
  `legajo_artesano` INT NOT NULL,
  `codigo_especialidad` INT NOT NULL,
  PRIMARY KEY (`legajo_artesano`, `codigo_especialidad`),
  INDEX `fk_artesano_especialidad_especialidad_idx` (`codigo_especialidad` ASC) VISIBLE,
  CONSTRAINT `fk_artesano_especialidad_empleado`
    FOREIGN KEY (`legajo_artesano`)
    REFERENCES `cosplay`.`empleado` (`legajo`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_artesano_especialidad_especialidad`
    FOREIGN KEY (`codigo_especialidad`)
    REFERENCES `cosplay`.`especialidad` (`codigo`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE);
    
#me faltan dos mas q n tengo ganas

#DML:
#2. Ranking de clientes. Indicar: Número de cliente, cuil/cuit, nombre, email, cantidad de
#trabajos encargados y sumatoria de importes presupuestados. Ordenar sumatoria de importes
#en forma descendente y por cantidad de trabajos en forma ascendente.
select clie.nro, count(t.nro) as cantidad_trabajos_encargados, sum(t.importe_presup) as importe
from cliente clie
inner join trabajo t on clie.nro = t.nro_cliente
group by 1
order by importe DESC, cantidad_trabajos_encargados ASC;

#3. Lista de costo de materiales. Indicar código del material, descripción, unidad de medida,
#color y valor actual.
drop temporary table if exists costos_actuales;
create temporary table costos_actuales
(
	select cm.codigo_material, max(cm.fecha_valor) fecha
    from costo_material cm
    group by 1
);

select m.codigo, m.descripcion, m.unidad_medida, m.color, costo_material.valor_unit
from material m
inner join costo_material on m.codigo = costo_material.codigo_material
inner join costos_actuales on costo_material.codigo_material = costos_actuales.codigo_material
							and costo_material.fecha_valor = costos_actuales.fecha;

#4. Trabajos pendientes: Listar los trabajos que no estén terminados al día de hoy. Indicar
#número de trabajo, fecha límite de confección, importe presupuestado, y para cada ítem del
#trabajo que no esté finalizado indicar el número de ítem, el detalle, y por cada tarea no
#completada el código del tipo de tarea, detalle de la tarea fecha y hora de inicio, horas
#estimadas y sumatoria de horas reales trabajadas para dicha tarea.
select t.nro, t.fecha_limite_conf, t.importe_presup, i.nro_item, i.detalle, tar.codigo_tipo_tarea,
		sum(et.hs_trabajadas_reales) as horas
from trabajo t
inner join item i on t.nro = i.nro_trabajo
inner join tarea tar on i.nro_trabajo = tar.nro_trabajo
					and i.nro_item = tar.nro_item
left join ejecucion_tarea et on et.nro_trabajo = tar.nro_trabajo
							and et.nro_item = tar.nro_item
                            and et.codigo_tipo_tarea = tar.codigo_tipo_tarea
where t.fecha_fin_confec is null
	and t.fecha_confirmacion is not null
	and tar.fecha_hora_fin is null
group by 1,2,3,4,5,6;

#5. Artesanos excediendo el máximo de horas al mes: realizar un procedimiento almacenado
#que calcule las horas trabajadas reales totales por artesano en el mes (usando la fecha de
#inicio) y liste aquellos que exceden el máximo de horas que deberían haber trabajado en el
#mes. El procedimiento almacenado debe recibir como parámetros el mes, el año y el máximo
#de horas. Debe listar los artesanos indicando legajo, cuil, nombre, apellido, descripción de la
#especialidad, cantidad total de horas trabajadas y horas excedidas. Al finalizar invocar el
#procedimiento.
USE `cosplay`;
DROP procedure IF EXISTS `exceso_artesanos`;

DELIMITER $$
USE `cosplay`$$
CREATE PROCEDURE `exceso_artesanos` (in mes INT, in anio int, in mh int)
BEGIN

select emp.legajo, emp.cuil, emp.nombre, emp.apellido, e.descripcion, 
		sum(et.hs_trabajadas_reales) as cantidad_horas, sum(et.hs_trabajadas_reales) - mh
from ejecucion_tarea et
inner join empleados emp on emp.legajo = et.legajo_artesano
inner join artesano_especialidad ae on emp.legajo = ae.legajo_artesano
inner join especialidad e on e.codigo = ae.codigo_especialidad
inner join tareas tar on tar.nro_trabajo = et.nro_trabajo
					and tar.nro_item = et.nro_item
                    and tar.codigo_tipo_tarea = et.codigo_tipo_tarea
where year(tar.fecha_hora_inicio) = anio
	and month(tar.fecha_hora_inicio) = mes
group by 1,2,3,4,5
having cantidad_horas > mh;
END$$

DELIMITER ;

#Para realizar pruebas usar Octubre de 2018 y 10 hs
call exceso_artesanos(10,2018,10);

#TCL:
#6. Actualización de precios: Debido al aumento en los costos de los proveedores, la empresa
#debe actualizar los costos de los materiales. El aumento regirá a partir del lunes próximo. El
#aumento en los materiales será de un 30% a los que tengan un importe menor a $2000 y de
#20% a los que tengan un importe mayor o igual a $2000.

start transaction;

drop temporary table if exists fec_costo_act;
create temporary table fec_costo_act
select codigo_material, max(fecha_valor) ult_fec
from costo_material cm
where fecha_valor<=current_date
group by codigo_material;

insert into costo_material
select cm.codigo_material, current_date, valor_unit*1.30 
from costo_material cm
inner join fec_costo_act on cm.codigo_material = fec_costo_act.codigo_material
						and cm.fecha_valor = fec_costo_act.ult_fec
where cm.valor_unit < 2000;

insert into costo_material
select cm.codigo_material, current_date, valor_unit*1.20 
from costo_material cm
inner join fec_costo_act on cm.codigo_material = fec_costo_act.codigo_material
						and cm.fecha_valor = fec_costo_act.ult_fec
where cm.valor_unit >= 2000;

commit;