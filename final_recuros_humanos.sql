#Final recursos humanos

#DML


#DML
#Indicar de los empleados que actualmente trabajan en el área de RRHH, de cuántas personas han realizado
#registro en el proceso de selección en el presente año. Mostrar Legajo, apellido y nombres del empleado y
#cantidad de personas de las que han realizado registro en el proceso de selección. Aquellos empleados que
#actualmente trabajan en el área de RRHH y que no han hecho registro en el proceso de selección listarlos con
#cantidad en cero.
#NOTAS:
#- para saber donde trabajan los empleados actualmente buscar el último cambio de puesto del empleado a la
#fecha de hoy y luego verificar si el empleado trabaja en el área de RRHH en ese cambio.
#- para la cantidad de personas se cuentan las distintas personas para las cuales el empleado de RRHH tiene
#registros en la tabla proceso de selección.)

select a.cod_area into @cod
from areas a
where a.denominacion = 'RRHH';

drop temporary table if exists emp_actuales;
create temporary table emp_actuales
(
	select legajo, max(fecha_ini) fecha
    from empleados_puestos emp_pue
    where emp_pue.fecha_ini <= current_date()
    group by legajo
);

select emp_actuales.legajo, emp.nombre, emp.apellido, count(distinct(concat(ps.tipo_doc, ps.nro_doc))) cantidad, ps.fecha_hora
from emp_actuales
inner join empleados_puestos ep on ep.legajo = emp_actuales.legajo
								and ep.fecha_ini = emp_actuales.fecha
inner join empleados emp on emp.legajo = emp_actuales.legajo
left join proceso_seleccion ps on emp_actuales.legajo = ps.legajo
								and ep.cod_area = @cod
where ps.fecha_hora >= '2018-01-01'
group by emp.legajo, emp.nombre, emp.apellido;

#Ranking de solicitudes para puestos de trabajo indicando: código y denominación del área, código y descripción
#del puesto de trabajo, cantidad de solicitudes registradas, porcentaje de solicitudes por puesto sobre la cantidad
#total de solicitudes registradas y suma de las cantidades de puestos solicitados. Ordenar el ranking en forma
#descendente por porcentaje de solicitudes.
# NOTA: el porcentaje deberá calcularse con solo dos dígitos decimales.
select count(*) into @cant
from solicitudes_puestos;

select sp.cod_area, a.denominacion, sp.cod_puesto, pdt.descripcion, count(*) cantidad, round((count(*)) * 100 / @cant) porcentaje,
sum(sp.cant_puestos_solic) 'cantidad puestos'
from solicitudes_puestos sp
inner join areas a on sp.cod_area = a.cod_area
inner join puestos_de_trabajo pdt on sp.cod_puesto = pdt.cod_puesto
group by 1,2,3,4
order by 5 desc;


#STORE PROCEDURE (SP): Desarrollar un SP para el registro inicial del proceso de selección, recibiendo como
#parámetros la fecha del día y el legajo del empleado que lanza el proceso.
# Tener en cuenta que para cada solicitud de puesto de trabajo activa (no tiene fecha de cancelación) se
#deberán registrar las personas que continuarán luego el proceso de selección:
# Las personas seleccionadas:
#- No deben ser o haber sido empleados de la empresa
#- No deben estar participando ya del proceso de selección para la solicitud
#- Debe haber una coincidencia en al menos dos de las competencias requeridas para el puesto de trabajo como
#excluyentes y las competencias que la persona incluyó en su curriculum.
#Recordar que el estado para estos registros será: Iniciado.

USE `recursos_humanos`;
DROP procedure IF EXISTS `procesoseleccion_ri`;

DELIMITER $$
USE `recursos_humanos`$$
CREATE PROCEDURE `procesoseleccion_ri` (in wfecha datetime, in wlegajo int)
BEGIN

select e.cod_estado INTO @westado from estados e;

INSERT INTO proceso_seleccion
SELECT sp.cod_area, sp.cod_puesto, sp.fecha_solic, c.tipo_doc, c.nro_doc, wfecha, wlegajo, '', westado
FROM solicitudes_puestos sp
INNER JOIN puestos_competencias pc ON pc.cod_area = sp.cod_area
									AND pc.cod_puesto = sp.cod_puesto
INNER JOIN curriculum c ON c.cod_competencia = pc.cod_competencia
LEFT JOIN empleados e ON e.tipo_doc = c.tipo_doc
						AND e.nro_doc = c.nro_doc
LEFT JOIN proceso_seleccion ps ON ps.cod_area = sp.cod_area
								AND ps.cod_puesto = sp.cod_puesto
								AND ps.fecha_solic = sp.fecha_solic
								AND ps.tipo_doc = c.tipo_doc
								AND ps.nro_doc = c.nro_doc
WHERE sp.fecha_canc is not null
					AND pc.excluyente = 'SI'
					AND ps.legajo is null
					AND ps.nro_doc IS NULL
group by 1,2,3,4,5
having count(distinct(c.cod_competencia)) >= 2;

END$$

DELIMITER ;


SELECT 
    sp.cod_area,
    sp.cod_puesto,
    sp.fecha_solic,
    c.tipo_doc,
    c.nro_doc,
    COUNT(DISTINCT (c.cod_competencia))
FROM
    solicitudes_puestos sp
        INNER JOIN
    puestos_competencias pc ON pc.cod_area = sp.cod_area
        AND pc.cod_puesto = sp.cod_puesto
        INNER JOIN
    curriculum c ON c.cod_competencia = pc.cod_competencia
WHERE
    sp.fecha_canc IS NOT NULL
        AND pc.excluyente = 'SI'
        AND CONCAT(c.tipo_doc, c.nro_doc) NOT IN (SELECT CONCAT(e.tipo_doc, e.nro_doc)
													FROM empleados e)
        AND CONCAT(c.tipo_doc, c.nro_doc) NOT IN (SELECT CONCAT(ps.tipo_doc, ps.nro_doc)
													FROM  proceso_seleccion ps
													WHERE ps.cod_area = sp.cod_area
													 AND ps.cod_puesto = sp.cod_puesto
												     AND ps.fecha_solic = sp.fecha_solic)
group by 1,2,3,4,5
having count(distinct(c.cod_competencia)) >= 2;



#TCL
#Registrar los nuevos valores hora para los puestos de trabajo para ser aplicados a partir del primer día del mes
#que viene. Los nuevos valores tendrán el siguiente incremento: para aquellos valores hora menores a $150 se
#realizará un incremento del 25%, para los mayores o iguales a $150 el incremento será de un 20%
start transaction;
	drop temporary table if exists TTsalarios_fecha;
	create temporary table TTsalarios_fecha(
	select s.cod_area, s.cod_puesto, max(s.fecha) 'fecha'
	from salario s
	where s.fecha <= current_date()
	group by 1,2);
    
    INSERT INTO salario
	SELECT tt.cod_area, tt.cod_puesto, '01-03-2018', round(s.valor_hora * 1.25,2)
	FROM ttsalarios_fecha tt
    INNER JOIN salario s
    ON s.cod_area = tt.cod_area
    and s.cod_puesto = tt.cod_puesto
    AND s.fecha = tt.fecha
    WHERE s.valor_hora >= 150;
    
	INSERT INTO salario
	SELECT tt.cod_area, tt.cod_puesto, '01-03-2018', round(s.valor_hora * 1.20,2)
	FROM ttsalarios_fecha tt
    INNER JOIN salarios s
    ON s.cod_area = tt.cod_area
    and s.cod_puesto = tt.cod_puesto
    AND s.fecha = tt.fecha
    WHERE s.valor_hora  < 150;
commit;