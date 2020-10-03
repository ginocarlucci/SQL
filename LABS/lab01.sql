#SQL1
select c.apeynom, c.direccion, c.password_web
from clientes c
where c.nro_tel = '4874962';

#SQL2
select count(c.password_web) as 'Clientes registrados', (count(*)-c.password_web) as 'Clientes no registrados'
from clientes c;

#SQL3
create temporary table val_del_dia
       (select vali.id_item, max(vali.fecha_valor) fecha_valor
                 from valores_item vali
                 where vali.fecha_valor<='2007-07-01'
                 group by vali.id_item);

select ped.fecha_pedido ,ped.id_pedido,ped.nro_factura,
         sum(detp.cantidad_detalle* val_item.valor_item) total
from pedidos ped
     inner join detalle_pedido detp
                                 on ped.fecha_pedido=detp.fecha_pedido
                                 and ped.id_pedido=detp.id_pedido
     inner join items
                        on detp.id_item=items.id_item
     inner join val_del_dia
                        on items.id_item=val_del_dia.id_item
     inner join valores_item val_item
                        on items.id_item=val_item.id_item
                        and val_del_dia.fecha_valor=val_item.fecha_valor
where ped.fecha_pedido='2007-07-06' and ped.id_pedido=5
group by ped.id_pedido;

drop table val_del_dia;

#SQL4
select count(p.id_pedido) as 'Pedidos de juan perez'
from empleados e
inner join pedidos p on e.cuil = p.cuil
where p.fecha_pedido='2007-07-05' and e.apeynom='Juan Perez';

#SQL5
select count(*) as 'Cantidad pedidos'
from clientes c 
inner join pedidos p on c.nro_tel = p.nro_tel
where p.fecha_pedido >= '2007-06-01' and p.fecha_pedido <= '2007-06-30'
	and c.nro_tel='4552007';
    
#SQL6
select distinct p.*
from pedidos p
inner join detalle_pedido dp on p.fecha_pedido = dp.fecha_pedido
							and p.id_pedido = dp.id_pedido
where p.estado_pedido='vigente' and dp.estado_detalle='Listo';

#SQL7
drop temporary table if exists val_act_item;
create temporary table val_act_item
(
	select 	vi.id_item, max(vi.fecha_valor), vi.valor_item
    from valores_item vi
    where vi.fecha_valor <= current_date
    group by vi.id_item
);

select distinct i.id_item, i.descripcion, vai.valor_item
from items i
inner join val_act_item vai on i.id_item = vai.id_item;

#SQL8
select i.id_item, i.descripcion, sum(dp.cantidad_detalle) as 'Cantidad Pedida'
from items i
inner join detalle_pedido dp on i.id_item = dp.id_item
where dp.fecha_pedido >= '2007-01-01' and dp.fecha_pedido <= '2007-12-31' and i.tiempo_preparacion is not null
group by i.id_item
order by 3 desc;

#SQL9
/* no funca :(
drop temporary table if exists val_act_item_fecha_0507;
create temporary table val_act_item_fecha_0507
(
	select 	vi.id_item, vi.fecha_valor, vi.valor_item
    from valores_item vi
    where vi.fecha_valor = '2007-07-05'
    group by vi.id_item
);

select sum(vaif.valor_item * pd.cantidad_detalle) as 'IMPORTE'
from pedidos p
inner join detalle_pedido pd on p.fecha_pedido = pd.fecha_pedido
							and p.id_pedido = pd.id_pedido
inner join items i on pd.id_item = i.id_item
inner join val_act_item_fecha_0507 vaif on i.id_item = vaif.id_item
where p.fecha_pedido = '2007-07-05'
*/

#SQL10
/*
drop temporary table if exists val_it;
create temporary table val_it
(
select id_item, max(fecha_valor) fecha_valor, valor_item
from valores_item vi
where fecha_valor <= current_date
group by id_item
);

select p.nro_factura, emp.cuil, sum(dp.cantidad_detalle), sum(dp.cantidad_detalle * vi.valor_item) as Total
from pedidos p
inner join detalle_pedido dp on dp.fecha_pedido = p.fecha_pedido
							and dp.id_pedido = p.id_pedido
inner join empleados emp on p.cuil = e.cuil
inner join items i on dp.id_item = i.id_items
inner join val_it vit on i.id_item = vit.id_item
inner join valores_item vi on vi.id_item = val_it.id_item
						and vi.fecha_valor = val_it.fecha_valor
where p.fecha_pedido = '2007-07-05'
group by p.nro_factura
order by Total desc
*/ #no va

#SQL 11
select c.nro_tel, c.apeynom
from clientes c
where c.nro_tel not in 
(
select distinct c.nro_tel
from clientes c 
inner join pedidos p on p.nro_tel = c.nro_tel
inner join detalle_pedido dp on dp.fecha_pedido = p.fecha_pedido
							and dp.id_pedido = p.id_pedido
inner join items i on dp.id_item = i.id_item
where i.descripcion = 'Tarta de carne' and c.nro_tel is not null
);

#SQL12
create temporary table ped_dia
(select ped.`fecha_pedido`,count(ped.`nro_mesa`) 'Pedidos Bar',count(*)-count(ped.`nro_mesa`) 'Pedidos Web'
from pedidos ped
where ped.`fecha_pedido`>='2007-07-01' and ped.`fecha_pedido`<='2007-07-31'
group by ped.`fecha_pedido`);

create temporary table items_dia
(select detp.`fecha_pedido`,items.`descripcion` item,sum(cantidad_detalle)'Cant Item'
from `detalle_pedido` detp
inner join items
      on detp.`id_item`=items.`id_item`
where detp.`fecha_pedido`>='2007-07-01' and detp.`fecha_pedido`<='2007-07-31'
group by detp.`fecha_pedido`,items.`id_item`,items.`descripcion`);

select *
from ped_dia
     inner join items_dia
           on ped_dia.fecha_pedido=items_dia.fecha_pedido;

drop table ped_dia;
drop table items_dia;

#SQL13
start transaction;
	update  sueldos_basicos set sueldo_basico=sueldo_basico*1.07
	where fecha_valor='2007-08-01' and sueldo_basico>=1000;

	update  sueldos_basicos set sueldo_basico=sueldo_basico*1.1
	where fecha_valor='2007-08-01' and sueldo_basico<1000;
commit;
