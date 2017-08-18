<?php 
require_once(CLASES.'Login.php');
require_once(CLASES.'Usuario.php');
require_once(CLASES.'UsuarioImp.php');
/*
	Clase: Model de Autor
	Autor: Felipe Monzón
	Fecha: 23-ABR-2017
*/
class UsuarioModel {
	public function inicioSesion($login){
		$objLogin = new Login();
		$objUsuario = new Usuario();
		$response = new ArrayObject();
		
		$res = $objLogin->loginUs($login->usuario,$login->password); 

		if ($res->Mensaje == 'EXITO') {
			$objUsuario = $res->datos;
			if ($objUsuario->getStatus() == 'DISPONIBLE') {
				$response->CodRetorno = '000';
				$response->NumEmp = $objUsuario->getClave();
				$response->Nombre = $objUsuario->getUsuario();
				$response->Tipo = $objUsuario->getTipoUsuario();
			} else {
				$response->CodRetorno = '001';
				$response->Mensaje = USUARIO_BLOQUEADO;
			}
		} else {
			$response->CodRetorno = '002';
			$response->Mensaje = $res->Mensaje;
		}

		return $response;
	}

	public function guardarUsuario($usuario){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
			$res = new ArrayObject();
			$retorno = new ArrayObject();
			$usuarioImp = new UsuarioImp();

			if (!isset($usuario) ) {
				$retorno->CodRetorno = '004';
				$retorno->Mensaje = PARAM_VACIOS;

				return $retorno;
				exit();
			}

			$res = $usuarioImp->guardarUsuario($usuario); 

			if ($res['codRetorno']  == '000') {
				$retorno->CodRetorno = $res['codRetorno']  ;
				$retorno->Mensaje = USUARIO_EXITO;
			} else {
				$retorno->CodRetorno = $res['codRetorno'];
				$retorno->Mensaje = $res['Mensaje'];
			}

			return $retorno;
		} catch (Exception $e) {
			$logger->write('buscarUsuario '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());	
		}
	}

	public function validaUsuario($usuario){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
			$response = new ArrayObject();
			$usuarioImp = new UsuarioImp();
			$objUsuario = new ArrayObject();

			if (!isset($usuario) ) {
				$retorno->CodRetorno = '004';
				$retorno->Mensaje = PARAM_VACIOS;

				return $retorno;
				exit();
			}

			$res = $usuarioImp->validarUsuario($usuario); 

			if ($res['codRetorno'] == '000') {
				$objUsuario = $res['Datos'];
				$response->CodRetorno = '000';
				$response->Id = $objUsuario['matricula_empleado'];
				$response->Usuario = $objUsuario['nombre_usuario'];
				$response->Tipo = $objUsuario['tipo_usuario'];
				$response->NombreEmpleado = $objUsuario['nombreEmpleado'];
				$response->Status = $objUsuario['status'];
			} else {
				$response->CodRetorno = $res['codRetorno'];
				$response->Mensaje = $res['Mensaje'];
			}

			return $response;
		} catch (Exception $e) {
			$logger->write('buscarUsuario '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());	
		}
	}

	public function cambiarPassword($usuario) {
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try {
			$usuarioImp = new UsuarioImp();
			$respuesta = new ArrayObject();
			$isValido = new ArrayObject();
			$resPass = new ArrayObject();

			if (!isset($usuario->codigoEmpleado,$usuario->nombreUsuario,$usuario->contrasenia) ) {
				$respuesta->CodRetorno = '004';
				$respuesta->Mensaje = PARAM_VACIOS;

				return $respuesta;
				exit();
			}

			$isValido = $usuarioImp->validarUsuario($usuario->nombreUsuario); 

			if ($isValido['codRetorno'] == '000') {
				$resPass = $usuarioImp->cambiarContrasenia($usuario); 

				if ($resPass['codRetorno'] == '000') {
					$respuesta->CodRetorno = $resPass['codRetorno'];
					$respuesta->Mensaje = MSJ_CONTRASENIA_ACTUALIZADA;
				} else {
					$respuesta->CodRetorno = $resPass['codRetorno'];
					$respuesta->Mensaje = $resPass['Mensaje'];
				}
			} else {
				$respuesta->CodRetorno = $isValido['codRetorno'] ;
				$respuesta->Mensaje = $isValido['Mensaje'];
			}

			return $respuesta;
		} catch (Exception $e) {
			$logger->write('buscarUsuario '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());	
		}
	}

	public function eliminarUsuario($usuario){
		$logger = new PHPTools\PHPErrorLog\PHPErrorLog();
		try{
			$usuarioImp = new UsuarioImp();
			$respuesta = new ArrayObject();
			$isValido = new ArrayObject();
			$respDel = new ArrayObject();
			
			$isValido = $usuarioImp->validarUsuario($usuario->nombre); 

			if ($isValido['codRetorno'] == '000') {
				$respDel = $usuarioImp->eliminarUsuario($usuario);

				if ($respDel['codRetorno'] == '000') {
					$respuesta->CodRetorno = $respDel['codRetorno'];
					$respuesta->Mensaje = USUARIO_DESASOCIADO;
				} else {
					$respuesta->CodRetorno = $respDel['codRetorno'];
					$respuesta->Mensaje = $respDel['Mensaje']; 
				}
			} else {
				$respuesta->CodRetorno = $isValido['codRetorno'];
				$respuesta->Mensaje = $isValido['Mensaje']; 
			}

			return $respuesta;
		} catch (Exception $e) {
			$logger->write('buscarUsuario '.$e->getMessage() , 3 );
			print(MENSAJE_ERROR.$e->getMessage());	
		}
	}
}
?>