DROP PROCEDURE IF EXISTS spConsultaLibros;

DELIMITER $$
CREATE PROCEDURE spConsultaLibros (
	IN pCodigo BIGINT,
	IN pInicio INT,
	IN pTamanio INT,
	IN pBusqueda INT,
	OUT CodRetorno CHAR(3),
	OUT msg VARCHAR(100),
	OUT numFilas INT
)
-- =============================================
-- Author:       	Felipe Monzón
-- Create date: 	29/Abr/2017
-- Description:   	Procedimiento para Consultar Libros 
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
	IF (COALESCE(pCodigo,'') = '' && COALESCE(pInicio,'') = '' && COALESCE(pTamanio,'') = '') THEN
		SET CodRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE		
		IF (numFilas = 0) THEN
			SET CodRetorno = '001';
			SET msg = "No Hay Datos Para Mostrar";
		ELSE 
			IF (pCodigo = 0 ) THEN
				 IF EXISTS (SELECT * FROM libros WHERE status = 'DISPONIBLE') THEN
				 	SELECT COUNT(*) INTO numFilas FROM libros WHERE status = 'DISPONIBLE';

					SELECT codigo_libro,nombre_libro,isbn,autor,editorial,descripcion,l.status,e.nombre_editorial,a.nombre_autor
					FROM libros l
					INNER JOIN autores a ON a.codigo_autor = l.autor
					INNER JOIN editoriales e ON e.codigo_editorial = l.editorial 
					WHERE l.status = 'DISPONIBLE' 
					ORDER BY nombre_libro ASC
					LIMIT pInicio, pTamanio;
					SET msg = 'SP Ejecutado Correctamente';
					SET CodRetorno = '000'; 
				ELSE
					SET CodRetorno = '001'; 
					SET msg = 'No Hay Datos Para Mostrar';
				END IF;
			ELSE
				IF (pBusqueda = 1) THEN
					IF EXISTS (SELECT * FROM libros WHERE status = 'DISPONIBLE' AND codigo_libro = pCodigo) THEN
						SELECT COUNT(*) INTO numFilas FROM libros WHERE status = 'DISPONIBLE' AND codigo_libro = pCodigo;

						SELECT codigo_libro,nombre_libro,isbn,autor,editorial,descripcion,l.status,e.nombre_editorial,a.nombre_autor
						FROM libros l
						INNER JOIN autores a ON a.codigo_autor = l.autor
						INNER JOIN editoriales e ON e.codigo_editorial = l.editorial 
						WHERE l.status = 'DISPONIBLE' AND codigo_libro = pCodigo
						ORDER BY nombre_libro ASC;
						SET msg = 'SP Ejecutado Correctamente';
						SET CodRetorno = '000'; 
					ELSE
						SET CodRetorno = '001'; 
						SET msg = 'No Hay Datos Para Mostrar';
					END IF;
				ELSE
					IF EXISTS (SELECT * FROM libros WHERE status = 'DISPONIBLE' AND autor = pCodigo) THEN
						SELECT COUNT(*) INTO numFilas FROM libros WHERE status = 'DISPONIBLE' AND autor = pCodigo;
					
						SELECT codigo_libro,nombre_libro,isbn,autor,editorial,descripcion,l.status,e.nombre_editorial,a.nombre_autor
						FROM libros l
						INNER JOIN autores a ON a.codigo_autor = l.autor
						INNER JOIN editoriales e ON e.codigo_editorial = l.editorial 
						WHERE l.status = 'DISPONIBLE' AND autor = pCodigo
						ORDER BY nombre_libro ASC;
						SET msg = 'SP Ejecutado Correctamente';
						SET CodRetorno = '000'; 
					ELSE
						SET CodRetorno = '001'; 
						SET msg = 'No Hay Datos Para Mostrar';
					END IF;
				END IF;
			END IF;
		END IF;	
	END IF;
END$$
DELIMITER ;
