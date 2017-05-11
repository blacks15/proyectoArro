<?php 
	header('Content-Type: application/json');
	require_once('../Models/usuarioModel.php');
	include "../Clases/Log.php";
	error_reporting(0);
	session_start();

	$opc = $_POST["opc"];
	switch ($opc) {
		case 'buscar':
			buscarUsuarios();
		break;
	}

	function buscarUsuarios(){
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo buscarUsuarios', false, true, true);	
		parse_str($_POST["parametros"], $_POST);
		try {
			$usuario = trim($_POST['codigo']);
			$sql = new UsuarioModel();
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => 'Usuario',
					'mensaje' => 'Sesión Caducada'
				);
				$log->insert('Usuario CodRetorno: '.$salidaJSON['codRetorno'] , false, true, true);
				print json_encode($salidaJSON);
				exit();
			}

			$usuarios = $sql->validaUsuario($usuario); 

			if ($usuarios->CodRetorno == "000") {
				$salidaJSON = array ('codRetorno' => $usuarios->CodRetorno,
					'nombreEmpleado' => $usuarios->NombreEmpleado,
					'tipo_usuario' => $usuarios->Tipo ,
					'matricula' => $usuarios->Id,
					'usuario' => $usuarios->Usuario,
					'form' => 'Usuario',
				);
			} else {
				$salidaJSON = array('codRetorno' => $usuarios->CodRetorno,
					'form' => 'Usuario',
					'bus' => '1',
					'Mensaje' => $usuarios->Mensaje,
				);
			}

			$log->insert('Usuario CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
			print json_encode($salidaJSON);

		} catch (Exception $e) {
			$log->insert('Error buscarUsuario '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}
?>