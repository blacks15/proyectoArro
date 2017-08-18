
$(document).ready(function(){
    /**************************
     *	 LLAMAR FUNCIONES	   *
     **************************/
    //global.validaSesion();
    global.isAdmin();

    $('ul.tabs').tabs();

    llenarCombo();
    actualizarLibro();
        //MASCARA DE PESOS
    $('#compra').mask("#,##0.00", {reverse: true});
    $('#venta').mask("#,##0.00", {reverse: true});
    /**************************
    *		BOTONOES		  *
    **************************/
    //BOTÓN NUEVO AUTOR
    $("#btnSearch").on('click', function(e) {
        e.preventDefault();
        $("#btnSearch").prop('disabled', true);
        var buscar = $("#codigoProducto").val();

        if (buscar != "") {
            $("#codigoLibro").val('');
            $("#buscar").val('');

            var respuesta = global.buscar('ControllerProducto', 'buscar', buscar, '2');

            if (respuesta.codRetorno == '000') {
                if (respuesta.productos.length != 0) {
                    llenarDatos(respuesta.productos);
                    $("#nuevo").prop('checked',true);
                    nextTab('inventario');
                } else {
                    llenarDatos(respuesta.libros);
                    $("#btnSigPaso3").prop('disabled', false);
                    $("#libro").prop('checked',true);
                    nextTab('producto');
                }

                $("#btnUpdate").prop('disabled', false);
            }
        } else {
            global.mensajes('Advertencia', 'Campo Buscar vacio', 'warning');
        }
        $("#btnSearch").prop('disabled', false);
    });
        //BOTÓN GUARDAR
    $("#btnSave").on('click', function() {
        enviarDatos();
    });
    //BOTÓN ACTUALIZAR
    $("#btnUpdate").on('click', function() {
        enviarDatos();
    });
    //BOTÓN CREAR REPORTE
    $("#btnReporte").on('click', function() {
        alert("hola salvaje");
    });
    //BOTÓN ELIMINAR
    $("#btnDelete").on('click', function(e) {
        e.preventDefault();
        alert("hola salvaje");
    });
    //BOTÓN REFRESCAR PÁGINA
    $("#btnRefresh").on('click', function(e) {
        e.preventDefault();
        global.cargarPagina('Libro');
    });
    //BOTÓN REFRESCAR PÁGINA
    $("#btnLibros").on('click', function(e) {
        e.preventDefault();
        global.cargarPagina('BuscarLibro');
    });

     $("#btnSigPaso2").on('click', function() {
        nextTab('producto');
    });

    $("#btnAntPaso1").on('click', function() {
        nextTab('tipo');
    });
    
    $("#btnSigPaso3").on('click', function() {
        nextTab('inventario');
    }); 

    $("#btnAntPaso2").on('click', function() {
        nextTab('producto');
    }); 
    /////////////////////////////////////////////////////////////////////////////////////	
    /***************************
     *		    EVENTOS	       *
     **************************/
    $("#nombreLibro").on('keypress', function(evt) {
        var charCode = evt.which || evt.keyCode;

        if (charCode == 13) {
            $("#isbn").focus();
        } else {
            global.numerosLetras(evt);
        }
    });

    $("#nombreLibro").on('keyup', function(evt) {
        habilitarPaso3();
        habilitaBoton();
    });

    $("#isbn").on('keypress', function(evt) {
        var charCode = evt.which || evt.keyCode;

        if (charCode == 13) {
            $("#autor").focus();
        } else {
            global.numeros(evt);
        }
    });

    $("#isbn").on('keyup', function(evt) {
        habilitarPaso3();
        habilitaBoton();
    });

    $("#autor").on('keypress', function(evt) {
        var charCode = evt.which || evt.keyCode;

        if (charCode == 13) {
            $("#editorial").focus();
        } else {
            global.letras(evt);
        }
    });

    $("#autor").on('keyup', function() {
        habilitarPaso3();
        habilitaBoton();
    });

    $("#editorial").on('keypress', function(evt) {
        var charCode = evt.which || evt.keyCode;

        if (charCode == 13) {
            $("#descripcionLibro").focus();
        } else {
            global.letras(evt);
        }
    });

    $("#editorial").on('keyup', function() {
        habilitarPaso3();
        habilitaBoton();
    });

        //EVENTO KEYPRESS
	$("#codigoBarras").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 11 && charCode == 13) {
			$("#proveedor").focus();
		} else {
			global.numeros(evt);
		}
	});
		//EVENTO KEYUP
	$("#codigoBarras").on('keyup',function(){
		habilitaBoton();
	});

    	//EVENTO CHANGE
	$("#proveedor").on('change',function(){
		habilitaBoton();
	});

    	//EVENTO CHANGE
	$("#categoria").on('change',function(){
		habilitaBoton();
	});

    		//EVENTO KEYPRESS
	$("#stMin").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val() != 0 && charCode == 13) {
			$("#stMax").focus();
		} else {
			global.numeros(evt);
		}
	});
		//EVENTO KEYUP
	$("#stMin").on('keyup',function(){
		habilitaBoton();
	});
		//EVENTO KEYPRESS
	$("#stMax").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val() != 0 && charCode == 13) {
			$("#stActual").focus();
		} else {
			global.numeros(evt);
		}
	});
		//EVENTO KEYUP
	$("#stMax").on('keyup',function(){
		habilitaBoton();
	});
		//EVENTO KEYPRESS
	$("#stActual").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val() != 0 && charCode == 13) {
			$("#compra").focus();
		} else {
			global.numeros(evt);
		}
	});
		//EVENTO KEYUP
	$("#stActual").on('keyup',function(){
		habilitaBoton();
	});
		//EVENTO KEYPRESS
	$("#compra").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val() != 0 && charCode == 13) {
			$("#venta").focus();
		} else {
			global.numeros(evt);
		}
	});
		//EVENTO KEYUP
	$("#compra").on('keyup',function(){
		habilitaBoton();
	});
		//EVENTO KEYPRESS
	$("#venta").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val() != 0 && charCode == 13) {
			$("#categoria").focus();
		} else {
			global.numeros(evt);
		}
	});
		//EVENTO KEYUP
	$("#venta").on('keyup',function(evt){
		habilitaBoton();
	});

    $("#buscar").on('keypress', function(evt) {
        var charCode = evt.which || evt.keyCode;

        if (charCode == 13) {
            $("#btnSearch").focus();
        } else {
            global.numerosLetras(evt);
        }
    });
        //AUTOCOMPLETE
    $("#buscar").autocomplete({
        minLength: 2,
        source: "php/autocomplete.php?opc=producto",
        autoFocus: true,
        select: function(event, ui) {
            $('#codigoProducto').val(ui.item.id);
            return ui.item.label;
        },
        response: function(event, ui) {
            if (ui.content[0].label == null) {
                var noResult = { value: "", label: "No Se Encontrarón Resultados" };
                ui.content.push(noResult);
            }
        }
    });
    	//VALIDAR CAMBIO EN LOS RADIOBUTTONS DE TIPO DE PRODUCTO
	$("input[name=tipo]").change(function(){
        var tipo = $(this).val();

        if ( $(this).is(':checked') ) {
            if (tipo == 'libro') {
                limpiarDatos();
                $("#btnSigPaso2").prop('disabled',false);
                $("#np").hide();
            } else {
                limpiarDatos();
                nextTab('inventario');
                $("#btnAntPaso2").prop('disabled',true);
            }
        } else {
            $("#btnSigPaso2").prop('disabled',true);
        }
    });
    /**************************
    *		 FUNCIONES        *
    **************************/
        //FUNCIÓN PARA AVANZAR A LA SIGUIENTE TABS
    function nextTab(tab) {
        $('li.tab').removeClass('disabled');
        $('ul.tabs').tabs('select_tab', tab);
        $('li.tab').addClass('disabled');
    }
        //FUNCIÓN PARA HABILITAR BOTÓN ACEPTAR 
    function habilitaBoton() {    
        var tipo = $("input[name=tipo]:checked").val();
        var nombre = $("#nombreLibro").val();
        var isbn = $("#isbn").val();
        var autor = $("#autor").val();
        var editorial = $("#editorial").val ();
        var nombreProducto = $("#nombreProducto").val();
		var codigoBarras = $("#codigoBarras").val();
		var proveedor = $("#proveedor").val();
		var stActual = $("#stActual").val();
		var stMin = $("#stMin").val();
		var stMax = $("#stMax").val();
		var compra = $("#compra").val();
		var venta = $("#venta").val();
		var categoria = $("#categoria").val();

        if (tipo == 'libro') {
            if (nombre != "" && isbn != "" && isbn.length > 10 && autor != "" && editorial != "" && codigoBarras != "" && proveedor != 0 && 
                stMin != "" && stMax != "" && stMax != 0 && stActual != "" && stActual != 0 && compra != "" && 
                compra != 0 && venta != "" && venta != 0 && categoria != 0) {
                if ($("#codigoLibro").val() != "") {
                    $("#btnUpdate").prop('disabled', false);
                    $("#btnSave").prop('disabled', true);
                } else {
                    $("#btnSave").prop('disabled', false);
                }
            } else {
                $("#btnSave").prop('disabled', true);
            }
        } else if (tipo == 'nuevo') {
            if (nombreProducto != "" && codigoBarras != "" && proveedor != 0 && stMin != "" && stMax != "" && stMax != 0 && 
                stActual != "" && stActual != 0 && compra != "" && compra != 0 && venta != "" && venta != 0 && categoria != 0) {
                if ($("#codigoProducto").val() == "" ) {
                    $("#btnSave").prop('disabled',false);
                } else {
                    $("#btnUpdate").prop('disabled',false);
                }
            }
        }
    }
        //FUNCIÓN PARA HABILITAR EL PASO 3
    function habilitarPaso3(){
        var nombre = $("#nombreLibro").val();
        var isbn = $("#isbn").val();
        var autor = $("#autor").val();
        var editorial = $("#editorial").val();

        if (nombre != "" && isbn != "" && isbn.length > 10 && autor != "" && editorial != "") {
            $("#btnSigPaso3").prop('disabled', false);
        } else {
            $("#btnSigPaso3").prop('disabled', true);
        }
    }
        //FUNCIÓN PARA ENTRAR DESDE BUSCAReMPELADOS Y MODIFICAR EL EMPLEADO	
    function actualizarLibro() {
        var res = "";
        var resJson = "";

        if (localStorage.libros != undefined) {
                //RECUPERAMOS LOS VALORES ALMACENADOS EN SESSION 
            res = localStorage.getItem('libros');
                //CONVERTIMOS EL JSON A UN OBJETO
            resJson = JSON.parse(res);
            console.log(resJson);
            setTimeout(function() {
                    //ASGINAMOS VALORES A LOS INPUTS
                $("#codigoLibro").val(resJson[0]);
                $("#nombreLibro").val(resJson[1]);
                $("#isbn").val(resJson[2]);
                $("#descripcionLibro").val(resJson[5]);
                $("#autor").val(resJson[6]).attr('selected', 'selected');
                $("#editorial").val(resJson[7]).attr('selected', 'selected');
                $("#rutaIMG").val(resJson[8]);
                cargar_imagen(resJson[8]);
                    //OCULTAMOS BOTON GUARDAR Y MOSTRAMOS MODIFICAR
                $("#codigoLibro").show('explode');
                $("#btnUpdate").prop('disabled', false);
                    //VACIAMOS LA SESSION
                localStorage.clear();
            }, 300);
        }
    }
        //FUNCIÓN PARA ENVIAR DATOS
    function enviarDatos() {
        var nombre = $("#nombreLibro").val();
        var cadena = JSON.stringify(global.json("#frmAgregarProducto"));
        var inputFileImage = document.getElementById('imagen');

        if (cadena == "") {
            global.mensajes('Advertencia', '!Debe llenar Todos los Campos', 'warning', '', '', '', '');
        } else {
            var nombreIMG = global.subirimagen(nombre);
            var parametros = { opc: 'guardar', img: nombreIMG.imagen, cadena };

            global.envioAjax('ControllerProducto', parametros);
        }
    }
        //FUNCIÓN PARA BUSQUEDA
    function llenarDatos(producto){
        $.each(producto, function(index, value) {
            $("#codigoLibro").val(value.codigoLibro);
            $("#nombreLibro").val(value.nombre);
            $("#isbn").val(value.isbn);
            $("#codigoAutor").val(value.idAutor);
            $("#autor").val(value.autor);
            $("#codigoEditorial").val(value.idEditorial);
            $("#editorial").val(value.editorial);
            $("#descripcionLibro").val(value.descripcion);
            $("#rutaIMG").val(value.rutaIMG);
            $("#codigoProducto").val(value.codigoProducto);
            $("#nombreProducto").val(value.nombreProducto);
            $("#codigoBarras").val(value.codigoBarras);
            $("#proveedor").val(value.proveedor).prop('selected', 'selected');
            $("#stMin").val(value.stMin);
            $("#stMax").val(value.stMax);
            $("#stActual").val(value.stActual);
            $("#compra").val(value.compra);
            $("#venta").val(value.venta);
            $("#categoria").val(value.categoria).prop('selected', 'selected');

            cargar_imagen(value.rutaIMG);
        });
    }
        //FUNCIÓN PARA LLENAR LOS SELECT DE LA VISTA	
    function llenarCombo() {
        var respuesta = global.buscar('ControllerProducto', 'filtro', '', '');

        if (respuesta.codRetorno = '000') {
            $("#proveedor").html(respuesta.proveedores);
			$("#categoria").html(respuesta.categorias);
        }
    }
        //FUNCIÓN PARA LIMPIAR LOS DATOS DEL FORMULARIO
    function limpiarDatos(){
        $("#codigoLibro").val('');
        $("#nombreLibro").val('');
        $("#isbn").val('');
        $("#codigoAutor").val('');
        $("#autor").val('');
        $("#codigoEditorial").val('');
        $("#editorial").val('');
        $("#descripcionLibro").val('');
        $("#codigoProducto").val('');
        $("#nombreProducto").val('');
		$("#codigoBarras").val('');
		$("#proveedor").val(0).prop('selected', 'selected');
		$("#stMin").val('');
		$("#stMax").val('');
		$("#stActual").val('');
		$("#compra").val('');
		$("#venta").val('');
		$("#categoria").val(0).prop('selected', 'selected');
    }
        //FUNCIÓN CARGAR IMAGEN
    function cargar_imagen(nombre) {
         //VALIDAMOS SI LA IMÁGEN EXISTE
         if (nombre == "") {
             //MOSTRAR IMÁGEN SINO SE ENCONTRÓ LA SOLICITADA
            $("#imagen").fileinput('refresh', {
                previewFileType: "image",
                allowedFileExtensions: ["jpg", "png"],
                showCaption: false,
                showUpload: false,
                showRemove: false,
                showClose: false,
                initialPreview: [
                    '<img src=images/no_image.png class="file-preview-image" >',
                ],
            });
        } else {
            //MOSTRAR IMÁGEN SOLICITADA
            $("#imagen").fileinput('refresh', {
                showCaption: false,
                showUpload: false,
                previewFileType: "image",
                allowedFileExtensions: ["jpg", "png"],
                elErrorContainer: "#errorBlock",
                browseClass: "btn green",
                browseLabel: "",
                browseIcon: "<i class=\"material-icons\">image</i> ",
                removeClass: "btn red",
                removeLabel: "",
                removeIcon: "<i class=\"material-icons\">delete</i> ",
                initialPreview: [
                    '<img src="' + nombre + '" class="file-preview-image">',
                ],
            });
        }
    }
        //INICIALIZAR EL PLUGIN DE FILE-INPUT`
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