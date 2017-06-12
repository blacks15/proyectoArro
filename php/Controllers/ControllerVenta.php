<?php 
	header('Content-Type: application/json');
    require_once('../Models/productoModel.php');
	require_once('../Models/ventaModel.php');
	include "../Clases/Log.php";
	error_reporting(0);
	session_start();
		//RECIBINMOS LA OPCIÓN Y LLAMAMOS LA FUNCIÓN
	$opc = $_POST["opc"];
	switch ($opc) {
		case 'guardar':
			guardar_venta();
		break;

		case 'buscar':
			buscarAutores();
		break;
	}
        //FUNCIÓN PARA GUARDAR LA VENTA
    function guardar_venta(){
        $log = new Log("log", "../../log/");
		$log->insert('Entro metodo guardarVenta', false, true, true);	
        try {
           // $sql = new VentaModel();
            $productosModel = new ProductoModel();
            $productosList = $productosModel->cargarProductos('0','0',1,'0'); 

            $status = 'PAGADA';
			$json = $_POST['datos'];
			$total = trim(addslashes($_POST['total']));
			$folio = trim(addslashes($_POST['folio']));
			$cajero = trim(addslashes($_POST['id']));
			$cliente = trim(addslashes($_POST['cliente']));
			$metodoPago = trim(addslashes($_POST['metodo']));
			$folioTarjeta = trim(addslashes($_POST['folTarj']));
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
			if (!isset($folio,$total,$metodoPago,$detalleVenta,$cajero)) {
				$salidaJSON = array('codRetorno' => '004',
					'form' => 'Venta',
					'mensaje' => 'Faltan Parametros'
				);
				print json_encode($salidaJSON);
				exit();
			}
            	//CONSULTAR SI HAY PRODUCTOS SUFICIENTES PARA REALIZAR LA VENTA
			foreach ($detalleVenta as $key => $value) {
				if ($value['Código Producto'] != 'Total') {
                    $cantidad = $productos->cargarProductos($value['Código Producto']); 
				}
					//VALIDAR SI HAY PRODUCTOS SUFICIENTE PARA LA VENTA
				if ($cantProd < 0) {
					$salidaJSON = array('codRetorno' => '002',
						'form' => 'Venta',
						'mensaje' => 'Producto insuficiente para la venta'
					);
					print json_encode($salidaJSON);
					exit();
				}
			} */

        } catch (Exception $e) {
			$log->insert('Error guardarVenta '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
    }
?>