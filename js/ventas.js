$(document).ready(function() {
    //global.validaSesion();
    $("#fechaVenta").val(global.obtenerFechaActual());
    $("#codigoProducto1").focus();
    $('ul.tabs').tabs();
    $("#folTarj").hide('slow');
    recuperarFolio();
    /////////////////////////////////////////////////////////////
    /**************************
     *		BOTONES			  *
     **************************/
    //BOTÓN COBRAR
    $("#btnPagar").on('click', function() {
        $('#modal2').modal('open');
    });
    //BOTÓN AGREGAR PRODUCTO
    $("#agregar").on('click', function(e) {
        e.preventDefault();
        modalCantidad();
    });
    //BOTÓN QUITAR PRODUCTO
    $("#quitar").on('click', function() {
        limpiarCampos();
        habilitar();
        $("#agregar").prop('disabled', true);
        $("#quitar").prop('disabled', true);
        $("#codigoProducto").focus();
    });
    //BOTÓN PAGAR
    $("#btnSave").on('click', function() {
        var datos = $("#datos").tableToJSON();
        var folio = $("#folio").val();
        var metPago = $("#metPago").val();
        var folTarj = $("#folioTarjeta").val();
        var total = $("#total").val();
        var cliente = $("#codigoCliente").val();
        var id = $("#codigoEmpleado").val();
        var datos = JSON.stringify(datos);

        var parametros = { opc: 'guardar', datos: datos, metodo: metPago, folTarj: folTarj, folio: folio, total: total, id: id, cliente: cliente };

        if (datos == "" && folio == "" && metPago == "") {
            global.messajes('Error', '!Debe llenar Todos los Campos', 'warning', '', '', '', '');
        } else {
            global.envioAjax('ControllerVenta', parametros);
        }
    });
    //BOTÓN SIGUIENTE TAB
    $("#btnSig").click(function() {
        $('ul.tabs').tabs('select_tab', 'pagar');
        $("#btnSave").focus();
    });
    //BOTÓN ANTERIOR TAB
    $("#btnAnt").click(function() {
        $('ul.tabs').tabs('select_tab', 'metodoPago');
        $("#metPago").focus();
    });
    /////////////////////////////////////////////////////////////
    /**************************
     *		EVENTOS			  *
     **************************/
    //AUTOCOMPLETAR CAMPO LIBRO
    $("#codigoProducto1").on('keyup', function(evt) {
        evt.preventDefault();
        var charCode = evt.which || evt.keyCode;
        if (charCode == 13 && $(this).val().length > 0) {
            var respuesta = global.buscar('ControllerProducto', 'buscar', $(this).val(), 1);
            //VALIDAMOS LA RESPUESTA
            if (respuesta.codRetorno == '000') {
                $.each(respuesta.datos, function(index, value) {
                    setTimeout(function() {
                        $("#codigoProducto").val(value.id);
                        $("#nombreProducto").val(value.nombreProducto);
                        $("#precioProducto").val(value.venta);
                        $("#cantidadProducto").val(value.stActual);

                        $("#agregar").prop('disabled', false);
                        $("#quitar").prop('disabled', false);
                        $("#agregar").focus();
                        deshabilitar();
                    }, 300);
                });
            }
        }
    });
    //AUTOCOMPLETAR CAMPO LIBRO
    $("#nombreProducto").autocomplete({
        minLength: 2,
        source: "php/autocomplete.php?opc=producto&id=1",
        autoFocus: true,
        select: function(event, ui) {
            if (ui.item.value != "" && ui.item.status != 'AGOTADO') {
                $('#codigoProducto').val(ui.item.id);
                $('#precioProducto').val(ui.item.precio);
                $("#cantidadProducto").val(ui.item.stActual);
                $("#codigoProducto1").val(ui.item.codigoBarras);
                $("#agregar").prop('disabled', false);
                $("#quitar").prop('disabled', false);
                $("#agregar").focus();
                deshabilitar();
            } else {
                habilitar();
            }
            return ui.item.label;
        },
        response: function(event, ui) {
            if (ui.content[0].label == null) {
                var noResult = { value: "", label: "No Se Encontrarón Resultados" };
                ui.content.push(noResult);
            }
        }
    });
    //AUTOCOMPLETAR CAMPO LIBRO
    $("#nombreCliente").autocomplete({
        minLength: 2,
        source: "php/autocomplete.php?opc=cliente",
        autoFocus: true,
        select: function(event, ui) {
            if (ui.item.value != "") {
                $('#codigoCliente').val(ui.item.id);
            }
            return ui.item.label;
        },
        response: function(event, ui) {
            if (ui.content[0].label == null) {
                var noResult = { value: "", label: "No Se Encontrarón Resultados" };
                ui.content.push(noResult);
            }
        }
    });
    //KEYPRESS
    $("#cantprod").on('keypress', function(evt) {
        var charCode = evt.which || evt.keyCode;

        if (charCode != 13) {
            global.numeros(evt);
        } else {
            $("#btnAgregar").focus();
        }
    });
    //CHANGE
    $("#cantprod").on('change', function(evt) {
        //VALIDAMOS QUE LA CANTIDAD SEA MAYOR QUE CERO
        if ($(this).val() > 0) {
            var precio = $("#precio").val();
            var subtotal = precio * $(this).val();

            $("#subtotal").val(subtotal);
        }
    });
    //CHANGE
    $("#metPago").on('change', function(evt) {
        //VALIDAMOS QUE LA CANTIDAD SEA MAYOR QUE CERO
        if ($(this).val() == 2) {
            $("#folTarj").show('slow');
        } else {
            $("#folTarj").hide('slow');
        }
    });
    //KEYPRESS
    $("#folioTarjeta").on('keypress', function(evt) {
        var charCode = evt.which || evt.keyCode;

        if (charCode != 13) {
            global.numeros(evt);
        }
    });
    /////////////////////////////////////////////////////////////
    /**************************
     *		FUNCIONES		  *
     **************************/
    //FUNCIÓN PARA RECUPERAR EL FOLIO ACTUAL
    function recuperarFolio() {
        var datos = global.cargaFolio('ControllerMovimientos', 'recuperaFolio', 'ventas');
        if (datos.codRetorno = '000') {
            $("#folio").val(datos.folio);
            $("#nombreEmpleado").val(datos.nombreEmpleado);
            $("#codigoEmpleado").val(datos.matricula);
        }
    }
    //FUNCIÓN PARA LIMPIAR CAMPOS
    function limpiarCampos() {
        $("#codigoProducto1").val('');
        $("#codigoProducto").val('');
        $("#nombreProducto").val('');
        $("#precioProducto").val('');
        $("#cantidadProducto").val('');
    }
    //FUNCIÓN PARA DESHABILITAR CAMPOS
    function deshabilitar() {
        $("#codigoProducto1").prop('disabled', true);
        $("#nombreProducto").prop('disabled', true);
    }
    //FUNCIÓN PARA DESHABILITAR CAMPOS
    function habilitar() {
        $("#codigoProducto1").prop('disabled', false);
        $("#nombreProducto").prop('disabled', false);
        $("#codigoProducto1").focus();
    }
    //FUNCIÓN MODALCANTIDAD
    function modalCantidad() {
        //MODAL CON INPUT
        setTimeout(function() {
            swal({
                title: 'Cantidad Producto',
                input: 'text',
                showCancelButton: false,
                allowEscapeKey: false,
                allowOutsideClick: false,
                inputValidator: function(value) {
                    return new Promise(function(resolve, reject) {
                        if (!isNaN(value) && value != "" && value > 0) {
                            if (parseInt(value) > $("#cantidadProducto").val()) {
                                global.mensajes('Advertencia', 'Producto insuficiente para la venta', 'info', '', '', '', '');
                            } else {
                                resolve()
                            }
                        } else {
                            reject('Necesita escribir una cantidad mayor a cero !')
                        }
                    })
                }
            }).then(function(result) {
                $("#cantidad").val(result);
                agregarGrid();
            });
        }, 150);
    }
    //FUNCIÓN PARA PINTAR FILA EN LA TABLA
    function agregarGrid() {
        var id = $("#codigoProducto1").val();
        var nombre = $("#nombreProducto").val();
        var precio = $("#precioProducto").val();
        var cantidad = $("#cantidad").val();
        var subtotal = precio * cantidad;
        var data = Array();
        var j = $("#índice").val();
        var total = $("#total").val();
        //LLENARA ARRAY CON DOS DE LA TABLA
        $("table tr").each(function(i, v) {
            data[i] = Array();
            $(this).children('td').each(function(ii, vv) {
                data[i][ii] = $(this).text();
            });
        });
        //VALIDAR SI EL PRODUCTO EXISTE
        for (var i = 0; i < data.length; i++) {
            if (data[i][0] == id) {
                global.mensajes('Advertencia', 'El Producto ya fue agregado', 'info', '', '', '', '');
                limpiarCampos();
                habilitar();
                return;
            }
        }
        //VALIDAR EL CONTADOR	
        if (j == "") {
            j = 0;
        } else {
            j += 1;
        }
        //SACAMSO EL TOTAL
        if (total == "") {
            total = 0;
        }
        total = parseInt(total) + parseInt(subtotal);
        //ASIGNAMOS EL INDICE
        $("#índice").val(j);
        $("#total").val(total);
        //AGREGAR DATOS A LA TABLA
        $("#tabla").append("<tr id=" + j + "><td width='20%'><p class='center' id=i" + j + ">" + id +
            "</p></td><td width='40%'><p class='center' id=n" + j + ">" + nombre + "</p></td><td width='10%'><p class='center' id=c" + j + ">" + cantidad +
            "</p></td><td width='10%'><p class='center' id=p" + j + ">" + precio + "</p></td><td width='10%'><p class='center' id=st" + j + ">" + subtotal +
            "</p></td><td><a href='#'><img class='icon-editar btnEditar' width='30' height='30' data=" + j + "></a> \
			</td><td><a href='#'><img class='icon-delProd24 btnEliminar' width='30' height='30' data=" + j + "></a>\
			</td></tr>"
        );
        //LLAMAR FUNCIONES
        limpiarCampos();
        habilitar();

        data.clear;
        $("#agregar").prop('disabled', true);
        $("#quitar").prop('disabled', true);
        $("#btnPagar").prop('disabled', false);
        sumarTotal();
    }
    //FUNCIÓN PARA TOMAR EL BOTOÓN ACTUALIZAR DE LA TABLA
    $('#tabla').on('click', function() {
        var array = [];
        $(".btnEditar").on('click', function(index) {
            var page = $(this).attr("data");

            $(this).parents("tr").find("td").each(function() {
                array.push($(this).text());
            });

            $('#modal').modal('open');

            $("#cantprod").focus();
            $("#id").val(page);
            $("#codigo").val(array[0]);
            $("#nombre").val(array[1]);
            $("#cantprod").val(array[2]);
            $("#precio").val(array[3]);
            $("#subtotal").val(array[4]);

            sumarTotal();

            array.length = 0;
        });
    });
    //FUNCIÓN PARA TOMAR EL BOTOÓN ELIMINAR DE LA TABLA
    $('#tabla').on('click', function() {
        $(".btnEliminar").on('click', function(index) {
            $(this).closest('tr').remove();
            sumarTotal();
        });
    });
    //BOTÓN MODIFICAR FILA DE LA TABLA
    $("#btnAgregar").on('click', function() {
        array = [];
        var id = $("#id").val();
        array[0] = $("#cantprod").val();
        array[1] = $("#subtotal").val();

        editarFila(id, array);
    });
    //FUNCIÒN EDITAR FILA DE LA TABLA
    function editarFila(no, datos) {
        $('#modal').modal('close');
        var cant = document.getElementById("c" + no);
        var subtotal = document.getElementById("st" + no);

        cant.innerHTML = datos[0];
        subtotal.innerHTML = datos[1];
        sumarTotal();
    }
    //FUNCIÓN PARA SUMAR EL TOTAL
    function sumarTotal() {
        var total = document.getElementById("txtTotal");
        var suma = 0.0;

        $('#datos tr ').each(function() { //filas con clase 'dato', especifica una clase, asi no tomas el nombre de las columnas
                suma += parseInt($(this).find('td').eq(4).text() || 0, 10)
            })
            //console.log(suma)
        total.innerHTML = " $ " + suma;
        $("#total").val(suma);
    }
    /////////////////////////////////////////////////////////////
    /**************************
     *		TOOLTIP			  *
     **************************/
    //SE CREA TOOLTIP
    $('.tooltipped').tooltip({
        delay: 50,
        tooltip: "Quitar Producto",
        position: 'right',
    });
    //SE CREA TOOLTIP2
    $('.tooltipped2').tooltip({
        delay: 50,
        tooltip: "Agrega Producto",
        position: 'right',
    });
    //CREAMOS LA MODAL
    $('#modal2').modal({
        dismissible: true, // Modal can be dismissed by clicking outside of the modal
        opacity: .5, // Opacity of modal background
        in_duration: 300, // Transition in duration
        out_duration: 200, // Transition out duration
        starting_top: '15%', // Starting top style attribute
        ending_top: '15%', // Ending top style attribute
        ready: function(modal, trigger) { // Callback for Modal open. Modal and trigger parameters available.
            $("#metPago").focus();
        },
        complete: function() {
                $("#metPago").val("");
            } // Callback for Modal close
    });
    //CREAMOS LA MODAL
    $('#modal').modal({
        dismissible: true, // Modal can be dismissed by clicking outside of the modal
        opacity: .5, // Opacity of modal background
        in_duration: 300, // Transition in duration
        out_duration: 200, // Transition out duration
        starting_top: '10%', // Starting top style attribute
        ending_top: '10%', // Ending top style attribute
        ready: function(modal, trigger) { // Callback for Modal open. Modal and trigger parameters available.
            $("#cantprod").focus();
        },
        complete: function() {
            $("#codigo").val("");
            $("#nombre").val("");
            $("#id").val("");
            $("#cantprod").val("");
            $("#precio").val("");
            $("#subtotal").val("");
        }
    });
});