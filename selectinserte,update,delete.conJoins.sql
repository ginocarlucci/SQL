#Insert select, update, delete con joins

#--------------------------------------------------insert select--------------------------------------------------

#Crear una nueva lista de precios para todos los planes de capacitación, a partir del
#01/06/2009 con un 20 por ciento más que su último valor. Eliminar las filas agregadas.
start transaction;
drop temporary table if exists fechas_actuales;

create temporary table fechas_actuales
(
	select nom_plan, max(fecha_desde_plan) fecha
    from valores_plan
    group by 1
);

insert into valores_plan (nom_plan, fecha_desde_plan, valor_plan)
select vp.nom_plan, '20090601', vp.valor_plan * 1.20
from valores_plan vp
inner join fechas_actuales on vp.nom_plan = fechas_actuales.nom_plan
							and vp.fecha_desde_plan = fechas_actuales.fecha;
commit;

#Crear una nueva lista de precios para todos los planes de capacitación, a partir del
#01/08/2009, con la siguiente regla: Los cursos cuyo último valor sea menor a $90
#aumentarlos en un 20% al resto aumentarlos un 12%.

start transaction;
drop temporary table if exists fechas_actuales;

create temporary table fechas_actuales
(
	select nom_plan, max(fecha_desde_plan) fecha
    from valores_plan
    group by 1
);

insert into valores_plan (nom_plan, fecha_desde_plan, valor_plan)
select vp.nom_plan, '20090801', case
									when vp.valor_plan < 90 then vp.valor_plan * 1.20
                                    when vp.valor_plan >= 90 then vp.valor_plan * 1.12
								end
from valores_plan vp
inner join fechas_actuales on vp.nom_plan = fechas_actuales.nom_plan
							and vp.fecha_desde_plan = fechas_actuales.fecha;
commit;

#Crear un nuevo plan: Marketing 1 Presen. Con los mismos datos que el plan Marketing 1
#pero con modalidad presencial. Este plan tendrá los mismos temas, exámenes y materiales
#que Marketing 1 pero con un costo un 50% superior, para todos los períodos de este año
#que ya estén definidos costos del plan.

start transaction;
insert into plan_capacitacion
select 'Marketing 1 Presen', desc_plan,hs,'presencial'
from plan_capacitacion
where nom_plan = 'Marketing 1';

insert into plan_temas
select 'Marketing 1 Presen', titulo,detalle
from plan_temas
where nom_plan = 'Marketing 1';

insert into examenes
select 'Marketing 1 Presen', nro_examen
from examenes
where nom_plan = 'Marketing 1';

insert into examenes_temas
select 'Marketing 1 Presen',titulo,nro_examen
from examenes_temas
where nom_plan= 'Marketing 1';

insert into valores_plan(nom_plan, fecha_desde_plan, valor_plan)
select 'Marketing 1 Presen',fecha_desde_plan,valor_plan*1.5
from valores_plan
where nom_plan= 'Marketing 1' and year(fecha_desde_plan)=2015;
commit;


#--------------------------------------------------Update join--------------------------------------------------

#Cambiar el supervisor de aquellos instructores que dictan Reparac PC Avanzada este año a
#66-66666666-6 (Franz Kafka).

start transaction;
update 
instructores ins
inner join cursos_instructores ci on ins.cuil = ci.cuil
set cuil_supervisor = '66-66666666-6'
where ci.nom_plan = 'Reparac PC Avanzada';
commit;

#Cambiar el horario de los cursos de que dicta este año Franz Kafka (cuil ) desde las 16 hs.
#Moverlos una hora más temprano.
start transaction;
update cursos_horarios ch
inner join cursos_instructores ci on ci.nro_curso = ch.nro_curso
								and ch.nom_plan = ci.nom_plan
inner join cursos c on ci.nom_plan = c.nom_plan
					and ci.nro_curso = c.nro_curso
set ch.hora_inicio=ADDTIME(ch.hora_inicio,-010000) ,ch.hora_fin=ADDTIME(ch.hora_fin,-010000)
where ci.cuil = '66-66666666-6' and ch.hora_inicio = 160000 and year(c.fecha_ini)=2009;
commit;

#--------------------------------------------------Delete join--------------------------------------------------
#Eliminar los exámenes donde el promedio general de las evaluaciones sea menor a 5.5.
#Eliminar también los temas que sólo se evalúan en esos exámenes. Ayuda​: Usar una tabla
#temporal para determinar el/los exámenes que cumplan en las condiciones y utilizar dichas
#tabla para los joins. Tener en cuenta las CF para poder eliminarlos.

start transaction;
drop temporary table if exists examenes_eliminados;
create temporary table examenes_eliminados
(
	select nom_plan, nro_examen, avg(nota) 'promedio'
    from evaluaciones eval
    group by 1,2
    having promedio < 5.5
);

delete ex, ex_te
from evaluaciones ev
inner join examenes_eliminados ee on ee.nom_plan = ev.nom_plan
					and ee.nro_examen = ev.nro_examen
inner join examenes_temas ex_te on ex_te.nom_plan = ev.nom_plan
					and ex_te.nro_examen = ev.nro_examen;

delete ex
from examenes_eliminados
inner join examenes ex on examenes_eliminados.nom_plan = ex.nom_plan
						and examenes_eliminados.nro_examen = ex.nro_examen;
commit;
