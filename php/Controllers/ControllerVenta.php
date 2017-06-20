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
           	$sql = new VentaModel();
			$productosList = new ArrayObject();
			$productosDet = new ArrayObject();

			$objVenta = new Venta();
			
			$objVenta->setStatus('PAGADA');
			$objVenta->setFolio(trim(addslashes($_POST['folio']) ));
			$objVenta->setCliente(trim(addslashes($_POST['cliente'])) );
			$objVenta->setCajero(trim(addslashes($_POST['id'])));
			$objVenta->setMetodoPago(trim(addslashes($_POST['metodo'])) );	
			
			$json = $_POST['datos'];
			$detalleVenta = json_decode($json,true);
			$folioTarjeta = trim(addslashes($_POST['folTarj']));
			$total = trim(addslashes($_POST['total']));  
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
								$objDetalleVenta = new DetalleVenta();

								$objDetalleVenta->setFolio( $objVenta->getFolio());
								$objDetalleVenta->setCodigoProducto( $value['Código Producto'] );
								$objDetalleVenta->setCantidad( $value['Cantidad'] );
								$objDetalleVenta->setPrecio( $value['Precio'] );
								$objDetalleVenta->setSubtotal( $value['Subtotal'] );

								$productosDet[$j] = $objDetalleVenta;
								$j++;
							}
						}
					}
				}
			}
				//EJECUTAMOS EL MÉTODO PARA GUARDAR
			$respuesta = $sql->guardarVenta($objVenta,$productosDet);

			var_dump($respuesta);
        } catch (Exception $e) {
			$log->insert('Error guardarVenta '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
    }
?>