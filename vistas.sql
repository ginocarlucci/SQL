#VISTAS
#En teoría de bases de datos, un vista es una consulta que se presenta como una tabla (virtual)
#a partir de un conjunto de tablas en una base de datos relacional. Las vistas tienen la misma 
#estructura que una tabla: filas y columnas. La única diferencia es que sólo se almacena de ellas
#la definición, no los datos.

#1
drop view if exists vw_instructores;
create view vw_instructores as 
select concat(i.nombre, i.apellido) as 'Nombre y apellido', i.tel, i.email
from instructores i;
select * from vw_instructores;

#2
drop view if exists vw_cursos_2015;
create view vw_cursos_2015 as
select c.`nom_plan` 'Nombre del Plan', p.`desc_plan` 'Descripcion del Plan',
		c.`nro_curso` 'Nro. del Curso', c.`fecha_ini` 'Fecha Inicio',
		c.`fecha_fin` 'Fecha Fin', c.`salon`, c.`cupo`,
count(*) 'Cantidad Alumnos'
from cursos c
inner join plan_capacitacion p on c.nom_plan = p.nom_plan
inner join inscripciones ins on c.nom_plan = ins.nom_plan
							and c.nro_curso = ins.nro_curso
where c.fecha_ini >= '2015-01-01' and c.fecha_fin <= '2015-12-30'
group by 1,2,3,4,5,6,7;
select * from vw_cursos_2015;

#3
drop view if exists vw_cursos_costos_2015;
create view vw_cursos_costos_2015 as
select c.`nom_plan`, p.`desc_plan`,
		c.`nro_curso`, c.`fecha_ini`,
		c.`fecha_fin`, c.`salon`, c.`cupo`, vp.fecha_desde_plan,
count(*)
from cursos c
inner join plan_capacitacion p on c.nom_plan = p.nom_plan
inner join inscripciones ins on c.nom_plan = ins.nom_plan
							and c.nro_curso = ins.nro_curso
inner join valores_plan vp on vp.nom_plan = c.nom_plan
where c.fecha_ini >= '2009-01-01'
group by 1,2,3,4,5,6,7;

drop temporary table if exists costos_actualizados;
create temporary table costos_actualizados
(
	select vp.nom_plan, max(vp.fecha_desde_plan) fechamax
    from valores_plan vp
    group by 1
);

select *  
from vw_cursos_costos_2015 vwcc
inner join costos_actualizados ca on vwcc.nom_plan = ca.nom_plan
							and vwcc.fecha_ini = ca.fechamax;
                            
#SQL4
CREATE VIEW alumplan 
AS SELECT a.dni, concat( nombre, " ", apellido ) Nomyape, e.nom_plan,
		e.nro_curso, avg( nota ) prom
FROM alumnos a
INNER JOIN inscripciones i ON a.dni = i.dni
INNER JOIN evaluaciones e ON e.dni = i.dni
AND e.nom_plan = i.nom_plan
AND e.nro_curso = i.nro_curso
GROUP BY 1 , 2, 3, 4;

CREATE TEMPORARY TABLE impagos
(
SELECT dni, count( * ) cantidad
FROM cuotas
WHERE fecha_pago IS NULL
GROUP BY 1
);

SELECT Nomyape, nom_plan, nro_curso, prom, cantidad
FROM alumplan a
LEFT JOIN impagos i ON a.dni = i.dni