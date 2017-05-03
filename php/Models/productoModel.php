<?php 
require_once('../Clases/funciones.php');
require_once('../Clases/Combo.php');
session_start();
/*	
	Clase: Model Proveedor
	Autor: Felipe Monzón
	Fecha: 02-MAY-2017
*/

class ProductoModel {
	public function productoFiltro(){
		try {
			$res->proveedores = mostrar_proveedor();
			$res->categorias = mostrar_categoria();

			return $res; 
		} catch (Exception $e) {
			$log->insert('Error ProductoFiltro '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
		}
	}
}
?>