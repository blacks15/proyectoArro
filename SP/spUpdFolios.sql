DROP PROCEDURE IF EXISTS spUpdFolios;

DELIMITER $$
CREATE PROCEDURE spUpdFolios (
    IN pTabla VARCHAR(10),
	IN pBandera INT,
	OUT codRetorno CHAR(3),
	OUT msg VARCHAR(100)
)
-- =============================================
-- Author:       	Felipe Monzón Mendoza
-- Create date: 	21/May/2017
-- Description:   	Procedimiento para Actualizar el Folio
-- =============================================
BEGIN
    DECLARE vAnio INT;
    DECLARE vConsecutivo INT;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
		@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
		SET msg = @full_error;
		SET codRetorno = '002';
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
		SET codRetorno = '002';
		RESIGNAL;
		ROLLBACK;
	END;

	IF (pTabla = '' || (pBandera != 1 && pBandera != 2)) THEN
		SET codRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE
		SELECT YEAR(NOW()) INTO vAnio;
		SELECT consecutivo INTO vConsecutivo FROM folios WHERE nombre = pTabla AND anio = vAnio;

		IF (pBandera = 1) THEN
			START TRANSACTION;
				UPDATE folios SET consecutivo = vConsecutivo+1 WHERE anio = vAnio AND nombre = CONVERT(pTabla USING utf8) COLLATE utf8_general_ci;
			COMMIT;
			SET codRetorno = '000';
			SET msg = 'SP Ejecutado Correctamente';
		ELSEIF (pBandera = 2) THEN
			START TRANSACTION;
    			UPDATE folios SET consecutivo = vConsecutivo-1 WHERE anio = vAnio AND nombre = CONVERT(pTabla USING utf8) COLLATE utf8_general_ci;
    		COMMIT;
	        SET codRetorno = '000';
			SET msg = 'SP Ejecutado Correctamente';
		END IF;
	END IF;
END$$
DELIMITER ;
