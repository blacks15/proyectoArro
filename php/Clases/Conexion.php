 <?php 
	class Conexion extends PDO { 
		private $tipo_de_base = 'mysql';
		private $host = 'localhost';
		private $nombre_de_base = 'ventas';
		private $usuario = 'root';
		private $contrasena = ''; 
		private $error = ''; 

		public function __construct() {
			try {
				parent::__construct($this->tipo_de_base.
					':host='.$this->host.
					';dbname='.$this->nombre_de_base,
					$this->usuario,
					$this->contrasena
				);
				//parent::setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
			} catch (PDOException $e){
				$salidaJson = array(
					'error' => $e->getMessage(),
					'isError' => 1
				);
				print ($salidaJson['isError']);
			}
		} 
	} 
?>