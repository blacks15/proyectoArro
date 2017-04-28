<?php 
require_once('../Clases/funciones.php');
require_once('../Clases/Autor.php');
session_start();
/*
	Clase: Model de Autor
	Autor: Felipe Monzón
	Fecha: 23-ABR-2017
*/
class AutorModel {
	public function guardarAutor($codigo,$nombreAutor,$status){
		$datos = array($codigo,$nombreAutor,$_SESSION['nombre'],$status);
		$consulta = "CALL spConsultaAutores(?,?,?,?,@codRetorno)";

		$stm = SP($consulta,$datos);

		if ($stm->codRetorno[0] == '000') {
			$retorno->CodRetorno = "000";
			$retorno->Mensaje = "Autor Guardado con Éxito";
		} else {
			$retorno->CodRetorno = "002";
			$retorno->Mensaje = "Ocurrio Un Error";
		} 

		return $retorno; 
	}
		//FUNCIÓN PARA LISTAR AUTORES
	public function cargarAutores($codigo,$inicio,$paginaActual){
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo cargarAutores!', false, true, true);	
		$i = 0;
		$autores = new ArrayObject();
		$datos = array($codigo,$inicio,5);
		$consulta = "CALL spConsultaAutores(?,?,?,@msg,@CodRetorno,@numFilas)";
			//EJECUTAMOS LA CONSULTA
		$stm = SP ($consulta,$datos);

		if ($stm->codRetorno[0] == '000') {
			foreach ($stm->datos as $key => $value) {
				$autores[$i] = array('codigo' => $value['codigo_autor'],
					'nombre' => $value['nombre_autor'],
					'status' => $value['status'],
				);
				$i++;
			}

				//VALIDAMOS EL NÚMERO DE FILAS
			if ($stm->numFilas[0] == 0) {
				$retorno->CodRetorno = "00";
				$retorno->Mensaje = 'No Hay Datos Para Mostrar';
			} else {
					//CREAMOS LA LISTA DE PAGINACIÓN
				$lista = paginacion($stm->numFilas[0],5,$paginaActual);	
					//ASIGNAMOS DATOS AL RETORNO
				$retorno->CodRetorno = "000";
				$retorno->autores = $autores;
				$retorno->lista = $lista;
			}
		} else {
			$retorno->CodRetorno = "002";
			$retorno->Mensaje = "Ocurrio Un Error";
		} 

		return $retorno; 
	}
}
?>