DROP PROCEDURE IF EXISTS spInsUpdAutor;

DELIMITER $$
CREATE PROCEDURE spInsUpdAutor (
	IN pCodigo BIGINT,
	IN pNombreAutor VARCHAR(50),
	IN pUsuario VARCHAR(15),
	IN pStatus VARCHAR(15),
	OUT CodRetorno CHAR(3),
	OUT msg VARCHAR(100)
)
-- =============================================
-- Author:       	Felipe Monzón Mendoza
-- Create date: 	28/Abr/2017
-- Description:   	Procedimiento para guardar un Autor 
-- =============================================
BEGIN
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
			
	IF (COALESCE(pCodigo,'') = '' && COALESCE(pNombreAutor,'') = '' && COALESCE(pUsuario,'') = ''  && COALESCE(pStatus,'') = '' ) THEN
		SET msg = 'Parametros Vacios';
	ELSE
		IF (pCodigo != 0 || COALESCE(pCodigo,'') = '') THEN
			IF EXISTS(SELECT * FROM autores WHERE codigo_autor = pCodigo) THEN
				IF NOT EXISTS(SELECT * FROM autores WHERE codigo_autor != pCodigo AND nombre_autor = CONVERT(pNombreAutor USING utf8) COLLATE utf8_general_ci ) THEN
					START TRANSACTION;
						UPDATE autores SET nombre_autor = pNombreAutor,fechaModificacion = NOW() WHERE codigo_autor = pCodigo;
						SET CodRetorno = '000';
						SET msg = 'Autor Actualizado con Exito';
					COMMIT; 
				ELSE 
					SET CodRetorno = '001';
					SET msg = 'El Nombre del Autor ya fue Registrado';
					ROLLBACK;
				END IF;
			ELSE
				SET CodRetorno = '001';
				SET msg = 'El Autor no Éxiste';
				ROLLBACK;
			END IF;
		ELSE 
			IF NOT EXISTS(SELECT * FROM autores WHERE nombre_autor = pNombreAutor) THEN
				START TRANSACTION;
					INSERT INTO autores (nombre_autor,usuario,status,fechaCreacion,fechaModificacion)
					VALUES (pNombreAutor, pUsuario, pStatus,NOW(), NOW() );
					SET CodRetorno = '000';
					SET msg = 'Autor Guardado con Exito';
				COMMIT;
			ELSE
				SET CodRetorno = '001';
				SET msg = 'El Autor ya Éxiste';
				ROLLBACK;
			END IF; 
		END IF; 
	END IF;
END$$
DELIMITER ;