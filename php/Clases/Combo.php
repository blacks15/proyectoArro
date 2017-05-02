<?php 
require_once('Conexion.php');

	function mostrar_autor(){
		$db = new Conexion();

		$opcion_autor = '<option value="0">SELECCIONE</option>';
		$consulta = "SELECT nombre_autor,codigo_autor FROM autores GROUP BY nombre_autor";
			//SE PREPARA Y SE EJECUTA LA CONSULTA
		$stm = $db->prepare($consulta);
		$stm->execute();
			//SE TRAEN LOS DATOS Y EL ERROR EN CASO DE HABER
		$rows = $stm->fetchAll();
			//CICLO PARA LLENAR EL COMBOBOX
		foreach ($rows as $row) {
			$opcion_autor.=  '<option value="'.$row['codigo_autor'].'">'.$row['nombre_autor'].'</option>';
		}

		return $opcion_autor;
	}

	function mostrar_editorial(){
		$db = new Conexion();

		$opcion_editorial = '<option value="0">SELECCIONE</option>';
		$consulta = "SELECT codigo_editorial,nombre_editorial FROM editoriales GROUP BY nombre_editorial";
			//SE PREPARA Y SE EJECUTA LA CONSULTA
		$stm = $db->prepare($consulta);
		$stm->execute();
			//SE TRAEN LOS DATOS Y EL ERROR EN CASO DE HABER
		$rows = $stm->fetchAll();
			//CICLO PARA LLENAR EL COMBOBOX
		foreach ($rows as $row) {
			$opcion_editorial.=  '<option value="'.$row['codigo_editorial'].'">'.$row['nombre_editorial'].'</option>';
		}

		return $opcion_editorial;
	}

	function mostrar_genero(){
		global $opciones;
		$db = new Conexion();

		$opcion_genero = '<option value="0">SELECCIONE</option>';
		$consulta = "select codigo_genero,nombre_genero from generos";
					//SE PREPARA Y SE EJECUTA LA CONSULTA
		$stm = $db->prepare($consulta);
		$stm->execute();
			//SE TRAEN LOS DATOS Y EL ERROR EN CASO DE HABER
		$rows = $stm->fetchAll();
		$error = $stm->errorInfo();
			//CICLO PARA LLENAR EL COMBOBOX
		foreach ($rows as $row) {
			$opcion_genero.=  '<option value="'.$row['codigo_genero'].'">'.$row['nombre_genero'].'</option>';
		}
		 $opciones->opcion_genero = $opcion_genero;
		 print($error[2]);
	}
	function mostrar_proveedor(){
			global $opciones;
			$db = new Conexion();

			$opcion_proveedor = '<option value="0">SELECCIONE </option>';
			$consulta = "SELECT codigo_proveedor,nombre_proveedor FROM proveedores WHERE status = 'DISPONIBLE' ";
				//SE PREPARA Y SE EJECUTA LA CONSULTA
			$stm = $db->prepare($consulta);
			$stm->execute();
				//SE TRAEN LOS DATOS Y EL ERROR EN CASO DE HABER
			$rows = $stm->fetchAll();
			$error = $stm->errorInfo();
			 	//CICLO PARA LLENAR EL COMBOBOX
			foreach ($rows as $row) {
				$opcion_proveedor.=  '<option value="'.$row['codigo_proveedor'].'">'.$row['nombre_proveedor'].'</option>';
			}
			$opciones->opcion_proveedor = $opcion_proveedor;
	}	
	function mostrar_categoria(){
		global $opciones;
		$db = new Conexion();

		$opcion_categoria = '<option value="0">SELECCIONE </option>';
		$consulta = "SELECT codigo_catpro,nombre_categoria FROM categorias_producto ";
			//SE PREPARA Y SE EJECUTA LA CONSULTA
		$stm = $db->prepare($consulta);
		$stm->execute();
			//SE TRAEN LOS DATOS Y EL ERROR EN CASO DE HABER
		$rows = $stm->fetchAll();
		$error = $stm->errorInfo();
		 	//CICLO PARA LLENAR EL COMBOBOX
		foreach ($rows as $row) {
			$opcion_categoria.=  '<option value="'.$row['codigo_catpro'].'">'.$row['nombre_categoria'].'</option>';
		}
		$opciones->opcion_categoria = $opcion_categoria;
	}		
?>