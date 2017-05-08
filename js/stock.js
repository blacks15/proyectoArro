$(document).ready(function(){
	/**************************
     *	 OOCULTAR CAMPOS	   *
     **************************/
	//global.validaSesion();
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
		global.cargarPagina('Stock');
	});
		//BOTÓN NUEVO LIBRO
	$("#btnNuevo").on('click',function(){
		global.cargarPagina("Producto");
	});
		//BOTÓN CREAR REPORTE
	$("#btnBuscarProducto").on('click',function(){
		global.cargarPagina("BuscarProducto");
	});
		//BOTÓN BUSCAR
	$("#btnSearch").on('click',function(e){
		e.preventDefault();

		var buscar = $("#codigo").val();
		var opc  = $("#busqueda").val();

		$(this).prop('disabled',true);
			//VALIDAMOS LA BUSQUEDA
		if (buscar == "") {
			buscar = $("#buscar").val();
		}
			//VALIDAMOS SI LA VARIABLE BUSCRA ESTA VACIA
		if (buscar != "") {

			var respuesta = global.buscar('ControllerProducto','buscar',buscar,opc);
			if (respuesta.codRetorno == '000') {
				$.each(respuesta.datos,function(index,value){
					$("#codigoProducto").val(value.codigoBarras);
					$("#producto").val(value.nombreProducto);
					$("#stockActual").val(value.stActual);
				});
					//
				$("#stock").show();
				$("#buscar").val('');
				$("#nuevoStock").focus();
			}
		} else {
			global.mensajes('Advertencia','Campo Buscar vacio','warning','','','','');
		}
		$(this).prop('disabled',false);
	});
		//BOTÓN GUARDAR
	$("#btnSave").on('click',function(){
		$(this).prop('disabled',true);
		var parametros = $("#Stock").serialize();
		var cadena = {opc: 'stock',parametros };
		var st = $("#nuevoStock").val();

		if (st == 0) {
			global.mensajes('Advertencia','El Stock debe ser mayor a 0','info','','','Producto','');
		} else {
			global.envioAjax('ControllerProducto',cadena);
		}

		$(this).prop('disabled',false);
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
		$("#buscar").val("");
		$("#codigo").val("");
			//VALIDAMOS LA OPCIÓN SELECCIONADA 1 = NOMBRE , 2 = EMPRESA
		if (opc == 0) {
			$("#stock").hide();
			$("#codigoProducto").val('');
			$("#busquedas").hide('');
		} else {
			$("#busquedas").show();
			$("#buscar").show();
		}
	});
		//EVENTO KEYPRESS DEL CAMPO BUSCAR POR NOMBRE
	$("#buscar").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#btnSearch").focus();
		} else {
			global.numerosLetras(evt);
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
//////////////////////////////////////////////
		/**************************
	    *		AUTOCOMPLETE	  *
	    **************************/
		//AUTOCOMPLETAR CAMPO NOMBRE
	$("#buscar").autocomplete({
		minLength: 2,
		source: "php/autocomplete.php?opc=producto",
		autoFocus: true,
		select: function (event, ui) {
			if (ui.item.id == undefined) {
				$("#buscar").val("");
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
