<?php 
require_once('../Clases/funciones.php');
require_once('../Clases/Combo.php');
session_start();
/*	
	Clase: Model vENTAS
	Autor: Felipe Monzón
	Fecha: 24-MAY-2017
*/
class VentaModel {
    public function validarStock($codigo){
        try {

        } catch (Exception $e) {
            $log->insert('Error validarStock '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
        }
    }
}

?>