<?php 
require_once(CLASES.'Combo.php');
require_once(CLASES.'funciones.php');
require_once(MODEL.'libroModel.php');
/*	
	Clase: Model Proveedor
	Autor: Felipe Monzón
	Fecha: 02-MAY-2017
*/
class ProductoModel {
	public function productoFiltro(){
		try {
			$res = new ArrayObject();
			$res->proveedores = mostrar_proveedor();
			$res->categorias = mostrar_categoria();

			return $res; 
		} catch (Exception $e) {
			$logger->write('productoFiltro '.$e->getMessage(),3 );
			print(MENSAJE_ERROR.$e->getMessage());
		}
	}

	public function guardarProducto($producto){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
			$sql = "";
			$db = new Conexion();
			$libro = new ArrayObject();
			$libroModel = new LibroModel();
				//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
			if (empty($producto) ) {
				$retorno = array( 'codRetorno' => '004',
					'Mensaje' => PARAM_VACIOS
				);

				return $retorno;
			}

			if ($producto->tipo == 'libro') {
				$libro->codigoLibro = $producto->codigoLibro;
				$libro->nombreLibro = $producto->nombreLibro;
				$libro->isbn = $producto->isbn;
				$libro->codigoAutor = $producto->codigoAutor;
				$libro->autor = $producto->autor;
				$libro->codigoEditorial = $producto->codigoEditorial;
				$libro->editorial = $producto->editorial;
				$libro->descripcionLibro = $producto->descripcionLibro;
				$libro->usuario = $producto->usuario;
				$libro->status = $producto->status;
				$libro->rutaIMG	= $producto->rutaIMG;	

				$respLibro = $libroModel->guardarLibro($libro);

				if ( $respLibro['codRetorno'] == '002' ) {
					$retorno = array( 'codRetorno' => $respLibro['codRetorno'],
						'Mensaje' => $respLibro['msg']
					);

					return $retorno;
				}

				$producto->nombreProducto = $libro->nombreLibro;
				$producto->isLibro = $respLibro['id'];
			} else {
				$producto->isLibro = 0;
			}

			$producto->status = $this->calculaStatus($producto->stActual,$producto->stMax);

			$sql = SP_INSUPDPRODUCTO;

			$stm = $db->prepare($sql);	
			$stm->bindParam(':codigoProducto',$producto->codigoProducto,PDO::PARAM_INT);
			$stm->bindParam(':nombreProducto',$producto->nombreProducto,PDO::PARAM_STR);
			$stm->bindParam(':codigoBarras',$producto->codigoBarras,PDO::PARAM_INT);
			$stm->bindParam(':proveedor',$producto->proveedor,PDO::PARAM_INT);
			$stm->bindParam(':stActual',$producto->stActual,PDO::PARAM_INT);
			$stm->bindParam(':stMin',$producto->stMin,PDO::PARAM_INT);
			$stm->bindParam(':stMax',$producto->stMax,PDO::PARAM_INT);
			$stm->bindParam(':compra',$producto->compra,PDO::PARAM_INT);
			$stm->bindParam(':venta',$producto->venta,PDO::PARAM_INT);
			$stm->bindParam(':categoria',$producto->categoria,PDO::PARAM_INT);
			$stm->bindParam(':status',$producto->status,PDO::PARAM_STR);
			$stm->bindParam(':isLibro',$producto->isLibro,PDO::PARAM_INT);
			$stm->bindParam(':usuario',$producto->usuario,PDO::PARAM_STR);
			
			$stm->execute();
			$stm->closeCursor();
			
			$error = $stm->errorInfo();

			if ($error[2] != "") {
				$logger->write('spInsUpdProducto: '.$error[2], 3 );
			}

			$retorno = $db->query('SELECT @codRetorno AS codRetorno, @msg AS Mensaje, @msgSQL AS msgSQL80')->fetch(PDO::FETCH_ASSOC);
			$logger->write('codRetorno spInsUpdProducto:  '.$retorno['codRetorno'] ,6 );

			if ($retorno['msgSQL80'] != '' || $retorno['msgSQL80'] != null) {
				$logger->write('spInsUpdProducto: '.$retorno['msgSQL80'] , 3 );
			}

			if ($retorno['codRetorno'] == "" ) {
				$retorno['codRetorno'] = '002';
				$retorno['Mensaje'] = MENSAJE_ERROR;
				return $retorno;
			}

			$db = null;

 			return $retorno;
		} catch (PDOException $e){
			$logger->write('guardarProducto: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage() ) ;
		}
	}

	public function cargarProductos($buscarProducto){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
			$i = 0;
			$sql = "";
			$libros = array();
			$db = new Conexion();
			$productos = array();
			$datos = new ArrayObject();
			$datosLib = new ArrayObject();
				//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
			if ( empty($buscarProducto) ) {
				$retorno = array( 'codRetorno' => '004',
					'Mensaje' => PARAM_VACIOS
				);

				return $retorno;
			}

			$sql = SP_CONSULTAPRODUCTOS;
				//EJECUTAMOS LA CONSULTA
			$stm = $db->prepare($sql);	
			$stm->bindParam(':codigoProducto',$buscarProducto->codigo,PDO::PARAM_INT);
			$stm->bindParam(':inicio',$buscarProducto->inicio,PDO::PARAM_INT);
			$stm->bindParam(':limite',$buscarProducto->tamanioPag,PDO::PARAM_INT);
			$stm->bindParam(':tipoBusqueda',$buscarProducto->tipoBusqueda,PDO::PARAM_INT);

			$stm->execute();
			$datos = $stm->fetchAll(PDO::FETCH_ASSOC);
			$stm->nextRowSet();
			$datosLib = $stm->fetchAll(PDO::FETCH_ASSOC);
			$datos = array_merge($datos,$datosLib);
			$stm->closeCursor();
			
			$error = $stm->errorInfo();

			if ($error[2] != "") {
				$logger->write('spConsultaProductos: '.$error[2], 3 );
			}

			$retorno = $db->query('SELECT @codRetorno AS codRetorno, @msg AS Mensaje, @numFilas AS numFilas, @msgSQL AS msgSQL80')->fetch(PDO::FETCH_ASSOC);
			$logger->write('codRetorno spConsultaProductos:  '.$retorno['codRetorno'] ,6 );

			if ($retorno['msgSQL80'] != '' || $retorno['msgSQL80'] != null) {
				$logger->write('spConsultaProductos: '.$retorno['msgSQL80'] , 3 );
			}

			if ($retorno['codRetorno'] == "" ) {
				$retorno['codRetorno'] = '002';
				$retorno['Mensaje'] = MENSAJE_ERROR;
				return $retorno;
			}

			if ($retorno['codRetorno'] == '000') { 
					//CREAMOS LA LISTA DE PAGINACIÓN
				if ($retorno['numFilas'] > 0) {
					$retorno['lista']  = paginacion($retorno['numFilas'],TAMANIO_PAGINACION,$buscarProducto->paginaActual);	
				} else {
					$retorno['codRetorno'] = '001';
					$retorno['Mensaje'] = SIN_DATOS;
					return $retorno;
				}

				foreach ($datos as $value) {
					if ($value['isLibro'] == 0) {
						$productos[$i] = array('codigoProducto' => $value['codigo_producto'],
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
							'isLibro' => $value['isLibro'],
							'nombreCategoria' => $value['nombreCategoria'],
							'nombreProveedor' => $value['nombreProveedor']
						);
					} else {
						$libros[$i] = array('codigoProducto' => $value['codigo_producto'],
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
							'isLibro' => $value['isLibro'],
							'nombreCategoria' => $value['nombreCategoria'],
							'nombreProveedor' => $value['nombreProveedor'],
							'codigoLibro' => $value['codigo_libro'],
							'nombre' => $value['nombre_libro'],
							'isbn' => $value['isbn'],
							'autor' => $value['nombre_autor'],
							'idAutor' => $value['codigoAutor'],
							'idEditorial' => $value['codigoEditorial'],
							'editorial' => $value['nombre_editorial'],
							'descripcion' => $value['descripcion'],
							'rutaIMG' => $value['rutaIMG']
						);
					}

					$i++;
				}
					//ASIGNAMOS DATOS AL RETORNO
				$retorno['Productos'] = $productos;
				$retorno['Productos'] = array_merge($retorno['Productos'],$libros);
				$retorno['Libros'] = $libros;
			}

			return $retorno;
		} catch (Exception $e) {
			$logger->write('cargarProductos: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());
		}
	}

    public function updStock($stock){
        $logger = new PHPTools\PHPErrorLog\PHPErrorLog();
        try {
            $db = new Conexion();
            $sql = SP_UPD_STOCK;
            
            $stm = $db->prepare($sql);

            $stm->bindParam(':codigoProducto',$stock['codigoProducto'],PDO::PARAM_INT);
			$stm->bindParam(':stockActual',$stock['stock'],PDO::PARAM_INT);
            $stm->bindParam(':status',$stock['status'],PDO::PARAM_STR);
            
            $stm->execute();			
			$stm->closeCursor();
			
			$error = $stm->errorInfo();

			if ($error[2] != "") {
				$logger->write('spUpdStock: '.$error[2], 3 );
			}

			$retorno = $db->query('SELECT @codRetorno AS codRetorno, @msg AS Mensaje, @msgSQL AS msgSQL80')->fetch(PDO::FETCH_ASSOC);
			$logger->write('codRetorno spUpdStock:  '.$retorno['codRetorno'] ,6 );

			if ($retorno['msgSQL80'] != '' || $retorno['msgSQL80'] != null) {
				$logger->write('spUpdStock: '.$retorno['msgSQL80'] , 3 );
				$retorno['Mensaje'] = MENSAJE_ERROR;
			}

			if ($retorno['codRetorno'] == "" ) {
				$retorno['codRetorno'] = '002';
				$retorno['Mensaje'] = MENSAJE_ERROR;
				return $retorno;
			}

			$db = null;

			return $retorno;
        } catch (Exception $e){
            $logger->write('guardarVenta: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());
        }
    }

		//FUNCIÓN PARA CALCULAR STATUS
	public function calculaStatus($stActual,$stMax){
		if ($stActual <= 0) {
			$status = 'AGOTADO';
		} else if ($stActual > $stMax) {
			$status = 'SOBRESTOCK';
		} else {
			$status = 'DISPONIBLE';
		}
		return $status;
	}
}
?>