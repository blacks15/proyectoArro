$(document).ready(function(){
	/**************************
     *	 OOCULTAR CAMPOS	   *
     **************************/
	global.validaSesion();
	global.isNotAdminMenu($("#tipoUsuario").val());
	$("#busquedas").hide();
	$("#filaBusqueda").hide();
	$("#stock").hide();
//////////////////////////////////////////////////////
	/**************************
     *		BOTONOES		  *
     **************************/
		//BOTÓN REFRESCAR
	$("#btnRefresh").on('click',function(){
		global.cargarPagina('pages/ActualizarInventario.html');
	});
		//BOTÓN NUEVO LIBRO
	$("#btnNuevo").on('click',function(){
		global.cargarPagina("pages/Producto.html");
	});
		//BOTÓN CREAR REPORTE
	$("#btnBuscarProducto").on('click',function(){
		global.cargarPagina("pages/BuscarProducto.html");
	});
		//BOTÓN BUSCAR
	$("#btnSearch").on('click',function(e){
		e.preventDefault();

		var buscar = $("#codigo").val();
		var opc  = $("#busqueda").val();

		$("#btnSearch").prop('disabled',true);
			//VALIDAMOS LA BUSQUEDA
		if (buscar == "") {
			buscar = $("#buscarE").val();
		}
			//VALIDAMOS SI LA VARIABLE BUSCRA ESTA VACIA
		if (buscar != "") {
			var parametros = {opc: 'buscarProducto','buscar': buscar,'tipoBusqueda':opc};

			var respuesta = global.buscar('producto',parametros);
			if (respuesta.codRetorno == '000') {
				$("#codigoProducto").val(respuesta.codigoBarras);
				$("#producto").val(respuesta.nombreProducto);
				$("#stockActual").val(respuesta.stActual);
				$("#stock").show();
				$("#buscarE").val('');
				$("#buscarN").val('');
				$("#nuevoStock").focus();
			}
		} else {
			global.mensajes('Advertencia','Campo Buscar vacio','warning');
		}
		$("#btnSearch").prop('disabled',false);
	});
		//BOTÓN GUARDAR
	$("#btnSave").on('click',function(){
		$("#btnSave").prop('disabled',true);
		var cadena = $("#updateStock").serialize();
		var parametros = {opc: 'stock',cadena };
		var st = $("#nuevoStock").val();
console.log(parametros);
		if (st == 0) {
			global.mensajes('Advertencia','El Stock debe ser mayor a 0','info','','','Producto','');
		} else {
			global.envioAjax('producto',parametros);
		}
	});
/////////////////////////////////////////////////////////////////////////////
		/**************************
	     *		  EVENTOS		  *
	     **************************/
		//VALIDAR CAMBIO EN LOS RADIOBUTTONS DE TIPO DE PRODUCTO
	$("input[name=tipo]").change(function(){
		var tipo = $(this).val();

		if (tipo == 'agregar') {
			mostrarStock('Agregar Stock',1);
		} else if (tipo == 'dev') {
			mostrarStock('Devolución',2);
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
		$("#codigo").val("");
			//VALIDAMOS LA OPCIÓN SELECCIONADA 1 = NOMBRE , 2 = EMPRESA
		if (opc == 0) {
			$("#stock").hide();
			$("#codigoProducto").val('');
			$("#busquedas").hide('explode');
		} else if (opc == 1) {
			ocultarBusquedas('buscarN','buscarE','busquedas','buscarE');
		} else {
			ocultarBusquedas('buscarE','buscarN','busquedas','buscarN');
		}
	});
		//EVENTO KEYPRESS DEL CAMPO BUSCAR POR NOMBRE
	$("#buscarN").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#btnSearch").focus();
		} else {
			global.numerosLetras(evt);
		}
	});
		//EVENTO KEYPRESS DEL CAMPO BUSCAR POR CÓDIGO
	$("#buscarE").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#btnSearch").focus();
		} else {
			global.numeros(evt);
		}
	});
		//EVENTO KEYUP
	$("#nuevoStock").on('keyup',function(){
		habilitarBoton();
	});
			//EVENTO KEYPRESS
	$("#nuevoStock").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#btnSave").focus();
		} else {
			global.numeros(evt);
		}
	});
//////////////////////////////////////////////
		/**************************
	    *		 FUNCIONES  	  *
	    **************************/
	    //FUNCIÓN HABILITAR BOTÓN
	function habilitarBoton(){
		var st = $("#nuevoStock").val();

		if (st == "") {
			$("#btnSave").prop('disabled',true);
		} else {
			$("#btnSave").prop('disabled',false);
		}
	}
		//FUNCIÓN PARA MOSTRAR BUSQUEDA
	function mostrarStock(titulo,bandera){
		$("#inputs").hide();
		$("#filaBusqueda").show();
		$("#busqueda").focus();
		$("#titulo").html(titulo);
		$("#lblAgDev").html(titulo);
		$("#bandera").val(bandera);
	}

	function ocultarBusquedas(bNombre,bCodigo,busquedas,foco,titulo){
		setTimeout(function() {
			$("#"+bNombre).hide();
			$("#"+bCodigo).show('explode');
			$("#"+busquedas).show("explode");
			$("#"+foco).focus();
		},300);
	}
//////////////////////////////////////////////
		/**************************
	    *		AUTOCOMPLETE	  *
	    **************************/
		//AUTOCOMPLETAR CAMPO NOMBRE
	$("#buscarN").autocomplete({
		minLength: 2,
		source: "php/autocomplete.php?opc=producto",
		autoFocus: true,
		select: function (event, ui) {
			if (ui.item.id == 0) {
				$("#buscarN").val("");
				$("#buscarN").empty();
			}
			$("#stockMax").val(ui.item.stockMax);
			$('#codigo').val(ui.item.id);
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
