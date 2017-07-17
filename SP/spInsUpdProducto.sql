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
	OUT codRetorno CHAR(3),
	OUT msg VARCHAR(100),
	OUT msgSQL VARCHAR(100)
)
-- ===================================================================
-- Author:       	Felipe Monzón
-- Create date: 	02/May/2017
-- Description:   	Procedimiento para guardar y/o actualizar Producto
-- ===================================================================
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
	
	IF (pNombreProducto = '' || pCodigoBarras = 0 || pProveedor = 0 || pStActual = 0 || pStMin = 0 || pStMax = 0 || pCompra = 0 || pVenta = 0 || pCategoria = 0 || pStatus = '' || pUsuario = '') THEN
		SET codRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE 
		IF (pCodigo != 0) THEN
			IF EXISTS(SELECT * FROM productos WHERE codigo_producto = pCodigo) THEN
				IF NOT EXISTS(SELECT * FROM productos WHERE codigo_producto != pCodigo AND nombre_producto = CONVERT(pNombreProducto USING utf8) COLLATE utf8_general_ci ) THEN
					START TRANSACTION;
						UPDATE productos SET nombre_producto = pNombreProducto, codigoBarras = pCodigoBarras, proveedor = pProveedor,
							stockActual = pStActual, stockMin = pStMin, stockMax = pStMax, compra = pCompra, venta = pVenta,
							categoria = pCategoria, status = pStatus, fechaModificacion = NOW()
						WHERE codigo_producto = pCodigo;
						SET codRetorno = '000';
						SET msg = 'Producto Actualizado con Exito';
					COMMIT; 
				ELSE
					SET codRetorno = '001';
					SET msg = 'El Nombre del Producto ya fue Registrado';
					ROLLBACK;
				END IF;
			ELSE
				SET codRetorno = '001';
				SET msg = 'El Producto no Existe';
			END IF;
		ELSE 
			IF NOT EXISTS(SELECT * FROM productos WHERE nombre_producto = CONVERT(pNombreProducto USING utf8) COLLATE utf8_general_ci ) THEN
				START TRANSACTION;
					INSERT INTO productos(nombre_producto,codigoBarras,proveedor,stockActual,stockMin,stockMax,compra,
						venta,categoria,status,usuario,fechaCreacion,fechaModificacion)
					VALUES(pNombreProducto, pCodigoBarras, pProveedor, pStActual, pStMin, pStMax, pCompra, pVenta, pCategoria,
						pStatus, pUsuario,NOW(), NOW() );
					SET codRetorno = '000';
					SET msg = 'Producto Guardado con Exito';
				COMMIT;
			ELSE
				SET codRetorno = '001';
				SET msg = 'El Producto ya Existe';
				ROLLBACK;
			END IF; 
		END IF; 
	END IF;
END$$
DELIMITER ;