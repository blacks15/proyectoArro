<?php 
require_once('../Clases/funciones.php');
require_once('../Clases/Producto.php');
require_once('../Models/productoModel.php');
/*	
	Clase: Model vENTAS
	Autor: Felipe Monzón
	Fecha: 24-MAY-2017
*/
class VentaModel {
    public function listarProductos(){
        try {
            $c = 0;
            $a = 1;
            $productosList = new ArrayObject();
            $productosModel = new ProductoModel();
            $inventario = $productosModel->cargarProductos('0',$c,'5','0');   

            $total  = ceil($inventario->numFilas/5);

            for ($i = 1; $i <= $total ; $i++) {     
                foreach ($inventario->Productos as $key => $value) {
                    $producto = new Producto();

                    $producto->setCodigo($value['id']);
                    $producto->setCodigoBarras($value['codigoBarras']);
                    $producto->setNombreProducto($value['nombreProducto']);
                    $producto->setStockAct($value['stActual']);
                    $producto->setStockMax($value['stMax']);
                    $producto->setPrecioVenta($value['venta']);
                    $producto->setStatus($value['status']);

                    $productosList[$a] = $producto;
                    $a++;
                }

                $c = $c + 5;
                $inventario = $productosModel->cargarProductos('0',$c,'5','0');  
            }

            return $productosList;
        } catch (Exception $e) {
            $log->insert('Error validarStock '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
        }
    }

    public function guardarVenta($venta,$detalleVenta,$stock){
        try {
            	//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
			if ($venta == "" || $detalleVenta == "" || $stock == "") {
				$retorno->CodRetorno = '004';
				$retorno->Mensaje = 'Parametros Vacios';

				return $retorno;
				exit();
			}

            $stm = $this->insertaVenta($venta);

			if ($stm->codRetorno[0] == '000') {  
                for ($i = 0; $i < count($detalleVenta); $i++) {
                    $stm = $this->insertaDetalle($detalleVenta[$i]);

                    if ($stm->codRetorno[0] == '000') {
                        $stm = $this->updStock($stock);

                        $retorno->CodRetorno = $stm->codRetorno[0];
                        $retorno->Mensaje = $stm->Mensaje[0];
                    } else {
                        $stm = $this->delVenta($venta);

                        if ($stm->codRetorno[0] == '000') {
                            $stm = $this->delDetalleVenta($venta);

                            if ($stm->codRetorno[0] == '000') {
                                $retorno->CodRetorno = $stm->codRetorno[0];
                                $retorno->Mensaje = $stm->Mensaje[0];
                            }
                        } else {
                            $retorno->CodRetorno = $stm->codRetorno[0];
                            $retorno->Mensaje = $stm->Mensaje[0];
                        }

                        return $retorno;
                    }
                } //END FOR
			} else if ($stm->codRetorno[0] == '002') {
                $retorno->CodRetorno = $stm->codRetorno[0];
				$retorno->Mensaje = 'Ocurrio un Error';
            }  else {
				$retorno->CodRetorno = $stm->codRetorno[0];
				$retorno->Mensaje = $stm->Mensaje[0];
			}

            return $retorno;
        } catch(Exception $e) {
            $log->insert('Error cargarProveedores '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
        }
    }

    private function delDetalleVenta($venta){
        $consulta = "CALL spDelDetalleVenta(?,@codRetorno,@msg)";
        $folio = array( $venta->getFolio() );

        $stm = executeSP($consulta,$folio);

        return $stm;
    }

    private function delVenta($venta){
        $consulta = "CALL spDelVenta(?,@codRetorno,@msg)";
        $folio = array( $venta->getFolio() );

        $stm = executeSP($consulta,$folio);

        return $stm;
    }

    private function updStock($stock){
        var_dump($stock->getCodigoBarras(),$stock->getStockAct(),$stock->getStatus());
        $consulta = "CALL spUpdStock(?,?,?,@CodRetorno,@msg)";
        $datos = array($stock->getCodigoBarras(),$stock->getStockAct(),$stock->getStatus());

        $stm = executeSP($consulta,$datos);
var_dump($stm);
        return $stm;
    }

    private function insertaVenta($venta){
        $datos = array($venta->getFolio(),$venta->getCajero(),$venta->getCliente(),$venta->getTotal(),$venta->getMetodoPago(),$venta->getFolioTarjeta(),$venta->getStatus(),$_SESSION['INGRESO']['nombre'] );

        $consulta = "CALL spInsVenta(?,?,?,?,?,?,?,?,@codRetorno,@msg)";

        $stm = executeSP($consulta,$datos);

        return $stm;
    }

    private function insertaDetalle($detalleVenta){
        $datos = array($detalleVenta->getFolio(),$detalleVenta->getCodigoProducto(),$detalleVenta->getCantidad(),$detalleVenta->getPrecio(),$detalleVenta->getSubtotal() );
        $consulta = "CALL spInsDetalleVenta(?,?,?,?,?,@codRetorno,@msg)";

        $stm = executeSP($consulta,$datos);

        return $stm;
    }

}

?>