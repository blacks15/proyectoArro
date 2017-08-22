<?php 
require_once(CLASES.'funciones.php');
require_once(CLASES.'Producto.php');
require_once(MODEL.'productoModel.php');
/*	
	Clase: Model vENTAS
	Autor: Felipe Monzón
	Fecha: 24-MAY-2017
*/
class VentaModel {
    public function listarProductos(){
        $logger = new PHPTools\PHPErrorLog\PHPErrorLog(); 
        try {
            $a = 1;
            $productosList = array();
            $buscarProducto = new ArrayObject();
            $productosModel = new ProductoModel();

            $buscarProducto->codigo = '0';
            $buscarProducto->inicio = '0';
            $buscarProducto->tamanioPag = TAMANIO_PAGINACION;
            $buscarProducto->tipoBusqueda = '0';
            $buscarProducto->paginaActual = '0';

            $inventario = $productosModel->cargarProductos($buscarProducto);   

            $total  = ceil($inventario['numFilas']/TAMANIO_PAGINACION);

            for ($i = 1; $i <= $total ; $i++) {
                foreach ($inventario['Productos'] as $value) {
                    $productosList[$a] = array('codigo' => $value['codigoProducto'],
                        'codigoBarras' => $value['codigoBarras'],
                        'nombreProducto' => $value['nombreProducto'],
                        'stockAct' => $value['stActual'],
                        'stMax' => $value['stMax'],
                        'precioVenta' => $value['venta'],
                        'status' => $value['status']
                    );
                    $a++;
                }

                $buscarProducto->inicio = $buscarProducto->inicio + TAMANIO_PAGINACION;
                $inventario = $productosModel->cargarProductos($buscarProducto);  
            }

            return $productosList;
        } catch (Exception $e) {
            $logger->write('guardarVenta: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());
        }
    }

    public function guardarVenta($venta,$detalleVenta,$stock){
        $logger = new PHPTools\PHPErrorLog\PHPErrorLog();
        try {
            	//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
			if (empty($venta) || empty($detalleVenta) || empty($stock) ) {
				$retorno = array('codRetorno' => '004',
                    'form' => VENTA,
                    'mensaje' => PARAM_VACIOS
                );

				return $retorno;
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
            $logger->write('guardarVenta: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());
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

        $sql = "CALL spInsVenta(:folio,:cajero,:cliente,:total,:metodoPago,:foliotarjeta,:status,:usuario,:bandera,@codRetorno,@msg,@msgSQL)";

        $stm = executeSP($consulta,$datos);

        try{
            $sql = "";
			$db = new Conexion();
        } catch(Exception $e){
            $logger->write('guardarVenta: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());
        }

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