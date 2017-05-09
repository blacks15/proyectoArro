$(document).ready(function(){
	$("#user-name").html(sessionStorage.usuario);
	$("#tipoUsuario").val(sessionStorage.tipo);
	//global.cargarPagina("pages/Venta.html");
	global.cargarPagina("Cliente");
	global.isNotAdminMenu($("#tipoUsuario").val());

	$('.button-collapse').sideNav({});

	$(".dropdown-button").dropdown({
		belowOrigin: true,
		alignment: 'left'
	});

	$('*').bind("cut copy paste",function(e) {
		e.preventDefault();
	});
////////////////////////////////////////////////////
 	/**************************
    *	 		MENÚ		  *
    **************************/

	$("#CerrarSesion").on('click',function(){
		global.envioAjax('ControllerLogin',{opc:'cerrarSession'});
	});

	$("#inicio").on('click',function(){
		global.cargarPagina("Inicio");
	});
		//////////////////////////
		//		MODULO VENTAS	//
		//////////////////////////

	$("#ventas").on('click',function(){
		global.cargarPagina("Venta");
	});

	$("#buscarVenta").on('click',function(){
		global.cargarPagina("BuscarVenta");
	});
		//////////////////////////
		//		MODULO LIRBOS	//
		//////////////////////////

	$("#libros").on('click',function(){
		global.cargarPagina("Libro");
	});

	$("#buscarLibro").on('click',function(){
		global.cargarPagina("BuscarLibro");
	});

	$("#autores").on('click',function(){
		global.cargarPagina("Autor");
	});

	$("#editoriales").on('click',function(){
		global.cargarPagina("Editorial");
	});
		//////////////////////////////////
		//		MODULO PROVEEDORES		//
		//////////////////////////////////

	$("#provedores").on('click',function(){
		global.cargarPagina("Proveedor");
	});

	$("#buscarProveedor").on('click',function(){
		global.cargarPagina("BuscarProveedor");
	});

	$("#productos").on('click',function(){
		global.cargarPagina("Producto");
	});

	$("#buscarProductos").on('click',function(){
		global.cargarPagina("BuscarProducto");
	});

	$("#modificarInventario").on('click',function(){
		global.cargarPagina("Stock");
	});
		//////////////////////////////////
		//		MODULO EMPLEADOS		//
		//////////////////////////////////

	$("#empleados").on('click',function(){
		global.cargarPagina("Empleado");
	});

	$("#buscarEmpleado").on('click',function(){
		global.cargarPagina("BuscarEmpleado");
	});

	$("#usuarios").on('click',function(){
		global.cargarPagina("Usuario");
	});

	$("#buscarUsuario").on('click',function(){
		global.cargarPagina("BuscarUsuario");
	});
		//////////////////////////////////
		//		MODULO CLIENTES			//
		//////////////////////////////////

	$("#clientes").on('click',function(){
		global.cargarPagina("Cliente");
	});

	$("#buscarClientes").on('click',function(){
		global.cargarPagina("BuscarCliente");
	});
	/*
	$("#deudas").on('click',function(){
		global.cargarPagina("Deuda");
	});

	$("#buscarDeudas").on('click',function(){
		global.cargarPagina("BuscarDeuda");
	});

	$("#abonos").on('click',function(){
		global.cargarPagina("Abono");
	});

	$("#buscarAbonos").on('click',function(){
		global.cargarPagina("BuscarAbono");
	}); */
		//////////////////////////////////
		//		MODULO RETROS			//
		//////////////////////////////////

	$("#retiros").on('click',function(){
		global.cargarPagina("Retiro");
	});

	$("#buscarRetiros").on('click',function(){
		global.cargarPagina("BuscarRetiro");
	});

	$("#corteCaja").on('click',function(){
		global.cargarPagina("CorteCaja");
	});

	$("#buscarCorteCaja").on('click',function(){
		global.cargarPagina("BuscarCorteCaja");
	});
});