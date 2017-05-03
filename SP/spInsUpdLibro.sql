DROP PROCEDURE IF EXISTS spInsUpdLibro;

DELIMITER $$
CREATE PROCEDURE spInsUpdLibro (
	IN pCodigo BIGINT,
	IN pNombreLibro VARCHAR(50),
	IN pISBN VARCHAR(13),
	IN pAutor BIGINT,
	IN pEditorial BIGINT,
	IN pDescripcion VARCHAR(500),
	IN pUsuario VARCHAR(15),
	IN pStatus VARCHAR(10),
	OUT CodRetorno CHAR(3),
	OUT msg VARCHAR(100)
)
-- =============================================
-- Author:       	Felipe Monzón
-- Create date: 	30/Abr/2017
-- Description:   	Procedimiento para guardar y/o actualizar Libros
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
		
	IF (pCodigo != 0 || COALESCE(pCodigo,NULL) = NULL) THEN
		IF EXISTS(SELECT * FROM libros WHERE codigo_libro = pCodigo) THEN
			IF NOT EXISTS(SELECT * FROM libros WHERE codigo_libro != pCodigo AND nombre_libro = CONVERT(pNombreLibro USING utf8) COLLATE utf8_general_ci ) THEN
				START TRANSACTION;
					UPDATE libros SET nombre_libro = pNombreLibro,isbn = pISBN,autor = pAutor,editorial = pEditorial,descripcion = pDescripcion,fechaModificacion = NOW()
					WHERE codigo_libro = pCodigo;
					SET CodRetorno = '000';
					SET msg = 'Libro Actualizado con Exito';
				COMMIT; 
			ELSE
				SET CodRetorno = '001';
				SET msg = 'El Nombre del Libro ya fue Registrado';
				ROLLBACK;
			END IF;
		ELSE
			SET CodRetorno = '001';
			SET msg = 'El Libro no Éxiste';
		END IF;
	ELSE 
		IF NOT EXISTS(SELECT * FROM libros WHERE nombre_libro = CONVERT(pNombreLibro USING utf8) COLLATE utf8_general_ci ) THEN
			START TRANSACTION;
				INSERT INTO libros(nombre_libro,isbn,autor,editorial,descripcion,usuario,status,fechaCreacion,fechaModificacion)
				VALUES (pNombreLibro, pISBN, pAutor, pEditorial, pDescripcion, pUsuario, pStatus,NOW(), NOW() );
				SET CodRetorno = '000';
				SET msg = 'Libro Guardado con Exito';
			COMMIT;
		ELSE
			SET CodRetorno = '001';
			SET msg = 'El Libro ya Éxiste';
			ROLLBACK;
		END IF; 
	END IF; 
END$$
DELIMITER ;