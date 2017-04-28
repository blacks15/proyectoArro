<?php 

/*
	Clase Usuario
	Autor: Felipe Monzón
	Fecha: 23-ABR-2017
*/

class Usuario {
	private $clave;
	private $usuario;
	private $tipoUsuario;
	private $status;

	function __construct($clave,$usuario,$tipoUsuario,$status) {
		$this->clave = $clave;
		$this->usuario = $usuario;
		$this->tipoUsuario = $tipoUsuario;
		$this->status = $status;
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