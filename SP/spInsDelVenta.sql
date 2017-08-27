DROP PROCEDURE IF EXISTS spInsDelVenta;

DELIMITER $$
CREATE PROCEDURE spInsDelVenta (
    IN pFolio BIGINT,
    IN pNumEmpleado BIGINT,
    IN pNumCliente BIGINT,
    IN pTotal DECIMAL(10,2),
    IN pIsTarjeta INT,
    IN pFolioTarjeta INT,
    IN pStatus CHAR(15),
    IN pUsuario CHAR(15),
    IN pBandera INT,
    OUT codRetorno CHAR(3),
    OUT msg VARCHAR(100),
    OUT msgSQL VARCHAR(100)
)
-- =================================================================
-- Author:              Felipe Monzón
-- Create date:         19/Jun/2017
-- Description:         Procedimiento para guardar o Eliminar ventas
-- =================================================================
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

    IF (pFolio = 0 || pNumEmpleado = 0 || pNumCliente = 0 || pTotal = 0.00 || pIsTarjeta = 0 || pStatus = '' || pUsuario = '' || pBandera = 0 || (pBandera != 1 && pBandera != 2)) THEN
        SET codRetorno = '004';
        SET msg = 'Parametros Vacios';
    ELSE 
        IF (pBandera = 1) THEN
            IF NOT EXISTS (SELECT folio FROM ventas WHERE folio = pFolio) THEN 
                START TRANSACTION;
                    INSERT INTO ventas (folio,fecha_venta,empleado,cliente,total,isTarjeta,folioTarjeta,status,usuario,fechaCreacion,fechaModificacion) 
                    VALUES (pFolio, NOW(), pNumEmpleado, pNumCliente, pTotal, pIsTarjeta, pFolioTarjeta, pStatus, pUsuario, NOW(), NOW());
                    CALL spUpdFolios('ventas',1,@codRetorno,@msg);
                    SET codRetorno = '000';
                    SET msg = 'SP Ejecutado con Exito';
                COMMIT; 
            ELSE
                SET codRetorno = '001';
                SET msg = 'El Folio ya fue Registrado';
                ROLLBACK;  
            END IF;
        ELSEIF (pBandera = 2) THEN
            IF EXISTS (SELECT folio FROM ventas WHERE folio = pFolio) THEN
                START TRANSACTION; 
                    DELETE FROM ventas WHERE folio = pFolio;
                    CALL spUpdFolios('ventas',2,@codRetorno,@msg);
                    SET codRetorno = '000';
                    SET msg = 'SP Ejecutado Correctamente';
                COMMIT; 
            ELSE 
                SET codRetorno = '001';
                SET msg = 'El Folio No Existe';
                ROLLBACK;
            END IF;
        END IF;
    END IF;
END$$
DELIMITER ;