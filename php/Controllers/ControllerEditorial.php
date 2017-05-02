<?php 
	header('Content-Type: application/json');
	require_once('../Models/editorialModel.php');
	include "../Clases/Log.php";
	error_reporting(0);
	session_start();
		//RECIBINMOS LA OPCIÓN Y LLAMAMOS LA FUNCIÓN
	$opc = $_POST["opc"];
	switch ($opc) {
		case 'guardar':
			guardar_editorial();
		break;

		case 'buscar':
			buscarEditoriales();
		break;
	}
		//FUNCIÓN PARA GUARDAR AUTOR
	function guardar_editorial(){
		$log = new Log("log", "../log/");
		parse_str($_POST["cadena"], $_POST);
		$log->insert('Entro metodo guardar_editorial', false, true, true);	
		try {
			$sql = new EditorialModel();
			$status = 'DISPONIBLE';
				//CICLO PARA LLENAR VARIABLES POR POST
			foreach ($_POST as $clave => $valor) {
				${$clave} = trim($_POST[$clave]);
			}
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => 'Editorial',
					'mensaje' => 'Sesión Caducada'
				);
				$log->insert('Editorial CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
				print json_encode($salidaJSON);
				exit();
			}
				//VALIDAMOS EL CÓDIG DE AUTOR
			if ($codigoEditorial == "") {
				$codigoEditorial = 0;
			}
				//CARGAMOS LOS DATOS
			$res = $sql->guardarEditorial($codigoEditorial,$nombreEditorial,$status);

			if ($res->CodRetorno == '000') {
				$salidaJSON = array('codRetorno' => $res->CodRetorno,
					'form' => 'Editorial',
					'Titulo' => 'Éxito',
					'Mensaje' => $res->Mensaje,
				);
			} else {
				$salidaJSON = array('codRetorno' => $res->CodRetorno,
					'form' => 'Editorial',
					'Titulo' => 'Error',
					'Mensaje' => $res->Mensaje,
				);
			}

			$log->insert('Editorial CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$log->insert('Error guardar_editorial! '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}
		//FUNCIÓN PARA LISTAR TODOS LAS EDITORIALES
	function buscarEditoriales(){
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo buscarEditoriales', false, true, true);	
		parse_str($_POST["parametros"], $_POST);
		try {
			$codigo = trim($_POST['codigo']);
			$sql = new EditorialModel();

				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => 'Editorial',
					'mensaje' => 'Sesión Caducada'
				);
				$log->insert('Editorial CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
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
			$editoriales = $sql->cargarEditoriales($codigo,$inicio,$paginaActual);	

			if ($editoriales->CodRetorno == "000") {
				$salidaJSON = array ('codRetorno' => '000',
					'datos' => $editoriales->editoriales,
					'link' => $editoriales->lista,
					'form' => 'Editorial',
				);
			} else {
				$salidaJSON = array('codRetorno' => '002',
					'form' => 'Editorial',
					'bus' => '1',
					'Mensaje' => 'Ocurrio un Error en la Consulta ',
				);
			}			
			$log->insert('Editorial CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$log->insert('Error buscarEditoriales! '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}
?>