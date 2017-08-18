DROP PROCEDURE IF EXISTS spInsUpdProveedor;

DELIMITER $$
CREATE PROCEDURE spInsUpdProveedor (
	IN pCodigo BIGINT,
	IN pNombreProveedor VARCHAR(50),
	IN pContacto VARCHAR(50),
	IN pAPaterno VARCHAR(30),
	IN pAMaterno VARCHAR(30),
	IN pCalle VARCHAR(30),
	IN pNumExt INT,
	IN pNumInt VARCHAR(5),
	IN pColonia VARCHAR(30),
	IN pCiudad VARCHAR(30),
	IN pEstado VARCHAR(30),
	IN pTelefono VARCHAR(10),
	IN pCelular VARCHAR(10),
	IN pEmail VARCHAR(40),
	IN pWeb VARCHAR(50),
	IN pStatus VARCHAR(10),
	IN pUsuario VARCHAR(15),
	OUT codRetorno CHAR(3),
	OUT msg VARCHAR(100),
	OUT msgSQL VARCHAR(100)
)
-- ======================================================================
-- Author:       	Felipe Monzón
-- Create date: 	30/Abr/2017
-- Description:   	Procedimiento para guardar y/o actualizar Proveedores
-- ======================================================================
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
DELIMITER ;