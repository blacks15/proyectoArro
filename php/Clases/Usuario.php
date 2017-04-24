<?php 

/*
	Clase Usuario
	Autor: Felipe Monzón
	Fecha: 23-ABR-2017
*/

class Usuario {
	private $usuario;
	private $password;
	private $tipoUsuario;
	private $status;
	
	function __construct($usuario,$password,$tipoUsuario) {
		$this->usuario = $usuario;
		$this->password = $password;
		$this->tipoUsuario = $tipoUsuario;
		$this->status = $status;
	}
		//GETTERS AND SETTERS
	public function getUsuario(){
		return $this->usuario;
	}

	public function setUsuario($usuario){
		$this->usuario = $usuario;
	}

	public function getPassword(){
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
}
?>