DROP PROCEDURE IF EXISTS spConsultaProductos;

DELIMITER $$
CREATE PROCEDURE spConsultaProductos (
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
-- Create date: 	03/May/2017
-- Description:   	Procedimiento para Consultar Productos 
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

	IF (pCodigo = 0 ) THEN
		IF EXISTS (SELECT * FROM productos) THEN
		 	SELECT COUNT(*) INTO numFilas FROM productos;

			SELECT p.codigo_producto,p.nombre_producto,p.codigoBarras,p.proveedor,p.stockActual,p.stockMin,
				p.stockMax,p.compra,p.venta,p.categoria,p.status,prv.nombre_proveedor AS nombreProveedor,
				cp.nombre_categoria AS nombreCategoria
			FROM productos p
			INNER JOIN categorias_producto cp ON cp.codigo_catpro = p.categoria
			INNER JOIN proveedores prv ON prv.codigo_proveedor = p.proveedor
			ORDER BY nombre_producto ASC
			LIMIT pInicio, pTamanio;

			SET msg = 'SP Ejecutado Correctamente';
			SET CodRetorno = '000'; 
		ELSE
			SET CodRetorno = '001'; 
			SET msg = 'No Hay Datos Para Mostrar';
		END IF;
	ELSE								
		IF (pBusqueda = 1) THEN			/* 1.-CODIGO BARRAS*/
				SELECT COUNT(*) INTO numFilas FROM productos WHERE codigoBarras = pCodigo;
			IF EXISTS (SELECT * FROM productos WHERE codigoBarras = pCodigo) THEN

				SELECT p.codigo_producto,p.nombre_producto,p.codigoBarras,p.proveedor,p.stockActual,p.stockMin,
					p.stockMax,p.compra,p.venta,p.categoria,p.status,prv.nombre_proveedor AS nombreProveedor,
					cp.nombre_categoria AS nombreCategoria
				FROM productos p
				INNER JOIN categorias_producto cp ON cp.codigo_catpro = p.categoria
				INNER JOIN proveedores prv ON prv.codigo_proveedor = p.proveedor
				WHERE codigoBarras = pCodigo
				ORDER BY nombre_producto ASC
				LIMIT pInicio, pTamanio;

				SET msg = 'SP Ejecutado Correctamente';
				SET CodRetorno = '000'; 
			ELSE
				SET CodRetorno = '001'; 
				SET msg = 'No Hay Datos Para Mostrar';
			END IF; 
		ELSEIF (pBusqueda = 2) THEN
				SELECT COUNT(*) INTO numFilas FROM productos WHERE codigo_producto = pCodigo;
			IF EXISTS (SELECT * FROM productos WHERE codigo_producto = pCodigo) THEN

				SELECT p.codigo_producto,p.nombre_producto,p.codigoBarras,p.proveedor,p.stockActual,p.stockMin,
					p.stockMax,p.compra,p.venta,p.categoria,p.status,prv.nombre_proveedor AS nombreProveedor,
					cp.nombre_categoria AS nombreCategoria
				FROM productos p
				INNER JOIN categorias_producto cp ON cp.codigo_catpro = p.categoria
				INNER JOIN proveedores prv ON prv.codigo_proveedor = p.proveedor
				WHERE codigo_producto = pCodigo
				ORDER BY nombre_producto ASC
				LIMIT pInicio, pTamanio;

				SET msg = 'SP Ejecutado Correctamente';
				SET CodRetorno = '000'; 
			ELSE
				SET CodRetorno = '001'; 
				SET msg = 'No Hay Datos Para Mostrar';
			END IF; 
		ELSEIF (pBusqueda = 3) THEN
				SELECT COUNT(*) INTO numFilas FROM productos WHERE proveedor = pCodigo;
			IF EXISTS (SELECT * FROM productos WHERE proveedor = pCodigo) THEN

				SELECT p.codigo_producto,p.nombre_producto,p.codigoBarras,p.proveedor,p.stockActual,p.stockMin,
					p.stockMax,p.compra,p.venta,p.categoria,p.status,prv.nombre_proveedor AS nombreProveedor,
					cp.nombre_categoria AS nombreCategoria
				FROM productos p
				INNER JOIN categorias_producto cp ON cp.codigo_catpro = p.categoria
				INNER JOIN proveedores prv ON prv.codigo_proveedor = p.proveedor
				WHERE proveedor = pCodigo
				ORDER BY nombre_producto ASC
				LIMIT pInicio, pTamanio;

				SET msg = 'SP Ejecutado Correctamente';
				SET CodRetorno = '000'; 
			ELSE
				SET CodRetorno = '001'; 
				SET msg = 'No Hay Datos Para Mostrar';
			END IF; 
		END IF;	/*FIN BUSQUEDA*/
	END IF;	/*FIN CODIGO*/
END$$
DELIMITER ;
