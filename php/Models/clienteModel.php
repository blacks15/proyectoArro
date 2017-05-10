<?php 
require_once('../Clases/funciones.php');

session_start();
/*	
	Clase: Model Proveedor
	Autor: Felipe Monzón
	Fecha: 08-MAY-2017
*/
class ClienteModel {
	public function guardarCliente($datos){
		try {
				//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
			if (empty($datos) ) {
				$retorno->CodRetorno = '004';
				$retorno->Mensaje = 'Parametros Vacios';

				return $retorno;
			}

			$consulta = "CALL spInsUpdCliente(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,@codRetorno,@msg)";

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
			$log->insert('Error guardarCliente '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
		}
	}

	public function cargarClientes($codigo,$inicio,$paginaActual){
		$clientes = new ArrayObject();
		$clientesDisp = new ArrayObject();
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
			$consulta = "CALL spConsultaClientes(?,?,?,@CodRetorno,@msg,@numFilas)";
				//EJECUTAMOS LA CONSULTA
			$stm = executeSP($consulta,$datos);

			if ($stm->codRetorno[0] == '000') {
				foreach ($stm->datos as $key => $value) {
					if ($_SESSION['INGRESO']['tipo'] == 1) {
						$clientes[$i] = array('id' => $value['matricula'],
							'rfc' => $value['rfc'],
							'nombreEmpresa' => $value['empresa'],
							'nombreCliente' => $value['nombre_contacto'],
							'apellidos' => $value['apellidos'],
							'direccion' => $value['direccion'],
							'ciudad' => $value['ciudad'],
							'estado' => $value['estado'],
							'telefono' => $value['telefono'],
							'celular' => $value['celular'],
							'email' => $value['email'],
							'calle' => $value['calle'],
							'numExt' => $value['numExt'],
							'numInt' => $value['numInt'],
							'colonia' => $value['colonia'],
							'apellidoPaterno' => $value['apellido_paterno'],
							'apellidoMaterno' => $value['apellido_materno'],
							'status' => $value['status'],
						);
					} else if ($_SESSION['INGRESO']['tipo'] != 1 && $value['status'] == 'DISPONIBLE' ) {
						$clientesDisp[$i] = array('id' => $value['matricula'],
							'rfc' => $value['rfc'],
							'nombreEmpresa' => $value['empresa'],
							'nombreCliente' => $value['nombre_contacto'],
							'apellidos' => $value['apellidos'],
							'direccion' => $value['direccion'],
							'ciudad' => $value['ciudad'],
							'estado' => $value['estado'],
							'telefono' => $value['telefono'],
							'celular' => $value['celular'],
							'email' => $value['email'],
							'calle' => $value['calle'],
							'numExt' => $value['numExt'],
							'numInt' => $value['numInt'],
							'colonia' => $value['colonia'],
							'apellidoPaterno' => $value['apellido_paterno'],
							'apellidoMaterno' => $value['apellido_materno'],
							'status' => $value['status'],
						);
					}

					$i++;
				}
					//VALIDAMOS EL NÚMERO DE FILAS
				if ($stm->numFilas[0] == 0) {
					$retorno->CodRetorno = $stm->codRetorno[0];
					$retorno->Mensaje = $stm->Mensaje[0];
				} else {
					$lista = paginacion($stm->numFilas[0],5,$paginaActual);	
					$retorno->lista = $lista;
				}

				if (count($clientes) > 0) {
					$retorno->Clientes = $clientes;
				} else {
					$retorno->Clientes = $clientesDisp;
				}

				$retorno->CodRetorno = "000";
				$retorno->numFilas = $stm->numFilas[0];
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