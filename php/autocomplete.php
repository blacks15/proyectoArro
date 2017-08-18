<?php 
	require_once('Clases/Conexion.php');
	require_once('Clases/funciones.php');
	header('Content-Type: application/json');
	
	error_reporting(0);
	session_start();
	$opc = $_GET['opc'];

	switch ($opc) {
		case 'autor':
			autor();
		break;

		case 'libro':
			libro();
		break;

		case 'proveedor':
			proveedor();
		break;

		case 'empleado':
			empleado();
		break;

		case 'cliente':
			cliente();
		break;

		case 'producto':
			producto();
		break;

		case 'editorial':
			editorial();
		break;
	}
		//FUNCIÓN PARA AUTOCOMPLETAR UN AUTOR
	function autor(){
		$db = new Conexion();
		$buscar = trim($_GET['term']);
			//VALIDAMOS SI LA BÚSQUEDA VIENE VACIA Y CREAMOS LA CONSULTA
		if(!empty($buscar)) {
      		$consulta = "SELECT codigo_autor,nombre_autor 
				FROM autores 
				WHERE nombre_autor LIKE ? AND status = 'DISPONIBLE'
				ORDER BY nombre_autor ASC ";
    			//SE PREPARA Y SE EJECUTA LA CONSULTA
			$stm = $db->prepare($consulta);
			$stm->execute(array("%$buscar%"));
				//SE TRAEN EL NÚMERO DE FILAS AFECTADAS Y EL ERROR EN CASO DE HABER
			$contar = $stm->rowCount();
			$error = $stm->errorInfo();
      			//VALIDAMOS SI HAY FILAS AFECTADAS Y RECORREMOS EL ARRAY PARA LLENARLO CON LA RESPUESTA
        	if ($contar > 0){
				while($rows = $stm->fetch(PDO::FETCH_ASSOC)){
                	$respuesta[] = array('value' => strtoupper($rows["nombre_autor"]) ,
                		'id' => $rows["codigo_autor"] );
				}
        	} else {
        		$respuesta[] = array('value' => null);	
        	}
        	print(json_encode($respuesta));
		}
	}
		//FUNCIÓN PARA AUTOCOMPLETAR UN LIBRO
	function libro(){
		$db = new Conexion();
		$buscar = trim($_GET['term']);
			//VALIDAMOS SI LA BÚSQUEDA VIENE VACIA Y CREAMOS LA CONSULTA
		if(!empty($buscar)) {
      		$consulta = "SELECT codigo_libro,nombre_libro 
				FROM libros 
				WHERE nombre_libro LIKE ? 
				ORDER BY nombre_libro ASC ";
    			//SE PREPARA Y SE EJECUTA LA CONSULTA
			$stm = $db->prepare($consulta);
			$stm->execute(array("%$buscar%"));
				//SE TRAEN EL NÚMERO DE FILAS AFECTADAS Y EL ERROR EN CASO DE HABER
			$contar = $stm->rowCount();
			$error = $stm->errorInfo();
      			//VALIDAMOS SI HAY FILAS AFECTADAS Y RECORREMOS EL ARRAY PARA LLENARLO CON LA RESPUESTA
        	if($contar > 0){
				while($rows = $stm->fetch(PDO::FETCH_ASSOC)){
                	$respuesta[] = array('value' => strtoupper($rows["nombre_libro"]) ,
                		'id' => $rows["codigo_libro"] );
				}
        	} else {
        		$respuesta[] = array('value' => null);	
        	}
        	print(json_encode($respuesta));
		}
	}
		//FUNCIÓN PARA AUTOCOMPLETAR PROVEEDOR
	function proveedor(){
		$db = new Conexion();
		$buscar = trim($_GET['term']);
			//VALIDAMOS SI LA BÚSQUEDA VIENE VACIA Y CREAMOS LA CONSULTA
		if(!empty($buscar)) {
      		$consulta = "SELECT codigo_proveedor,nombre_proveedor 
				FROM proveedores 
				WHERE status != 'BAJA' and nombre_proveedor LIKE ?
				ORDER BY nombre_proveedor ASC ";
    			//SE PREPARA Y SE EJECUTA LA CONSULTA
			$stm = $db->prepare($consulta);
			$stm->execute(array("%$buscar%"));
				//SE TRAEN EL NÚMERO DE FILAS AFECTADAS Y EL ERROR EN CASO DE HABER
			$contar = $stm->rowCount();
			$error = $stm->errorInfo();
      			//VALIDAMOS SI HAY FILAS AFECTADAS Y RECORREMOS EL ARRAY PARA LLENARLO CON LA RESPUESTA
        	if($contar > 0){
				while($rows = $stm->fetch(PDO::FETCH_ASSOC)){
                	$respuesta[] = array('value' => strtoupper($rows["nombre_proveedor"]) ,
                		'id' => $rows["codigo_proveedor"] );
				}
        	} else {
        		$respuesta[] = array('value' => null);	
        	}
        	print(json_encode($respuesta));
		} 
	}
		//FUNCIÓN PARA AUTOCOMPLETAR EMPLEADO
	function empleado(){
		try {
				//DECLARACIÓN Y ASIGNACIÓN DE VARIABLES
			$db = new Conexion();
			$buscar = trim($_GET['term']);
			$consulta = "";
				//VALIDAMOS SI LA BÚSQUEDA VIENE VACIA Y CREAMOS LA CONSULTA
			if(!empty($buscar)) {
				$consulta = "SELECT matricula,concat(nombre_empleado,' ',apellido_paterno,' ',
						apellido_materno) as nombre_empleado,isUsu
					FROM empleados WHERE status != 'BAJA' and nombre_empleado LIKE ?
					ORDER BY nombre_empleado ASC ";
	        		//SE PREPARA Y SE EJECUTA LA CONSULTA
				$stm = $db->prepare($consulta);
				$stm->execute(array("%$buscar%"));
					//SE TRAEN EL NÚMERO DE FILAS AFECTADAS Y EL ERROR EN CASO DE HABER
				$contar = $stm->rowCount();
				$error = $stm->errorInfo();
					//VALIDAMOS SI HUBO FILAS AFECTADAS
				if ($contar > 0) {
						//VALIDAMOS SI HAY FILAS AFECTADAS Y RECORREMOS EL ARRAY PARA LLENARLO CON LA RESPUESTA
					while ($rows = $stm->fetch(PDO::FETCH_ASSOC)){
		            	$respuesta[] = array('value' => strtoupper($rows["nombre_empleado"] ),
		            		'id' => $rows["matricula"],
		            		'isUsu' => $rows["isUsu"]
		            	);
					}					
				} else {
					$respuesta[] = array('id' => "",
						'value' => null);	
				}
				print(json_encode($respuesta));	
				$db = null;
			}
		} catch (Exception $e) {
			print('Error: '.$e->getMessage());
		}
	}
		//FUNCIÓN QUE MANDA EL NOMBRE DEL CLIENTE EN EL AUTOCOMPLETE
	function cliente(){
		try {
				//DECLARACIÓN Y ASIGNACIÓN DE VARIABLES
			$db = new Conexion();
			$buscar = trim($_GET['term']);
			$consulta = "";
				//VALIDAMOS SI LA BÚSQUEDA VIENE VACIA Y CREAMOS LA CONSULTA
			if(!empty($buscar)) {
				$consulta = "SELECT concat(nombre_contacto,' ',apellido_paterno,' ',apellido_materno) AS nombre_cliente, matricula
					FROM clientes WHERE nombre_contacto LIKE ? AND matricula != '1' ORDER BY nombre_cliente ASC ";
				$datos = array("%$buscar%");

				$stm = $db->prepare($consulta);
				$stm->execute(array("%$buscar%"));
					//SE TRAEN EL NÚMERO DE FILAS AFECTADAS Y EL ERROR EN CASO DE EXISTIR
				$contar = $stm->rowCount();
				$error = $stm->errorInfo();
	        		//VALIDAMOS SI HAY RESUPUESTA Y RECORREMOS EL ARRAY PARA LLENARLO CON LA RESPUESTA
	        	if ($contar > 0){
					while($rows = $stm->fetch(PDO::FETCH_ASSOC)){
                		$respuesta[] = array('value' => strtoupper($rows["nombre_cliente"]) ,
                			'id' => $rows["matricula"]);
					}
		        } else {
					$consulta = "SELECT empresa AS nombre_cliente, matricula
						FROM clientes WHERE empresa LIKE ? AND matricula != '1' ORDER BY nombre_cliente ASC ";

					$stm = $db->prepare($consulta);
					$stm->execute(array("%$buscar%"));
						//SE RECUPERA EL NÚMERO DE FILAS AFECTADAS Y EL ERROR EN CASO DE EXISTIR
					$contar = $stm->rowCount();
					$error = $stm->errorInfo();

					if ($contar > 0) {
						while($rows = $stm->fetch(PDO::FETCH_ASSOC)){
							$respuesta[] = array('value' => strtoupper($rows["nombre_cliente"]) ,
								'id' => $rows["matricula"]);
						}
					} else {
						$respuesta[] = array('value' => null);
					}
				}
				print(json_encode($respuesta));	
			}
		} catch (Exception $e) {
			print('Error: '.$e->getMessage());
		}
	}
		//FUNCIÓN PARA AUTOCOMPLETAR PRODUCTOS
	function producto(){
		try {
				//DECLARACIÓN Y ASIGNACIÓN DE VARIABLES
			$db = new Conexion();
			$buscar = trim($_GET['term']);
			$tipoBuscar = trim($_GET['id']);
			$consulta = "";
			$start = date("G:i:s");
			$_SESSION['expire'] = date("G:i",strtotime($start)+600); 
				//VALIDAMOS SI LA BÚSQUEDA VIENE VACIA Y CREAMOS LA CONSULTA
			if (!empty($buscar)) {
				$buscar = strtolower($buscar);
					//CREAMOS LA CONSULTA
				$consulta = "SELECT nombre_producto,codigo_producto,venta,codigoBarras,stockActual,stockMax,status
					FROM productos 
					WHERE nombre_producto LIKE ?
					ORDER BY nombre_producto ASC";
						//SE PREPARA Y SE EJECUTA LA CONSULTA
				$stm = $db->prepare($consulta);
				$stm->execute(array("%$buscar%"));
					//SE TRAEN EL NÚMERO DE FILAS AFECTADAS Y EL ERROR EN CASO DE HABER
				$contar = $stm->rowCount();
				$error = $stm->errorInfo();
	        		//VALIDAMOS SI HAY RESUPUESTA Y RECORREMOS EL ARRAY PARA LLENARLO CON LA RESPUESTA
	        	if ($contar > 0){
						//VALIDAMOS SI HAY FILAS AFECTADAS Y RECORREMOS EL ARRAY PARA LLENARLO CON LA RESPUESTA
					while ($rows = $stm->fetch(PDO::FETCH_ASSOC)){
                		$respuesta[] = array('value' => strtoupper($rows["nombre_producto"]) ,
                			'id' => $rows["codigo_producto"],
                			'precio' => $rows["venta"],
                			'stActual' => $rows["stockActual"],
                			'stockMax' => $rows["stockMax"],	
                			'codigoBarras' => $rows["codigoBarras"],
                			'status' => $rows['status'],
                			'sesion' => $_SESSION['expire'],
                			'error' => $error[2]
                		);
					}
		        } else {
					$respuesta[] = array('value' => null);
				}
				print(json_encode($respuesta));	
			}
		} catch (Exception $e) {
			print('Error: '.$e->getMessage());
		}
	}
			//FUNCIÓN PARA AUTOCOMPLETAR UNA EDITORIAL
	function editorial(){
		$db = new Conexion();
		$buscar = trim($_GET['term']);
			//VALIDAMOS SI LA BÚSQUEDA VIENE VACIA Y CREAMOS LA CONSULTA
		if (!empty($buscar)) {
      		$consulta = "SELECT codigo_editorial,nombre_editorial 
				FROM editoriales
				WHERE nombre_editorial LIKE ? AND status = 'DISPONIBLE'
				ORDER BY nombre_editorial ASC ";
    			//SE PREPARA Y SE EJECUTA LA CONSULTA
			$stm = $db->prepare($consulta);
			$stm->execute(array("%$buscar%"));
				//SE TRAEN EL NÚMERO DE FILAS AFECTADAS Y EL ERROR EN CASO DE HABER
			$contar = $stm->rowCount();
			$error = $stm->errorInfo();
      			//VALIDAMOS SI HAY FILAS AFECTADAS Y RECORREMOS EL ARRAY PARA LLENARLO CON LA RESPUESTA
        	if ($contar > 0){
				while($rows = $stm->fetch(PDO::FETCH_ASSOC)){
                	$respuesta[] = array('value' => strtoupper($rows["nombre_editorial"] ),
                		'id' => $rows["codigo_editorial"] );
				}
        	} else {
        		$respuesta[] = array('value' => null);	
        	}
        	print(json_encode($respuesta));
		}
	}
?>