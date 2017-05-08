<?php 
	header('Content-Type: application/json');
	require_once('../Models/provedorModel.php');
	include "../Clases/Log.php";
	error_reporting(0);
	session_start();
		//RECIBINMOS LA OPCIÓN Y LLAMAMOS LA FUNCIÓN
	$opc = $_POST["opc"];
	switch ($opc) {
		case 'guardar':
			guardarProveedor();
		break;

		case 'buscar':
			buscarProveedor();
		break;
	}
		//FUNCIÓN PARA GUARDAR
	function guardarProveedor(){	
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo guardarProveedor', false, true, true);		
		try {
			$sql = new ProveedorModel();
				//RECIBIMOS EL SERIALIZE() Y LO ASIGNAMOS A VARIABLES
			parse_str($_POST["cadena"], $_POST);
			 	//DECLARACION Y ASIGNACIÓN DE VARIABLES
			$status = 'DISPONIBLE';
			 	//CICLO PARA LLENAR VARIABLES POR POST
			foreach ($_POST as $clave => $valor) {
				${$clave} = trim($_POST[$clave]);
			}
				//VALIDAMOS EL CÓDIGO
			if ($codigoEmpresa == "") {
				$codigoEmpresa = 0;
			}
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO']) ) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => 'Proveedor',
					'Mensaje' => 'Sesión Caducada'
				);
				$log->insert('Proveedor CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
				print json_encode($salidaJSON);
				exit();
			}
				//VALIDAMOS LOS PARAMETROS
			if (!isset($codigoEmpresa,$nombreEmpresa,$nombreContacto,$calle,$numExt,$numInt,$colonia,$ciudad,$estado,$telefono,$celular,$email,$web,$status) ) {
				$salidaJSON = array('codRetorno' => '004',
					'form' => 'Proveedor',
					'Titulo' => 'Advertencia',
					'Mensaje' => 'Parametros Vacios'
				);
				$log->insert('Proveedor CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
				print json_encode($salidaJSON);
				exit();
			}
				//SE CREA EL ARRAY CON LOS DATOS A INSERTAR
			$datos = array($codigoEmpresa,$nombreEmpresa,$nombreContacto,$calle,$numExt,$numInt,$colonia,$ciudad,$estado,$telefono,$celular,$email,$web,$_SESSION['INGRESO']['nombre'],$status);
				//EJECUTAMOS EL MÉTODO PARA GUARDAR
			$res = $sql->guardarProveedor($datos);
				//SE VALIDA EL RETORNO DEL MÉTODO
			if ($res->CodRetorno == '000') {
				$salidaJSON = array('codRetorno' => $res->CodRetorno,
					'form' => 'Proveedor',
					'Titulo' => 'Éxito',
					'Mensaje' => $res->Mensaje,
				);	
			} else {
				$salidaJSON = array('codRetorno' => $res->CodRetorno,
					'form' => 'Proveedor',
					'Titulo' => 'Error',
					'Mensaje' => $res->Mensaje,
				);
			}

			$log->insert('Proveedor CodRetorno: '.$salidaJSON['codRetorno'], false, true, true);	
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$log->insert('Error Proveedor: '.$e->getMessage(), false, true, true);
			print('Ocurrio un Error'.$e->getMessage());					
		}
	}
		//FUNCIÓN PARA BUSCAR PROVEEDOR(ES)
	function buscarProveedor(){
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo buscarProveedores!', false, true, true);
		
		try {
				//RECIBIMOS EL SERIALIZE() Y LO ASIGNAMOS A VARIABLES
			parse_str($_POST["parametros"], $_POST);
			$codigo = trim($_POST['codigo']);
			$sql = new ProveedorModel();
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => 'Proveedor',
					'Mensaje' => 'Sesión Caducada'
				);
				$log->insert('Proveedor CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
				print json_encode($salidaJSON);
				exit();
			}
			
			if (isset($_POST['partida'])) {
				$paginaActual = $_POST['partida'];	
			}
				//CALCULAMOS EL INICIO
			if ($paginaActual <= 1){
				$inicio = 0;
			} else {
				$inicio = ($paginaActual - 1) * 5;
			}
				//CARGAMOS LOS DATOS
			$proveedores = $sql->cargarProveedores($codigo,$inicio,$paginaActual);	

			if ($proveedores->CodRetorno == "000") {
				$salidaJSON = array ('codRetorno' => $proveedores->CodRetorno,
					'datos' => $proveedores->proveedores,
					'link' => $proveedores->lista,
					'form' => 'Proveedor',
				);
			} else {
				$salidaJSON = array('codRetorno' => $proveedores->CodRetorno,
					'form' => 'Proveedor',
					'bus' => '1',
					'Mensaje' => $proveedores->Mensaje,
				);
			}			
			$log->insert('Proveedor CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$log->insert('Error buscarProveedores '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}
?>