<?php 
require_once('funciones.php');
require_once('Usuario.php');
/*
	Clase: Implementación de Usuario
	Autor: Felipe Monzón
	Fecha: 10-May-2017
*/
class UsuarioImp {
	public function guardarUsuario($usuario){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
			$usuario->nombreUsuario = filter_var($usuario->nombreUsuario, FILTER_SANITIZE_STRING,FILTER_FLAG_NO_ENCODE_QUOTES|FILTER_FLAG_ENCODE_AMP);
			$usuario->contrasenia = filter_var($usuario->contrasenia, FILTER_SANITIZE_STRING,FILTER_FLAG_NO_ENCODE_QUOTES|FILTER_FLAG_ENCODE_AMP);
			$usuario->nombreUsuario = limpiarCadena($usuario->nombreUsuario);
			$usuario->contrasenia = limpiarCadena($usuario->contrasenia);
			$usuario->contrasenia = encrypta($usuario->contrasenia);
			$db = new Conexion();

			if (!isset($usuario) ) {
				$retorno->CodRetorno = '004';
				$retorno->Mensaje = PARAM_VACIOS;

				return $retorno;
				exit();
			}
				//LLAMADA DEL SP
			$sql = SP_INSDELUSUARIO;

			$stm = $db->prepare($sql);	
			$stm->bindParam(':codigoEmpleado',$usuario->codigoEmpleado,PDO::PARAM_INT);
			$stm->bindParam(':nombreUsuario',$usuario->nombreUsuario,PDO::PARAM_STR);
			$stm->bindParam(':contrasenia',$usuario->contrasenia,PDO::PARAM_STR);
			$stm->bindParam(':tipo',$usuario->tipo,PDO::PARAM_INT);
			$stm->bindParam(':status',$usuario->status,PDO::PARAM_STR);
			$stm->bindParam(':bandera',$usuario->bandera,PDO::PARAM_INT);

			$stm->execute();
			$stm->closeCursor();
			
			$error = $stm->errorInfo();

			if ($error[2] != "") {
				$logger->write('spInsDelUsuarios: '.$error[2], 3 );
			}

			$retorno = $db->query('SELECT @codRetorno AS codRetorno, @msg AS Mensaje, @msgSQL AS msgSQL80')->fetch(PDO::FETCH_ASSOC);
			$logger->write('codRetorno spInsDelUsuarios:  '.$retorno['codRetorno'] ,6 );

			if ($retorno['msgSQL80'] != '' || $retorno['msgSQL80'] != null) {
				$logger->write('spInsDelUsuarios: '.$retorno['msgSQL80'] , 3 );
				$retorno['Mensaje'] = MENSAJE_ERROR;
			}

			if ($retorno['codRetorno'] == "" ) {
				$retorno['codRetorno'] = '002';
				$retorno['Mensaje'] = MENSAJE_ERROR;
				return $retorno;
			}

			return $retorno;
		} catch (Exception $e) {
			$logger->write('guardarUsuario '.$e->getMessage() , 3 );	
			print(MENSAJE_ERROR.$e->getMessage());		
		}
	}

	public function validarUsuario($usuario){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {	
			$usuarioDB = "";
			$db = new Conexion();
			$datos = new ArrayObject();
			$objUsuario = new Usuario();
			$usuario = filter_var($usuario, FILTER_SANITIZE_STRING,FILTER_FLAG_NO_ENCODE_QUOTES|FILTER_FLAG_ENCODE_AMP);

			if ( !isset( $_SESSION['INGRESO']['nombre'] ) ) {
				$usuarioLog = $usuario;
			} else {
				$usuarioLog = $_SESSION['INGRESO']['nombre'];
			}

			$sql = SP_VALIDAUSUARIO;

			$stm = $db->prepare($sql);	
			$stm->bindParam(':nombreUsuario',$usuario,PDO::PARAM_STR);
			$stm->bindParam(':usuario',$usuarioLog,PDO::PARAM_STR);

			$stm->execute();
			$datos = $stm->fetch(PDO::FETCH_ASSOC);
			$stm->closeCursor();
			
			$error = $stm->errorInfo();

			if ($error[2] != "") {
				$logger->write('spValidaUsuario: '.$error[2], 3 );
			}

			$retorno = $db->query('SELECT @codRetorno AS codRetorno, @msg AS Mensaje, @msgSQL AS msgSQL80')->fetch(PDO::FETCH_ASSOC);
			$logger->write('codRetorno spValidaUsuario:  '.$retorno['codRetorno'] ,6 );

			if ($retorno['msgSQL80'] != '' || $retorno['msgSQL80'] != null) {
				$logger->write('spValidaUsuario: '.$retorno['msgSQL80'] , 3 );
				$retorno['Mensaje'] = MENSAJE_ERROR;
			}

			if ($retorno['codRetorno'] == "" ) {
				$retorno['codRetorno'] = '002';
				$retorno['Mensaje'] = MENSAJE_ERROR;
				return $retorno;
			}

			if ($retorno['codRetorno'] == '000') {
				$retorno['Datos'] = $datos;
				$usuarioDB = $datos['nombre_usuario'];

				if (strcmp($usuarioDB,$usuario) != 0) {
					$retorno['codRetorno'] = '002';
					$retorno['Mensaje'] = ERROR_USUARIO;
					return $retorno;
				}
				
				if ($datos['status'] == 'BLOQUEADO') {
					$retorno['codRetorno'] = '002';
					$retorno['Mensaje'] = USUARIO_BLOQUEADO;
				}
			}

			return $retorno;
		} catch (Exception $e) {
			$logger->write('validarUsuario '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());		
		}
	}

	public function eliminarUsuario($usuario){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
			$db = new Conexion();
			$usuario->nombreUsuario  = '';
			$usuario->contrasenia = '';
			$usuario->tipo = '';
			$usuario->status = '';

			$sql = SP_INSDELUSUARIO;

			$stm = $db->prepare($sql);	
			$stm->bindParam(':codigoEmpleado',$usuario->codigoEmpleado,PDO::PARAM_INT);
			$stm->bindParam(':nombreUsuario',$usuario->nombre,PDO::PARAM_STR);
			$stm->bindParam(':contrasenia',$usuario->contrasenia,PDO::PARAM_STR);
			$stm->bindParam(':tipo',$usuario->tipo,PDO::PARAM_INT);
			$stm->bindParam(':status',$usuario->status,PDO::PARAM_STR);
			$stm->bindParam(':bandera',$usuario->bandera,PDO::PARAM_INT);

			$stm->execute();
			$datos = $stm->fetch(PDO::FETCH_ASSOC);
			$stm->closeCursor();
			
			$error = $stm->errorInfo();

			if ($error[2] != "") {
				$logger->write('spInsDelUsuarios: '.$error[2], 3 );
			}

			$retorno = $db->query('SELECT @codRetorno AS codRetorno, @msg AS Mensaje, @msgSQL AS msgSQL80')->fetch(PDO::FETCH_ASSOC);
			$logger->write('codRetorno spInsDelUsuarios:  '.$retorno['codRetorno'] ,6 );

			if ($retorno['msgSQL80'] != '' || $retorno['msgSQL80'] != null) {
				$logger->write('spInsDelUsuarios: '.$retorno['msgSQL80'] , 3 );
				$retorno['Mensaje'] = MENSAJE_ERROR;
			}

			if ($retorno['codRetorno'] == "" ) {
				$retorno['codRetorno'] = '002';
				$retorno['Mensaje'] = MENSAJE_ERROR;
				return $retorno;
			}

			return $retorno;
		} catch (Exception $e) {
			$logger->write('eliminarUsuario '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());		
		}
	}

	public function cambiarContrasenia($usuario){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {	
			$db = new Conexion();
			$usuario->nombreUsuario = filter_var($usuario->nombreUsuario, FILTER_SANITIZE_STRING,FILTER_FLAG_NO_ENCODE_QUOTES|FILTER_FLAG_ENCODE_AMP);
			$usuario->contrasenia = filter_var($usuario->contrasenia, FILTER_SANITIZE_STRING,FILTER_FLAG_NO_ENCODE_QUOTES|FILTER_FLAG_ENCODE_AMP);
			$usuario->nombreUsuario = limpiarCadena($usuario->nombreUsuario);
			$usuario->contrasenia = limpiarCadena($usuario->contrasenia);
			$usuario->contrasenia = encrypta($usuario->contrasenia);
			
			$sql = SP_CAMBIAR_PASSWORD;

			$stm = $db->prepare($sql);	
			$stm->bindParam(':codigoEmpleado',$usuario->codigoEmpleado,PDO::PARAM_INT);
			$stm->bindParam(':nombreUsuario',$usuario->nombreUsuario,PDO::PARAM_STR);
			$stm->bindParam(':contrasenia',$usuario->contrasenia,PDO::PARAM_STR);

			$stm->execute();
			$datos = $stm->fetch(PDO::FETCH_ASSOC);
			$stm->closeCursor();
			
			$error = $stm->errorInfo();

			if ($error[2] != "") {
				$logger->write('spCambiarPassword: '.$error[2], 3 );
			}

			$retorno = $db->query('SELECT @codRetorno AS codRetorno, @msg AS Mensaje, @msgSQL AS msgSQL80')->fetch(PDO::FETCH_ASSOC);
			$logger->write('codRetorno spCambiarPassword:  '.$retorno['codRetorno'] ,6 );

			if ($retorno['msgSQL80'] != '' || $retorno['msgSQL80'] != null) {
				$logger->write('spCambiarPassword: '.$retorno['msgSQL80'] , 3 );
				$retorno['Mensaje'] = MENSAJE_ERROR;
			}

			if ($retorno['codRetorno'] == "" ) {
				$retorno['codRetorno'] = '002';
				$retorno['Mensaje'] = MENSAJE_ERROR;
				return $retorno;
			}

			return $retorno;
		} catch (Exception $e) {
			$logger->write('cambiarPasword '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());		
		}
	}	
}
?>