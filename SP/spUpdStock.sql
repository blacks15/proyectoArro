DROP PROCEDURE IF EXISTS spUpdStock;

DELIMITER $$
CREATE PROCEDURE spUpdStock (
	IN pCodigo BIGINT,
	IN pStActual INT,
	IN pStatus VARCHAR(15),
	OUT codRetorno CHAR(3),
	OUT msg VARCHAR(100),
	OUT msgSQL VARCHAR(100)
)
-- =======================================================
-- Author:       	Felipe Monzón
-- Create date: 	07/May/2017
-- Description:   	Procedimiento para el actualizar Stock
-- =======================================================
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
		
	IF (pCodigo = 0 || pStActual = 0 || pStatus = '') THEN
		SET codRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE
		IF EXISTS(SELECT * FROM productos WHERE codigoBarras = pCodigo) THEN
			START TRANSACTION;
				UPDATE productos SET stockActual = pStActual, status = pStatus, fechaModificacion = NOW()
				WHERE codigoBarras = pCodigo;
				SET codRetorno = '000';
				SET msg = 'Stock Actualizado con Exito';
			COMMIT; 
		ELSE
			ROLLBACK;
			SET codRetorno = '001';
			SET msg = 'El Producto no Existe';
		END IF;
	END IF; 
END$$
DELIMITER ;