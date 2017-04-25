$(document).ready(function(){
	/**************************
     *	 OOCULTAR CAMPOS	   *
     **************************/
	global.validaSesion();
	global.isNotAdminMenu($("#tipoUsuario").val());
	global.pagination('php/proveedor.php',1);
	$("#buscar").focus();
//////////////////////////////////////////////////////
	/**************************
     *		BOTONOES		  *
     **************************/
		//BOTÓN NUEVO LIBRO
	$("#btnNuevo").on('click',function(){
		global.cargarPagina("pages/Proveedor.html");
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
		var buscar = $("#buscar").val(); 

		if (buscar != "") {
			$("#btnSearch").prop('disabled',true);
			var parametros = {opc: 'buscarProveedor','buscar': buscar };

			var respuesta = global.buscar('proveedor',parametros);
			if (respuesta.codRetorno == '000') {
				$("#table").html("");
				$("#table").append("<tr><td style='display: none' width='5%'>"+respuesta.id+
					"</td><td width='30%'>"+respuesta.nombreProveedor+"</td><td width='10%'>"+respuesta.contacto+
					"</td><td width='25%'>"+respuesta.direccion+"</td><td width='8%'>"+respuesta.ciudad+
					"</td><td width='8%'>"+respuesta.estado+"</td><td width='5%'>"+respuesta.telefono+
					"</td><td width='5%'>"+respuesta.celular+"</td><td style='display: none' width='10%'>"+respuesta.email+
					"</td><td style='display: none' width='5%'>"+respuesta.web+"</td><td style='display: none' width='5%'>"+respuesta.colonia+
					"</td><td style='display: none' width='5%'>"+respuesta.calle+"</td><td style='display: none' width='5%'>"+respuesta.numero+
					"</td><td><td><button type='button' class='icon-info btn blue btnMostrar'></button>\
					<button type='button' class='icon-editar btn green lighten-1 btnEditar'></button>\
					</td></tr>"
				);
				$('#page-numbers').html("");
			}
			$("#btnSearch").prop('disabled',false);	
		} else {
			global.mensajes('Advertencia','Campo Buscar vacio','warning');
		}
	});
/////////////////////////////////////////////////////////////////////////////
		/**************************
	     *		EVENTOS			  *
	     **************************/
		//EVENTO KEYPRESS DEL CAMPO BUSCAR
	$("#buscar").on('keypress',function(evt){
    	var charCode = evt.which || evt.keyCode;

    	if ( $(this).val().length == 0 && charCode == 13) {
    		//$("#btnSearch").focus();
    	} else {
			global.numerosLetras(evt);
		}
    });
		//EVENTO CHANGE DEL CAMPO BUSCAR
	$("#buscar").on('keyup',function(){
    	if ( $(this).val().length == 0 && $(this).val() == "") {
    		global.pagination('php/proveedor.php',1);
    	}
    });
		//AUTOCOMPLETE
	$("#buscar").autocomplete({
     	minLength: 2,
        source: "php/autocomplete.php?opc=proveedor",
		autoFocus: true,
		select: function (event, ui) {
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
			global.pagination('php/proveedor.php',page);
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
			global.cargarPagina('pages/Proveedor.html');
			array.clear;
		});
	});
 		//CREAMOS LA MODAL
	$('.modal').modal({
		dismissible: true, // Modal can be dismissed by clicking outside of the modal
		opacity: .5, // Opacity of modal background
		in_duration: 300, // Transition in duration
		out_duration: 200, // Transition out duration
		starting_top: '4%', // Starting top style attribute
		ending_top: '10%', // Ending top style attribute
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
		} // Callback for Modal close
	});
});