<?php 
require_once('funciones.php');
require_once('Usuario.php');
session_start();
/*
	Clase: Model de Usuario
	Autor: Felipe Monzón
	Fecha: 26-ABR-2017
*/
class Login {
	public function loginUs($nombreUsuario,$password){
		$nombreUsuario = limpiarCadena($nombreUsuario);
		$password = limpiarCadena($password);
		try {
			$objUsuario = new Usuario();
			if ($this->validaUsuario($nombreUsuario) == false ) {
				$res->Mensaje = 'Usuario y/o Contraseña Incorrecto';
			} else if ($this->validaPassword($nombreUsuario,$password) == false) {
				$res->Mensaje = 'Usuario y/o Contraseña Incorrecto';
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
			$log->insert('Error Login '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());					
		}
	}
		//FUNCIÓN PARA VALIDAR EL USUARIO
	private function validaUsuario($usuario){
		try {			
			$res = false;
			$usuario = filter_var($usuario, FILTER_SANITIZE_STRING,FILTER_FLAG_NO_ENCODE_QUOTES|FILTER_FLAG_ENCODE_AMP);
			$datos = array($usuario);

			$sql = "SELECT nombre_usuario FROM  usuarios WHERE nombre_usuario = ?";

			$stm = SQL($sql,$datos); 

			if ($stm->rowCount() > 0) {
				$res = true;
			} else {
				$res = false;
			}

			return $res;
		} catch (Exception $e) {
			$log->insert('Error validaUsu '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());		
		}
	}
		//FUNCIÓN PARA VALIDAR EL PASSWORD
	private function validaPassword($usuario,$password){
		try {
			$res = false;
			$usuario = filter_var($usuario, FILTER_SANITIZE_STRING,FILTER_FLAG_NO_ENCODE_QUOTES|FILTER_FLAG_ENCODE_AMP);
			$password = filter_var($password,FILTER_SANITIZE_STRING,FILTER_FLAG_NO_ENCODE_QUOTES|FILTER_FLAG_ENCODE_AMP);
			$datos = array($usuario);

			if (empty($password)) {
				$res = false;
			} else {
				$sql = "SELECT nombre_usuario,tipo_usuario,matricula_empleado,password,status FROM usuarios WHERE nombre_usuario = ?";

				$stm = SQL($sql,$datos);

				if ($stm->rowCount() > 0) {
					$row = $stm->fetch(PDO::FETCH_ASSOC);

					if ( crypt($password,$row['password']) == $row['password'] ) {
						$ip = $this->IPuser();
						$hora = time();

						$_SESSION['INGRESO'] = array(
							'id' => $row['matricula_empleado'],
							'tipo' => $row['tipo_usuario'],
							'nombre' => $row['nombre_usuario'],
							'status' => $row['status'],
							'hora' => $hora,
							'ip' => $ip,
						); 

						$res = true;
					}
				} else {
					$res = false;
				}
			}
			return $res;
		} catch (Exception $e) {
			$log->insert('Error validaUsu '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}
/*
 * Retorna el IP de usuario
 * @return [string] [devuel la io del usuario]
 */
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