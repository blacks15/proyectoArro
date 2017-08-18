<?php 
require_once(CLASES.'Conexion.php');
require_once(CLASES.'funciones.php');
/*	
	Clase: Model Proveedor
	Autor: Felipe Monzón
	Fecha: 08-MAY-2017
*/
class ClienteModel {
	public function guardarCliente($cliente){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
			$sql = "";
			$retorno = array();
			$db = new Conexion();
				//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
			if (empty($cliente) ) {
				$retorno = array( 'codRetorno' => '004',
					'Mensaje' => PARAM_VACIOS
				);

				return $retorno;
			}

			$sql = SP_INSUPDCLIENTE;
			
			$stm = $db->prepare($sql);	
			$stm->bindParam(':codigoCliente',$cliente->codigoCliente,PDO::PARAM_INT);
			$stm->bindParam(':rfc',$cliente->rfc,PDO::PARAM_INT);
			$stm->bindParam(':nombreEmpresa',$cliente->nombreEmpresa,PDO::PARAM_STR);
			$stm->bindParam(':nombreCliente',$cliente->nombreCliente,PDO::PARAM_STR);
			$stm->bindParam(':apellidoPaterno',$cliente->apellidoPaterno,PDO::PARAM_STR);
			$stm->bindParam(':apellidoMaterno',$cliente->apellidoMaterno,PDO::PARAM_STR);
			$stm->bindParam(':calle',$cliente->calle,PDO::PARAM_STR);
			$stm->bindParam(':numExt',$cliente->numExt,PDO::PARAM_INT);
			$stm->bindParam(':numInt',$cliente->numInt,PDO::PARAM_INT);
			$stm->bindParam(':colonia',$cliente->colonia,PDO::PARAM_STR);
			$stm->bindParam(':ciudad',$cliente->ciudad,PDO::PARAM_STR);
			$stm->bindParam(':estado',$cliente->estado,PDO::PARAM_STR);
			$stm->bindParam(':telefono',$cliente->telefono,PDO::PARAM_INT);
			$stm->bindParam(':celular',$cliente->celular,PDO::PARAM_INT);
			$stm->bindParam(':email',$cliente->email,PDO::PARAM_INT);
			$stm->bindParam(':status',$cliente->status,PDO::PARAM_STR);
			$stm->bindParam(':usuario',$cliente->usuario,PDO::PARAM_STR);
			
			$stm->execute();
			$stm->closeCursor();
			
			$error = $stm->errorInfo();

			if ($error[2] != "") {
				$logger->write('spInsUpdCliente: '.$error[2], 3 );
			}

			$retorno = $db->query('SELECT @codRetorno AS codRetorno, @msg AS Mensaje, @msgSQL AS msgSQL80')->fetch(PDO::FETCH_ASSOC);
			$logger->write('codRetorno spInsUpdCliente:  '.$retorno['codRetorno'] ,6 );

			if ($retorno['msgSQL80'] != '' || $retorno['msgSQL80'] != null) {
				$logger->write('spInsUpdCliente: '.$retorno['msgSQL80'] , 3 );
			}

			if ($retorno['codRetorno'] == "" ) {
				$retorno['codRetorno'] = '002';
				$retorno['Mensaje'] = MENSAJE_ERROR;
				return $retorno;
			}

			$db = null;

			return $retorno; 
		} catch (Exception $e) {
			$logger->write('guardarCliente: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage() ) ;
		}
	}

	public function cargarClientes($buscarCliente){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
			$i = 0;
			$sql = "";
			$retorno = array();
			$clientes = array();
			$db = new Conexion();
			$clientesDisp = array();
			$datos = new ArrayObject();
				//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
			if ($buscarCliente->codigo == "" || $buscarCliente->paginaActual == "") {
				$retorno = array( 'codRetorno' => '004',
					'Mensaje' => PARAM_VACIOS
				);

				return $retorno;
			}

			$sql = Sp_CONSULTA_CLIENTES;
				//EJECUTAMOS LA CONSULTA
			$stm = $db->prepare($sql);	
			$stm->bindParam(':codigoCliente',$buscarCliente->codigo,PDO::PARAM_INT);
			$stm->bindParam(':inicio',$buscarCliente->inicio,PDO::PARAM_INT);
			$stm->bindParam(':limite',$buscarCliente->tamanioPag,PDO::PARAM_INT);
			
			$stm->execute();
			$datos = $stm->fetchAll(PDO::FETCH_ASSOC);
			$stm->closeCursor();
			
			$error = $stm->errorInfo();

			if ($error[2] != "") {
				$logger->write('spConsultaClientes: '.$error[2], 3 );
			}

			$retorno = $db->query('SELECT @codRetorno AS codRetorno, @msg AS Mensaje, @numFilas AS numFilas, @msgSQL AS msgSQL80')->fetch(PDO::FETCH_ASSOC);
			$logger->write('codRetorno spConsultaClientes:  '.$retorno['codRetorno'] ,6 );

			if ($retorno['msgSQL80'] != '' || $retorno['msgSQL80'] != null) {
				$logger->write('spConsultaClientes: '.$retorno['msgSQL80'] , 3 );
				$retorno['Mensaje'] = MENSAJE_ERROR;
			}

			if ($retorno['codRetorno'] == "" ) {
				$retorno['codRetorno'] = '002';
				$retorno['Mensaje'] = MENSAJE_ERROR;
				return $retorno;
			}

			if ($retorno['codRetorno'] == '000') {
					//CREAMOS LA LISTA DE PAGINACIÓN
				if ($retorno['numFilas'] > 0) {
					$retorno['lista'] = paginacion($retorno['numFilas'],TAMANIO_PAGINACION,$buscarCliente->paginaActual);	
				} else {
					$retorno['codRetorno'] = '001';
					$retorno['Mensaje'] = SIN_DATOS;
					return $retorno;
				}

				foreach ($datos as $value) {
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
					//ASIGNAMOS DATOS
				if (count($clientes) > 0) {
					$retorno['Clientes'] = $clientes;
				} else {
					$retorno['Clientes'] = $clientesDisp;
				}
			}

			return $retorno;
		} catch (Exception $e) {
			$logger->write('buscarClientes: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage() ) ;
		}
	}
}
?>