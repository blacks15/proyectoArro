DROP PROCEDURE IF EXISTS spConsultaAutores;

DELIMITER $$
CREATE PROCEDURE spConsultaAutores (
	IN pCodigo BIGINT,
	IN pInicio INT,
	IN pTamanio INT,
	OUT codRetono CHAR(3),
	OUT msg VARCHAR(100),
	OUT numFilas INT
)
-- =============================================
-- Author:       	Felipe Monzón Mendoza
-- Create date: 	02/Feb/2017
-- Description:   	Procedimiento para Consultar Autores 
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
	IF (pCodigo = NULL && pInicio = NULL && pTamanio = NULL) THEN
		SET CodRetorno = '002';
		SET msg = 'Parametros Vacios';
	ELSE
		SELECT COUNT(*) INTO numFilas FROM autores WHERE status = 'DISPONIBLE';
		
		IF (pCodigo > 0) THEN
			IF EXISTS (SELECT * FROM autores WHERE status = 'DISPONIBLE' AND codigo_autor = pCodigo) THEN
				SELECT codigo_autor,nombre_autor,status FROM autores 
				WHERE status = 'DISPONIBLE' AND codigo_autor = pCodigo 
				ORDER BY nombre_autor ASC;
				SET msg = 'SP Ejecutado Correctamente';
				SET CodRetorno = '000'; 
			ELSE
				SET CodRetorno = '001'; 
				SET msg = 'No Hay Datos Para Mostrar';
			END IF;
		ELSE 
			IF EXISTS(SELECT * FROM autores WHERE status = 'DISPONIBLE') THEN
				SELECT codigo_autor,nombre_autor,status FROM autores 
				WHERE status = 'DISPONIBLE' 
				ORDER BY nombre_autor ASC
				LIMIT pInicio, pTamanio;
				SET msg = 'SP Ejecutado Correctamente';
				SET CodRetorno = '000'; 
			ELSE
				SET @text = MESSAGE_TEXT;
				SET CodRetorno = '001'; 
				SET msg = 'No Hay Datos Para Mostrar';
			END IF;
		END IF;
	END IF;
END$$
DELIMITER ;
