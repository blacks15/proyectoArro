DROP PROCEDURE IF EXISTS spInsVenta;

DELIMITER $$
CREATE PROCEDURE spInsVenta (
    IN pFolio BIGINT,
    IN pNumEmpleado BIGINT,
    IN pNumCliente BIGINT,
    IN pTotal DECIMAL(10,2),
    IN pIsTarjeta INT,
    IN pFolioTarjeta INT,
    IN pStatus CHAR(15),
    IN pUsuario CHAR(15),
    OUT CodRetorno CHAR(3),
    OUT msg VARCHAR(100)
)
-- ======================================================
-- Author:              Felipe Monzón
-- Create date:         19/Jun/2017
-- Description:         Procedimiento para guardar ventas
-- ======================================================
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
        @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
        SET CodRetorno = '002';
        SET msg = @full_error;
        RESIGNAL;
        ROLLBACK;
    END; 

    DECLARE EXIT HANDLER FOR SQLWARNING
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
        @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
        SET CodRetorno = '002';
        SET msg = @full_error;
        SHOW WARNINGS LIMIT 1;
        RESIGNAL;
        ROLLBACK;
    END;

    IF (pFolio = 0 || pNumEmpleado = 0 || pNumCliente = 0 || pTotal = 0.00 || pIsTarjeta = 0 || pStatus = '' || pUsuario = '') THEN
        SET CodRetorno = '004';
        SET msg = 'Parametros Vacios';
    ELSE 
        IF NOT EXISTS (SELECT folio FROM ventas WHERE folio = pFolio) THEN 
            START TRANSACTION;
                INSERT INTO ventas (folio,fecha_venta,empleado,cliente,total,isTarjeta,folioTarjeta,status,usuario,fechaCreacion,fechaModificacion) 
                VALUES (pFolio, NOW(), pNumEmpleado, pNumCliente, pTotal, pIsTarjeta, pFolioTarjeta, pStatus, pUsuario, NOW(), NOW());
                CALL spUpdFolios('ventas',@codRetorno,@msg);
                SET CodRetorno = '000';
                SET msg = 'SP Ejecutado con Exito';
            COMMIT; 
        ELSE
            SET CodRetorno = '001';
            SET msg = 'El Folio ya fue Registrado';
            ROLLBACK;  
        END IF;
    END IF;
END$$
DELIMITER ;