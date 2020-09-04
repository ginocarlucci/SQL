#LAB02

#SQL1
select cpe.nro_contrato, sc.nombre_servicio
from contratos_por_eventos cpe
inner join servicios_contratos sc on cpe.nro_contrato = sc.nro_contrato
where cpe.fecha_evento >= '2007-09-01' and cpe.fecha_evento <= '2007-09-30';

#SQL2
select sc.nombre_servicio, count(*) as Cantidad
from servicios_contratos sc
group by sc.nombre_servicio;

#SQL3
select p.apellidoynombre, cpe.nro_contrato, cpe.fecha_evento
from contratos_por_eventos cpe
inner join recibos_pago rp on cpe.nro_contrato = rp.nro_contrato
inner join personas p on cpe.idpersona = p.idpersona
where cpe.nro_contrato=2;

#SQL4
select p.dni, p.apellidoynombre, count(cpe.nro_contrato) as 'Cantidad eventos'
from personas p
inner join contratos_por_eventos cpe on p.idpersona = cpe.idpersona
group by 1, 2
order by 3 desc;

#SQL5
drop temporary table if exists val_ser;
create temporary table val_ser
(
select nombre_servicio, max(fecha_precio) fecha_precio, importe
from precios_servicios 
where fecha_precio <= '2007-09-25'
group by nombre_servicio
);

select cpe.nro_contrato, sum(ps.importe)+cpe.valor_serv_pers as 'Total'
from contratos_por_eventos cpe
inner join servicios_contratos sc on cpe.nro_contrato = sc.nro_contrato
inner join val_ser on val_ser.nombre_servicio = sc.nombre_servicio
inner join precios_servicios ps on ps.nombre_servicio = val_ser.nombre_servicio
								and ps.fecha_precio = val_ser.fecha_precio
where cpe.fecha_evento = '2007-09-25'
group by cpe.nro_contrato;

#SQL6
select ve.`dni`,
       sum(rp.`valor_abonado`)*(ve.`porcentaje_comision`/100)+ve.`sueldo_basico`,
       ve.`sueldo_basico`
from `contratos_por_eventos` c
     inner join `valores_empleados` ve
           on c.`dni_empleado`=ve.`dni`
     inner join `recibos_pago` rp
           on c.`nro_contrato`=rp.`nro_contrato`
where ve.`anio_valor`=2007 and ve.`mes_valor`=9
      and c.`fecha_evento`>='2007-09-01' and c.`fecha_evento`<='2007-09-31'
group by ve.`dni`;

#SQL7
select *
from personas p
where p.`fecha_tentativa`>'2007-11-24'
AND p.dni is null;

#SQL8
select e.dni,e.`apellidoynombres`,count(*) cant_serv
from empleados e
     inner join `contratos_por_eventos` c
           on e.`dni`=c.`dni_empleado`
     inner join `servicios_contratos` sc
           on c.`nro_contrato`=sc.`nro_contrato`
group by e.dni,e.`apellidoynombres`
order by cant_serv;

#SQL9
select p.`dni`,p.`apellidoynombre`,e.`dni`, e.`apellidoynombres`,count(*) cant_eventos
from personas p
     inner join `contratos_por_eventos` c
           on p.`idpersona`=c.`idpersona`
     inner join empleados e
           on e.`dni`=c.`dni_empleado`
group by p.`dni`,p.`apellidoynombre`,e.`dni`, e.`apellidoynombres`;

#SQL10
select p.apellidoynombre, cpe.nro_contrato, cpe.fecha_evento, count(*) cantidad_servicios
from personas p
inner join contratos_por_eventos cpe on p.idpersona = cpe.idpersona
inner join servicios_contratos sc on cpe.nro_contrato = sc.nro_contrato
group by p.apellidoynombre, cpe.nro_contrato, cpe.fecha_evento
having cantidad_servicios <= 3;

#SQL11
select p.*
from personas p
     inner join `contratos_por_eventos` c
           on p.`idpersona`=c.`idpersona`
where c.`salon_ubicacion` is null;

#SQL12
select *
from `personas`
where personas.`idpersona` not in (select p.`idpersona`
                                   from personas p
                                        inner join `contratos_por_eventos` c
                                                   on p.`idpersona`=c.`idpersona`
                                   where c.`salon_ubicacion` is null);
#SQL13
update `valores_empleados`
set sueldo_basico=sueldo_basico*1.07
where sueldo_basico>=1000 and anio_valor=2007 and mes_valor=10;

update `valores_empleados`
set sueldo_basico=sueldo_basico*1.1
where sueldo_basico<1000 and anio_valor=2007 and mes_valor=10;


