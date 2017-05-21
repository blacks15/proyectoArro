<?php 
	header('Content-Type: application/json');
	require_once('../Models/usuarioModel.php');
	include "../Clases/Log.php";
	error_reporting(0);
	session_start();

	$opc = $_POST["opc"];
	switch ($opc) {
		case 'guardar':
			guardarUsuario();
		break;

		case 'validaUsuario':
			validaUsu();
		break;

		case 'buscar':
			buscarUsuarios();
		break;

		case 'eliminar':
			eliminarUsuario();
		break;

		case 'cambiarContrasenia':
			cambiarContrasenia();
		break;

		case 'isAdmin':
			validaAdmin();
		break;
	}

	function guardarUsuario(){
		$log = new Log("log", "../../log/");
		$bandera = trim($_POST['bandera']);
		parse_str($_POST["cadena"], $_POST);
		$log->insert('Entro metodo guardarUsuario', false, true, true);	
		try {
			$status = "";
			$sql = new UsuarioModel();
				//CICLO PARA LLENAR VARIABLES POR POST
			foreach ($_POST as $clave => $valor) {
				${$clave} = trim($_POST[$clave]);
			}
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => 'Usuario',
					'Mensaje' => 'Sesión Caducada'
				);
				$log->insert('Usuario CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);
				print json_encode($salidaJSON);
				exit();
			}
				//VALIDAMOS LA SESSION
			if ($_SESSION['INGRESO']['tipo'] != 1 ) {
				$salidaJSON = array('codRetorno' => '002',
					'form' => 'Usuario',
					'Titulo' => 'Éxito',
					'Mensaje' => 'No Cuenta con los Permisos Suficientes'
				);
				$log->insert('Usuario CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);
				print json_encode($salidaJSON);
				exit();
			}
				//VALIDAMOS EL CÓDIGO
			if ($codigoEmpleado == "") {
				$codigoEmpleado = 0;
			}	
				//VALIDAMOS EL STATUS
			if ($status == "") {
				$status = 'DISPONIBLE';
			}
				//EJECUTAMOS EL MÉTODO PARA GUARDAR
			$res = $sql->guardarUsuario($codigoEmpleado,$nombreUsuario,$contrasenia,$tipo,$status,$bandera);

			if ($res->CodRetorno == '000') {
				$salidaJSON = array('codRetorno' => $res->CodRetorno,
					'form' => 'Usuario',
					'Titulo' => 'Éxito',
					'Mensaje' => $res->Mensaje,
				);
			} else {
				$salidaJSON = array('codRetorno' => $res->CodRetorno,
					'form' => 'Usuario',
					'Titulo' => 'Error',
					'Mensaje' => $res->Mensaje,
				);
			}

			$log->insert('Usuario CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$log->insert('Error guardarUsuario '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}
		//FUNCIÓN PARA VALIDAR USUARIO
	function validaUsu(){
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo validaUsu', false, true, true);	
		parse_str($_POST["parametros"], $_POST);
		try {
			$usuario = trim($_POST['codigo']);
			$matricula = trim($_POST['tipoBusqueda']);

			$sql = new UsuarioModel();
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => 'Usuario',
					'Mensaje' => 'Sesión Caducada'
				);
				$log->insert('Usuario CodRetorno: '.$salidaJSON['codRetorno'] , false, true, true);
				print json_encode($salidaJSON);
				exit();
			}

			if (!isset($usuario) || empty($matricula)) {
				$salidaJSON = array('codRetorno' => '004',
					'form' => 'Usuario',
					'Mensaje' => 'Parametros Vacios'
				);
				$log->insert('Usuario CodRetorno: '.$salidaJSON['codRetorno'] , false, true, true);
				print json_encode($salidaJSON);
				exit();
			}

			$usuarios = $sql->validaUsuario($usuario); 

			if ($usuarios->CodRetorno == "000") {
				$salidaJSON['form'] = 'Usuario';
				if ($matricula != $usuarios->Id) {
					$salidaJSON['codRetorno'] = '001';
					$salidaJSON['Mensaje'] = 'Usuario no disponible';
				} else {
					$salidaJSON['codRetorno'] = '000';
				}
			} else if ($usuarios->CodRetorno == '001') {
				$salidaJSON['codRetorno'] = '000';
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
			$log->insert('Error validaUsu '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
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
					'Mensaje' => 'Sesión Caducada'
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
					'status' => $usuarios->Status,
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

	function cambiarContrasenia(){
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo cambiarContrasenia', false, true, true);	
		parse_str($_POST["cadena"], $_POST);
		try {
			$usuario = trim($_POST['codigo']);
			$sql = new UsuarioModel();
				//CICLO PARA LLENAR VARIABLES POR POST
			foreach ($_POST as $clave => $valor) {
				${$clave} = trim($_POST[$clave]);
			}
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => 'Usuario',
					'Mensaje' => 'Sesión Caducada'
				);
				$log->insert('Usuario CodRetorno: '.$salidaJSON['codRetorno'] , false, true, true);
				print json_encode($salidaJSON);
				exit();
			}
				//VALIDAMOS EL PERFIL
			if ($_SESSION['INGRESO']['tipo'] != 1 ) {
				$salidaJSON = array('codRetorno' => '002',
					'form' => 'Usuario',
					'Titulo' => 'Éxito',
					'Mensaje' => 'No Cuenta con los Permisos Suficientes'
				);
				$log->insert('Usuario CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);
				print json_encode($salidaJSON);
				exit();
			}	
				//VALIDAMOS la contraseña
			if ($contrasenia != $repContrasenia) {
				$salidaJSON = array('codRetorno' => '001',
					'form' => 'Usuario',
					'Titulo' => 'Advertencia',
					'Mensaje' => 'La contraeña y la confirmación de la contraseña no son iguales',
				);
				$log->insert('Usuario CodRetorno: '.$salidaJSON['codRetorno'] , false, true, true);
				print json_encode($salidaJSON);
				exit();
			} 

			$res = $sql->cambiarPassword($codigoEmpleado,$nombreUsuario,$contrasenia); 

			if ($res->CodRetorno == '000') {
				$salidaJSON = array('codRetorno' => $res->CodRetorno,
					'form' => 'Usuario',
					'Titulo' => 'Éxito',
					'Mensaje' => $res->Mensaje,
				);
			} else {
				$salidaJSON = array('codRetorno' => $res->CodRetorno,
					'form' => 'Usuario',
					'Titulo' => 'Error',
					'Mensaje' => $res->Mensaje,
				);
			} 

			$log->insert('Usuario CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$log->insert('Error cambiarContrasenia '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}

	function validaAdmin(){
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo validaAdmin', false, true, true);	
		try {
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => 'Usuario',
					'Mensaje' => 'Sesión Caducada'
				);
				$log->insert('Usuario CodRetorno: '.$salidaJSON['codRetorno'] , false, true, true);
				print json_encode($salidaJSON);
				exit();
			} else if ($_SESSION['INGRESO']['tipo'] != 1) {
				$salidaJSON = array('codRetorno' => '001',
					'form' => 'Inicio',
					'bus' => '1',
					'Mensaje' => 'No Cuenta con los permisos necesarios'
				);
				$log->insert('Usuario CodRetorno: '.$salidaJSON['codRetorno'] , false, true, true);
				print json_encode($salidaJSON);
				exit();
			} else {
				$salidaJSON = array('codRetorno' => '000');
				$log->insert('Usuario CodRetorno: '.$salidaJSON['codRetorno'] , false, true, true);
				print json_encode($salidaJSON);
				exit();
			}
		} catch (Exception $e){
			$log->insert('Error validaAdmin '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}
?>