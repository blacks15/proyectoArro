<?php 
require_once('../Clases/funciones.php');
/*
	Clase: Model de Autor
	Autor: Felipe Monzón
	Fecha: 23-ABR-2017
*/
class AutorModel {
		//FUNCIÓN PARA LISTAR AUTORES
	public function cargarAutores($codigo,$inicio){
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo cargarAutores!', false, true, true);	
		$i = 0;
		$datos = array($codigo,$inicio,5);
		$consulta = "CALL spConsultaAutores(?,?,?,@msg,@codRetorno)";

		$stm = SQL($consulta,$datos);

		if ($stm->codRetorno[0] == '000') {
			foreach ($stm->datos as $key => $value) {
				$autores[$i] = array('codigo' => $value['codigo_autor'],
					'nombre' => $value['nombre_autor'],
					'status' => $value['status'],
				);
				$i++;
			}
		}

		return $autores; 
	}
}
?>