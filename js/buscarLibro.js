$(document).ready(function(){
	 /**************************
     *	 OOCULTAR CAMPOS	   *
     **************************/
	global.validaSesion();
	global.isNotAdminMenu($("#tipoUsuario").val());
	global.pagination('php/libro.php',1);
	$("#busqueda").focus();
	$('#descripcionLibro').trigger('autoresize');
	$("#busquedas").hide();
//////////////////////////////////////////////////////
	/**************************
    *		BOTONOES		  *
    **************************/
    	//BOTÓN REFRESCAR
	$("#btnRefresh").on('click',function(){
		global.cargarPagina('pages/BuscarLibro.html');
	});
	     //BOTÓN NUEVO LIBRO
	$("#btnNuevo").on('click',function(){
		global.cargarPagina("pages/Libro.html");
	});
		//BOTÓN CREAR REPORTE
	$("#btnReporte").on('click',function(){
		global.imprimir();
	});
		//BOTÓN CERRAR MODAL
	$("#btnClose").on('click',function(){
		$("#modal").modal('close');
	});
		//BOTÓN BUSCAR
	$("#btnSearch").on('click',function(e){
		e.preventDefault();
		var parametros = "";
		var buscar = $("#codigoLibro").val(); 
		var opc =  $("#busqueda").val();
			//VALIDAMOS EL CMAPO BUSCAR
		if (buscar != "") {
			global.pagination('php/libro.php',1,buscar,opc);
		} else {
			global.mensajes('Advertencia','Campo Buscar vacio','warning');
		}
		$("#btnSearch").prop('disabled',false);	
	});
/////////////////////////////////////////////////////////////////////////////
		/**************************
	     *		EVENTOS			  *
	     **************************/
		//OCULTA O MUESTRA CAMPOS PARA BUSQUEDA
	$("#busqueda").change(function(){
			//OBTENEMOS EL VALOR DEL SELECT Y LIMPIAMOS LOS CAMPOS
		var opc =  $(this).val();
		$("#buscarE").val("");
		$("#buscarN").val("");
			//VALIDAMOS LA OPCIÓN SELECCIONADA 1 = NOMBRE , 2 = EMPRESA
		if (opc == 0) {
			$("#busquedas").hide('explode');
		} else if (opc == 1) {
			$("#buscarE").hide();
			$("#buscarN").show('explode');
			$("#busquedas").show("explode");
			$("#buscarN").focus();
		} else {
			$("#buscarN").hide();
			$("#buscarE").show('explode');
			$("#busquedas").show("explode");
			$("#buscarE").focus();
		}
	});
		//EVENTO KEYPRESS DEL CAMPO BUSCAR
	$("#buscarN").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#btnSearch").focus();
		} else {
			global.numerosLetras(evt);
		}
	});
		//EVENTO CHANGE DEL CAMPO BUSCAR
	$("#buscarN").on('keyup',function(){
		if ( $(this).val().length == 0 && $(this).val() == "") {
			global.pagination('php/libro.php',1);
		}
	});
		//EVENTO KEYPRESS DEL CAMPO BUSCAR
	$("#buscarE").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#btnSearch").focus();
		} else {
			global.numerosLetras(evt);
		}
	});
		//EVENTO CHANGE DEL CAMPO BUSCAR
	$("#buscarE").on('keyup',function(){
		if ( $(this).val().length == 0 && $(this).val() == "") {
			global.pagination('php/libro.php',1);
		}
	});
//////////////////////////////////////////////
		/**************************
	    *		AUTOCOMPLETE	  *
	    **************************/
		//AUTOCOMPLETAR CAMPO NOMBRE
	$("#buscarN").autocomplete({
		minLength: 2,
		source: "php/autocomplete.php?opc=libro",
		autoFocus: true,
		select: function (event, ui) {
			if (ui.item.id == 0) {
				$("#buscarN").val("");
				$("#buscarN").empty();
			}
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
		//AUTOCOMPLETAR CAMPO BUQUEDA POR AUTOR
	$("#buscarE").autocomplete({
		minLength: 2,
		source: "php/autocomplete.php?opc=autor",
		autoFocus: true,
		select: function (event, ui) {
			if (ui.item.id == 0) {
				$("#buscarE").val("");
				$("#buscarE").empty();
			}
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
		//FUNCIÓN PARA CAMBIAR PÁGINACION
	$("#pages").on('click',function(){
		$(".paginate").on('click',function(){
			var page = $(this).attr("data");		
			global.pagination('php/libro.php',page);
		});
	});
	    //FUNCIÓN PARA TOMAR EL BOTOÓN ACTUALIZAR DE LA TABLA
 	$('#table').on('click',function() {
 		array = [];
		$(".btnImage").on('click',function(){
			$(this).parents("tr").find("td").each(function(){
				array.push($(this).text());
            });

			$("#modal").modal('open');
			cargar_imagen(array[1]);
			$("#descripcionLibro").val(array[5]);

			array.clear;
		});
	});
	    //FUNCIÓN PARA TOMAR EL BOTOÓN ACTUALIZAR DE LA TABLA
 	$('#table').on('click',function() {
 		array = [];
		$(".btnEditar").on('click',function(index){
			$(this).parents("tr").find("td").each(function(){
				array.push($(this).text());
            });

			localStorage.clear();
	        	//CONVERTIMOS A JSON 
			localStorage.libros = JSON.stringify(array);
			global.cargarPagina('pages/Libro.html');
			array.clear;
		});
	});
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
				overwriteInitial: false,
				initialPreviewAsData: true,
		        initialPreview: [
	            	'<img src=images/no_image.png class="file-preview-image">',
	        	],
			});
    	} else {
    			//MOSTRAR IMÁGEN SOLICITADA
			$("#imagen").fileinput('refresh',{
		        previewFileType: "image",
		        allowedFileExtensions: ["jpg"],
		        showCaption: false,
				showUpload: false,
				showRemove: false,
				showClose: false,
				overwriteInitial: false,
		        initialPreview: [
	            	'<img src="images/'+nombre+'.jpg" class="file-preview-image">',
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
		ending_top: '10%', // Ending top style attribute
		complete: function() { 
			$("#descripcionLibro").val("");
		} // Callback for Modal close
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