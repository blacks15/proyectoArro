<?php 
	header('Content-Type: application/json');
	require_once('../Clases/Constantes.php');
	require_once(CLASES.'PHPErrorLog.php');
	require_once(CLASES.'funciones.php');
	require_once(MODEL.'empleadoModel.php');
	
	if (!isset($_SESSION)) {
		session_start();
	}
		//RECIBINMOS LA OPCIÓN Y LLAMAMOS LA FUNCIÓN
	$opc = $_POST["opc"];
	switch ($opc) {
		case 'guardar':
			guardarEmpleado();
		break;

		case 'buscar':
			buscarEmpleados();
		break;
	}
	
	function guardarEmpleado(){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
				//ASIGNAMOS A VARIABLES
			$empleado = json_decode($_POST['cadena']);
			$modelo = new EmpleadoModel();
			$resModelo = new ArrayObject();
			$empleado->status = 'DISPONIBLE';
			$empleado->usuario = $_SESSION['INGRESO']['nombre'];

			$replace = array(
				'(' => '',
				')' => '',
				'-' => '',
				' ' => ''
			);

			$empleado->celular = strReplaceAssoc($replace,$empleado->celular);
			$empleado->telefono = strReplaceAssoc($replace,$empleado->telefono);
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => EMPLEADO,
					'Mensaje' => SESSION_CADUCADA
				);
				$logger->write('codRetorno Empleado:  '.$salidaJSON['codRetorno'] , 6 );
				print json_encode($salidaJSON);
				exit();
			}

			if ($empleado->isUsu == "") {
				$empleado->isUsu = 0;
			}
				//VALIDAMOS LOS PARAMETROS
			if (!isset($empleado->codigoEmpleado,$empleado->nombreEmpleado,$empleado->apellidoPaterno,$empleado->apellidoMaterno,$empleado->calle,
				$empleado->numExt,$empleado->colonia,$empleado->ciudad,$empleado->estado,$empleado->celular,$empleado->sueldo,$empleado->puesto,
				$empleado->status,$empleado->isUsu )) {
				$salidaJSON = array('codRetorno' => '004',
					'form' => EMPLEADO,
					'Titulo' => 'Advertencia',
					'Mensaje' => PARAM_VACIOS
				);
				$logger->write(EMPLEADO.'codRetorno :  '.$salidaJSON['codRetorno'] , 6 );	
				print json_encode($salidaJSON);
				exit();
			}
				//EJECUTAMOS EL MÉTODO PARA GUARDAR
			$resModelo = $modelo->guardarEmpleado($empleado);
				//SE VALIDA EL RETORNO DEL MÉTODO
			if ($resModelo['codRetorno'] == '000') {
				$salidaJSON = array('codRetorno' => $resModelo['codRetorno'],
					'form' => EMPLEADO,
					'Titulo' => 'Éxito',
					'Mensaje' => $resModelo['Mensaje'],
				);
			} else {
				$salidaJSON = array('codRetorno' => $resModelo['codRetorno'],
					'form' => EMPLEADO,
					'Titulo' => 'Error',
					'Mensaje' => $resModelo['Mensaje'],
				);
			}
			$logger->write('codRetorno Empleado:  '.$salidaJSON['codRetorno'] , 6 );
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$logger->write('guardarEmpleado: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage() ) ;
		}
	}
		//FUNCIÓN PARA BUSCAR EMPLEADO(ES)
	function buscarEmpleados(){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
				//RECIBIMOS EL SERIALIZE() Y LO ASIGNAMOS A VARIABLES
			$modelo = new EmpleadoModel();
			$buscarEmpleado = new ArrayObject();
			parse_str($_POST["parametros"], $_POST);

			$buscarEmpleado->codigo = trim($_POST['codigo']);
			$buscarEmpleado->tamanioPag = TAMANIO_PAGINACION;
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => EMPLEADO,
					'Mensaje' => SESSION_CADUCADA
				);
				$logger->write('codRetorno Empleado:  '.$salidaJSON['codRetorno'] , 6 );
				print json_encode($salidaJSON);
				exit();
			}
			
			if (isset($_POST['partida'])) {
				$buscarEmpleado->paginaActual = $_POST['partida'];	
			}
				//CALCULAMOS EL INICIO
			if ($buscarEmpleado->paginaActual <= 1){
				$buscarEmpleado->inicio = 0;
			} else {
				$buscarEmpleado->inicio = ($buscarEmpleado->paginaActual - 1) * 5;
			}
				//CARGAMOS LOS DATOS
			$resModel = $modelo->cargarEmpleados($buscarEmpleado);	

			if ($resModel['codRetorno'] == "000") {
				$salidaJSON = array('codRetorno' => $resModel['codRetorno'],
					'datos' => $resModel['Empleados'],
					'link' => $resModel['lista'],
					'form' => EMPLEADO,
				);
			} else {
				$salidaJSON = array('codRetorno' => $resModel['codRetorno'],
					'form' => EMPLEADO,
					'bus' => '1',
					'Mensaje' => $resModel['Mensaje']
				);
			}			
			$logger->write('codRetorno Empleado:  '.$salidaJSON['codRetorno'] , 6 );
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$logger->write('buscarEmpleado: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage() ) ;
		}
	}
?>