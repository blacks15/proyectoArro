DROP PROCEDURE IF EXISTS spConsultaEmpleados;

DELIMITER $$
CREATE PROCEDURE spConsultaEmpleados (
	IN pCodigo BIGINT,
	IN pInicio INT,
	IN pTamanio INT,
	OUT codRetorno CHAR(3),
	OUT msg VARCHAR(100),
	OUT numFilas INT,
	OUT msgSQL VARCHAR(100)
)
-- =======================================================
-- Author:       	Felipe Monzón
-- Create date: 	08/May/2017
-- Description:   	Procedimiento para Consultar Empleados 
-- =======================================================
BEGIN
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
DELIMITER ;
