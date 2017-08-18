<?php 
	header('Content-Type: application/json');
	require_once('../Clases/Constantes.php');
	require_once(CLASES.'PHPErrorLog.php');
	require_once(MODEL.'usuarioModel.php');

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
	function login(){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
				//DECLARACIÓN Y ASIGNACIÓN
			$modelo = new UsuarioModel();
			$login = new ArrayObject();
			$login = json_decode($_POST['cadena']);

			$login->usuario = addslashes($login->usuario);
			$login->password = addslashes($login->password);
				//VALIDAMOS LOS PARAMETROS
			if (!isset($login) ) {
				$salidaJSON = array('codRetorno' => '004',
					'form' => LOGIN,
					'Titulo' => 'Advertencia',
					'Mensaje' => PARAM_VACIOS
				);
				$logger->write(LOGIN.'codRetorno:  '.$salidaJSON['codRetorno'] , 6 );
				print json_encode($salidaJSON);
				exit();
			}
				//CARGAMOS LOS DATOS
			$usuario = $modelo->inicioSesion($login);	

			if ($usuario->CodRetorno == '000') {
				$salidaJSON = array('codRetorno' => $usuario->CodRetorno,
					'form' => LOGIN,
					'tipo' => $usuario->Tipo,
					'numEmp' => $usuario->NumEmp,
					'Titulo' => 'Bienvenido',
					'Mensaje' => $usuario->Nombre,
					'url' => 'Menu.html'
				);
			} else {
				$salidaJSON = array('codRetorno' => $usuario->CodRetorno,
					'form' => LOGIN,
					'Titulo' => MENSAJE_ERROR,
					'Mensaje' => $usuario->Mensaje,
				);
			}
			$logger->write(LOGIN.'codRetorno:  '.$salidaJSON['codRetorno'] , 6 );
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$logger->write('logOut '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());	
		}
	}
		//FUNCIÓN PARA LOGOUT
	function logOut(){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {	
			if (isset($_SESSION)) {
				session_unset();
				session_destroy();
			}
			
			if (!isset($_SESSION) || empty($_SESSION['INGRESO']) ) {
				$salidaJSON = array('codRetorno' => '003',
					'Mensaje' => MSG_CERRAR_SESSION
				);
				$logger->write(LOGIN.'codRetorno:  '.$salidaJSON['codRetorno'] , 6 );
				print json_encode($salidaJSON);
				exit();
			} else {
				$salidaJSON = array('codRetorno' => '002',
					'Mensaje' => MENSAJE_ERROR
				);
			}

			$logger->write(LOGIN.'codRetorno:  '.$salidaJSON['codRetorno'] , 6 );
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$logger->write('logOut '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());	
		}
	}
?>