<?php 
	header('Content-Type: application/json');
	require_once('../Models/productoModel.php');
	include "../Clases/Log.php";
	error_reporting(0);
	session_start();
		//RECIBINMOS LA OPCIÓN Y LLAMAMOS LA FUNCIÓN
	$opc = $_POST["opc"];
	switch ($opc) {
		case 'filtro':
			productoFiltro();
		break;
		
		case 'guardar':
			guardarProducto();
		break;

		case 'buscar':
			buscarProducto();
		break;
	}
		//FUNCIÓN FILTRO
	function productoFiltro(){
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo productoFiltro', false, true, true);	
		try {
			$sql = new ProductoModel();
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO']) ) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => 'Producto',
					'Mensaje' => 'Sesión Caducada'
				);
				$log->insert('Producto CodRetorno: '.$salidaJSON['codRetorno'], false, true, true);	
				print json_encode($salidaJSON);
				exit();
			}

			$datosCombo = $sql->productoFiltro();

			if ($datosCombo != "") {
				$salidaJSON = array('codRetorno' => '000',
					'proveedores' => $datosCombo->proveedores,
					'categorias' => $datosCombo->categorias,
					'form' => 'Producto',
				);	
			} else {
				$salidaJSON = array('codRetorno' => '002',
					'form' => 'Producto',
					'Mensaje' => 'Ocurrio un Error ',
				);
			}

			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$log->insert('Error productoFiltro '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}












?>