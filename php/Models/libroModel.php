<?php 
require_once('../Clases/funciones.php');
require_once('../Clases/Combo.php');
session_start();
/*	
	Clase: Model Autor
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

	public function guardarLibro($datos){
		try {
				//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
			if (empty($datos) ) {
				$retorno->CodRetorno = '004';
				$retorno->Mensaje = 'Parametros Vacios';

				return $retorno;
			}

			$consulta = "CALL spInsUpdLibro(?,?,?,?,?,?,?,?,?,@codRetorno,@msg)";

			$stm = executeSP($consulta,$datos);

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
		} catch (Exception $e) {
			$log->insert('Error guardarLibro '.$e->getMessage(), false, true, true);	
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