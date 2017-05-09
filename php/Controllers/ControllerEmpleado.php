<?php 
	header('Content-Type: application/json');
	require_once('../Models/empleadoModel.php');
	include "../Clases/Log.php";
	error_reporting(0);
	session_start();
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
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo guardarProducto', false, true, true);
		try {
				//RECIBIMOS EL SERIALIZE() Y LO ASIGNAMOS A VARIABLES
			parse_str($_POST["cadena"], $_POST);
			$sql = new EmpleadoModel();
			$status = 'DISPONIBLE';
			 	//CICLO PARA LLENAR VARIABLES POR POST
			foreach ($_POST as $clave => $valor) {
				${$clave} = trim($_POST[$clave]);
			}
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO']) ) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => 'Empleado',
					'Mensaje' => 'Sesión Caducada'
				);
				$log->insert('Empleado CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
				print json_encode($salidaJSON);
				exit();
			}

			if ($isUsu == "") {
				$isUsu = 0;
			}
				//VALIDAMOS LOS PARAMETROS
			if (!isset($codigoEmpleado,$nombreEmpleado,$apellidoPaterno,$apellidoMaterno,$calle,$numExt,$colonia,$ciudad,$estado,$celular,$sueldo,$puesto,$status,$_SESSION['INGRESO']['nombre'],$isUsu )) {
				$salidaJSON = array('codRetorno' => '004',
					'form' => 'Empleado',
					'Titulo' => 'Advertencia',
					'Mensaje' => 'Parametros Vacios'
				);
				$log->insert('Empleado CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
				print json_encode($salidaJSON);
				exit();
			}
				//CREAMOS EL ARRAY CON LOS DATOS
			$datos = array($codigoEmpleado,$nombreEmpleado,$apellidoPaterno,$apellidoMaterno,$calle,$numExt,$numInt,$colonia,$ciudad,$estado,$telefono,$celular,$sueldo,$puesto,$status,$isUsu,$_SESSION['INGRESO']['nombre']);
				//EJECUTAMOS EL MÉTODO PARA GUARDAR
			$res = $sql->guardarEmpleado($datos);
				//SE VALIDA EL RETORNO DEL MÉTODO
			if ($res->CodRetorno == '000') {
				$salidaJSON = array('codRetorno' => $res->CodRetorno,
					'form' => 'Empleado',
					'Titulo' => 'Éxito',
					'Mensaje' => $res->Mensaje,
				);
			} else {
				$salidaJSON = array('codRetorno' => $res->CodRetorno,
					'form' => 'Empleado',
					'Titulo' => 'Error',
					'Mensaje' => $res->Mensaje,
				);
			}

			$log->insert('Empleado CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$log->insert('Error guardarEmpleado: '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}
		//FUNCIÓN PARA BUSCAR EMPLEADO(ES)
	function buscarEmpleados(){
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo buscarEmpleados!', false, true, true);
		
		try {
				//RECIBIMOS EL SERIALIZE() Y LO ASIGNAMOS A VARIABLES
			parse_str($_POST["parametros"], $_POST);
			$codigo = trim($_POST['codigo']);
			$sql = new EmpleadoModel();
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => 'Empelado',
					'Mensaje' => 'Sesión Caducada'
				);
				$log->insert('Empelado CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
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
			$empleados = $sql->cargarEmpleados($codigo,$inicio,$paginaActual);	

			if ($empleados->CodRetorno == "000") {
				$salidaJSON = array ('codRetorno' => $empleados->CodRetorno,
					'datos' => $empleados->Empleados,
					'link' => $empleados->lista,
					'form' => 'Empleado',
				);
			} else {
				$salidaJSON = array('codRetorno' => $empleados->CodRetorno,
					'form' => 'Empleado',
					'bus' => '1',
					'Mensaje' => $empleados->Mensaje,
				);
			}			
			$log->insert('Empleado CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$log->insert('Error buscarEmpleados '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}
?>