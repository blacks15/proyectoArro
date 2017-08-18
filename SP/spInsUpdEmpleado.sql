DROP PROCEDURE IF EXISTS spInsUpdEmpleado;

DELIMITER $$
CREATE PROCEDURE spInsUpdEmpleado (
	IN pCodigo BIGINT,
	IN pNombreEmpleado VARCHAR(20),
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
	IN pSueldo DECIMAL,
	IN pPuesto VARCHAR(30),
	IN pStatus VARCHAR(10),
	IN pISUsu INT,
	IN pUsuario VARCHAR(15),
	OUT codRetorno CHAR(3),
	OUT msg VARCHAR(100),
	OUT msgSQL VARCHAR(100)
)
-- ====================================================================
-- Author:       	Felipe Monzón
-- Create date: 	07/May/2017
-- Description:   	Procedimiento para guardar y/o actualizar Empleados
-- ====================================================================
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
DELIMITER ;