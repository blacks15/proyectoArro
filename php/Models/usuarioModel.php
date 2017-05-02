<?php 
require_once('../Clases/Login.php');
require_once('../Clases/Usuario.php');
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
}



?>