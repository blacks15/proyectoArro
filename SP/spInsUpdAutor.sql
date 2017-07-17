DROP PROCEDURE IF EXISTS spInsUpdAutor;

DELIMITER $$
CREATE PROCEDURE spInsUpdAutor (
	IN pCodigo BIGINT,
	IN pNombreAutor VARCHAR(50),
	IN pUsuario VARCHAR(15),
	IN pStatus VARCHAR(15),
	OUT codRetorno CHAR(3),
	OUT msg VARCHAR(100),
	OUT msgSQL VARCHAR(100),
	OUT id INT
)
-- =================================================================
-- Author:       	Felipe Monzón Mendoza
-- Create date: 	28/Abr/2017
-- Description:   	Procedimiento para guardar o actualizar un Autor 
-- =================================================================
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
			
	IF (pNombreAutor = '' && pUsuario = ''  && pStatus = '' ) THEN
		SET codRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE
		IF (pCodigo != 0) THEN
			IF EXISTS(SELECT * FROM autores WHERE codigo_autor = pCodigo) THEN
				IF NOT EXISTS(SELECT * FROM autores WHERE codigo_autor != pCodigo AND nombre_autor = CONVERT(pNombreAutor USING utf8) COLLATE utf8_general_ci ) THEN
					START TRANSACTION;
						UPDATE autores SET nombre_autor = pNombreAutor,fechaModificacion = NOW() WHERE codigo_autor = pCodigo;
						SET codRetorno = '000';
						SET msg = 'Autor Actualizado con Exito';
						SELECT codigo_autor INTO id FROM autores WHERE codigo_autor = pCodigo;
					COMMIT; 
				ELSE 
					SET codRetorno = '001';
					SET msg = 'El Nombre del Autor ya fue Registrado';
					ROLLBACK;
				END IF;
			ELSE
				SET codRetorno = '001';
				SET msg = 'El Autor no Existe';
				ROLLBACK;
			END IF;
		ELSE 
			IF NOT EXISTS(SELECT * FROM autores WHERE nombre_autor = CONVERT(pNombreAutor USING utf8) COLLATE utf8_general_ci) THEN
				START TRANSACTION;
					INSERT INTO autores (nombre_autor,usuario,status,fechaCreacion,fechaModificacion)
					VALUES (pNombreAutor, pUsuario, pStatus,NOW(), NOW() );
					SET codRetorno = '000';
					SET msg = 'Autor Guardado con Exito';

					SET id =  LAST_INSERT_ID();
				COMMIT;
			ELSE
				SET codRetorno = '001';
				SET msg = 'El Autor ya Existe';
				SELECT codigo_autor INTO id FROM autores WHERE nombre_autor = CONVERT(pNombreAutor USING utf8) COLLATE utf8_general_ci;
				ROLLBACK;
			END IF; 
		END IF; 
	END IF;
END$$
DELIMITER ;