<?php 
	header('Content-Type: application/json');
	require_once('../Models/productoModel.php');
	include "../Clases/Log.php";
	error_reporting(0);
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
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo productoFiltro', false, true, true);	
		try {
			$sql = new ProductoModel();
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO']) ) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => 'Producto',
					'Mensaje' => 'Sesión Caducada'
				);
				$log->insert('Producto CodRetorno: '.$salidaJSON['codRetorno'], false, true, true);	
				print json_encode($salidaJSON);
				exit();
			}

			$datosCombo = $sql->productoFiltro();

			if ($datosCombo != "") {
				$salidaJSON = array('codRetorno' => '000',
					'proveedores' => $datosCombo->proveedores,
					'categorias' => $datosCombo->categorias,
					'form' => 'Producto',
				);	
			} else {
				$salidaJSON = array('codRetorno' => '002',
					'form' => 'Producto',
					'Mensaje' => 'Ocurrio un Error ',
				);
			}

			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$log->insert('Error productoFiltro '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}
		//FUNCIÓN PARA GUARDAR
	function guardarProducto(){	
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo guardarProducto', false, true, true);		
		try {
				//RECIBIMOS EL SERIALIZE() Y LO ASIGNAMOS A VARIABLES
			parse_str($_POST["cadena"], $_POST);
			$sql = new ProductoModel();
			 	//CICLO PARA LLENAR VARIABLES POR POST
			foreach ($_POST as $clave => $valor) {
				${$clave} = trim($_POST[$clave]);
			}
				//VALIDAMOS EL CÓDIGO
			if ($codigoProducto == "") {
				$codigoProducto = 0;
			}
				//CALUCLAMOS EL STATUS
			$status = calculaStatus($stActual,$stMax);
			$nombreProducto = strtolower($nombreProducto);
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO']) ) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => 'Producto',
					'Mensaje' => 'Sesión Caducada'
				);
				$log->insert('Producto CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
				print json_encode($salidaJSON);
				exit();
			}
				//VALIDAMOS LOS PARAMETROS
			if (!isset($codigoProducto,$nombreProducto,$codigoBarras,$proveedor,$stActual,$stMin,$stMax,$compra,$venta,$categoria,$status) ) {
				$salidaJSON = array('codRetorno' => '004',
					'form' => 'Producto',
					'Titulo' => 'Advertencia',
					'Mensaje' => 'Parametros Vacios'
				);
				$log->insert('Producto CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
				print json_encode($salidaJSON);
				exit();
			}
				//SE CREA EL ARRAY CON LOS DATOS A INSERTAR
			$datos = array($codigoProducto,$nombreProducto,$codigoBarras,$proveedor,$stActual,$stMin,$stMax,$compra,$venta,$categoria,$status,$_SESSION['INGRESO']['nombre']);
				//EJECUTAMOS EL MÉTODO PARA GUARDAR
			$res = $sql->guardarProducto($datos);
				//SE VALIDA EL RETORNO DEL MÉTODO
			if ($res->CodRetorno == '000') {
				$salidaJSON = array('codRetorno' => $res->CodRetorno,
					'form' => 'Producto',
					'Titulo' => 'Éxito',
					'Mensaje' => $res->Mensaje,
				);
			} else {
				$salidaJSON = array('codRetorno' => $res->CodRetorno,
					'form' => 'Producto',
					'Titulo' => 'Error',
					'Mensaje' => $res->Mensaje,
				);
			}

			$log->insert('Producto CodRetorno: '.$salidaJSON['codRetorno'], false, true, true);	
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$log->insert('Error guardarProducto: '.$e->getMessage(), false, true, true);
			print('Ocurrio un Error'.$e->getMessage());					
		}
	}
		//FUNCIÓN PARA BUSCAR PROVEEDOR(ES)
	function buscarProductos(){
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo buscarProductos', false, true, true);
		
		try {
			sleep(0.5);
				//RECIBIMOS EL SERIALIZE() Y LO ASIGNAMOS A VARIABLES
			parse_str($_POST["parametros"], $_POST);
			$codigo = trim($_POST['codigo']);
			$tipoBusqueda = trim($_POST['tipoBusqueda']);
			$sql = new ProductoModel();
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => 'Producto',
					'Mensaje' => 'Sesión Caducada'
				);
				$log->insert('Producto CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
				print json_encode($salidaJSON);
				exit();
			} 
				//VALIDAMOS SI LA BUSQUEDA ESTA VACIA
			if ($tipoBusqueda == "" || $tipoBusqueda == undefined) {
				$tipoBusqueda = "0";
			} 

			if (isset($_POST['partida'])) {
				$paginaActual = $_POST['partida'];	
			}
				//CALCULAMOS EL INICIO
			if ($paginaActual <= 1){
				$inicio = 0;
			} else {
				$inicio = ($paginaActual - 1) * 5;
			}
				//CARGAMOS LOS DATOS
			$productos = $sql->cargarProductos($codigo,$inicio,$paginaActual,$tipoBusqueda);	

			if ($productos->CodRetorno == "000") {
				$salidaJSON = array ('codRetorno' => $productos->CodRetorno,
					'datos' => $productos->Productos,
					'link' => $productos->lista,
					'form' => 'Producto',
				);
			} else {
				$salidaJSON = array('codRetorno' => $productos->CodRetorno,
					'form' => 'Producto',
					'bus' => '1',
					'Mensaje' => $productos->Mensaje,
				);
			}

			$log->insert('Producto CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$log->insert('Error buscarProductos '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}
		//FUNCIÓN PARA ACTUALIZAR EL STOCK DE LOS PRODUCTOS
	function acutalizarStock(){
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo stock', false, true, true);	
		try {
			$sql = new ProductoModel();
			parse_str($_POST["parametros"], $_POST);
			 	//CICLO PARA LLENAR VARIABLES POR POST
			foreach ($_POST as $clave => $valor) {
				${$clave} = trim($_POST[$clave]);
			}
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO']) ) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => 'Producto',
					'Mensaje' => 'Sesión Caducada'
				);
				$log->insert('Producto CodRetorno: '.$salidaJSON['codRetorno'], false, true, true);	
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
			$stock = $sql->stock($codigo,$stockActual,$status);
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

			$log->insert('Producto CodRetorno: '.$salidaJSON['codRetorno'], false, true, true);	
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$log->insert('Error stcok '.$e->getMessage(), false, true, true);	
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