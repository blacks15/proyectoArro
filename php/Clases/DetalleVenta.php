<?php 
/*
	Clase Detalle Venta
	Autor: Felipe Monzón
	Fecha: 17-Jun-2017
*/
class DetalleVenta {
    private $folio;
    private $CodigoProducto;
    private $cantidad;
    private $precio;
    private $subtotal;

    function __construct($folio,$CodigoProducto,$cantidad,$precio,$subtotal){
        $this->folio = $folio;
        $this->CodigoProducto = $CodigoProducto;
        $this->cantidad = $cantidad;
        $this->precio = $precio;
        $this->subtotal = $subtotal;
    }

    public function getFolio(){
        return $this->Folio;
    }

    public function setFolio($folio){
        $this->folio = $folio;
    }    

    public function getCodigoProducto(){
        return $this->CodigoProducto;
    }

    public function setCodigoProducto($CodigoProducto){
        $this->CodigoProducto = $CodigoProducto;
    }

    public function getCantidad(){
        return $this->cantidad;
    }

    public function setCantidad($cantidad){
        $this->cantidad = $cantidad;
    }

    public function getPrecio(){
        return $this->precio;
    }

    public function setPrecio($precio){
        $this->precio = $precio;
    }

    public function getSubtotal(){
        return $this->subtotal;
    }

    public function setSubtotal($subtotal){
        $this->subtotal = $subtotal;
    }
}
?>