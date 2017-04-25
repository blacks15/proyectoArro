$(document).ready(function(){
	/**************************
     *	 OOCULTAR CAMPOS	   *
     **************************/
	global.validaSesion();
	global.isAdmin();
	$('ul.tabs').tabs();
	$("#nombreCliente").focus();
	$("#busquedas").hide();
	entrar();
////////////////////////////////////////////////////
		/**************************
	     *		BOTONOES		  *
	     **************************/
		//BOTÓN REFRESCAR
	$("#btnRefresh").on('click',function(){
		global.cargarPagina('pages/Cliente.html');
	});
		//BOTÓN GUARDAR
	$("#btnSave").on('click',function(){
		$("#btnSave").prop('disabled',true);
		var cadena = $("#frmAgregarCliente").serialize();
		var parametros = {opc: 'guardar',cadena };

		if (cadena == "") {
			global.messajes('Advertencia','!Debe llenar Todos los Campos','warning');
		} else {
			if ( validarCampos() ) {  //prueba rfc = CUPU800825569
				global.envioAjax('cliente',parametros);
			}
		}
		$("#btnSearch").prop('disabled',false);
	});
		//BOTÓN ACTUALIZAR
	$("#btnUpdate").on('click',function(){
		$("#btnUpdate").prop('disabled',true);
		var cadena = $("#frmAgregarCliente").serialize();
		var parametros = {opc: 'actualizar',cadena };

		if (cadena == "") {
			global.mensajes('Advertencia','!Debe llenar Todos los Campos','warning');
		} else {
			if ( validarCampos() ) {  //prueba rfc = CUPU800825569
				global.envioAjax('cliente',parametros);
			}
		}	
		$("#btnUpdate").prop('disabled',false);
	});
		//BOTÓN BUSCAR
	$("#btnSearch").on('click',function(e){
		e.preventDefault();
		$("#btnSearch").prop('disabled',true);
		var buscar = $("#codigoCliente").val(); 

		if (buscar != "") {
			var parametros = {opc: 'buscarCliente','buscar': buscar };

			var respuesta = global.buscar('cliente',parametros);
			if (respuesta.codRetorno == '000') {
				$("#codigoCliente").val(respuesta.id);
				$("#nombreCliente").val(respuesta.nombreCliente);
				$("#apellidoPaterno").val(respuesta.apellidoPaterno);
				$("#apellidoMaterno").val(respuesta.apellidoMaterno);
				$("#rfc").val(respuesta.rfc);
				$("#nombreEmpresa").val(respuesta.nombreEmpresa);
				$("#email").val(respuesta.email);
				$("#telefono").val(respuesta.telefono);
				$("#celular").val(respuesta.celular);
				$("#calle").val(respuesta.calle);
				$("#numExt").val(respuesta.numExt);
				$("#numInt").val(respuesta.numInt);
				$("#colonia").val(respuesta.colonia);
				$("#ciudad").val(respuesta.ciudad);
				$("#estado").val(respuesta.estado);
				
				$("#buscarN").val("");
				$("#buscarE").val("");
				$("#btnUpdate").prop('disabled',false);
				$("#btnSearch").prop('disabled',false);
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
		$('ul.tabs').tabs('select_tab', 'direccion');
		$("#calle").focus();
	});
		//BOTÓN ANTERIOR TAB
	$("#btnAnt").click(function() {
		$('ul.tabs').tabs('select_tab', 'datosCliente');
		$("#nombreCliente").focus();
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
	$("#nombreCliente").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#apellidoPaterno").focus();
		} else {
			global.letars(evt);
		}
	});
		//EVENTO KEYUP
	$("#nombreCliente").on('keyup',function(evt){
		validarDatos();
	});
		//EVENTO KEYPRESS
	$("#apellidoPaterno").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#apellidoMaterno").focus();
		} else {
			global.letras(evt);
		}
	});
		//EVENTO KEYUP
	$("#apellidoPaterno").on('keyup',function(evt){
		validarDatos();
	});
		//EVENTO KEYPRESS
	$("#apellidoMaterno").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#rfc").focus();
		} else {
			global.letras(evt);
		}
	});
		//EVENTO KEYUP
	$("#apellidoMaterno").on('keyup',function(evt){
		validarDatos();
	});
		//EVENTO KEYPRESS
	$("#rfc").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#nombreEmpresa").focus();
		} else {
			global.numerosLetras(evt);
		}
	});
		//EVENTO KEYUP
	$("#rfc").on('keyup',function(evt){
		validarDatos();
	});
		//EVENTO KEYPRESS
	$("#nombreEmpresa").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#email").focus();
		} else {
			global.numerosLetras(evt);
		}
	});
		//EVENTO KEYUP
	$("#nombreEmpresa").on('keyup',function(evt){
		validarDatos();
	});
			//EVENTO KEYPRESS
	$("#email").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#telefono").focus();
		} else {
			global.numerosLetras(evt);
		}
	});
		//EVENTO KEYUP
	$("#email").on('keyup',function(evt){
		validarDatos();
	});
    	//EVENTO KEYPRESS TELÉFONO
	$("#telefono").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#celular").focus();
		} else {
			global.numeros(evt);
		}
    });
		//EVENTO KEYUP
	$("#telefono").on('keyup',function(evt){
		validarDatos();
	});
		//EVENTO KEYPRESS CELULAR
	$("#celular").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#btnSig").focus();
		} else {
			global.numeros(evt);
		}
    });
		//EVENTO KEYUP
	$("#celular").on('keyup',function(evt){
		validarDatos();
	});
		//EVENTO KEYPRESS CALLE
	$("#calle").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#numExt").focus();
		} else {
			global.numerosLetras(evt);
		}
    });
		//EVENTO KEYUP
	$("#calle").on('keyup',function(evt){
		validarDatos();
	});
		//EVENTO KEYPRESS NÚM. EXT.
	$("#numExt").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length == 4  && charCode == 13) {
			$("#numInt").focus();
		} else {
			global.numeros(evt);
		}
    });
		//EVENTO KEYUP
	$("#numExt").on('keyup',function(evt){
		validarDatos();
	});
		//EVENTO KEYPRESS NÚM. INT.
	$("#numInt").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#colonia").focus();
		} else {
			global.numerosLetras(evt);
		}
    });
		//EVENTO KEYUP
	$("#numInt").on('keyup',function(evt){
		validarDatos();
	});
		//EVENTO KEYPRESS COLONIA
	$("#colonia").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#ciudad").focus();
		} else {
			global.numerosLetras(evt);
		}
    });
		//EVENTO KEYUP
	$("#colonia").on('keyup',function(evt){
		validarDatos();
	});
		//EVENTO KEYPRESS CIUDAD
	$("#ciudad").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#estado").focus();
		} else {
			global.letras(evt);
		}
    });
		//EVENTO KEYUP
	$("#ciudad").on('keyup',function(evt){
		validarDatos();
	});
   		//EVENTO KEYPRESS ESTADO
	$("#estado").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#btnSave").focus();
		} else {
			global.letras(evt);
		}
    });
		//EVENTO KEYUP
	$("#estado").on('keyup',function(evt){
		validarDatos();
	});
//////////////////////////////////////////////
		/**************************
	    *		FUNCIONES		  *
	    **************************/
		//FUNCIÓN PARA VALIDAR DATOS CORRECTOS
	function validarCampos(){
		var rfc = $("#rfc").val();
		var email = $("#email").val();

		if (!global.validaRFC(rfc) ) {
			$("#rfc").focus();
			global.mensajes('Advertencia','El RFC No Coincide con el Formato Correcto','info','','','','');
			return false;
		} else if ( !global.validarEmail(email) ) {
			$("#email").focus();
			global.mensajes('Advertencia','Formato de E-mail Incorrecto','info','','','','');
			return false;
		} else {
			return true;
		}
	}
		//FUNCIÓN PARA HABILITAR BOTÓN GUARDAR
    function validarDatos(){
		var nombreCliente = $("#nombreCliente").val();
		var apellidoPaterno = $("#apellidoPaterno").val();
		var apellidoMaterno = $("#apellidoMaterno").val();
		var rfc = $("#rfc").val();
		var nombreEmpresa = $("#nombreEmpresa").val();
		var email = $("#email").val();
		var telefono = $("#telefono").val();
		var celular = $("#celular").val();
		var calle = $("#calle").val();
		var numExt = $("#numExt").val();
		var colonia = $("#colonia").val();
		var ciudad = $("#ciudad").val();
		var estado = $("#estado").val();

    	if (nombreCliente != "" && apellidoPaterno != "" && apellidoPaterno != ""  &&  rfc != "" && nombreEmpresa != "" &&
    		email != "" && telefono != "" && celular != ""  && calle != "" && numExt != "" && colonia != "" && ciudad != "" && estado != "") {
			if ( $("#codigoCliente").val() == "") {
				$("#btnSave").prop('disabled',false);
			} else {
				$("#btnUpdate").prop('disabled',false);
			}
		} else {
			$("#btnSave").prop('disabled',true);
			$("#btnUpdate").prop('disabled',true);
		}
    }
		//FUNCIÓN PARA ENTRAR DESDE BUSCARPROVEEDOR Y MODIFICAR EL PROVEEDOR	
	function entrar(){
		var res = "";
		var resJson = "";

		if (localStorage.cliente != undefined){
				//RECUPERAMOS LOS VALORES ALMACENADOS EN SESSION 
			res = localStorage.getItem('cliente');
				//CONVERTIMOS EL JSON A UN OBJETO
			resJson = JSON.parse(res);
			console.log(resJson);
			numero = resJson[13].split(" ",2);
			setTimeout(function() {
				numero = resJson[13].split(" ",2);
					//ASGINAMOS VALORES A LOS INPUTS
				$("#codigoCliente").val(resJson[0]);
				$("#rfc").val(resJson[1]);
				$("#nombreEmpresa").val(resJson[2]);
				$("#nombreCliente").val(resJson[3]);
				$("#apellidoPaterno").val(resJson[14]);
				$("#apellidoMaterno").val(resJson[15]);
				$("#ciudad").val(resJson[6]);
				$("#estado").val(resJson[7]);
				$("#telefono").val(resJson[8]);
				$("#celular").val(resJson[9]);
				$("#email").val(resJson[10]);
				$("#colonia").val(resJson[11]);
				$("#calle").val(resJson[12]);
				$("#numExt").val(numero[0]);
				$("#numInt").val(numero[1]);
					//OCULTAMOS BOTON GUARDAR Y MOSTRAMOS MODIFICAR
				$("#btnUpdate").prop('disabled',false);
					//VACIAMOS LA SESSION
				localStorage.clear();
			}, 300);	
		}
	}
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