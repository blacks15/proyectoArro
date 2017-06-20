<?php 
/*
	Clase Venta
	Autor: Felipe Monzón
	Fecha: 14-JUN-2017
*/
class Venta {
	private $folio;
	private $fecha;
	private $status;
	private $cajero;
	private $cliente;
	private $metodoPago;

	function __construct($folio,$fecha,$cajero,$status,$cliente,$status,$metodoPago){
		$this->folio = $folio;
		$this->fecha = $fecha;
		$this->cajero = $cajero;
		$this->status = $status;
		$this->cliente = $cliente;
		$this->metodoPago = $metodoPago;
	}		

	public function getFolio() {
		return $this->folio;
	}

    public function setFolio($folio) {
		return $this->folio = $folio;
    }

	public function getFecha() {
		return $this->fecha;
	}

	public function setFecha($fecha){
		return $this->fecha = $fecha;
	}

	public function getStatus() {
		return $this->status;
	}

	public function setStatus($status) {
		return $this->status = $status;
	}

	public function getCajero() {
		return $this->cajero;
	}

	public function setCajero($cajero){
		return $this->cajero = $cajero;
	}

	public function getCliente() {
		return $this->cliente;
	}

    public function setCliente($cliente){
		return $this->cliente = $cliente;
	}

	public function getMetodoPago() {
		return $this->metodoPago;
	}

    public function setMetodoPago($metodoPago){
		return $this->$metodoPago = $metodoPago;
	}	 
}

?>