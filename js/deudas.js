$(document).ready(function(){
	/**************************
    *	 OOCULTAR CAMPOS	  *
    **************************/
	global.validaSesion();
	global.isAdmin();
	$('ul.tabs').tabs();
	$("#busquedas").hide();
	$("#borrar").hide('explode');
	$("#busqueda").focus();
////////////////////////////////////////////////////
		/**************************
	     *		BOTONOES		  *
	     **************************/
		//BOTÓN GUARDAR
	$("#btnSave").on('click',function(){
		var cadena = $("#frmAgregarDeuda").serialize();
		var parametros = {opc: 'guardar',cadena };

		if (cadena == "") {
			global.messajes('Error','!Debe llenar Todos los Campos','warning');
		} else {
			global.envioAjax('deuda',parametros);
		}
	});
		//BOTÓN REFRESCAR
	$("#btnRefresh").on('click',function(){
		global.cargarPagina('pages/Deuda.html');
	});
		//BOTÓN REPORTE
	$("#btnReporte").on('click',function(){
		alert("reports");
	});
		//BOTÓN SIGUIENTE TAB
	$("#btnSig").click(function() {
		$('ul.tabs').tabs('select_tab', 'detalleDeuda');
		$("#folio").focus();
	});
		//BOTÓN ANTERIOR TAB
	$("#btnAnt").click(function() {
		$('ul.tabs').tabs('select_tab', 'datosDeuda');
		$("#busqueda").focus();
	});
		//BOTÓN BUSCAR
	$("#btnSearch").on('click',function(e){
		e.preventDefault();
		$("#btnSearch").prop('disabled',true);
		var buscar = $("#codigoCliente").val(); 

		if (buscar != "") {
			var parametros = {opc: 'buscarCliente','buscar': buscar };
			var url = 'php/cliente.php';	

			var respuesta = global.buscar(url,parametros);
			console.log(respuesta);
			if (respuesta.codRetorno == '000') {
				//console.log(respuesta);	
				direccion = respuesta.numExt+'-'+respuesta.numInt+' '+respuesta.calle+' '+respuesta.ciudad+' '+respuesta.estado;
				$("#codigoCliente").val(respuesta.id);
				$("#nombreCliente").val(respuesta.nombreCliente);
				$("#apellidos").val(respuesta.apellidoPaterno+' '+respuesta.apellidoMaterno);
				$("#nombreEmpresa").val(respuesta.nombreEmpresa);
				$("#direccion").val(direccion);
				$("#telefono").val(respuesta.telefono);
				$("#celular").val(respuesta.celular);

				$("#buscarN").val("");
				$("#buscarE").val("");
				$("#busquedas").hide('explode');
				$("#busqueda").val(0).prop('selected','selected');
				$("#btnSearch").prop('disabled',false);
				$("#btnSig").trigger('click');
			}	
		} else {
			global.mensajes('Advertencia','Campo Buscar vacio','warning');
		}
		$("#btnSearch").prop('disabled',false);
	});
		//BOTÓN BORRAR FOLIO
	$("#borrar").on('click',function(){
		$("#folio").val('');
		$("#fechaCompra").val('');
		$("#fechaCompra2").val('');
		$("#totalCompra").val('');
		$("#table").html('');
		$("#folio").prop('readonly',false);
		$("#borrar").hide('explode');
		$("#folio").focus();
	});
/////////////////////////////////////////////////////////////////////////////
		/**************************
	     *		  EVENTOS		  *
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
			//EVENTO KEYPRESS
	$("#folio").on('keypress',function(event){
		if (((document.all) ? event.keyCode : event.which) == 13) {
			//
		} else {
			global.numeros(event);
		}
	});
		//EVENTO KEYUP
	$("#folio").on('keyup',function(evt){
		var charCode = evt.which || evt.keyCode;
		if ($(this).val().length >= 12 && charCode == 13) {
			var buscar = $(this).val(); 
			var parametros = {opc: 'buscarFolio','folio': buscar };
			var url = 'php/ventas.php';	

			var respuesta = global.buscar(url,parametros);
			if (respuesta.codRetorno == '000') {
				//console.log(respuesta);	
				$("#folio").prop('readonly',true);
				$("#fechaCompra").val(global.formatoFecha(respuesta.fecha));
				$("#fechaCompra2").val(respuesta.fecha);
				$("#totalCompra").val(respuesta.total);
					//LLENAMOS LA TABLA CON EL DETALLE DE LA VENTA
				$("#table").html("");
				$.each(respuesta.datos,function(index,value){
					$("#table").append("<tr><td style='display: none' width='10%'>"+value.id+
						"</td><td width='40%'>"+value.nombreProducto+"</td><td width='10%'>"+value.cantidad+
						"</td><td width='15%'>"+value.precio+"</td><td width='15%'>"+value.subtotal+
						"</td></tr>"
					).show('fold',1000);
				});
				$("#btnSave").prop('disabled',false);
				$("#borrar").show('explode');
			} 
		}
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