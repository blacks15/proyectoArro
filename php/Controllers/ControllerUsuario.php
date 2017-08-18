<?php 
	header('Content-Type: application/json');
	require_once('../Clases/Constantes.php');
	require_once(CLASES.'PHPErrorLog.php');
	require_once(MODEL.'usuarioModel.php');

	if (!isset($_SESSION)) {
		session_start();
	}
	
	$opc = $_POST["opc"];
	switch ($opc) {
		case 'guardar':
			guardarUsuario();
		break;

		case 'validaUsuario':
			validaUsuario();
		break;

		case 'buscar':
			buscarUsuarios();
		break;

		case 'eliminar':
			desasociarUsuario();
		break;

		case 'cambiarContrasenia':
			cambiarContrasenia();
		break;

		case 'isAdmin':
			validaAdmin();
		break;
	}

	function desasociarUsuario(){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try{
			$respuesta = new ArrayObject();
			$modelo = new UsuarioModel();
			$usuario = json_decode($_POST['cadena']);
			$usuario->bandera = ELIMINAR_USUARIO;
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => USUARIO,
					'Mensaje' => SESSION_CADUCADA
				);
				$logger->write('codRetorno Usuario:  '.$salidaJSON['codRetorno'] , 6 );
				print json_encode($salidaJSON);
				exit();
			}
				//VALIDAMOS LA SESSION
			if ($_SESSION['INGRESO']['tipo'] != 1 ) {
				$salidaJSON = array('codRetorno' => '002',
					'form' => USUARIO,
					'Titulo' => 'Advertencia',
					'Mensaje' => SIN_PERMISOS
				);
				$logger->write('codRetorno Usuario:  '.$salidaJSON['codRetorno'] , 6 );
				print json_encode($salidaJSON);
				exit();
			}

			if (!isset($usuario) || empty($usuario->codigoEmpleado)) {
				$salidaJSON = array('codRetorno' => '004',
					'form' => USUARIO,
					'Mensaje' => PARAM_VACIOS
				);
				$logger->write('codRetorno Usuario:  '.$salidaJSON['codRetorno'] , 6 );
				print json_encode($salidaJSON);
				exit();
			}

			$resModelo = $modelo->eliminarUsuario($usuario);

			if ($resModelo->CodRetorno == '000') {
				$salidaJSON = array('codRetorno' => $resModelo->CodRetorno,
					'form' => USUARIO,
					'Titulo' => 'Éxito',
					'Mensaje' => $resModelo->Mensaje,
				);
			} else {
				$salidaJSON = array('codRetorno' => $resModelo->CodRetorno,
					'form' => USUARIO,
					'Titulo' => 'Error',
					'Mensaje' => $resModelo->Mensaje,
				);
			}
			$logger->write('codRetorno Usuario:  '.$salidaJSON['codRetorno'] , 6 );
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$logger->write('desasociarUsuario: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());	
		}
	}

	function guardarUsuario(){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
			$respuesta = new ArrayObject();
			$modelo = new UsuarioModel();
			$usuario = json_decode($_POST['cadena']);
			$usuario->bandera = ACTIVAR_USUARIO;
			$usuario->status = "ACTIVO";
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => USUARIO,
					'Mensaje' => SESSION_CADUCADA
				);
				$logger->write('codRetorno Usuario:  '.$salidaJSON['codRetorno'] , 6 );
				print json_encode($salidaJSON);
				exit();
			}
				//VALIDAMOS LA SESSION
			if ($_SESSION['INGRESO']['tipo'] != 1 ) {
				$salidaJSON = array('codRetorno' => '002',
					'form' => USUARIO,
					'Titulo' => 'Advertencia',
					'Mensaje' => SIN_PERMISOS
				);
				$logger->write('codRetorno Usuario:  '.$salidaJSON['codRetorno'] , 6 );
				print json_encode($salidaJSON);
				exit();
			}

			if (!isset($usuario)) {
				$salidaJSON = array('codRetorno' => '004',
					'form' => USUARIO,
					'Mensaje' => PARAM_VACIOS
				);
				$logger->write('codRetorno Usuario:  '.$salidaJSON['codRetorno'] , 6 );
				print json_encode($salidaJSON);
				exit();
			}
				//EJECUTAMOS EL MÉTODO PARA GUARDAR
			$respuesta = $modelo->guardarUsuario($usuario);

			if ($respuesta->CodRetorno == '000') {
				$salidaJSON = array('codRetorno' => $respuesta->CodRetorno,
					'form' => USUARIO,
					'Titulo' => 'Éxito',
					'Mensaje' => $respuesta->Mensaje,
				);
			} else {
				$salidaJSON = array('codRetorno' => $respuesta->CodRetorno,
					'form' => USUARIO,
					'Titulo' => 'Error',
					'Mensaje' => $respuesta->Mensaje,
				);
			}
			$logger->write('codRetorno Usuario:  '.$salidaJSON['codRetorno'] , 6 );
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$logger->write('guardarUsuario: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());	
		}
	}
		//FUNCIÓN PARA VALIDAR USUARIO
	function validaUsuario(){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		parse_str($_POST["parametros"], $_POST);
		try {
			$usuario = trim($_POST['codigo']);
			$matricula = trim($_POST['tipoBusqueda']);

			$modelo = new UsuarioModel();
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => USUARIO,
					'Mensaje' => SESSION_CADUCADA
				);
				$logger->write('codRetorno Usuario:  '.$salidaJSON['codRetorno'] , 6 );
				print json_encode($salidaJSON);
				exit();
			}

			if (!isset($usuario) || empty($matricula)) {
				$salidaJSON = array('codRetorno' => '004',
					'form' => USUARIO,
					'Mensaje' => PARAM_VACIOS
				);
				$logger->write('codRetorno Usuario:  '.$salidaJSON['codRetorno'] , 6 );
				print json_encode($salidaJSON);
				exit();
			}

			$usuarios = $modelo->validaUsuario($usuario); 

			if ($usuarios->CodRetorno == "000") {
				$salidaJSON['form'] = USUARIO;
				if ($matricula != $usuarios->Id) {
					$salidaJSON['codRetorno'] = '001';
					$salidaJSON['Mensaje'] = USUARIO_NO_DISP;
				} else {
					$salidaJSON['codRetorno'] = '000';
				}
			} else if ($usuarios->CodRetorno == '001') {
				$salidaJSON['codRetorno'] = '000';
			} else {
				$salidaJSON = array('codRetorno' => $usuarios->CodRetorno,
					'form' => USUARIO,
					'bus' => '1',
					'Mensaje' => $usuarios->Mensaje,
				);
			}
			$logger->write('codRetorno Usuario:  '.$salidaJSON['codRetorno'] , 6 );	
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$logger->write('validaUsuario: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());	
		}
	}

	function buscarUsuarios(){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		parse_str($_POST["parametros"], $_POST);
		try {
			$usuario = trim($_POST['codigo']);
			$modelo = new UsuarioModel();
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => USUARIO,
					'Mensaje' => SESSION_CADUCADA
				);
				$logger->write('codRetorno Usuario:  '.$salidaJSON['codRetorno'] , 6 );	
				print json_encode($salidaJSON);
				exit();
			}

			$usuarios = $modelo->validaUsuario($usuario); 

			if ($usuarios->CodRetorno == "000") {
				$salidaJSON = array ('codRetorno' => $usuarios->CodRetorno,
					'nombreEmpleado' => $usuarios->NombreEmpleado,
					'tipo_usuario' => $usuarios->Tipo ,
					'matricula' => $usuarios->Id,
					'usuario' => $usuarios->Usuario,
					'status' => $usuarios->Status,
					'form' => USUARIO,
				);
			} else {
				$salidaJSON = array('codRetorno' => $usuarios->CodRetorno,
					'form' => USUARIO,
					'bus' => '1',
					'Mensaje' => $usuarios->Mensaje,
				);
			}
			$logger->write('codRetorno Usuario:  '.$salidaJSON['codRetorno'] , 6 );		
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$logger->write('usuario: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());	
		}
	}

	function cambiarContrasenia(){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
			$res = new ArrayObject();
			$modelo = new UsuarioModel();
			$usuario = json_decode($_POST['cadena']);
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => USUARIO,
					'Mensaje' => SESSION_CADUCADA
				);
				$logger->write('codRetorno Usuario:  '.$salidaJSON['codRetorno'] , 6 );	
				print json_encode($salidaJSON);
				exit();
			}
				//VALIDAMOS EL PERFIL
			if ($_SESSION['INGRESO']['tipo'] != 1 ) {
				$salidaJSON = array('codRetorno' => '002',
					'form' => USUARIO,
					'Titulo' => 'Éxito',
					'Mensaje' => SIN_PERMISOS
				);
				$logger->write('codRetorno Usuario:  '.$salidaJSON['codRetorno'] , 6 );	
				print json_encode($salidaJSON);
				exit();
			}	
				//VALIDAMOS la contraseña
			if ($usuario->contrasenia != $usuario->repContrasenia) {
				$salidaJSON = array('codRetorno' => '001',
					'form' => USUARIO,
					'Titulo' => 'Advertencia',
					'Mensaje' => ERROR_CONTRASEÑA
				);
				$logger->write('codRetorno Usuario:  '.$salidaJSON['codRetorno'] , 6 );	
				print json_encode($salidaJSON);
				exit();
			} 

			$res = $modelo->cambiarPassword($usuario); 

			if ($res->CodRetorno == '000') {
				$salidaJSON = array('codRetorno' => $res->CodRetorno,
					'form' => USUARIO,
					'Titulo' => 'Éxito',
					'Mensaje' => $res->Mensaje,
				);
			} else {
				$salidaJSON = array('codRetorno' => $res->CodRetorno,
					'form' => USUARIO,
					'Titulo' => 'Error',
					'Mensaje' => $res->Mensaje,
				);
			} 
			$logger->write('codRetorno Usuario:  '.$salidaJSON['codRetorno'] , 6 );		
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$logger->write('usuario: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());	
		}
	}

	function validaAdmin(){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => USUARIO,
					'Mensaje' => SESSION_CADUCADA
				);
				$logger->write('codRetorno Usuario:  '.$salidaJSON['codRetorno'] , 6 );	
				print json_encode($salidaJSON);
				exit();
			} else if ($_SESSION['INGRESO']['tipo'] != 1) {
				$salidaJSON = array('codRetorno' => '001',
					'form' => 'Inicio',
					'bus' => '1',
					'Mensaje' => SIN_PERMISOS
				);
				$logger->write('codRetorno Usuario:  '.$salidaJSON['codRetorno'] , 6 );	
				print json_encode($salidaJSON);
				exit();
			} else {
				$salidaJSON = array('codRetorno' => '000');
				$logger->write('codRetorno Usuario:  '.$salidaJSON['codRetorno'] , 6 );	
				print json_encode($salidaJSON);
				exit();
			}
		} catch (Exception $e){
			$logger->write('usuario: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());	
		}
	}
?>