DROP PROCEDURE IF EXISTS spDelVenta;

DELIMITER $$
CREATE PROCEDURE spDelVenta (
    IN pFolio BIGINT, 
    OUT codRetorno CHAR(3),
    OUT msg VARCHAR(100)
)
-- ======================================================
-- Author:              Felipe Monzón
-- Create date:         20/Jun/2017
-- Description:         Procedimiento para eliminar ventas
-- ======================================================
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
        @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
        SET codRetorno = '002';
        SET msg = @full_error;
        RESIGNAL;
        ROLLBACK;
    END; 

    DECLARE EXIT HANDLER FOR SQLWARNING
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
        @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
        SET codRetorno = '002';
        SET msg = @full_error;
        SHOW WARNINGS LIMIT 1;
        RESIGNAL;
        ROLLBACK;
    END;

    IF (pFolio = 0) THEN
        SET codRetorno = '004';
        SET msg = 'Parametros Vacios';
    ELSE 
        START TRANSACTION; 
            DELETE FROM ventas WHERE folio = pFolio;
            CALL spDelFolios('ventas',@codRetorno,@msg);
            SET codRetorno = '000';
            SET msg = 'SP Ejecutado Correctamente';
        COMMIT; 
    END IF;
END$$
DELIMITER ;