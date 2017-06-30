<?php 
	require_once('Conexion.php');
		//FUNCIÓN PARA INSERTAR DATOS
	function executeSP($sql,$datos){
		$log = new Log("log", "../../log/");
		try {
			$db = new Conexion();
				//CREAMOS LA TRAMA Y ESCRIBIMOS EN EL LOG
			$trama = debug($sql,$datos);
			$log->insert('trama: '.$trama, false, true, true);
				//SE PREPARA Y SE EJECUTA LA sql
			$stm = $db->prepare($sql);
				//SE EJECUTA LA CONSULTA CON EL ARRAY DE LOS DATOS Y SE REGRESA EL ÚLTIMO ID INSERTADO
			$stm->execute($datos);
			$error = $stm->errorInfo();
			$res->datos = $stm->fetchAll(PDO::FETCH_ASSOC);
				//ESCRIBIMOS ERROR EN EL LOG
			if ($error[2] != "") {
				$res->codRetorno[0] = '002';
				$res->Mensaje[0] = 'Ocurrio un Error';
				$log->insert('Error SP: '.$error[2], false, true, true);	
				return $res;
			}
				//PERMITE EJECUTAR LA SEGUNDA CNSULTA
			$stm->closeCursor();
			
			$res->codRetorno = $db->query('select @CodRetorno')->fetch();
			$res->Mensaje = $db->query('select @msg')->fetch();
			$res->numFilas = $db->query('select @numFilas')->fetch();
			$log->insert('codRetorno SP: '.$res->codRetorno[0], false, true, true);	
				//CERRAMOS LA CONEXIÓN
			$db = null;
				//RETORNAMOS LA RESPUESTA
			return $res;
		} catch (PDOException $e) {
			$log->insert('Error SP' .$e->getMessage(), false, true, true);
		}
	}	
		//FUNCIÓN PARA INSERTAR DATOS
	function SQL($sql,$datos){ 
		$log = new Log("log", "../../log/");
		try {
			$db = new Conexion();
				//CREAMOS LA TRAMA Y ESCRIBIMOS EN EL LOG
			$trama = debug($sql,$datos);
			$log->insert('trama: '.$trama, false, true, true);
				//SE PREPARA Y SE EJECUTA LA sql
			$stm = $db->prepare($sql);
				//SE EJECUTA LA CONSULTA CON EL ARRAY DE LOS DATOS Y SE REGRESA EL ÚLTIMO ID INSERTADO
			$stm->execute($datos);
				//SE TRAEN LOS DATOS Y EL ERROR EN CASO DE HABER
			$error = $stm->errorInfo();
				//ESCRIBIMOS ERROR EN EL LOG
			if ($error[2] != "") {
				$log->insert('Error SQL: '.$error[2], false, true, true);	
			}
				//CERRAMOS LA CONEXIÓN
			$db = null;
				//RETORNAMOS LA RESPUESTA
			return $stm;
		} catch (Exception $e) {
			$log->insert('Error SQL' .$e->getMessage(), false, true, true);
		}
	}
		//FUNCIÓN PARA CREAR LISTA DE PAGINACIÓN
	function paginacion($numFilas,$tamañoPagina,$paginaActual){
			//OBTENEMOS EL TOTAL DE PÁGINAS
		$total_paginas  = ceil($numFilas/$tamañoPagina);
			//CREAMOS EL APARTADO ANTERIOR
		if ($paginaActual > 1){
			$lista = $lista.'<li><a class="paginate" href="#" data="'.($paginaActual-1).'">Anterior</a></li>';
		}
			//CREAMOS LA PAGINACION
		for ($i = 1; $i <= $total_paginas ; $i++){
			if ($i == $paginaActual) {
				$lista = $lista.'<li class="active"><a>'.$i.'</a></li>';
			} else {
				$lista = $lista.'<li><a class="paginate" href="#" data="'.$i.'">'.$i.'</a></li>';
			}
		}
			//CREAMOS EL APARTADO SIGUIENTE
		if ($paginaActual < $total_paginas ){
			$lista = $lista.'<li><a class="paginate" href="#" data="'.($paginaActual + 1).'">Siguiente</a></li>';
		}
			//RETORNAMOS LA LISTA
		return $lista;
	}	
		//FUNCIÓN ENCRIPTA
	function encrypta($string){
			// GENERAMOS UN SALT
		$salt = substr(base64_encode(openssl_random_pseudo_bytes('30')), 0, 22);
			//REEMPLAZAMOS + POR PUNTOS
		$salt = strtr($salt, array('+' => '.')); 
			// GENERAMOS EL HASH
		$hash = crypt($string, '$2y$10$' . $salt);

		return $hash;
	}
		//LIMPIA LA CADENA DE CARACTERES ESPECIALES
	function limpiarCadena($texto){
		$textoLimpio = preg_replace('([^A-Za-z0-9\.\-\_])', '', $texto);	     					
		return $textoLimpio;
	}
		//FUNCIÓN DEBUG
	function debug ($statement, array $params = []) {
		$statement = preg_replace_callback (
			'/[?]/',
			function ($k) use ($params) {
				static $i = 0;
				return sprintf("'%s'", $params[$i++]);
			},
			$statement
		);
		return $statement;
	}	
?>