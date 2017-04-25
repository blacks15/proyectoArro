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

		case 'buscarAutor':
			buscarAutor();
		break;
	}

	function buscarAutores(){
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo buscarAutor!', false, true, true);	
		parse_str($_POST["parametros"], $_POST);
		try {
			$sql = new AutorModel();
			
			if (isset($_POST['partida'])) {
				$paginaActual = $_POST['partida'];	
			}
				//CARGAMOS LOS DATOS
			$autores = $sql->cargarAutores(0,0);
				//RECUPERAMOS NUM FILAS
			$numeroFilas = $autores->numFilas;
				//VALIDAMOS EL NÚMERO DE FILAS
			if ($numeroFilas == 0) {
				$salidaJSON = array('codRetorno' => '001',
					'form' => 'Autor',
					'error: ' => $error[2],
					'mensaje' => 'No Hay Datos Para Mostrar',
					'sesion' => $_SESSION['expire']
				);
				$log->insert('Autor CodRetorno: '.$salidaJSON['codRetorno'], false, true, true);	
				print json_encode($salidaJSON);
				exit();
			}
				//CALCULAMOS EL INICIO
			if ($paginaActual <= 1){
				$inicio = 0;
			} else {
				$inicio = ($paginaActual - 1) * 5;
			}
				//CREAMOS LA RESPUESTA 
			$salidaJSON = array ('codRetorno' => '000',
				'datos' => $autores->autores,
				'link' => $lista,
				'form' => 'Autor',
			);	
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$log->insert('Error buscarAutores! '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}
?>