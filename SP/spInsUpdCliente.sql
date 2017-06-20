DROP PROCEDURE IF EXISTS spInsUpdCliente;

DELIMITER $$
CREATE PROCEDURE spInsUpdCliente (
	IN pCodigo BIGINT,
	IN pRFC CHAR(13),
	IN pEmpresa VARCHAR(30),
	IN pNombreContacto VARCHAR(20),
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
	IN pEmail VARCHAR(30),
	IN pStatus VARCHAR(10),
	IN pUsuario VARCHAR(15),
	OUT CodRetorno CHAR(3),
	OUT msg VARCHAR(100)
)
-- =============================================
-- Author:       	Felipe Monzón
-- Create date: 	08/May/2017
-- Description:   	Procedimiento para guardar y/o actualizar Clientes
-- =============================================
BEGIN
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
		
	IF (pCodigo != 0 || COALESCE(pCodigo,NULL) = NULL) THEN
		IF EXISTS(SELECT * FROM clientes WHERE matricula = pCodigo) THEN
			IF ( (SELECT COUNT(*) FROM clientes WHERE matricula != pCodigo AND empresa = CONVERT(pEmpresa USING utf8) COLLATE utf8_general_ci) = 0 ) THEN
				IF ( (SELECT COUNT(*) FROM clientes WHERE matricula != pCodigo AND  rfc = pRFC) = 0 ) THEN
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
DELIMITER ;