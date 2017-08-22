<?php 
/*
	Clase Venta
	Autor: Felipe Monzón
	Fecha: 14-JUN-2017
*/
class Venta {
	private $folio;
	private $fecha;
	private $cajero;
	private $cliente;
	private $total;
	private $metodoPago;
	private $folioTarjeta;
	private $status;

	function __construct($folio = null,$fecha = null,$cajero = null,$cliente = null,$total = null,$metodoPago = null,$folioTarjeta = null,$status = null){
		$this->folio = $folio;
		$this->fecha = $fecha;
		$this->cajero = $cajero;
		$this->cliente = $cliente;
		$this->total = $total;
		$this->metodoPago = $metodoPago;
		$this->folioTarjeta = $folioTarjeta;
		$this->status = $status;
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
		return $this->metodoPago = $metodoPago;
	}	 

	public function getTotal() {
		return $this->total;
	}

    public function setTotal($total){
		return $this->total = $total;
	}	

	public function getFolioTarjeta() {
		return $this->folioTarjeta;
	}

    public function setFolioTarjeta($folioTarjeta){
		return $this->folioTarjeta = $folioTarjeta;
	}	

}

?>