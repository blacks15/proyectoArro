<?php
	require_once('clases/Conexion.php');
//phpinfo();

	$db = new Conexion();
	$p = '';
	$datos = array($p);
	$result = array();
	$consulta = "CALL spTest(?,@msg)";
		//CREAMOS LA TRAMA Y ESCRIBIMOS EN EL LOG

		//SE PREPARA Y SE EJECUTA LA CONSULTA
	$stm = $db->prepare($consulta);
		//SE EJECUTA LA CONSULTA CON EL ARRAY DE LOS DATOS Y SE REGRESA EL ÚLTIMO ID INSERTADO
	$stm->execute($datos);
	$result = $stm->fetchAll(PDO::FETCH_ASSOC);
	$stm->closeCursor();
	$res = $db->query('select @msg')->fetch();
 	var_dump($res);
	
	//$result = $stm->fetchAll(PDO::FETCH_ASSOC);
	
	print json_encode($result);


?>
