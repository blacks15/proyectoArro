$(document).ready(function(){
	/**************************
    *	 LLAMAR FUNCIONES	  *
    **************************/
	global.validaSesion();
	global.isNotAdminMenu($("#tipoUsuario").val());
	$("#btnCancela").hide();
	$("#busqueda").focus();
	$("#busquedas").hide();
//////////////////////////////////////////////////////
	/**************************
     *		BOTONOES		  *
     **************************/
		//BOTÓN NUEVO LIBRO
	$("#btnNuevo").on('click',function(){
		global.cargarPagina("pages/Deuda.html");
	});
		//BOTÓN CREAR REPORTE
	$("#btnReporte").on('click',function(){
		alert("hola salvaje");
	});
		//BOTÓN BUSCAR
	$("#btnSearch").on('click',function(e){
		e.preventDefault();
		var buscar = $("#codigoCliente").val(); 

		if (buscar != "") {
			$("#btnSearch").prop('disabled',true);
			obtenerDatos('',buscar);
		} else {
			global.mensajes('Advertencia','Campo Buscar vacio','warning');
		}
		limpíarBusquedas();
		$("#btnSearch").prop('disabled',false);	
	});
		//BOTÓN CERRAR MDOAL
	$("#btnClose").on('click',function(){
		$('#modal').modal('close');
	});
		//BOTÓN CANCELA
	$("#btnCancela").on('click',function(){
		$("#codigoCliente").val('');
		$("#nombreCliente").val('');
		$("#direccionEmpleado").val('');
		$("#totalDeuda").val('');
		$("#tableDeudas").html("");
		$("#page-numbers").html("");
		$("#btnCancela").hide();
		$("#busqueda").focus();
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
		//EVENTO KEYPRESS DEL CAMPO BUSCAR
	$("#buscarE").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#btnSearch").focus();
		} else {
			global.numerosLetras(evt);
		}
	});
		//FUNCIÓN PARA CAMBIAR PÁGINACION
	$("#pages").on('click',function(){
		$(".paginate").on('click',function(){
			obtenerDatos($(this).attr("data") , $("#codigoCliente").val() );
		});
	});
		//FUNCIÓN PARA TOMAR EL BOTOÓN ACTUALIZAR DE LA TABLA
	$('#tableDeudas').on('click',function() {
		var array = [];
		var parametros = "";
		var respuesta = "";
		$(".btnMostrar").on('click',function(index){
			var url = 'php/deuda.php';	
				//GUARDAMOS LOS VALORES DE LA TABLA EN UN ARRAY
			$(this).parents("tr").find("td").each(function(){
				array.push($(this).text());
			});
				//CREAMOS LOS PARAMETROS Y EJECUTAMOS LA BUSQUEDA
			parametros = {opc: 'buscarDetalle','buscar': array[0]};
			respuesta = global.buscar(url,parametros);
				//VALIDAMOS EL CODIGO DE RETORNO
			if (respuesta.codRetorno == '000') {
					//ASIGNAMOS LOS VALORES A LOS CAMPOS
				$("#folioVenta").html(array[0]);
				$("#detalleVenta").html("");	
					//LLENAMOS LA TABLA
				$.each(respuesta.datos,function(index,value){ console.log(value);
					$("#detalleVenta").append("<tr></td><td width='20%'>"+value.CodigoBarras+
						"</td><td width='30%'>"+value.nombreProducto+"</td><td width='10%'>$"+value.precio+
						"</td><td width='10%'>"+value.cantidad+"</td><td width='10%'>$"+value.subtotal+
						"</td></tr>"
					);
				});
					//LEVANTAMOS LA MODAL
				$('#modal').modal('open');
			}
			array.clear;
		});
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
//////////////////////////////////////////////
	/**************************
    *		 FUNCIONES	 	  *
    **************************/
		//FUNCIÓN PARA REINICIAR LAS BUSQUEDAS
	function limpíarBusquedas(){
		$("#buscarE").val("");
		$("#buscarN").val("");
		$("#busquedas").hide("explode");
		$("#busqueda").val(0).prop('selected','selected');
	}
		//FUNCIÓON PARA OBTENER LOS DATOS DE LA BUSQUEDA
	function obtenerDatos(page,buscar){
			//VALIDAMOS LA PÁGINA
		if (page == "") {
			partida = 1;
		} else {
			partida = page;
		}
		var parametros = {opc: 'buscarDeuda','buscar': buscar,'partida' :partida};

		var respuesta = global.buscar('deuda',parametros);
		if (respuesta.codRetorno == '000') {
			$("#btnCancela").show();
			nombre = respuesta.nombreCliente+' '+respuesta.apellidoPaterno+' '+respuesta.apellidoMaterno;
			direccion = respuesta.calle+' '+respuesta.numExt+' '+respuesta.numInt+' '+respuesta.colonia;

			$("#nombreCliente").val(nombre);
			$("#direccionEmpleado").val(direccion);
			$("#totalDeuda").val(global.formatearTotal( respuesta.totalDeuda ));

			$("#tableDeudas").html("");
			$.each(respuesta.datos,function(index,value){
				$("#tableDeudas").append("<tr></td><td width='30%'>"+value.folioVenta+
					"</td><td width='30%'>"+value.fechaVenta+"</td><td width='30%'>$"+value.total+
					"</td><td><td><button type='button' class='icon-info btn blue btnMostrar'></button>\
					</td></tr>"
				);
			});
			$("#page-numbers").html(respuesta.link);
		}
	}
 		//CREAMOS LA MODAL
	$('.modal').modal({
		dismissible: false, // Modal can be dismissed by clicking outside of the modal
		opacity: .7, // Opacity of modal background
		in_duration: 300, // Transition in duration
		out_duration: 200, // Transition out duration
		starting_top: '25%', // Starting top style attribute
		ending_top: '25%',
		ready: function(modal, trigger) { // Callback for Modal open. Modal and trigger parameters available.
		}, // Ending top style attribute
		complete: function() { 
			$("#folioVenta").val("");
			$("#detalleVenta").html("");
		} // Callback for Modal close
	});
});