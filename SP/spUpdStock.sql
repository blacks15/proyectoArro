DROP PROCEDURE IF EXISTS spUpdStock;

DELIMITER $$
CREATE PROCEDURE spUpdStock (
	IN pCodigo BIGINT,
	IN pStActual INT,
	IN pStatus VARCHAR(15),
	OUT CodRetorno CHAR(3),
	OUT msg VARCHAR(100)
)
-- =============================================
-- Author:       	Felipe Monzón
-- Create date: 	07/May/2017
-- Description:   	Procedimiento para el actualizar Stock
-- =============================================
BEGIN
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
		SET CodRetorno = '002';
		SHOW WARNINGS LIMIT 1;
		RESIGNAL;
		ROLLBACK;
	END;
		
	IF (pCodigo != 0) THEN
		IF EXISTS(SELECT * FROM productos WHERE codigo_producto = pCodigo) THEN
			START TRANSACTION;
				UPDATE productos SET stockActual = pStActual, status = pStatus, fechaModificacion = NOW()
				WHERE codigo_producto = pCodigo;
				SET CodRetorno = '000';
				SET msg = 'Stock Actualizado con Exito';
			COMMIT; 
		ELSE
			ROLLBACK;
			SET CodRetorno = '001';
			SET msg = 'El Producto no Existe';
		END IF;
	ELSE
		SET CodRetorno = '004';
		SET msg = 'Parametros Vacios';
	END IF; 
END$$
DELIMITER ;