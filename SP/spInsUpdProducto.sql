DROP PROCEDURE IF EXISTS spInsUpdProducto;

DELIMITER $$
CREATE PROCEDURE spInsUpdProducto (
	IN pCodigo BIGINT,
	IN pNombreProducto VARCHAR(50),
	IN pCodigoBarras BIGINT,
	IN pProveedor BIGINT,
	IN pStActual INT,
	IN pStMin INT,
	IN pStMax INT,
	IN pCompra DECIMAL,
	IN pVenta DECIMAL,
	IN pCategoria BIGINT,
	IN pStatus VARCHAR(15),
	IN pUsuario VARCHAR(15),
	OUT CodRetorno CHAR(3),
	OUT msg VARCHAR(100)
)
-- =============================================
-- Author:       	Felipe Monzón
-- Create date: 	02/May/2017
-- Description:   	Procedimiento para guardar y/o actualizar Producto
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
		IF EXISTS(SELECT * FROM productos WHERE codigo_producto = pCodigo) THEN
			IF NOT EXISTS(SELECT * FROM productos WHERE codigo_producto != pCodigo AND nombre_producto = CONVERT(pNombreProducto USING utf8) COLLATE utf8_general_ci ) THEN
				START TRANSACTION;
					UPDATE productos SET nombre_producto = pNombreProducto, codigoBarras = pCodigoBarras, proveedor = pProveedor,
						stockActual = pStActual, stockMin = pStMin, stockMax = pStMax, compra = pCompra, venta = pVenta,
						categoria = pCategoria, status = pStatus, fechaModificacion = NOW()
					WHERE codigo_producto = pCodigo;
					SET CodRetorno = '000';
					SET msg = 'Producto Actualizado con Exito';
				COMMIT; 
			ELSE
				SET CodRetorno = '001';
				SET msg = 'El Nombre del Producto ya fue Registrado';
				ROLLBACK;
			END IF;
		ELSE
			SET CodRetorno = '001';
			SET msg = 'El Producto no Éxiste';
		END IF;
	ELSE 
		IF NOT EXISTS(SELECT * FROM productos WHERE nombre_producto = CONVERT(pNombreProducto USING utf8) COLLATE utf8_general_ci ) THEN
			START TRANSACTION;
				INSERT INTO productos(nombre_producto,codigoBarras,proveedor,stockActual,stockMin,stockMax,compra,
					venta,categoria,status,usuario,fechaCreacion,fechaModificacion)
				VALUES(pNombreProducto, pCodigoBarras, pProveedor, pStActual, pStMin, pStMax, pCompra, pVenta, pCategoria,
					pStatus, pUsuario,NOW(), NOW() );
				SET CodRetorno = '000';
				SET msg = 'Producto Guardado con Exito';
			COMMIT;
		ELSE
			SET CodRetorno = '001';
			SET msg = 'El Producto ya Éxiste';
			ROLLBACK;
		END IF; 
	END IF; 
END$$
DELIMITER ;