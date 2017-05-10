-- phpMyAdmin SQL Dump
-- version 4.5.1
-- http://www.phpmyadmin.net
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 09-05-2017 a las 21:48:23
-- Versión del servidor: 10.1.19-MariaDB
-- Versión de PHP: 5.6.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `ventas`
--

DELIMITER $$
--
-- Procedimientos
--
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `spConsultaClientes` (IN `pCodigo` BIGINT, IN `pInicio` INT, IN `pTamanio` INT, OUT `CodRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `numFilas` INT)  BEGIN
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
		SET CodRetorno = '004';
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
				SET CodRetorno = '000'; 
			ELSE
				SET CodRetorno = '001'; 
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
				SET CodRetorno = '000'; 
			ELSE
				SET CodRetorno = '001'; 
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `spConsultaEmpleados` (IN `pCodigo` BIGINT, IN `pInicio` INT, IN `pTamanio` INT, OUT `CodRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `numFilas` INT)  BEGIN
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
				SET CodRetorno = '000'; 
			ELSE
				SET CodRetorno = '001'; 
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
				SET CodRetorno = '000'; 
			ELSE
				SET CodRetorno = '001'; 
				SET msg = 'No Hay Datos Para Mostrar';
			END IF;
		END IF;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spConsultaLibros` (IN `pCodigo` BIGINT, IN `pInicio` INT, IN `pTamanio` INT, IN `pBusqueda` INT, OUT `CodRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `numFilas` INT)  BEGIN
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

					SELECT codigo_libro,nombre_libro,isbn,autor,editorial,descripcion,l.status,e.nombre_editorial,a.nombre_autor
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

						SELECT codigo_libro,nombre_libro,isbn,autor,editorial,descripcion,l.status,e.nombre_editorial,a.nombre_autor
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
					
						SELECT codigo_libro,nombre_libro,isbn,autor,editorial,descripcion,l.status,e.nombre_editorial,a.nombre_autor
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `spConsultaProductos` (IN `pCodigo` BIGINT, IN `pInicio` INT, IN `pTamanio` INT, IN `pBusqueda` INT, OUT `CodRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `numFilas` INT)  BEGIN
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
		IF (pBusqueda = 1) THEN			
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
		END IF;	
	END IF;	
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spConsultaProveedores` (IN `pCodigo` BIGINT, IN `pInicio` INT, IN `pTamanio` INT, OUT `CodRetorno` CHAR(3), OUT `msg` VARCHAR(100), OUT `numFilas` INT)  BEGIN
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
		SET CodRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE		
		IF (pCodigo = 0 ) THEN
			 IF EXISTS (SELECT * FROM proveedores WHERE status = 'DISPONIBLE') THEN
			 	SELECT COUNT(*) INTO numFilas FROM proveedores WHERE status = 'DISPONIBLE';

				SELECT codigo_proveedor,nombre_proveedor,contacto,calle,num_ext,num_int,colonia,ciudad,estado,
					telefono,celular,email,web,usuario,status,CONCAT(calle,' ',num_ext,' ',num_int) AS direccion
				FROM proveedores
				WHERE status = 'DISPONIBLE' 
				ORDER BY nombre_proveedor ASC
				LIMIT pInicio, pTamanio;
				SET msg = 'SP Ejecutado Correctamente';
				SET CodRetorno = '000'; 
			ELSE
				SET CodRetorno = '001'; 
				SET msg = 'No Hay Datos Para Mostrar';
			END IF;
		ELSE
			IF EXISTS (SELECT * FROM proveedores WHERE status = 'DISPONIBLE' AND codigo_proveedor = pCodigo) THEN
				SELECT COUNT(*) INTO numFilas FROM proveedores WHERE status = 'DISPONIBLE' AND codigo_proveedor = pCodigo;

				SELECT codigo_proveedor,nombre_proveedor,contacto,calle,num_ext,num_int,colonia,ciudad,estado,
					telefono,celular,email,web,usuario,status,CONCAT(calle,' ',num_ext,' ',num_int) AS direccion
				FROM proveedores
				WHERE status = 'DISPONIBLE' AND codigo_proveedor = pCodigo
				ORDER BY nombre_proveedor ASC;
				SET msg = 'SP Ejecutado Correctamente';
				SET CodRetorno = '000'; 
			ELSE
				SET CodRetorno = '001'; 
				SET msg = 'No Hay Datos Para Mostrar';
			END IF;
		END IF;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spInsUpdAutor` (IN `pCodigo` BIGINT, IN `pNombreAutor` VARCHAR(50), IN `pUsuario` VARCHAR(15), IN `pStatus` VARCHAR(15), OUT `CodRetorno` CHAR(3), OUT `msg` VARCHAR(100))  BEGIN
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
			
	IF (COALESCE(pCodigo,'') = '' && COALESCE(pNombreAutor,'') = '' && COALESCE(pUsuario,'') = ''  && COALESCE(pStatus,'') = '' ) THEN
		SET msg = 'Parametros Vacios';
	ELSE
		IF (pCodigo != 0 || COALESCE(pCodigo,'') = '') THEN
			IF EXISTS(SELECT * FROM autores WHERE codigo_autor = pCodigo) THEN
				IF NOT EXISTS(SELECT * FROM autores WHERE codigo_autor != pCodigo AND nombre_autor = CONVERT(pNombreAutor USING utf8) COLLATE utf8_general_ci ) THEN
					START TRANSACTION;
						UPDATE autores SET nombre_autor = pNombreAutor,fechaModificacion = NOW() WHERE codigo_autor = pCodigo;
						SET CodRetorno = '000';
						SET msg = 'Autor Actualizado con Exito';
					COMMIT; 
				ELSE 
					SET CodRetorno = '001';
					SET msg = 'El Nombre del Autor ya fue Registrado';
					ROLLBACK;
				END IF;
			ELSE
				SET CodRetorno = '001';
				SET msg = 'El Autor no Éxiste';
				ROLLBACK;
			END IF;
		ELSE 
			IF NOT EXISTS(SELECT * FROM autores WHERE nombre_autor = pNombreAutor) THEN
				START TRANSACTION;
					INSERT INTO autores (nombre_autor,usuario,status,fechaCreacion,fechaModificacion)
					VALUES (pNombreAutor, pUsuario, pStatus,NOW(), NOW() );
					SET CodRetorno = '000';
					SET msg = 'Autor Guardado con Exito';
				COMMIT;
			ELSE
				SET CodRetorno = '001';
				SET msg = 'El Autor ya Éxiste';
				ROLLBACK;
			END IF; 
		END IF; 
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spInsUpdCliente` (IN `pCodigo` BIGINT, IN `pRFC` CHAR(13), IN `pEmpresa` VARCHAR(30), IN `pNombreContacto` VARCHAR(20), IN `pAPaterno` VARCHAR(30), IN `pAMaterno` VARCHAR(30), IN `pCalle` VARCHAR(30), IN `pNumExt` INT, IN `pNumInt` VARCHAR(5), IN `pColonia` VARCHAR(30), IN `pCiudad` VARCHAR(30), IN `pEstado` VARCHAR(30), IN `pTelefono` VARCHAR(10), IN `pCelular` VARCHAR(10), IN `pEmail` VARCHAR(30), IN `pStatus` VARCHAR(10), IN `pUsuario` VARCHAR(15), OUT `CodRetorno` CHAR(3), OUT `msg` VARCHAR(100))  BEGIN
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
		IF EXISTS(SELECT * FROM clientes WHERE matricula = pCodigo) THEN
			IF NOT EXISTS(SELECT * FROM clientes WHERE matricula != pCodigo AND empresa = CONVERT(pEmpresa USING utf8) COLLATE utf8_general_ci ) THEN
				IF NOT EXISTS(SELECT * FROM clientes WHERE matricula != pCodigo AND  rfc = pRFC) THEN
					START TRANSACTION;
						UPDATE clientes SET rfc = pRFC, empresa = pEmpresa, nombre_contacto = pNombreContacto, 
							apellido_paterno = pAPaterno, apellido_materno = pAMaterno, calle = pCalle, numExt = pNumExt,
							numInt = pNumInt, colonia = pColonia, ciudad = pCiudad, estado = pEstado, telefono = pTelefono,
							celular = pCelular, email = pEmail, fechaModificacion = NOW()
						WHERE matricula = pCodigo;
						SET CodRetorno = '000';
						SET msg = 'Cliente Actualizado con Exito';
					COMMIT; 
				ELSE
					SET CodRetorno = '001';
					SET msg = 'El RFC del Cliente ya fue Registrado';
					ROLLBACK;
				END IF;
			ELSE
				SET CodRetorno = '001';
				SET msg = 'El Nombre del Cliente ya fue Registrado';
				ROLLBACK;
			END IF;
		ELSE
			SET CodRetorno = '001';
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
					SET CodRetorno = '000';
					SET msg = 'Cliente Guardado con Exito';
				COMMIT;
			ELSE
				SET CodRetorno = '001';
				SET msg = 'El RFC del Cliente ya fue Registrado';
				ROLLBACK;
			END IF;
		ELSE
			SET CodRetorno = '001';
			SET msg = 'El Client ya fue Registrado';
			ROLLBACK;
		END IF; 
	END IF; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spInsUpdEditorial` (IN `pCodigo` BIGINT, IN `pNombreEditorial` VARCHAR(50) COLLATE utf8_spanish2_ci, IN `pUsuario` VARCHAR(15), IN `pStatus` VARCHAR(15), OUT `CodRetorno` CHAR(3), OUT `msg` VARCHAR(100))  BEGIN
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
			
	IF (COALESCE(pCodigo,'') = '' && COALESCE(pNombreEditorial,'') = '' && COALESCE(pUsuario,'') = ''  && COALESCE(pStatus,'') = '' ) THEN
		SET msg = 'Parametros Vacios';
	ELSE
		IF (pCodigo != 0 || COALESCE(pCodigo,'') = '') THEN
			IF EXISTS(SELECT * FROM editoriales WHERE codigo_editorial = pCodigo) THEN
				IF NOT EXISTS(SELECT * FROM editoriales WHERE codigo_editorial != pCodigo AND nombre_editorial = CONVERT(pNombreEditorial USING utf8) COLLATE utf8_general_ci ) THEN
					START TRANSACTION;
						UPDATE editoriales SET nombre_editorial = pNombreEditorial,fechaModificacion = NOW() WHERE codigo_editorial = pCodigo;
						SET CodRetorno = '000';
						SET msg = 'Editorial Actualizado con Exito';
					COMMIT; 
				ELSE
					SET CodRetorno = '001';
					SET msg = 'El Nombre de la Editorial ya fue Registrado';
					ROLLBACK;
				END IF;
			ELSE
				SET CodRetorno = '001';
				SET msg = 'La Editorial no Éxiste';
			END IF;
		ELSE 
			IF NOT EXISTS(SELECT * FROM editoriales WHERE nombre_editorial = pNombreEditorial) THEN
				START TRANSACTION;
					INSERT INTO editoriales(nombre_editorial,usuario,status,fechaCreacion,fechaModificacion)
					VALUES (pNombreEditorial, pUsuario, pStatus,NOW(), NOW() );
					SET CodRetorno = '000';
					SET msg = 'Editorial Guardado con Exito';
				COMMIT;
			ELSE
				SET CodRetorno = '001';
				SET msg = 'La Editorial ya Éxiste';
				ROLLBACK;
			END IF; 
		END IF; 
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spInsUpdEmpleado` (IN `pCodigo` BIGINT, IN `pNombreEmpleado` VARCHAR(20), IN `pAPaterno` VARCHAR(30), IN `pAMaterno` VARCHAR(30), IN `pCalle` VARCHAR(30), IN `pNumExt` INT, IN `pNumInt` VARCHAR(5), IN `pColonia` VARCHAR(30), IN `pCiudad` VARCHAR(30), IN `pEstado` VARCHAR(30), IN `pTelefono` VARCHAR(10), IN `pCelular` VARCHAR(10), IN `pSueldo` DECIMAL, IN `pPuesto` VARCHAR(30), IN `pStatus` VARCHAR(10), IN `pISUsu` INT, IN `pUsuario` VARCHAR(15), OUT `CodRetorno` CHAR(3), OUT `msg` VARCHAR(100))  BEGIN
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
		IF EXISTS(SELECT * FROM empleados WHERE matricula = pCodigo) THEN
			IF NOT EXISTS(SELECT * FROM empleados WHERE matricula != pCodigo AND nombre_empleado = CONVERT(pNombreEmpleado USING utf8) COLLATE utf8_general_ci ) THEN
				START TRANSACTION;
					UPDATE empleados SET nombre_empleado = pNombreEmpleado, apellido_paterno = pAMaterno,apellido_materno = pAMaterno,
						calle = pCalle,	numExt = pNumExt,numInt = numInt,colonia = pColonia, ciudad = pCiudad, estado = pEstado, 
						telefono = pTelefono, celular = pCelular, sueldo = pSueldo, puesto = pPuesto,fechaModificacion = NOW()
					WHERE matricula = pCodigo;
					SET CodRetorno = '000';
					SET msg = 'Empleado Actualizado con Exito';
				COMMIT; 
			ELSE
				SET CodRetorno = '001';
				SET msg = 'El Nombre del Empleado ya fue Registrado';
				ROLLBACK;
			END IF;
		ELSE
			SET CodRetorno = '001';
			SET msg = 'El Empleado no Existe';
		END IF;
	ELSE 
		IF NOT EXISTS(SELECT * FROM empleados WHERE nombre_empleado = CONVERT(pNombreEmpleado USING utf8) COLLATE utf8_general_ci ) THEN
			START TRANSACTION;
				INSERT INTO empleados(nombre_empleado,apellido_paterno,apellido_materno,calle,numExt,numInt,colonia,ciudad,estado,
					telefono,celular,sueldo,puesto,status,isUsu,usuario,fechaCreacion,fechaModificacion)
				VALUES (pNombreEmpleado, pAPaterno, pAMaterno, pCalle, pNumExt, pNumInt, pColonia, pCiudad, pEstado, pTelefono,
					pCelular, pSueldo, pPuesto, pStatus, pISUsu, pUsuario,NOW(), NOW() );
				SET CodRetorno = '000';
				SET msg = 'Empleado Guardado con Exito';
			COMMIT;
		ELSE
			SET CodRetorno = '001';
			SET msg = 'El Empleado ya Existe';
			ROLLBACK;
		END IF; 
	END IF; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spInsUpdLibro` (IN `pCodigo` BIGINT, IN `pNombreLibro` VARCHAR(50), IN `pISBN` VARCHAR(13), IN `pAutor` BIGINT, IN `pEditorial` BIGINT, IN `pDescripcion` VARCHAR(500), IN `pUsuario` VARCHAR(15), IN `pStatus` VARCHAR(10), OUT `CodRetorno` CHAR(3), OUT `msg` VARCHAR(100))  BEGIN
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
		IF EXISTS(SELECT * FROM libros WHERE codigo_libro = pCodigo) THEN
			IF NOT EXISTS(SELECT * FROM libros WHERE codigo_libro != pCodigo AND nombre_libro = CONVERT(pNombreLibro USING utf8) COLLATE utf8_general_ci ) THEN
				START TRANSACTION;
					UPDATE libros SET nombre_libro = pNombreLibro,isbn = pISBN,autor = pAutor,editorial = pEditorial,descripcion = pDescripcion,fechaModificacion = NOW()
					WHERE codigo_libro = pCodigo;
					SET CodRetorno = '000';
					SET msg = 'Libro Actualizado con Exito';
				COMMIT; 
			ELSE
				SET CodRetorno = '001';
				SET msg = 'El Nombre del Libro ya fue Registrado';
				ROLLBACK;
			END IF;
		ELSE
			SET CodRetorno = '001';
			SET msg = 'El Libro no Éxiste';
		END IF;
	ELSE 
		IF NOT EXISTS(SELECT * FROM libros WHERE nombre_libro = CONVERT(pNombreLibro USING utf8) COLLATE utf8_general_ci ) THEN
			START TRANSACTION;
				INSERT INTO libros(nombre_libro,isbn,autor,editorial,descripcion,usuario,status,fechaCreacion,fechaModificacion)
				VALUES (pNombreLibro, pISBN, pAutor, pEditorial, pDescripcion, pUsuario, pStatus,NOW(), NOW() );
				SET CodRetorno = '000';
				SET msg = 'Libro Guardado con Exito';
			COMMIT;
		ELSE
			SET CodRetorno = '001';
			SET msg = 'El Libro ya Éxiste';
			ROLLBACK;
		END IF; 
	END IF; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spInsUpdProducto` (IN `pCodigo` BIGINT, IN `pNombreProducto` VARCHAR(50), IN `pCodigoBarras` BIGINT, IN `pProveedor` BIGINT, IN `pStActual` INT, IN `pStMin` INT, IN `pStMax` INT, IN `pCompra` DECIMAL, IN `pVenta` DECIMAL, IN `pCategoria` BIGINT, IN `pStatus` VARCHAR(15), IN `pUsuario` VARCHAR(15), OUT `CodRetorno` CHAR(3), OUT `msg` VARCHAR(100))  BEGIN
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `spInsUpdProveedor` (IN `pCodigo` BIGINT, IN `pNombreProveedor` VARCHAR(50), IN `pContacto` VARCHAR(50), IN `pCalle` VARCHAR(30), IN `pNumExt` INT, IN `pNumInt` VARCHAR(5), IN `pColonia` VARCHAR(30), IN `pCiudad` VARCHAR(30), IN `pEstado` VARCHAR(30), IN `pTelefono` VARCHAR(10), IN `pCelular` VARCHAR(10), IN `pEmail` VARCHAR(40), IN `pWeb` VARCHAR(50), IN `pUsuario` VARCHAR(15), IN `pStatus` VARCHAR(10), OUT `CodRetorno` CHAR(3), OUT `msg` VARCHAR(100))  BEGIN
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
		IF EXISTS(SELECT * FROM proveedores WHERE codigo_proveedor = pCodigo) THEN
			IF NOT EXISTS(SELECT * FROM proveedores WHERE codigo_proveedor != pCodigo AND nombre_proveedor = CONVERT(pNombreProveedor USING utf8) COLLATE utf8_general_ci ) THEN
				START TRANSACTION;
					UPDATE proveedores SET nombre_proveedor = pNombreProveedor, contacto = pContacto, calle = pCalle,
						num_ext = pNumExt, num_int = pNumInt, colonia = pColonia, ciudad = pCiudad, estado = pEstado,
						telefono = pTelefono, celular = pCelular, email = pEmail, web = pWeb, fechaModificacion = NOW()
					WHERE codigo_proveedor = pCodigo;
					SET CodRetorno = '000';
					SET msg = 'Proveedor Actualizado con Exito';
				COMMIT; 
			ELSE
				SET CodRetorno = '001';
				SET msg = 'El Nombre del Proveedor ya fue Registrado';
				ROLLBACK;
			END IF;
		ELSE
			SET CodRetorno = '001';
			SET msg = 'El Proveedor no Éxiste';
		END IF;
	ELSE 
		IF NOT EXISTS(SELECT * FROM proveedores WHERE nombre_proveedor = CONVERT(pNombreProveedor USING utf8) COLLATE utf8_general_ci ) THEN
			START TRANSACTION;
				INSERT INTO proveedores(nombre_proveedor,contacto,calle,num_ext,num_int,colonia,
					ciudad,estado,telefono,celular,email,web,usuario,status,fechaCreacion,fechaModificacion)
				VALUES (pNombreProveedor, pContacto, pCalle, pNumExt, pNumInt, pColonia, pCiudad, pEstado, pTelefono,
					pCelular, pEmail, pWeb, pUsuario, pStatus,NOW(), NOW() );
				SET CodRetorno = '000';
				SET msg = 'Proveedor Guardado con Exito';
			COMMIT;
		ELSE
			SET CodRetorno = '001';
			SET msg = 'El Proveedor ya Éxiste';
			ROLLBACK;
		END IF; 
	END IF; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spUpdStock` (IN `pCodigo` BIGINT, IN `pStActual` INT, IN `pStatus` VARCHAR(15), OUT `CodRetorno` CHAR(3), OUT `msg` VARCHAR(100))  BEGIN
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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `autores`
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
-- Estructura de tabla para la tabla `categorias_producto`
--

CREATE TABLE `categorias_producto` (
  `codigo_catpro` bigint(20) NOT NULL,
  `nombre_categoria` varchar(20) COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes`
--

CREATE TABLE `clientes` (
  `matricula` bigint(20) NOT NULL,
  `rfc` char(13) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `empresa` varchar(30) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `nombre_contacto` varchar(20) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `apellido_paterno` varchar(30) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `apellido_materno` varchar(30) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `calle` varchar(30) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `numExt` int(11) NOT NULL,
  `numInt` varchar(5) CHARACTER SET utf8 COLLATE utf8_spanish_ci DEFAULT NULL,
  `colonia` varchar(20) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `ciudad` varchar(30) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `estado` varchar(20) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
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
-- Estructura de tabla para la tabla `cortecaja`
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
-- Estructura de tabla para la tabla `detalle_venta`
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
-- Estructura de tabla para la tabla `deudas`
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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `editoriales`
--

CREATE TABLE `editoriales` (
  `codigo_editorial` bigint(20) NOT NULL,
  `nombre_editorial` varchar(50) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `status` varchar(15) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `usuario` bigint(20) NOT NULL,
  `fechaCreacion` datetime NOT NULL,
  `fechaModificacion` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleados`
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
  `sueldo` decimal(10,2) NOT NULL,
  `puesto` varchar(30) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `status` char(10) CHARACTER SET latin1 NOT NULL,
  `isUsu` int(11) NOT NULL DEFAULT '0',
  `usuario` varchar(15) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `fechaCreacion` datetime NOT NULL,
  `fechaModificacion` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `folios`
--

CREATE TABLE `folios` (
  `id` bigint(20) NOT NULL,
  `nombre` char(10) COLLATE utf8_bin NOT NULL,
  `anio` int(11) NOT NULL,
  `consecutivo` bigint(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `libros`
--

CREATE TABLE `libros` (
  `codigo_libro` bigint(20) NOT NULL,
  `nombre_libro` varchar(50) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `isbn` varchar(13) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `autor` bigint(20) NOT NULL,
  `editorial` bigint(20) NOT NULL,
  `descripcion` varchar(500) CHARACTER SET utf8 COLLATE utf8_spanish_ci DEFAULT NULL,
  `usuario` varchar(15) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `status` varchar(10) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `fechaCreacion` datetime NOT NULL,
  `fechaModificacion` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
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
  `usuario` varchar(15) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `fechaCreacion` datetime NOT NULL,
  `fechaModificacion` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedores`
--

CREATE TABLE `proveedores` (
  `codigo_proveedor` bigint(20) NOT NULL,
  `nombre_proveedor` varchar(50) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `contacto` varchar(50) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
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
-- Estructura de tabla para la tabla `retiros`
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
-- Estructura de tabla para la tabla `tipo_usuarios`
--

CREATE TABLE `tipo_usuarios` (
  `id_tipoUsuario` bigint(20) NOT NULL,
  `descripcion` varchar(15) COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` bigint(20) NOT NULL,
  `nombre_usuario` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `password` varchar(100) COLLATE utf8_spanish_ci NOT NULL,
  `tipo_usuario` bigint(20) NOT NULL,
  `matricula_empleado` bigint(20) NOT NULL,
  `status` varchar(15) COLLATE utf8_spanish_ci NOT NULL,
  `fechaCreacion` datetime NOT NULL,
  `fechaModificacion` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas`
--

CREATE TABLE `ventas` (
  `folio` bigint(20) NOT NULL,
  `fecha_venta` datetime NOT NULL,
  `empleado` bigint(20) NOT NULL,
  `cliente` bigint(20) NOT NULL,
  `total` decimal(10,2) NOT NULL,
  `isTarjeta` int(11) NOT NULL,
  `folioTarjeta` int(11) DEFAULT NULL,
  `status` varchar(15) COLLATE utf8_spanish2_ci NOT NULL,
  `usuario` varchar(15) COLLATE utf8_spanish2_ci NOT NULL,
  `fechaCreacion` datetime NOT NULL,
  `fechaModificacion` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `autores`
--
ALTER TABLE `autores`
  ADD PRIMARY KEY (`codigo_autor`),
  ADD KEY `usuario` (`usuario`);

--
-- Indices de la tabla `categorias_producto`
--
ALTER TABLE `categorias_producto`
  ADD PRIMARY KEY (`codigo_catpro`);

--
-- Indices de la tabla `clientes`
--
ALTER TABLE `clientes`
  ADD PRIMARY KEY (`matricula`);

--
-- Indices de la tabla `cortecaja`
--
ALTER TABLE `cortecaja`
  ADD PRIMARY KEY (`folioCorte`);

--
-- Indices de la tabla `detalle_venta`
--
ALTER TABLE `detalle_venta`
  ADD PRIMARY KEY (`folio`,`clave_producto`);

--
-- Indices de la tabla `deudas`
--
ALTER TABLE `deudas`
  ADD PRIMARY KEY (`clave_deuda`);

--
-- Indices de la tabla `editoriales`
--
ALTER TABLE `editoriales`
  ADD PRIMARY KEY (`codigo_editorial`),
  ADD KEY `usuario` (`usuario`);

--
-- Indices de la tabla `empleados`
--
ALTER TABLE `empleados`
  ADD PRIMARY KEY (`matricula`);

--
-- Indices de la tabla `folios`
--
ALTER TABLE `folios`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `libros`
--
ALTER TABLE `libros`
  ADD PRIMARY KEY (`codigo_libro`),
  ADD KEY `usuario` (`usuario`),
  ADD KEY `editorial` (`editorial`),
  ADD KEY `autor` (`autor`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`codigo_producto`),
  ADD KEY `proveedor` (`proveedor`),
  ADD KEY `categoria` (`categoria`);

--
-- Indices de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  ADD PRIMARY KEY (`codigo_proveedor`),
  ADD KEY `usuario` (`usuario`);

--
-- Indices de la tabla `retiros`
--
ALTER TABLE `retiros`
  ADD PRIMARY KEY (`codigo_retiro`);

--
-- Indices de la tabla `tipo_usuarios`
--
ALTER TABLE `tipo_usuarios`
  ADD PRIMARY KEY (`id_tipoUsuario`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD KEY `tipo_usuario` (`tipo_usuario`);

--
-- Indices de la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD PRIMARY KEY (`folio`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `autores`
--
ALTER TABLE `autores`
  MODIFY `codigo_autor` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;
--
-- AUTO_INCREMENT de la tabla `categorias_producto`
--
ALTER TABLE `categorias_producto`
  MODIFY `codigo_catpro` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT de la tabla `clientes`
--
ALTER TABLE `clientes`
  MODIFY `matricula` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;
--
-- AUTO_INCREMENT de la tabla `deudas`
--
ALTER TABLE `deudas`
  MODIFY `clave_deuda` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT de la tabla `editoriales`
--
ALTER TABLE `editoriales`
  MODIFY `codigo_editorial` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;
--
-- AUTO_INCREMENT de la tabla `empleados`
--
ALTER TABLE `empleados`
  MODIFY `matricula` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;
--
-- AUTO_INCREMENT de la tabla `folios`
--
ALTER TABLE `folios`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;
--
-- AUTO_INCREMENT de la tabla `libros`
--
ALTER TABLE `libros`
  MODIFY `codigo_libro` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;
--
-- AUTO_INCREMENT de la tabla `productos`
--
ALTER TABLE `productos`
  MODIFY `codigo_producto` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;
--
-- AUTO_INCREMENT de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  MODIFY `codigo_proveedor` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT de la tabla `retiros`
--
ALTER TABLE `retiros`
  MODIFY `codigo_retiro` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;
--
-- AUTO_INCREMENT de la tabla `tipo_usuarios`
--
ALTER TABLE `tipo_usuarios`
  MODIFY `id_tipoUsuario` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `libros`
--
ALTER TABLE `libros`
  ADD CONSTRAINT `libro_autor` FOREIGN KEY (`autor`) REFERENCES `autores` (`codigo_autor`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `libro_editorial` FOREIGN KEY (`editorial`) REFERENCES `editoriales` (`codigo_editorial`) ON DELETE CASCADE ON UPDATE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
