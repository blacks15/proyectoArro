$(document).ready(function() {
    $("#iVentas").on('click', function() {
        global.cargarPagina('Venta');
    });

    $("#iLibros").on('click', function() {
        global.cargarPagina('BuscarLibro');
    });

    $("#iProductos").on('click', function() {
        global.cargarPagina('BuscarProducto');
    });

    $("#iMovimientos").on('click', function() {
        global.cargarPagina('Retiro');
    });

    $("#iProveedores").on('click', function() {
        global.cargarPagina('BuscarProveedor');
    });

    $("#iClientes").on('click', function() {
        global.cargarPagina('BuscarCliente');
    });

    $("#iEmpleados").on('click', function() {
        global.cargarPagina('BuscarEmpleado');
    });

    $("#iReportes").on('click', function() {
        global.cargarPagina('Reportes');
    });
});