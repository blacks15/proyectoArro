$(document).ready(function() {
    //global.validaSesion();
    $("#cantidad").focus(),
    $("#fecha").val(global.obtenerFechaActual());
    editarDatos();
    recuperarFolio();
    ///////////////////////////////////////////////////////////
    /**************************
     *		BOTONOES		  *
     **************************/
    //BOTÓN REFRESCAR
    $("#btnRefresh").on('click', function() {
        global.cargarPagina('Retiro');
    });
    //BOTÓN GUARDAR
    $("#btnSave").on('click', function() {
        enviarDatos('guardar');
    });
    //BOTÓN ACTUALIZAR
    $("#btnUpdate").on('click', function() {
        enviarDatos('guardar');
    });
    //BOTÓN ACTUALIZAR
    $("#btnDelete").on('click', function() {
        enviarDatos('borrar');
    });
    //BOTÓN BUSCAR
    $("#btnSearch").on('click', function(e) {
        e.preventDefault();
        $(this).prop('disabled', true);
        var buscar = $("#buscar").val();

        if (buscar == "") {
            $("#buscar").focus();
            global.mensajes('Advertencia', 'Campo Buscar vacio', 'warning', '', '', '', '');
        } else if (buscar.length < 13) {
            $("#buscar").focus();
            global.mensajes('Advertencia', 'El Folio Debe Ser Mayor a 13 Digitos', 'warning', '', '', '', '');
        } else {
            var respuesta = global.buscar('ControllerMovimientos', 'buscar', buscar, '');
            if (respuesta.codRetorno == '000') {
                $.each(respuesta.datos, function(index, value) {
                    $("#codigoRetiro").val(value.id);
                    $("#folio").val(value.folio);
                    $("#nombreEmpleado").val(value.nombreEmpleado);
                    $("#fecha").val(global.formatoFecha(value.fecha));
                    $("#cantidad").val(value.cantidad);
                    $("#descripcion").val(value.descripcion);
                });

                $("#buscar").val("");
                $("#btnUpdate").prop('disabled', false);
                $("#btnDelete").prop('disabled', false);
            }
        }

        $(this).prop('disabled', false);
    });
    /////////////////////////////////////////////////////////////////////////////
    /**************************
     *		  EVENTOS		  *
     **************************/
    //EVENTO KEYPRESS
    $("#cantidad").on('keypress', function(evt) {
        var charCode = evt.which || evt.keyCode;

        if (charCode == 13) {
            $("#descripcion").focus();
        } else {
            global.numeros(evt);
        }
    });
    //EVENTO KEYUP
    $("#cantidad").on('keyup', function(evt) {
        habilitarBoton();
    });
    //EVENTO KEYPRESS
    $("#descripcion").on('keypress', function(evt) {
        var charCode = evt.which || evt.keyCode;

        if (charCode == 13) {
            $("#btnSave").focus();
        } else {
            global.numerosLetras(evt);
        }
    });
    //EVENTO KEYUP
    $("#descripcion").on('keyup', function() {
        habilitarBoton();
    });
    //EVENTO KEYPRESS
    $("#buscar").on('keypress', function(evt) {
        var charCode = evt.which || evt.keyCode;

        if (charCode == 13) {
            $("#btnSearch").focus();
        } else {
            global.numeros(evt);
        }
    });
/////////////////////////////////////////////////////
        /**************************
        *		  FUNCIONES		  *
        **************************/
    function recuperarFolio() {
        var datos = global.cargaFolio('ControllerMovimientos', 'recuperaFolio','retiros');
        if (datos.codRetorno = '000') {
            $("#folio").val(datos.folio);
            $("#nombreEmpleado").val(datos.nombreEmpleado);
        }
    }
        //FUNCIÓN PARA ENVIAR DATOS
    function enviarDatos(opc) {
        $(this).prop('disabled', true);
        var cadena = $("#frmAgregarRetiro").serialize();
        var parametros = { opc: opc, cadena };

        if (cadena == "") {
            global.messajes('Error', '!Debe llenar Todos los Campos', 'warning', '', '', '', '');
        } else {
            global.envioAjax('ControllerMovimientos', parametros);
        }

        $(this).prop('disabled', false);
    }
        //FUNCIÓN PARA HABILITAR BOTÓN
    function habilitarBoton() {
        var id = $("#codigoRetiro").val();
        var cantidad = $("#cantidad").val();
        var descripcion = $("#descripcion").val();

        if (cantidad != "" && descripcion != "") {
            if (id == "") {
                $("#btnSave").prop('disabled', false);
            } else {
                $("#btnUpdate").prop('disabled', false);
            }
        }
    }
        //FUNCIÓN PARA EDITAR DATOS DESDE BUSCAR RETIROS
    function editarDatos() {
        var res = "";
        var resJson = "";

        if (localStorage.retiros != undefined) {
                //RECUPERAMOS LOS VALORES ALMACENADOS EN SESSION 
            res = localStorage.getItem('retiros');
                //CONVERTIMOS EL JSON A UN OBJETO
            resJson = JSON.parse(res);

            setTimeout(function() {
                    //ASGINAMOS VALORES A LOS INPUTS
                $("#codigoRetiro").val(resJson[0]);
                $("#folio").val(resJson[1]);
                $("#nombreEmpleado").val(resJson[2]);
                $("#cantidad").val(resJson[3]);
                $("#descripcion").val(resJson[4]);
                $("#fecha").val(resJson[5]);
                    //OCULTAMOS BOTON GUARDAR Y MOSTRAMOS MODIFICAR
                $("#btnUpdate").prop('disabled', false);
                    //VACIAMOS LA SESSION
                localStorage.clear();
            }, 300);
        }
    }
});