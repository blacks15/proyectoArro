<?php 
	header('Content-Type: application/json');
	require_once('../Models/autorModel.php');
	include "../Clases/Log.php";
	error_reporting(0);
	buscarAutores();

	function buscarAutores(){
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo buscarAutor!', false, true, true);	
		try {
			$sql = new AutorModel();
			$autores = $sql->cargarAutores(0,0);

			print json_encode($autores);
		} catch (Exception $e) {
			$log->insert('Error buscarAutores! '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}
?>