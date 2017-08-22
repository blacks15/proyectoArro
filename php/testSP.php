<?php

	//phpinfo();
	require_once('clases/Conexion.php');
	$db = new Conexion();
	// $p = '';
	// $datos = array($p);

	$result = new ArrayObject();

	$editorial = new ArrayObject();
	$retorno = new ArrayObject();

	$editorial->nombreditorial = '0';
	$editorial->usuario = '0';
	$editorial->status = '5';
	$editorial->bus = '0';

	$sql = "CALL spConsultaProductos(?,?,?,?,@codRetorno,@msg,@numFilas,@msgSQL)";

	$stm = $db->prepare($sql);

	$stm->bindParam(1,$editorial->nombreditorial,PDO::PARAM_INT);
	$stm->bindParam(2,$editorial->usuario,PDO::PARAM_INT);
	$stm->bindParam(3,$editorial->status,PDO::PARAM_INT);
	$stm->bindParam(4,$editorial->bus,PDO::PARAM_INT);

	$stm->execute();
	//var_dump($stm);
	$result->prod = $stm->fetchAll(PDO::FETCH_ASSOC);
	// $retorno->id = $db->lastInsertId();
	$stm->nextRowSet();
	//$stm->closeCursor();
	$result->lib = $stm->fetchAll(PDO::FETCH_ASSOC);
	// $retorno->codRetorno = $db->query('SELECT @CodRetorno AS codRetorno')->fetch(PDO::FETCH_ASSOC);
	// $retorno->Mensaje = $db->query('SELECT @msg AS msg')->fetch(PDO::FETCH_ASSOC);
	// $retorno->msgSQL = $db->query('SELECT @msgSQL AS msgSQL80')->fetch(PDO::FETCH_ASSOC);

	print_r($result);
	
	// $encrypta = encrypta("123456");
	// //$result = $stm->fetchAll(PDO::FETCH_ASSOC);
	
	// print json_encode($encrypta);

	// function encrypta($string){
	// 		// GENERAMOS UN SALT
	// 	$salt = substr(base64_encode(openssl_random_pseudo_bytes('30')), 0, 22);
	// 		//REEMPLAZAMOS + POR PUNTOS
	// 	$salt = strtr($salt, array('+' => '.')); 
	// 		// GENERAMOS EL HASH
	// 	$hash = crypt($string, '$2y$10$' . $salt);

	// 	return $hash;
	// }


?>
