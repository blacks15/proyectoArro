DROP PROCEDURE IF EXISTS spInsDelUsuarios;

DELIMITER $$
CREATE PROCEDURE spInsDelUsuarios (
	IN pCodigo BIGINT,
	IN pNombreUsuario VARCHAR(10),
	IN pPaswword VARCHAR(100),
    IN pTipo BIGINT,
	IN pStatus VARCHAR(15),
	IN pBandera INT,
	OUT codRetorno CHAR(3),
	OUT msg VARCHAR(100),
	OUT msgSQL VARCHAR(100)
)
-- ============================================================
-- Author:       	Felipe Monzón Mendoza
-- Create date: 	28/Abr/2017
-- Description:   	Procedimiento para guardar/Eliminar Usuario 
-- ============================================================
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
			
	IF (pCodigo = 0 || pBandera = 0 || pNombreUsuario = '') THEN
		SET msg = 'Parametros Vacios';
		SET CodRetorno = '002';
	ELSE
		IF (pBandera = 2 ) THEN
			IF EXISTS(SELECT * FROM usuarios WHERE matricula_empleado = pCodigo) THEN
                START TRANSACTION;
                    DELETE FROM usuarios WHERE matricula_empleado = pCodigo AND nombre_usuario = CONVERT(pNombreUsuario USING utf8) COLLATE utf8_general_ci ;
                    UPDATE empleados SET isUsu = '0' WHERE matricula = pCodigo AND status = 'DISPONIBLE';
                    SET codRetorno = '000';
                    SET msg = 'Usuario Desasociado con Exito';
                COMMIT; 
			ELSE
				SET codRetorno = '001';
				SET msg = 'El Usuario no Existe';
				ROLLBACK;
			END IF;
		ELSEIF (pBandera = 1) THEN 
			IF ( pNombreUsuario = '' || pPaswword = '' || pStatus = '' || pTipo = 0) THEN
				SET msg = 'Parametros Vacios';
				SET CodRetorno = '002';
			ELSE
				IF NOT EXISTS(SELECT * FROM usuarios WHERE nombre_usuario = CONVERT(pNombreUsuario USING utf8) COLLATE utf8_general_ci) THEN
					START TRANSACTION;
						INSERT INTO usuarios (nombre_usuario,password,tipo_usuario,matricula_empleado,status,fechaCreacion,fechaModificacion)
						VALUES (pNombreUsuario, pPaswword, pTipo, pCodigo, pStatus,NOW(), NOW() );
						SET codRetorno = '000';
						SET msg = 'Usuario Guardado con Exito';
					COMMIT;
				ELSE
					SET codRetorno = '001';
					SET msg = 'El Usuario ya Existe';
					ROLLBACK;
				END IF; 
			END IF;
		END IF;
	END IF;
END$$
DELIMITER ;