#DCL
#Crear el usuario ‘usuario’ con contraseña ‘entre’.
create user 'gino'@'localhost' identified by '1234';

#Cambiar la contraseña de usuario a ‘entrar’
#set password for 'gino'@'localhost' = PASSWORD('entrar');

#Darle permisos a usuario para realizar SELECT de todas las tablas de AGENCIA_PERSONAL.
GRANT SELECT ON agencia_personal.* to 'gino'@'localhost';

#Darle permisos al usuario para realizar (INSERT, UPDATE y DELETE) los datos de la tabla
#PERSONAS.
GRANT INSERT ON agencia_personal.Personas to 'gino'@'localhost';
GRANT DELETE ON agencia_personal.Personas to 'gino'@'localhost';
GRANT UPDATE ON agencia_personal.Personas to 'gino'@'localhost';
#O de otra forma
GRANT all PRIVILEGES ON agencia_personal.Personas to 'gino'@'localhost';

#Quitarle todos los permisos a usuario.
#REVOKE all PRIVILEGES ON agencia_personal.* FROM 'gino'@'localhost'; (nose pq me tira error)
revoke INSERT ON agencia_personal.Personas from 'gino'@'localhost';
revoke INSERT ON agencia_personal.Personas from 'gino'@'localhost';
revoke INSERT ON agencia_personal.Personas from 'gino'@'localhost';
revoke INSERT ON agencia_personal.Personas from 'gino'@'localhost';

#Darle permisos a usuario de realizar SELECT, INSERT y UPDATE sobre la vista vw_contratos.
GRANT UPDATE ON agencia_personal.vw_contratos to 'gino'@'localhost';
GRANT INSERT ON agencia_personal.vw_contratos to 'gino'@'localhost';
GRANT DELETE ON agencia_personal.vw_contratos to 'gino'@'localhost';