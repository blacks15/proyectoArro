<?php 
	header('Content-Type: application/json');
	require_once('../Models/movimientosModel.php');
	include "../Clases/Log.php";
	error_reporting(0);
	session_start();

	$opc = $_POST["opc"];
	switch ($opc) {
		case 'recuperaFolio':
			filtroRetiro();
		break;

		case 'guardar':
			guardarRetiro();
		break;
		
		case 'borrar':
			borrarRetiro();
		break;

		case 'buscar':
			buscarRetiro();
		break;
	}
		//FUNCIÓN FILTRO 
    function filtroRetiro(){
        $log = new Log("log", "../../log/");
        try {
				//RECIBIMOS EL SERIALIZE() Y LO ASIGNAMOS A VARIABLES
			parse_str($_POST["parametros"], $_POST);
			$tipo =	 trim($_POST['codigo']);
            $sql = new MovimientosModel();
            	//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => 'Retiro',
					'Mensaje' => 'Sesión Caducada'
				);
				$log->insert('Retiro CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);
				print json_encode($salidaJSON);
				exit();
			}
				//VALIDMOS LOS PERMISOS
			if ($_SESSION['INGRESO']['tipo'] != 1 && $_SESSION['INGRESO']['tipo'] != 2) {
				$salidaJSON = array('codRetorno' => '005',
					'form' => 'Inicio',
					'bus' => '1',
					'Mensaje' => 'No Cuenta con los permisos necesarios'
				);
				$log->insert('Retiro CodRetorno: '.$salidaJSON['codRetorno'] , false, true, true);
				print json_encode($salidaJSON);
				exit();
			} 

            $folio = $sql->recuperarFolio($tipo,$_SESSION['INGRESO']['id']);

			if ($folio->CodRetorno == "000") {
				$salidaJSON = array('codRetorno' => '000',
					'folio' => $folio->Datos[0]['vFolio'],
					'nombreEmpleado' => strtoupper($folio->Datos[0]['nombreEmpleado']),
					'matricula' => $_SESSION['INGRESO']['id']
				);
			} else {
				$salidaJSON = array('codRetorno' => '002',
					'form' => 'Retiro',
					'Titulo' => 'Error',
					'Mensaje' => 'Ocurrio un Error'
				);
			}

			$log->insert('Retiro CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);
			print json_encode($salidaJSON);
        } catch (Exception $e) {
			$log->insert('Error recuperaFolio '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
    }
		//FUNCIÓN PARA GUARDAR RETIROS
	function guardarRetiro(){
		$log = new Log("log", "../../log/");
        try {
				//RECIBIMOS EL SERIALIZE() Y LO ASIGNAMOS A VARIABLES
			parse_str($_POST["cadena"], $_POST);
			$sql = new MovimientosModel();
			$status = 'EFECTUADO';
			 	//CICLO PARA LLENAR VARIABLES POR POST
			foreach ($_POST as $clave => $valor) {
				${$clave} = trim($_POST[$clave]);
			}
				//VALIDAMOS EL CÓDIGO
			if ($codigoRetiro == "") {
				$codigoRetiro = 0;
			}
            	//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => 'Retiro',
					'Mensaje' => 'Sesión Caducada'
				);
				$log->insert('Retiro CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);
				print json_encode($salidaJSON);
				exit();
			}
				//VALIDAMOS LOS PARAMETROS
			if (!isset($codigoRetiro,$folio,$nombreEmpleado,$cantidad,$descripcion,$status) ) {
				$salidaJSON = array('codRetorno' => '004',
					'form' => 'Retiro',
					'Titulo' => 'Advertencia',
					'Mensaje' => 'Parametros Vacios'
				);
				$log->insert('Retiro CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
				print json_encode($salidaJSON);
				exit();
			}
				//EJECUTAMOS EL MÉTODO
			$respuesta = $sql->guardarRetiro($codigoRetiro,$folio,$nombreEmpleado,$cantidad,$descripcion,$status,$_SESSION['INGRESO']['nombre']);
				//SE VALIDA EL RETORNO DEL MÉTODO
			if ($respuesta->CodRetorno == '000') {
				$salidaJSON = array('codRetorno' => $respuesta->CodRetorno,
					'form' => 'Retiro',
					'Titulo' => 'Éxito',
					'Mensaje' => $respuesta->Mensaje,
				);
			} else {
				$salidaJSON = array('codRetorno' => $respuesta->CodRetorno,
					'form' => 'Retiro',
					'Titulo' => 'Error',
					'Mensaje' => $respuesta->Mensaje,
				);
			}

			$log->insert('Retiro CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$log->insert('Error guardarRetiro '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}
		//FUNCIÓN PARA GUARDAR RETIROS
	function borrarRetiro(){
		$log = new Log("log", "../../log/");
        try {
				//RECIBIMOS EL SERIALIZE() Y LO ASIGNAMOS A VARIABLES
			parse_str($_POST["cadena"], $_POST);
			$sql = new MovimientosModel();
			$status = 'ELIMINADO';
			 	//CICLO PARA LLENAR VARIABLES POR POST
			foreach ($_POST as $clave => $valor) {
				${$clave} = trim($_POST[$clave]);
			}
				//VALIDAMOS EL CÓDIGO
			if ($codigoRetiro == "") {
				$codigoRetiro = 0;
			}
            	//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => 'Retiro',
					'Mensaje' => 'Sesión Caducada'
				);
				$log->insert('Retiro CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);
				print json_encode($salidaJSON);
				exit();
			}
				//VALIDAMOS LOS PARAMETROS
			if ( $_SESSION['INGRESO']['tipo'] != 1) {
				$salidaJSON = array('codRetorno' => '002',
					'form' => 'Retiro',
					'Titulo' => 'Advertencia',
					'Mensaje' => 'No Cuenta con los Permisos Suficientes'
				);
				$log->insert('Retiro CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
				print json_encode($salidaJSON);
				exit();
			}
				//VALIDAMOS LOS PARAMETROS
			if (!isset($folio,$status) ) {
				$salidaJSON = array('codRetorno' => '004',
					'form' => 'Retiro',
					'Titulo' => 'Advertencia',
					'Mensaje' => 'Parametros Vacios'
				);
				$log->insert('Retiro CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
				print json_encode($salidaJSON);
				exit();
			}
				//EJECUTAMOS EL MÉTODO
			$respuesta = $sql->eliminarRetiro($folio,$status,$_SESSION['INGRESO']['nombre']);
				//SE VALIDA EL RETORNO DEL MÉTODO
			if ($respuesta->CodRetorno == '000') {
				$salidaJSON = array('codRetorno' => $respuesta->CodRetorno,
					'form' => 'Retiro',
					'Titulo' => 'Éxito',
					'Mensaje' => $respuesta->Mensaje,
				);
			} else {
				$salidaJSON = array('codRetorno' => $respuesta->CodRetorno,
					'form' => 'Retiro',
					'Titulo' => 'Error',
					'Mensaje' => $respuesta->Mensaje,
				);
			}

			$log->insert('Retiro CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$log->insert('Error borrrarRetiro '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}
 		//FUNCIÓN PARA BUSCAR RETIROS
	function buscarRetiro(){
		$log = new Log("log", "../../log/");
		try {
				//RECIBIMOS EL SERIALIZE() Y LO ASIGNAMOS A VARIABLES
			parse_str($_POST["parametros"], $_POST);
			$sql = new MovimientosModel();
			 	//CICLO PARA LLENAR VARIABLES POR POST
			foreach ($_POST as $clave => $valor) {
				${$clave} = trim(addslashes($_POST[$clave]));
			}
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => 'Retiro',
					'Mensaje' => 'Sesión Caducada'
				);
				$log->insert('Retiro CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);
				print json_encode($salidaJSON);
				exit();
			}
				//VALIDAMOS LOS PARAMETROS
			if (!isset($codigo) ) {
				$salidaJSON = array('codRetorno' => '004',
					'form' => 'Retiro',
					'Titulo' => 'Advertencia',
					'Mensaje' => 'Parametros Vacios'
				);
				$log->insert('Retiro CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
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
				//EJECUTAMOS EL MÉTODO
			$respuesta = $sql->buscarRetiro($codigo,$inicio,$paginaActual,$_SESSION['INGRESO']['nombre']);
				//SE VALIDA EL RETORNO DEL MÉTODO
			if ($respuesta->CodRetorno == '000') {
				$salidaJSON = array('codRetorno' => $respuesta->CodRetorno,
					'form' => 'Retiro',
					'datos' => $respuesta->Retiros,
					'link' => $respuesta->lista
				);
			} else {
				$salidaJSON = array('codRetorno' => $respuesta->CodRetorno,
					'form' => 'Retiro',
					'Titulo' => 'Error',
					'Mensaje' => $respuesta->Mensaje,
				);
			}

			$log->insert('Retiro CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$log->insert('Error buscarRetiro '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}
?>