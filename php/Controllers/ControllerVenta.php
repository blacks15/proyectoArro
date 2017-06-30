<?php 
	header('Content-Type: application/json');
	require_once('../Models/ventaModel.php');
	require_once('../Clases/Venta.php');
	require_once('../Clases/Producto.php');
	require_once('../Clases/DetalleVenta.php');
	require_once('../Clases/Log.php');
	error_reporting(0);
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
        $log = new Log("log", "../../log/");
		$log->insert('Entro metodo guardarVenta', false, true, true);	
        try { 
			$i = 0;
			$j = 0;
           	$stock = "";
			$sql = new VentaModel();
			$productosList = new ArrayObject();
			$productosDet = new ArrayObject();

			$objVenta = new Venta();
			
			$objVenta->setStatus('PAGADA');
			$objVenta->setFolio(trim(addslashes($_POST['folio']) ));
			$objVenta->setCliente(trim(addslashes($_POST['cliente'])) );
			$objVenta->setCajero(trim(addslashes($_POST['id'])));
			$objVenta->setMetodoPago(trim($_POST['metodo']) );	
			$objVenta->setTotal( trim(addslashes($_POST['total'])) );
			$objVenta->setFolioTarjeta( trim(addslashes($_POST['folTarj'])) );

			$json = $_POST['datos'];
			$detalleVenta = json_decode($json,true);
            	//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => 'Venta',
					'mensaje' => 'Sesión Caducada'
				);
				$log->insert('Venta CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
				print json_encode($salidaJSON);
				exit();
			}
            	//VALIDAMOS SI EL FOLIO NO VIENE VACIO
			if (!isset($objVenta,$detalleVenta)) {
				$salidaJSON = array('codRetorno' => '004',
					'form' => 'Venta',
					'mensaje' => 'Faltan Parametros'
				);
				print json_encode($salidaJSON);
				exit();
			}
				//CARGAMOS LOS PRODUCTOS
			$productosList = $sql->listarProductos(); 
            	//CONSULTAR SI HAY PRODUCTOS SUFICIENTES PARA REALIZAR LA VENTA
			for ($i = 1; $i <= count($productosList) ; $i++) { //productosList LISTAS DE TODOS LOS PRODUCTOS EN STOCK
				foreach ($detalleVenta as $key => $value) { //PRODUCTOS QUE ADQUIERE CLIENTE
					if ($productosList[$i]->getCodigoBarras() == $value['Código Producto']) {
						if ($value['Código Producto'] != 'Total') {
							$cantidad = $productosList[$i]->getStockAct() - $value['Cantidad'];
								//VALIDAR SI HAY PRODUCTOS SUFICIENTE PARA LA VENTA
							if ($cantidad < 0) {
								$salidaJSON = array('codRetorno' => '002',
									'form' => 'Venta',
									'mensaje' => 'Producto insuficiente para la venta'
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
								$producto->setStatus( calculaStatus($cantidad,$productosList[$i]->getStockMax()) );

								$productosDet[$j] = $objDetalleVenta;
								$stock[$j] = $producto;

								$j++;
							}
						}
					}
				}
			}
				//EJECUTAMOS EL MÉTODO PARA GUARDAR
			$respuesta = $sql->guardarVenta($objVenta,$productosDet,$stock);

			if ($respuesta->CodRetorno == '000') {
				$salidaJSON = array('codRetorno' => $respuesta->CodRetorno,
					'form' => 'Venta',
					'Titulo' => 'Éxito',
					'Mensaje' => $respuesta->Mensaje,
				);
			} else {
				$salidaJSON = array('codRetorno' => $respuesta->CodRetorno,
					'form' => 'Venta',
					'Titulo' => 'Error',
					'Mensaje' => $respuesta->Mensaje,
				);
			} 

			$log->insert('Ventas CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
			print json_encode($salidaJSON);
        } catch (Exception $e) {
			$log->insert('Error guardarVenta '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
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