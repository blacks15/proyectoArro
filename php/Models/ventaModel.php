<?php 
require_once('../Clases/funciones.php');
require_once('../Clases/Producto.php');
require_once('../Models/productoModel.php');
/*	
	Clase: Model vENTAS
	Autor: Felipe Monzón
	Fecha: 24-MAY-2017
*/
class VentaModel {
    public function listarProductos(){
        try {
            $c = 0;
            $a = 1;
            $productosList = new ArrayObject();
            $productosModel = new ProductoModel();
            $inventario = $productosModel->cargarProductos('0',$c,'5','0');   

            $total  = ceil($inventario->numFilas/5);

            for ($i = 1; $i <= $total ; $i++) {     
                foreach ($inventario->Productos as $key => $value) {
                    $producto = new Producto();

                    $producto->setCodigo($value['id']);
                    $producto->setCodigoBarras($value['codigoBarras']);
                    $producto->setNombreProducto($value['nombreProducto']);
                    $producto->setStockAct($value['stActual']);
                    $producto->setPrecioVenta($value['venta']);
                    $producto->setStatus($value['status']);

                    $productosList[$a] = $producto;
                    $a++;
                }

                $c = $c + 5;
                $inventario = $productosModel->cargarProductos('0',$c,'5','0');  
            }

            return $productosList;
        } catch (Exception $e) {
            $log->insert('Error validarStock '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
        }
    }

    public function guardarVenta($venta,$detalleVenta){
        try {
            	//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
			if ($venta == "" || $detalleVenta == "") {
				$retorno->CodRetorno = '004';
				$retorno->Mensaje = 'Parametros Vacios';

				return $retorno;
				exit();
			}

            $consulta = "CALL spInsUpdVenta(?,?,?,?,?,?,?,?,?,?,?,?,@codRetorno,@msg)";

            $stm = executeSP($consulta,$datos);

			if ($stm->codRetorno[0] == '000') {
				$retorno->CodRetorno = $stm->codRetorno[0];
				$retorno->Mensaje = $stm->Mensaje[0];
			} else {
				$retorno->CodRetorno = $stm->codRetorno[0];
				$retorno->Mensaje = $stm->Mensaje[0];
			}

            return $retorno;
        } catch(Exception $e) {
            $log->insert('Error cargarProveedores '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());
        }
    }
}

?>