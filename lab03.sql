#LAB03

#SQL1
select s.apeynom, a.descripcion, sa.anio_incripcion, sa.mes_inscripcion
from socios s
inner join socios_actividades sa on s.nro_socio = sa.nro_socio
inner join actividades a on sa.cod_actividad = a.cod_actividad
where s.apeynom like 'Juan Perez';

#SQL2
#Marre, no necesito crear una table temp, directamente lo hago sobre la misma
select a.descripcion, a.hora_desde
from instalaciones i
inner join actividades a on i.cod_instalaciones = a.cod_instalacion
where a.descripcion like 'natac%'
order by a.hora_desde asc;

#SQL3
drop temporary table if exists ult_fech;
create temporary table ult_fech
(
select nro_socio, max(fecha_pago) fecha_pago
from liquidaciones liq
where fecha_pago <= current_date
group by nro_socio
);

select s.apeynom, ult_fech.fecha_pago
from socios s
inner join liquidaciones l on s.nro_socio = l.nro_socio
inner join ult_fech on s.nro_socio = ult_fech.nro_socio
					and l.fecha_pago = ult_fech.fecha_pago
group by s.apeynom;

#SQL4
select s.nro_socio
from socios s
where s.nro_socio not in
(
	select distinct nro_socio
    from liquidaciones l
    where l.fecha_pago is not null
);

#SQL5
select ser.cod_servicio, ser.desc_servicio, count(*) cantidad_periodos
from socios_serv_inst_mens ssim
inner join socios s on ssim.nro_socio = s.nro_socio
inner join servicios ser on ser.cod_servicio = ssim.cod_servicio
where s.apeynom like 'maría de los dolores'
group by ser.cod_servicio, ser.desc_servicio;

#SQL6
select s.nro_socio, sum(l.monto_total) monto, l.fecha_pago
from socios s 
inner join liquidaciones l on s.nro_socio = l.nro_socio
group by s.nro_socio, l.fecha_pago
having monto > 100;

#SQL7
select serv.`desc_servicio`, count(ssu.`fecha_uso`) cant_usos
from `servicios` serv inner join
     `servicios_instalaciones` si ON serv.`cod_servicio`=si.`cod_servicio`
                                  left join
     `socios_serv_inst_uso` ssu ON  ssu.`cod_servicio`=si.`cod_servicio`
                                and ssu.`cod_instalaciones`=si.`cod_instalaciones`
where serv.`tipo_servicio` like '%uso%'
group by si.`cod_servicio`,si.`cod_instalaciones`
order by cant_usos asc, serv.`desc_servicio` desc;


