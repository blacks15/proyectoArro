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
               // actualizaFolios('retiros');
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

    public function actualizaFolios($tabla){
        try {
            $datos = array($tabla);
            $consulta = "CALL spUpdFolios(?,@codRetorno,@msg)";

            $stm = executeSP($consulta,$datos);
            
        } catch (Exception $e) {
            $log->insert('Error UpdFolios '.$e->getMessage(), false, true, true);  
            print('Ocurrio un Error'.$e->getMessage());
        }
    }
}

?>