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
	
	SELECT COUNT(*) INTO numFilas FROM autores WHERE status = 'DISPONIBLE';
	
	IF (numFilas = 0) THEN
		SET codRetono = '001';
		SET msg = "No Hay Datos Para Mostrar";
	ELSE 
		IF (pCodigo = 0 ) THEN
			SELECT codigo_autor,nombre_autor,status FROM autores WHERE status = 'DISPONIBLE' LIMIT pInicio, pTamanio;
			SET codRetono = '000';
		ELSE
			SELECT codigo_autor,nombre_autor,status FROM autores WHERE status = 'DISPONIBLE' AND codigo_autor = pCodigo;
			SET codRetono = '000';
		END IF;
	END IF;	
END$$

DELIMITER ;