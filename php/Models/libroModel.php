<?php 
require_once('../Clases/Conexion.php');
//require_once('../Clases/funciones.php');
require_once('../Clases/Combo.php');
session_start();
/*	
	Clase: Model Libro
	Autor: Felipe Monzón
	Fecha: 30-ABR-2017
*/
class LibroModel {
	public function libroFiltro(){
		try {
			$res->autores = mostrar_autor();
			$res->editoriales = mostrar_editorial();

			return $res; 
		} catch (Exception $e) {
			$log->insert('Error libroFiltro '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
		}
	}

	public function guardarLibro($libro){
		try {
				//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
			if (empty($libro) ) {
				$retorno->CodRetorno = '004';
				$retorno->Mensaje = 'Parametros Vacios';

				return $retorno;
			}
			$db = new Conexion();
			$sql = "CALL spInsUpdLibro(?,?,?,?,?,?,?,?,?)";

			$stm = $db->prepare($sql);
			$stm->bindParam(1,$libro->codigoLibro,PDO::PARAM_INT);
			$stm->bindParam(2,$libro->nombreLibro,PDO::PARAM_STR);
			$stm->bindParam(3,$libro->isbn,PDO::PARAM_INT);
			$stm->bindParam(4,$libro->autor,PDO::PARAM_INT);
			$stm->bindParam(5,$libro->editorial,PDO::PARAM_STR);
			$stm->bindParam(6,$libro->descripcionLibro,PDO::PARAM_STR);
			$stm->bindParam(7,$_SESSION['INGRESO']['nombre'],PDO::PARAM_STR);
			$stm->bindParam(8,$libro->status,PDO::PARAM_STR);
			$stm->bindParam(9,$codRetorno,PDO::PARAM_INT|PDO::PARAM_INPUT_OUTPUT);
			$stm->bindParam(10,$msg,PDO::PARAM_STR|PDO::PARAM_INPUT_OUTPUT);
			$stm->bindParam(11,$msgSQL,PDO::PARAM_STR|PDO::PARAM_INPUT_OUTPUT);

			$stm->execute();
			$error = $stm->errorInfo();
			var_dump($stm);
			var_dump($error[2]);
			//$stm = executeSP($consulta,$datos);
			if ($stm->codRetorno[0] == '000') {
				$retorno->CodRetorno = $stm->codRetorno[0];
				$retorno->Mensaje = $stm->Mensaje[0];
			} else if ($stm->codRetorno[0] == '001') {
				$retorno->CodRetorno = $stm->codRetorno[0];
				$retorno->Mensaje = $stm->Mensaje[0];
			} else {
				$retorno->CodRetorno = '002';
				$retorno->Mensaje = 'Ocurrio un Error';
			}

			return $retorno; 
		} catch (PDOException $e) {
			$log->insert('Error guardarLibro '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
		}
	}

	private function guardarEditorial(){
		try {
			$datos = array($codigo,$nombreEditorial,$_SESSION['INGRESO']['nombre'],$status);
			$consulta = "CALL spInsUpdEditorial(?,?,?,?,@codRetorno,@msg)";

			$stm = executeSP($consulta,$datos); 

			if ($stm->codRetorno[0] == '000') {
				$retorno->CodRetorno = $stm->codRetorno[0];
				$retorno->Mensaje = $stm->Mensaje[0];
			} else if ($stm->codRetorno[0] == '001') {
				$retorno->CodRetorno = $stm->codRetorno[0];
				$retorno->Mensaje = $stm->Mensaje[0];
			} else {
				$retorno->Mensaje = 'Ocurrio un Error';
			}

			return $retorno; 
		} catch (Exception $e) {
			$log->insert('Error guardarEditorial	 '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
		}
	}

	public function cargarLibros($codigo,$inicio,$paginaActual,$tipobusqueda){
		$libros = new ArrayObject();
		$i = 0;
		try {
				//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
			if ($codigo == "" || $paginaActual == "" || $tipobusqueda == "") {
				$retorno->CodRetorno = '004';
				$retorno->Mensaje = 'Parametros Vacios';

				return $retorno;
				exit();
			}

			$datos = array($codigo,$inicio,5,$tipobusqueda);
			$consulta = "CALL spConsultaLibros(?,?,?,?,@CodRetorno,@msg,@numFilas)";
				//EJECUTAMOS LA CONSULTA
			$stm = executeSP($consulta,$datos);

			if ($stm->codRetorno[0] == '000') {
				foreach ($stm->datos as $key => $value) {
					$libros[$i] = array('id' => $value['codigo_libro'],
						'nombre' => $value['nombre_libro'],
						'isbn' => $value['isbn'],
						'autor' => $value['nombre_autor'],
						'idAutor' => $value['autor'],
						'idEditorial' => $value['editorial'],
						'editorial' => $value['nombre_editorial'],
						'descripcion' => $value['descripcion'],
						'rutaIMG' => $value['rutaIMG']
					);
					$i++;
				}
					//VALIDAMOS EL NÚMERO DE FILAS
				if ($stm->numFilas[0] == 0) {
					$retorno->CodRetorno = "001";
					$retorno->Mensaje = 'No Hay Datos Para Mostrar';
				} else {
					$lista = paginacion($stm->numFilas[0],5,$paginaActual);	
					$retorno->lista = $lista;
				}
				$retorno->CodRetorno = "000";
				$retorno->libros = $libros;
			} else {
				$retorno->CodRetorno = "002";
				$retorno->Mensaje = "Ocurrio Un Error";
			} 

			return $retorno;
		} catch (Exception $e) {
			$log->insert('Error cargarLibro '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
		}
	}
}

?>