#crear TRIGGERS para insertar los nuevos valores en archivo_historico cuando los
#alumnos sean ingresados o sus datos sean modificados. Registrar la fecha y hora actual
#con CURRENT_TIMESTAMP y el usuario actual con CURRENT_USER

DROP TRIGGER IF EXISTS `afatse`.`alumnos_BEFORE_INSERT`;
DELIMITER $$
USE `afatse`$$
CREATE DEFINER = CURRENT_USER TRIGGER `afatse`.`alumnos_BEFORE_INSERT` BEFORE INSERT ON `alumnos` FOR EACH ROW
BEGIN
insert into alumnos_historico
values(new.dni, current_timestamp(), new.nombre, new.apellido, new.tel, new.email,
		new.direccion, current_user());
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS `afatse`.`alumnos_AFTER_UPDATE`;
DELIMITER $$
USE `afatse`$$
CREATE DEFINER = CURRENT_USER TRIGGER `afatse`.`alumnos_AFTER_UPDATE` AFTER UPDATE ON `alumnos` FOR EACH ROW
BEGIN
insert into alumnos_historico
values(new.dni, current_timestamp(), new.nombre, new.apellido, new.tel, new.email,
		new.direccion, current_user());
END$$
DELIMITER ;

#Crear TRIGGERS para registrar los movimientos en las cantidades de los materiales en
#la tabla del histórico. En el caso de un nuevo material se debe registrar la cantidad
#inicial como la cantidad movida y SÓLO en el caso de un cambio en la cantidad registrar
#el cambio.

DROP TRIGGER IF EXISTS `afatse`.`materiales_AFTER_INSERT`;
DELIMITER $$
USE `afatse`$$
CREATE DEFINER = CURRENT_USER TRIGGER `afatse`.`materiales_AFTER_INSERT` AFTER INSERT ON `materiales` FOR EACH ROW
BEGIN
if new.cant_disponible is not null then
	insert into stock_movimientos( cod_material, cantidad_movida,
	cantidad_restante, usuario_movimiento)
	values (new.cod_material,new.cant_disponible,new.cant_disponible,CURRENT_USER);
 end if;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS `afatse`.`materiales_BEFORE_UPDATE`;

DELIMITER $$
USE `afatse`$$
CREATE DEFINER = CURRENT_USER TRIGGER `afatse`.`materiales_BEFORE_UPDATE` BEFORE UPDATE ON `materiales` FOR EACH ROW
BEGIN
	if new.cant_disponible is not null then
		set @cant_movida=new.cant_disponible-old.cant_disponible;
		if @cant_movida!=0 then
			insert into stock_movimientos( cod_material, cantidad_movida,
			cantidad_restante, usuario_movimiento)
			values (new.cod_material,@cant_movida,
			new.cant_disponible,CURRENT_USER);
		end if;
	end if;
END$$
DELIMITER ;

#Crear los TRIGGERS necesarios para actualizar la cantidad de inscriptos del curso, los
#mismos deberán dispararse al inscribir un nuevo alumno y al eliminar una inscripción.

DROP TRIGGER IF EXISTS `afatse`.`inscripciones_AFTER_INSERT`;
DELIMITER $$
USE `afatse`$$
CREATE DEFINER = CURRENT_USER TRIGGER `afatse`.`inscripciones_AFTER_INSERT` AFTER INSERT ON `inscripciones` FOR EACH ROW
BEGIN
	update cursos set cant_inscriptos = cant_inscriptos + 1
    where nom_plan = new.nom_plan and nro_curso = new.nro_curso;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS `afatse`.`inscripciones_AFTER_DELETE`;

DELIMITER $$
USE `afatse`$$
CREATE DEFINER = CURRENT_USER TRIGGER `afatse`.`inscripciones_AFTER_DELETE` AFTER DELETE ON `inscripciones` FOR EACH ROW
BEGIN
	update cursos set cant_inscriptos = cant_inscriptos - 1
    where nom_plan = old.nom_plan and nro_curso = old.nro_curso;
END$$
DELIMITER ;

#Crear un TRIGGER que una vez insertado el nuevo precio registre el usuario que lo
#ingresó.
DROP TRIGGER IF EXISTS `afatse`.`valores_plan_BEFORE_INSERT`;

DELIMITER $$
USE `afatse`$$
CREATE DEFINER = CURRENT_USER TRIGGER `afatse`.`valores_plan_BEFORE_INSERT` BEFORE INSERT ON `valores_plan` FOR EACH ROW
BEGIN
	set new.usuario_alta = current_user();	
END$$
DELIMITER ;







