<?php 
require_once(CLASES.'funciones.php');
/*
	Clase: Movimientos Model
	Autor: Felipe Monzón
	Fecha: 18-May-2017
*/
class MovimientosModel {
    public function recuperarFolio($retiro){
        $logger = new PHPTools\PHPErrorLog\PHPErrorLog();
        try {
            $sql = "";
            $db = new Conexion();
            $datos = new ArrayObject();
             	//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
			if (empty($retiro->tabla) || empty($retiro->idEmpleado) ) {
				$retorno = array('codRetorno' => '004',
                    'form' => VENTA,
                    'Mensaje' => PARAM_VACIOS
                );

				return $retorno;
            }
            
            $sql = SP_RECUPERA_FOLIO;
            $stm = $db->prepare($sql);

            $stm->bindParam(':tabla',$retiro->tabla,PDO::PARAM_STR);
            $stm->bindParam(':codigoEmpelado',$retiro->idEmpleado,PDO::PARAM_INT);
            
            $stm->execute();
            $datos = $stm->fetchAll(PDO::FETCH_ASSOC);            
			$stm->closeCursor();
			
			$error = $stm->errorInfo();

			if ($error[2] != "") {
				$logger->write('spRecuperaFolio: '.$error[2], 3 );
			}

			$retorno = $db->query('SELECT @codRetorno AS codRetorno, @msg AS Mensaje, @msgSQL AS msgSQL80')->fetch(PDO::FETCH_ASSOC);
			$logger->write('codRetorno spRecuperaFolio:  '.$retorno['codRetorno'] ,6 );

			if ($retorno['msgSQL80'] != '' || $retorno['msgSQL80'] != null) {
				$logger->write('spRecuperaFolio: '.$retorno['msgSQL80'] , 3 );
				$retorno['Mensaje'] = MENSAJE_ERROR;
			}

			if ($retorno['codRetorno'] == "" ) {
				$retorno['codRetorno'] = '002';
				$retorno['Mensaje'] = MENSAJE_ERROR;
				return $retorno;
			}

            if ($retorno['codRetorno'] == '000') {
                foreach ($datos as $value) {
                    $datosFolio = array('folio' => $value['folio'],
                        'nombreEmpleado' => $value['nombreEmpleado']);
                }

                $retorno['DatosFolio'] = $datosFolio;
            }

			$db = null;

			return $retorno;
        } catch (Exception $e) {
			$logger->write('RecuperaFolio: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());
		}
    }

    public function guardarRetiro($codigoRetiro,$folio,$nombreEmpleado,$cantidad,$descripcion,$status,$usuario){
        try {
            $datos = array($codigoRetiro,$folio,$nombreEmpleado,$cantidad,$descripcion,$status,$usuario);
            $consulta = "CALL spInsUpdRetiro(?,?,?,?,?,?,?,@codRetorno,@msg)";

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
			$log->insert('Error retiro '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
		}
    }

    public function buscarRetiro($folio,$inicio,$paginaActual,$usuario){
        $retiros = new ArrayObject();
        try {
            $folio = limpiarCadena($folio);
            $usuario = limpiarCadena($usuario);

            $datos = array($folio,$inicio,5,$usuario);
            $consulta = "CALL spConsultaRetiros(?,?,?,?,@codRetorno,@msg,@numFilas)";

            $stm = executeSP($consulta,$datos);
            
            if ($stm->codRetorno[0] == '000') { 
				foreach ($stm->datos as $key => $value) {
					$retiros[$i] = array('id' => $value['codigo_retiro'],
						'folio' => $value['folio'],
						'nombreEmpleado' => $value['empleado'],
						'fecha' => date("d-m-Y",strtotime($value['fecha'])),
						'cantidad' => $value['cantidad'],
						'descripcion' => $value['descripcion'],
					);
					$i++;
				}
					//CREAMOS LA LISTA DE PAGINACIÓN
				if ($stm->numFilas[0] > 0) {
					$lista = paginacion($stm->numFilas[0],5,$paginaActual);	
					$retorno->lista = $lista;
				} else {
					$retorno->CodRetorno = $stm->codRetorno[0];
					$retorno->Mensaje = $stm->Mensaje[0];
				}
					//ASIGNAMOS DATOS AL RETORNO
				$retorno->CodRetorno = $stm->codRetorno[0];
				$retorno->Retiros = $retiros;
			} else {
				$retorno->CodRetorno = $stm->codRetorno[0];
				$retorno->Mensaje = $stm->Mensaje[0];
			} 

			return $retorno;
        } catch (Exception $e) {
            $log->insert('Error UpdFolios '.$e->getMessage(), false, true, true);  
            print('Ocurrio un Error'.$e->getMessage());
        }
    }

    public function eliminarRetiro($folio,$status,$usuario){
        try {
            $folio = limpiarCadena($folio);
            $usuario = limpiarCadena($usuario);

            $datos = array($folio,$status,$usuario);
            $consulta = "CALL spDelRetiro(?,?,?,@codRetorno,@msg)";

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
			$log->insert('Error retiro '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
		}
    }
}

?>