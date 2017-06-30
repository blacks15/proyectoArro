DROP PROCEDURE IF EXISTS spInsUpdEditorial;

DELIMITER $$
CREATE PROCEDURE spInsUpdEditorial (
	IN pCodigo BIGINT,
	IN pNombreEditorial VARCHAR(50),
	IN pUsuario VARCHAR(15),
	IN pStatus VARCHAR(15),
	OUT CodRetorno CHAR(3),
	OUT msg VARCHAR(100),
	OUT msgSQL VARCHAR(100)
)
-- =============================================
-- Author:       	Pedro Ed Monzón Mendoza
-- Create date: 	30/Abr/2017
-- Description:   	Procedimiento para guardar y/o actualizar editoriales
-- =============================================
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
		@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
		SET msgSQL = @full_error;
		SET CodRetorno = '002';
		RESIGNAL;
		ROLLBACK;
	END; 
	DECLARE EXIT HANDLER FOR SQLWARNING
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
		@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
		SET msgSQL = @full_error;
		SET CodRetorno = '002';
		SHOW WARNINGS LIMIT 1;
		RESIGNAL;
		ROLLBACK;
	END;
			
	IF (pNombreEditorial = '' && pUsuario = '' && pStatus = '' ) THEN
		SET CodRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE
		IF (pCodigo != 0 ) THEN
			IF EXISTS(SELECT * FROM editoriales WHERE codigo_editorial = pCodigo) THEN
				IF NOT EXISTS(SELECT * FROM editoriales WHERE codigo_editorial != pCodigo AND nombre_editorial = CONVERT(pNombreEditorial USING utf8) COLLATE utf8_general_ci ) THEN
					START TRANSACTION;
						UPDATE editoriales SET nombre_editorial = pNombreEditorial,fechaModificacion = NOW() WHERE codigo_editorial = pCodigo;
						SET CodRetorno = '000';
						SET msg = 'Editorial Actualizado con Exito';
					COMMIT; 
				ELSE
					SET CodRetorno = '001';
					SET msg = 'El Nombre de la Editorial ya fue Registrado';
					ROLLBACK;
				END IF;
			ELSE
				SET CodRetorno = '001';
				SET msg = 'La Editorial no Éxiste';
			END IF;
		ELSE 
			IF NOT EXISTS(SELECT * FROM editoriales WHERE nombre_editorial = CONVERT(pNombreEditorial USING utf8) COLLATE utf8_general_ci ) THEN
				START TRANSACTION;
					INSERT INTO editoriales(nombre_editorial,usuario,status,fechaCreacion,fechaModificacion)
					VALUES (pNombreEditorial, pUsuario, pStatus,NOW(), NOW() );
					SET CodRetorno = '000';
					SET msg = 'Editorial Guardado con Exito';
				COMMIT;
			ELSE
				SET CodRetorno = '001';
				SET msg = 'La Editorial ya Éxiste';
				ROLLBACK;
			END IF; 
		END IF; 
	END IF;
END$$
DELIMITER ;