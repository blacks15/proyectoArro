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

	public function guardarProducto($datos){
		try {
				//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
			if (empty($datos) ) {
				$retorno->CodRetorno = '004';
				$retorno->Mensaje = 'Parametros Vacios';

				return $retorno;
			}

			$consulta = "CALL spInsUpdProducto(?,?,?,?,?,?,?,?,?,?,?,?,@codRetorno,@msg)";

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
			$log->insert('Error guardarProducto '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
		}
	}

	public function cargarProductos($codigo,$inicio,$paginaActual,$tipoBusqueda){
		$productos = new ArrayObject();
		$i = 0;
		try {
				//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
			if ($codigo == "" || $paginaActual == "" || $tipoBusqueda == "") {
				$retorno->CodRetorno = '004';
				$retorno->Mensaje = 'Parametros Vacios';

				return $retorno;
				exit();
			}

			$datos = array($codigo,$inicio,5,$tipoBusqueda);
			$consulta = "CALL spConsultaProductos(?,?,?,?,@CodRetorno,@msg,@numFilas)";
				//EJECUTAMOS LA CONSULTA
			$stm = executeSP($consulta,$datos);

			if ($stm->codRetorno[0] == '000') { 
				foreach ($stm->datos as $key => $value) {
					$productos[$i] = array('id' => $value['codigo_producto'],
						'codigoBarras' => $value['codigoBarras'],
						'nombreProducto' => $value['nombre_producto'],
						'proveedor' => $value['proveedor'],
						'stActual' => $value['stockActual'],
						'stMin' => $value['stockMin'],
						'stMax' => $value['stockMax'],
						'compra' => $value['compra'],
						'venta' => $value['venta'],
						'categoria' => $value['categoria'],
						'status' => $value['status'],
						'nombreCategoria' => $value['nombreCategoria'],
						'nombreProveedor' => $value['nombreProveedor'],
					);
					$i++;
				}
					//CREAMOS LA LISTA DE PAGINACIÓN
				if ($stm->numFilas[0] > 0) {
					$lista = paginacion($stm->numFilas[0],5,$paginaActual);	
					$retorno->numFilas = $stm->numFilas[0];
					$retorno->lista = $lista;
				} else {
					$retorno->CodRetorno = $stm->codRetorno[0];
					$retorno->Mensaje = $stm->Mensaje[0];
				}
					//ASIGNAMOS DATOS AL RETORNO
				$retorno->CodRetorno = $stm->codRetorno[0];
				$retorno->Productos = $productos;
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

	public function stock($codigo,$stockActual,$status){
		$productos = new ArrayObject();
		$i = 0;
		try {
				//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
			if ($codigo == "" || $stockActual == "" || $status == "") {
				$retorno->CodRetorno = '004';
				$retorno->Mensaje = 'Parametros Vacios';

				return $retorno;
				exit();
			}

			$datos = array($codigo,$stockActual,$status);
			$consulta = "CALL spUpdStock(?,?,?,@CodRetorno,@msg)";
				//EJECUTAMOS LA CONSULTA
			$stm = SP ($consulta,$datos);

			if ($stm->codRetorno[0] == '000') { 
				$retorno->CodRetorno = $stm->codRetorno[0];
				$retorno->Mensaje = $stm->Mensaje[0];
			} else {
				$retorno->CodRetorno = $stm->codRetorno[0];
				$retorno->Mensaje = $stm->Mensaje[0];
			} 

			return $retorno;
		} catch (Exception $e) {
			$log->insert('Error stock '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
		}
	}
}
?>