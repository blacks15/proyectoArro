<?php 
/*
	Clase Producto
	Autor: Felipe Monzón
	Fecha: 14-JUN-2017
*/
class Producto {
	private $codigo;
	private $codigoBarras;
	private $nombre_producto;
	private $proveedor;
	private $stockMin;
	private $stockMax;
	private $stockAct;
	private $precioCompra;
	private $precioVenta;
	private $categoria;
	private $status;

    function __construct($codigo = null,$codigoBarras = null,$nombre_producto = null,$proveedor = null,$stockMin = null,
    $stockMax = null,$stockAct = null,$precioCompra = null,$precioVenta = null,$categoria = null,$status = null){
		$this->codigo = $codigo;
		$this->codigoBarras = $codigoBarras;
		$this->nombre_producto = $nombre_producto;
		$this->proveedor = $proveedor;
		$this->stockMin = $stockMin;
		$this->stockMax = $stockMax;
		$this->stockAct = $stockAct;
		$this->precioCompra = $precioCompra;
		$this->precioVenta = $precioVenta;
		$this->categoria = $categoria;
		$this->status = $status;
	}

    public function getCodigo() {
        return $this->codigo;
    }

	public function setCodigo($codigo){
		return $this->codigo = $codigo;
	}

    public function getCodigoBarras(){
		return $this->codigoBarras;
	}

	public function setCodigoBarras($codigoBarras){
		return $this->codigoBarras = $codigoBarras;
	}

    public function getNombreProducto(){
        return $this->nombre_producto;
    }

    public function setNombreProducto($nombre_producto){
        return $this->nombre_producto = $nombre_producto;
    }

    public function getProveedor(){
        return $this->proveedor;
    }

    public function setProveedor($proveedor){
        $this->proveedor = $proveedor;
    }

    public function getStockMin() {
        return $this->stockMin;
    }

    public function setStockMin($stockMin){
        $this->stockMin = $stockMin;
    }

    public function getStockMax(){
        return $this->stockMax;
    }

    public function setStockMax($stockMax){
        return $this->stockMax = $stockMax;
    }

    public function getStockAct(){
        return $this->stockAct;
    }

    public function setStockAct($stockAct){
        return $this->stockAct = $stockAct;
    }

    public function getPrecioCompra(){
        return $this->precioCompra;
    }

    public function setPrecioCompra($precioCompra){
        return $this->precioCompra = $precioCompra;
    }

    public function getPrecioVenta(){
        return $this->precioVenta;
    }

    public function setPrecioVenta($precioVenta){
        return $this->precioVenta = $precioVenta;
    }

    public function getCategoria(){
        return $this->categoria;
    }

    public function setCategoria($categoria){
        $this->categoria = $categoria;
    }

    public function getStatus(){
        return $this->status;
    }

    public function setStatus($status){
        return $this->status = $status;
    }
}
?>