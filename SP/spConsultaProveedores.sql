DROP PROCEDURE IF EXISTS spConsultaProveedores;

DELIMITER $$
CREATE PROCEDURE spConsultaProveedores (
	IN pCodigo BIGINT,
	IN pInicio INT,
	IN pTamanio INT,
	OUT codRetorno CHAR(3),
	OUT msg VARCHAR(100),
	OUT numFilas INT,
	OUT msgSQL VARCHAR(100)
)
-- =============================================
-- Author:       	Felipe Monzón
-- Create date: 	29/Abr/2017
-- Description:   	Procedimiento para Consultar Proveedores 
-- =============================================
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
DELIMITER ;
