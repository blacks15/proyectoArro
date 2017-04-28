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
		$objUsuario = new Usuario();
		if ($this->validaUsuario($nombreUsuario) == false ) {
			$res->Mensaje = 'Usuario y/o Contraseña Incorrecto';
		} else if ($this->validaPassword($nombreUsuario,$password) == false) {
			$res->Mensaje = 'Usuario y/o Contraseña Incorrecto';
		} else {
			$objUsuario->setClave($_SESSION['INGRESO']['id']);
			$objUsuario->setUsuario($_SESSION['INGRESO']['nombre']);
			$objUsuario->setTipoUsuario($_SESSION['INGRESO']['tipo']);
			
			$res->Mensaje = 'EXITO';
			$res->datos = $objUsuario;	
			var_dump($objUsuario);
		}

		return $res;
	}
		//FUNCIÓN PARA VALIDAR EL USUARIO
	private function validaUsuario($usuario){
		$res = false;
		$datos = array($usuario);

		$sql = "SELECT nombre_usuario FROM  usuarios WHERE nombre_usuario= ?";

		$stm = SQL($sql,$datos); 

		if ($stm->rowCount() > 0) {
			$res = true;
		} else {
			$res = false;
		}

		return $res;
	}
		//FUNCIÓN PARA VALIDAR EL PASSWORD
	private function validaPassword($usuario,$password){
		$res = false;
		$password   = filter_var($password, FILTER_SANITIZE_STRING,FILTER_FLAG_NO_ENCODE_QUOTES|FILTER_FLAG_ENCODE_AMP);
		$datos = array($usuario);

		if (empty($password)) {
			$res = false;
		} else {
			$sql = "SELECT nombre_usuario,tipo_usuario,matricula_empleado,password FROM usuarios WHERE nombre_usuario = ?";

			$stm = SQL($sql,$datos);

			if ($stm->rowCount() > 0) {
				$row = $stm->fetch(PDO::FETCH_ASSOC);

				if ( crypt($password,$row['password']) == $row['password'] ) {
					$ip = $this->IPuser();
					$hora = time();

					$_SESSION['INGRESO'] = array(
						'Id' => $row['matricula_empleado'],
						'tipo' => $row['tipo_usuario'],
						'Nombre' => $row['nombre_usuario'],
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