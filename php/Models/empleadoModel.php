<?php 
require_once('../Clases/funciones.php');
session_start();
/*	
	Clase: Model Empleado
	Autor: Felipe Monzón
	Fecha: 07-MAY-2017
*/
class EmpleadoModel {
	public function guardarEmpleado($datos){
		try {
				//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
			if (empty($datos) ) {
				$retorno->CodRetorno = '004';
				$retorno->Mensaje = 'Parametros Vacios';

				return $retorno;
			}

			$consulta = "CALL spInsUpdEmpleado(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,@codRetorno,@msg)";

			$stm = SP($consulta,$datos);

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
			$log->insert('Error guardarProducto '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
		}
	}
}
?>