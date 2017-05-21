$(document).ready(function(){
	 /**************************
     *	 LLAMAR FUNCIONES	   *
     **************************/
	//global.validaSesion();
	global.isAdmin();
	$("#nombreLibro").focus();
	llenarCombo();
	actualizarLibro();
	/**************************
    *		BOTONOES		  *
    **************************/
    	//BOTÓN NUEVO AUTOR
	$("#btnSearch").on('click',function(e){
		e.preventDefault();
		$("#btnSearch").prop('disabled',true);
		var buscar = $("#codigoLibro").val(); 

		if (buscar != "") {
			$("#codigoLibro").val(''); 
			$("#buscar").val(''); 

			var respuesta = global.buscar('ControllerLibro','buscar',buscar,'');
			if (respuesta.codRetorno == '000') {
				$.each(respuesta.datos,function(index,value){
					$("#codigoLibro").val(value.id);
					$("#nombreLibro").val(value.nombre);
					$("#isbn").val(value.isbn);
					$("#autor").val(value.idAutor).prop('selected', 'selected');
					$("#editorial").val(value.idEditorial).prop('selected', 'selected');
					$("#descripcionLibro").val(value.descripcion);
						//ELIMINAMOS ESPACIO DEL NOMBRE
					value.nombre = value.nombre.replace(/\s+/g, '');
						//VALIDAR SI LA IMAGEN NO ESTA VACIA O NO SE ENCUENTRA
					cargar_imagen(value.nombre);	
				});
				
				$("#btnUpdate").prop('disabled',false);
			}	
		} else {
			global.mensajes('Advertencia','Campo Buscar vacio','warning');
		}
		$("#btnSearch").prop('disabled',false);
	});
		//BOTÓN GUARDAR
	$("#btnSave").on('click',function(){
		var nombre = $("#nombreLibro").val();
		var cadena = $("#frmAgregarLibro").serialize();
		var parametros = {opc: 'guardar',cadena };

		if (cadena == "") {
			global.messajes('Error','!Debe llenar Todos los Campos','warning');
		} else {
			var retorno = global.subirimagen(nombre);
			if (retorno == false) {
				swal({
					title: 'Ocurrio un Error al subir la Imágen',
					text: '¿Desea Continuar?',
					type: 'warning',
					allowEscapeKey: false,
					allowOutsideClick: false,
					showCancelButton: true,
					confirmButtonColor: '#3085d6',
					cancelButtonColor: '#d33',
					confirmButtonText: 'Si'},
				function(isConfirm){ 
					if (isConfirm) {
						global.envioAjax('ControllerLibro',parametros);
					}
				});
			} else {
				global.envioAjax('ControllerLibro',parametros);
			}
		}	
	});
		//BOTÓN ACTUALIZAR
	$("#btnUpdate").on('click',function(){
		var nombre = $("#nombreLibro").val();
		var cadena = $("#frmAgregarLibro").serialize();
		var parametros = {opc: 'guardar',cadena };

		if (cadena == "") {
			global.mensajes('Advertencia','!Debe llenar Todos los Campos','warning','','','','');
		} else {
			global.subirimagen(nombre);
			global.envioAjax('ControllerLibro',parametros);
		}	
	});
		//BOTÓN CREAR REPORTE
	$("#btnReporte").on('click',function(){
		alert("hola salvaje");
	});
		//BOTÓN ELIMINAR
	$("#btnDelete").on('click',function(e){
		e.preventDefault();
		alert("hola salvaje");
	});
		//BOTÓN REFRESCAR PÁGINA
	$("#btnRefresh").on('click',function(e){
		e.preventDefault();
		global.cargarPagina('Libro');
	});
		//BOTÓN REFRESCAR PÁGINA
	$("#btnLibros").on('click',function(e){
		e.preventDefault();
		global.cargarPagina('BuscarLibro');
	});
/////////////////////////////////////////////////////////////////////////////////////	
    $("#nombreLibro").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#isbn").focus();
		} else {
			global.numerosLetras(evt);
		}
    });

	$("#isbn").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#autor").focus();
		} else {
			global.numeros(evt);
		}
    });

	$("#autor").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;
		
		if (charCode == 13) {
			$("#editorial").focus();
		}
    });

	$("#autor").on('change',function(){
	  	habilitaBoton();
    });

    $("#editorial").on('change',function(){
		habilitaBoton();
    });

    $("#buscar").on('keypress',function(evt){
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
		source: "php/autocomplete.php?opc=libro",
		autoFocus: true,
		select: function (event, ui) {
			$('#codigoLibro').val(ui.item.id);
			return ui.item.label;
		},
		response: function(event, ui) {
			if (ui.content[0].label == null) {
				var noResult = { value: "" ,label: "No Se Encontrarón Resultados" };
				ui.content.push(noResult);
			} 
		}
	});
    	//FUNCIÓN PARA HABILITAR BOTÓN ACEPTAR 
    function habilitaBoton(){
    	var codigo = $("#codigoLibro").val();
    	var nombre = $("#nombreLibro").val();
    	var isbn = $("#isbn").val();
    	var autor  = $("#autor").val();
    	var editorial = $("#editorial").val();
    	var imagen = $("#imagen").val();

    	if (nombre != "" && isbn != "" && isbn.length > 10 && autor != 0 && editorial != 0 && imagen != "") {
    		if (codigo.length != 0) {
    			$("#btnUpdate").prop('disabled',false);
    			$("#btnSave").prop('disabled',true);
    		} else {
    			$("#btnSave").prop('disabled',false);
    		}
    	} else {
    		$("#btnSave").prop('disabled',true);
    	}
    }
		//FUNCIÓN PARA ENTRAR DESDE BUSCAReMPELADOS Y MODIFICAR EL EMPLEADO	
	function actualizarLibro(){
		var res = "";
		var resJson = "";

		if (localStorage.libros != undefined){
				//RECUPERAMOS LOS VALORES ALMACENADOS EN SESSION 
			res = localStorage.getItem('libros');
				//CONVERTIMOS EL JSON A UN OBJETO
			resJson = JSON.parse(res);
			setTimeout(function() {
					//ASGINAMOS VALORES A LOS INPUTS
				$("#codigoLibro").val(resJson[0]);
				$("#nombreLibro").val(resJson[1]);
				$("#isbn").val(resJson[2]);
				$("#descripcionLibro").val(resJson[5]);
				$("#autor").val(resJson[6]).attr('selected', 'selected');
				$("#editorial").val(resJson[7]).attr('selected', 'selected');
				cargar_imagen(resJson[1]);
					//OCULTAMOS BOTON GUARDAR Y MOSTRAMOS MODIFICAR
				$("#codigoLibro").show('explode');
				$("#btnUpdate").prop('disabled',false);
					//VACIAMOS LA SESSION
				localStorage.clear();
			}, 300);	
		}
	}	
    	//FUNCIÓN PARA LLENAR LOS SELECT DE LA VISTA	
	function llenarCombo(){
		var respuesta = global.buscar('ControllerLibro','filtro','','');

		if (respuesta.codRetorno = '000') {
			$("#editorial").html(respuesta.editoriales);
			$("#autor").html(respuesta.autores);
		}
	}
		 //FUNCIÓN CARGAR IMAGEN
    function cargar_imagen(nombre){
    		//SE REEMPLAZA EL ESPACIO EN BLANCO 
    	nombre = global.getCleanedString(nombre);
	    	//VALIDAMOS SI LA IMÁGEN EXISTE
    	if (global.existeUrl('images/'+nombre+'.jpg' ) != true ) {
    			//MOSTRAR IMÁGEN SINO SE ENCONTRÓ LA SOLICITADA
			$("#imagen").fileinput('refresh',{
				previewFileType: "image",
				allowedFileExtensions: ["jpg","png"],
				showCaption: false,
				showUpload: false,
				showRemove: false,
				showClose: false,
		        initialPreview: [
	            '<img src=images/no_image.png class="file-preview-image">',
	        	],
			});
    	} else {
    			//MOSTRAR IMÁGEN SOLICITADA
			$("#imagen").fileinput('refresh',{
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
		        initialPreview: [
	            '<img src="images/'+nombre+'.jpg" class="file-preview-image">',
	        	],
		    });
    	}
    }
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