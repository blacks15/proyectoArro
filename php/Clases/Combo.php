<?php 
require_once('funciones.php');
	
	$status = 'DISPONIBLE';	

	function mostrar_autor(){
		global $status;
		$opcion_autor = '<option value="0">SELECCIONE</option>';

		$consulta = "SELECT nombre_autor,codigo_autor FROM autores WHERE status = ?";
		$datos = array($status);
			//SE EJECUTA LA CONSULTA
		$stm = SQL($consulta,$datos);
			//SE TRAEN LOS DATOS
		$rows = $stm->fetchAll();
			//CICLO PARA LLENAR EL COMBOBOX
		foreach ($rows as $row) {
			$opcion_autor.=  '<option value="'.$row['codigo_autor'].'">'.$row['nombre_autor'].'</option>';
		}

		return $opcion_autor;
	}

	function mostrar_editorial(){
		global $status;
		$opcion_editorial = '<option value="0">SELECCIONE</option>';

		$consulta = "SELECT codigo_editorial,nombre_editorial FROM editoriales WHERE status = ?";
		$datos = array($status);
			//SE EJECUTA LA CONSULTA
		$stm = SQL($consulta,$datos);
			//SE TRAEN LOS DATOS
		$rows = $stm->fetchAll();
			//CICLO PARA LLENAR EL COMBOBOX
		foreach ($rows as $row) {
			$opcion_editorial.=  '<option value="'.$row['codigo_editorial'].'">'.$row['nombre_editorial'].'</option>';
		}

		return $opcion_editorial;
	}

	function mostrar_proveedor(){
		global $status;
		$opcion_proveedor = '<option value="0">SELECCIONE </option>';
		
		$consulta = "SELECT codigo_proveedor,nombre_proveedor FROM proveedores WHERE status = ? ";
		$datos = array($status);
			//SE EJECUTA LA CONSULTA
		$stm = SQL($consulta,$datos);
			//SE TRAEN LOS DATOS
		$rows = $stm->fetchAll();
		 	//CICLO PARA LLENAR EL COMBOBOX
		foreach ($rows as $row) {
			$opcion_proveedor.=  '<option value="'.$row['codigo_proveedor'].'">'.$row['nombre_proveedor'].'</option>';
		}

		return $opcion_proveedor;
	}	

	function mostrar_categoria(){
		$db = new Conexion();

		$opcion_categoria = '<option value="0">SELECCIONE </option>';
		$consulta = "SELECT codigo_catpro,nombre_categoria FROM categorias_producto ";
		$datos = array();
			//SE EJECUTA LA CONSULTA
		$stm = SQL($consulta,$datos);
			//SE TRAEN LOS DATOS
		$rows = $stm->fetchAll();
		 	//CICLO PARA LLENAR EL COMBOBOX
		foreach ($rows as $row) {
			$opcion_categoria.=  '<option value="'.$row['codigo_catpro'].'">'.$row['nombre_categoria'].'</option>';
		}

		return $opcion_categoria;
	}		
?>