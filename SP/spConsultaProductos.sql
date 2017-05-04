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

	IF (pCodigo = 0 ) THEN
		IF EXISTS (SELECT * FROM productos) THEN
		 	SELECT COUNT(*) INTO numFilas FROM productos;

			SELECT codigo_producto,nombre_producto,codigoBarras,proveedor,stockActual,stockMin,stockMax,compra,venta,categoria,
				p.status,prv.nombre_proveedor AS nombreProveedor,cp.nombre_categoria AS nombreCategoria
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
			IF EXISTS (SELECT * FROM productos WHERE codigoBarras = pCodigo) THEN
				SELECT COUNT(*) INTO numFilas FROM productos WHERE codigoBarras = pCodigo;

				SELECT codigo_producto,nombre_producto,codigoBarras,proveedor,stockActual,stockMin,stockMax,compra,venta,categoria,
					p.status,prv.nombre_proveedor AS nombreProveedor,cp.nombre_categoria AS nombreCategoria
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
		ELSE IF (pBusqueda = 2) THEN  /*2.-NOMBRE PORDUCTO*/
			IF EXISTS (SELECT * FROM productos WHERE codigo_producto = pCodigo) THEN
				SELECT COUNT(*) INTO numFilas FROM productos WHERE codigo_producto = pCodigo;

				SELECT codigo_producto,nombre_producto,codigoBarras,proveedor,stockActual,stockMin,stockMax,compra,venta,categoria,
					p.status,prv.nombre_proveedor AS nombreProveedor,cp.nombre_categoria AS nombreCategoria
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
		ELSE IF (pBusqueda = 3) THEN	/*3.-PROVEEDOR*/	
			IF EXISTS (SELECT * FROM productos WHERE proveedor = pCodigo) THEN
				SELECT COUNT(*) INTO numFilas FROM productos WHERE proveedor = pCodigo;

				SELECT codigo_producto,nombre_producto,codigoBarras,proveedor,stockActual,stockMin,stockMax,compra,venta,categoria,
					p.status,prv.nombre_proveedor AS nombreProveedor,cp.nombre_categoria AS nombreCategoria
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
		END IF; /*FIN BUSQUEDAS*/
	END IF;	/*FIN CODIGO*/
END$$
DELIMITER ;
