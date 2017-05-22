<?php 
require_once('../Clases/funciones.php');
/*
	Clase: Movimientos Model
	Autor: Felipe Monzón
	Fecha: 18-May-2017
*/
class MovimientosModel {
    public function recuperarFolio($nombre,$id){
        try {
            $datos = array($nombre,$id);
            $consulta = "CALL spRecuperaFolio(?,?,@codRetorno,@msg)";

            $stm = executeSP($consulta,$datos);

            if ($stm->codRetorno[0] == '000') {
                $retorno->CodRetorno = $stm->codRetorno[0];
                $retorno->Datos = $stm->datos;
            } else if ($stm->codRetorno[0] == '001') {
                $retorno->CodRetorno = $stm->codRetorno[0];
                $retorno->Mensaje = $stm->Mensaje[0];
            } else {
                $retorno->CodRetorno = '002';
                $retorno->Mensaje = 'Ocurrio un Error';
            }

            return $retorno;
        } catch (Exception $e) {
			$log->insert('Error recuperarFolio '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
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