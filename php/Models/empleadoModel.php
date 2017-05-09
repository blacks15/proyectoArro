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
			$log->insert('Error guardarProducto '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
		}
	}

	public function cargarEmpleados($codigo,$inicio,$paginaActual){
		$empleados = new ArrayObject();
		$i = 0;
		try {
				//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
			if ($codigo == "" || $paginaActual == "") {
				$retorno->CodRetorno = '004';
				$retorno->Mensaje = 'Parametros Vacios';

				return $retorno;
				exit();
			}

			$datos = array($codigo,$inicio,5);
			$consulta = "CALL spConsultaEmpleados(?,?,?,@CodRetorno,@msg,@numFilas)";
				//EJECUTAMOS LA CONSULTA
			$stm = executeSP($consulta,$datos);
			if ($stm->codRetorno[0] == '000') {
				foreach ($stm->datos as $key => $value) {
					$empleados[$i] = array('id' => $value['matricula'],
						'nombreEmpleado' => $value['nombre_empleado'],
						'apellidos' => $value['apellidos'],
						'direccion' => $value['direccion'],
						'ciudad' => $value['ciudad'],
						'estado' => $value['estado'],
						'telefono' => $value['telefono'],
						'celular' => $value['celular'],
						'sueldo' => $value['sueldo'],
						'puesto' => $value['puesto'],
						'apellidoPaterno' => $value['apellido_paterno'],
						'apellidoMaterno' => $value['apellido_materno'],
						'calle' => $value['calle'],
						'numExt' => $value['numExt'],
						'numInt' => $value['numInt'],
						'colonia' => $value['colonia'],
						'isUsu' => $value['isUsu'],
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
				$retorno->Empleados = $empleados;
			} else {
				$retorno->CodRetorno = $stm->codRetorno[0];
				$retorno->Mensaje = $stm->Mensaje[0];
			} 

			return $retorno;
		} catch (Exception $e) {
			$log->insert('Error cargarProveedores '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
		}
	}
}
?>