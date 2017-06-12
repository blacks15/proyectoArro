DROP PROCEDURE IF EXISTS spDelRetiro;

DELIMITER $$
CREATE PROCEDURE spDelRetiro (
	IN pCodigo BIGINT,
    In pStatus VARCHAR(15),
    IN pUsuario VARCHAR(15),
	OUT CodRetorno CHAR(3),
	OUT msg VARCHAR(100)
)
-- =============================================
-- Author:       	Felipe Monzón Mendoza
-- Create date: 	21/May/2017
-- Description:   	Procedimiento para Eliminar Retiros
-- =============================================
BEGIN
    DECLARE vPerfil INT;
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
		SHOW WARNINGS LIMIT 1;
		SET CodRetorno = '003';
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
DELIMITER ;
