$(document).ready(function(){
	/**************************
     *	 OOCULTAR CAMPOS	   *
     **************************/
	//global.validaSesion();
	global.isNotAdminMenu($("#tipoUsuario").val());
	global.pagination('ControllerEmpleado',1,0,'');
	$("#buscar").focus();
//////////////////////////////////////////////////////
	/**************************
     *		BOTONOES		  *
     **************************/
		//BOTÓN NUEVO LIBRO
	$("#btnNuevo").on('click',function(){
		global.cargarPagina("Empleado");
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
		$(this).prop('disabled',true);
		var buscar = $("#codigoEmpelado").val(); 

		if (buscar != "") {
			global.pagination('ControllerEmpleado',1,buscar,'');
		} else {
			global.mensajes('Advertencia','Campo Buscar vacio','warning','','','','');
		}
		$(this).prop('disabled',false);	
	});
/////////////////////////////////////////////////////////////////////////////
		/**************************
	     *		EVENTOS			  *
	     **************************/
		//EVENTO KEYPRESS DEL CAMPO BUSCAR
	$("#buscar").on('keypress',function(evt){
    	var charCode = evt.which || evt.keyCode;

    	if ( $(this).val().length != 0 && charCode == 13) {
    		$("#btnSearch").focus();
    	} else {
			global.numerosLetras(evt);
		}
    });
		//EVENTO CHANGE DEL CAMPO BUSCAR
	$("#buscar").on('keyup',function(){
		if ( $(this).val().length == 0 || $(this).val() == "") {
			global.pagination('ControllerEmpleado',1,0,'');
		}
	});
		//AUTOCOMPLETE
	$("#buscar").autocomplete({
	 	minLength: 2,
	    source: "php/autocomplete.php?opc=empleado",
		autoFocus: true,
		select: function (event, ui) {
			if (ui.item.label == "") {
				$("#buscar").val("");
			}
			$("#codigoEmpelado").val(ui.item.id);
			return ui.item.label;
		},
		response: function(event, ui) {
			if (ui.content[0].label == null || ui.content[0].label == "" ) {
				var noResult = { value: "" ,label: "No Se Encontrarón Resultados" };
				ui.content.push(noResult);
			} 
		}
     });
		//FUNCIÓN PARA CAMBIAR PÁGINACION
	$("#pages").on('click',function(){
		$(".paginate").on('click',function(){
			var page = $(this).attr("data");	
			global.pagination('ControllerProducto',page,'','');
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
			
			$("#codigo").html("<b>Código Empleado:</b>" +array[0]);
			$("#nombreEmpleado").html("<b>Nombre Empleado:</b> "+array[1]);
			$("#apellidos").html("<b>Apellidos:</b> "+array[2]);
			$("#domicilio").html("<b>Domicilio:</b> "+array[3]);
			$("#ciudad").html("<b>Ciudad:</b> " +array[4]);
			$("#estado").html("<b>Estado:</b> " +array[5]);
			$("#telefono").html("<b>Teléfono:</b> "+array[6]);
			$("#celular").html("<b>Celular:</b> "+array[7]);
			$("#sueldo").html("<b>Sueldo:</b> $"+array[8]);
			$("#puesto").html("<b>Puesto:</b> "+array[9]);

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
			localStorage.empleado = JSON.stringify(array);
			global.cargarPagina('Empleado');
			array.clear;
		});
	});
 		//CREAMOS LA MODAL
	$('.modal').modal({
		dismissible: true, // Modal can be dismissed by clicking outside of the modal
		opacity: .5, // Opacity of modal background
		in_duration: 300, // Transition in duration
		out_duration: 200, // Transition out duration
		starting_top: '20%', // Starting top style attribute
		ending_top: '20%', // Ending top style attribute
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