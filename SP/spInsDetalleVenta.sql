DROP PROCEDURE IF EXISTS spInsDetalleVenta;

DELIMITER $$
CREATE PROCEDURE spInsDetalleVenta (
    IN pFolio BIGINT,
    IN pIdProducto BIGINT,
    IN pCantidad INT,
    IN pPrecio DECIMAL(10,2),
    IN pSubTotal DECIMAL(10,2),
    IN pBandera INT,
    OUT codRetorno CHAR(3),
    OUT msg VARCHAR(100),
    OUT msgSQL VARCHAR(100)
)
-- ==============================================================================
-- Author:          Felipe Monzón
-- Create date:     19/Jun/2017
-- Description:     Procedimiento para guardar o Eliminar el detalle de una venta
-- ==============================================================================
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

    IF (pFolio = 0 || pIdProducto = 0 || pCantidad = 0 || pPrecio = 0.00 || pSubTotal = 0.00 || (pBandera != 1 && pBandera != 2) ) THEN
        SET codRetorno = '004';
        SET msg = 'Parametros Vacios';
    ELSE 
        IF (pBandera = 1) THEN
            IF NOT EXISTS (SELECT folio FROM detalle_venta WHERE folio = pFolio AND clave_producto = pIdProducto) THEN
                START TRANSACTION;
                    INSERT INTO detalle_venta (folio,clave_producto,cantidad,precio,subtotal)
                    VALUES (pFolio,pIdProducto,pCantidad,pPrecio,pSubTotal);

                    SET codRetorno = '000';
                    SET msg = 'Venta Guardada con Exito';
                COMMIT; 
            ELSE 
                SET codRetorno = '001';
                SET msg = 'El Folio ya fue Registrado';
                ROLLBACK;
            END IF;
        ELSEIF (pBandera = 2) THEN
            IF EXISTS (SELECT folio FROM detalle_venta WHERE folio = pFolio) THEN
                START TRANSACTION; 
                    DELETE FROM detalle_venta WHERE folio = pFolio;
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