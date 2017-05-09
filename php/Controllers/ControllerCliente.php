<?php 
	header('Content-Type: application/json');
	require_once('../Models/clienteModel.php');
	include "../Clases/Log.php";
	error_reporting(0);
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

	function guardarEmpleado(){
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo guardarCliente', false, true, true);
		try {
				//RECIBIMOS EL SERIALIZE() Y LO ASIGNAMOS A VARIABLES
			parse_str($_POST["cadena"], $_POST);
			$sql = new ClienteModel();
			$status = 'DISPONIBLE';
			 	//CICLO PARA LLENAR VARIABLES POR POST
			foreach ($_POST as $clave => $valor) {
				${$clave} = trim($_POST[$clave]);
			}
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO']) ) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => 'Cliente',
					'Mensaje' => 'Sesión Caducada'
				);
				$log->insert('Cliente CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
				print json_encode($salidaJSON);
				exit();
			}
				//VALIDAMOS LOS PARAMETROS
			if (!isset($codigoCliente,$rfc,$nombreEmpresa,$nombreCliente,$apellidoPaterno,$apellidoMaterno,$calle,$numExt,$numInt,$colonia,$ciudad,$estado,$telefono,$celular,$email) ) {
				$salidaJSON = array('codRetorno' => '004',
					'form' => 'Cliente',
					'Titulo' => 'Advertencia',
					'Mensaje' => 'Parametros Vacios'
				);
				$log->insert('Cliente CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
				print json_encode($salidaJSON);
				exit();
			}
				//CREAMOS EL ARRAY CON LOS DATOS
			$datos = array($codigoCliente,$rfc,$nombreEmpresa,$nombreCliente,$apellidoPaterno,$apellidoMaterno,$calle,$numExt,$numInt,$colonia,$ciudad,$estado,$telefono,$celular,$email,$status,$_SESSION['INGRESO']['nombre']);
				//EJECUTAMOS EL MÉTODO PARA GUARDAR
			$res = $sql->guardarCliente($datos);
				//SE VALIDA EL RETORNO DEL MÉTODO
			if ($res->CodRetorno == '000') {
				$salidaJSON = array('codRetorno' => $res->CodRetorno,
					'form' => 'Cliente',
					'Titulo' => 'Éxito',
					'Mensaje' => $res->Mensaje,
				);
			} else {
				$salidaJSON = array('codRetorno' => $res->CodRetorno,
					'form' => 'Cliente',
					'Titulo' => 'Error',
					'Mensaje' => $res->Mensaje,
				);
			}

			$log->insert('Cliente CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$log->insert('Error guardarCliente: '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}



?>