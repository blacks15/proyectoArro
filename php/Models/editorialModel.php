<?php 
require_once('../Clases/funciones.php');
session_start();
/*
	Clase: Model Editorial
	Autor: Felipe Monzón
	Fecha: 29-ABR-2017
*/
class EditorialModel {
	public function guardarEditorial($codigo,$nombreEditorial,$status){
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
		//FUNCIÓN PARA LISTAR EDITORIALES
	public function cargarEditoriales($codigo,$inicio,$paginaActual){
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo cargarEditorial', false, true, true);	
		$i = 0;
		try {
			$editoriales = new ArrayObject();
			$datos = array($codigo,$inicio,5);
			$consulta = "CALL spConsultaEditoriales(?,?,?,@CodRetorno,@msg,@numFilas)";
				//EJECUTAMOS LA CONSULTA
			$stm = executeSP($consulta,$datos);
				//VALIDAR RETORNO DEL SP
			if ($stm->codRetorno[0] == '000') {
				foreach ($stm->datos as $key => $value) {
					$editoriales[$i] = array('codigo' => $value['codigo_editorial'],
						'nombre' => $value['nombre_editorial'],
						'status' => $value['status'],
					);
					$i++;
				}
					//VALIDAMOS EL NÚMERO DE FILAS
				if ($stm->numFilas[0] == 0) {
					$retorno->CodRetorno = $stm->codRetorno;
					$retorno->Mensaje = 'No Hay Datos Para Mostrar';
				} else {
						//CREAMOS LA LISTA DE PAGINACIÓN
					$lista = paginacion($stm->numFilas[0],5,$paginaActual);	
						//ASIGNAMOS DATOS AL RETORNO
					$retorno->CodRetorno = $stm->codRetorno[0];
					$retorno->editoriales = $editoriales;
					$retorno->lista = $lista;
				}
			} else {
				$retorno->CodRetorno = $stm->codRetorno[0];
				$retorno->Mensaje = $stm->Mensaje;
			} 

			return $retorno; 
		} catch (Exception $e) {
			$log->insert('Error cargarEditorial '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
		}
	}	
}
?>