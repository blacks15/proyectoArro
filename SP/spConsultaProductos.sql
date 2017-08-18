DROP PROCEDURE IF EXISTS spConsultaProductos;

DELIMITER $$
CREATE PROCEDURE spConsultaProductos (
	IN pCodigo BIGINT,
	IN pInicio INT,
	IN pTamanio INT,
	IN pBusqueda INT,
	OUT codRetorno CHAR(3),
	OUT msg VARCHAR(100),
	OUT numFilas INT,
	OUT msgSQL VARCHAR(100)
)
-- =======================================================
-- Author:       	Felipe Monzón
-- Create date: 	03/May/2017
-- Description:   	Procedimiento para Consultar Productos 
-- =======================================================
BEGIN
	DECLARE isLibro INT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
		@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
		SET codRetorno = '002';
		SET msgSQL = @full_error;
		RESIGNAL;
		ROLLBACK;
	END; 
	DECLARE EXIT HANDLER FOR SQLWARNING
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
		@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
		SET codRetorno = '002';
		SET msgSQL = @full_error;
		SHOW WARNINGS LIMIT 1;
		RESIGNAL;
		ROLLBACK;
	END;

	IF (pCodigo = 0 ) THEN
		IF EXISTS (SELECT * FROM productos) THEN
		 	SELECT COUNT(*) INTO numFilas FROM productos;

			SELECT p.codigo_producto,p.nombre_producto,p.codigoBarras,p.proveedor,p.stockActual,p.stockMin,
				p.stockMax,p.compra,p.venta,p.categoria,p.status,p.isLibro,prv.nombre_proveedor AS nombreProveedor,
				cp.nombre_categoria AS nombreCategoria
			FROM productos p
			INNER JOIN categorias_producto cp ON cp.codigo_catpro = p.categoria
			INNER JOIN proveedores prv ON prv.codigo_proveedor = p.proveedor
			WHERE p.isLibro = 0
			ORDER BY nombre_producto ASC
			LIMIT pInicio, pTamanio;

			SELECT p.codigo_producto, p.nombre_producto, p.codigoBarras, p.proveedor, p.stockActual, p.stockMin,
				p.stockMax, p.compra, p.venta, p.categoria, p.status, p.isLibro, prv.nombre_proveedor AS nombreProveedor,
				cp.nombre_categoria AS nombreCategoria, l.codigo_libro, l.nombre_libro, l.isbn, l.autor AS codigoAutor, au.nombre_autor,
				l.editorial AS codigoEditorial, ed.nombre_editorial, l.descripcion, l.rutaIMG
			FROM productos p
			INNER JOIN categorias_producto cp ON cp.codigo_catpro = p.categoria
			INNER JOIN proveedores prv ON prv.codigo_proveedor = p.proveedor
			INNER JOIN libros l ON p.isLibro = l.codigo_libro
			INNER JOIN autores au ON l.autor = au.codigo_autor
			INNER JOIN editoriales ed ON l.editorial = ed.codigo_editorial
			ORDER BY nombre_producto ASC
			LIMIT pInicio, pTamanio;

			SET msg = 'SP Ejecutado Correctamente';
			SET codRetorno = '000'; 
		ELSE
			SET codRetorno = '001'; 
			SET msg = 'No Hay Datos Para Mostrar';
		END IF;
	ELSE								
		IF (pBusqueda = 1) THEN			/* 1.-CODIGO BARRAS*/
			SELECT COUNT(*) INTO numFilas FROM productos WHERE codigoBarras = pCodigo;
			IF EXISTS (SELECT * FROM productos WHERE codigoBarras = pCodigo) THEN

				SELECT p.codigo_producto,p.nombre_producto,p.codigoBarras,p.proveedor,p.stockActual,p.stockMin,
					p.stockMax,p.compra,p.venta,p.categoria,p.status,p.isLibro,prv.nombre_proveedor AS nombreProveedor,
					cp.nombre_categoria AS nombreCategoria
				FROM productos p
				INNER JOIN categorias_producto cp ON cp.codigo_catpro = p.categoria
				INNER JOIN proveedores prv ON prv.codigo_proveedor = p.proveedor
				WHERE codigoBarras = pCodigo
				ORDER BY nombre_producto ASC
				LIMIT pInicio, pTamanio;

				SET msg = 'SP Ejecutado Correctamente';
				SET codRetorno = '000'; 
			ELSE
				SET codRetorno = '001'; 
				SET msg = 'No Hay Datos Para Mostrar';
			END IF; 
		ELSEIF (pBusqueda = 2) THEN 	/* 2.-CODIGO PRODUCTO*/
			SELECT COUNT(*) INTO numFilas FROM productos WHERE codigo_producto = pCodigo;
			SELECT isLibro INTO isLibro FROM productos WHERE codigo_producto = pCodigo;
			IF EXISTS (SELECT * FROM productos WHERE codigo_producto = pCodigo) THEN
				IF (isLibro = 0) THEN
					SELECT p.codigo_producto,p.nombre_producto,p.codigoBarras,p.proveedor,p.stockActual,p.stockMin,
						p.stockMax,p.compra,p.venta,p.categoria,p.status,p.isLibro,prv.nombre_proveedor AS nombreProveedor,
						cp.nombre_categoria AS nombreCategoria
					FROM productos p
					INNER JOIN categorias_producto cp ON cp.codigo_catpro = p.categoria
					INNER JOIN proveedores prv ON prv.codigo_proveedor = p.proveedor
					WHERE codigo_producto = pCodigo;

					SET msg = 'SP Ejecutado Correctamente';
					SET codRetorno = '000'; 
				ELSE 
					SELECT p.codigo_producto, p.nombre_producto, p.codigoBarras, p.proveedor, p.stockActual, p.stockMin,
						p.stockMax, p.compra, p.venta, p.categoria, p.status, p.isLibro, prv.nombre_proveedor AS nombreProveedor,
						cp.nombre_categoria AS nombreCategoria, l.codigo_libro, l.nombre_libro, l.isbn, l.autor AS codigoAutor, au.nombre_autor,
						l.editorial AS codigoEditorial, ed.nombre_editorial, l.descripcion, l.rutaIMG
					FROM productos p
					INNER JOIN categorias_producto cp ON cp.codigo_catpro = p.categoria
					INNER JOIN proveedores prv ON prv.codigo_proveedor = p.proveedor
					INNER JOIN libros l ON p.isLibro = l.codigo_libro
					INNER JOIN autores au ON l.autor = au.codigo_autor
					INNER JOIN editoriales ed ON l.editorial = ed.codigo_editorial
					WHERE codigo_producto = pCodigo;

					SET msg = 'SP Ejecutado Correctamente';
					SET codRetorno = '000'; 
				END IF;
			ELSE
				SET codRetorno = '001'; 
				SET msg = 'No Hay Datos Para Mostrar';
			END IF; 
		ELSEIF (pBusqueda = 3) THEN		/* 3.-PROVEEDOR*/
			SELECT COUNT(*) INTO numFilas FROM productos WHERE proveedor = pCodigo;
			IF EXISTS (SELECT * FROM productos WHERE proveedor = pCodigo) THEN

				SELECT p.codigo_producto,p.nombre_producto,p.codigoBarras,p.proveedor,p.stockActual,p.stockMin,
					p.stockMax,p.compra,p.venta,p.categoria,p.status,p.isLibro,prv.nombre_proveedor AS nombreProveedor,
					cp.nombre_categoria AS nombreCategoria
				FROM productos p
				INNER JOIN categorias_producto cp ON cp.codigo_catpro = p.categoria
				INNER JOIN proveedores prv ON prv.codigo_proveedor = p.proveedor
				WHERE proveedor = pCodigo
				ORDER BY nombre_producto ASC
				LIMIT pInicio, pTamanio;

				SET msg = 'SP Ejecutado Correctamente';
				SET codRetorno = '000'; 
			ELSE
				SET codRetorno = '001'; 
				SET msg = 'No Hay Datos Para Mostrar';
			END IF; 
		END IF;	/*FIN BUSQUEDA*/
	END IF;	/*FIN CODIGO*/
END$$
DELIMITER ;
