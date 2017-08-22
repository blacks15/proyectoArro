<?php 
	header('Content-Type: application/json');
	require_once('../Clases/Constantes.php');
	require_once(CLASES.'PHPErrorLog.php');
	require_once(MODEL.'ventaModel.php');
	require_once(CLASES.'Venta.php');
	require_once(CLASES.'Producto.php');
	require_once(CLASES.'DetalleVenta.php');
	session_start();
		//RECIBINMOS LA OPCIÓN Y LLAMAMOS LA FUNCIÓN
	$opc = $_POST["opc"];
	switch ($opc) {
		case 'guardar':
			guardar_venta();
		break;

		case 'buscar':
			buscarVenta();
		break;
	}
        //FUNCIÓN PARA GUARDAR LA VENTA
    function guardar_venta(){
        $logger = new PHPTools\PHPErrorLog\PHPErrorLog();
        try { 
			$i = 0;
			$j = 0;
           	$stock = "";
			$productosList = array();
			$model = new VentaModel();
			$productosDet = new ArrayObject();

			$objVenta = new Venta();
			
			$objVenta->setStatus('PAGADA');
			$objVenta->setFolio(trim(addslashes($_POST['folio']) ));
			$objVenta->setCliente(trim(addslashes($_POST['cliente'])) );
			$objVenta->setCajero(trim(addslashes($_POST['id'])));
			$objVenta->setMetodoPago(trim($_POST['metodo']) );	
			$objVenta->setTotal( trim(addslashes($_POST['total'])) );
			$objVenta->setFolioTarjeta( trim(addslashes($_POST['folTarj'])) );

			$detalleVenta = json_decode($_POST['datos'],true);
            	//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO']) ) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => VENTA,
					'Mensaje' => SESSION_CADUCADA
				);
				$logger->write(VENTA.' codRetorno :  '.$salidaJSON['codRetorno'] , 6 );	
				print json_encode($salidaJSON);
				exit();
			}
            	//VALIDAMOS SI EL FOLIO NO VIENE VACIO
			if (!isset($objVenta,$detalleVenta)) {
				$salidaJSON = array('codRetorno' => '004',
					'form' => VENTA,
					'mensaje' => PARAM_VACIOS
				);
				print json_encode($salidaJSON);
				exit();
			}
				//CARGAMOS LOS PRODUCTOS
			$productosList = $model->listarProductos(); 
            	//CONSULTAR SI HAY PRODUCTOS SUFICIENTES PARA REALIZAR LA VENTA
			for ($i = 1; $i <= count($productosList) ; $i++) { //productosList LISTAS DE TODOS LOS PRODUCTOS EN STOCK
				foreach ($detalleVenta as $value) { //PRODUCTOS QUE ADQUIERE CLIENTE
					if ($productosList[$i]['codigoBarras'] == $value['Código Producto']) {
						if ($value['Código Producto'] != 'Total') {
							$cantidad = $productosList[$i]['stockAct'] - $value['Cantidad'];
								//VALIDAR SI HAY PRODUCTOS SUFICIENTE PARA LA VENTA
							if ($cantidad < 0) {
								$salidaJSON = array('codRetorno' => '002',
									'form' => VENTA,
									'Mensaje' => PRODUCTO_INSUFICIENTE
								);
								print json_encode($salidaJSON);
								exit();
							} else {
								$producto = new Producto();
								$objDetalleVenta = new DetalleVenta();

								$objDetalleVenta->setFolio( $objVenta->getFolio());
								$objDetalleVenta->setCodigoProducto( $value['Código Producto'] );
								$objDetalleVenta->setCantidad( $value['Cantidad'] );
								$objDetalleVenta->setPrecio( $value['Precio'] );
								$objDetalleVenta->setSubtotal( $value['Subtotal'] );
								$objDetalleVenta->setStock( $cantidad );

								$producto->setCodigoBarras( $value['Código Producto']  );
								$producto->setStockAct( $cantidad );
								$producto->setStatus( calculaStatus($cantidad,$productosList[$i]['stMax'] ));

								$productosDet[$j] = $objDetalleVenta;
								$stock[$j] = $producto;

								$j++;
							}
						}
					}
				}
			}
				//EJECUTAMOS EL MÉTODO PARA GUARDAR
			//$resModel = $model->guardarVenta($objVenta,$productosDet,$stock);

			if ($resModel->CodRetorno == '000') {
				$salidaJSON = array('codRetorno' => $resModel->CodRetorno,
					'form' => VENTA,
					'Titulo' => 'Éxito',
					'Mensaje' => $resModel->Mensaje,
				);
			} else {
				$salidaJSON = array('codRetorno' => $resModel->CodRetorno,
					'form' => VENTA,
					'Titulo' => 'Error',
					'Mensaje' => $resModel->Mensaje,
				);
			} 
			$logger->write(VENTA.' codRetorno :  '.$salidaJSON['codRetorno'] , 6 );		
			print json_encode($salidaJSON);
        } catch (Exception $e) {
			$logger->write('guardarVenta: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());
		}
    }

		//FUNCIÓN PARA CALCULAR STATUS
	function calculaStatus($stActual,$stMax){
		if ($stActual <= 0) {
			$status = 'AGOTADO';
		} else if ($stActual > $stMax) {
			$status = 'SOBRESTOCK';
		} else {
			$status = 'DISPONIBLE';
		}
		return $status;
	}
?>