<?php 
const TAMANIO_PAGINACION = '5';
    //RUTAS
const MODEL = '../Models/';
const CLASES = '../Clases/';
const RUTA_LOG = '../../log/';
    //FORMULARIOS 
const PRODUCTO = 'Producto';
const SESSION_CADUCADA = 'Sesión Caducada';
const PARAM_VACIOS = 'Parametros Vacios';
const MENSAJE_ERROR = 'Ocurrio un Error ';
const SIN_PERMISOS = 'No Cuenta con los permisos necesarios';
const SIN_DATOS = 'No Hay Datos Para Mostrar';
    //LOGIN
const LOGIN = 'Login';
const USUARIO_BLOQUEADO = 'Usuario Bloqueado Contacte con el Administrador';
const MSJ_CONTRASENIA_ACTUALIZADA = 'Contraseña Actualizada con Exito';
const ERROR_USUARIO = 'Usuario y/o Contraseña Incorrecto';
const MSG_CERRAR_SESSION = 'Auf Wiedersehen';
    //USUARIO
const USUARIO = 'Usuario';
const ERROR_CONTRASENIA = 'La contraeña y la confirmación de la contraseña no son iguales';
const USUARIO_NO_DISP = 'Usuario no disponible';
const USUARIO_EXITO = 'Usuario Guardado con Éxito';
CONST USUARIO_DESASOCIADO = 'Usuario Desasociado con Exito';
const ACTIVAR_USUARIO = 1;
const ELIMINAR_USUARIO = 2;
    //EMPLEADO
const EMPLEADO = 'Empleado';
    //CLIENTE
const CLIENTE = 'Cliente';
    //PROVEEDOR
const PROVEEDOR = 'Proveedor';
    //VENTA
const VENTA = 'Venta';
const ACTIVAR_VENTA = '1';
const ELIMINAR_VENTA = '2';
const PRODUCTO_INSUFICIENTE = 'Producto insuficiente para la venta';
const VENTA_EXITO = 'Venta Realizada con Éxito con Folio: ';
    //RETIRO
const RETIRO = 'Retiro';
    //LLAMADA SP'S
const SP_INSUPDEDITORIAL= "CALL spInsUpdEditorial(:codigoEditorial,:nombreEditorial,:usuario,:status,@codRetorno,@msg,@msgSQL,@id)";
const SP_INSUPDAUTOR = "CALL spInsUpdAutor(:codigoAutor,:nombreAutor,:usuario,:status,@codRetorno,@msg,@msgSQL,@id)";
const SP_INSUPDLIBROS = "CALL spInsUpdLibro(:codigoLibro,:nombreLibro,:isbn,:codigoAutor,:codigoEditorial,:descripcionLibro,:usuario,
				:status,:rutaIMG,@codRetorno,@msg,@msgSQL,@id)";
const SP_INSUPDPRODUCTO = "CALL spInsUpdProducto(:codigoProducto,:nombreProducto,:codigoBarras,:proveedor,:stActual,:stMin,:stMax,:compra,:venta,
				:categoria,:status,:isLibro,:usuario,@codRetorno,@msg,@msgSQL)";
const SP_CONSULTAPRODUCTOS = "CALL spConsultaProductos(:codigoProducto,:inicio,:limite,:tipoBusqueda,@codRetorno,@msg,@numFilas,@msgSQL)";
const SP_UPD_STOCK = "CALL spUpdStock(:codigoProducto,:stockActual,:status,@codRetorno,@msg,@msgSQL)";
const SP_VALIDAUSUARIO = "CALL spValidaUsuario(:nombreUsuario,:usuario,@codRetorno,@msg,@msgSQL)";
const SP_BLOQUEA_USUARIO = "CALL spBloqueaUsuario(:nombreUsuario,@codRetorno,@msg,@msgSQL)";
const SP_INSDELUSUARIO = "CALL spInsDelUsuarios(:codigoEmpleado,:nombreUsuario,:contrasenia,:tipo,:status,:bandera,@codRetorno,@msg,@msgSQL)";
const SP_CAMBIAR_PASSWORD = "CALL spCambiarPassword(:codigoEmpleado,:nombreUsuario,:contrasenia,@codRetorno,@msg,@msgSQL)";
const SP_INSUPDEMPLEADO = "CALL spInsUpdEmpleado(:codigoEmpleado,:nombreEmpleado,:apellidoPaterno,:apellidoMaterno,:calle,:numExt,:numInt,
                :colonia,:ciudad,:estado,:telefono,:celular,:sueldo,:puesto,:status,:isUsu,:usuario,@codRetorno,@msg,@msgSQL)";
const SP_CONSULTA_EMPLEADOS = "CALL spConsultaEmpleados(:codigoEmpleado,:inicio,:limite,@codRetorno,@msg,@numFilas,@msgSQL)";
const SP_INSUPDCLIENTE = "CALL spInsUpdCliente(:codigoCliente,:rfc,:nombreEmpresa,:nombreCliente,:apellidoPaterno,:apellidoMaterno,:calle,
                :numExt,:numInt,:colonia,:ciudad,:estado,:telefono,:celular,:email,:status,:usuario,@codRetorno,@msg,@msgSQL)";
const Sp_CONSULTA_CLIENTES = "CALL spConsultaClientes(:codigoCliente,:inicio,:limite,@codRetorno,@msg,@numFilas,@msgSQL)";
const SP_INSUPDPROVEEDORES = "CALL spInsUpdProveedor(:codigoCliente,:nombreEmpresa,:nombreContacto,:apellidoPaterno,:apellidoMaterno,:calle,
                :numExt,:numInt,:colonia,:ciudad,:estado,:telefono,:celular,:email,:web,:status,:usuario,@codRetorno,@msg,@msgSQL)";
const SP_CONSULTA_PROVEEDORES = "CALL spConsultaProveedores(:codigoProveedor,:inicio,:limite,@codRetorno,@msg,@numFilas,@msgSQL)";
const SP_INSDEL_VENTA =  "CALL spInsDelVenta(:folio,:cajero,:cliente,:total,:metodoPago,:foliotarjeta,:status,:usuario,:bandera,@codRetorno,@msg,@msgSQL)";
const SP_INSDEL_DETALLE_VENTA = "CALL spInsDetalleVenta(:folio,:codigoProducto,:cantidad,:precio,:subTotal,:bandera,@codRetorno,@msg,@msgSQL)";
const SP_RECUPERA_FOLIO = "CALL spRecuperaFolio(:tabla,:codigoEmpelado,@codRetorno,@msg,@msgSQL)";
?>