<?php 
require_once('funciones.php');
require_once('Usuario.php');
require_once('UsuarioImp.php');
session_start();
/*
	Clase: Login
	Autor: Felipe Monzón
	Fecha: 26-ABR-2017
*/
class Login {
	public function loginUs($nombreUsuario,$password){
		$nombreUsuario = limpiarCadena($nombreUsuario);
		$password = limpiarCadena($password);
		try {
			$objUsuario = new Usuario();
			$res = new ArrayObject();

			if (!isset($_SESSION['intentos']) ) {
				$_SESSION['intentos'] = 0; 
				$_SESSION['usuario'] = ""; 
			} else if ($_SESSION['intentos'] > 3 && $_SESSION['usuario'] == $nombreUsuario) {
				$this->bloquearUsuario($nombreUsuario);
				$res->Mensaje = USUARIO_BLOQUEADO;
				return $res;
				exit();
			}
				//VALIDAMOS USUARIO Y PASSWORD
			if ($this->validaUsuario($nombreUsuario) == false ) {
				$res->Mensaje = ERROR_USUARIO;
				$_SESSION['intentos'] += 1; 
				$_SESSION['usuario'] = $nombreUsuario;
			} else if ($this->validaPassword($password) == false) {
				$res->Mensaje = ERROR_USUARIO;
				$_SESSION['intentos'] += 1; 
				$_SESSION['usuario'] = $nombreUsuario;
			} else {
				$objUsuario->setClave($_SESSION['INGRESO']['id']);
				$objUsuario->setUsuario($_SESSION['INGRESO']['nombre']);
				$objUsuario->setTipoUsuario($_SESSION['INGRESO']['tipo']);
				$objUsuario->setStatus($_SESSION['INGRESO']['status']);
				
				$res->Mensaje = 'EXITO';
				$res->datos = $objUsuario;	
			}

			return $res;
		} catch (Exception $e) {
			$logger->write('Login '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());					
		}
	}
		//FUNCIÓN PARA VALIDAR EL USUARIO
	private function validaUsuario($usuario){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {	
			$respuesta = false;		
			$usuarioIMP = new UsuarioImp();
			$isValido = $usuarioIMP->validarUsuario($usuario);

			if ($isValido['codRetorno'] == '000') {
				$_SESSION['usuario'] = $isValido['Datos'];
				$respuesta = true;
			}

			return $respuesta;
		} catch (Exception $e) {
			$logger->write('Login '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());		
		}
	}
		//FUNCIÓN PARA VALIDAR EL PASSWORD
	private function validaPassword($password){
		try {
			$isValido = false;
			$objUsuario = new Usuario();
			$password = filter_var($password,FILTER_SANITIZE_STRING,FILTER_FLAG_NO_ENCODE_QUOTES|FILTER_FLAG_ENCODE_AMP);

			$objUsuario->setClave($_SESSION['usuario']['matricula_empleado']);
			$objUsuario->setUsuario($_SESSION['usuario']['nombre_usuario']);
			$objUsuario->setPassword( $_SESSION["usuario"]['password'] );
			$objUsuario->setTipoUsuario($_SESSION['usuario']['tipo_usuario']);
			$objUsuario->setStatus($_SESSION['usuario']['status']);
			unset($_SESSION["usuario"]);

			if (empty($password)) {
				$isValido = false;
			} else {
				if ( crypt($password,$objUsuario->getPassword() ) == $objUsuario->getPassword()  ) {
					$ip = $this->IPuser();
					$hora = time();

					$_SESSION['INGRESO'] = array(
						'id' => $objUsuario->getClave(),
						'tipo' => $objUsuario->getTipoUsuario(),
						'nombre' => $objUsuario->getUsuario(),
						'status' => $objUsuario->getStatus(),
						'hora' => $hora,
						'ip' => $ip,
					); 

					$isValido = true;
				} else {
					$isValido = false;
					$objUsuario = null;
				}
			}
			return $isValido;
		} catch (Exception $e) {
			$logger->write('Login '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());	
		}
	}
		//BLOQUEAR USUARIO
	private function bloquearUsuario($usuario){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
			$isValido = true;
			$db = new Conexion();
			$usuario = filter_var($usuario, FILTER_SANITIZE_STRING,FILTER_FLAG_NO_ENCODE_QUOTES|FILTER_FLAG_ENCODE_AMP);

			$sql = SP_BLOQUEA_USUARIO;;

			$stm = $db->prepare($sql);	
			$stm->bindParam(':nombreUsuario',$usuario,PDO::PARAM_STR);

			$stm->execute();
			$stm->closeCursor();
			
			$error = $stm->errorInfo();

			if ($error[2] != "") {
				$logger->write('spBloqueaUsuario: '.$error[2], 3 );
			}

			$retorno = $db->query('SELECT @codRetorno AS codRetorno, @msg AS Mensaje, @msgSQL AS msgSQL80')->fetch(PDO::FETCH_ASSOC);
			$logger->write('codRetorno spBloqueaUsuario:  '.$retorno['codRetorno'] ,6 );

			if ($retorno['msgSQL80'] != '' || $retorno['msgSQL80'] != null) {
				$logger->write('spBloqueaUsuario: '.$retorno['msgSQL80'] , 3 );
			}

			if ($retorno['codRetorno'] != '000' || $retorno['codRetorno'] == "" ) {
				$isValido = false;
				return $isValido;
			}

			return $isValido;
		} catch (Exception $e) {
			$logger->write('Login '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());	
		}
	}
		//Retorna el IP de usuario/
	private function IPuser() {
		$retorno = "";

		if (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
			$retorno = $_SERVER['HTTP_X_FORWARDED_FOR']; 
		} else if (!empty($_SERVER['HTTP_CLIENT_IP'])){
			$retorno = $_SERVER['HTTP_CLIENT_IP']; 
		} else 	if(!empty($_SERVER['REMOTE_ADDR'])){
			$retorno = $_SERVER['REMOTE_ADDR'];
		}

		return $retorno;
	}
}
?>