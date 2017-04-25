$(document).ready(function(){
	/**************************
     *	 OOCULTAR CAMPOS	   *
     **************************/
	global.validaSesion();
	global.isNotAdminMenu($("#tipoUsuario").val());
	global.pagination('php/cliente.php',1);
	$("#busqueda").focus();
	$("#busquedas").hide();
//////////////////////////////////////////////////////
	/**************************
     *		BOTONOES		  *
     **************************/
		//BOTÓN NUEVO LIBRO
	$("#btnNuevo").on('click',function(){
		global.cargarPagina("pages/Cliente.html");
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
		var buscar = $("#codigoCliente").val(); 

		if (buscar != "") {
			$("#btnSearch").prop('disabled',true);
			var parametros = {opc: 'buscarCliente','buscar': buscar };

			var respuesta = global.buscar('cliente',parametros);
			if (respuesta.codRetorno == '000') {
				direccion = respuesta.calle+' '+respuesta.numExt+' '+respuesta.numInt+' '+respuesta.colonia;
				numero = respuesta.numExt+' '+respuesta.numInt;
				$("#table").html("");
				$("#table").append("<tr><td style='display: none' width='5%'>"+respuesta.id+
					"</td><td width='8%'>"+respuesta.rfc+"</td><td width='15%'>"+respuesta.nombreEmpresa+
					"</td><td width='15%'>"+respuesta.nombreCliente+"</td><td width='15%'>"+respuesta.apellidoPaterno+' '+respuesta.apellidoMaterno+
					"</td><td width='25%'>"+direccion+"</td><td width='8%'>"+respuesta.ciudad+
					"</td><td width='8%'>"+respuesta.estado+"</td><td width='5%'>"+respuesta.telefono+
					"</td><td style='display: none' width='5%'>"+respuesta.celular+"</td><td style='display: none' width='5%'>"+respuesta.email+
					"</td><td style='display: none' width='5%'>"+respuesta.colonia+
					"</td><td style='display: none' width='5%'>"+respuesta.calle+"</td><td style='display: none' width='5%'>"+numero+
					"</td><td style='display: none' width='5%'>"+respuesta.apellidoPaterno+"</td><td style='display: none' width='5%'>"+respuesta.apellidoMaterno+
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
			global.pagination('php/cliente.php',1);
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
			global.pagination('php/cliente.php',1);
		}
	});
		//FUNCIÓN PARA CAMBIAR PÁGINACION
	$("#pages").on('click',function(){
		$(".paginate").on('click',function(){
			var page = $(this).attr("data");	
			global.pagination('php/cliente.php',page);
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
			
			for (var i = 0; i <= array.length; i++) {
				if (array[i] == "") {
					array[i] = "N/A";
				}
			}

			$("#codigo").html("Código Cliente: " +array[0]);
			$("#rfc").html("R.F.C.: "+array[1]);
			$("#nombreEmpresa").html("Nombre Empresa: "+array[2]);
			$("#nombreCliente").html("Nombre Cliente: "+array[3]);
			$("#apellidos").html("Apellidos: "+array[4]);
			$("#domicilio").html("Domicilio: "+array[5]);
			$("#ciudad").html("Ciudad: " +array[6]);
			$("#estado").html("Estado: " +array[7]);
			$("#telefono").html("Teléfono: "+array[8]);
			$("#celular").html("Celular: "+array[9]);
			$("#email").html("E-mail: "+array[10]);

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
			localStorage.cliente = JSON.stringify(array);
			global.cargarPagina('pages/Cliente.html');
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
			$("#rfc").html("");
			$("#nombreEmpresa").html("");
			$("#nombreCliente").html("");
			$("#apellidos").html("");
			$("#domicilio").html("");
			$("#ciudad").html("");
			$("#estado").html("");
			$("#telefono").html("");
			$("#celular").html("");
			$("#email").html("");
		} // Callback for Modal close
	});
	//////////////////////////////////////////////
		/**************************
	    *		AUTOCOMPLETE	  *
	    **************************/
		//AUTOCOMPLETAR CAMPO NOMBRE
	$("#buscarN").autocomplete({
		minLength: 2,
		source: "php/autocomplete.php?opc=cliente&id=1",
		autoFocus: true,
		select: function (event, ui) {
			if (ui.item.id == 0) {
				$("#buscarN").val("");
				$("#buscarN").empty();
			}
			$('#codigoCliente').val(ui.item.id);
			return ui.item.label;
		},
		response: function(event, ui) {
			if (ui.content[0].label == null) {
				var noResult = { value: "" ,label: "No Se Encontrarón Resultados" };
				ui.content.push(noResult);
			} 
		}
	});
		//AUTOCOMPLETAR CAMPO BUQUEDA POR EMPRESA
	$("#buscarE").autocomplete({
		minLength: 2,
		source: "php/autocomplete.php?opc=cliente&id=2",
		autoFocus: true,
		select: function (event, ui) {
			if (ui.item.id == 0) {
				$("#buscarE").val("");
				$("#buscarE").empty();
			}
			$('#codigoCliente').val(ui.item.id);
			return ui.item.label;
		},
		response: function(event, ui) {
			if (ui.content[0].label == null) {
				var noResult = { value: "" ,label: "No Se Encontrarón Resultados" };
				ui.content.push(noResult);
			} 
		}
	});
});