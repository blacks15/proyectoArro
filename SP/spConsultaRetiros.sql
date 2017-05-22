DROP PROCEDURE IF EXISTS spConsultaRetiros;

DELIMITER $$
CREATE PROCEDURE spConsultaRetiros (
	IN pCodigo BIGINT,
	IN pInicio INT,
	IN pTamanio INT,
	IN pUsuario VARCHAR(15),
	OUT CodRetorno CHAR(3),
	OUT msg VARCHAR(100),
	OUT numFilas INT
)
-- =============================================
-- Author:       	Felipe Monzón Mendoza
-- Create date: 	21/May/2017
-- Description:   	Procedimiento para Consultar Retiros 
-- =============================================
BEGIN
	DECLARE vPerfil INT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
		@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
		SET msg = @full_error;
		SET CodRetorno = '002';
		RESIGNAL;
		ROLLBACK;
	END; 
	DECLARE EXIT HANDLER FOR SQLWARNING
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
		@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
		SET msg = @full_error;
		SET CodRetorno = '002';
		SHOW WARNINGS LIMIT 1;
		RESIGNAL;
		ROLLBACK;
	END;
	IF (pCodigo = NULL && pInicio = NULL && pTamanio = NULL) THEN
		SET CodRetorno = '002';
		SET msg = 'Parametros Vacios';
	ELSE		
		SELECT tipo_usuario INTO vPerfil FROM usuarios WHERE nombre_usuario = CONVERT(pUsuario USING utf8) COLLATE utf8_general_ci;

		IF (vPerfil = 1) THEN 
			IF (pCodigo > 0) THEN
				IF EXISTS (SELECT * FROM retiros WHERE folio = pCodigo) THEN
					SELECT COUNT(*) INTO numFilas FROM retiros WHERE folio = pCodigo;

					SELECT codigo_retiro,folio,fecha,empleado,cantidad,descripcion,status 
					FROM retiros 
					WHERE folio = pCodigo 
					ORDER BY folio ASC;
					SET msg = 'SP Ejecutado Correctamente';
					SET CodRetorno = '000'; 
				ELSE
					SET CodRetorno = '001'; 
					SET msg = 'No Hay Datos Para Mostrar';
				END IF;
			ELSE
				IF ( (SELECT COUNT(*) FROM retiros) > 0 ) THEN
					SELECT COUNT(*) INTO numFilas FROM retiros;

					SELECT codigo_retiro,folio,fecha,empleado,cantidad,descripcion,status 
					FROM retiros 
					ORDER BY folio ASC
					LIMIT pInicio, pTamanio;
					SET msg = 'SP Ejecutado Correctamente';
					SET CodRetorno = '000'; 
				ELSE
					SET CodRetorno = '001'; 
					SET msg = 'No Hay Datos Para Mostrar';
				END IF;
			END IF;
		ELSE
			IF (pCodigo > 0) THEN
				IF EXISTS (SELECT * FROM retiros WHERE folio = pCodigo AND usuario = CONVERT(pUsuario USING utf8) COLLATE utf8_general_ci) THEN
					SELECT COUNT(*) INTO numFilas FROM retiros WHERE folio = pCodigo AND usuario = CONVERT(pUsuario USING utf8) COLLATE utf8_general_ci;

					SELECT codigo_Retiro,folio,fecha,empleado,cantidad,descripcion,status 
					FROM retiros 
					WHERE folio = pCodigo AND usuario = CONVERT(pUsuario USING utf8) COLLATE utf8_general_ci
					ORDER BY folio ASC;
					SET msg = 'SP Ejecutado Correctamente';
					SET CodRetorno = '000'; 
				ELSE
					SET CodRetorno = '001'; 
					SET msg = 'No Hay Datos Para Mostrar';
				END IF;
			ELSE
				IF ( (SELECT COUNT(*) FROM retiros WHERE usuario = CONVERT(pUsuario USING utf8) COLLATE utf8_general_ci) > 0 ) THEN 
					SELECT COUNT(*) INTO numFilas FROM retiros WHERE usuario = CONVERT(pUsuario USING utf8) COLLATE utf8_general_ci;

					SELECT codigo_retiro,folio,fecha,empleado,cantidad,descripcion,status 
					FROM retiros 
					WHERE usuario = CONVERT(pUsuario USING utf8) COLLATE utf8_general_ci
					ORDER BY folio ASC
					LIMIT pInicio, pTamanio;
					SET msg = 'SP Ejecutado Correctamente';
					SET CodRetorno = '000'; 
				ELSE
					SET CodRetorno = '001'; 
					SET msg = 'No Hay Datos Para Mostrar';
				END IF;
			END IF;
		END IF;
	END IF;
END$$
DELIMITER ;
