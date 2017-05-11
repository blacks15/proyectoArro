<?php 
require_once('../Clases/Login.php');
require_once('../Clases/Usuario.php');
require_once('../Clases/UsuarioImp.php');
/*
	Clase: Model de Autor
	Autor: Felipe Monzón
	Fecha: 23-ABR-2017
*/
class UsuarioModel {
	public function inicioSesion($usuario,$password){
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo loginM', false, true, true);	
		$objUsuario = new Usuario();
		$login = new Login();
		
		$res = $login->loginUs($usuario,$password); 
		$objUsuario = $res->datos;

		if ($res->Mensaje == 'EXITO') {
			if ($objUsuario->getStatus() == 'DISPONIBLE') {
				$response->CodRetorno = '000';
				$response->NumEmp = $objUsuario->getClave();
				$response->Nombre = $objUsuario->getUsuario();
				$response->Tipo = $objUsuario->getTipoUsuario();
			} else {
				$response->CodRetorno = '001';
				$response->Mensaje = 'Usuario Bloqueado Contacte con el Administrador';
			}
		} else {
			$response->CodRetorno = '002';
			$response->Mensaje = $res->Mensaje;
		}

		return $response;
	}

	public function validaUsuario($usuario){
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo validaUs', false, true, true);	
		try {
			$usuarioImp = new UsuarioImp();
			$objUsuario = new Usuario();

			if (!isset($usuario) ) {
				$retorno->CodRetorno = '004';
				$retorno->Mensaje = 'Parametros Vacios';

				return $retorno;
				exit();
			}

			$res = $usuarioImp->validarUsuario($usuario); 
			$objUsuario = $res->Datos;

			if ($res->CodRetorno == '000') {
				if ($_SESSION['INGRESO']['nombre'] == $objUsuario->getUsuario() ) {
					$response->CodRetorno = '001';
					$response->Mensaje = "El Usuario esta en Uso";
				} else {
					$response->CodRetorno = '000';
					$response->Id = $objUsuario->getClave();
					$response->Usuario = $objUsuario->getUsuario();
					$response->Tipo = $objUsuario->getTipoUsuario();
					$response->NombreEmpleado = $objUsuario->getEmpleado();
					$response->Status = $objUsuario->getStatus();
				}
			} else {
				$response->CodRetorno = $res->CodRetorno ;
				$response->Mensaje = $res->Mensaje;
			}

			return $response;
		} catch (Exception $e) {
			$log->insert('Error buscarUsuario '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}
}
?>