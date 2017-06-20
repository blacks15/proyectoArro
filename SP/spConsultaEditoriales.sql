DROP PROCEDURE IF EXISTS spConsultaEditoriales;

DELIMITER $$
CREATE PROCEDURE spConsultaEditoriales (
	IN pCodigo BIGINT,
	IN pInicio INT,
	IN pTamanio INT,
	OUT CodRetorno CHAR(3),
	OUT msg VARCHAR(100),
	OUT numFilas INT
)
-- =============================================
-- Author:       	Felipe Monzón
-- Create date: 	02/Abr/2017
-- Description:   	Procedimiento para Consultar Editoriales 
-- =============================================
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
		@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
		SET CodRetorno = '002';
		SET msg = @full_error;
		RESIGNAL;
		ROLLBACK;
	END; 
	DECLARE EXIT HANDLER FOR SQLWARNING
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
		@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
		SET CodRetorno = '002';
		SET msg = @full_error;
		SHOW WARNINGS LIMIT 1;
		RESIGNAL;
		ROLLBACK;
	END;
	IF (COALESCE(pCodigo,'') = '' && COALESCE(pInicio,'') = '' && COALESCE(pTamanio,'') = '') THEN
		SET CodRetorno = '002';
		SET msg = 'Parametros Vacios';
	ELSE
		SELECT COUNT(*) INTO numFilas FROM editoriales WHERE status = 'DISPONIBLE';
		
		IF (numFilas = 0) THEN
			SET CodRetorno = '001';
			SET msg = "No Hay Datos Para Mostrar";
		ELSE 
			IF (pCodigo = 0 ) THEN
				 IF EXISTS (SELECT * FROM editoriales WHERE status = 'DISPONIBLE') THEN
					SELECT codigo_editorial,nombre_editorial,status FROM editoriales 
					WHERE status = 'DISPONIBLE' 
					ORDER BY codigo_editorial ASC
					LIMIT pInicio, pTamanio;
					SET msg = 'SP Ejecutado Correctamente';
					SET CodRetorno = '000'; 
				ELSE
					SET CodRetorno = '001'; 
					SET msg = 'No Hay Datos Para Mostrar';
				END IF;
			ELSE
				IF EXISTS (SELECT * FROM editoriales WHERE status = 'DISPONIBLE' AND codigo_editorial = pCodigo) THEN
					SELECT codigo_editorial,nombre_editorial,status FROM editoriales 
					WHERE status = 'DISPONIBLE' AND codigo_editorial = pCodigo 
					ORDER BY codigo_editorial ASC;
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
