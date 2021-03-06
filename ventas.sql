-- phpMyAdmin SQL Dump
-- version 4.5.1
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Aug 26, 2017 at 07:18 PM
-- Server version: 10.1.19-MariaDB
-- PHP Version: 5.6.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ventas`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `spBloqueaUsuario` (IN `pUsuario` VARCHAR(10), OUT `codRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `msgSQL` VARCHAR(100))  BEGIN
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

	IF (pUsuario = '') THEN
		SET codRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE		
		IF EXISTS (SELECT * FROM usuarios WHERE nombre_usuario = CONVERT(pUsuario USING utf8) COLLATE utf8_general_ci) THEN
			START TRANSACTION;
                UPDATE usuarios SET status = 'BLOQUEADO' WHERE nombre_usuario = CONVERT(pUsuario USING utf8) COLLATE utf8_general_ci;
                SET CodRetorno = '000';
                SET msg = 'SP Ejecutado Correctamente';
            COMMIT; 
		ELSE 
            ROLLBACK;
			SET codRetorno = '001';
			SET msg = 'El Usuario no Existe';
		END IF;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spCambiarPassword` (IN `pCodigo` BIGINT, IN `pNombreUsuario` VARCHAR(10), IN `pContrasenia` VARCHAR(100), OUT `codRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `msgSQL` VARCHAR(100))  BEGIN
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

	IF (pCodigo = 0 || pNombreUsuario = '' || pContrasenia = '') THEN
		SET codRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE
		IF EXISTS (SELECT * FROM usuarios WHERE matricula_empleado = pCodigo AND nombre_usuario = CONVERT(pNombreUsuario USING utf8) COLLATE utf8_general_ci ) THEN
			START TRANSACTION;
				UPDATE usuarios SET password = pContrasenia WHERE nombre_usuario = CONVERT(pNombreUsuario USING utf8) COLLATE utf8_general_ci AND matricula_empleado = pCodigo;
				SET codRetorno = '000';
				SET msg = 'Contraseña Actualizada con Exito';
			COMMIT; 
		ELSE
			SET codRetorno = '001';
			SET msg = 'El Usuario no Existe';
			ROLLBACK;
		END IF;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spConsultaAutores` (IN `pCodigo` BIGINT, IN `pInicio` INT, IN `pTamanio` INT, OUT `msg` VARCHAR(100), OUT `CodRetorno` CHAR(3), OUT `numFilas` INT)  IF (pCodigo = NULL && pInicio = NULL && pTamanio = NULL) THEN
        SET CodRetorno = '002';
        SET msg = 'Parametros Vacios.';
    ELSE
        SELECT COUNT(*) INTO numfilas FROM autores WHERE status = 'DISPONIBLE';
        IF (pCodigo > 0) THEN
            IF EXISTS (SELECT * FROM autores WHERE status = 'DISPONIBLE' AND codigo_autor = pCodigo) THEN
                SELECT codigo_autor,nombre_autor,status FROM autores 
                WHERE status = 'DISPONIBLE' AND codigo_autor = pCodigo 
                ORDER BY nombre_autor ASC;
                SET msg = 'SP Ejecutado Correctamente';
                SET CodRetorno = '000'; 
            ELSE
                SET @text = MESSAGE_TEXT;
                SET CodRetorno = '001'; 
                SET msg = 'No Hay Datos Para Mostrar';
                ROLLBACK;
            END IF;
        ELSE 
            IF EXISTS(SELECT * FROM autores WHERE status = 'DISPONIBLE') THEN
                SELECT codigo_autor,nombre_autor,status FROM autores 
                WHERE status = 'DISPONIBLE' 
                LIMIT pInicio, pTamanio;
                SET msg = 'SP Ejecutado Correctamente';
                SET CodRetorno = '000'; 
            ELSE
                SET @text = MESSAGE_TEXT;
                SET CodRetorno = '001'; 
                SET msg = 'No Hay Datos Para Mostrar';
                ROLLBACK;
            END IF;
        END IF;
    END IF$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spConsultaClientes` (IN `pCodigo` BIGINT, IN `pInicio` INT, IN `pTamanio` INT, OUT `codRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `numFilas` INT, OUT `msgSQL` VARCHAR(100))  BEGIN
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
		
	IF (pTamanio = 0) THEN
		SET codRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE		
		IF (pCodigo = 0 ) THEN
			 IF EXISTS (SELECT * FROM clientes) THEN
			 	SELECT COUNT(*) INTO numFilas FROM clientes;

				SELECT matricula,rfc,empresa,nombre_contacto,apellido_paterno,apellido_materno,calle,numExt,numInt,
					colonia,ciudad,estado,telefono,celular,email,status,CONCAT(calle,' ',numExt,' ',numInt,' ',colonia) AS direccion,
					CONCAT(apellido_paterno,' ',apellido_materno) AS apellidos
				FROM clientes
				WHERE matricula != 1
				ORDER BY apellidos ASC
				LIMIT pInicio, pTamanio;
				SET msg = 'SP Ejecutado Correctamente';
				SET codRetorno = '000'; 
			ELSE
				SET codRetorno = '001'; 
				SET msg = 'No Hay Datos Para Mostrar';
			END IF;
		ELSE
			IF EXISTS (SELECT * FROM clientes WHERE matricula = pCodigo) THEN
				SELECT COUNT(*) INTO numFilas FROM clientes WHERE matricula = pCodigo;

				SELECT matricula,rfc,empresa,nombre_contacto,apellido_paterno,apellido_materno,calle,numExt,numInt,
					colonia,ciudad,estado,telefono,celular,email,status,CONCAT(calle,' ',numExt,' ',numInt,' ',colonia) AS direccion,
					CONCAT(apellido_paterno,' ',apellido_materno) AS apellidos
				FROM clientes
				WHERE matricula = pCodigo AND matricula != 1
				ORDER BY apellidos ASC;
				SET msg = 'SP Ejecutado Correctamente';
				SET codRetorno = '000'; 
			ELSE
				SET codRetorno = '001'; 
				SET msg = 'No Hay Datos Para Mostrar';
			END IF;
		END IF;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spConsultaEditoriales` (IN `pCodigo` BIGINT, IN `pInicio` INT, IN `pTamanio` INT, OUT `CodRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `numFilas` INT)  BEGIN
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
	IF (COALESCE(pCodigo,'') = '' && COALESCE(pInicio,'') = '' && COALESCE(pTamanio,'') = '') THEN
		SET CodRetorno = '002';
		SET msg = 'Parametros Vacios';
	ELSE
		SELECT COUNT(*) INTO numFilas FROM editoriales WHERE status = 'DISPONIBLE';
		
		IF (numFilas = 0) THEN
			SET CodRetorno = '001';
			SET msg = "No Hay Datos Para Mostrar";
		ELSE 
			IF (pCodigo = 0 ) THEN
				 IF EXISTS (SELECT * FROM editoriales WHERE status = 'DISPONIBLE') THEN
					SELECT codigo_editorial,nombre_editorial,status FROM editoriales 
					WHERE status = 'DISPONIBLE' 
					ORDER BY nombre_editorial ASC
					LIMIT pInicio, pTamanio;
					SET msg = 'SP Ejecutado Correctamente';
					SET CodRetorno = '000'; 
				ELSE
					SET CodRetorno = '001'; 
					SET msg = 'No Hay Datos Para Mostrar';
				END IF;
			ELSE
				IF EXISTS (SELECT * FROM editoriales WHERE status = 'DISPONIBLE' AND codigo_editorial = pCodigo) THEN
					SELECT codigo_editorial,nombre_editorial,status FROM editoriales 
					WHERE status = 'DISPONIBLE' AND codigo_editorial = pCodigo 
					ORDER BY nombre_editorial ASC;
					SET msg = 'SP Ejecutado Correctamente';
					SET CodRetorno = '000'; 
				ELSE
					SET CodRetorno = '001'; 
					SET msg = 'No Hay Datos Para Mostrar';
				END IF;
			END IF;
		END IF;	
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spConsultaEmpleados` (IN `pCodigo` BIGINT, IN `pInicio` INT, IN `pTamanio` INT, OUT `codRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `numFilas` INT, OUT `msgSQL` VARCHAR(100))  BEGIN
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
	IF (pTamanio = 0) THEN
		SET CodRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE		
		IF (pCodigo = 0 ) THEN
			 IF EXISTS (SELECT * FROM empleados WHERE status = 'DISPONIBLE') THEN
			 	SELECT COUNT(*) INTO numFilas FROM empleados WHERE status = 'DISPONIBLE';

				SELECT matricula,nombre_empleado,apellido_paterno,apellido_materno,calle,numExt,numInt,puesto,
					colonia,ciudad,estado,telefono,celular,sueldo,CONCAT(calle,' ',numExt,' ',numInt) AS direccion,
					CONCAT(apellido_paterno,' ',apellido_materno) AS apellidos,isUsu
				FROM empleados
				WHERE status = 'DISPONIBLE' 
				ORDER BY apellidos ASC
				LIMIT pInicio, pTamanio;
				SET msg = 'SP Ejecutado Correctamente';
				SET codRetorno = '000'; 
			ELSE
				SET codRetorno = '001'; 
				SET msg = 'No Hay Datos Para Mostrar';
			END IF;
		ELSE
			IF EXISTS (SELECT * FROM empleados WHERE status = 'DISPONIBLE' AND matricula = pCodigo) THEN
				SELECT COUNT(*) INTO numFilas FROM empleados WHERE status = 'DISPONIBLE' AND matricula = pCodigo;

				SELECT matricula,nombre_empleado,apellido_paterno,apellido_materno,calle,numExt,numInt,puesto,
					colonia,ciudad,estado,telefono,celular,sueldo,CONCAT(calle,' ',numExt,' ',numInt) AS direccion,
					CONCAT(apellido_paterno,' ',apellido_materno) AS apellidos,isUsu
				FROM empleados
				WHERE status = 'DISPONIBLE' AND matricula = pCodigo
				ORDER BY apellidos ASC;
				SET msg = 'SP Ejecutado Correctamente';
				SET codRetorno = '000'; 
			ELSE
				SET codRetorno = '001'; 
				SET msg = 'No Hay Datos Para Mostrar';
			END IF;
		END IF;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spConsultaLibros` (IN `pCodigo` BIGINT, IN `pInicio` INT, IN `pTamanio` INT, IN `pBusqueda` INT, OUT `CodRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `numFilas` INT, OUT `msgSQL` VARCHAR(100))  BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
		@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
		SET CodRetorno = '002';
		SET msgSQL = @full_error;
		RESIGNAL;
		ROLLBACK;
	END; 
	DECLARE EXIT HANDLER FOR SQLWARNING
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
		@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
		SET CodRetorno = '002';
		SET msgSQL = @full_error;
		SHOW WARNINGS LIMIT 1;
		RESIGNAL;
		ROLLBACK;
	END;
	SET msgSQL = '';
	IF (pTamanio = 0) THEN
		SET CodRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE		
		IF (numFilas = 0) THEN
			SET CodRetorno = '001';
			SET msg = "No Hay Datos Para Mostrar";
		ELSE 
			IF (pCodigo = 0 ) THEN
				 IF EXISTS (SELECT * FROM libros WHERE status = 'DISPONIBLE') THEN
				 	SELECT COUNT(*) INTO numFilas FROM libros WHERE status = 'DISPONIBLE';

					SELECT codigo_libro,nombre_libro,isbn,autor,editorial,descripcion,l.status,e.nombre_editorial,a.nombre_autor,rutaIMG
					FROM libros l
					INNER JOIN autores a ON a.codigo_autor = l.autor
					INNER JOIN editoriales e ON e.codigo_editorial = l.editorial 
					WHERE l.status = 'DISPONIBLE' 
					ORDER BY nombre_libro ASC
					LIMIT pInicio, pTamanio;
					SET msg = 'SP Ejecutado Correctamente';
					SET CodRetorno = '000'; 
				ELSE
					SET CodRetorno = '001'; 
					SET msg = 'No Hay Datos Para Mostrar';
				END IF;
			ELSE
				IF (pBusqueda = 1) THEN
					IF EXISTS (SELECT * FROM libros WHERE status = 'DISPONIBLE' AND codigo_libro = pCodigo) THEN
						SELECT COUNT(*) INTO numFilas FROM libros WHERE status = 'DISPONIBLE' AND codigo_libro = pCodigo;

						SELECT codigo_libro,nombre_libro,isbn,autor,editorial,descripcion,l.status,e.nombre_editorial,a.nombre_autor,rutaIMG
						FROM libros l
						INNER JOIN autores a ON a.codigo_autor = l.autor
						INNER JOIN editoriales e ON e.codigo_editorial = l.editorial 
						WHERE l.status = 'DISPONIBLE' AND codigo_libro = pCodigo
						ORDER BY nombre_libro ASC;
						SET msg = 'SP Ejecutado Correctamente';
						SET CodRetorno = '000'; 
					ELSE
						SET CodRetorno = '001'; 
						SET msg = 'No Hay Datos Para Mostrar';
					END IF;
				ELSE
					IF EXISTS (SELECT * FROM libros WHERE status = 'DISPONIBLE' AND autor = pCodigo) THEN
						SELECT COUNT(*) INTO numFilas FROM libros WHERE status = 'DISPONIBLE' AND autor = pCodigo;
					
						SELECT codigo_libro,nombre_libro,isbn,autor,editorial,descripcion,l.status,e.nombre_editorial,a.nombre_autor,rutaIMG
						FROM libros l
						INNER JOIN autores a ON a.codigo_autor = l.autor
						INNER JOIN editoriales e ON e.codigo_editorial = l.editorial 
						WHERE l.status = 'DISPONIBLE' AND autor = pCodigo
						ORDER BY nombre_libro ASC;
						SET msg = 'SP Ejecutado Correctamente';
						SET CodRetorno = '000'; 
					ELSE
						SET CodRetorno = '001'; 
						SET msg = 'No Hay Datos Para Mostrar';
					END IF;
				END IF;
			END IF;
		END IF;	
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spConsultaProductos` (IN `pCodigo` BIGINT, IN `pInicio` INT, IN `pTamanio` INT, IN `pBusqueda` INT, OUT `codRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `numFilas` INT, OUT `msgSQL` VARCHAR(100))  BEGIN
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
		IF (pBusqueda = 1) THEN			
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
		ELSEIF (pBusqueda = 2) THEN 	
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
		ELSEIF (pBusqueda = 3) THEN		
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
		END IF;	
	END IF;	
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spConsultaProveedores` (IN `pCodigo` BIGINT, IN `pInicio` INT, IN `pTamanio` INT, OUT `codRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `numFilas` INT, OUT `msgSQL` VARCHAR(100))  BEGIN
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

	IF (pTamanio = 0) THEN
		SET CodRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE		
		IF (pCodigo = 0 ) THEN
			 IF EXISTS (SELECT * FROM proveedores WHERE status = 'DISPONIBLE') THEN
			 	SELECT COUNT(*) INTO numFilas FROM proveedores WHERE status = 'DISPONIBLE';

				SELECT codigo_proveedor,nombre_proveedor,CONCAT(contacto,' ',apellido_paterno,' ',apellido_materno) AS nombreContacto,calle,
					num_ext,num_int,colonia,ciudad,estado,telefono,celular,email,web,usuario,status,contacto,apellido_materno,apellido_paterno,
					CONCAT(calle,' ',num_ext,' ',num_int) AS direccion
				FROM proveedores
				WHERE status = 'DISPONIBLE' 
				ORDER BY nombre_proveedor ASC
				LIMIT pInicio, pTamanio;
				SET msg = 'SP Ejecutado Correctamente';
				SET codRetorno = '000'; 
			ELSE
				SET codRetorno = '001'; 
				SET msg = 'No Hay Datos Para Mostrar';
			END IF;
		ELSE
			IF EXISTS (SELECT * FROM proveedores WHERE status = 'DISPONIBLE' AND codigo_proveedor = pCodigo) THEN
				SELECT COUNT(*) INTO numFilas FROM proveedores WHERE status = 'DISPONIBLE' AND codigo_proveedor = pCodigo;

				SELECT codigo_proveedor,nombre_proveedor,CONCAT(contacto,' ',apellido_paterno,' ',apellido_materno) AS nombreContacto,calle,
					num_ext,num_int,colonia,ciudad,estado,telefono,celular,email,web,usuario,status,contacto,apellido_materno,apellido_paterno,
					CONCAT(calle,' ',num_ext,' ',num_int) AS direccion
				FROM proveedores
				WHERE status = 'DISPONIBLE' AND codigo_proveedor = pCodigo
				ORDER BY nombre_proveedor ASC;
				SET msg = 'SP Ejecutado Correctamente';
				SET codRetorno = '000'; 
			ELSE
				SET codRetorno = '001'; 
				SET msg = 'No Hay Datos Para Mostrar';
			END IF;
		END IF;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spConsultaRetiros` (IN `pCodigo` BIGINT, IN `pInicio` INT, IN `pTamanio` INT, IN `pUsuario` VARCHAR(15), OUT `CodRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `numFilas` INT)  BEGIN
	DECLARE vPerfil INT;
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
	IF (pCodigo = NULL && pInicio = NULL && pTamanio = NULL) THEN
		SET CodRetorno = '002';
		SET msg = 'Parametros Vacios';
	ELSE		
		SELECT tipo_usuario INTO vPerfil FROM usuarios WHERE nombre_usuario = CONVERT(pUsuario USING utf8) COLLATE utf8_general_ci;

		IF (vPerfil = 1) THEN 
			IF (pCodigo > 0) THEN
				IF EXISTS (SELECT * FROM retiros WHERE folio = pCodigo) THEN
					SELECT COUNT(*) INTO numFilas FROM retiros WHERE folio = pCodigo;

					SELECT codigo_retiro,folio,fecha,empleado,cantidad,descripcion,status 
					FROM retiros 
					WHERE folio = pCodigo 
					ORDER BY folio DESC;
					SET msg = 'SP Ejecutado Correctamente';
					SET CodRetorno = '000'; 
				ELSE
					SET CodRetorno = '001'; 
					SET msg = 'No Hay Datos Para Mostrar';
				END IF;
			ELSE
				IF ( (SELECT COUNT(*) FROM retiros) > 0 ) THEN
					SELECT COUNT(*) INTO numFilas FROM retiros;

					SELECT codigo_retiro,folio,fecha,empleado,cantidad,descripcion,status 
					FROM retiros 
					ORDER BY folio DESC
					LIMIT pInicio, pTamanio;
					SET msg = 'SP Ejecutado Correctamente';
					SET CodRetorno = '000'; 
				ELSE
					SET CodRetorno = '001'; 
					SET msg = 'No Hay Datos Para Mostrar';
				END IF;
			END IF;
		ELSE
			IF (pCodigo > 0) THEN
				IF EXISTS (SELECT * FROM retiros WHERE folio = pCodigo AND usuario = CONVERT(pUsuario USING utf8) COLLATE utf8_general_ci) THEN
					SELECT COUNT(*) INTO numFilas FROM retiros WHERE folio = pCodigo AND usuario = CONVERT(pUsuario USING utf8) COLLATE utf8_general_ci;

					SELECT codigo_Retiro,folio,fecha,empleado,cantidad,descripcion,status 
					FROM retiros 
					WHERE folio = pCodigo AND usuario = CONVERT(pUsuario USING utf8) COLLATE utf8_general_ci
					ORDER BY folio ASC;
					SET msg = 'SP Ejecutado Correctamente';
					SET CodRetorno = '000'; 
				ELSE
					SET CodRetorno = '001'; 
					SET msg = 'No Hay Datos Para Mostrar';
				END IF;
			ELSE
				IF ( (SELECT COUNT(*) FROM retiros WHERE usuario = CONVERT(pUsuario USING utf8) COLLATE utf8_general_ci) > 0 ) THEN 
					SELECT COUNT(*) INTO numFilas FROM retiros WHERE usuario = CONVERT(pUsuario USING utf8) COLLATE utf8_general_ci;

					SELECT codigo_retiro,folio,fecha,empleado,cantidad,descripcion,status 
					FROM retiros 
					WHERE usuario = CONVERT(pUsuario USING utf8) COLLATE utf8_general_ci
					ORDER BY folio ASC
					LIMIT pInicio, pTamanio;
					SET msg = 'SP Ejecutado Correctamente';
					SET CodRetorno = '000'; 
				ELSE
					SET CodRetorno = '001'; 
					SET msg = 'No Hay Datos Para Mostrar';
				END IF;
			END IF;
		END IF;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spDelFolios` (IN `pTabla` VARCHAR(10), OUT `CodRetorno` CHAR(3), OUT `msg` VARCHAR(100))  BEGIN
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `spDelRetiro` (IN `pCodigo` BIGINT, IN `pStatus` VARCHAR(15), IN `pUsuario` VARCHAR(15), OUT `CodRetorno` CHAR(3), OUT `msg` VARCHAR(100))  BEGIN
    DECLARE vPerfil INT;
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

	IF (COALESCE(pCodigo,'') = '' && pCodigo = 0 && COALESCE(pUsuario,'') = '') THEN
		SET CodRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE
        SELECT tipo_usuario INTO vPerfil FROM usuarios WHERE nombre_usuario = CONVERT(pUsuario USING utf8) COLLATE utf8_general_ci ;

        IF ( vPerfil = 1) THEN 
            IF EXISTS (SELECT * FROM retiros WHERE folio = pCodigo) THEN
                START TRANSACTION;
                    UPDATE retiros SET status = pStatus, fechaModificacion = NOW() WHERE folio = pCodigo;
                    SET CodRetorno = '000';
                    SET msg = 'Retiro Eliminado con Exito';
                COMMIT; 
            ELSE
                SET CodRetorno = '001';
                SET msg = 'El Folio no Existe';
                ROLLBACK;
            END IF;
        ELSE
            SET CodRetorno = '002';
            SET msg = 'No Cuenta con los Permisos Suficientes';
        END IF;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spDelVenta` (IN `pFolio` BIGINT, OUT `codRetorno` CHAR(3), OUT `msg` VARCHAR(100))  BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
        @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
        SET codRetorno = '002';
        SET msg = @full_error;
        RESIGNAL;
        ROLLBACK;
    END; 

    DECLARE EXIT HANDLER FOR SQLWARNING
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
        @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
        SET codRetorno = '002';
        SET msg = @full_error;
        SHOW WARNINGS LIMIT 1;
        RESIGNAL;
        ROLLBACK;
    END;

    IF (pFolio = 0) THEN
        SET codRetorno = '004';
        SET msg = 'Parametros Vacios';
    ELSE 
        START TRANSACTION; 
            DELETE FROM ventas WHERE folio = pFolio;
            CALL spDelFolios('ventas',@codRetorno,@msg);
            SET codRetorno = '000';
            SET msg = 'SP Ejecutado Correctamente';
        COMMIT; 
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spInsDelUsuarios` (IN `pCodigo` BIGINT, IN `pNombreUsuario` VARCHAR(10), IN `pPaswword` VARCHAR(100), IN `pTipo` BIGINT, IN `pStatus` VARCHAR(15), IN `pBandera` INT, OUT `codRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `msgSQL` VARCHAR(100))  BEGIN
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
			
	IF (pCodigo = 0 || pBandera = 0 || pNombreUsuario = '') THEN
		SET msg = 'Parametros Vacios';
		SET CodRetorno = '002';
	ELSE
		IF (pBandera = 2 ) THEN
			IF EXISTS(SELECT * FROM usuarios WHERE matricula_empleado = pCodigo) THEN
                START TRANSACTION;
                    DELETE FROM usuarios WHERE matricula_empleado = pCodigo AND nombre_usuario = CONVERT(pNombreUsuario USING utf8) COLLATE utf8_general_ci ;
                    UPDATE empleados SET isUsu = '0' WHERE matricula = pCodigo AND status = 'DISPONIBLE';
                    SET codRetorno = '000';
                    SET msg = 'Usuario Desasociado con Exito';
                COMMIT; 
			ELSE
				SET codRetorno = '001';
				SET msg = 'El Usuario no Existe';
				ROLLBACK;
			END IF;
		ELSEIF (pBandera = 1) THEN 
			IF ( pNombreUsuario = '' || pPaswword = '' || pStatus = '' || pTipo = 0) THEN
				SET msg = 'Parametros Vacios';
				SET CodRetorno = '002';
			ELSE
				IF NOT EXISTS(SELECT * FROM usuarios WHERE nombre_usuario = CONVERT(pNombreUsuario USING utf8) COLLATE utf8_general_ci) THEN
					START TRANSACTION;
						INSERT INTO usuarios (nombre_usuario,password,tipo_usuario,matricula_empleado,status,fechaCreacion,fechaModificacion)
						VALUES (pNombreUsuario, pPaswword, pTipo, pCodigo, pStatus,NOW(), NOW() );
						SET codRetorno = '000';
						SET msg = 'Usuario Guardado con Exito';
					COMMIT;
				ELSE
					SET codRetorno = '001';
					SET msg = 'El Usuario ya Existe';
					ROLLBACK;
				END IF; 
			END IF;
		END IF;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spInsDelVenta` (IN `pFolio` BIGINT, IN `pNumEmpleado` BIGINT, IN `pNumCliente` BIGINT, IN `pTotal` DECIMAL(10,2), IN `pIsTarjeta` INT, IN `pFolioTarjeta` INT, IN `pStatus` CHAR(15), IN `pUsuario` CHAR(15), IN `pBandera` INT, OUT `codRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `msgSQL` VARCHAR(100))  BEGIN
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

    IF (pFolio = 0 || pNumEmpleado = 0 || pNumCliente = 0 || pTotal = 0.00 || pIsTarjeta = 0 || pStatus = '' || pUsuario = '' || pBandera = 0 || (pBandera != 1 && pBandera != 2)) THEN
        SET codRetorno = '004';
        SET msg = 'Parametros Vacios';
    ELSE 
        IF (pBandera = 1) THEN
            IF NOT EXISTS (SELECT folio FROM ventas WHERE folio = pFolio) THEN 
                START TRANSACTION;
                    INSERT INTO ventas (folio,fecha_venta,empleado,cliente,total,isTarjeta,folioTarjeta,status,usuario,fechaCreacion,fechaModificacion) 
                    VALUES (pFolio, NOW(), pNumEmpleado, pNumCliente, pTotal, pIsTarjeta, pFolioTarjeta, pStatus, pUsuario, NOW(), NOW());
                    CALL spUpdFolios('ventas',1,@codRetorno,@msg);
                    SET codRetorno = '000';
                    SET msg = 'SP Ejecutado con Exito';
                COMMIT; 
            ELSE
                SET codRetorno = '001';
                SET msg = 'El Folio ya fue Registrado';
                ROLLBACK;  
            END IF;
        ELSEIF (pBandera = 2) THEN
            IF EXISTS (SELECT folio FROM ventas WHERE folio = pFolio) THEN
                START TRANSACTION; 
                    DELETE FROM ventas WHERE folio = pFolio;
                    CALL spUpdFolios('ventas',2,@codRetorno,@msg);
                    SET codRetorno = '000';
                    SET msg = 'SP Ejecutado Correctamente';
                COMMIT; 
            ELSE 
                SET codRetorno = '001';
                SET msg = 'El Folio No Existe';
                ROLLBACK;
            END IF;
        END IF;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spInsDetalleVenta` (IN `pFolio` BIGINT, IN `pIdProducto` BIGINT, IN `pCantidad` INT, IN `pPrecio` DECIMAL(10,2), IN `pSubTotal` DECIMAL(10,2), IN `pBandera` INT, OUT `codRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `msgSQL` VARCHAR(100))  BEGIN
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

    IF (pFolio = 0 || pIdProducto = 0 || pCantidad = 0 || pPrecio = 0.00 || pSubTotal = 0.00 || (pBandera != 1 && pBandera != 2) ) THEN
        SET codRetorno = '004';
        SET msg = 'Parametros Vacios';
    ELSE 
        IF (pBandera = 1) THEN
            IF NOT EXISTS (SELECT folio FROM detalle_venta WHERE folio = pFolio AND clave_producto = pIdProducto) THEN
                START TRANSACTION;
                    INSERT INTO detalle_venta (folio,clave_producto,cantidad,precio,subtotal)
                    VALUES (pFolio,pIdProducto,pCantidad,pPrecio,pSubTotal);

                    SET codRetorno = '000';
                    SET msg = 'Venta Guardada con Exito';
                COMMIT; 
            ELSE 
                SET codRetorno = '001';
                SET msg = 'El Folio ya fue Registrado';
                ROLLBACK;
            END IF;
        ELSEIF (pBandera = 2) THEN
            IF EXISTS (SELECT folio FROM detalle_venta WHERE folio = pFolio) THEN
                START TRANSACTION; 
                    DELETE FROM detalle_venta WHERE folio = pFolio;
                    SET codRetorno = '000';
                    SET msg = 'SP Ejecutado Correctamente';
                COMMIT;
            ELSE
                SET codRetorno = '001';
                SET msg = 'El Folio No Existe';
                ROLLBACK;
            END IF;
        END IF;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spInsEditorial` (IN `pNombreEditorial` VARCHAR(50), IN `pUsuario` VARCHAR(15), IN `pStatus` VARCHAR(15), OUT `codRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `msgSQL` VARCHAR(100))  BEGIN
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
			
	IF (pNombreEditorial = '' && pUsuario = '' && pStatus = '' ) THEN
		SET codRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE
        IF NOT EXISTS(SELECT * FROM editoriales WHERE nombre_editorial = CONVERT(pNombreEditorial USING utf8) COLLATE utf8_general_ci ) THEN
            START TRANSACTION;
                INSERT INTO editoriales(nombre_editorial,usuario,status,fechaCreacion,fechaModificacion)
                VALUES (pNombreEditorial, pUsuario, pStatus, NOW(), NOW() );
                SET codRetorno = '000';
                SET msg = 'Editorial Guardado con Exito';
            COMMIT;
        ELSE
            SET codRetorno = '001';
            SET msg = 'La Editorial ya Existe';
            ROLLBACK;
        END IF; 
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spInsUpdAutor` (IN `pCodigo` BIGINT, IN `pNombreAutor` VARCHAR(50), IN `pUsuario` VARCHAR(15), IN `pStatus` VARCHAR(15), OUT `codRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `msgSQL` VARCHAR(100), OUT `id` INT)  BEGIN
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
			
	IF (pNombreAutor = '' && pUsuario = ''  && pStatus = '' ) THEN
		SET codRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE
		IF (pCodigo != 0) THEN
			IF EXISTS(SELECT * FROM autores WHERE codigo_autor = pCodigo) THEN
				IF NOT EXISTS(SELECT * FROM autores WHERE codigo_autor != pCodigo AND nombre_autor = CONVERT(pNombreAutor USING utf8) COLLATE utf8_general_ci ) THEN
					START TRANSACTION;
						UPDATE autores SET nombre_autor = pNombreAutor,fechaModificacion = NOW() WHERE codigo_autor = pCodigo;
						SET codRetorno = '000';
						SET msg = 'Autor Actualizado con Exito';
						SELECT codigo_autor INTO id FROM autores WHERE codigo_autor = pCodigo;
					COMMIT; 
				ELSE 
					SET codRetorno = '001';
					SET msg = 'El Nombre del Autor ya fue Registrado';
					ROLLBACK;
				END IF;
			ELSE
				SET codRetorno = '001';
				SET msg = 'El Autor no Existe';
				ROLLBACK;
			END IF;
		ELSE 
			IF NOT EXISTS(SELECT * FROM autores WHERE nombre_autor = CONVERT(pNombreAutor USING utf8) COLLATE utf8_general_ci) THEN
				START TRANSACTION;
					INSERT INTO autores (nombre_autor,usuario,status,fechaCreacion,fechaModificacion)
					VALUES (pNombreAutor, pUsuario, pStatus,NOW(), NOW() );
					SET codRetorno = '000';
					SET msg = 'Autor Guardado con Exito';

					SET id =  LAST_INSERT_ID();
				COMMIT;
			ELSE
				SET codRetorno = '001';
				SET msg = 'El Autor ya Existe';
				SELECT codigo_autor INTO id FROM autores WHERE nombre_autor = CONVERT(pNombreAutor USING utf8) COLLATE utf8_general_ci;
				ROLLBACK;
			END IF; 
		END IF; 
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spInsUpdCliente` (IN `pCodigo` BIGINT, IN `pRFC` CHAR(13), IN `pEmpresa` VARCHAR(30), IN `pNombreContacto` VARCHAR(20), IN `pAPaterno` VARCHAR(30), IN `pAMaterno` VARCHAR(30), IN `pCalle` VARCHAR(30), IN `pNumExt` INT, IN `pNumInt` VARCHAR(5), IN `pColonia` VARCHAR(30), IN `pCiudad` VARCHAR(30), IN `pEstado` VARCHAR(30), IN `pTelefono` VARCHAR(10), IN `pCelular` VARCHAR(10), IN `pEmail` VARCHAR(30), IN `pStatus` VARCHAR(10), IN `pUsuario` VARCHAR(15), OUT `codRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `msgSQL` VARCHAR(100))  BEGIN
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
	IF (pEmpresa = '' ||  pNombreContacto = '' || pAPaterno = '' || pAMaterno =  '' || pNumExt = 0 || pColonia = '' || pCiudad = '' || pEstado = '' || pEmail = '' || pStatus = '') THEN
		SET codRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE
		IF (pCodigo != 0) THEN
			IF EXISTS(SELECT * FROM clientes WHERE matricula = pCodigo) THEN
				IF ( (SELECT COUNT(*) FROM clientes WHERE matricula != pCodigo AND empresa = CONVERT(pEmpresa USING utf8) COLLATE utf8_general_ci) = 0 ) THEN
					IF ( (SELECT COUNT(*) FROM clientes WHERE matricula != pCodigo AND  rfc = pRFC) = 0 ) THEN
						START TRANSACTION;
							UPDATE clientes SET rfc = pRFC, empresa = pEmpresa, nombre_contacto = pNombreContacto, 
								apellido_paterno = pAPaterno, apellido_materno = pAMaterno, calle = pCalle, numExt = pNumExt,
								numInt = pNumInt, colonia = pColonia, ciudad = pCiudad, estado = pEstado, telefono = pTelefono,
								celular = pCelular, email = pEmail, fechaModificacion = NOW()
							WHERE matricula = pCodigo;
							SET codRetorno = '000';
							SET msg = 'Cliente Actualizado con Exito';
						COMMIT; 
					ELSE
						SET codRetorno = '001';
						SET msg = 'El RFC del Cliente ya fue Registrado';
						ROLLBACK;
					END IF;
				ELSE
					SET codRetorno = '001';
					SET msg = 'El Nombre del Cliente ya fue Registrado';
					ROLLBACK;
				END IF;
			ELSE
				SET codRetorno = '001';
				SET msg = 'El Cliente no Existe';
			END IF;
		ELSE 
			IF NOT EXISTS(SELECT * FROM clientes WHERE empresa = CONVERT(pEmpresa USING utf8) COLLATE utf8_general_ci ) THEN
				IF NOT EXISTS (SELECT * FROM clientes WHERE rfc = pRFC) THEN
					START TRANSACTION;
						INSERT INTO clientes(rfc,empresa,nombre_contacto,apellido_paterno,apellido_materno,calle,numExt,numInt,
							colonia,ciudad,estado,telefono,celular,email,status,usuario,fechaCreacion,fechaModificacion)
						VALUES (pRFC, pEmpresa, pNombreContacto, pAPaterno, pAMaterno, pCalle, pNumExt, pNumInt, pColonia,
							pCiudad, pEstado, pTelefono, pCelular, pEmail, pStatus, pUsuario, NOW(), NOW() );
						SET codRetorno = '000';
						SET msg = 'Cliente Guardado con Exito';
					COMMIT;
				ELSE
					SET codRetorno = '001';
					SET msg = 'El RFC del Cliente ya fue Registrado';
					ROLLBACK;
				END IF;
			ELSE
				SET codRetorno = '001';
				SET msg = 'El Client ya fue Registrado';
				ROLLBACK;
			END IF; 
		END IF; 
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spInsUpdEditorial` (IN `pCodigo` BIGINT, IN `pNombreEditorial` VARCHAR(50), IN `pUsuario` VARCHAR(15), IN `pStatus` VARCHAR(15), OUT `CodRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `msgSQL` VARCHAR(100), OUT `id` INT)  BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
		@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
		SET msgSQL = @full_error;
		SET CodRetorno = '002';
		RESIGNAL;
		ROLLBACK;
	END; 
	DECLARE EXIT HANDLER FOR SQLWARNING
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
		@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
		SET msgSQL = @full_error;
		SET CodRetorno = '002';
		SHOW WARNINGS LIMIT 1;
		RESIGNAL;
		ROLLBACK;
	END;
			
	IF (pNombreEditorial = '' && pUsuario = '' && pStatus = '' ) THEN
		SET CodRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE
		IF (pCodigo != 0 ) THEN
			IF EXISTS(SELECT * FROM editoriales WHERE codigo_editorial = pCodigo) THEN
				IF NOT EXISTS(SELECT * FROM editoriales WHERE codigo_editorial != pCodigo AND nombre_editorial = CONVERT(pNombreEditorial USING utf8) COLLATE utf8_general_ci ) THEN
					START TRANSACTION;
						UPDATE editoriales SET nombre_editorial = pNombreEditorial,fechaModificacion = NOW() WHERE codigo_editorial = pCodigo;
						SET CodRetorno = '000';
						SET msg = 'Editorial Actualizado con Exito';
						SELECT codigo_editorial INTO id FROM editoriales WHERE codigo_editorial = pCodigo;
					COMMIT; 
				ELSE
					SET CodRetorno = '001';
					SET msg = 'El Nombre de la Editorial ya fue Registrado';
					ROLLBACK;
				END IF;
			ELSE
				SET CodRetorno = '001';
				SET msg = 'La Editorial no Existe';
			END IF;
		ELSE 
			IF NOT EXISTS(SELECT * FROM editoriales WHERE nombre_editorial = CONVERT(pNombreEditorial USING utf8) COLLATE utf8_general_ci ) THEN
				START TRANSACTION;
					INSERT INTO editoriales(nombre_editorial,usuario,status,fechaCreacion,fechaModificacion)
					VALUES (pNombreEditorial, pUsuario, pStatus,NOW(), NOW() );
					SET CodRetorno = '000';
					SET msg = 'Editorial Guardado con Exito';
					SET id =  LAST_INSERT_ID();
				COMMIT;
			ELSE
				SET CodRetorno = '001';
				SET msg = 'La Editorial ya Existe';
				SELECT codigo_editorial INTO id FROM editoriales WHERE nombre_editorial = CONVERT(pNombreEditorial USING utf8) COLLATE utf8_general_ci;
				ROLLBACK;
			END IF; 
		END IF; 
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spInsUpdEmpleado` (IN `pCodigo` BIGINT, IN `pNombreEmpleado` VARCHAR(20), IN `pAPaterno` VARCHAR(30), IN `pAMaterno` VARCHAR(30), IN `pCalle` VARCHAR(30), IN `pNumExt` INT, IN `pNumInt` VARCHAR(5), IN `pColonia` VARCHAR(30), IN `pCiudad` VARCHAR(30), IN `pEstado` VARCHAR(30), IN `pTelefono` VARCHAR(10), IN `pCelular` VARCHAR(10), IN `pSueldo` DECIMAL, IN `pPuesto` VARCHAR(30), IN `pStatus` VARCHAR(10), IN `pISUsu` INT, IN `pUsuario` VARCHAR(15), OUT `codRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `msgSQL` VARCHAR(100))  BEGIN
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
		
	IF (pNombreEmpleado = '' || pAPaterno = '' || pAMaterno =  '' || pNumExt = 0 || pColonia = '' || pCiudad = '' || pEstado = '' || pSueldo = 0.00 || pPuesto = '') THEN
		SET codRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE
		IF (pCodigo != 0) THEN
			IF EXISTS (SELECT * FROM empleados WHERE matricula = pCodigo) THEN
				IF NOT EXISTS (SELECT * FROM empleados WHERE matricula != pCodigo AND nombre_empleado = CONVERT(pNombreEmpleado USING utf8) COLLATE utf8_general_ci 
				AND apellido_paterno = CONVERT(pAPaterno USING utf8) COLLATE utf8_general_ci AND apellido_materno = CONVERT(pAMaterno USING utf8) COLLATE utf8_general_ci ) THEN
					START TRANSACTION;
						UPDATE empleados SET nombre_empleado = pNombreEmpleado, apellido_paterno = pAPaterno,apellido_materno = pAMaterno,
							calle = pCalle,	numExt = pNumExt,numInt = numInt,colonia = pColonia, ciudad = pCiudad, estado = pEstado, 
							telefono = pTelefono, celular = pCelular, sueldo = pSueldo, puesto = pPuesto,fechaModificacion = NOW()
						WHERE matricula = pCodigo;
						SET codRetorno = '000';
						SET msg = 'Empleado Actualizado con Exito';
					COMMIT; 
				ELSE
					SET codRetorno = '001';
					SET msg = 'El Nombre del Empleado ya fue Registrado';
					ROLLBACK;
				END IF;
			ELSE
				SET codRetorno = '001';
				SET msg = 'El Empleado no Existe';
			END IF;
		ELSE 
			IF NOT EXISTS(SELECT * FROM empleados WHERE nombre_empleado = CONVERT(pNombreEmpleado USING utf8) COLLATE utf8_general_ci ) THEN
				START TRANSACTION;
					INSERT INTO empleados(nombre_empleado,apellido_paterno,apellido_materno,calle,numExt,numInt,colonia,ciudad,estado,
						telefono,celular,sueldo,puesto,status,isUsu,usuario,fechaCreacion,fechaModificacion)
					VALUES (pNombreEmpleado, pAPaterno, pAMaterno, pCalle, pNumExt, pNumInt, pColonia, pCiudad, pEstado, pTelefono,
						pCelular, pSueldo, pPuesto, pStatus, pISUsu, pUsuario,NOW(), NOW() );
					SET codRetorno = '000';
					SET msg = 'Empleado Guardado con Exito';
				COMMIT;
			ELSE
				SET codRetorno = '001';
				SET msg = 'El Empleado ya Existe';
				ROLLBACK;
			END IF; 
		END IF; 
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spInsUpdLibro` (IN `pCodigo` BIGINT, IN `pNombreLibro` VARCHAR(50), IN `pISBN` VARCHAR(13), IN `pAutor` BIGINT, IN `pEditorial` BIGINT, IN `pDescripcion` VARCHAR(500), IN `pUsuario` VARCHAR(15), IN `pStatus` VARCHAR(10), IN `pRutaIMG` VARCHAR(50), OUT `codRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `msgSQL` VARCHAR(100), OUT `id` INT)  BEGIN
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
		
	IF (pCodigo != 0) THEN
		IF EXISTS(SELECT * FROM libros WHERE codigo_libro = pCodigo) THEN
			IF NOT EXISTS(SELECT * FROM libros WHERE codigo_libro != pCodigo AND nombre_libro = CONVERT(pNombreLibro USING utf8) COLLATE utf8_general_ci ) THEN
				START TRANSACTION;
					UPDATE libros SET nombre_libro = pNombreLibro,isbn = pISBN,autor = pAutor,editorial = pEditorial,descripcion = pDescripcion,rutaIMG = pRutaIMG,fechaModificacion = NOW()
					WHERE codigo_libro = pCodigo;
					SET codRetorno = '000';
					SET msg = 'Libro Actualizado con Exito';
					SELECT codigo_libro INTO id FROM libros WHERE codigo_libro = pCodigo;
				COMMIT; 
			ELSE
				SET codRetorno = '001';
				SET msg = 'El Nombre del Libro ya fue Registrado';
				ROLLBACK;
			END IF;
		ELSE
			SET codRetorno = '001';
			SET msg = 'El Libro no Existe';
		END IF;
	ELSE 
		IF NOT EXISTS(SELECT * FROM libros WHERE nombre_libro = CONVERT(pNombreLibro USING utf8) COLLATE utf8_general_ci ) THEN
			START TRANSACTION;
				INSERT INTO libros(nombre_libro,isbn,autor,editorial,descripcion,rutaIMG,usuario,status,fechaCreacion,fechaModificacion)
				VALUES (pNombreLibro, pISBN, pAutor, pEditorial, pDescripcion, pRutaIMG, pUsuario, pStatus,NOW(), NOW() );
				SET codRetorno = '000';
				SET msg = 'Libro Guardado con Exito';
				SET id =  LAST_INSERT_ID();
			COMMIT;
		ELSE
			SET codRetorno = '001';
			SET msg = 'El Libro ya Existe';
			ROLLBACK;
			SELECT codigo_libro INTO id FROM libros WHERE nombre_libro = CONVERT(pNombreLibro USING utf8) COLLATE utf8_general_ci;
		END IF; 
	END IF; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spInsUpdProducto` (IN `pCodigo` BIGINT, IN `pNombreProducto` VARCHAR(50), IN `pCodigoBarras` BIGINT, IN `pProveedor` BIGINT, IN `pStActual` INT, IN `pStMin` INT, IN `pStMax` INT, IN `pCompra` DECIMAL, IN `pVenta` DECIMAL, IN `pCategoria` BIGINT, IN `pStatus` VARCHAR(15), IN `pIsLibro` INT, IN `pUsuario` VARCHAR(15), OUT `codRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `msgSQL` VARCHAR(100))  BEGIN
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
						venta,categoria,status,isLibro,usuario,fechaCreacion,fechaModificacion)
					VALUES(pNombreProducto, pCodigoBarras, pProveedor, pStActual, pStMin, pStMax, pCompra, pVenta, pCategoria,
						pStatus, pIsLibro, pUsuario,NOW(), NOW() );
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `spInsUpdProveedor` (IN `pCodigo` BIGINT, IN `pNombreProveedor` VARCHAR(50), IN `pContacto` VARCHAR(50), IN `pAPaterno` VARCHAR(30), IN `pAMaterno` VARCHAR(30), IN `pCalle` VARCHAR(30), IN `pNumExt` INT, IN `pNumInt` VARCHAR(5), IN `pColonia` VARCHAR(30), IN `pCiudad` VARCHAR(30), IN `pEstado` VARCHAR(30), IN `pTelefono` VARCHAR(10), IN `pCelular` VARCHAR(10), IN `pEmail` VARCHAR(40), IN `pWeb` VARCHAR(50), IN `pStatus` VARCHAR(10), IN `pUsuario` VARCHAR(15), OUT `codRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `msgSQL` VARCHAR(100))  BEGIN
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
		
	IF (pNombreProveedor = '' || pAPaterno = '' || pAMaterno =  '' || pNumExt = 0 || pColonia = '' || pCiudad = '' || pEstado = '' || pTelefono = '' || pCelular = '' || pEmail = '') THEN
		SET codRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE
		IF (pCodigo != 0) THEN
			IF EXISTS(SELECT * FROM proveedores WHERE codigo_proveedor = pCodigo) THEN
				IF NOT EXISTS(SELECT * FROM proveedores WHERE codigo_proveedor != pCodigo AND nombre_proveedor = CONVERT(pNombreProveedor USING utf8) COLLATE utf8_general_ci ) THEN
					START TRANSACTION;
						UPDATE proveedores SET nombre_proveedor = pNombreProveedor, contacto = pContacto, apellido_paterno = pAPaterno,
							apellido_materno = pAMaterno, calle = pCalle, num_ext = pNumExt, num_int = pNumInt, colonia = pColonia, 
							ciudad = pCiudad, estado = pEstado,	telefono = pTelefono, celular = pCelular, email = pEmail, web = pWeb, fechaModificacion = NOW()
						WHERE codigo_proveedor = pCodigo;
						SET codRetorno = '000';
						SET msg = 'Proveedor Actualizado con Exito';
					COMMIT; 
				ELSE
					SET codRetorno = '001';
					SET msg = 'El Nombre del Proveedor ya fue Registrado';
					ROLLBACK;
				END IF;
			ELSE
				SET codRetorno = '001';
				SET msg = 'El Proveedor no Existe';
			END IF;
		ELSE 
			IF NOT EXISTS(SELECT * FROM proveedores WHERE nombre_proveedor = CONVERT(pNombreProveedor USING utf8) COLLATE utf8_general_ci ) THEN
				START TRANSACTION;
					INSERT INTO proveedores(nombre_proveedor,contacto,apellido_paterno,apellido_materno,calle,num_ext,num_int,colonia,
						ciudad,estado,telefono,celular,email,web,usuario,status,fechaCreacion,fechaModificacion)
					VALUES (pNombreProveedor, pContacto, pAPaterno, pAMaterno, pCalle, pNumExt, pNumInt, pColonia, pCiudad, pEstado, 
						pTelefono, pCelular, pEmail, pWeb, pUsuario, pStatus, NOW(), NOW() );
					SET codRetorno = '000';
					SET msg = 'Proveedor Guardado con Exito';
				COMMIT;
			ELSE
				SET codRetorno = '001';
				SET msg = 'El Proveedor ya Existe';
				ROLLBACK;
			END IF; 
		END IF; 
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spInsUpdRetiro` (IN `pCodigo` BIGINT, IN `pFolio` BIGINT, IN `pNombreEmpleado` VARCHAR(50), IN `pCantidad` DECIMAL, IN `pDescripcion` VARCHAR(100), IN `pStatus` VARCHAR(15), IN `pUsuario` VARCHAR(15), OUT `CodRetorno` CHAR(3), OUT `msg` VARCHAR(100))  BEGIN
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
			
	IF (COALESCE(pCodigo,'') = '' && COALESCE(pFolio,'') = '' && COALESCE(pNombreEmpleado,'') = '' && pCantidad = 0 && COALESCE(pCantidad,'') = '' && COALESCE(pDescripcion,'') = '' && COALESCE(pStatus,'') = '' ) THEN
		SET msg = 'Parametros Vacios';
        SET CodRetorno = '004';
	ELSE
		IF (pCodigo != 0 || COALESCE(pCodigo,'') = '') THEN
            IF EXISTS(SELECT * FROM retiros WHERE folio = pFolio) THEN
                START TRANSACTION;
                    UPDATE retiros SET cantidad = pCantidad, descripcion = pDescripcion, fechaModificacion = NOW() WHERE codigo_retiro = pCodigo AND folio = pFolio;
                    SET CodRetorno = '000';
                    SET msg = 'Retiro Actualizado con Exito';
                COMMIT; 
            ELSE 
                SET CodRetorno = '001';
                SET msg = 'El retiro no Existe';
                ROLLBACK;
            END IF;
		ELSE 
			IF ( (SELECT COUNT(*) FROM retiros WHERE folio = pFolio )= 0) THEN
				START TRANSACTION;
					INSERT INTO retiros (folio,fecha,empleado,cantidad,descripcion,status,usuario,fechaCreacion,fechaModificacion )
					VALUES (pFolio, NOW(), pNombreEmpleado, pCantidad, pDescripcion, pStatus, pUsuario, NOW(), NOW() );
					CALL spUpdFolios('retiros',@codRetorno,@msg);
					SET CodRetorno = '000';
					SET msg = 'Retiro Guardado con Exito';
				COMMIT;
			ELSE
				SET CodRetorno = '001';
				SET msg = 'El Folio del Retiro ya fue Registrado';
				ROLLBACK;
			END IF; 
		END IF; 
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spInsVenta` (IN `pFolio` BIGINT, IN `pNumEmpleado` BIGINT, IN `pNumCliente` BIGINT, IN `pTotal` DECIMAL(10,2), IN `pIsTarjeta` INT, IN `pFolioTarjeta` INT, IN `pStatus` CHAR(15), IN `pUsuario` CHAR(15), OUT `codRetorno` CHAR(3), OUT `msg` VARCHAR(100))  BEGIN
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

    IF (pFolio = 0 || pNumEmpleado = 0 || pNumCliente = 0 || pTotal = 0.00 || pIsTarjeta = 0 || pStatus = '' || pUsuario = '') THEN
        SET CodRetorno = '004';
        SET msg = 'Parametros Vacios';
    ELSE 
        IF NOT EXISTS (SELECT folio FROM ventas WHERE folio = pFolio) THEN 
            START TRANSACTION;
                INSERT INTO ventas (folio,fecha_venta,empleado,cliente,total,isTarjeta,folioTarjeta,status,usuario,fechaCreacion,fechaModificacion) 
                VALUES (pFolio, NOW(), pNumEmpleado, pNumCliente, pTotal, pIsTarjeta, pFolioTarjeta, pStatus, pUsuario, NOW(), NOW());
                CALL spUpdFolios('ventas',@codRetorno,@msg);
                SET CodRetorno = '000';
                SET msg = 'SP Ejecutado con Exito';
            COMMIT; 
        ELSE
            SET CodRetorno = '001';
            SET msg = 'El Folio ya fue Registrado';
            ROLLBACK;  
        END IF;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spRecuperaFolio` (IN `pTabla` VARCHAR(10), IN `pCodigo` BIGINT, OUT `codRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `msgSQL` VARCHAR(100))  BEGIN
    DECLARE vFolio BIGINT;
    DECLARE vAnio INT;
    DECLARE vMes INT;
    DECLARE vDia INT;
    DECLARE vConsecutivo INT;

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
		SHOW WARNINGS LIMIT 1;
		SET codRetorno = '002';
		RESIGNAL;
		ROLLBACK;
	END;

	IF (pCodigo = 0 || pTabla = '') THEN
		SET codRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE
		IF EXISTS (SELECT * FROM empleados WHERE matricula = pCodigo ) THEN
			select YEAR(NOW()) INTO vAnio;
            select Date_format(NOW(),' %m') INTO vMes;  
            select DAY(NOW()) INTO vDia;

            SET vFolio = CONCAT(vAnio,'0',vMes,vDia); 

            IF ( (SELECT COUNT(consecutivo) FROM folios WHERE nombre = pTabla AND anio = vAnio) > 0) THEN
            	SELECT consecutivo INTO vConsecutivo FROM folios WHERE nombre = pTabla AND anio = vAnio;
            	SET vFolio = CONCAT((vFolio * 10000),vConsecutivo);
            ELSE
            	START TRANSACTION;
            		INSERT INTO folios (nombre,anio,consecutivo) VALUES(pTabla,vAnio,1);
            		SET vFolio = CONCAT((vFolio * 10000),1);
            	COMMIT;
            END IF;

			SELECT vFolio AS folio,CONCAT(nombre_empleado,' ',apellido_paterno,' ',apellido_materno) AS nombreEmpleado FROM empleados WHERE matricula = pCodigo;

            SET codRetorno = '000';
			SET msg = 'SP Ejecutado Correctamente';
		ELSE
			SET codRetorno = '001';
			SET msg = 'El Empleado no Existe';
		END IF;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spUpdFolios` (IN `pTabla` VARCHAR(10), IN `pBandera` INT, OUT `codRetorno` CHAR(3), OUT `msg` VARCHAR(100))  BEGIN
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `spUpdStock` (IN `pCodigo` BIGINT, IN `pStActual` INT, IN `pStatus` VARCHAR(15), OUT `codRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `msgSQL` VARCHAR(100))  BEGIN
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `spValidaUsuario` (IN `pNombre` VARCHAR(10), IN `pUsuario` VARCHAR(10), OUT `codRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `msgSQL` VARCHAR(100))  BEGIN

	DECLARE isAdmin INT;
	DECLARE vStatus VARCHAR(15);

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

	IF (pNombre = '' && pUsuario = '') THEN
		SET codRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE		
		IF EXISTS (SELECT * FROM usuarios WHERE nombre_usuario = CONVERT(pNombre USING utf8) COLLATE utf8_general_ci) THEN
			SELECT tipo_usuario INTO isAdmin FROM usuarios WHERE nombre_usuario = CONVERT(pUsuario USING utf8) COLLATE utf8_general_ci ;

			IF (isAdmin != 1) THEN
				SELECT status INTO vStatus FROM usuarios WHERE nombre_usuario = CONVERT(pNombre USING utf8) COLLATE utf8_general_ci;
				IF (vStatus = 'DISPONIBLE') THEN
					SELECT u.matricula_empleado,u.tipo_usuario,u.nombre_usuario,u.status,u.password,
						CONCAT(e.nombre_empleado,' ',e.apellido_paterno,' ',e.apellido_materno) AS nombreEmpleado
					FROM usuarios u
					INNER JOIN empleados e ON e.matricula = u.matricula_empleado
					WHERE u.status = 'DISPONIBLE' AND nombre_usuario = CONVERT(pNombre USING utf8) COLLATE utf8_general_ci;
					SET codRetorno = '000';
					SET msg = 'SP Ejecutado Correcamente';
				ELSE 
					SET codRetorno = '001';
					SET msg = 'Usuario Bloqueado';
				END IF;
			ELSE
				SELECT u.matricula_empleado,u.tipo_usuario,u.nombre_usuario,u.status,u.password,
					CONCAT(e.nombre_empleado,' ',e.apellido_paterno,' ',e.apellido_materno) AS nombreEmpleado
				FROM usuarios u
				INNER JOIN empleados e ON e.matricula = u.matricula_empleado
				WHERE nombre_usuario = CONVERT(pNombre USING utf8) COLLATE utf8_general_ci;
				SET codRetorno = '000';
				SET msg = 'SP Ejecutado Correcamente';
			END IF;
		ELSE 
			SET codRetorno = '001';
			SET msg = 'El Usuario no Existe';
		END IF;
	END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `autores`
--

CREATE TABLE `autores` (
  `codigo_autor` bigint(20) NOT NULL,
  `nombre_autor` varchar(50) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `usuario` varchar(15) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `status` varchar(15) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `fechaCreacion` datetime NOT NULL,
  `fechaModificacion` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `autores`
--

INSERT INTO `autores` (`codigo_autor`, `nombre_autor`, `usuario`, `status`, `fechaCreacion`, `fechaModificacion`) VALUES
(1, 'j. k. rowling', '1', 'DISPONIBLE', '2016-08-17 00:00:00', '2017-08-04 14:28:46'),
(2, 'gabriel marquez', '1', 'DISPONIBLE', '2016-08-17 00:00:00', '2017-08-04 11:08:42'),
(3, 'Dante Alighieri''s', 'felipe', 'DISPONIBLE', '2016-08-27 00:00:00', '2016-08-27 00:00:00'),
(4, 'paulo cohelo', 'felipe', 'DISPONIBLE', '2016-09-11 02:21:00', '2016-09-11 02:21:00'),
(5, 'hiro fujiwara', 'felipe', 'DISPONIBLE', '2016-09-11 02:27:00', '2017-08-04 11:50:11'),
(6, 'arre lulu', 'felipe', 'DISPONIBLE', '2016-09-11 02:31:00', '2016-09-11 02:31:00'),
(7, 'shiro', 'felipe', 'DISPONIBLE', '2016-09-15 11:06:00', '2016-09-15 11:06:00'),
(8, 'vina jackson', 'felipe', 'DISPONIBLE', '2016-09-15 11:09:00', '2017-08-04 10:00:11'),
(9, 'juan manuel', 'felipe', 'DISPONIBLE', '2016-12-29 04:17:00', '2017-01-11 09:26:00'),
(10, 'juan rulfo', 'felipe', 'DISPONIBLE', '2017-01-11 09:17:00', '2017-01-11 09:25:00'),
(11, 'max lhew', 'felipe', 'DISPONIBLE', '2017-01-11 09:26:00', '2017-01-11 09:26:00'),
(12, 'gabriel garcia marquez', 'felipe', 'DISPONIBLE', '2017-03-23 09:23:00', '2017-03-23 09:23:00'),
(13, 'juan rulfo', 'felipe', 'DISPONIBLE', '2017-03-23 09:29:00', '2017-03-23 09:29:00'),
(14, 'steve job', 'felipe', 'DISPONIBLE', '2017-03-23 09:30:00', '2017-03-23 09:30:00'),
(15, 'jshwj', 'felipe', 'DISPONIBLE', '2017-03-23 09:34:00', '2017-03-23 09:34:00'),
(16, 'sie mash', 'felipe', 'DISPONIBLE', '2017-03-23 09:36:00', '2017-03-23 09:40:00'),
(17, 'dcdcdcd', 'felipe', 'DISPONIBLE', '2017-07-13 11:59:56', '2017-07-13 11:59:56');

-- --------------------------------------------------------

--
-- Table structure for table `categorias_producto`
--

CREATE TABLE `categorias_producto` (
  `codigo_catpro` bigint(20) NOT NULL,
  `nombre_categoria` varchar(20) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `categorias_producto`
--

INSERT INTO `categorias_producto` (`codigo_catpro`, `nombre_categoria`) VALUES
(1, 'LIBROS'),
(2, 'DIDACTICOS'),
(3, 'COMIC'),
(4, 'MANGA'),
(5, 'OTROS');

-- --------------------------------------------------------

--
-- Table structure for table `clientes`
--

CREATE TABLE `clientes` (
  `matricula` bigint(20) NOT NULL,
  `rfc` char(13) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `empresa` varchar(30) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `nombre_contacto` varchar(20) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `apellido_paterno` varchar(30) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `apellido_materno` varchar(30) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `calle` varchar(30) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `numExt` char(5) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `numInt` varchar(5) CHARACTER SET utf8 COLLATE utf8_spanish_ci DEFAULT NULL,
  `colonia` varchar(30) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `ciudad` varchar(30) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `estado` varchar(30) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `telefono` varchar(10) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `celular` varchar(10) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `email` varchar(30) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `status` char(10) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `usuario` varchar(15) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `fechaCreacion` datetime NOT NULL,
  `fechaModificacion` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `clientes`
--

INSERT INTO `clientes` (`matricula`, `rfc`, `empresa`, `nombre_contacto`, `apellido_paterno`, `apellido_materno`, `calle`, `numExt`, `numInt`, `colonia`, `ciudad`, `estado`, `telefono`, `celular`, `email`, `status`, `usuario`, `fechaCreacion`, `fechaModificacion`) VALUES
(1, 'xxxxxxxxxxxxx', 'cliente general', 'cliente general', '', '', '', '0', '', '', '', '', '0', '0', 'null@null.com', 'DISPONIBLE', '', '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(2, 'solj841524457', 'bookvillage', 'jorge', 'soto', 'luna', 'juarez', '3312', 'A', 'las vegas', 'teic', 'Baja California', '6767105585', '6678954623', 'luis@book.com', 'BAJA', '', '0000-00-00 00:00:00', '2017-05-23 15:23:59'),
(3, 'CUPU800825569', 'papeleria del sol', 'juan', 'lopez', 'vargas', 'obregon', '5324', '5', 'centro', 'culiacan', 'sinaloa', '6675481875', '6677895471', 'ejemplo@yo.com', 'DISPONIBLE', '', '0000-00-00 00:00:00', '2017-03-26 03:32:00'),
(5, 'peol850457123', 'librerÃ­a norte del sol', 'luis', 'perez', 'oso', 'lejana', '22', '', 'de', 'culiacan', 'sinaloa', '6761457828', '6768915272', 'ejemplo@yo.com', 'DISPONIBLE', '', '0000-00-00 00:00:00', '2017-05-23 15:22:28'),
(6, 'momf900527538', 'libreria caracol', 'jorge', 'mendoza', 'lopez', 'muy lejana', '4040', 'C', 'mazatlan', 'mazatlan', 'sinaloa', '6677584796', '6679154835', 'caracol@gmail.com', 'DISPONIBLE', '', '0000-00-00 00:00:00', '2017-05-09 12:51:26'),
(7, 'oslr740537123', 'libreria mexico', 'rosa', 'osuna', 'lopez', 'grande', '1515', '', 'centro', 'los mochis', 'sinaloa', '2147483647', '2147483647', 'yo@gmail.com', 'DISPONIBLE', '', '0000-00-00 00:00:00', '2017-05-23 15:21:02'),
(8, '1vwd1d15s3sds', 'libreria Buen libro', 'ruben Alfonso', 'mendoza', 'mendoza', 'perrona', '152', '4', 'las vegas', 'tepito', 'CDMX', '5507862', '6675084532', 'tepito@gmail.com', 'DISPONIBLE', '', '0000-00-00 00:00:00', '2016-08-31 09:47:00'),
(9, 'rolj953245646', 'librerÃ­a del sol 2', 'juan', 'rojo', 'lugo', 'camarÃ³n', '457', '5', 'las palmas', 'mazatlan', 'sinaloa', '6677154812', '2147483647', 'libreriadelsol@gmail.com', 'DISPONIBLE', 'felipe', '2016-08-29 09:25:00', '2017-05-23 15:24:48'),
(10, 'lolj910245123', 'librerÃ­a del sol', 'juan luis', 'lopez', 'lopez', 'camarones', '452', '6', 'las palmas', 'mazatlan', 'sinaloa', '6787481526', '2147483647', 'juan@gmail.com', 'DISPONIBLE', 'felipe', '2016-08-29 09:29:00', '2017-08-17 11:27:57'),
(11, 'jsal850412002', 'librerÃ­a estrella', 'juan Ernesto', 'sanches', 'lopez', 'sindicalsimo', '4818', 'a', 'infonavit barrancos', 'culiacan', 'sinaloa', '6677106788', '6671568899', 'felipe_borre@hotmail.com', 'DISPONIBLE', 'felipe', '2017-02-07 03:28:00', '2017-08-17 11:26:17');

-- --------------------------------------------------------

--
-- Table structure for table `cortecaja`
--

CREATE TABLE `cortecaja` (
  `folioCorte` bigint(20) NOT NULL,
  `fecha_corte` datetime NOT NULL,
  `empleado` varchar(50) COLLATE utf8_spanish2_ci NOT NULL,
  `ingreso` decimal(10,2) NOT NULL,
  `egreso` decimal(10,2) NOT NULL,
  `total` decimal(10,2) NOT NULL,
  `status` varchar(10) COLLATE utf8_spanish2_ci NOT NULL,
  `usuario` varchar(20) COLLATE utf8_spanish2_ci NOT NULL,
  `fechaCreacion` datetime NOT NULL,
  `fechaModificacion` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Dumping data for table `cortecaja`
--

INSERT INTO `cortecaja` (`folioCorte`, `fecha_corte`, `empleado`, `ingreso`, `egreso`, `total`, `status`, `usuario`, `fechaCreacion`, `fechaModificacion`) VALUES
(201703200001, '2017-03-20 03:46:00', 'FELIPE MONZON MENDOZA', '880.00', '150.00', '730.00', 'REALIZADO', 'felipe', '2017-03-21 03:46:00', '2017-03-21 03:46:00');

-- --------------------------------------------------------

--
-- Table structure for table `detalle_venta`
--

CREATE TABLE `detalle_venta` (
  `folio` bigint(20) NOT NULL,
  `clave_producto` bigint(20) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Dumping data for table `detalle_venta`
--

INSERT INTO `detalle_venta` (`folio`, `clave_producto`, `cantidad`, `precio`, `subtotal`) VALUES
(2015070001, 3, 1, '200.00', '200.00'),
(2015070001, 4, 2, '251.00', '502.00'),
(2015070002, 3, 1, '200.00', '200.00'),
(2015070002, 4, 2, '251.00', '502.00'),
(2015070003, 3, 3, '200.00', '600.00'),
(2015070007, 3, 1, '200.00', '200.00'),
(2015070007, 5, 2, '50.00', '100.00'),
(2015070008, 5, 1, '50.00', '50.00'),
(2015070008, 6, 1, '100.00', '100.00'),
(2015070008, 7, 1, '100.00', '100.00'),
(2015070009, 3, 1, '200.00', '200.00'),
(2015070009, 6, 1, '100.00', '100.00'),
(20150700010, 3, 1, '200.00', '200.00'),
(20150700010, 5, 1, '50.00', '50.00'),
(20150700010, 6, 1, '100.00', '100.00'),
(20150800011, 5, 1, '50.00', '50.00'),
(20150800011, 6, 1, '100.00', '100.00'),
(20150800012, 5, 1, '50.00', '50.00'),
(20150800013, 4, 2, '251.00', '502.00'),
(20150800013, 6, 2, '100.00', '200.00'),
(20150800014, 4, 1, '251.00', '251.00'),
(20150800014, 7, 1, '100.00', '100.00'),
(20150800015, 5, 10, '50.00', '500.00'),
(20150800016, 6, 3, '100.00', '300.00'),
(20150800017, 4, 5, '251.00', '1255.00'),
(20150800019, 5, 2, '50.00', '100.00'),
(20150800020, 6, 1, '100.00', '100.00'),
(20150800021, 7, 5, '100.00', '500.00'),
(20150800022, 8, 1, '500.00', '500.00'),
(20150800023, 5, 4, '50.00', '200.00'),
(20151000024, 6, 2, '100.00', '200.00'),
(20151000024, 7, 2, '100.00', '200.00'),
(201703060001, 3, 2, '20.00', '40.00'),
(201703060001, 4, 2, '25.50', '51.00'),
(201703060002, 6, 2, '10.00', '20.00'),
(201703060003, 3, 2, '20.00', '40.00'),
(201703060003, 9, 2, '220.00', '440.00'),
(201703060004, 4, 3, '25.50', '76.50'),
(201703060005, 3, 2, '20.00', '40.00'),
(201703060006, 4, 2, '25.50', '51.00'),
(201703060007, 4, 2, '25.50', '51.00'),
(201703060008, 4, 2, '25.50', '51.00'),
(201703070009, 4, 3, '25.50', '76.50'),
(2017030700010, 4, 2, '25.50', '51.00'),
(2017031000011, 9786074009811, 2, '220.00', '440.00'),
(2017031000011, 9788478887590, 1, '150.00', '150.00'),
(2017031000012, 9786074009811, 2, '220.00', '440.00'),
(2017031000012, 9788478887590, 1, '150.00', '150.00'),
(2017031000013, 9788478887590, 2, '150.00', '300.00'),
(2017031000014, 9788478887590, 2, '150.00', '300.00'),
(2017031000015, 9788478887590, 1, '150.00', '150.00'),
(2017031000016, 9786074009811, 2, '220.00', '440.00'),
(2017031000017, 9786074009811, 2, '220.00', '440.00'),
(2017031000018, 9786074009811, 2, '220.00', '440.00'),
(2017031200019, 9788478887590, 2, '150.00', '300.00'),
(2017031200019, 9788478887606, 2, '300.00', '600.00'),
(2017031200019, 9788478887613, 2, '300.00', '600.00'),
(2017031600020, 9786074009811, 4, '220.00', '880.00'),
(2017032000021, 9786074009811, 2, '220.00', '440.00'),
(2017032000022, 9786074009811, 2, '220.00', '440.00'),
(2017032100023, 9786074009811, 2, '220.00', '440.00'),
(2017032200024, 9788478887590, 1, '150.00', '150.00'),
(2017032400025, 9786074009811, 1, '220.00', '220.00'),
(2017032900026, 9788478887590, 1, '150.00', '150.00'),
(2017032900026, 9788478887606, 2, '300.00', '600.00'),
(2017032900026, 9788478887613, 1, '300.00', '300.00'),
(2017082500001, 8, 2, '180.00', '360.00'),
(2017082500001, 9788478887613, 2, '300.00', '600.00');

-- --------------------------------------------------------

--
-- Table structure for table `deudas`
--

CREATE TABLE `deudas` (
  `clave_deuda` bigint(20) NOT NULL,
  `folio_deuda` bigint(20) NOT NULL,
  `fecha_compra` datetime NOT NULL,
  `folio_venta` bigint(20) NOT NULL,
  `matricula_cliente` bigint(20) NOT NULL,
  `total_deuda` decimal(10,2) NOT NULL,
  `total_abbono` decimal(10,2) NOT NULL DEFAULT '0.00',
  `status` varchar(15) COLLATE utf8_spanish2_ci NOT NULL,
  `usuario` varchar(20) COLLATE utf8_spanish2_ci NOT NULL,
  `fechaCreacion` datetime NOT NULL,
  `fechaModificacion` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Dumping data for table `deudas`
--

INSERT INTO `deudas` (`clave_deuda`, `folio_deuda`, `fecha_compra`, `folio_venta`, `matricula_cliente`, `total_deuda`, `total_abbono`, `status`, `usuario`, `fechaCreacion`, `fechaModificacion`) VALUES
(1, 201703260004, '2017-03-10 00:00:00', 2017031000018, 3, '440.00', '0.00', 'ACTIVO', 'felipe', '2017-03-26 07:35:00', '2017-03-26 07:35:00'),
(2, 201703270005, '2017-03-24 00:00:00', 2017032400025, 3, '220.00', '0.00', 'ACTIVO', 'felipe', '2017-03-27 08:14:00', '2017-03-27 08:14:00'),
(3, 201703270006, '2017-03-22 00:00:00', 2017032200024, 3, '150.00', '0.00', 'ACTIVO', 'felipe', '2017-03-27 09:51:00', '2017-03-27 09:51:00'),
(4, 201703270007, '2017-03-20 00:00:00', 2017032000022, 3, '440.00', '0.00', 'ACTIVO', 'felipe', '2017-03-27 09:52:00', '2017-03-27 09:52:00'),
(5, 201703270008, '2017-03-20 00:00:00', 2017032000021, 3, '440.00', '0.00', 'ACTIVO', 'felipe', '2017-03-27 09:53:00', '2017-03-27 09:53:00'),
(6, 201703290009, '2017-03-29 00:00:00', 2017032900026, 3, '1050.00', '0.00', 'ACTIVO', 'felipe', '2017-03-29 08:07:00', '2017-03-29 08:07:00');

-- --------------------------------------------------------

--
-- Table structure for table `editoriales`
--

CREATE TABLE `editoriales` (
  `codigo_editorial` bigint(20) NOT NULL,
  `nombre_editorial` varchar(50) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `status` varchar(15) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `usuario` varchar(15) NOT NULL,
  `fechaCreacion` datetime NOT NULL,
  `fechaModificacion` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `editoriales`
--

INSERT INTO `editoriales` (`codigo_editorial`, `nombre_editorial`, `status`, `usuario`, `fechaCreacion`, `fechaModificacion`) VALUES
(1, 'oceano', 'DISPONIBLE', '1', '2016-08-17 00:00:00', '2017-08-04 11:05:23'),
(2, 'tomo', 'DISPONIBLE', '1', '2016-08-17 00:00:00', '2017-08-04 11:08:42'),
(3, 'mega', 'DISPONIBLE', '0', '2016-09-16 02:22:00', '2016-09-16 02:22:00'),
(4, 'larousse', 'DISPONIBLE', '0', '2016-09-16 02:23:00', '2016-09-16 02:23:00'),
(5, 'mexicana', 'DISPONIBLE', '0', '2017-01-11 07:36:00', '2017-01-11 07:36:00'),
(6, 'mega', 'DISPONIBLE', '0', '2017-01-11 07:38:00', '2017-04-30 19:34:24'),
(7, 'panini manga', 'DISPONIBLE', '0', '2017-01-11 07:40:00', '2017-08-04 11:49:30'),
(8, 'linea roja mexicana', 'DISPONIBLE', '0', '2017-01-11 08:26:00', '2017-01-11 08:47:00'),
(9, 'max', 'DISPONIBLE', '0', '2017-01-11 08:27:00', '2017-01-11 08:27:00'),
(10, 'mÃ¡xima espaÃ±ola', 'DISPONIBLE', '0', '2017-01-11 09:16:00', '2017-01-11 09:26:00'),
(11, 'rusa unida', 'DISPONIBLE', '0', '2017-01-11 09:27:00', '2017-01-11 09:27:00'),
(12, 'maeva', 'DISPONIBLE', '0', '2017-01-12 08:14:00', '2017-08-04 10:00:11'),
(13, 'salamandra', 'DISPONIBLE', '0', '2017-03-12 10:21:00', '2017-08-04 14:28:31'),
(14, 'nueva imagen', 'DISPONIBLE', '0', '2017-03-23 09:57:00', '2017-03-23 09:57:00'),
(15, 'cdcdcd', 'DISPONIBLE', 'felipe', '2017-07-13 16:54:35', '2017-07-13 16:54:35');

-- --------------------------------------------------------

--
-- Table structure for table `empleados`
--

CREATE TABLE `empleados` (
  `matricula` bigint(20) NOT NULL,
  `nombre_empleado` varchar(20) CHARACTER SET latin1 NOT NULL,
  `apellido_paterno` varchar(30) CHARACTER SET latin1 NOT NULL,
  `apellido_materno` varchar(30) CHARACTER SET latin1 NOT NULL,
  `calle` varchar(20) CHARACTER SET latin1 NOT NULL,
  `numExt` int(5) NOT NULL,
  `numInt` varchar(3) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `colonia` varchar(30) CHARACTER SET latin1 NOT NULL,
  `ciudad` varchar(30) CHARACTER SET latin1 DEFAULT NULL,
  `estado` varchar(30) CHARACTER SET latin1 NOT NULL,
  `telefono` char(10) CHARACTER SET latin1 NOT NULL,
  `celular` char(10) CHARACTER SET latin1 NOT NULL,
  `sueldo` char(10) CHARACTER SET latin1 NOT NULL,
  `puesto` varchar(30) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `status` char(10) CHARACTER SET latin1 NOT NULL,
  `isUsu` int(11) NOT NULL DEFAULT '0',
  `usuario` varchar(15) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `fechaCreacion` datetime NOT NULL,
  `fechaModificacion` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `empleados`
--

INSERT INTO `empleados` (`matricula`, `nombre_empleado`, `apellido_paterno`, `apellido_materno`, `calle`, `numExt`, `numInt`, `colonia`, `ciudad`, `estado`, `telefono`, `celular`, `sueldo`, `puesto`, `status`, `isUsu`, `usuario`, `fechaCreacion`, `fechaModificacion`) VALUES
(1, 'juan', 'martinez', 'lopez', 'muy larga', 4815, 'B', 'la mas peligrosa 2', 'juarez', 'sinaloa', '6677105452', '6673031398', '1100', 'cajero', 'DISPONIBLE', 1, 'felipe', '0000-00-00 00:00:00', '2017-08-16 11:45:27'),
(2, 'felipe', 'monzon', 'mendoza', 'siempre viva', 1234, '5', 'alegre', 'springfield', 'california', '7106788', '6671234567', '4957', 'capturista', 'DISPONIBLE', 1, 'felipe', '0000-00-00 00:00:00', '2016-09-01 10:18:00'),
(3, 'luis', 'oso', 'oso', 'quinta av.', 4215, '', 'diaz ordaz', 'culiacan', 'sinaloa', '7154824', '6672051684', '1100', '', 'BAJA', 0, 'felipe', '0000-00-00 00:00:00', '2016-09-16 09:33:00'),
(4, 'jose', 'lopez', 'lopez', 'sindicalismo', 4818, 'a', 'infonavit barrancos', 'culiacan', 'sinalos', '6677106788', '6673031398', '400', 'vendedor', 'DISPONIBLE', 1, 'felipe', '2016-08-27 03:19:00', '2017-05-08 18:05:48'),
(5, 'juan', 'perez', 'lopez', 'corta', 4452, 'A', 'peligrosa', 'culiacan', 'sinaloa', '7106788', '6673031398', '400', 'vendedor', 'DISPONIBLE', 0, 'felipe', '2016-09-01 10:05:00', '2016-09-01 10:05:00'),
(6, 'felipe de jesus', 'monzon', 'mendoza', 'sindicalsimo', 4818, 'a', 'infonavit barrancos', 'culiacan', 'sinaloa', '6677606060', '6673031398', '$3150.50', 'cajero', 'DISPONIBLE', 1, 'felipe', '2017-01-19 05:09:00', '2017-01-21 12:24:00'),
(7, 'paola', 'lopez', 'mendoza', 'muy lejana', 7584, 'X', 'las vegas', 'pequeÃ±a', 'grande', '6671548278', '6673021548', '3500', 'cajera', 'felipe', 0, 'DISPONIBLE', '2017-05-11 10:02:17', '2017-05-11 10:02:17'),
(8, 'xssssssssss', 'xsxsxsxsx', 'sxsxsxsxsx', 'swxsxsxs', 22222, '222', 'xsxsxs', 'xssxsxsx', 'sxsxsxsxsxs', '(667) 710-', '(667) 303-', '22', 'sxsxsx', 'DISPONIBLE', 0, 'felipe', '2017-08-15 12:11:47', '2017-08-15 12:11:47'),
(9, 'zzzzzzzzzzz', 'zzzzzzzzzzzzzzz', 'zzzzzzzzzzzzzzzzzzzzzzzzzzz', 'ssssssssss', 22222, '222', 'sssssssssss', 'sssssssss', 'ssssssssssssssssssssssss', '3333333333', '3333333333', '2', 'dddddddddddddd', 'DISPONIBLE', 0, 'felipe', '2017-08-15 17:19:00', '2017-08-15 17:19:00');

-- --------------------------------------------------------

--
-- Table structure for table `folios`
--

CREATE TABLE `folios` (
  `id` bigint(20) NOT NULL,
  `nombre` char(10) COLLATE utf8_bin NOT NULL,
  `anio` int(11) NOT NULL,
  `consecutivo` bigint(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Dumping data for table `folios`
--

INSERT INTO `folios` (`id`, `nombre`, `anio`, `consecutivo`) VALUES
(1, 'ventas', 2015, 25),
(2, 'compras', 2015, 9),
(3, 'cortecaja', 2015, 1),
(4, 'retiro', 2016, 2),
(8, 'retiro', 2017, 12),
(9, 'deuda', 2017, 9),
(11, 'venta', 2017, 26),
(12, 'corteCaja', 2017, 1),
(13, 'retiros', 2017, 3),
(14, 'ventas', 2017, 2);

-- --------------------------------------------------------

--
-- Table structure for table `generos`
--

CREATE TABLE `generos` (
  `codigo_genero` bigint(20) NOT NULL,
  `nombre_genero` varchar(50) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `usuario` bigint(20) NOT NULL,
  `fechaCreacion` datetime NOT NULL,
  `fechaModificacion` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `generos`
--

INSERT INTO `generos` (`codigo_genero`, `nombre_genero`, `usuario`, `fechaCreacion`, `fechaModificacion`) VALUES
(1, 'Terror', 1, '2016-08-17 13:26:00', '2016-08-17 14:19:25'),
(2, 'Drama', 1, '2016-08-17 13:26:00', '2016-08-17 14:19:25'),
(3, 'suspenso', 0, '2016-09-16 02:04:00', '2016-09-16 02:05:00'),
(4, 'novela', 0, '2016-09-16 02:06:00', '2016-09-16 02:06:00'),
(5, 'infantiles', 0, '2016-09-16 02:06:00', '2016-09-16 02:06:00');

-- --------------------------------------------------------

--
-- Table structure for table `libros`
--

CREATE TABLE `libros` (
  `codigo_libro` bigint(20) NOT NULL,
  `nombre_libro` varchar(50) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `isbn` varchar(13) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `autor` bigint(20) NOT NULL,
  `editorial` bigint(20) NOT NULL,
  `descripcion` varchar(500) CHARACTER SET utf8 COLLATE utf8_spanish_ci DEFAULT NULL,
  `rutaIMG` varchar(100) NOT NULL,
  `usuario` varchar(15) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `status` varchar(10) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `fechaCreacion` datetime NOT NULL,
  `fechaModificacion` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `libros`
--

INSERT INTO `libros` (`codigo_libro`, `nombre_libro`, `isbn`, `autor`, `editorial`, `descripcion`, `rutaIMG`, `usuario`, `status`, `fechaCreacion`, `fechaModificacion`) VALUES
(1, 'el principito', '14287596', 2, 2, 'la historia de un prÃ­ncipe chiquito que se perdiÃ³ en un desierto muy peligroso que no le gustan los dibujos feos', 'images/elprincipito.jpg', '1', 'DISPONIBLE', '2016-08-19 08:52:00', '2017-08-04 11:08:42'),
(2, 'ochenta melodÃ­as de pasiÃ³n en amarillo', '9786074009811', 8, 12, 'libro de pasiÃ³n y mÃºsica sobre violinistas', 'images/ochentamelodiasdepasionenamarillo.jpg', '1', 'DISPONIBLE', '2016-08-20 04:27:00', '2017-07-31 15:29:51'),
(3, 'la divina comedia infierno', '9706664581', 3, 2, 'primer libro de la saga ', '', 'felipe', 'DISPONIBLE', '2016-08-27 11:12:00', '2016-08-27 12:05:00'),
(4, 'las aventuras de tom sayer', '1542478522111', 5, 4, 'cuenta la historia de un niÃ±o travieso', '', 'felipe', 'DISPONIBLE', '2016-09-16 02:41:00', '2016-09-16 02:41:00'),
(5, '404', '1111111111111', 6, 4, '', '', 'felipe', 'DISPONIBLE', '2016-12-31 07:37:00', '2016-12-31 07:37:00'),
(6, 'ochenta melodias de pasiÃ³n en azul', '1111111111111', 8, 12, 'Recientemente instalada en Nueva York, la pelirroja Summer Zahova estÃ¡ disfrutando de su vida como violinista en una orquesta importante. Bajo la atenta mirada de SimÃ³n, su impresionante director venezolano, su carrera, y la propia Summer, florecerÃ¡n. Pero una nueva ciudad, un Ã©xito reciente, le deparan nuevas tentaciones, y muy pronto Summer se ve arrastrada de nuevo a un peligroso mundo ilÃ­cito y peligroso de intriga y deseo que creÃ­a haber dejado atrÃ¡s para siempre.', 'images/ochentamelodiasdepasionenazul.jpg', 'felipe', 'DISPONIBLE', '2017-01-12 08:24:00', '2017-07-31 15:36:10'),
(7, 'ochenta melodias de pasion en rojo', '1215451054151', 8, 12, 'La renombrada violinista Summer Zahova regresa a Londres, la ciudad donde todo empezÃ³ para ella. Libre y soltera en la hedonista capital, Summer se embarca e una serie de ardientes aventuras, aceptando las excitantes y nuevas oportunidades y viajando a Europa para cumplir sus sueÃ±os.', 'images/ochentamelodiasdepasionenrojo.jpg', 'felipe', 'DISPONIBLE', '2017-01-12 08:28:00', '2017-08-04 10:00:11'),
(8, 'harry potter y la piedra filosofal', '9788478887590', 1, 13, 'harry ha quedado huÃ©rfano y vive con sus abdominales tios', 'images/harrypotterylapiedrafilosofal.jpg', 'felipe', 'DISPONIBLE', '2017-03-08 04:56:00', '2017-08-04 11:07:30'),
(9, 'harry potter y el prisionero de azkaban', '9788478887613', 1, 13, 'por la cicatriz que lleva en la frente ', 'images/harrypotteryelprisionerodeazkaban.jpg', 'felipe', 'DISPONIBLE', '2017-03-12 10:20:00', '2017-08-04 14:28:55'),
(10, 'harry potter y la camara de los secretos', '9788478887606', 1, 13, 'tras derrotar una vez mÃ s a lord voldemort', 'images/harrypotterylacamaradelossecretos.jpg', 'felipe', 'DISPONIBLE', '2017-03-12 10:23:00', '2017-08-03 12:48:06'),
(11, 'harry potter y el cÃ¡liz de fuego', '9788478887620', 1, 1, 'tras otro abominable verano con los Dursley harry se dispone a cursar el cuarto aÃ±o en hogwarts la famosa escuela de magia y hechicerÃ­a', '', 'felipe', 'DISPONIBLE', '2017-03-24 08:36:00', '2017-03-24 10:21:00'),
(12, 'harry potter y la orden del fÃ©nix', '9788478887446', 1, 1, 'las tediosas vacaciones de verano en casa de sus tios todavia no han acabado y harry se encuentra mÃ¡s inquieto que nunca', 'images/harrypotterylaordendelfenix.jpg', 'felipe', 'DISPONIBLE', '2017-03-24 08:54:00', '2017-08-04 11:05:23'),
(14, 'maid sama tomo 1', '9781401236960', 5, 7, 'en la secundaria seika misaki es la presidenta', 'images/maidsamatomo1.jpg', 'felipe', 'DISPONIBLE', '2017-05-01 13:52:41', '2017-06-09 17:30:48'),
(15, 'maid sama tomo 2', '9781401236960', 5, 7, 'Hoy en caffe maid latte es dÃ­a de disfrazarse de hombre, ademÃ¡s la preparatoria seika tiene conflictos con la prestigiosa escuela miyabigaoka', 'images/maidsamatomo2.jpg', 'felipe', 'DISPONIBLE', '2017-05-01 18:40:51', '2017-08-04 11:50:11'),
(20, 'cdcdcdcddcc', '5555555555555', 17, 15, '', 'images/cdcdcdcddcc', 'felipe', 'DISPONIBLE', '2017-07-13 17:39:20', '2017-07-13 17:39:20');

-- --------------------------------------------------------

--
-- Table structure for table `productos`
--

CREATE TABLE `productos` (
  `codigo_producto` bigint(20) NOT NULL,
  `codigoBarras` bigint(20) NOT NULL,
  `nombre_producto` varchar(50) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `proveedor` bigint(20) NOT NULL,
  `stockActual` int(11) NOT NULL,
  `stockMin` int(11) NOT NULL,
  `stockMax` int(11) NOT NULL,
  `compra` decimal(10,2) NOT NULL,
  `venta` decimal(10,2) NOT NULL,
  `categoria` bigint(20) NOT NULL,
  `status` varchar(15) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `isLibro` int(11) NOT NULL DEFAULT '0',
  `usuario` varchar(15) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `fechaCreacion` datetime NOT NULL,
  `fechaModificacion` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `productos`
--

INSERT INTO `productos` (`codigo_producto`, `codigoBarras`, `nombre_producto`, `proveedor`, `stockActual`, `stockMin`, `stockMax`, `compra`, `venta`, `categoria`, `status`, `isLibro`, `usuario`, `fechaCreacion`, `fechaModificacion`) VALUES
(3, 1, 'huevo grande dinosuario', 3, 0, 1, 20, '15.00', '20.00', 3, 'AGOTADO', 0, '', '0000-00-00 00:00:00', '2017-01-17 06:49:00'),
(4, 2, 'huevo chico dinosaurio', 3, 0, 1, 10, '20.00', '25.50', 3, 'AGOTADO', 0, '', '0000-00-00 00:00:00', '2017-01-17 06:47:00'),
(5, 3, 'animales magicos', 5, 0, 1, 0, '30.00', '50.00', 0, 'AGOTADO', 0, '', '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(6, 4, 'bolsa emoji', 3, 0, 1, 30, '5.00', '10.00', 3, 'AGOTADO', 0, '', '0000-00-00 00:00:00', '2017-01-17 06:48:00'),
(9, 9786074009811, 'ochenta melodÃ­as de pasiÃ³n en amarillo', 1, 5, 1, 10, '185.00', '250.00', 1, 'DISPONIBLE', 2, 'felipe', '2016-09-02 11:00:00', '2017-07-31 15:30:33'),
(10, 5, 'el principito', 1, 2, 1, 4, '15.00', '25.00', 1, 'DISPONIBLE', 1, 'felipe', '2016-09-03 07:31:00', '2017-08-04 11:08:42'),
(11, 6, 'ochenta melodias de pasiÃ³n en azul', 1, 14, 1, 10, '100.00', '180.00', 1, 'SOBRESTOCK', 6, 'felipe', '2017-01-17 04:54:00', '2017-07-31 15:36:32'),
(12, 8, 'ochenta melodias de pasion en rojo', 1, 3, 1, 10, '130.00', '180.00', 1, 'DISPONIBLE', 7, 'felipe', '2017-01-17 04:55:00', '2017-08-25 23:58:45'),
(13, 7, 'las aventuras de tom sayer', 2, 0, 1, 5, '30.00', '60.00', 1, 'AGOTADO', 4, 'felipe', '2017-01-17 04:57:00', '2017-01-17 06:49:00'),
(14, 9788478887590, 'harry potter y la piedra filosofal', 4, 1, 1, 15, '100.00', '150.00', 1, 'DISPONIBLE', 8, 'felipe', '2017-03-08 05:48:00', '2017-08-04 11:07:30'),
(15, 9788478887613, 'harry potter y el prisionero de azkaban', 4, 3, 1, 10, '200.00', '300.00', 1, 'DISPONIBLE', 9, 'felipe', '2017-03-12 10:26:00', '2017-08-25 23:58:13'),
(16, 9788478887606, 'harry potter y la camara de los secretos', 4, 15, 1, 10, '150.00', '300.00', 1, 'SOBRESTOCK', 10, 'felipe', '2017-03-12 10:27:00', '2017-08-03 12:48:06'),
(17, 9788478887446, 'harry potter y la orden del fÃ©nix', 4, 15, 1, 10, '100.00', '157.00', 1, 'SOBRESTOCK', 12, 'felipe', '2017-04-01 01:29:00', '2017-08-04 11:05:23'),
(18, 9781401236960, 'maid sama tomo 2', 5, 15, 1, 10, '80.00', '99.00', 3, 'SOBRESTOCK', 15, 'felipe', '2017-04-09 12:05:00', '2017-08-04 11:50:11'),
(19, 9781401236960, 'maid sama tomo 1', 5, 3, 2, 5, '50.00', '85.00', 4, 'DISPONIBLE', 14, 'felipe', '2017-07-17 11:48:32', '2017-07-17 11:48:32');

-- --------------------------------------------------------

--
-- Table structure for table `proveedores`
--

CREATE TABLE `proveedores` (
  `codigo_proveedor` bigint(20) NOT NULL,
  `nombre_proveedor` varchar(50) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `contacto` varchar(50) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `apellido_paterno` varchar(30) NOT NULL,
  `apellido_materno` varchar(30) NOT NULL,
  `calle` varchar(30) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `num_ext` int(5) NOT NULL,
  `num_int` varchar(5) CHARACTER SET utf8 COLLATE utf8_spanish_ci DEFAULT NULL,
  `colonia` varchar(30) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `ciudad` varchar(30) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `estado` varchar(30) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `telefono` varchar(10) CHARACTER SET utf8 COLLATE utf8_spanish_ci DEFAULT NULL,
  `celular` varchar(10) CHARACTER SET utf8 COLLATE utf8_spanish_ci DEFAULT NULL,
  `email` varchar(40) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `web` varchar(50) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `usuario` varchar(15) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `status` varchar(10) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `fechaCreacion` datetime NOT NULL,
  `fechaModificacion` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `proveedores`
--

INSERT INTO `proveedores` (`codigo_proveedor`, `nombre_proveedor`, `contacto`, `apellido_paterno`, `apellido_materno`, `calle`, `num_ext`, `num_int`, `colonia`, `ciudad`, `estado`, `telefono`, `celular`, `email`, `web`, `usuario`, `status`, `fechaCreacion`, `fechaModificacion`) VALUES
(1, 'Grupo Editorial Tomo S.A de C.V', 'pamela silva', '', '', 'NicolÃ¡s San Juan', 1043, '5', 'del valle', 'benito juarez', 'CDMX', '5555750186', '6673031398', 'pamelas@grupotomo.com.mx', 'www.grupotomo.com.mx', '1', 'DISPONIBLE', '2016-08-22 10:50:00', '2017-01-16 05:57:00'),
(2, 'librerÃ­a mÃ©xico', 'luis', 'lopez', 'sanchez', 'sindicalismo', 4818, 'a', 'infonavit barrancos', 'culiacan', 'sinaloa', '6677106788', '6673031398', 'luis_21@libreriamexico.com', 'www.libreriamexico.com', 'felipe', 'DISPONIBLE', '2017-01-14 06:07:00', '2017-08-18 14:28:50'),
(3, 'materiales didacticos roggers', 'maria lopez', '', '', 'av obregon', 7852, '52', 'centro', 'tlaquepalque', 'guadalajara', '5555750186', '6674568266', 'malo@hotmail.com', '', 'felipe', 'DISPONIBLE', '2017-01-17 05:36:00', '2017-01-17 05:36:00'),
(4, 'editorial Oceano de Mexico SA de CV', 'lorena montes', '', '', 'eugenio sue', 5500, '0', 'miguel hidalgo', 'polanco chapultepec', 'CDMX', '5591785100', '', 'lorena.montes@editorialoceano.com', 'www.oceano.com.mx', 'felipe', 'DISPONIBLE', '2017-03-13 03:37:00', '2017-03-13 03:37:00'),
(5, 'grupo editorial panini', 'juan panini', '', '', 'benito juarez', 61, 'a', 'buenos aires', 'iztaalapa', 'cmdx', '5572154881', '6678251867', 'john.panini@paniigroup.com', 'www.comisc.panini.com', 'felipe', 'DISPONIBLE', '2017-04-09 12:05:00', '2017-04-09 12:05:00'),
(6, 'mas libros s A de C v', 'silvia Rodriguez', '', '', 'av siempre viva', 6666, '', 'las vegas', 'springfield', 'chico', '6781457828', '2758152433', 'silvi@maslibros.com', '', 'felipe', 'DISPONIBLE', '2017-05-02 16:53:03', '2017-05-02 16:53:03');

-- --------------------------------------------------------

--
-- Table structure for table `retiros`
--

CREATE TABLE `retiros` (
  `codigo_retiro` bigint(20) NOT NULL,
  `folio` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `fecha` datetime NOT NULL,
  `empleado` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  `cantidad` decimal(10,2) NOT NULL,
  `descripcion` text COLLATE utf8_spanish_ci NOT NULL,
  `status` varchar(15) COLLATE utf8_spanish_ci NOT NULL,
  `usuario` varchar(15) COLLATE utf8_spanish_ci NOT NULL,
  `fechaCreacion` datetime NOT NULL,
  `fechaModificacion` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Dumping data for table `retiros`
--

INSERT INTO `retiros` (`codigo_retiro`, `folio`, `fecha`, `empleado`, `cantidad`, `descripcion`, `status`, `usuario`, `fechaCreacion`, `fechaModificacion`) VALUES
(1, '20160900001', '2016-09-05 10:11:00', 'FELIPE MENDOZA MENDOZA', '150.00', 'cena empleados', 'EFECTUADO', 'felipe', '2016-09-05 10:11:00', '2016-09-05 10:11:00'),
(2, '20160900002', '2016-09-05 10:13:00', 'FELIPE MENDOZA MENDOZA', '350.00', 'Pago Empleado juan luis', 'EFECTUADO', 'felipe', '2016-09-05 10:13:00', '2016-09-07 08:27:00'),
(7, '20170212001', '2017-02-12 08:03:00', 'FELIPE ROBERTO LOPES MENDOZA', '500.00', 'pago agua', 'EFECTUADO', 'felipe', '2017-02-12 08:03:00', '2017-02-12 08:03:00'),
(8, '20170212002', '2017-02-12 07:38:00', 'FELIPE ROBERTO LOPES MENDOZA', '100.00', 'deayuno', 'EFECTUADO', 'felipe', '2017-02-12 07:38:00', '2017-02-12 07:38:00'),
(9, '20170212003', '2017-02-12 07:44:00', 'FELIPE ROBERTO LOPES MENDOZA', '150.00', 'pago renta', 'EFECTUADO', 'felipe', '2017-02-12 07:44:00', '2017-02-12 07:44:00'),
(10, '20170212004', '2017-02-12 07:48:00', 'FELIPE ROBERTO LOPES MENDOZA', '200.00', 'pago empleado juan', 'EFECTUADO', 'felipe', '2017-02-12 07:48:00', '2017-02-12 07:48:00'),
(11, '20170212005', '2017-02-12 08:44:00', 'FELIPE ROBERTO LOPES MENDOZA', '150.00', 'pago paqueteria', 'EFECTUADO', 'felipe', '2017-02-12 08:44:00', '2017-02-12 08:44:00'),
(12, '201703050006', '2017-03-05 12:48:00', 'FELIPE ROBERTO LOPES MENDOZA', '350.00', 'luz', 'EFECTUADO', 'felipe', '2017-03-05 12:48:00', '2017-03-05 12:48:00'),
(13, '201703160007', '2017-03-16 05:56:00', 'FELIPE MONZON MENDOZA', '200.00', 'cena de empleados', 'EFECTUADO', 'felipe', '2017-03-16 05:56:00', '2017-03-16 05:56:00'),
(14, '201703200008', '2017-03-20 06:36:00', 'FELIPE MONZON MENDOZA', '150.00', 'cena empleados', 'EFECTUADO', 'felipe', '2017-03-20 06:36:00', '2017-03-20 06:36:00'),
(15, '201703210009', '2017-03-21 03:55:00', 'FELIPE MONZON MENDOZA', '150.00', 'cena empleados', 'EFECTUADO', 'felipe', '2017-03-21 03:55:00', '2017-03-21 03:55:00'),
(16, '2017032200010', '2017-03-22 08:30:00', 'FELIPE MONZON MENDOZA', '150.00', 'cena', 'EFECTUADO', 'felipe', '2017-03-22 08:30:00', '2017-03-22 08:30:00'),
(17, '2017032400011', '2017-03-24 09:08:00', 'FELIPE MONZON MENDOZA', '450.00', 'pago empleado', 'EFECTUADO', 'felipe', '2017-03-24 09:08:00', '2017-03-24 09:08:00'),
(18, '2017040900012', '2017-04-09 08:55:00', 'FELIPE MONZON MENDOZA', '150.00', 'cena de empleados', 'EFECTUADO', 'felipe', '2017-04-09 08:55:00', '2017-04-09 08:55:00'),
(19, '2017052200001', '2017-05-22 11:04:12', 'FELIPE MONZON MENDOZA', '350.00', 'pago empleado juan', 'EFECTUADO', 'felipe', '2017-05-22 11:04:12', '2017-05-22 11:04:12'),
(20, '2017052200002', '2017-05-22 11:04:25', 'FELIPE MONZON MENDOZA', '200.00', 'comida empleados', 'EFECTUADO', 'felipe', '2017-05-22 11:04:25', '2017-05-22 11:04:25');

-- --------------------------------------------------------

--
-- Table structure for table `tipo_usuarios`
--

CREATE TABLE `tipo_usuarios` (
  `id_tipoUsuario` bigint(20) NOT NULL,
  `descripcion` varchar(15) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tipo_usuarios`
--

INSERT INTO `tipo_usuarios` (`id_tipoUsuario`, `descripcion`) VALUES
(1, 'ADMINISTRADOR'),
(2, 'CAJERO'),
(3, 'VENDEDOR');

-- --------------------------------------------------------

--
-- Table structure for table `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` bigint(20) NOT NULL,
  `nombre_usuario` varchar(10) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `password` varchar(100) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `tipo_usuario` bigint(20) NOT NULL,
  `matricula_empleado` bigint(20) NOT NULL,
  `status` varchar(15) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `fechaCreacion` datetime NOT NULL,
  `fechaModificacion` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `nombre_usuario`, `password`, `tipo_usuario`, `matricula_empleado`, `status`, `fechaCreacion`, `fechaModificacion`) VALUES
(2, 'felipe', '$2y$10$BK2uIwK0gXnwGYVE8K37IuQwJoOjIY1uUKbrYLfPVfldtBmL3.d8S', 1, 2, 'DISPONIBLE', '2016-08-25 12:23:00', '2016-09-18 10:08:00'),
(3, 'cajero1', '$2y$10$oKmmSGZIBV/9WWDuN/R9/ehIN7igos1wdbAbupuUCYHGnAxWuLPd6', 2, 6, 'DISPONIBLE', '2017-01-29 07:49:00', '2017-01-29 07:49:00'),
(4, 'vendedor1', '$2y$10$BK2uIwK0gXnwGYVE8K37IuQwJoOjIY1uUKbrYLfPVfldtBmL3.d8S', 3, 4, 'DISPONIBLE', '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(5, 'luigis', '$2y$10$fJ0p5n5qgpbPdDIiabYAau98gmfHSw5U2ONSsqkRPp8h7bZRt79BO', 2, 1, 'DISPONIBLE', '2017-03-26 01:19:00', '2017-03-26 01:19:00'),
(6, 'paola123', '$2y$10$Rp.SnurWRy6Rcyw4TEm7bOvZh.v3LryH8dZZE9SCu57OBJBMdvVq2', 2, 7, 'DISPONIBLE', '2017-05-15 16:21:05', '2017-05-15 16:21:05');

-- --------------------------------------------------------

--
-- Table structure for table `ventas`
--

CREATE TABLE `ventas` (
  `folio` bigint(20) NOT NULL,
  `fecha_venta` datetime NOT NULL,
  `empleado` bigint(20) NOT NULL,
  `cliente` bigint(20) NOT NULL,
  `total` decimal(10,2) NOT NULL,
  `isTarjeta` int(11) NOT NULL,
  `folioTarjeta` int(11) DEFAULT NULL,
  `status` varchar(15) CHARACTER SET utf8 COLLATE utf8_spanish2_ci NOT NULL,
  `usuario` varchar(15) CHARACTER SET utf8 COLLATE utf8_spanish2_ci NOT NULL,
  `fechaCreacion` datetime NOT NULL,
  `fechaModificacion` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ventas`
--

INSERT INTO `ventas` (`folio`, `fecha_venta`, `empleado`, `cliente`, `total`, `isTarjeta`, `folioTarjeta`, `status`, `usuario`, `fechaCreacion`, `fechaModificacion`) VALUES
(2015070001, '2015-07-16 00:00:00', 1, 1, '702.00', 0, 0, 'PAGADA', '', '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(2015070002, '2015-07-16 00:00:00', 1, 1, '702.00', 0, 0, 'CANCELADA', '', '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(2015070003, '2015-07-16 00:00:00', 2, 1, '600.00', 0, 0, 'PAGADA', '', '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(2015070007, '2015-07-22 00:00:00', 1, 1, '300.00', 0, 0, 'CANCELADA', '', '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(2015070008, '2015-07-30 00:00:00', 1, 5, '250.00', 0, 0, 'PAGADA', '', '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(2015070009, '2015-07-30 00:00:00', 1, 1, '300.00', 0, 0, 'PAGADA', '', '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(20150700010, '2015-07-30 00:00:00', 2, 1, '350.00', 0, 0, 'PAGADA', '', '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(20150800011, '2015-08-03 00:00:00', 1, 1, '150.00', 0, 0, 'PAGADA', '', '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(20150800012, '2015-08-05 00:00:00', 1, 1, '50.00', 0, 0, 'PAGADA', '', '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(20150800013, '2015-08-05 00:00:00', 1, 1, '702.00', 0, 0, 'PAGADA', '', '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(20150800014, '2015-08-06 00:00:00', 1, 1, '351.00', 0, 0, 'PAGADA', '', '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(20150800015, '2015-08-07 00:00:00', 1, 1, '500.00', 0, 0, 'PAGADA', '', '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(20150800016, '2015-08-07 00:00:00', 1, 1, '0.00', 0, 0, 'CANCELADA', '', '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(20150800017, '2015-08-07 00:00:00', 1, 1, '0.00', 0, 0, 'CANCELADA', '', '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(20150800018, '2015-08-07 00:00:00', 1, 1, '0.00', 0, 0, 'CANCELADA', '', '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(20150800019, '2015-08-07 00:00:00', 1, 1, '0.00', 0, 0, 'CANCELADA', '', '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(20150800020, '2015-08-07 00:00:00', 1, 1, '0.00', 0, 0, 'CANCELADA', '', '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(20150800021, '2015-08-07 00:00:00', 1, 1, '0.00', 0, 0, 'CANCELADA', '', '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(20150800022, '2015-08-07 00:00:00', 1, 1, '500.00', 0, 0, 'PAGADA', '', '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(20150800023, '2015-08-09 00:00:00', 1, 1, '200.00', 0, 0, 'PAGADA', '', '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(20151000024, '2015-10-29 00:00:00', 1, 1, '400.00', 0, 0, 'PAGADA', '', '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(20151100025, '2015-11-25 00:00:00', 1, 1, '0.00', 0, 0, 'PAGADA', '', '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(201703060001, '2017-03-06 05:19:00', 2, 0, '91.00', 0, 0, 'PAGADA', 'felipe', '2017-03-06 05:19:00', '2017-03-06 05:19:00'),
(201703060002, '2017-03-06 05:22:00', 2, 0, '20.00', 1, 2017054285, 'PAGADA', 'felipe', '2017-03-06 05:22:00', '2017-03-06 05:22:00'),
(201703060003, '2017-03-06 05:23:00', 2, 0, '480.00', 0, 0, 'PAGADA', 'felipe', '2017-03-06 05:23:00', '2017-03-06 05:23:00'),
(201703060004, '2017-03-06 05:25:00', 2, 0, '76.00', 0, 0, 'PAGADA', 'felipe', '2017-03-06 05:25:00', '2017-03-06 05:25:00'),
(201703060005, '2017-03-06 05:29:00', 2, 0, '40.00', 0, 0, 'PAGADA', 'felipe', '2017-03-06 05:29:00', '2017-03-06 05:29:00'),
(201703060006, '2017-03-06 05:30:00', 2, 0, '51.00', 0, 0, 'PAGADA', 'felipe', '2017-03-06 05:30:00', '2017-03-06 05:30:00'),
(201703060007, '2017-03-06 05:32:00', 2, 0, '51.00', 0, 0, 'PAGADA', 'felipe', '2017-03-06 05:32:00', '2017-03-06 05:32:00'),
(201703060008, '2017-03-06 05:35:00', 2, 0, '51.00', 0, 0, 'PAGADA', 'felipe', '2017-03-06 05:35:00', '2017-03-06 05:35:00'),
(201703070009, '2017-03-07 04:08:00', 2, 0, '76.00', 0, 0, 'PAGADA', 'felipe', '2017-03-07 04:08:00', '2017-03-07 04:08:00'),
(2017030700010, '2017-03-07 04:41:00', 2, 0, '51.00', 0, 0, 'PAGADA', 'felipe', '2017-03-07 04:41:00', '2017-03-07 04:41:00'),
(2017031000011, '2017-03-10 03:40:00', 2, 0, '590.00', 0, 0, 'PAGADA', 'felipe', '2017-03-10 03:40:00', '2017-03-11 09:05:00'),
(2017031000012, '2017-03-10 03:40:00', 2, 0, '590.00', 0, 0, 'PAGADA', 'felipe', '2017-03-10 03:40:00', '2017-03-10 03:40:00'),
(2017031000013, '2017-03-10 04:34:00', 2, 0, '300.00', 0, 0, 'PAGADA', 'felipe', '2017-03-10 04:34:00', '2017-03-10 04:34:00'),
(2017031000014, '2017-03-10 04:35:00', 2, 0, '300.00', 0, 0, 'PAGADA', 'felipe', '2017-03-10 04:35:00', '2017-03-10 04:35:00'),
(2017031000015, '2017-03-10 04:37:00', 2, 0, '150.00', 0, 0, 'PAGADA', 'felipe', '2017-03-10 04:37:00', '2017-03-10 04:37:00'),
(2017031000016, '2017-03-10 05:05:00', 2, 0, '440.00', 0, 0, 'PAGADA', 'felipe', '2017-03-10 05:05:00', '2017-03-10 05:05:00'),
(2017031000017, '2017-03-10 05:08:00', 2, 0, '440.00', 0, 0, 'PAGADA', 'felipe', '2017-03-10 05:08:00', '2017-03-10 05:08:00'),
(2017031000018, '2017-03-10 05:10:00', 2, 0, '440.00', 0, 0, 'PAGADA', 'felipe', '2017-03-10 05:10:00', '2017-03-10 05:10:00'),
(2017031200019, '2017-03-12 10:31:00', 2, 0, '1500.00', 1, 2147483647, 'PAGADA', 'felipe', '2017-03-12 10:31:00', '2017-03-12 10:31:00'),
(2017031600020, '2017-03-16 04:13:00', 2, 0, '880.00', 0, 0, 'PAGADA', 'felipe', '2017-03-16 04:13:00', '2017-03-16 04:13:00'),
(2017032000021, '2017-03-20 06:48:00', 2, 0, '440.00', 0, 0, 'PAGADA', 'felipe', '2017-03-20 06:48:00', '2017-03-20 06:48:00'),
(2017032000022, '2017-03-20 07:43:00', 2, 0, '440.00', 0, 0, 'PAGADA', 'felipe', '2017-03-20 07:43:00', '2017-03-20 07:43:00'),
(2017032100023, '2017-03-21 03:54:00', 2, 0, '440.00', 0, 0, 'PAGADA', 'felipe', '2017-03-21 03:54:00', '2017-03-21 03:54:00'),
(2017032200024, '2017-03-22 08:30:00', 2, 0, '150.00', 0, 0, 'PAGADA', 'felipe', '2017-03-22 08:30:00', '2017-03-22 08:30:00'),
(2017032400025, '2017-03-24 09:07:00', 2, 0, '220.00', 0, 0, 'PAGADA', 'felipe', '2017-03-24 09:07:00', '2017-03-24 09:07:00'),
(2017032900026, '2017-03-29 08:04:00', 2, 0, '1050.00', 0, 0, 'PAGADA', 'felipe', '2017-03-29 08:04:00', '2017-03-29 08:04:00'),
(2017082500001, '2017-08-25 23:58:07', 2, 1, '960.00', 1, 0, 'PAGADA', 'felipe', '2017-08-25 23:58:07', '2017-08-25 23:58:07');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `autores`
--
ALTER TABLE `autores`
  ADD PRIMARY KEY (`codigo_autor`),
  ADD KEY `usuario` (`usuario`);

--
-- Indexes for table `categorias_producto`
--
ALTER TABLE `categorias_producto`
  ADD PRIMARY KEY (`codigo_catpro`);

--
-- Indexes for table `clientes`
--
ALTER TABLE `clientes`
  ADD PRIMARY KEY (`matricula`);

--
-- Indexes for table `cortecaja`
--
ALTER TABLE `cortecaja`
  ADD PRIMARY KEY (`folioCorte`);

--
-- Indexes for table `detalle_venta`
--
ALTER TABLE `detalle_venta`
  ADD PRIMARY KEY (`folio`,`clave_producto`);

--
-- Indexes for table `deudas`
--
ALTER TABLE `deudas`
  ADD PRIMARY KEY (`clave_deuda`);

--
-- Indexes for table `editoriales`
--
ALTER TABLE `editoriales`
  ADD PRIMARY KEY (`codigo_editorial`),
  ADD KEY `usuario` (`usuario`);

--
-- Indexes for table `empleados`
--
ALTER TABLE `empleados`
  ADD PRIMARY KEY (`matricula`);

--
-- Indexes for table `folios`
--
ALTER TABLE `folios`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `generos`
--
ALTER TABLE `generos`
  ADD PRIMARY KEY (`codigo_genero`),
  ADD KEY `usuario` (`usuario`);

--
-- Indexes for table `libros`
--
ALTER TABLE `libros`
  ADD PRIMARY KEY (`codigo_libro`),
  ADD KEY `usuario` (`usuario`),
  ADD KEY `editorial` (`editorial`),
  ADD KEY `autor` (`autor`);

--
-- Indexes for table `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`codigo_producto`),
  ADD KEY `proveedor` (`proveedor`),
  ADD KEY `categoria` (`categoria`);

--
-- Indexes for table `proveedores`
--
ALTER TABLE `proveedores`
  ADD PRIMARY KEY (`codigo_proveedor`),
  ADD KEY `usuario` (`usuario`);

--
-- Indexes for table `retiros`
--
ALTER TABLE `retiros`
  ADD PRIMARY KEY (`codigo_retiro`);

--
-- Indexes for table `tipo_usuarios`
--
ALTER TABLE `tipo_usuarios`
  ADD PRIMARY KEY (`id_tipoUsuario`);

--
-- Indexes for table `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD KEY `tipo_usuario` (`tipo_usuario`);

--
-- Indexes for table `ventas`
--
ALTER TABLE `ventas`
  ADD PRIMARY KEY (`folio`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `autores`
--
ALTER TABLE `autores`
  MODIFY `codigo_autor` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;
--
-- AUTO_INCREMENT for table `categorias_producto`
--
ALTER TABLE `categorias_producto`
  MODIFY `codigo_catpro` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT for table `clientes`
--
ALTER TABLE `clientes`
  MODIFY `matricula` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;
--
-- AUTO_INCREMENT for table `deudas`
--
ALTER TABLE `deudas`
  MODIFY `clave_deuda` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT for table `editoriales`
--
ALTER TABLE `editoriales`
  MODIFY `codigo_editorial` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;
--
-- AUTO_INCREMENT for table `empleados`
--
ALTER TABLE `empleados`
  MODIFY `matricula` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;
--
-- AUTO_INCREMENT for table `folios`
--
ALTER TABLE `folios`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;
--
-- AUTO_INCREMENT for table `generos`
--
ALTER TABLE `generos`
  MODIFY `codigo_genero` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT for table `libros`
--
ALTER TABLE `libros`
  MODIFY `codigo_libro` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;
--
-- AUTO_INCREMENT for table `productos`
--
ALTER TABLE `productos`
  MODIFY `codigo_producto` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;
--
-- AUTO_INCREMENT for table `proveedores`
--
ALTER TABLE `proveedores`
  MODIFY `codigo_proveedor` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT for table `retiros`
--
ALTER TABLE `retiros`
  MODIFY `codigo_retiro` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;
--
-- AUTO_INCREMENT for table `tipo_usuarios`
--
ALTER TABLE `tipo_usuarios`
  MODIFY `id_tipoUsuario` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;
--
-- Constraints for dumped tables
--

--
-- Constraints for table `libros`
--
ALTER TABLE `libros`
  ADD CONSTRAINT `libro_autor` FOREIGN KEY (`autor`) REFERENCES `autores` (`codigo_autor`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `libro_editorial` FOREIGN KEY (`editorial`) REFERENCES `editoriales` (`codigo_editorial`) ON DELETE CASCADE ON UPDATE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
