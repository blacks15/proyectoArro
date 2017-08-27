<?php 
require_once(CLASES.'funciones.php');
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

    public function guardarVenta($venta,$detalleVenta){
        $logger = new PHPTools\PHPErrorLog\PHPErrorLog();
        try {
            $productosModel = new ProductoModel();
            	//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
			if (empty($venta) || empty($detalleVenta) ) {
				$retorno = array('codRetorno' => '004',
                    'form' => VENTA,
                    'Mensaje' => PARAM_VACIOS
                );

				return $retorno;
			}

            $respVenta = $this->insertaVenta($venta);

			if ($respVenta['codRetorno'] == '000') {
                for ($i = 0; $i < count($detalleVenta); $i++) {
                    $resDetalle = $this->insertaDetalle($detalleVenta[$i],$venta->bandera);

                    if ($resDetalle['codRetorno'] == '000') {
                        $resUpdStock = $productosModel->updStock($detalleVenta[$i]);
                        
                        if ($resUpdStock['codRetorno'] == '000') {
                            $retorno = array( 'codRetorno' => $resUpdStock['codRetorno'],
                                'Mensaje' => VENTA_EXITO.$venta->folio
                            );
                        } else {
                            for ($j = ($i-1); $j < 0; $j--) { 
                                $detalleVenta[$j]['stock'] = $detalleVenta[$j]['stock'] ;
                                $resUpdStock = $productosModel->updStock($detalleVenta[$J]);
                            }
                            $retorno = $this->eliminarVenta($venta,$detalleVenta[$i]);
                        }
                    } else {
                        $retorno = $this->eliminarVenta($venta,$detalleVenta[$i]);
                    } //IF DETALLE
                } //END FOR
			} else {
                $retorno = array( 'codRetorno' => $respVenta['codRetorno'],
                    'Mensaje' => $respVenta['Mensaje']
                );
			}

            return $retorno;
        } catch(Exception $e) {
            $logger->write('guardarVenta: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());
        }
    }

    private function eliminarVenta($venta,$detalleVenta){
        $venta->bandera = ELIMINAR_VENTA;
        $respVenta = $this->insertaVenta($venta);

        if ($respVenta['codRetorno'] == '000') {
            $resDetalle = $this->insertaDetalle($detalleVenta,$venta->bandera);

            if ($resDetalle['codRetorno'] == '000') {
                $retorno = array( 'codRetorno' => '002',
                    'Mensaje' => MENSAJE_ERROR
                );
            } else {                
                $retorno = array( 'codRetorno' => $resUpdStock['codRetorno'],
                    'Mensaje' => MENSAJE_ERROR
                );
            }
        } else {
            $retorno = array( 'codRetorno' => $respVenta['codRetorno'],
                'Mensaje' => MENSAJE_ERROR
            );
        }

        return $retorno;
    }

    private function insertaVenta($venta){
        $logger = new PHPTools\PHPErrorLog\PHPErrorLog();
        try {
            $db = new Conexion();
            $sql = SP_INSDEL_VENTA;
            
            $stm = $db->prepare($sql);

            $stm->bindParam(':folio',$venta->folio,PDO::PARAM_INT);
			$stm->bindParam(':cajero',$venta->codigoEmpleado,PDO::PARAM_INT);
			$stm->bindParam(':cliente',$venta->codigoCliente,PDO::PARAM_INT);
            $stm->bindParam(':total',$venta->total,PDO::PARAM_INT);
            $stm->bindParam(':metodoPago',$venta->metPago,PDO::PARAM_INT);
            $stm->bindParam(':foliotarjeta',$venta->folioTarjeta,PDO::PARAM_INT);
            $stm->bindParam(':status',$venta->status,PDO::PARAM_STR);
            $stm->bindParam(':usuario',$venta->usuario,PDO::PARAM_STR);
            $stm->bindParam(':bandera',$venta->bandera,PDO::PARAM_INT);
            
            $stm->execute();			
			$stm->closeCursor();
			
			$error = $stm->errorInfo();

			if ($error[2] != "") {
				$logger->write('spInsDelVenta: '.$error[2], 3 );
			}

			$retorno = $db->query('SELECT @codRetorno AS codRetorno, @msg AS Mensaje, @msgSQL AS msgSQL80')->fetch(PDO::FETCH_ASSOC);
			$logger->write('codRetorno spInsDelVenta:  '.$retorno['codRetorno'] ,6 );

			if ($retorno['msgSQL80'] != '' || $retorno['msgSQL80'] != null) {
				$logger->write('spInsDelVenta: '.$retorno['msgSQL80'] , 3 );
				$retorno['Mensaje'] = MENSAJE_ERROR;
			}

			if ($retorno['codRetorno'] == "" ) {
				$retorno['codRetorno'] = '002';
				$retorno['Mensaje'] = MENSAJE_ERROR;
				return $retorno;
			}

			$db = null;

			return $retorno;
        } catch (Exception $e){
            $logger->write('guardarVenta: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());
        }
    }

    private function insertaDetalle($detalleVenta,$bandera){
        $logger = new PHPTools\PHPErrorLog\PHPErrorLog();
        try {
            $db = new Conexion();
            $sql = SP_INSDEL_DETALLE_VENTA;
            $detalleVenta['bandera'] = $bandera;
            
            $stm = $db->prepare($sql);

            $stm->bindParam(':folio',$detalleVenta['folio'],PDO::PARAM_INT);
			$stm->bindParam(':codigoProducto',$detalleVenta['codigoProducto'],PDO::PARAM_INT);
			$stm->bindParam(':cantidad',$detalleVenta['cantidad'],PDO::PARAM_INT);
            $stm->bindParam(':precio',$detalleVenta['precio'],PDO::PARAM_INT);
            $stm->bindParam(':subTotal',$detalleVenta['subTotal'],PDO::PARAM_INT);
            $stm->bindParam(':bandera',$detalleVenta['bandera'],PDO::PARAM_INT);
            
            $stm->execute();			
			$stm->closeCursor();
			
			$error = $stm->errorInfo();

			if ($error[2] != "") {
				$logger->write('spInsDetalleVenta: '.$error[2], 3 );
			}

			$retorno = $db->query('SELECT @codRetorno AS codRetorno, @msg AS Mensaje, @msgSQL AS msgSQL80')->fetch(PDO::FETCH_ASSOC);
			$logger->write('codRetorno spInsDetalleVenta:  '.$retorno['codRetorno'] ,6 );

			if ($retorno['msgSQL80'] != '' || $retorno['msgSQL80'] != null) {
				$logger->write('spInsDetalleVenta: '.$retorno['msgSQL80'] , 3 );
				$retorno['Mensaje'] = MENSAJE_ERROR;
			}

			if ($retorno['codRetorno'] == "" ) {
				$retorno['codRetorno'] = '002';
				$retorno['Mensaje'] = MENSAJE_ERROR;
				return $retorno;
			}

			$db = null;

			return $retorno;
        } catch (Exception $e){
            $logger->write('guardarVenta: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());
        }
    }
}
?>