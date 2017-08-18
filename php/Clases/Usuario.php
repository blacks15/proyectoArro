<?php 
/*
	Clase Usuario
	Autor: Felipe Monzón
	Fecha: 23-ABR-2017
*/
class Usuario {
	private $clave;
	private $usuario;
	private $password;
	private $empleado;
	private $tipoUsuario;
	private $status;

	function __construct($clave = null,$usuario = null,$password = null ,$tipoUsuario = null,$status = null,$empleado = null) {
		$this->clave = $clave;
		$this->usuario = $usuario;
		$this->password = $password;
		$this->tipoUsuario = $tipoUsuario;
		$this->status = $status;
		$this->empleado = $empleado;
	}
		//GETTERS AND SETTERS
	public function getClave(){
		return $this->clave;
	}

	public function setClave($clave){
		$this->clave = $clave;
	}

	public function getUsuario(){
		return $this->usuario;
	}

	public function setUsuario($usuario){
		$this->usuario = $usuario;
	}

	public function getPassword() {
		return $this->password;
	}

	public function setPassword($password){
		$this->password = $password;
	}

	public function getTipoUsuario(){
		return $this->tipoUsuario;
	}

	public function setTipoUsuario($tipoUsuario){
		$this->tipoUsuario = $tipoUsuario;
	}

    public function getStatus(){
		return $this->status;
	}

	public function setStatus($status){
		$this->status = $status;
	}

	public function getEmpleado(){
		return $this->empleado;
	}

	public function setEmpleado($empleado){
		$this->empleado = $empleado;
	}
}
?>