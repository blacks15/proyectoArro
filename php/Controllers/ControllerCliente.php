<?php 
	header('Content-Type: application/json');
	require_once('../Clases/Constantes.php');
	require_once(CLASES.'PHPErrorLog.php');
	require_once(MODEL.'clienteModel.php');
	session_start();
		//RECIBINMOS LA OPCIÓN Y LLAMAMOS LA FUNCIÓN
	$opc = $_POST["opc"];
	switch ($opc) {
		case 'guardar':
			guardarCliente();
		break;

		case 'buscar':
			buscarClientes();
		break;
	}

	function guardarCliente(){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
				//ASIGNACIÓN DE VARIABLES
			$modelo = new ClienteModel();
			$resModelo = new ArrayObject();
			$cliente = json_decode($_POST['cadena']);
			$cliente->usuario = $_SESSION['INGRESO']['nombre'];
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => CLIENTE,
					'Mensaje' => SESSION_CADUCADA
				);
				$logger->write('codRetorno Cliente:  '.$salidaJSON['codRetorno'] , 6 );
				print json_encode($salidaJSON);
				exit();
			}
				//VALIDAMOS LOS PARAMETROS
			if (!isset($cliente->codigoCliente,$cliente->rfc,$cliente->nombreEmpresa,$cliente->nombreCliente,$cliente->apellidoPaterno,
			$cliente->apellidoMaterno,$cliente->calle,$cliente->numExt,$cliente->numInt,$cliente->colonia,$cliente->ciudad,$cliente->estado,
			$cliente->telefono,$cliente->celular,$cliente->email) ) {
				$salidaJSON = array('codRetorno' => '004',
					'form' => CLIENTE,
					'Titulo' => 'Advertencia',
					'Mensaje' => PARAM_VACIOS
				);
				$logger->write(CLIENTE.' codRetorno :  '.$salidaJSON['codRetorno'] , 6 );	
				print json_encode($salidaJSON);
				exit();
			}

			if ($cliente->status == "") {
				$cliente->status = 'DISPONIBLE';
			}
				//EJECUTAMOS EL MÉTODO PARA GUARDAR
			$resModelo = $modelo->guardarCliente($cliente);
				//SE VALIDA EL RETORNO DEL MÉTODO
			if ($resModelo['codRetorno'] == '000') {
				$salidaJSON = array('codRetorno' => $resModelo['codRetorno'],
					'form' => CLIENTE,
					'Titulo' => 'Éxito',
					'Mensaje' => $resModelo['Mensaje'],
				);
			} else {
				$salidaJSON = array('codRetorno' => $resModelo['codRetorno'],
					'form' => CLIENTE,
					'Titulo' => 'Error',
					'Mensaje' => $resModelo['Mensaje'],
				);
			}
			$logger->write(CLIENTE.' codRetorno :  '.$salidaJSON['codRetorno'] , 6 );	
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$logger->write('guardarCliente: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage() ) ;
		}
	}
		//FUNCIÓN PARA BUSCAR CLIENTE(S)
	function buscarClientes(){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
				//RECIBIMOS EL SERIALIZE() Y LO ASIGNAMOS A VARIABLES
			$modelo = new ClienteModel();
 			$buscarCliente = new ArrayObject();
			parse_str($_POST["parametros"], $_POST);
		
			$buscarCliente->codigo = trim($_POST['codigo']);
			$buscarCliente->tamanioPag = TAMANIO_PAGINACION;
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => CLIENTE,
					'Mensaje' => SESSION_CADUCADA
				);
				$logger->write(CLIENTE.' codRetorno :  '.$salidaJSON['codRetorno'] , 6 );	
				print json_encode($salidaJSON);
				exit();
			}
			
			if (isset($_POST['partida'])) {
				$buscarCliente->paginaActual = $_POST['partida'];	
			}
				//CALCULAMOS EL INICIO
			if ($buscarCliente->paginaActual <= 1){
				$buscarCliente->inicio = 0;
			} else {
				$buscarCliente->inicio = ($paginaActual - 1) * TAMANIO_PAGINACION;
			}
				//CARGAMOS LOS DATOS
			$resModel = $modelo->cargarClientes($buscarCliente);	

			if ($resModel['codRetorno'] == "000") {
				$salidaJSON = array ('codRetorno' => $resModel['codRetorno'],
					'datos' => $resModel['Clientes'],
					'link' => $resModel['lista'],
					'form' => CLIENTE
				);
			} else {
				$salidaJSON = array('codRetorno' => $resModel['codRetorno'],
					'form' => CLIENTE,
					'bus' => '1',
					'Titulo' => 'Error',
					'Mensaje' => $resModel['Mensaje']
				);
			}			
			$logger->write(CLIENTE.' codRetorno :  '.$salidaJSON['codRetorno'] , 6 );
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$logger->write('buscarClientes: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage() ) ;
		}
	}
?>