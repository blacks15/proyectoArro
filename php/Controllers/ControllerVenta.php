<?php 
	header('Content-Type: application/json');
	require_once('../Clases/Constantes.php');
	require_once(MODEL.'productoModel.php');
	require_once(CLASES.'PHPErrorLog.php');
	require_once(MODEL.'ventaModel.php');
	require_once(MODEL.'movimientosModel.php');
	session_start();
		//RECIBINMOS LA OPCIÓN Y LLAMAMOS LA FUNCIÓN
	$opc = $_POST["opc"];
	switch ($opc) {
		case 'filtroVentas':
			filtroVentas();
		break;

		case 'guardar':
			guardar_venta();
		break;

		case 'buscar':
			buscarVenta();
		break;
	}

	function filtroVentas(){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
				//RECIBIMOS EL SERIALIZE() Y LO ASIGNAMOS A VARIABLES
			parse_str($_POST["parametros"], $_POST);
			$retiro = new ArrayObject();
			$modelo = new MovimientosModel();
			$retiro->tabla = trim($_POST['codigo']);
			$retiro->idEmpleado = $_SESSION['INGRESO']['id'];
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO']) ) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => RETIRO,
					'Mensaje' => SESSION_CADUCADA
				);
				$logger->write(RETIRO.' codRetorno :  '.$salidaJSON['codRetorno'] , 6 );	
				print json_encode($salidaJSON);
			}

			$resModel = $modelo->recuperarFolio($retiro);

			if ($resModel['codRetorno'] == "000") {
				$salidaJSON = array('codRetorno' => $resModel['codRetorno'],
					'folio' => $resModel['DatosFolio']['folio'],
					'nombreEmpleado' => strtoupper($resModel['DatosFolio']['nombreEmpleado']),
					'matricula' => $retiro->idEmpleado
				);
			} else {
				$salidaJSON = array('codRetorno' => '002',
					'form' => RETIRO,
					'Titulo' => 'Error',
					'Mensaje' => MENSAJE_ERROR
				);
			}
			$logger->write(VENTA.' codRetorno :  '.$salidaJSON['codRetorno'] , 6 );	
			print json_encode($salidaJSON);
		} catch (Exception $e){
			$logger->write('guardarVenta: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());
		}
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
			$productosModel = new ProductoModel();

			$venta = json_decode($_POST['cadena']);
			$detalleVenta = json_decode($_POST['datos'],true);

			$venta->status = 'PAGADA';
			$venta->bandera = ACTIVAR_VENTA;
			$venta->usuario = $_SESSION['INGRESO']['nombre'];
				//VALIDAMOS SI ES CLIENTE GENERAL 1
			if ($venta->codigoCliente == "") {
				$venta->codigoCliente = 1;
			}
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
			if (!isset($venta->codigoCliente,$venta->folio,$venta->status,$venta->total,$venta->metPago,$venta->codigoEmpleado,$venta->folioTarjeta,$detalleVenta)) {
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
								$productosDet[$j] = array( 'folio' => $venta->folio,
									'codigoProducto' => $value['Código Producto'],
									'cantidad' => $value['Cantidad'],
									'precio' => $value['Precio'],
									'subTotal' => $value['Subtotal'],
									'stock' => $cantidad,
									'status' => $productosModel->calculaStatus($cantidad,$productosList[$i]['stMax'])
								);

								$j++;
							}
						}
					}
				}
			}
				//EJECUTAMOS EL MÉTODO PARA GUARDAR
			$resModel = $model->guardarVenta($venta,$productosDet);

			if ($resModel['codRetorno'] == '000') {
				$salidaJSON = array('codRetorno' => $resModel['codRetorno'],
					'form' => VENTA,
					'Titulo' => 'Éxito',
					'Mensaje' => $resModel['Mensaje']
				);
			} else {
				$salidaJSON = array('codRetorno' => $resModel['codRetorno'],
					'form' => VENTA,
					'Titulo' => 'Error',
					'Mensaje' => $resModel['Mensaje']
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