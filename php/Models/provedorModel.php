<?php 
require_once('../Clases/funciones.php');

session_start();
/*	
	Clase: Model Proveedor
	Autor: Felipe Monzón
	Fecha: 02-MAY-2017
*/
class ProveedorModel {
	public function guardarProveedor($datos){
		try {
				//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
			if (empty($datos) ) {
				$retorno->CodRetorno = '004';
				$retorno->Mensaje = 'Parametros Vacios';

				return $retorno;
			}

			$consulta = "CALL spInsUpdProveedor(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,@codRetorno,@msg)";

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
			$log->insert('Error guardarProveedor '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
		}
	}

	public function cargarProveedores($codigo,$inicio,$paginaActual){
		$proveedores = new ArrayObject();
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
			$consulta = "CALL spConsultaProveedores(?,?,?,@CodRetorno,@msg,@numFilas)";
				//EJECUTAMOS LA CONSULTA
			$stm = SP ($consulta,$datos);

			if ($stm->codRetorno[0] == '000') {
				foreach ($stm->datos as $key => $value) {
					$proveedores[$i] = array('id' => $value['codigo_proveedor'],
						'nombreProveedor' => $value['nombre_proveedor'],
						'contacto' => $value['contacto'],
						'direccion' => $value['direccion'],
						'ciudad' => $value['ciudad'],
						'estado' => $value['estado'],
						'telefono' => $value['telefono'],
						'celular' => $value['celular'],
						'email' => $value['email'],
						'web' => $value['web'],
						'calle' => $value['calle'],
						'numExt' => $value['num_ext'],
						'numInt' => $value['num_int'],
						'colonia' => $value['colonia'],
					);
					$i++;
				}
					//VALIDAMOS EL NÚMERO DE FILAS
				if ($stm->numFilas[0] == 0) {
					$retorno->CodRetorno = "001";
					$retorno->Mensaje = 'No Hay Datos Para Mostrar';
				} else {
						//CREAMOS LA LISTA DE PAGINACIÓN
					$lista = paginacion($stm->numFilas[0],5,$paginaActual);	
						//ASIGNAMOS DATOS AL RETORNO
					$retorno->CodRetorno = "000";
					$retorno->proveedores = $proveedores;
					$retorno->lista = $lista;
				}
			} else {
				$retorno->CodRetorno = "002";
				$retorno->Mensaje = "Ocurrio Un Error";
			} 

			return $retorno;
		} catch (Exception $e) {
			$log->insert('Error cargarProveedores '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
		}
	}
}
?>