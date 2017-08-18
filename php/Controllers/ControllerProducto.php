<?php 
	header('Content-Type: application/json');
	require_once('../Clases/Constantes.php');
	require_once(CLASES.'PHPErrorLog.php');
	require_once(MODEL.'productoModel.php');
	session_start();
		//RECIBINMOS LA OPCIÓN Y LLAMAMOS LA FUNCIÓN
	$opc = $_POST["opc"];
	switch ($opc) {
		case 'filtro':
			productoFiltro();
		break;
		
		case 'guardar':
			guardarProducto();
		break;

		case 'buscar':
			buscarProductos();
		break;	

		case 'stock':
			acutalizarStock();
		break;	
	}
		//FUNCIÓN FILTRO
	function productoFiltro(){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
			$modelo = new ProductoModel();
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO']) ) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => PRODUCTO,
					'Mensaje' => SESSION_CADUCADA
				);
				$logger->write('codRetorno productoFiltro:  '.$salidaJSON['codRetorno'] , 6 );
				print json_encode($salidaJSON);
				exit();
			}

			$datosCombo = $modelo->productoFiltro();

			if ($datosCombo != "") {
				$salidaJSON = array('codRetorno' => '000',
					'proveedores' => $datosCombo->proveedores,
					'categorias' => $datosCombo->categorias,
					'form' => PRODUCTO,
				);	
			} else {
				$salidaJSON = array('codRetorno' => '002',
					'form' => PRODUCTO,
					'Mensaje' => MENSAJE_ERROR,
				);
			}

			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$logger->write('productoFiltro: '.$e->getMessage() , 3 );
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}
		//FUNCIÓN PARA GUARDAR
	function guardarProducto(){	
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
			 	//DECLARACION Y ASIGNACIÓN DE VARIABLES
			$model = new ProductoModel();
			$rutaIMG2 = trim($_POST['img']);
			$producto = json_decode($_POST['cadena']);
			$producto->status = 'DISPONIBLE';
			$producto->usuario = $_SESSION['INGRESO']['nombre'];
				//COMPROBAMOS SI LA VARIABLE TRAE LA RUTA DE LA IMÀGEN 
			if ($rutaIMG2 != "" || $rutaIMG2 != null) {
				$producto->rutaIMG = $rutaIMG2;
			}
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO']) ) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => PRODUCTO,
					'Mensaje' => SESSION_CADUCADA
				);
				$logger->write(PRODUCTO.'codRetorno :  '.$salidaJSON['codRetorno'] , 6 );	
				print json_encode($salidaJSON);
				exit();
			}
				//VALIDAMOS LOS PARAMETROS
			if (!isset($producto) ) {
				$salidaJSON = array('codRetorno' => '004',
					'form' => PRODUCTO,
					'Titulo' => 'Advertencia',
					'Mensaje' => PARAM_VACIOS
				);
				$logger->write(PRODUCTO.'codRetorno :  '.$salidaJSON['codRetorno'] , 6 );	
				print json_encode($salidaJSON);
				exit();
			}
				//VALIDAMOS EL CÓDIGO
			if ($producto->codigoLibro == "") {
				$producto->codigoLibro = 0;
			}

			if ($producto->codigoEditorial == "") {
				$producto->codigoEditorial = 0;
			}

			if ($producto->codigoAutor == "") {
				$producto->codigoAutor = 0;
			}

			if ($producto->codigoProducto == "") {
				$producto->codigoProducto = 0;
			}
				//EJECUTAMOS EL MÉTODO PARA GUARDAR
			$resModel = $model->guardarProducto($producto);
				//SE VALIDA EL RETORNO DEL MÉTODO
			if ($resModel['codRetorno'] == '000') {
				$salidaJSON = array('codRetorno' => $resModel['codRetorno'],
					'form' => PRODUCTO,
					'Titulo' => 'Éxito',
					'Mensaje' => $resModel['Mensaje'],
				);
			} else {
				$salidaJSON = array('codRetorno' => $resModel['codRetorno'],
					'form' => PRODUCTO,
					'Titulo' => 'Error',
					'Mensaje' => $resModel['Mensaje']
				);
			}
			$logger->write(PRODUCTO.'codRetorno :  '.$salidaJSON['codRetorno'] , 6 );		
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$logger->write('guardarProducto: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());					
		}
	}
		//FUNCIÓN PARA BUSCAR PROVEEDOR(ES)
	function buscarProductos(){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();		
		try {
			sleep(0.5);
				//RECIBIMOS EL SERIALIZE() Y LO ASIGNAMOS A VARIABLES
			$modelo = new ProductoModel();
			$buscarProducto = new ArrayObject();
			parse_str($_POST["parametros"], $_POST);

			$buscarProducto->codigo = trim($_POST['codigo']);
			$buscarProducto->tipoBusqueda = trim($_POST['tipoBusqueda']);
			$buscarProducto->tamanioPag = TAMANIO_PAGINACION;
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => PRODUCTO,
					'Mensaje' => SESSION_CADUCADA
				);
				$logger->write(PRODUCTO.'codRetorno :  '.$salidaJSON['codRetorno'] , 6 );
				print json_encode($salidaJSON);
				exit();
			} 
				//VALIDAMOS SI LA BUSQUEDA ESTA VACIA
			if ($buscarProducto->tipoBusqueda == "" || !isset($buscarProducto->tipoBusqueda) ) {
				$buscarProducto->tipoBusqueda = "0";
			} 

			if (isset($_POST['partida'])) {
				$buscarProducto->paginaActual = $_POST['partida'];	
			}
				//CALCULAMOS EL INICIO
			if ($buscarProducto->paginaActual <= 1){
				$buscarProducto->inicio = 0;
			} else {
				$buscarProducto->inicio = ($buscarProducto->paginaActual - 1) * 5;
			}
				//CARGAMOS LOS DATOS
			$resModel = $modelo->cargarProductos($buscarProducto);	

			if ($resModel['codRetorno'] == "000") {
				$salidaJSON = array('codRetorno' => $resModel['codRetorno'],
					'productos' => $resModel['Productos'],
					'libros' => $resModel['Libros'],
					'link' => $resModel['lista'],
					'form' => PRODUCTO,
				);
			} else {
				$salidaJSON = array('codRetorno' => $resModel['codRetorno'],
					'form' => PRODUCTO,
					'bus' => '1',
					'Mensaje' => $resModel['Mensaje'],
				);
			}
			$logger->write(PRODUCTO.' CodRetorno: '.$salidaJSON['codRetorno'], 6 );
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$logger->write('buscarProductos: '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());	
		}
	}
		//FUNCIÓN PARA ACTUALIZAR EL STOCK DE LOS PRODUCTOS
	function acutalizarStock(){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();		
		try {
			$modelo = new ProductoModel();
			parse_str($_POST["parametros"], $_POST);
			 	//CICLO PARA LLENAR VARIABLES POR POST
			foreach ($_POST as $clave => $valor) {
				${$clave} = trim($_POST[$clave]);
			}
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO']) ) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => PRODUCTO,
					'Mensaje' => SESSION_CADUCADA
				);
				$logger->write(PRODUCTO.' CodRetorno: '.$salidaJSON['codRetorno'], 6 );
				print json_encode($salidaJSON);
				exit();
			}
				//VALIDAMOS EL ESTADO ACTUAL DEL PRODUCTO PARA DEFINIR EL STATUS
			if ($bandera == 1) {
				$stockActual = $stockActual+$nuevoStock;
			} else if ($bandera == 2) {
				$stockActual = $stockActual-$nuevoStock;
			}
				//CALUCLAMOS EL STATUS
			$status = calculaStatus($stockActual,$stockMax);
				//LLAMAMOS EL MÉTODO
			$stock = $modelo->stock($codigo,$stockActual,$status);
				//VALIDAMOS EL CODIGO DE RETORNO
			if ($stock->CodRetorno == "000") {
				$salidaJSON = array('codRetorno' => $stock->CodRetorno,
					'Titulo' => 'Exito',
					'form' => 'Stock',
					'Mensaje' => $stock->Mensaje,
				);	
			} else {
				$salidaJSON = array('codRetorno' => $stock->CodRetorno,
					'form' => 'Stock',
					'Titulo' => 'Advertencia',
					'Mensaje' => $stock->Mensaje,
				);
			}
			$logger->write(PRODUCTO.' CodRetorno: '.$salidaJSON['codRetorno'], 6 );
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$logger->write('stcok: '.$e->getMessage() , 3 );
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}	
		//FUNCIÓN PARA CALCULAR STATUS
	function calculaStatus($stActual,$stMax){
		if ($stActual <= 0) {
			$status = 'AGOTADO';
		} else if ($stActual > $stMax) {
			$status = 'SOBRESTOCK';
		} else {
			$status = 'DISPONIBLE';
		}
		return $status;
	}
?>