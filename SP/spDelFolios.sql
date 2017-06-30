DROP PROCEDURE IF EXISTS spDelFolios;

DELIMITER $$
CREATE PROCEDURE spDelFolios (
    IN pTabla VARCHAR(10),
	OUT CodRetorno CHAR(3),
	OUT msg VARCHAR(100)
)
-- =============================================================
-- Author:       	Felipe Monzón Mendoza
-- Create date: 	23/Jun/2017
-- Description:   	Procedimiento para Actualizar el Folio en -1
-- =============================================================
BEGIN
    DECLARE vAnio INT;
    DECLARE vConsecutivo INT;

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
		SHOW WARNINGS LIMIT 1;
		SET CodRetorno = '002';
		RESIGNAL;
		ROLLBACK;
	END;

	IF (COALESCE(pTabla,'') = '') THEN
		SET CodRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE
		SELECT YEAR(NOW()) INTO vAnio;
		SELECT consecutivo INTO vConsecutivo FROM folios WHERE nombre = pTabla AND anio = vAnio;

    	START TRANSACTION;
    	UPDATE folios SET consecutivo = vConsecutivo-1 WHERE anio = vAnio AND nombre = CONVERT(pTabla USING utf8) COLLATE utf8_general_ci;
    	COMMIT;

        SET CodRetorno = '000';
		SET msg = 'SP Ejecutado Correctamente';
END IF;
END$$
DELIMITER ;
