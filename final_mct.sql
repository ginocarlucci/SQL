#DDL:
#1. (Evaluación: Esta consigna es eliminatoria). Desarrolle las sentencias DDL requeridas para completar
#la definición de las tablas CHOFERES_TURNOS y VIAJES.


#DML:
#2. Ranking de móviles. Indicar: Patente, cantidad de kilómetros recorridos en todos los viajes que realizó el
#móvil. Ordenar por cantidad de kilómetros recorridos en forma descendente.

SELECT vm.patente, sum(vm.km_fin - vm.km_ini) AS cantidadkilometros
from viajes_moviles vm
group by vm.patente
order by cantidadkilometros desc;

#3. Lista de precios. Indicar código del tipo de viaje, descripción y valor actual. Si el tipo de viaje aún no
#tiene ningún precio registrado, mostrar igual el tipo de viaje indicando esta situación.

drop temporary table if exists val_act;
create temporary table val_act
(
 select cod_tipo_viaje, max(fecha_desde) fec_val
 from tipos_viajes_valores
 where fecha_desde <= current_date
 group by cod_tipo_viaje
);

select tv.desc_tipo_viaje, tvv.valor_km
from tipos_viajes tv
     left join val_act on val_act.cod_tipo_viaje=tv.cod_tipo_viaje
		left join tipos_viajes_valores tvv on tvv.cod_tipo_viaje = val_act.cod_tipo_viaje
               and tvv.fecha_desde = val_act.fec_val;



#4. Importes adeudados: Listar los clientes que adeudan cuotas indicando: tipo y nro. de documento,
#nombre, teléfono, cantidad de cuotas vencidas, importe total adeudado e importe total de recargo al día
#de hoy.
#Recordar que las cuotas vencidas tienen un importe de recargo que se calcula: Recargo = cantidad de
#días de mora * porcentaje de recargo vigente * importe de la cuota / 100.
#Cantidad de días de mora = fecha actual – fecha vencimiento (Función DATEDIFF)

select r.PorcRecargoDiario INTO @recargo 
FROM recargos r 
WHERE r.FechaDesde = (select max(r1.fechadesde) FROM recargos r1);

select @recargo;

SELECT cli.tipo_doc, cli.nro_doc, cli.denominacion, cli.telefono,
	   SUM(cu.importe) Importe , 
       SUM(ROUND(@recargo * (datediff(current_date(), cu.fecha_venc)) * cu.importe / 100,2)) Recargo
from  cuotas cu
INNER JOIN viajes v ON v.nro_viaje = cu.nro_viaje
INNER JOIN contratos co ON co.nro_contrato = v.nro_contrato
INNER JOIN clientes cli ON cli.tipo_doc = co.tipo_doc
	AND cli.nro_doc = co.nro_doc
WHERE cu.fecha_pago is null AND cu.fecha_venc < current_date()
GROUP BY 1,2,3,4;

#5. Disponibilidad de móviles: realizar un procedimiento almacenado que analice la disponibilidad de
#móviles con una cierta capacidad o más (parámetro de entrada) para realizar un viaje casual. El
#procedimiento deberá listar Patente y capacidad de los móviles disponibles.
# Probar el procedimiento para la capacidad: 20

USE `manolo_carpa_tigre`;
DROP procedure IF EXISTS `sp_moviles_disp`;

DELIMITER $$
USE `manolo_carpa_tigre`$$
CREATE PROCEDURE `sp_moviles_disp` (in wcapacidad INT)
BEGIN
select m.patente, m.capacidad
from moviles m
where m.fecha_baja is null
AND m.patente not in
( select vm.patente
 from viajes v
   inner join viajes_moviles vm
         on v.nro_viaje=vm.nro_viaje
 where v.fecha_cancelacion is null
   AND v.estado = 'En Proceso'
   OR (v.fecha_ini = curdate()
   and v.estado = 'Pendiente'))
   And m.capacidad >= wcapacidad;

END$$

DELIMITER ;

CALL sp_moviles_disp(20);



#TCL:
#6. Actualización de precios: Debido a un aumento en los combustibles la empresa ha decidido un aumento
#de precios para el valor por km de los tipos de viajes. El aumento regirá a partir del lunes próximo. El
#aumento será de un 25% a los que tengan un importe menor a $100 y de 30% a los que tengan un
#importe mayor o igual a $100. 

START transaction;
	drop temporary table if exists val_act;
	create temporary table val_act
	(
		select cod_tipo_viaje, max(fecha_desde) fec_val
		from tipos_viajes_valores
		where fecha_desde <= current_date
		group by cod_tipo_viaje
	);

	INSERT INTO tipos_viajes_valores
    SELECT tvc.cod_tipo_viaje, '2018-07-09', tvc.valor_km * 1.30
    from tipos_viajes_valores tvc
    INNER JOIN val_act va
    ON va.cod_tipo_viaje = tvc.cod_tipo_viaje
    AND va.fec_val = tvc.fecha_desde
    WHERE tvc.valor_km >= 100;
    
    INSERT INTO tipos_viajes_valores
	SELECT tvc.cod_tipo_viaje, '2018-07-09',tvc.valor_km * 1.25
    from tipos_viajes_valores tvc
    INNER JOIN val_act va
    ON va.cod_tipo_viaje = tvc.cod_tipo_viaje
    AND va.fec_val = tvc.fecha_desde
    WHERE tvc.valor_km < 100;
commit;