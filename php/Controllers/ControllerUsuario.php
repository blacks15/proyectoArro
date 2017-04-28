<?php 
	header('Content-Type: application/json');
	require_once('../Models/usuarioModel.php');
	include "../Clases/Log.php";
	error_reporting(0);
	session_start();

	login();


	function login($usuario,$password){
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo login', false, true, true);	

		try {
			$usuario = mysql_real_escape_string('felipe');
			$password = '123456';
			$sql = new UsuarioModel();
				//CARGAMOS LOS DATOS
			$usuario = $sql->inicioSesion($usuario,$password);		

			//print json_encode($usuario);
		} catch (Exception $e) {
			$log->insert('Error buscarAutores! '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}
?>