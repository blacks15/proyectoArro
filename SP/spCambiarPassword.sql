DROP PROCEDURE IF EXISTS spCambiarPassword;

DELIMITER $$
CREATE PROCEDURE spCambiarPassword (
	IN pCodigo BIGINT,
	IN pNombreUsuario VARCHAR(10),
	IN pContrasenia VARCHAR(100),
	OUT codRetorno CHAR(3),
	OUT msg VARCHAR(100),
	OUT msgSQL VARCHAR(100)
)
-- =====================================================================
-- Author:       	Felipe Monzón Mendoza
-- Create date: 	17/May/2017
-- Description:   	Procedimiento para Cambiar la Contraseña del Usuario
-- =====================================================================
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
		@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
		SET codRetorno = '002';
		SET msgSQL = @full_error;
		RESIGNAL;
		ROLLBACK;
	END; 
	DECLARE EXIT HANDLER FOR SQLWARNING
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
		@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
		SET codRetorno = '002';
		SET msgSQL = @full_error;
		SHOW WARNINGS LIMIT 1;
		RESIGNAL;
		ROLLBACK;
	END;

	IF (pCodigo = 0 || pNombreUsuario = '' || pContrasenia = '') THEN
		SET codRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE
		IF EXISTS (SELECT * FROM usuarios WHERE matricula_empleado = pCodigo AND nombre_usuario = CONVERT(pNombreUsuario USING utf8) COLLATE utf8_general_ci ) THEN
			START TRANSACTION;
				UPDATE usuarios SET password = pContrasenia WHERE nombre_usuario = CONVERT(pNombreUsuario USING utf8) COLLATE utf8_general_ci AND matricula_empleado = pCodigo;
				SET codRetorno = '000';
				SET msg = 'Contraseña Actualizada con Exito';
			COMMIT; 
		ELSE
			SET codRetorno = '001';
			SET msg = 'El Usuario no Existe';
			ROLLBACK;
		END IF;
	END IF;
END$$
DELIMITER ;
