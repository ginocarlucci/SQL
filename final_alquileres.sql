#DDL

#DML
#SQL2
#Indicar por empleado la cantidad de eventos que tuvo como coordinador. Mostrar CUIL, apellido, nombres y
#cantidad de eventos. Aquellos empleados que no fueron coordinadores en ningún evento indicar 0
select emp.cuil, emp.nombre, emp.apellido, count(e.cuilEmpleado) as 'cantidad eventos'
from empleados emp
left join eventos e on emp.cuil = e.cuilEmpleado
group by emp.cuil, emp.nombre, emp.apellido;

#SQL3
#Ranking de servicios contratados indicando: datos del servicio, suma de la cantidad del servicio contratado
#para todos los eventos y porcentaje de esta suma sobre la suma total de las cantidades de servicios
#contratados. Los servicios que no hayan sido contratados deberán figurar en la lista con cantidad total 0.
#Ordenar el ranking en forma descendente por porcentaje. 

select SUM(contrata.cantidad) into @cant_total
from contrata;

select ser.CodServicio, ser.DescServicio, sum(c.cantidad) cantidad, sum(c.cantidad) * 100 / @cant_total 'Porcentaje Total'
from  servicios ser
inner join   contrata c on c.CodServicio = ser.CodServicio
group by 1,2
order by 3 desc;

#SQL4
#Calcular el total a pagar del Evento 5. El total debe incluir: la suma de los valores pactados por las
#instalaciones más la suma de los totales de servicios contratados. NOTA: el total de un servicio se calcula
#como la cantidad del servicio contratada por el valor del servicio a la fecha del contrato del evento. 

select SUM(ie.valorpactado) INTO @vinstala
FROM instalaciones_eventos ie
WHERE ie.NroEvento = 5;

select ev.fechacontrato into @vfechacontrato
FROM eventos ev
WHERE ev.NroEvento = 5;

select SUM(c.cantidad * vs.valor) INTO @vservicios 
from  contrata c
INNER JOIN valores_servicios vs ON vs.CodServicio = c.CodServicio
						AND vs.fechadesde = (SELECT MAX(vsf.fechadesde)
												FROM valores_servicios vsf
												WHERE vsf.CodServicio = vs.CodServicio
												AND vsf.fechadesde <= @vfechacontrato)
WHERE c.NroEvento = 5;

SELECT @vinstala + @vservicios as 'Valores';

#SQL5
#STORE PROCEDURE (SP): Desarrollar un SP que dada una nueva descripción de un tipo de evento lo registre
#en la tabla correspondiente manteniendo la correlatividad de los códigos de tipos de evento 

DROP procedure IF EXISTS NuevoTipoEvento;
DELIMITER $$
USE `va_alquileres`$$
CREATE PROCEDURE NuevoTipoEvento (in Descripcion varchar(20))
BEGIN
select max(te.CodTipoEvento) into @codigo
from tipos_evento te;
insert into tipos_evento(CodTipoEvento, DescTipoEvento) values (@codigo+1, descripcion);
END$$
DELIMITER ;

call NuevoTipoEvento('Fiesta electronica');

#TCL
#SQL6
#Registrar los nuevos valores de servicios para la fecha de hoy en función de su valor anterior más un 20%. 
start transaction;
drop temporary table if exists tt_valfecha;
create temporary table tt_valfecha
select vs.CodServicio, max(vs.fechadesde) FechaDesde
FROM valores_servicios vs
where vs.fechadesde <= current_date()
group by 1;


INSERT INTO valores_servicios
SELECT tt.CodServicio, current_date(), vs.valor * 1.20
FROM tt_valfecha tt
INNER JOIN valores_servicios vs ON vs.CodServicio = tt.CodServicio
								AND vs.fechadesde = tt.FechaDesde;
COMMIT;



