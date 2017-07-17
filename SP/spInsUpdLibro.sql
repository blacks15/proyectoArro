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
	IN pRutaIMG VARCHAR(50),
	OUT codRetorno CHAR(3),
	OUT msg VARCHAR(100),
	OUT msgSQL VARCHAR(100),
	OUT id INT
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
	
	IF (pNombreLibro = '' || pISBN = 0 || pAutor = 0 || pEditorial = 0 || pUsuario = '' || pStatus = '' || pRutaIMG = '') THEN
		SET codRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE 
		IF (pCodigo != 0) THEN
			IF EXISTS(SELECT * FROM libros WHERE codigo_libro = pCodigo) THEN
				IF NOT EXISTS(SELECT * FROM libros WHERE codigo_libro != pCodigo AND nombre_libro = CONVERT(pNombreLibro USING utf8) COLLATE utf8_general_ci ) THEN
					START TRANSACTION;
						UPDATE libros SET nombre_libro = pNombreLibro,isbn = pISBN,autor = pAutor,editorial = pEditorial,descripcion = pDescripcion,rutaIMG = pRutaIMG,fechaModificacion = NOW()
						WHERE codigo_libro = pCodigo;
						SET codRetorno = '000';
						SET msg = 'Libro Actualizado con Exito';
						SELECT codigo_libro INTO id FROM libros WHERE codigo_libro = pCodigo;
					COMMIT; 
				ELSE
					SET codRetorno = '001';
					SET msg = 'El Nombre del Libro ya fue Registrado';
					ROLLBACK;
				END IF;
			ELSE
				SET codRetorno = '001';
				SET msg = 'El Libro no Existe';
			END IF;
		ELSE 
			IF NOT EXISTS(SELECT * FROM libros WHERE nombre_libro = CONVERT(pNombreLibro USING utf8) COLLATE utf8_general_ci ) THEN
				START TRANSACTION;
					INSERT INTO libros(nombre_libro,isbn,autor,editorial,descripcion,rutaIMG,usuario,status,fechaCreacion,fechaModificacion)
					VALUES (pNombreLibro, pISBN, pAutor, pEditorial, pDescripcion, pRutaIMG, pUsuario, pStatus,NOW(), NOW() );
					SET codRetorno = '000';
					SET msg = 'Libro Guardado con Exito';
					SET id =  LAST_INSERT_ID();
				COMMIT;
			ELSE
				SET codRetorno = '001';
				SET msg = 'El Libro ya Existe';
				ROLLBACK;
				SELECT codigo_libro INTO id FROM libros WHERE nombre_libro = CONVERT(pNombreLibro USING utf8) COLLATE utf8_general_ci;
			END IF; 
		END IF; 
	END IF;
END$$
DELIMITER ;