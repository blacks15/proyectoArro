DROP PROCEDURE IF EXISTS spValidaUsuario;

DELIMITER $$
CREATE PROCEDURE spValidaUsuario (
	IN pNombre VARCHAR(10),
	IN pUsuario VARCHAR(10),
	OUT codRetono CHAR(3),
	OUT msg VARCHAR(100)
)
-- =============================================
-- Author:       	Felipe Monzón Mendoza
-- Create date: 	10/May/2017
-- Description:   	Procedimiento para Validar Usuarios 
-- =============================================
BEGIN

	DECLARE isAdmin INT;
	DECLARE vStatus VARCHAR(15);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
		@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
		SELECT @full_error;
		RESIGNAL;
		ROLLBACK;
	END; 
	DECLARE EXIT HANDLER FOR SQLWARNING
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
		@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
		SELECT @full_error;
		SHOW WARNINGS LIMIT 1;
		RESIGNAL;
		ROLLBACK;
	END;

	IF (pNombre = NULL && pUsuario = NULL) THEN
		SET codRetono = '004';
		SET msg = 'Parametros Vacios';
	ELSE		
		IF EXISTS (SELECT * FROM usuarios WHERE nombre_usuario = CONVERT(pNombre USING utf8) COLLATE utf8_general_ci) THEN
			SELECT tipo_usuario INTO isAdmin FROM usuarios WHERE nombre_usuario = CONVERT(pUsuario USING utf8) COLLATE utf8_general_ci ;

			IF (isAdmin != 1) THEN
				SELECT status INTO vStatus FROM usuarios WHERE nombre_usuario = CONVERT(pNombre USING utf8) COLLATE utf8_general_ci;
				IF (vStatus = 'DISPONIBLE') THEN
					SELECT u.matricula_empleado,u.tipo_usuario,u.nombre_usuario,u.status,
						CONCAT(e.nombre_empleado,' ',e.apellido_paterno,' ',e.apellido_materno) AS nombreEmpleado
					FROM usuarios u
					INNER JOIN empleados e ON e.matricula = u.matricula_empleado
					WHERE u.status = 'DISPONIBLE' AND nombre_usuario = CONVERT(pNombre USING utf8) COLLATE utf8_general_ci;
					SET codRetono = '000';
					SET msg = 'SP Ejecutado Correcamente';
				ELSE 
					SET codRetono = '001';
					SET msg = 'Usuario Bloqueado';
				END IF;
			ELSE
				SELECT u.matricula_empleado,u.tipo_usuario,u.nombre_usuario,u.status,
					CONCAT(e.nombre_empleado,' ',e.apellido_paterno,' ',e.apellido_materno) AS nombreEmpleado
				FROM usuarios u
				INNER JOIN empleados e ON e.matricula = u.matricula_empleado
				WHERE nombre_usuario = CONVERT(pNombre USING utf8) COLLATE utf8_general_ci;
				SET codRetono = '000';
				SET msg = 'SP Ejecutado Correcamente';
			END IF;
		ELSE 
			SET codRetono = '001';
			SET msg = 'El Usuario no Existe';
		END IF;
	END IF;
END$$
DELIMITER ;