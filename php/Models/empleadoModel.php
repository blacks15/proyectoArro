<?php 
require_once(CLASES.'Conexion.php');
/*	
	Clase: Model Empleado
	Autor: Felipe Monzón
	Fecha: 07-MAY-2017
*/
class EmpleadoModel {
	public function guardarEmpleado($empleado){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
			$sql = "";
			$db = new Conexion();
			$retorno = array();
				//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
			if (empty($empleado) ) {
				$retorno = array( 'codRetorno' => '004',
					'Mensaje' => PARAM_VACIOS
				);

				return $retorno;
			}

  			$sql = SP_INSUPDEMPLEADO;

			$stm = $db->prepare($sql);	
			$stm->bindParam(':codigoEmpleado',$empleado->codigoEmpleado,PDO::PARAM_INT);
			$stm->bindParam(':nombreEmpleado',$empleado->nombreEmpleado,PDO::PARAM_STR);
			$stm->bindParam(':apellidoPaterno',$empleado->apellidoPaterno,PDO::PARAM_STR);
			$stm->bindParam(':apellidoMaterno',$empleado->apellidoMaterno,PDO::PARAM_STR);
			$stm->bindParam(':calle',$empleado->calle,PDO::PARAM_STR);
			$stm->bindParam(':numExt',$empleado->numExt,PDO::PARAM_INT);
			$stm->bindParam(':numInt',$empleado->numInt,PDO::PARAM_INT);
			$stm->bindParam(':colonia',$empleado->colonia,PDO::PARAM_STR);
			$stm->bindParam(':ciudad',$empleado->ciudad,PDO::PARAM_STR);
			$stm->bindParam(':estado',$empleado->estado,PDO::PARAM_STR);
			$stm->bindParam(':telefono',$empleado->telefono,PDO::PARAM_INT);
			$stm->bindParam(':celular',$empleado->celular,PDO::PARAM_INT);
			$stm->bindParam(':sueldo',$empleado->sueldo,PDO::PARAM_INT);
			$stm->bindParam(':puesto',$empleado->puesto,PDO::PARAM_INT);
			$stm->bindParam(':status',$empleado->status,PDO::PARAM_STR);
			$stm->bindParam(':isUsu',$empleado->isUsu,PDO::PARAM_INT);
			$stm->bindParam(':usuario',$empleado->usuario,PDO::PARAM_STR);

			$stm->execute();
			$stm->closeCursor();
			
			$error = $stm->errorInfo();

			if ($error[2] != "") {
				$logger->write('spInsUpdEmpleado: '.$error[2], 3 );
			}

			$retorno = $db->query('SELECT @codRetorno AS codRetorno, @msg AS Mensaje, @msgSQL AS msgSQL80')->fetch(PDO::FETCH_ASSOC);
			$logger->write('codRetorno spInsUpdEmpleado:  '.$retorno['codRetorno'] ,6 );

			if ($retorno['msgSQL80'] != '' || $retorno['msgSQL80'] != null) {
				$logger->write('spInsUpdEmpleado: '.$retorno['msgSQL80'] , 3 );
			}

			if ($retorno['codRetorno'] == "" ) {
				$retorno['codRetorno'] = '002';
				$retorno['Mensaje'] = MENSAJE_ERROR;
				return $retorno;
			}

			$db = null;

			return $retorno; 
		} catch (Exception $e) {
			$logger->write('guardarEmpleado: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage() ) ;
		}
	}

	public function cargarEmpleados($buscarEmpleado){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
			$i = 0;
			$sql = "";
			$retorno = array();
			$db = new Conexion();
			$empleados = array();
			$datos = new ArrayObject();
				//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
			if ($buscarEmpleado->codigo == "" || $buscarEmpleado->paginaActual == "") {
				$retorno = array( 'codRetorno' => '004',
					'Mensaje' => PARAM_VACIOS
				);

				return $retorno;
			}

			$sql = SP_CONSULTA_EMPLEADOS;
				//EJECUTAMOS LA CONSULTA
			$stm = $db->prepare($sql);	
			$stm->bindParam(':codigoEmpleado',$buscarEmpleado->codigo,PDO::PARAM_INT);
			$stm->bindParam(':inicio',$buscarEmpleado->inicio,PDO::PARAM_INT);
			$stm->bindParam(':limite',$buscarEmpleado->tamanioPag,PDO::PARAM_INT);
			
			$stm->execute();
			$datos = $stm->fetchAll(PDO::FETCH_ASSOC);
			$stm->closeCursor();
			
			$error = $stm->errorInfo();

			if ($error[2] != "") {
				$logger->write('spConsultaEmpleados: '.$error[2], 3 );
			}

			$retorno = $db->query('SELECT @codRetorno AS codRetorno, @msg AS Mensaje, @numFilas AS numFilas, @msgSQL AS msgSQL80')->fetch(PDO::FETCH_ASSOC);
			$logger->write('codRetorno spConsultaEmpleados:  '.$retorno['codRetorno'] ,6 );

			if ($retorno['msgSQL80'] != '' || $retorno['msgSQL80'] != null) {
				$logger->write('spConsultaEmpleados: '.$retorno['msgSQL80'] , 3 );
				$retorno['Mensaje'] = MENSAJE_ERROR;
			}

			if ($retorno['codRetorno'] == "" ) {
				$retorno['codRetorno'] = '002';
				$retorno['Mensaje'] = MENSAJE_ERROR;
				return $retorno;
			}

			if ($retorno['codRetorno']  == '000') {
					//CREAMOS LA LISTA DE PAGINACIÓN
				if ($retorno['numFilas'] > 0) {
					$retorno['lista']  = paginacion($retorno['numFilas'],TAMANIO_PAGINACION,$buscarEmpleado->paginaActual);	
				} else {
					$retorno['codRetorno'] = '001';
					$retorno['Mensaje'] = SIN_DATOS;
					return $retorno;
				}

				foreach ($datos as $value) {
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
					//ASIGNAMOS DATOS
				$retorno['Empleados'] = $empleados;
			}

			return $retorno;
		} catch (Exception $e) {
			$logger->write('buscarEmpleado: '.$e->getMessage() , 3 );	
			print('Ocurrio un Error'.$e->getMessage());
		}
	}
}
?>