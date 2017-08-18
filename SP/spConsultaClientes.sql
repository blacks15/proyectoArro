DROP PROCEDURE IF EXISTS spConsultaClientes;

DELIMITER $$
CREATE PROCEDURE spConsultaClientes (
	IN pCodigo BIGINT,
	IN pInicio INT,
	IN pTamanio INT,
	OUT codRetorno CHAR(3),
	OUT msg VARCHAR(100),
	OUT numFilas INT,
	OUT msgSQL VARCHAR(100)
)
-- ======================================================
-- Author:       	Felipe Monzón
-- Create date: 	09/May/2017
-- Description:   	Procedimiento para Consultar Clientes
-- ======================================================
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
DELIMITER ;