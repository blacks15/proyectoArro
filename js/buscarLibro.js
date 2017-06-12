$(document).ready(function() {
    /**************************
     *	   LLAMAR FUNCIONES    *
     **************************/
    //global.validaSesion();
    global.pagination('ControllerLibro', 1, 0, 0);
    global.isNotAdminMenu($("#tipoUsuario").val());
    $("#busqueda").focus();
    $("#busquedas").hide();
    //////////////////////////////////////////////////////
    /**************************
     *		BOTONOES		  *
     **************************/
    //BOTÓN REFRESCAR
    $("#btnRefresh").on('click', function() {
        global.cargarPagina('BuscarLibro');
    });
    //BOTÓN NUEVO LIBRO
    $("#btnNuevo").on('click', function() {
        global.cargarPagina("Libro");
    });
    //BOTÓN CREAR REPORTE
    $("#btnReporte").on('click', function() {
        global.imprimir();
    });
    //BOTÓN CERRAR MODAL
    $("#btnClose").on('click', function() {
        $("#modal").modal('close');
    });
    //BOTÓN BUSCAR
    $("#btnSearch").on('click', function(e) {
        e.preventDefault();
        $(this).prop('disabled', true);
        var buscar = $("#codigoLibro").val();
        var opc = $("#busqueda").val();
        //VALIDAMOS EL CMAPO BUSCAR
        if (buscar != "") {
            global.pagination('ControllerLibro', 1, buscar, opc);
            $('#pagination').hide();
        } else {
            global.mensajes('Advertencia', 'Campo Buscar vacio', 'warning', '', '', '');
        }

        $(this).prop('disabled', false);
    });
    /////////////////////////////////////////////////////////////////////////////
    /**************************
     *		EVENTOS			  *
     **************************/
    //OCULTA O MUESTRA CAMPOS PARA BUSQUEDA
    $("#busqueda").change(function() {
        //OBTENEMOS EL VALOR DEL SELECT Y LIMPIAMOS LOS CAMPOS
        var opc = $(this).val();
        var nombre = "";

        $("#buscar").val("");
        $("#codigoLibro").val('');
        //VALIDAMOS LA OPCIÓN SELECCIONADA 1 = NOMBRE , 2 = EMPRESA
        if (opc == 0) {
            $("#busquedas").hide('explode');
        } else if (opc == 1) {
            nombre = "libro";
        } else {
            nombre = "autor";
        }

        llamarAutocompletar(nombre);
    });
    //EVENTO KEYPRESS DEL CAMPO BUSCAR
    $("#buscar").on('keypress', function(evt) {
        var charCode = evt.which || evt.keyCode;

        if (charCode == 13) {
            $("#btnSearch").focus();
        } else {
            global.numerosLetras(evt);
        }
    });
    //EVENTO CHANGE DEL CAMPO BUSCAR
    $("#buscar").on('change', function(evt) {
        if ($(this).val().length == 0) {
            global.pagination('ControllerLibro', 1, 0);
            $('#pagination').show();
        }
    });
    //FUNCIÓN PARA CAMBIAR PÁGINACION
    $("#pagination").on('click', function() {
        $(".paginate").on('click', function() {
            var page = $(this).attr("data");
            global.pagination('ControllerLibro', page, 0);
        });
    });
    //FUNCIÓN PARA TOMAR EL BOTOÓN ACTUALIZAR DE LA TABLA
    $('#table').on('click', function() {
        array = [];
        $(".btnImage").on('click', function() {
            $(this).parents("tr").find("td").each(function() {
                array.push($(this).text());
            });

            $("#modal").modal('open');
            cargar_imagen(array[1]);
            $("#descripcionLibro").val(array[5]);

            array.length = 0;
        });
    });
    //FUNCIÓN PARA TOMAR EL BOTOÓN ACTUALIZAR DE LA TABLA
    $('#table').on('click', function() {
        array = [];
        $(".btnEditar").on('click', function(index) {
            $(this).parents("tr").find("td").each(function() {
                array.push($(this).text());
            });

            localStorage.clear();
            //CONVERTIMOS A JSON 
            localStorage.libros = JSON.stringify(array);
            global.cargarPagina('Libro');

            array.length = 0;
        });
    });
    /////////////////////////////////////////////////////////////////////////////////////
    /*********************************
     *			FUNCIONES			 *
     *********************************/
    //LLAMAR FUNCIÓN AUTOCOMPLETAR
    function llamarAutocompletar(opc) {
        $("#busquedas").show("explode");
        autocompletar(opc);
    }
    //FUNCIÓN AUTOCOMPLETAR
    function autocompletar(opc) {
        $("#buscar").autocomplete({
            minLength: 2,
            source: "php/autocomplete.php?opc=" + opc,
            autoFocus: true,
            select: function(event, ui) {
                console.log(ui.item);
                $('#codigoLibro').val(ui.item.id);
                return ui.item.label;
            },
            response: function(event, ui) {
                if (ui.content[0].label == null) {
                    var noResult = { value: "", label: "No Se Encontrarón Resultados" };
                    ui.content.push(noResult);
                }
            }
        });
    }
    //FUNCIÓN CARGAR IMAGEN
    function cargar_imagen(nombre) {
        //SE REEMPLAZA EL ESPACIO EN BLANCO 
        nombre = global.getCleanedString(nombre);
        //VALIDAMOS SI LA IMÁGEN EXISTE
        if (global.existeUrl('images/' + nombre + '.jpg') != true) {
            //MOSTRAR IMÁGEN SINO SE ENCONTRÓ LA SOLICITADA
            $("#imagen").fileinput('refresh', {
                previewFileType: "image",
                allowedFileExtensions: ["jpg", "png"],
                showCaption: false,
                showUpload: false,
                showRemove: false,
                showClose: false,
                overwriteInitial: false,
                initialPreviewAsData: true,
                initialPreview: [
                    '<img src=images/no_image.png class="file-preview-image">',
                ],
            });
        } else {
            //MOSTRAR IMÁGEN SOLICITADA
            $("#imagen").fileinput('refresh', {
                previewFileType: "image",
                allowedFileExtensions: ["jpg"],
                showCaption: false,
                showUpload: false,
                showRemove: false,
                showClose: false,
                overwriteInitial: false,
                initialPreview: [
                    '<img src="images/' + nombre + '.jpg" class="file-preview-image">',
                ],
            });
        }
    }
    //NECESARIO PARA CREAR LA MODAL
    $('.modal').modal({
        dismissible: true, // Modal can be dismissed by clicking outside of the modal
        opacity: .5, // Opacity of modal background
        in_duration: 300, // Transition in duration
        out_duration: 200, // Transition out duration
        starting_top: '10%', // Starting top style attribute
        ending_top: '25%', // Ending top style attribute
        complete: function() {
            $("#descripcionLibro").val("");
        }
    });
    //INICIALIZAR EL PLUGIN DE FILE-INPUT
    $("#imagen").fileinput({
        language: "es",
        showCaption: false,
        showUpload: false,
        previewFileType: "image",
        allowedFileExtensions: ["jpg"],
        elErrorContainer: "#errorBlock",
        browseClass: "btn green",
        browseLabel: "",
        browseIcon: "<i class=\"material-icons\">image</i> ",
        removeClass: "btn red",
        removeLabel: "",
        removeIcon: "<i class=\"material-icons\">delete</i> ",
    });
});