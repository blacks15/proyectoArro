<?php 
	include "Clases/Log.php";
	header('Content-Type: application/json');
	error_reporting(0);

	$log = new Log("log", "../log/");
		//SE RECIBE EL NOMBRE DE LA IMÁGEN, LA CARPETA DE GUARDADO CON SUS RESPECTIVOS DATOS
	$name = trim($_POST['name']);
	$upload_folder = '../images';
	$nombre_archivo = $_FILES['archivo']['name'];
	$tipo_archivo = $_FILES['archivo']['type'];
	$tamano_archivo = $_FILES['archivo']['size'];
	$tmp_archivo = $_FILES['archivo']['tmp_name'];
		//SE AÑADE EL PUNTO DESPÚES DEL NOMBRE Y LA EXTENCIÓN DE LA IMÁGEN
	$tipo = stristr($nombre_archivo,'.');
	$nombre = $name.$tipo;
		//SE CONVIERTE A MINÚSCULAS Y SE QUITAN LOS ESPACIOS EN BLANCO 
	$nombre = strtolower($nombre);
	$nombre = rtrim($nombre);
	$nombre = utf8_decode($nombre);
	$archivador = $upload_folder . '/' . $nombre;
	$log->insert('imagen '.$nombre, false, true, true);
		//SE VALIDA SI SE SUBIO CORRECTAMENTE LA IMÁGEN
	if (!move_uploaded_file($tmp_archivo, $archivador)) {
		$return = array('codRetorno' => '001');
	} else {
		$return = array('codRetorno' => '000');
	}
	print(json_encode($return));
 ?>