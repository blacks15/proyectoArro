DROP PROCEDURE IF EXISTS spRecuperaFolio;

DELIMITER $$
CREATE PROCEDURE spRecuperaFolio (
    IN pTabla VARCHAR(10),
	IN pCodigo BIGINT,
	OUT CodRetorno CHAR(3),
	OUT msg VARCHAR(100)
)
-- =============================================
-- Author:       	Felipe Monzón Mendoza
-- Create date: 	19/May/2017
-- Description:   	Procedimiento para Recuperar el Folio
-- =============================================
BEGIN
    DECLARE vFolio BIGINT;
    DECLARE vAnio INT;
    DECLARE vMes INT;
    DECLARE vDia INT;
    DECLARE vConsecutivo INT;

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
		SHOW WARNINGS LIMIT 1;
		SET CodRetorno = '002';
		RESIGNAL;
		ROLLBACK;
	END;

	IF (COALESCE(pCodigo,'') = '' && COALESCE(pTabla,'') = '' && pCodigo = 0) THEN
		SET CodRetorno = '004';
		SET msg = 'Parametros Vacios';
	ELSE
		IF EXISTS (SELECT * FROM empleados WHERE matricula = pCodigo ) THEN
			select YEAR(NOW()) INTO vAnio;
            select Date_format(NOW(),' %m') INTO vMes;  
            select DAY(NOW()) INTO vDia;

            SET vFolio = CONCAT(vAnio,'0',vMes,vDia); 

            IF ( (SELECT COUNT(consecutivo) FROM folios WHERE nombre = pTabla AND anio = vAnio) > 0) THEN
            	SELECT consecutivo INTO vConsecutivo FROM folios WHERE nombre = pTabla AND anio = vAnio;
            	SET vFolio = CONCAT((vFolio * 10000),vConsecutivo);
            ELSE
            	START TRANSACTION;
            	INSERT INTO folios (nombre,anio,consecutivo) VALUES(pTabla,vAnio,1);
            	SET vFolio = CONCAT((vFolio * 10000),1);
            	COMMIT;
            END IF;

			SELECT vFolio,CONCAT(nombre_empleado,' ',apellido_paterno,' ',apellido_materno) AS nombreEmpleado FROM empleados WHERE matricula = pCodigo;

            SET CodRetorno = '000';
			SET msg = 'SP Ejecutado Correctamente';
		ELSE
			SET CodRetorno = '001';
			SET msg = 'El Empleado no Existe';
		END IF;
	END IF;
END$$
DELIMITER ;
