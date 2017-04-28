<?php 
require_once('../Clases/Login.php');
/*
	Clase: Model de Autor
	Autor: Felipe Monzón
	Fecha: 23-ABR-2017
*/
class UsuarioModel {
	public function inicioSesion($usuario,$password){
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo loginM', false, true, true);	

		$login = new Login();
		
		$res = $login->loginUs($usuario,$password); 

		var_dump($res);
	}
}



?>