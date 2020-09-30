#STORE PROCEDURE AND FUNCTIONS

#Crear un procedimiento almacenado llamado plan_lista_precios_actual que devuelva los
#planes de capacitación indicando:
#nom_plan modalidad valor_actual
DELIMITER $$
USE `afatse`$$
CREATE PROCEDURE plan_lista_precios_actual()
BEGIN
drop temporary table if exists precios_actuales;
create temporary table precios_actuales
(
select vp.nom_plan, max(vp.fecha_desde_plan) fecha
from valores_plan vp
group by vp.nom_plan
); 

select pc.nom_plan, pc.modalidad, vp.valor_plan
from plan_capacitacion pc
inner join precios_actuales on pc.nom_plan = precios_actuales.nom_plan
inner join valores_plan vp on vp.nom_plan = precios_actuales.nom_plan
						and vp.fecha_desde_plan = precios_actuales.fecha;
END$$
DELIMITER ;

#Crear un procedimiento almacenado llamado plan_lista_precios_a_fecha que dada una
#fecha devuelva los planes de capacitación indicando:
#nombre_plan modalidad valor_a_fecha
DELIMITER $$
USE `afatse`$$
CREATE PROCEDURE plan_lista_precios_actual(in fecha_hasta date)
BEGIN
drop temporary table if exists precios_actuales;
create temporary table precios_actuales
(
select vp.nom_plan, max(vp.fecha_desde_plan) fecha
from valores_plan vp
where vp.fecha_desde_plan <= fecha_hasta
group by vp.nom_plan
); 

select pc.nom_plan, pc.modalidad, vp.valor_plan
from plan_capacitacion pc
inner join precios_actuales on pc.nom_plan = precios_actuales.nom_plan
inner join valores_plan vp on vp.nom_plan = precios_actuales.nom_plan
						and vp.fecha_desde_plan = precios_actuales.fecha;
END$$
DELIMITER ;

#Modificar el procedimiento almacenado creado en 1) para que internamente invoque al
#procedimiento creado en 2).
DELIMITER $$
USE `afatse`$$
drop procedure plan_lista_precios_actual;
create procedure plan_lista_precios_actual
BEGIN
CALL plan_lista_precios_actual(CURRENT_DATE);
END$$
DELIMITER ;

#Crear un procedimiento almacenado llamado alumnos_pagos_deudas_a_fecha que dada
#una fecha y un alumno indique cuanto ha pagado hasta esa fecha y cuantas cuotas
#adeudaba a dicha fecha (cuotas emitidas y no pagadas). Devolver los resultados en
#parámetros de salida.

DELIMITER $$
USE `afatse`$$
drop procedure alumnos_pagos_deudas_a_fecha;
create procedure alumnos_pagos_deudas_a_fecha(in fecha DATE, in dniAl int, OUT pagado float, OUT cant_adeudado int)
BEGIN
select sum(cuo.importe_pagado) INTO @pagado
from cuotas cuo
where cuo.dni = dniAl and cuo.fecha_emision <= fecha and cuo.fecha_pago is not null;

select count(*) into @cant_adeudado
from cuotas cuo
where cuo.fecha_pago is null and cuo.fecha_emision <= fecha and cuo.dni = dniAL;

set pagado:=@pagado;
set cant_adeudado:=@cant_adeudado;

END$$
DELIMITER ;

call alumnos_pagos_deudas_a_fecha(101010, 2013-06-01, @pagado, @cant_adeudado);
select @pagado, @cant_adeudado;

#Crear una función llamada alumnos_deudas_a_fecha que dado un alumno y una fecha
#indique cuantas cuotas adeuda a la fecha.

DELIMITER $$
USE `afatse`$$
drop function alumnos_pagos_deudas_a_fecha;
create function alumnos_pagos_deudas_a_fecha(in fecha DATE, in dniAl int)
returns float
BEGIN
select count(*) into cant_adeudado
from cuotas cuo
where cuo.fecha_pago is null and cuo.fecha_emision <= fecha and cuo.dni = dniAL;
return cant_adeudado;
END$$
DELIMITER ;

#Crear un procedimiento almacenado llamado alumno_inscripcion que dados los datos de
#un alumno y un curso lo inscriba en dicho curso el día de hoy y genere la primera cuota con
#fecha de emisión hoy para el mes próximo.

DELIMITER $$
USE `afatse`$$
create procedure alumno_inscripcion(in dniAlumno int, in plan char, in nro int)
BEGIN

start transaction;
insert into inscripciones 
values (plan, nro, dniAlumno, CURRENT_DATE);
insert into cuotas 
values (plan, nro, dniAlumno, year(current_Date), month(current_date), current_date, null, null);
commit;

END$$
DELIMITER ;

#Crear un procedimiento almacenado llamado alumno_anula_inscripcion que elimine la
#inscripción del alumno. El mismo deberá tener en cuenta que el alumno no haya pagado
#ninguna cuota antes de eliminarlo. Si hay cuotas ya generadas pero impagas las mismas
#deberán ser eliminadas.

DELIMITER $$
USE `afatse`$$

CREATE PROCEDURE `alumno_anula_inscripcion`(IN plan CHAR(20), IN curso INTEGER(11), IN
alumno INTEGER(11))
BEGIN
	declare cuotas_pagas integer(11);
	select count(*) into cuotas_pagas
	from cuotas
	where nom_plan=plan and nro_curso=curso and dni=alumno
			and fecha_pago is not null;
	if cuotas_pagas<=0 then
		start transaction;
		delete from cuotas 
        where nom_plan=plan and nro_curso=curso
				and dni=alumno and fecha_pago is null;
		delete from inscripciones
        where nom_plan=plan and nro_curso=curso and dni=alumno;
		commit;
	end if;

END$$
DELIMITER ;
