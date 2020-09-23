#LAB 04
#SQL1
select distinct c.cod_cargo, c.desc_cargo, se.cuit
from solicitudes_empresas se 
inner join cargos c on se.cod_cargo = c.cod_cargo
where c.cod_cargo = 6;

#SQL2
select e.cuit, e.razon_social
from empresas e
where e.cuit not in
(
	select c.cuit
    from contratos c
    where c.fecha_incorporacion >= '2007-01-01' and c.fecha_incorporacion <= '2007-12-31'
);

#SQL5
select e.cuit into @cuit
from empresas e
where e.razon_social like 'viejos amigos';

select e.razon_social, c.cod_cargo, c.desc_cargo
from solicitudes_empresas se
inner join cargos c on c.cod_cargo = se.cod_cargo
inner join empresas e on se.cuit = e.cuit
where se.cuit = @cuit and se.fecha_solicitud = '2007-09-21';

#SQL6	
select dni into @dni_eliseo
from personas
where dni = 27890765;

select @dni_eliseo;

select ent.dni, ent_ev.resultado ,c.cod_cargo ,e.cuit, ent.nombre_entrevistador
from entrevistas ent
inner join entrevistas_evaluaciones ent_ev on ent.nro_entrevista = ent_ev.nro_entrevista
inner join empresas e on e.cuit = ent.cuit
inner join cargos c on ent.cod_cargo = c.cod_cargo
where ent.dni = @dni_eliseo;

#SQL7
select pe.apellido, pe.fecha_nacimiento,
       ti.desc_titulo, pt.fecha_graduacion, c.desc_cargo
from personas pe
inner join antecedentes ant on ant.dni = pe.dni 
inner join cargos c on c.cod_cargo = ant.cod_cargo 
left join personas_titulos pt on pe.dni = pt.dni
left join titulos ti on ti.cod_titulo = pt.cod_titulo
where c.desc_cargo = 'Director de Obras'
and fecha_nacimiento between '1978-01-01' and '1988-12-31';

#SQL8
select e.cuit, sum(com.importe_comision)
from contratos c
inner join comisiones com on c.nro_contrato = com.nro_contrato
inner join empresas e on e.cuit = c.cuit
where com.fecha_pago is null
group by 1;

#SQL9
select pe.apellido, pe.fecha_registro_agencia, ti.desc_titulo, c.desc_cargo
from personas pe 
inner join personas_titulos pt on pe.dni = pt.dni
inner join titulos ti on pt.cod_titulo = ti.cod_titulo
inner join antecedentes ant on ant.dni = pe.dni
inner join cargos c on c.cod_cargo = ant.cod_cargo
WHERE ti.tipo_titulo = 'Universitario'
  and pe.dni not in (select co.dni from contratos co)
  and pt.fecha_graduacion is not null;
  
#SQL10
update contratos
set sueldo = sueldo * 1.20
where contratos.fecha_caducidad is null and fecha_finalizacion_contrato > '2008-02-27';

#SQL11
select c.cod_cargo, c.desc_cargo, count(*) cantidad_empresas
from solicitudes_empresas se
left join contratos con on se.cuit = con.cuit
					and se.cod_cargo = con.cod_cargo
                    and se.fecha_solicitud = con.fecha_solicitud
inner join cargos c on se.cod_cargo = c.cod_cargo
where con.nro_contrato is null
group by 1,2
order by cantidad_empresas desc;

#SQL12
select sum(c.importe_comision) into @total
from comisiones c
where c.fecha_pago is not null;

select @total;

select e.razon_social, count(*) cantidad_pagos, sum(com.importe_comision) importe_total, ((sum(com.importe_comision))*100/@total) porcentaje
from empresas e
inner join contratos c on e.cuit = c.cuit
inner join comisiones com on c.nro_contrato = com.nro_contrato
where com.fecha_pago is not null
group by 1;

#SQL13
START TRANSACTION;
insert into personas (dni, apeynom, fecha_nacimiento, fecha_registro_agencia)
values (30425782, 'Lousteau, Pedro', '1982-08-25', now());

insert into personas_titulos (dni, cod_titulo, fecha_graduacion)
values (30425782, 7, '2007-12-25');

insert into antecedentes (dni, cod_cargo, fecha_desde, fecha_hasta, cuit, persona_contacto)
values (30425782, 6, '2005-01-05', '2006-12-31','30-21098732-4', 'Juan Perez');

COMMIT; 