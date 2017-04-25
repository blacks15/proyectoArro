$(document).ready(function(){
	$("#user-name").html(sessionStorage.usuario);
	$("#tipoUsuario").val(sessionStorage.tipo);
	//global.cargarPagina("pages/Venta.html");
	global.cargarPagina("Autor");
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
		global.cerrarSesion('Auf Wiedersehen');
	});

	$("#inicio").on('click',function(){
		global.cargarPagina("pages/Inicio.html");
	});
		//////////////////////////
		//		MODULO VENTAS	//
		//////////////////////////

	$("#ventas").on('click',function(){
		global.cargarPagina("pages/Venta.html");
	});

	$("#buscarVenta").on('click',function(){
		global.cargarPagina("pages/BuscarVenta.html");
	});
		//////////////////////////
		//		MODULO LIRBOS	//
		//////////////////////////

	$("#libros").on('click',function(){
		global.cargarPagina("pages/Libro.html");
	});

	$("#buscarLibro").on('click',function(){
		global.cargarPagina("pages/BuscarLibro.html");
	});

	$("#autores").on('click',function(){
		global.cargarPagina("pages/Autor.html");
	});

	$("#editoriales").on('click',function(){
		global.cargarPagina("pages/Editorial.html");
	});
		//////////////////////////////////
		//		MODULO PROVEEDORES		//
		//////////////////////////////////

	$("#provedores").on('click',function(){
		global.cargarPagina("pages/Proveedor.html");
	});

	$("#buscarProveedor").on('click',function(){
		global.cargarPagina("pages/BuscarProveedor.html");
	});

	$("#productos").on('click',function(){
		global.cargarPagina("pages/Producto.html");
	});

	$("#buscarProductos").on('click',function(){
		global.cargarPagina("pages/BuscarProducto.html");
	});

	$("#modificarInventario").on('click',function(){
		global.cargarPagina("pages/Stock.html");
	});
		//////////////////////////////////
		//		MODULO EMPLEADOS		//
		//////////////////////////////////

	$("#empleados").on('click',function(){
		global.cargarPagina("pages/Empleado.html");
	});

	$("#buscarEmpleado").on('click',function(){
		global.cargarPagina("pages/BuscarEmpleado.html");
	});

	$("#usuarios").on('click',function(){
		global.cargarPagina("pages/Usuario.html");
	});

	$("#buscarUsuario").on('click',function(){
		global.cargarPagina("pages/BuscarUsuario.html");
	});
		//////////////////////////////////
		//		MODULO CLIENTES			//
		//////////////////////////////////

	$("#clientes").on('click',function(){
		global.cargarPagina("pages/Cliente.html");
	});

	$("#buscarClientes").on('click',function(){
		global.cargarPagina("pages/BuscarCliente.html");
	});
	/*
	$("#deudas").on('click',function(){
		global.cargarPagina("pages/Deuda.html");
	});

	$("#buscarDeudas").on('click',function(){
		global.cargarPagina("pages/BuscarDeuda.html");
	});

	$("#abonos").on('click',function(){
		global.cargarPagina("pages/Abono.html");
	});

	$("#buscarAbonos").on('click',function(){
		global.cargarPagina("pages/BuscarAbono.html");
	}); */
		//////////////////////////////////
		//		MODULO RETROS			//
		//////////////////////////////////

	$("#retiros").on('click',function(){
		global.cargarPagina("pages/Retiro.html");
	});

	$("#buscarRetiros").on('click',function(){
		global.cargarPagina("pages/BuscarRetiro.html");
	});

	$("#corteCaja").on('click',function(){
		global.cargarPagina("pages/CorteCaja.html");
	});

	$("#buscarCorteCaja").on('click',function(){
		global.cargarPagina("pages/BuscarCorteCaja.html");
	});
});