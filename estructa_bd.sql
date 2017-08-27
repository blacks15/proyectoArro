-- phpMyAdmin SQL Dump
-- version 4.5.1
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Aug 26, 2017 at 07:22 PM
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

-- --------------------------------------------------------

--
-- Table structure for table `categorias_producto`
--

CREATE TABLE `categorias_producto` (
  `codigo_catpro` bigint(20) NOT NULL,
  `nombre_categoria` varchar(20) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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

-- --------------------------------------------------------

--
-- Table structure for table `tipo_usuarios`
--

CREATE TABLE `tipo_usuarios` (
  `id_tipoUsuario` bigint(20) NOT NULL,
  `descripcion` varchar(15) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
