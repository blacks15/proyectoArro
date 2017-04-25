$(document).ready(function(){
	/**************************
     *	 OOCULTAR CAMPOS	   *
     **************************/
	global.validaSesion();
	global.isAdmin();
	$('ul.tabs').tabs();
	$("#nombreProducto").focus();
	disable();
	combo();
	actualizarProducto();
		/**************************
	     *		BOTONOES		  *
	     **************************/
		//BOTÓN REFRESCAR
	$("#btnRefresh").on('click',function(){
		global.cargarPagina('pages/Producto.html');
	});
		//BOTÓN GUARDAR
	$("#btnSave").on('click',function(){
		var cadena = $("#frmAgregarPoducto").serialize();
		var parametros = {opc: 'guardar',cadena };

		if (cadena == "") {
			global.messajes('Error','!Debe llenar Todos los Campos','warning');
		} else {
			global.envioAjax('producto',parametros);
		}
	});
		//BOTÓN ACTUALIZAR
	$("#btnUpdate").on('click',function(){
		var cadena = $("#frmAgregarPoducto").serialize();
		var parametros = {opc: 'actualizar',cadena };

		if (cadena == "") {
			global.mensajes('Advertencia','!Debe llenar Todos los Campos','warning');
		} else {
			global.envioAjax('producto',parametros);
		}	
	});
		//BOTÓN BUSCAR
	$("#btnSearch").on('click',function(e){
		e.preventDefault();
		var buscar = $("#codigo").val(); 

		$("#btnSearch").prop('disabled',true);
		if (buscar != "") {		
			var parametros = {opc: 'buscarProducto','buscar': buscar,'tipoBusqueda':2};

			var respuesta = global.buscar('producto',parametros);
			if (respuesta.codRetorno == '000') {
				//console.log(respuesta);	
				habilitar();
				$("#codigoProducto").val(respuesta.id);
				$("#nombreProducto").val(respuesta.nombreProducto);
				$("#codigoBarras").val(respuesta.codigoBarras);
				$("#proveedor").val(respuesta.proveedor).prop('selected','selected');
				$("#stMin").val(respuesta.stMin);
				$("#stMax").val(respuesta.stMax);
				$("#stActual").val(respuesta.stActual);
				$("#compra").val(respuesta.compra);
				$("#venta").val(respuesta.venta);
				$("#categoria").val(respuesta.categoria).prop('selected','selected');
				
				$("#buscar").val("");
				$("#btnUpdate").prop('disabled',false);
				$("input[name=tipo]").prop('disabled',true);
			}	
		} else {
			global.mensajes('Advertencia','Campo Buscar vacio','warning');
		}
		$("#btnSearch").prop('disabled',false);
	});
		//BOTÓN REPORTE
	$("#btnReporte").on('click',function(){
		alert("reports");
	});
		//BOTÓN SIGUIENTE TAB
	$("#btnSig").click(function() {
		$('ul.tabs').tabs('select_tab', 'inventario');
		$("#stMin").focus();
	});
		//BOTÓN ANTERIOR TAB
	$("#btnAnt").click(function() {
		$('ul.tabs').tabs('select_tab', 'datosProducto');
		$("#nombreProducto").focus();
	});
/////////////////////////////////////////////////////////////////////////////
		/**************************
	     *		  EVENTOS		  *
	     **************************/
		//VALIDAR CAMBIO EN LOS RADIOBUTTONS DE TIPO DE PRODUCTO
	$("input[name=tipo]").change(function(){
		var tipo = $(this).val();
				//ASIGNAMOS EL VALOR AL RADIO BUTTON
			if (tipo == 'libro') {
				habilitar();
				$("#nombreProducto").focus();
				$("#nombreProducto").autocomplete({
					minLength: 2,
			        source: "php/autocomplete.php?opc=libro",
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
			} else {
				habilitar();
				$("#nombreProducto").focus();
			}
    });
		//EVENTO KEYPRESS
	$("#nombreProducto").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 5 && charCode == 13) {
			$("#codigoBarras").focus();
		} else {
			global.letras(evt);
		}
	});
		//EVENTO KEYUP
	$("#nombreProducto").on('keyup',function(){
		validarDatos();
	});
		//EVENTO KEYPRESS
	$("#codigoBarras").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 11 && charCode == 13) {
			$("#proveedor").focus();
		} else {
			global.numeros(evt);
		}
	});
		//EVENTO KEYUP
	$("#codigoBarras").on('keyup',function(){
		validarDatos();
	});
		//EVENTO KEYPRESS
	$('#proveedor').on('keypress', function(event) {
		if (((document.all) ? event.keyCode : event.which) == 13) {
			$("#btnSig").focus();
		}
	});
		//EVENTO CHANGE
	$("#proveedor").on('change',function(){
		validarDatos();
	});
		//EVENTO KEYPRESS
	$("#stMin").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val() != 0 && charCode == 13) {
			$("#stMax").focus();
		} else {
			global.numeros(evt);
		}
	});
		//EVENTO KEYUP
	$("#stMin").on('keyup',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 0 && charCode == 13) {
			validarDatos();
		}
	});
		//EVENTO KEYPRESS
	$("#stMax").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val() != 0 && charCode == 13) {
			$("#stActual").focus();
		} else {
			global.numeros(evt);
		}
	});
		//EVENTO KEYUP
	$("#stMax").on('keyup',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 0 && charCode == 13) {
			validarDatos();
		}
	});
		//EVENTO KEYPRESS
	$("#stActual").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val() != 0 && charCode == 13) {
			$("#compra").focus();
		} else {
			global.numeros(evt);
		}
	});
		//EVENTO KEYUP
	$("#stActual").on('keyup',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 0 && charCode == 13) {
			validarDatos();
		}
	});
		//EVENTO KEYPRESS
	$("#compra").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val() != 0 && charCode == 13) {
			$("#venta").focus();
		} else {
			global.numeros(evt);
		}
	});
		//EVENTO KEYUP
	$("#compra").on('keyup',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 0 && charCode == 13) {
			validarDatos();
		}
	});
		//EVENTO KEYPRESS
	$("#venta").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val() != 0 && charCode == 13) {
			$("#categoria").focus();
		} else {
			global.numeros(evt);
		}
	});
		//EVENTO KEYUP
	$("#venta").on('keyup',function(evt){
		validarDatos();
	});
		//EVENTO KEYPRESS
	$('#categoria').on('keypress', function(event) {
		if (((document.all) ? event.keyCode : event.which) == 13) {
			$("#btnSave").focus();
		}
	});
		//EVENTO CHANGE
	$("#categoria").on('change',function(){
		validarDatos();
	});

	$("#buscar").on('keypress',function(){
		if (((document.all) ? event.keyCode : event.which) == 13 && $(this).val() != "") {
			$("#btnSearch").focus();
		}
	});
		//AAUTOCOMPLETAR CAMPO LIBRO
	$("#buscar").autocomplete({
		minLength: 2,
		source: "php/autocomplete.php?opc=producto",
		autoFocus: true,
		select: function (event, ui) {
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
/////////////////////////////////////////////////////////////////////////////
		/**************************
	    *		  FUNCIONES		  *
	    **************************/
	    //FUNCIÓN PARA MODIFICAR UN PRODUCTO DE LA VITSA "BUSCAR PRODUCTO"
	function actualizarProducto(){
		var res = "";
		var resJson = "";

		if (localStorage.producto != undefined){
				//RECUPERAMOS LOS VALORES ALMACENADOS EN SESSION 
			res = localStorage.getItem('producto');
				//CONVERTIMOS EL JSON A UN OBJETO
			resJson = JSON.parse(res);
			console.log(resJson);
			setTimeout(function() {
					//ASGINAMOS VALORES A LOS INPUTS
				$("#codigoProducto").val(resJson[0]);
				$("#codigoBarras").val(resJson[1]);
				$("#nombreProducto").val(resJson[2]);
				$("#stActual").val(resJson[4]);
				$("#venta").val(resJson[5]);
				$("#proveedor").val(resJson[7]);
				$("#stMin").val(resJson[8]);
				$("#stMax").val(resJson[9]);
				$("#compra").val(resJson[10]);
				$("#categoria").val(resJson[11]);
					//OCULTAMOS BOTON GUARDAR Y MOSTRAMOS MODIFICAR
				$("#btnUpdate").prop('disabled',false);
				$("input[name=tipo]").prop('disabled',true);
				habilitar();
					//VACIAMOS LA SESSION
				localStorage.clear();
			}, 300);	
		}
	}
		//FUNCIÓN PARA VALIDAR DATOS OBLIGATORIOS
	function validarDatos(){
		var nombreProducto = $("#nombreProducto").val();
		var codigoBarras = $("#codigoBarras").val();
		var proveedor = $("#proveedor").val();
		var stActual = $("#stActual").val();
		var stMin = $("#stMin").val();
		var stMax = $("#stMax").val();
		var compra = $("#compra").val();
		var venta = $("#venta").val();
		var categoria = $("#categoria").val();

		if (nombreProducto == "" && codigoBarras == "" && proveedor == 0 && stMin == "" && stMax == "" && stMax == 0 && stActual == "" && 
			stActual == 0 && compra == "" && compra == 0 && venta == "" && venta == 0 && categoria == 0) {
			$("#btnSave").prop('disabled',true);
		} else {
			if ( $("#codigoProducto").val() == "") {
    			$("#btnSave").prop('disabled',false);
    		} else {
    			$("#btnUpdate").prop('disabled',false);
    		}
		}
	}
    	//FUNCIÓN PARA LLENAR LOS SELECT DE LA VISTA	
	function combo(){
		$.ajax({
			cache: false,
			type: "POST",
			datatype: "json",
			url: "php/combo.php",
			data: {opc:"combo_libro"},
			success: function(opciones){
				$("#proveedor").html(opciones.opcion_proveedor);
				$("#categoria").html(opciones.opcion_categoria);
			},
			error: function(xhr,ajaxOptions,throwError){
				if (xhr.status == 404) {
					global.mensajesError('Error','Ocurrio un error');
				}
			} 
		});
	}
		//FUNCIÓN PARA DESHABILITAR CAMPOS
	function disable(){
		$("#nombreProducto").prop('disabled', true);
		$("#codigoBarras").prop('disabled', true);
		$("#proveedor").prop('disabled', true);
		$("#stMin").prop('disabled', true);
		$("#stMax").prop('disabled', true);
		$("#stActual").prop('disabled', true);
		$("#compra").prop('disabled', true);
		$("#venta").prop('disabled', true);
		$("#categoria").prop('disabled', true);
		$("#btnSig").prop('disabled', true);
		$("#btnAnt").prop('disabled', true);
		$("#inventario").prop('disabled', true);
	}
		//FUNCIÓN PARA HABILITAR CAMPOS
	function habilitar(){
		$("#nombreProducto").prop('disabled', false);
		$("#codigoBarras").prop('disabled', false);
		$("#proveedor").prop('disabled', false);
		$("#stMin").prop('disabled', false);
		$("#stMax").prop('disabled', false);
		$("#stActual").prop('disabled', false);
		$("#compra").prop('disabled', false);
		$("#venta").prop('disabled', false);
		$("#categoria").prop('disabled', false);
		$("#btnSig").prop('disabled', false);
		$("#btnAnt").prop('disabled', false);
		$("#inventario").prop('disabled', false);
	}
});