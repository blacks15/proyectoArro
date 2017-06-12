DROP PROCEDURE IF EXISTS spInsUpdProveedor;

DELIMITER $$
CREATE PROCEDURE spInsUpdProveedor (
	IN pCodigo BIGINT,
	IN pNombreProveedor VARCHAR(50),
	IN pContacto VARCHAR(50),
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
	IN pUsuario VARCHAR(15),
	IN pStatus VARCHAR(10),
	OUT CodRetorno CHAR(3),
	OUT msg VARCHAR(100)
)
-- =============================================
-- Author:       	Felipe Monzón
-- Create date: 	30/Abr/2017
-- Description:   	Procedimiento para guardar y/o actualizar Proveedores
-- =============================================
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
		@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
		SET msg = @full_error;
		SET CodRetorno = '003';
		RESIGNAL;
		ROLLBACK;
	END; 
	DECLARE EXIT HANDLER FOR SQLWARNING
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
		@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
		SET msg = @full_error;
		SET CodRetorno = '003';
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
			SET msg = 'El Proveedor no Existe';
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
			SET msg = 'El Proveedor ya Existe';
			ROLLBACK;
		END IF; 
	END IF; 
END$$
DELIMITER ;