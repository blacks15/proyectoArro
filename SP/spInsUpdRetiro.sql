DROP PROCEDURE IF EXISTS spInsUpdRetiro;

DELIMITER $$
CREATE PROCEDURE spInsUpdRetiro (
	IN pCodigo BIGINT,
    IN pFolio BIGINT,
	IN pNombreEmpleado VARCHAR(50),
    In pCantidad DECIMAL,
    In pDescripcion VARCHAR(100),
    IN pStatus VARCHAR(15),
	IN pUsuario VARCHAR(15),
	OUT CodRetorno CHAR(3),
	OUT msg VARCHAR(100)
)
-- =============================================
-- Author:       	Felipe Monzón Mendoza
-- Create date: 	19/May/2017
-- Description:   	Procedimiento para guardar y/o Actualizar Retiros 
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
DELIMITER ;