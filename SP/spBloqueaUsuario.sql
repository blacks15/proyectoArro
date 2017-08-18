DROP PROCEDURE IF EXISTS spBloqueaUsuario;

DELIMITER $$
CREATE PROCEDURE spBloqueaUsuario (
	IN pUsuario VARCHAR(10),
	OUT codRetorno CHAR(3),
	OUT msg VARCHAR(100),
	OUT msgSQL VARCHAR(100)
)
-- =======================================================
-- Author:       	Felipe Monzón Mendoza
-- Create date: 	08/Ago/2017
-- Description:   	Procedimiento para Bloquear un Usuario
-- =======================================================
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
		@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
		SET msgSQL = @full_error;
		SET codRetorno = '002';
		RESIGNAL;
		ROLLBACK;
	END; 
	DECLARE EXIT HANDLER FOR SQLWARNING
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
		@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
		SET msgSQL = @full_error;
		SET codRetorno = '002';
		SHOW WARNINGS LIMIT 1;
		RESIGNAL;
		ROLLBACK;
	END;

	IF (pUsuario = '') THEN
		SET codRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE		
		IF EXISTS (SELECT * FROM usuarios WHERE nombre_usuario = CONVERT(pUsuario USING utf8) COLLATE utf8_general_ci) THEN
			START TRANSACTION;
                UPDATE usuarios SET status = 'BLOQUEADO' WHERE nombre_usuario = CONVERT(pUsuario USING utf8) COLLATE utf8_general_ci;
                SET CodRetorno = '000';
                SET msg = 'SP Ejecutado Correctamente';
            COMMIT; 
		ELSE 
            ROLLBACK;
			SET codRetorno = '001';
			SET msg = 'El Usuario no Existe';
		END IF;
	END IF;
END$$
DELIMITER ;
