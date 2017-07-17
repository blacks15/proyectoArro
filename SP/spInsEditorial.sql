DROP PROCEDURE IF EXISTS spInsEditorial;

DELIMITER $$
CREATE PROCEDURE spInsEditorial (
	IN pNombreEditorial VARCHAR(50),
	IN pUsuario VARCHAR(15),
	IN pStatus VARCHAR(15),
	OUT codRetorno CHAR(3),
	OUT msg VARCHAR(100),
	OUT msgSQL VARCHAR(100)
)
-- =============================================
-- Author:       	Pedro Ed Monzón Mendoza
-- Create date: 	30/Abr/2017
-- Description:   	Procedimiento para guardar y/o actualizar editoriales
-- =============================================
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
			
	IF (pNombreEditorial = '' && pUsuario = '' && pStatus = '' ) THEN
		SET codRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE
        IF NOT EXISTS(SELECT * FROM editoriales WHERE nombre_editorial = CONVERT(pNombreEditorial USING utf8) COLLATE utf8_general_ci ) THEN
            START TRANSACTION;
                INSERT INTO editoriales(nombre_editorial,usuario,status,fechaCreacion,fechaModificacion)
                VALUES (pNombreEditorial, pUsuario, pStatus, NOW(), NOW() );
                SET codRetorno = '000';
                SET msg = 'Editorial Guardado con Exito';
            COMMIT;
        ELSE
            SET codRetorno = '001';
            SET msg = 'La Editorial ya Existe';
            ROLLBACK;
        END IF; 
	END IF;
END$$
DELIMITER ;