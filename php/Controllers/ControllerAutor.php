<?php 
	header('Content-Type: application/json');
	require_once('../Models/autorModel.php');
	include "../Clases/Log.php";
	error_reporting(0);
	session_start();
		//RECIBINMOS LA OPCIÓN Y LLAMAMOS LA FUNCIÓN
	$opc = $_POST["opc"];
	switch ($opc) {
		case 'guardar':
			guardar_autor();
		break;

		case 'actualizar':
			actualizar_autor();
		break;

		case 'buscar':
			buscarAutores();
		break;
	}
		//FUNCIÓN PARA GUARDAR AUTOR
	function guardar_autor(){
		$log = new Log("log", "../log/");
		parse_str($_POST["cadena"], $_POST);
		$log->insert('Entro metodo guardarAutor', false, true, true);	
		try {
			$sql = new AutorModel();
			$status = 'DISPONIBLE';
				//CICLO PARA LLENAR VARIABLES POR POST
			foreach ($_POST as $clave => $valor) {
				${$clave} = trim($_POST[$clave]);
			}
				//VALIDAMOS LA SESSION
			if (isset($_SESSION)) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => 'Autor',
					'mensaje' => 'Sesión Caducada'
				);
				$log->insert('Autor CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
				print json_encode($salidaJSON);
				exit();
			}
				//CARGAMOS LOS DATOS
			$res = $sql->guardarAutor($codigo,$nombre,$status);

			var_dump($res);

			$log->insert('Autor CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$log->insert('Error guardarAutores! '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}
		//FUNCIÓN PARA LISTAR TODOS LOS AUTORES
	function buscarAutores(){
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo buscarAutor!', false, true, true);	
		parse_str($_POST["parametros"], $_POST);
		try {
			$codigo = trim($_POST['codigo']);
			$sql = new AutorModel();

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
			$autores = $sql->cargarAutores($codigo,$inicio,$paginaActual);	

			if ($autores->CodRetorno == "000") {
					//CREAMOS LA RESPUESTA 
				$salidaJSON = array ('codRetorno' => '000',
					'datos' => $autores->autores,
					'link' => $autores->lista,
					'form' => 'Autor',
				);
			} else {
				$salidaJSON = array('codRetorno' => '002',
					'form' => 'Autor',
					'bus' => '1',
					'mensaje' => 'Ocurrio un Error en la Consulta ',
				);
			}			
			$log->insert('Autor CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$log->insert('Error buscarAutores! '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}
?>