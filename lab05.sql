#LAB05
#SQL01
select maq.nro_serie, maq.tipo_maquina
from maquinarias maq
where maq.nro_serie not in
(
	select con.nro_serie_maquina
    from contratos con
);

#SQL02
select p.cuit, count(*) as cantidad, sum(cuo.importe) as importe
from personas p
inner join contratos con on p.cuit = con.cuit_cliente
inner join cuotas cuo on con.nro_contrato = cuo.nro_contrato
where cuo.fecha_pago is not null
group by 1;

#SQL03
select p.cuit, con.nro_contrato, count(*) as cantidad, sum(cuo.importe) as importe
from personas p
inner join contratos con on p.cuit = con.cuit_cliente
inner join cuotas cuo on con.nro_contrato = cuo.nro_contrato
where cuo.fecha_pago is not null
group by 1, 2
having importe > 250;

#SQL04
select p.cuit, con.nro_contrato, maq.nro_serie, maq.tipo_maquina, con.fecha_pago_limite, con.fecha_inicio_arren
from garante_contrato gc
inner join contratos con on gc.nro_contrato = con.nro_contrato
inner join personas p on p.cuit = gc.cuit_garante
inner join maquinarias maq on con.nro_serie_maquina = maq.nro_serie
where con.fecha_pago is null;

#SQL05
drop temporary table if exists val_serv;
create temporary table val_serv
(
	select vs.cod_servicio, max(vs.fecha_desde) fecha
    from valores_servicios vs
    where vs.fecha_desde <= '2008-05-11'
    group by 1
);

select s.cod_servicio, s.descripcion, vs.importe
from servicios s
inner join val_serv on s.cod_servicio = val_serv.cod_servicio
inner join valores_servicios vs on vs.cod_servicio = val_serv.cod_servicio
								and vs.fecha_desde = val_serv.fecha;
                                
#SQL06
select p.cuit, p.nomyape, c.nro_contrato,  sum(con.horas_consumidas) horas
from contrata_abono ca
inner join contratos c on c.nro_contrato = ca.nro_contrato
inner join personas p on c.cuit_cliente = p.cuit
inner join consumos con on con.nro_contrato = ca.nro_contrato
						and con.cod_servicio = ca.cod_servicio
group by 1, 2, 3
having horas = ca.horas_contratadas;

#SQL7
select p.cuit, p.nomyape, p.telefono, s.cod_servicio, s.descripcion, cont.nro_contrato, sum(con.horas_consumidas)*100/(sum(ca.horas_contratadas)) porcentaje
from personas p 
inner join contratos cont on cont.cuit_cliente = p.cuit
inner join contrata_abono ca on ca.nro_contrato = cont.nro_contrato
inner join servicios s on ca.cod_servicio = s.cod_servicio
inner join consumos con on con.nro_contrato = ca.nro_contrato
						and con.cod_servicio = ca.cod_servicio
group by 1, 2, 3, 4, 5, 6
order by porcentaje DESC;

#SQL08
select s.cod_servicio, s.descripcion, p.nomyape
from servicios s 
inner join personas p
where s.cod_servicio not in
(
	select ca.cod_servicio
    from contrata_abono ca
);

#SQL09
select con.nro_contrato, p.nomyape, max(cuo.fecha_pago) ultima_fecha, con.fecha_pago_limite
from contratos con 
inner join personas p on p.cuit = con.cuit_cliente
inner join cuotas cuo on con.nro_contrato = cuo.nro_contrato
group  by 1, 2
having max(cuo.fecha_pago) > con.fecha_pago_limite;

#SQL10
update contrata_abono set horas_contratadas = horas_contratadas*1.3
where horas_contratadas	< 10;

update contrata_abono set horas_contratadas = horas_contratadas*1.1
where horas_contratadas	> 10;

#SQL11
select p.*, clie.*
from contratos c
inner join garante_contrato gc on gc.nro_contrato = c.nro_contrato
inner join personas p on p.cuit = gc.cuit_garante
inner join personas clie on clie.cuit = c.cuit_cliente;
