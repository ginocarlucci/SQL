#LAB06
#SQL1
select emp.cuil, emp.nombre, emp.apellido
from evento e 
inner join tipos_evento tp on e.cod_tipo_evento = tp.cod_tipo_evento
inner join empleados emp on e.cuil_empleado = emp.cuil
where tp.desc_tipo_evento like 'fiesta';

#SQL02
select ins.codigo, ins.tipo_instalacion
from instalaciones ins
inner join contrata con on ins.codigo = con.codigo_instalacion
where con.nombre_servicio like 'decorado';

#SQL03
select *
from organizadores org
where org.cuit not in
(
	select e.cuit_organizador
    from evento e
    inner join instalaciones_eventos in_env on e.nro_contrato = in_env.nro_contrato
    inner join instalaciones_servicios ins_ser on ins_ser.codigo_instalacion = in_env.codigo_instalacion
    where ins_ser.nombre_servicio like 'catering'
);

#SQL04
/*
select e.nro_contrato, count(*)
from evento e
inner join instalaciones_eventos ie on e.nro_contrato = ie.nro_contrato
inner join instalaciones_servicios ins_ser on ins_ser.codigo_instalacion = ie.codigo_instalacion
inner join servicios ser on ser.nombre = ins_ser.nombre_servicio
group by 1;
*/

