<?php 
require_once('funciones.php');
require_once('Usuario.php');
/*
	Clase: Implementación de Usuario
	Autor: Felipe Monzón
	Fecha: 10-May-2017
*/
class UsuarioImp {
	public function validarUsuario($usuario){
		try {	
			$usuario = filter_var($usuario, FILTER_SANITIZE_STRING,FILTER_FLAG_NO_ENCODE_QUOTES|FILTER_FLAG_ENCODE_AMP);
			$datos = array($usuario,$_SESSION['INGRESO']['nombre']);

			$objUsuario = new Usuario();

			$consulta = "CALL spValidaUsuario(?,?,@CodRetorno,@msg)";
				//EJECUTAMOS LA CONSULTA
			$stm = executeSP($consulta,$datos);

			if ($stm->codRetorno[0] == '000') {
				foreach ($stm->datos as $key => $value) {
					$objUsuario->setClave($value['matricula_empleado']);
					$objUsuario->setUsuario($value['nombre_usuario']);
					$objUsuario->setEmpleado($value['nombreEmpleado']);
					$objUsuario->setTipoUsuario($value['tipo_usuario']);
					$objUsuario->setStatus($value['status']);
				}

				$retorno->CodRetorno = $stm->codRetorno[0];
				$retorno->Datos = $objUsuario;
			} else if ($stm->codRetorno[0] == '001') {
				$retorno->CodRetorno = $stm->codRetorno[0];
				$retorno->Mensaje = $stm->Mensaje[0];
			} else {
				$retorno->CodRetorno = '002';
				$retorno->Mensaje = 'Ocurrio un Error';
			}

			return $retorno;
		} catch (Exception $e) {
			$log->insert('Error validaUsu '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());		
		}
	}
}
?>