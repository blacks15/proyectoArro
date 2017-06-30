<?php 
/*
	Clase Detalle Venta
	Autor: Felipe Monzón
	Fecha: 17-Jun-2017
*/
class DetalleVenta {
    private $folio;
    private $codigoProducto;
    private $cantidad;
    private $precio;
    private $subtotal;
    private $stock;

    function __construct($folio,$codigoProducto,$cantidad,$precio,$subtotal,$stock){
        $this->folio = $folio;
        $this->codigoProducto = $codigoProducto;
        $this->cantidad = $cantidad;
        $this->precio = $precio;
        $this->subtotal = $subtotal;
        $this->stock = $stock;
    }

    public function getStock(){
        return $this->stock;
    }

    public function setStock($stock){
        $this->stock = $stock;
    }

    public function getFolio(){
        return $this->folio;
    }

    public function setFolio($folio){
        $this->folio = $folio;
    }    

    public function getCodigoProducto(){
        return $this->codigoProducto;
    }

    public function setCodigoProducto($codigoProducto){
        $this->codigoProducto = $codigoProducto;
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