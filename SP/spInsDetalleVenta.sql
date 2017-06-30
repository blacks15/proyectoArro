DROP PROCEDURE IF EXISTS spInsDetalleVenta;

DELIMITER $$
CREATE PROCEDURE spInsDetalleVenta (
    IN pFolio BIGINT,
    IN pIdProducto BIGINT,
    IN pCantidad INT,
    IN pPrecio DECIMAL(10,2),
    IN pSubTotal DECIMAL(10,2),
    OUT CodRetorno CHAR(3),
    OUT msg VARCHAR(100)
)
-- ====================================================================
-- Author:          Felipe Monzón
-- Create date:     19/Jun/2017
-- Description:     Procedimiento para guardar el detalle de una ventas
-- ====================================================================
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

    IF (pFolio = 0 || pIdProducto = 0 || pCantidad = 0 || pPrecio = 0.00 || pSubTotal = 0.00) THEN
        SET CodRetorno = '004';
        SET msg = 'Parametros Vacios';
    ELSE 
        IF NOT EXISTS (SELECT folio FROM detalle_venta WHERE folio = pFolio AND clave_producto = pIdProducto) THEN
            START TRANSACTION;
                INSERT INTO detalle_venta (folio,clave_producto,cantidad,precio,subtotal)
                VALUES(pFolio,pIdProducto,pCantidad,pPrecio,pSubTotal);

                SET CodRetorno = '000';
                SET msg = 'Venta Guardada con Exito';
            COMMIT; 
        ELSE 
            SET CodRetorno = '001';
            SET msg = 'El Folio ya fue Registrado';
            ROLLBACK;
        END IF;
    END IF;
END$$
DELIMITER ;