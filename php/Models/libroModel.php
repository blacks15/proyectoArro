<?php 
require_once('../Clases/Conexion.php');
require_once('../Clases/Combo.php');
session_start();
/*	
	Clase: Model Libro
	Autor: Felipe Monzón
	Fecha: 30-ABR-2017
*/
class LibroModel {
	// public function libroFiltro(){
	// 	try {
	// 		$res->autores = mostrar_autor();
	// 		$res->editoriales = mostrar_editorial();

	// 		return $res; 
	// 	} catch (Exception $e) {
	// 		$log->insert('Error libroFiltro '.$e->getMessage(), false, true, true);	
	// 		print('Ocurrio un Error'.$e->getMessage());
	// 	}
	// }

	public function guardarProducto($producto){
		$log = new Log("log", "../../log/");
		try {
			$sql = "";
			$db = new Conexion();
			$libro = new ArrayObject();
			$retorno = new ArrayObject();
				//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
			if (empty($producto) ) {
				$retorno->CodRetorno = '004';
				$retorno->Mensaje = 'Parametros Vacios';

				return $retorno;
			}

			if ($producto->tipo == 'libro') {
				$libro->codigoLibro = $producto->codigoLibro;
				$libro->nombreLibro = $producto->nombreLibro;
				$libro->isbn = $producto->isbn;
				$libro->codigoAutor = $producto->codigoAutor;
				$libro->autor = $producto->autor;
				$libro->codigoEditorial = $producto->codigoEditorial;
				$libro->editorial = $producto->editorial;
				$libro->descripcionLibro = $producto->descripcionLibro;
				$libro->usuario = $producto->usuario;
				$libro->status = $producto->status;
				$libro->rutaIMG	= $producto->rutaIMG;	

				$respLibro = $this->guardarLibro($libro);

				if ( $respLibro['codRetorno'] == '002' ) {
					$retorno->CodRetorno = $respLibro['codRetorno'];
					$retorno->Mensaje = $respLibro['msg'];

					return $retorno;
				}
			}

			$sql = "CALL spInsUpdProducto(?,?,?,?,?,?,?,?,?,?,?,?,@codRetorno,@msg,@msgSQL)";

			$stm = $db->prepare($sql);
			$stm->bindParam(1,$libro->codigoLibro,PDO::PARAM_INT);
			$stm->bindParam(2,$libro->nombreLibro,PDO::PARAM_STR);
			$stm->bindParam(3,$libro->isbn,PDO::PARAM_INT);
			$stm->bindParam(4,$libro->codigoAutor,PDO::PARAM_INT);
			$stm->bindParam(5,$libro->codigoEditorial,PDO::PARAM_INT);
			$stm->bindParam(6,$libro->descripcionLibro,PDO::PARAM_STR);
			$stm->bindParam(7,$libro->usuario,PDO::PARAM_STR);
			$stm->bindParam(8,$libro->status,PDO::PARAM_STR);
			$stm->bindParam(9,$libro->rutaIMG,PDO::PARAM_STR);

			$stm->execute();
			$stm->closeCursor();
			
			$retorno = $db->query('SELECT @codRetorno AS codRetorno, @msg AS msg, @msgSQL AS msgSQL80, @id AS id')->fetch(PDO::FETCH_ASSOC);
			$error = $stm->errorInfo();

			if ($error[2] != "") {
				$log->insert('Error spInsUpdLibro: ' .$error[2] , false, true, true);
			}

			$log->insert('codRetorno SP: ' .$retorno['codRetorno'] , false, true, true);	

			if ($retorno['msgSQL80'] != '' || $retorno['msgSQL80'] != null) {
				$log->insert('Error spInsUpdLibro: '.$retorno['msgSQL80'], false, true, true);	
			}

			$db = null;
			

		} catch (PDOException $e){
			$log->insert('Error guardarLibro '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
		}
	}

	private function guardarLibro($libro){
		$log = new Log("log", "../../log/");
		try {
			$db = new Conexion();
			$editorial = new ArrayObject();
			$autor = new ArrayObject();
			$retorno = new ArrayObject();
				//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
			if (empty($libro) ) {
				$retorno->CodRetorno = '004';
				$retorno->Mensaje = 'Parametros Vacios';

				return $retorno;
			}

			$editorial->codigoEditorial = $libro->codigoEditorial;
			$editorial->nombreditorial = strtolower($libro->editorial);
			$editorial->usuario = $_SESSION['INGRESO']['nombre'];
			$editorial->status = 'DISPONIBLE';

			$autor->codigoAutor = $libro->codigoAutor;
			$autor->nombreAutor = strtolower($libro->autor) ;
			$autor->usuario = $_SESSION['INGRESO']['nombre'];
			$autor->status = 'DISPONIBLE';

			$respEdit = $this->guardarEditorial($editorial);

			if ( $respEdit['codRetorno'] == '002' ) {
				$retorno->CodRetorno = $respEdit['codRetorno'];
				$retorno->Mensaje = $respEdit['msg'];

				return $retorno;
			} else if ($respEdit['codRetorno'] == '001') {
				$libro->codigoEditorial = $respEdit['id'];
			}

			$respAutor = $this->guardarAutor($autor);

			if ( $respAutor['codRetorno'] == '002' ) {
				$retorno->CodRetorno = $respAutor['codRetorno'];
				$retorno->Mensaje = $respAutor['msg'];

				return $retorno;
			} else if ($respAutor['codRetorno'] == '001') {
				$libro->codigoAutor = $respAutor['id'];
			}

			$sql = "CALL spInsUpdLibro(?,?,?,?,?,?,?,?,?,@codRetorno,@msg,@msgSQL,@id)";

			$stm = $db->prepare($sql);
			$stm->bindParam(1,$libro->codigoLibro,PDO::PARAM_INT);
			$stm->bindParam(2,$libro->nombreLibro,PDO::PARAM_STR);
			$stm->bindParam(3,$libro->isbn,PDO::PARAM_INT);
			$stm->bindParam(4,$libro->codigoAutor,PDO::PARAM_INT);
			$stm->bindParam(5,$libro->codigoEditorial,PDO::PARAM_INT);
			$stm->bindParam(6,$libro->descripcionLibro,PDO::PARAM_STR);
			$stm->bindParam(7,$libro->usuario,PDO::PARAM_STR);
			$stm->bindParam(8,$libro->status,PDO::PARAM_STR);
			$stm->bindParam(9,$libro->rutaIMG,PDO::PARAM_STR);

			$stm->execute();
			$stm->closeCursor();
			
			$retorno = $db->query('SELECT @codRetorno AS codRetorno, @msg AS msg, @msgSQL AS msgSQL80, @id AS id')->fetch(PDO::FETCH_ASSOC);
			$error = $stm->errorInfo();

			if ($error[2] != "") {
				$log->insert('Error spInsUpdLibro: ' .$error[2] , false, true, true);
			}

			$log->insert('codRetorno SP: ' .$retorno['codRetorno'] , false, true, true);	

			if ($retorno['msgSQL80'] != '' || $retorno['msgSQL80'] != null) {
				$log->insert('Error spInsUpdLibro: '.$retorno['msgSQL80'], false, true, true);	
			}

			$db = null;

			return $retorno; 
		} catch (PDOException $e) {
			$log->insert('Error guardarLibro '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
		}
	}

	private function guardarAutor($autor){
		$log = new Log("log", "../../log/");
		try {
			$retorno = new ArrayObject();
			$db = new Conexion();

			$sql = "CALL spInsUpdAutor(:codigoAutor,:nombreAutor,:usuario,:status,@codRetorno,@msg,@msgSQL,@id)";

			$stm = $db->prepare($sql);
			
			$stm->bindParam(':codigoAutor',$autor->codigoAutor,PDO::PARAM_INT);
			$stm->bindParam(':nombreAutor',$autor->nombreAutor,PDO::PARAM_STR);
			$stm->bindParam(':usuario',$autor->usuario,PDO::PARAM_STR);
			$stm->bindParam(':status',$autor->status,PDO::PARAM_STR);

			$stm->execute();			
			$stm->closeCursor();
			
			$retorno = $db->query('SELECT @CodRetorno AS codRetorno, @msg AS msg, @msgSQL AS msgSQL80, @id AS id')->fetch(PDO::FETCH_ASSOC);
			$error = $stm->errorInfo();

			if ($error[2] != "") {
				$log->insert('Error spInsUpdLibro: ' .$error[2] , false, true, true);
			}

			$log->insert('codRetorno spInsUpdAutor: ' .$retorno['codRetorno'] , false, true, true);	

			if ($retorno['msgSQL80'] != '' || $retorno['msgSQL80'] != null) {
				$log->insert('Error spInsUpdAutor: '.$retorno['msgSQL80'], false, true, true);	
			}

			$db = null;

			return $retorno; 
		} catch (Exception $e) {
			$log->insert('Error guardarAutor '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
		}
	}

	private function guardarEditorial($editorial){
		$log = new Log("log", "../../log/");
		try {
			$retorno = new ArrayObject();
			$db = new Conexion();

			$sql = "CALL spInsUpdEditorial(:codigoEditorial,:nombreEditorial,:usuario,:status,@codRetorno,@msg,@msgSQL,@id)";

			$stm = $db->prepare($sql);
			
			$stm->bindParam(':codigoEditorial',$editorial->codigoEditorial,PDO::PARAM_INT);
			$stm->bindParam(':nombreEditorial',$editorial->nombreditorial,PDO::PARAM_STR);
			$stm->bindParam(':usuario',$editorial->usuario,PDO::PARAM_STR);
			$stm->bindParam(':status',$editorial->status,PDO::PARAM_STR);

			$stm->execute();			
			$stm->closeCursor();
			
			$retorno = $db->query('SELECT @CodRetorno AS codRetorno, @msg AS msg, @msgSQL AS msgSQL80, @id AS id')->fetch(PDO::FETCH_ASSOC);
			$error = $stm->errorInfo();

			if ($error[2] != "") {
				$log->insert('Error spInsUpdLibro: ' .$error[2] , false, true, true);
			}

			$log->insert('codRetorno spInsEditorial: ' .$retorno['codRetorno'] , false, true, true);	

			if ($retorno['msgSQL80'] != '' || $retorno['msgSQL80'] != null) {
				$log->insert('Error spInsEditorial: '.$retorno['msgSQL80'], false, true, true);	
			}

			$db = null;

			return $retorno; 
		} catch (Exception $e) {
			$log->insert('Error guardarEditorial '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
		}
	}

	// public function cargarLibros($codigo,$inicio,$paginaActual,$tipobusqueda){
	// 	$libros = new ArrayObject();
	// 	$i = 0;
	// 	try {
	// 			//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
	// 		if ($codigo == "" || $paginaActual == "" || $tipobusqueda == "") {
	// 			$retorno->CodRetorno = '004';
	// 			$retorno->Mensaje = 'Parametros Vacios';

	// 			return $retorno;
	// 			exit();
	// 		}

	// 		$datos = array($codigo,$inicio,5,$tipobusqueda);
	// 		$consulta = "CALL spConsultaLibros(?,?,?,?,@CodRetorno,@msg,@numFilas)";
	// 			//EJECUTAMOS LA CONSULTA
	// 		$stm = executeSP($consulta,$datos);

	// 		if ($stm->codRetorno[0] == '000') {
	// 			foreach ($stm->datos as $key => $value) {
	// 				$libros[$i] = array('id' => $value['codigo_libro'],
	// 					'nombre' => $value['nombre_libro'],
	// 					'isbn' => $value['isbn'],
	// 					'autor' => $value['nombre_autor'],
	// 					'idAutor' => $value['autor'],
	// 					'idEditorial' => $value['editorial'],
	// 					'editorial' => $value['nombre_editorial'],
	// 					'descripcion' => $value['descripcion'],
	// 					'rutaIMG' => $value['rutaIMG']
	// 				);
	// 				$i++;
	// 			}
	// 				//VALIDAMOS EL NÚMERO DE FILAS
	// 			if ($stm->numFilas[0] == 0) {
	// 				$retorno->CodRetorno = "001";
	// 				$retorno->Mensaje = 'No Hay Datos Para Mostrar';
	// 			} else {
	// 				$lista = paginacion($stm->numFilas[0],5,$paginaActual);	
	// 				$retorno->lista = $lista;
	// 			}
	// 			$retorno->CodRetorno = "000";
	// 			$retorno->libros = $libros;
	// 		} else {
	// 			$retorno->CodRetorno = "002";
	// 			$retorno->Mensaje = "Ocurrio Un Error";
	// 		} 

	// 		return $retorno;
	// 	} catch (Exception $e) {
	// 		$log->insert('Error cargarLibro '.$e->getMessage(), false, true, true);	
	// 		print('Ocurrio un Error'.$e->getMessage());
	// 	}
	// }
}

?>