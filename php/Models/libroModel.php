<?php 
require_once('../Clases/Constantes.php');
require_once(CLASES.'Conexion.php');
require_once(CLASES.'Combo.php');
/*	
	Clase: Model Libro
	Autor: Felipe Monzón
	Fecha: 30-ABR-2017
*/
class LibroModel {
	public function guardarLibro($libro){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
			$db = new Conexion();
			$editorial = new ArrayObject();
			$autor = new ArrayObject();
			$retorno = new ArrayObject();
				//VALIDAR QUE LOS DATOS NO ESTEN VACIOS
			if (empty($libro) ) {
				$retorno = array( 'codRetorno' => '004',
					'Mensaje' => PARAM_VACIOS
				);

				return $retorno;
			}

			$editorial->codigoEditorial = $libro->codigoEditorial;
			$editorial->nombreditorial = strtolower($libro->editorial);
			$editorial->usuario = $_SESSION['INGRESO']['nombre'];
			$editorial->status = $libro->status;

			$autor->codigoAutor = $libro->codigoAutor;
			$autor->nombreAutor = strtolower($libro->autor) ;
			$autor->usuario = $_SESSION['INGRESO']['nombre'];
			$autor->status = $libro->status;

			$respEdit = $this->guardarEditorial($editorial);

			if ( $respEdit['codRetorno'] == '002' ) {
				$retorno = array( 'codRetorno' => $respEdit['codRetorno'],
					'Mensaje' => $respEdit['msg']
				);

				return $retorno;
			} else if ($respEdit['codRetorno'] == '001') {
				$libro->codigoEditorial = $respEdit['id'];
			}

			$respAutor = $this->guardarAutor($autor);

			if ( $respAutor['codRetorno'] == '002' ) {
				$retorno = array( 'codRetorno' => $respAutor['codRetorno'],
					'Mensaje' => $respAutor['msg']
				);

				return $retorno;
			} else if ($respAutor['codRetorno'] == '001') {
				$libro->codigoAutor = $respAutor['id'];
			}

			$sql = SP_INSUPDLIBROS;

			$stm = $db->prepare($sql);
			$stm->bindParam(':codigoLibro',$libro->codigoLibro,PDO::PARAM_INT);
			$stm->bindParam(':nombreLibro',$libro->nombreLibro,PDO::PARAM_STR);
			$stm->bindParam(':isbn',$libro->isbn,PDO::PARAM_INT);
			$stm->bindParam(':codigoAutor',$libro->codigoAutor,PDO::PARAM_INT);
			$stm->bindParam(':codigoEditorial',$libro->codigoEditorial,PDO::PARAM_INT);
			$stm->bindParam(':descripcionLibro',$libro->descripcionLibro,PDO::PARAM_STR);
			$stm->bindParam(':usuario',$libro->usuario,PDO::PARAM_STR);
			$stm->bindParam(':status',$libro->status,PDO::PARAM_STR);
			$stm->bindParam(':rutaIMG',$libro->rutaIMG,PDO::PARAM_STR);

			$stm->execute();
			$stm->closeCursor();
			
			$error = $stm->errorInfo();

			if ($error[2] != "") {
				$logger->write('spInsUpdLibro: '.$error[2], 3 );
			}

			$retorno = $db->query('SELECT @codRetorno AS codRetorno, @msg AS msg, @msgSQL AS msgSQL80, @id AS id')->fetch(PDO::FETCH_ASSOC);
			$logger->write('codRetorno spInsUpdLibro:  '.$retorno['codRetorno'] ,6 );

			if ($retorno['msgSQL80'] != '' || $retorno['msgSQL80'] != null) {
				$logger->write('spInsUpdLibro: '.$retorno['msgSQL80'] , 3 );
				$retorno['Mensaje'] = MENSAJE_ERROR;
			}

			if ($retorno['codRetorno'] == "" ) {
				$retorno['codRetorno'] = '002';
				$retorno['Mensaje'] = MENSAJE_ERROR;
				return $retorno;
			}

			$db = null;

			return $retorno; 
		} catch (PDOException $e) {
			$logger->write('guardarLibro: '.$e->getMessage() , 3 );
			print('Ocurrio un Error'.$e->getMessage());
		}
	}

	private function guardarAutor($autor){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
			$retorno = new ArrayObject();
			$db = new Conexion();

			$sql = SP_INSUPDAUTOR;

			$stm = $db->prepare($sql);
			
			$stm->bindParam(':codigoAutor',$autor->codigoAutor,PDO::PARAM_INT);
			$stm->bindParam(':nombreAutor',$autor->nombreAutor,PDO::PARAM_STR);
			$stm->bindParam(':usuario',$autor->usuario,PDO::PARAM_STR);
			$stm->bindParam(':status',$autor->status,PDO::PARAM_STR);

			$stm->execute();			
			$stm->closeCursor();
			
			$error = $stm->errorInfo();

			if ($error[2] != "") {
				$logger->write('spInsUpdLibro: '.$error[2], 3 );
			}

			$retorno = $db->query('SELECT @CodRetorno AS codRetorno, @msg AS msg, @msgSQL AS msgSQL80, @id AS id')->fetch(PDO::FETCH_ASSOC);
			$logger->write('codRetorno spInsUpdAutor:  '.$retorno['codRetorno'] ,6 );

			if ($retorno['msgSQL80'] != '' || $retorno['msgSQL80'] != null) {
				$logger->write('spInsUpdAutor: '.$retorno['msgSQL80'] , 3 );
				$retorno['Mensaje'] = MENSAJE_ERROR;
			}

			if ($retorno['codRetorno'] == "" ) {
				$retorno['codRetorno'] = '002';
				$retorno['Mensaje'] = MENSAJE_ERROR;
				return $retorno;
			}

			$db = null;

			return $retorno; 
		} catch (Exception $e) {
			$logger->write('guardarAutor: '.$e->getMessage() , 3 );
			print('Ocurrio un Error'.$e->getMessage());
		}
	}

	private function guardarEditorial($editorial){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
			$retorno = new ArrayObject();
			$db = new Conexion();

			$sql = SP_INSUPDEDITORIAL;

			$stm = $db->prepare($sql);
			
			$stm->bindParam(':codigoEditorial',$editorial->codigoEditorial,PDO::PARAM_INT);
			$stm->bindParam(':nombreEditorial',$editorial->nombreditorial,PDO::PARAM_STR);
			$stm->bindParam(':usuario',$editorial->usuario,PDO::PARAM_STR);
			$stm->bindParam(':status',$editorial->status,PDO::PARAM_STR);

			$stm->execute();			
			$stm->closeCursor();
			
			$error = $stm->errorInfo();

			if ($error[2] != "") {
				$logger->write('spInsUpdLibro: '.$error[2], 3 );
			}

			$retorno = $db->query('SELECT @CodRetorno AS codRetorno, @msg AS msg, @msgSQL AS msgSQL80, @id AS id')->fetch(PDO::FETCH_ASSOC);
			$logger->write('codRetorno spInsEditorial:  '.$retorno['codRetorno'] ,6 );

			if ($retorno['msgSQL80'] != '' || $retorno['msgSQL80'] != null) {
				$logger->write('spInsEditorial: '.$retorno['msgSQL80'] , 3 );
				$retorno['Mensaje'] = MENSAJE_ERROR;
			}

			if ($retorno['codRetorno'] == "" ) {
				$retorno['codRetorno'] = '002';
				$retorno['Mensaje'] = MENSAJE_ERROR;
				return $retorno;
			}

			$db = null;

			return $retorno; 
		} catch (Exception $e) {
			$logger->write('guardarEditorial: '.$e->getMessage() , 3 );
			print('Ocurrio un Error'.$e->getMessage());
		}
	}
}
?>