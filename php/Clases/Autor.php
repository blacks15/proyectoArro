<?php 
/*
	Clase Autor
	Autor: Felipe Monzón
	Fecha: 23-ABR-2017
*/
class Autor {
	
	private $codigoAutor;
	private $nombreAutor;
	private $status;

	function __construct($codigoAutor,$nombreAutor,$status) {
		$this->codigoAutor = $codigoAutor;
		$this->nombreAutor = $nombreAutor;
		$this->status = $status;
	}
		//GETTERS AND SETTERS
	public function getCodigoAutor(){
		return $this->codigoAutor;
	}

	public function setCodigoAutor($codigoAutor){
		$this->codigoAutor = $codigoAutor;
	}

	public function getNombreAutor(){
		return $this->nombreAutor;
	}

	public function setNombreAutor($nombreAutor){
		$this->nombreAutor = $nombreAutor;
	}

	public function getStatus(){
		return $this->status;
	}

	public function setStatus($status){
		$this->status = $status;
	}
}



?>