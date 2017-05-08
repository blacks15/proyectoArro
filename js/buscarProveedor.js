$(document).ready(function(){
	/**************************
     *	 OOCULTAR CAMPOS	   *
     **************************/
	//global.validaSesion();
	//global.isNotAdminMenu($("#tipoUsuario").val());
	global.pagination('ControllerProveedor',1,0,'');
	$("#buscar").focus();
//////////////////////////////////////////////////////
	/**************************
     *		BOTONOES		  *
     **************************/
		//BOTÓN NUEVO LIBRO
	$("#btnNuevo").on('click',function(){
		global.cargarPagina("Proveedor");
	});
		//BOTÓN CREAR REPORTE
	$("#btnReporte").on('click',function(){
		alert("hola salvaje");
	});
		//BOTÓN CERRAR MODAL
	$("#btnClose").on('click',function(){
		$("#modal").modal('close');
	});
		//BOTÓN BUSCAR
	$("#btnSearch").on('click',function(e){
		e.preventDefault();
		$("#btnSearch").prop('disabled',true);
		var buscar = $("#buscar").val(); 
		var codigo = $("#codigo").val();

		if (buscar != "") {
			global.pagination('ControllerProveedor',1,codigo);
			$('#pagination').hide();
		} else {
			global.mensajes('Advertencia','Campo Buscar vacio','warning');
		}
			
		$("#btnSearch").prop('disabled',false);	
	});
/////////////////////////////////////////////////////////////////////////////
		/**************************
	     *		EVENTOS			  *
	     **************************/
		//EVENTO KEYPRESS DEL CAMPO BUSCAR
	$("#buscar").on('keypress',function(evt){
    	var charCode = evt.which || evt.keyCode;

    	if ( $(this).val().length != 0 && charCode != 13) {
			global.numerosLetras(evt);
    	}
    });
		//EVENTO CHANGE DEL CAMPO BUSCAR
	$("#buscar").on('change',function(){
    	if ( $(this).val().length == 0) {
    		global.pagination('ControllerProveedor',1,0);
    		$('#pagination').show();
    	}
    });
		//AUTOCOMPLETE
	$("#buscar").autocomplete({
     	minLength: 2,
        source: "php/autocomplete.php?opc=proveedor",
		autoFocus: true,
		select: function (event, ui) {
			$("#codigo").val(ui.item.id);
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
	$("#pagination").on('click',function(){
		$(".paginate").on('click',function(){
			var page = $(this).attr("data");	
			global.pagination('ControllerProveedor',page,0);
		});
	});
		//FUNCIÓN PARA TOMAR EL BOTOÓN ACTUALIZAR DE LA TABLA
 	$('#table').on('click',function() {
 		array = [];
		$(".btnMostrar").on('click',function(index){

			$(this).parents("tr").find("td").each(function(){
				array.push($(this).text());
            });
				console.log(array);
			$('#modal').modal('open');
			
			$("#codigo").html("Código Proveedor: " +array[0]);
			$("#proveedor").html("Nombre Proveedor: "+array[1]);
			$("#contacto").html("Nombre Contacto: "+array[2]);
			$("#domicilio").html("Domicilio: "+array[3]);
			$("#ciudad").html("Ciudad: " +array[4]);
			$("#estado").html("Estado: " +array[5]);
			$("#telefono").html("Teléfono: "+array[6]);
			$("#celular").html("Celular: "+array[7]);
			$("#email").html("E-mail: "+array[8]);
			$("#web").html("Página Web: "+array[9]);

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
			localStorage.proveedor = JSON.stringify(array);
			global.cargarPagina('Proveedor');
			array.clear;
		});
	});
 		//CREAMOS LA MODAL
	$('.modal').modal({
		dismissible: true, // Modal can be dismissed by clicking outside of the modal
		opacity: .5, // Opacity of modal background
		in_duration: 300, // Transition in duration
		out_duration: 200, // Transition out duration
		starting_top: '15%', // Starting top style attribute
		ending_top: '15%', // Ending top style attribute
		complete: function() { 		
			$("#codigo").html("");
			$("#proveedor").html("");
			$("#contacto").html("");
			$("#domicilio").html("");
			$("#ciudad").html("");
			$("#estado").html("");
			$("#telefono").html("");
			$("#celular").html("");
			$("#email").html("");
			$("#web").html("");
		}
	});
});