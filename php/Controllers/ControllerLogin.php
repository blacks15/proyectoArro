<?php 
	header('Content-Type: application/json');
	require_once('../Models/usuarioModel.php');
	include "../Clases/Log.php";
	error_reporting(0);
	session_start();

	$opc = $_POST["opc"];
	switch ($opc) {
		case 'login':
			login();
		break;

		case 'cerrarSession':
			logOut();
		break;
	}
		//FUNCIÓN PARA LOGIN
	function login($usuario,$password){
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo login', false, true, true);	

		try {
				//RECIBIMOS EL SERIALIZE() Y LO ASIGNAMOS A VARIABLES
			parse_str($_POST["cadena"], $_POST);
				//DECLARACIÓN Y ASIGNACIÓN
			$usuario = trim($_POST['usuario']);
			$password = trim($_POST['password']);

			$password = mysql_real_escape_string($password);
			$usuario = mysql_real_escape_string($usuario);

			$usuario = addslashes($usuario);
			$password = addslashes($password);

			$sql = new UsuarioModel();
				//CARGAMOS LOS DATOS
			$usuario = $sql->inicioSesion($usuario,$password);	

			if ($usuario->CodRetorno == '000') {
				$salidaJSON = array('codRetorno' => $usuario->CodRetorno,
					'form' => 'frmLogin',
					'tipo' => $usuario->Tipo,
					'numEmp' => $usuario->NumEmp,
					'Titulo' => 'Bienvenido',
					'Mensaje' => $usuario->Nombre,
					'url' => 'Menu.html'
				);
			} else {
				$salidaJSON = array('codRetorno' => $usuario->CodRetorno,
					'form' => 'frmLogin',
					'Titulo' => 'Ocurrio un Error',
					'Mensaje' => $usuario->Mensaje,
				);
			}
			$log->insert('Login Codigo de Retorno '.$salidaJSON['codRetorno'], false, true, true);
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$log->insert('Error login '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}
		//FUNCIÓN PARA LOGOUT
	function logOut($usuario,$password){
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo logOut', false, true, true);	

		try {	

			session_start();
			session_unset();
			session_destroy();
			
			if (!isset($_SESSION) || empty($_SESSION['INGRESO']) ) {
				$salidaJSON = array('codRetorno' => '003',
					'Mensaje' => 'Auf Wiedersehen'
				);
				$log->insert('LogOut CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
				print json_encode($salidaJSON);
				exit();
			}

			$log->insert('LogOut Codigo de Retorno '.$salidaJSON['codRetorno'], false, true, true);
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$log->insert('Error logOut '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}
?>