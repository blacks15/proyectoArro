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
	}
		//FUNCIÓN FILTRO 
    function filtroRetiro(){
        $log = new Log("log", "../../log/");
        try {
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

            $folio = $sql->recuperarFolio('retiros',$_SESSION['INGRESO']['id']);

			if ($folio->CodRetorno == "000") {
				$salidaJSON = array('codRetorno' => '000',
					'folio' => $folio->Datos[0]['vFolio'],
					'nombreEmpleado' => strtoupper($folio->Datos[0]['nombreEmpleado'])
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
			$log->insert('Error recuperaFolio '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}

?>