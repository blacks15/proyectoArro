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

			$stm = SP($consulta,$datos);

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

	public function cargarProductos($codigo,$inicio,$paginaActual){
		$productos = new ArrayObject();
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
			$consulta = "CALL spConsultaProductos(?,?,?,@CodRetorno,@msg,@numFilas)";
				//EJECUTAMOS LA CONSULTA
			$stm = SP ($consulta,$datos);

			if ($stm->codRetorno[0] == '000') {
					//VALIDAMOS EL NÚMERO DE FILAS
				if ($stm->numFilas[0] == 0) {
					$retorno->CodRetorno = "001";
					$retorno->Mensaje = 'No Hay Datos Para Mostrar';
				} else {
					foreach ($stm->datos as $key => $value) {
						$productos[$i] = array('id' => $value['codigo_productos'],
							'codigoBarras' => $value['codigoBarras'],
							'nombre_producto' => $value['nombre_producto'],
							'proveedor' => $value['proveedor'],
							'stockActual' => $value['stockActual'],
							'stockMin' => $value['stockMin'],
							'stockMax' => $value['stockMax'],
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
					$lista = paginacion($stm->numFilas[0],5,$paginaActual);	
						//ASIGNAMOS DATOS AL RETORNO
					$retorno->CodRetorno = "000";
					$retorno->Productos = $productos;
					$retorno->lista = $lista;
				}
			} else {
				$retorno->CodRetorno = "002";
				$retorno->Mensaje = "Ocurrio Un Error";
			} 

			return $retorno;
		} catch (Exception $e) {
			$log->insert('Error cargarProveedores '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
		}
	}
}
?>