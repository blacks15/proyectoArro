<?php 
require_once(CLASES.'Conexion.php');
require_once(CLASES.'funciones.php');
/*	
	Clase: Model Proveedor
	Autor: Felipe Monzón
	Fecha: 02-MAY-2017
*/
class ProveedorModel {
	public function guardarProveedor($proveedores) {
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
			$sql = "";
			$retorno = array();
			$db = new Conexion();
				//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
			if (empty($proveedores) ) {
				$retorno = array( 'codRetorno' => '004',
					'Mensaje' => PARAM_VACIOS
				);

				return $retorno;
			}

			$sql = SP_INSUPDPROVEEDORES;
			
			$stm = $db->prepare($sql);	
			$stm->bindParam(':codigoCliente',$cliente->codigoEmpresa,PDO::PARAM_INT);
			$stm->bindParam(':nombreEmpresa',$cliente->nombreEmpresa,PDO::PARAM_STR);
			$stm->bindParam(':nombreContacto',$cliente->nombreContacto,PDO::PARAM_STR);
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
			$stm->bindParam(':web',$cliente->web,PDO::PARAM_STR);
			$stm->bindParam(':status',$cliente->status,PDO::PARAM_STR);
			$stm->bindParam(':usuario',$cliente->usuario,PDO::PARAM_STR);
			
			$stm->execute();
			$stm->closeCursor();
			
			$error = $stm->errorInfo();

			if ($error[2] != "") {
				$logger->write('spInsUpdProveedor: '.$error[2], 3 );
			}

			$retorno = $db->query('SELECT @codRetorno AS codRetorno, @msg AS Mensaje, @msgSQL AS msgSQL80')->fetch(PDO::FETCH_ASSOC);
			$logger->write('codRetorno spInsUpdProveedor:  '.$retorno['codRetorno'] ,6 );

			if ($retorno['msgSQL80'] != '' || $retorno['msgSQL80'] != null) {
				$logger->write('spInsUpdProveedor: '.$retorno['msgSQL80'] , 3 );
			}

			if ($retorno['codRetorno'] == "" ) {
				$retorno['codRetorno'] = '002';
				$retorno['Mensaje'] = MENSAJE_ERROR;
				return $retorno;
			}

			$db = null;

			return $retorno; 
		} catch (Exception $e) {
			$logger->write('guardarProveedores: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage() ) ;
		}
	}

	public function cargarProveedores($buscarProveedor){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
			$i = 0;
			$sql = "";
			$retorno = array();
			$db = new Conexion();
			$proveedores = array();
			$datos = new ArrayObject();
				//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
			if ($buscarProveedor->codigo == "" || $buscarProveedor->paginaActual == "") {
				$retorno = array( 'codRetorno' => '004',
					'Mensaje' => PARAM_VACIOS
				);

				return $retorno;
			}

			$sql = SP_CONSULTA_PROVEEDORES;
				//EJECUTAMOS LA CONSULTA
			$stm = $db->prepare($sql);	
			$stm->bindParam(':codigoProveedor',$buscarProveedor->codigo,PDO::PARAM_INT);
			$stm->bindParam(':inicio',$buscarProveedor->inicio,PDO::PARAM_INT);
			$stm->bindParam(':limite',$buscarProveedor->tamanioPag,PDO::PARAM_INT);
			
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
					$retorno['lista'] = paginacion($retorno['numFilas'],TAMANIO_PAGINACION,$buscarProveedor->paginaActual);	
				} else {
					$retorno['codRetorno'] = '001';
					$retorno['Mensaje'] = SIN_DATOS;
					return $retorno;
				}
	
				foreach ($datos as $value) {
					$proveedores[$i] = array('id' => $value['codigo_proveedor'],
						'nombreProveedor' => $value['nombre_proveedor'],
						'nombreContacto' => $value['nombreContacto'],
						'contacto' => $value['contacto'],
						'apellidoPaterno' => $value['apellido_paterno'],
						'apellidoMaterno' => $value['apellido_materno'],
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
				
				$retorno['Proveedores'] = $proveedores;
			}

			return $retorno;
		} catch (Exception $e) {
			$logger->write('buscarProveedores: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage() ) ;
		}
	}
}
?>