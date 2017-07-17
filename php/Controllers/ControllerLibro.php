<?php 
	header('Content-Type: application/json');
	require_once('../Models/libroModel.php');
	include "../Clases/Log.php";
	error_reporting(0);
	session_start();
		//RECIBINMOS LA OPCIÓN Y LLAMAMOS LA FUNCIÓN
	$opc = $_POST["opc"];
	switch ($opc) {
		case 'filtro':
			libroFiltro();
		break;

		case 'guardar':
			guardar_libro();
		break;

		case 'buscar':
			buscarLibros();
		break;
	}
		//FUNCIÓN FILTRO
	function libroFiltro(){
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo libroFiltro', false, true, true);	
		try {
			$sql = new LibroModel();
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO']) ) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => 'Libro',
					'Mensaje' => 'Sesión Caducada'
				);
				$log->insert('Libro CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
				print json_encode($salidaJSON);
				exit();
			}

			$datosCombo = $sql->libroFiltro();

			if ($datosCombo != "") {
				$salidaJSON = array('codRetorno' => '000',
					'autores' => $datosCombo->autores,
					'editoriales' => $datosCombo->editoriales,
					'form' => 'Libro',
				);	
			} else {
				$salidaJSON = array('codRetorno' => '002',
					'form' => 'Libro',
					'Mensaje' => 'Ocurrio un Error ',
				);
			}

			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$log->insert('Error libroFiltro '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}
		//FUNCIÓN PARA GUARDAR LIBRO
	function guardar_libro(){	
		$log = new Log("log", "../../log/");
		try {
			 	//DECLARACION Y ASIGNACIÓN DE VARIABLES
			$sql = new LibroModel();
			$rutaIMG2 = trim($_POST['img']);
			$libro = json_decode($_POST['cadena']);
			$libro->status = 'DISPONIBLE';
			$libro->usuario = $_SESSION['INGRESO']['nombre'];
				//COMPROBAMOS SI LA VARIABLE TRAE LA RUTA DE LA IMÀGEN 
			if ($rutaIMG2 != "" || $rutaIMG2 != null) {
				$libro->rutaIMG = $rutaIMG2;
			}
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO']) ) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => 'Libro',
					'Mensaje' => 'Sesión Caducada'
				);
				$log->insert('Libro CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
				print json_encode($salidaJSON);
				exit();
			}
				//VALIDAMOS LOS PARAMETROS
			if (!isset($libro) ) {
				$salidaJSON = array('codRetorno' => '004',
					'form' => 'Libro',
					'Titulo' => 'Advertencia',
					'Mensaje' => 'Parametros Vacios'
				);
				$log->insert('Libro CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
				print json_encode($salidaJSON);
				exit();
			}
				//VALIDAMOS EL CÓDIGO
			if ($libro->codigoLibro == "") {
				$libro->codigoLibro = 0;
			}

			if ($libro->codigoEditorial == "") {
				$libro->codigoEditorial = 0;
			}

			if ($libro->codigoAutor == "") {
				$libro->codigoAutor = 0;
			}
				//EJECUTAMOS EL MÉTODO PARA GUARDAR
			$res = $sql->guardarLibro($libro);
				//SE VALIDA EL RETORNO DEL MÉTODO
			if ($res->CodRetorno == '000') {
				$salidaJSON = array('codRetorno' => $res->CodRetorno,
					'form' => 'Libro',
					'Titulo' => 'Éxito',
					'Mensaje' => $res->Mensaje,
				);
			} else if (!empty($res->CodRetorno) ) {
				$salidaJSON = array('codRetorno' => $res->CodRetorno,
					'form' => 'Libro',
					'Titulo' => 'Error',
					'Mensaje' => $res->Mensaje,
				);
			} else {
				$salidaJSON = array('codRetorno' => '002',
					'form' => 'Libro',
					'Titulo' => 'Error',
					'Mensaje' => 'Ocurrio un Error',
				);
			}

			$log->insert('Libro CodRetorno: '.$salidaJSON['codRetorno'], false, true, true);	
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$log->insert('Error Libro: '.$e->getMessage(), false, true, true);
			print('Ocurrio un Error'.$e->getMessage());					
		}
	}
		//FUNCIÓN PARA BUSCAR LIBRO(S)
	function buscarLibros(){
		$log = new Log("log", "../../log/");
		$log->insert('Entro metodo buscarLibro', false, true, true);	
		parse_str($_POST["parametros"], $_POST);
		try { 
			$codigoLibro = trim($_POST['codigo']);
			$tipoBusqueda = trim($_POST['tipoBusqueda']);
			$sql = new LibroModel();
				//VALIDAMOS LA SESSION
			if (!isset($_SESSION) || empty($_SESSION['INGRESO'])) {
				$salidaJSON = array('codRetorno' => '003',
					'form' => 'Libro',
					'mensaje' => 'Sesión Caducada'
				);
				$log->insert('Libro CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
				print json_encode($salidaJSON);
				exit();
			}
				//VALIDAMOS SI LA BUSQUEDA ESTA VACIA
			if ($tipoBusqueda == "" || $tipoBusqueda == undefined) {
				$tipoBusqueda = "0";
			} 
				//VALIDAMOS LA PÁGINA ACTUAL
			if (isset($_POST['partida'])) {
				$paginaActual = $_POST['partida'];	
			}
				//CALCULAMOS LA PÁG DE INICIO
			if ($paginaActual <= 1){
				$inicio = 0;
			} else {
				$inicio = ($paginaActual - 1) * 5;
			}
				//CARGAMOS LOS DATOS
			$libros = $sql->cargarLibros($codigoLibro,$inicio,$paginaActual,$tipoBusqueda);	

			if ($libros->CodRetorno == "000") {
				$salidaJSON = array ('codRetorno' => $libros->CodRetorno ,
					'datos' => $libros->libros,
					'link' => $libros->lista,
					'form' => 'Libro',
				);
			} else {
				$salidaJSON = array('codRetorno' => $libros->CodRetorno ,
					'form' => 'Libro',
					'bus' => '1',
					'Mensaje' => $libros->Mensaje,
				);
			}			
			$log->insert('Libro CodRetorno: '.$salidaJSON['codRetorno']  , false, true, true);	
			print json_encode($salidaJSON);
		} catch (Exception $e) {
			$log->insert('Error buscarEditoriales! '.$e->getMessage(), false, true, true);	
			print('Ocurrio un Error'.$e->getMessage());	
		}
	}
?>