<?php 
	header('Content-Type: application/json');
	require_once('../Clases/Constantes.php');
	require_once(CLASES.'PHPErrorLog.php');
	require_once(MODEL.'proveedorModel.php');
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
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
			//ASIGNACIÓN DE VARIABLES
			$modelo = new ProveedorModel();
			$resModel = new ArrayObject();
			$proveedor = json_decode($_POST['cadena']);
			$proveedor->usuario = $_SESSION['INGRESO']['nombre'];
				//VALIDAMOS EL CÓDIGO
			if ($proveedor->codigoEmpresa == "") {
				$proveedor->codigoEmpresa = 0;
			}
			if ($proveedor->status == "") {
				$proveedor->status = 'DISPONIBLE';
			}
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => PROVEEDOR,
					'Mensaje' => SESSION_CADUCADA
				);
				$logger->write('codRetorno Proveedor:  '.$salidaJSON['codRetorno'] , 6 );
				print json_encode($salidaJSON);
				exit();
			}
				//VALIDAMOS LOS PARAMETROS
			if (!isset($proveedor->codigoEmpresa,$proveedor->nombreEmpresa,$proveedor->nombreContacto,$proveedor->apellidoPaterno,
			$proveedor->apellidoMaterno,$proveedor->calle,$proveedor->numExt,$proveedor->colonia,$proveedor->ciudad,$proveedor->estado,
			$proveedor->telefono,$proveedor->celular,$proveedor->email,$proveedor->web,$proveedor->status) ) {
				$salidaJSON = array('codRetorno' => '004',
					'form' => PROVEEDOR,
					'Titulo' => 'Advertencia',
					'Mensaje' => PARAM_VACIOS
				);
				$log->insert('Proveedor CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
				print json_encode($salidaJSON);
				exit();
			}
				//EJECUTAMOS EL MÉTODO PARA GUARDAR
			$resModel = $modelo->guardarProveedor($proveedor);
				//SE VALIDA EL RETORNO DEL MÉTODO
			if ($resModel['codRetorno'] == '000') {
				$salidaJSON = array('codRetorno' => $resModel['codRetorno'],
					'form' => PROVEEDOR,
					'Titulo' => 'Éxito',
					'Mensaje' => $resModel['Mensaje']
				);	
			} else {
				$salidaJSON = array('codRetorno' => $resModel['codRetorno'],
					'form' => PROVEEDOR,
					'Titulo' => 'Error',
					'Mensaje' => $resModel['Mensaje']
				);
			}
			$logger->write(PROVEEDOR.' codRetorno :  '.$salidaJSON['codRetorno'] , 6 );	
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$logger->write('guardarProveedor: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage() ) ;				
		}
	}
		//FUNCIÓN PARA BUSCAR PROVEEDOR(ES)
	function buscarProveedor(){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();		
		try {
				//ASIGNACIÓN DE VARIABLES
			$modelo = new ProveedorModel();
			$resModel = new ArrayObject();
			$buscarProveedor = new ArrayObject();

			parse_str($_POST["parametros"], $_POST);
			$buscarProveedor->codigo = trim($_POST['codigo']);
			$buscarProveedor->tamanioPag = TAMANIO_PAGINACION;
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => PROVEEDOR,
					'Mensaje' => SESSION_CADUCADA
				);
				$logger->write('codRetorno Proveedor:  '.$salidaJSON['codRetorno'] , 6 );
				print json_encode($salidaJSON);
				exit();
			}
			
			if (isset($_POST['partida'])) {
				$buscarProveedor->paginaActual = $_POST['partida'];	
			}
				//CALCULAMOS EL INICIO
			if ($buscarProveedor->paginaActual <= 1){
				$buscarProveedor->inicio = 0;
			} else {
				$buscarProveedor->inicio = ($buscarProveedor->paginaActual - 1) * TAMANIO_PAGINACION;
			}
				//CARGAMOS LOS DATOS
			$resModel = $modelo->cargarProveedores($buscarProveedor);	

			if ($resModel['codRetorno'] == "000") {
				$salidaJSON = array('codRetorno' => $resModel['codRetorno'],
					'datos' => $resModel['Proveedores'],
					'link' => $resModel['lista'],
					'form' => PROVEEDOR
				);
			} else {
				$salidaJSON = array('codRetorno' => $resModel['codRetorno'],
					'form' => PROVEEDOR,
					'bus' => '1',
					'Titulo' => 'Error',
					'Mensaje' => $resModel['Mensaje']
				);
			}			
			$logger->write(PROVEEDOR.' codRetorno :  '.$salidaJSON['codRetorno'] , 6 );
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$logger->write('buscarProveedor: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage() ) ;	
		}
	}
?>