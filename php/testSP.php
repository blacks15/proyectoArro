<?php
	require_once('clases/Conexion.php');
//phpinfo();

	$db = new Conexion();
	$datos = array(0,0,5);
	$result = array();
	$consulta = "CALL spConsultaAutores(?,?,?,@msg,@codRetorno)";
		//CREAMOS LA TRAMA Y ESCRIBIMOS EN EL LOG

		//SE PREPARA Y SE EJECUTA LA CONSULTA
	$stm = $db->prepare($consulta);
		//SE EJECUTA LA CONSULTA CON EL ARRAY DE LOS DATOS Y SE REGRESA EL ÚLTIMO ID INSERTADO
	$stm->execute($datos);
	$result = $stm->fetchAll(PDO::FETCH_ASSOC);
	$stm->closeCursor();
	$res = $db->query('select @msg,@codRetorno')->fetch();
 	var_dump($res);
	
	//$result = $stm->fetchAll(PDO::FETCH_ASSOC);
	
	print json_encode($result);


?>
