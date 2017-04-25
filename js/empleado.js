$(document).ready(function(){
	 /**************************
     *	 OOCULTAR CAMPOS	   *
     **************************/
	global.validaSesion();
	global.isAdmin();
	$('ul.tabs').tabs();
	$("#nombreEmpleado").focus();
	entrar();
		/**************************
	     *		BOTONOES		  *
	     **************************/
		//BOTÓN REFRESCAR
	$("#btnRefresh").on('click',function(){
		global.cargarPagina('pages/Empleado.html');
	});
		//BOTÓN GUARDAR
	$("#btnSave").on('click',function(){
		var cadena = $("#frmAgregarEmpleado").serialize();
		var parametros = {opc: 'guardar',cadena };

		if (cadena == "") {
			global.messajes('Error','!Debe llenar Todos los Campos','warning');
		} else {
			global.envioAjax('empleado',parametros);
		}
	});
		//BOTÓN ACTUALIZAR
	$("#btnUpdate").on('click',function(){
		var cadena = $("#frmAgregarEmpleado").serialize();
		var parametros = {opc: 'actualizar',cadena };
		
		if (cadena == "") {
			global.mensajes('Advertencia','!Debe llenar Todos los Campos','warning');
		} else {
			global.envioAjax('empleado',parametros);
		}	
	});
		//BOTÓN BUSCAR
	$("#btnSearch").on('click',function(e){
		e.preventDefault();
		var buscar = $("#codigoEmpleado").val(); 

		if (buscar != "") {
			$("#btnSearch").prop('disabled',true);
			var parametros = {opc: 'buscarEmpleado','buscar': buscar };
			var url = 'php/empleado.php';	

			var respuesta = global.buscar(url,parametros);
			if (respuesta.codRetorno == '000') {
				console.log(respuesta);	
				$("#codigoEmpleado").val(respuesta.id);
				$("#nombreEmpleado").val(respuesta.nombreEmpleado);
				$("#apellidoPaterno").val(respuesta.apellidoPaterno);
				$("#apellidoMaterno").val(respuesta.apellidoMaterno);
				$("#telefono").val(respuesta.telefono);
				$("#celular").val(respuesta.celular);
				$("#sueldo").val(respuesta.sueldo);
				$("#puesto").val(respuesta.puesto);
				$("#calle").val(respuesta.calle);
				$("#numExt").val(respuesta.numExt);
				$("#numInt").val(respuesta.numInt);
				$("#colonia").val(respuesta.colonia);
				$("#ciudad").val(respuesta.ciudad);
				$("#estado").val(respuesta.estado);
				
				$("#buscar").val("");
				$("#btnUpdate").prop('disabled',false);
				$("#btnSearch").prop('disabled',false);
			}	
		} else {
			global.mensajes('Advertencia','Campo Buscar vacio','warning');
		}
		$("#btnSearch").prop('disabled',false);
	});
		//BOTÓN SIGUIENTE TAB
	$("#btnSig").click(function() {
		$('ul.tabs').tabs('select_tab', 'direccion');
		$("#calle").focus();
	});
		//BOTÓN ANTERIOR TAB
	$("#btnAnt").click(function() {
		$('ul.tabs').tabs('select_tab', 'datosEmpleado');
		$("#nombreEmpleado").focus();
	});
/////////////////////////////////////////////////////////////////////////////
		/**************************
	     *		  EVENTOS		  *
	     **************************/
	$("#nombreEmpleado").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 3 && charCode == 13) {
			$("#apellidoPaterno").focus();
		} else {
			global.letras(evt);
		}
	});
		//EVENTO KEYUP
	$("#nombreEmpleado").on('keyup',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 3 && charCode == 13) {
			validarDatos();
		}
	});
		//EVENTO KEYPRESS NOMBRE CONTACTO
	$("#apellidoPaterno").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 3 && charCode == 13) {
			$("#apellidoMaterno").focus();
		} else {
			global.letras(evt);
		}
    });
		//EVENTO KEYUP
	$("#apellidoPaterno").on('keyup',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 5 && charCode == 13) {
			validarDatos();
		}
	});
		//EVENTO KEYPRESS NOMBRE CONTACTO
	$("#apellidoMaterno").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 3 && charCode == 13) {
			$("#telefono").focus();
		} else {
			global.letras(evt);
		}
    });
		//EVENTO KEYUP
	$("#apellidoMaterno").on('keyup',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 5 && charCode == 13) {
			validarDatos();
		}
	});
    	//EVENTO KEYPRESS TELÉFONO
	$("#telefono").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length == 10 && charCode == 13) {
			$("#celular").focus();
		} else {
			global.numeros(evt);
		}
    });
		//EVENTO KEYUP
	$("#telefono").on('keyup',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length == 10 && charCode == 13) {
			validarDatos();
		}
	});
		//EVENTO KEYPRESS CELULAR
	$("#celular").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length == 10 && charCode == 13) {
			$("#puesto").focus();
		} else {
			global.numeros(evt);
		}
    });
		//EVENTO KEYUP
	$("#celular").on('keyup',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length == 10 && charCode == 13) {
			validarDatos();
		}
	});
    	//EVENTO KEYPRESS
	$("#puesto").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 4 && charCode == 13) {
			$("#sueldo").focus();
		} else {
			global.letras(evt);
		}
    });
		//EVENTO KEYUP
	$("#puesto").on('keyup',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 4 && charCode == 13) {
			validarDatos();
		}
	});
    	//EVENTO KEYPRESS
	$("#sueldo").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val() > 0 && charCode == 13) {
			$("#btnSig").focus();
		} else {
			global.numeros(evt);
		}
    });
		//EVENTO KEYUP
	$("#sueldo").on('keyup',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val() > 0 && charCode == 13) {
			validarDatos();
		}
	});
		//EVENTO KEYPRESS CALLE
	$("#calle").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 5 && charCode == 13) {
			$("#numExt").focus();
		} else {
			global.numerosLetras(evt);
		}
    });
		//EVENTO KEYUP
	$("#calle").on('keyup',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 5 && charCode == 13) {
			validarDatos();
		}
	});
		//EVENTO KEYPRESS NÚM. EXT.
	$("#numExt").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length == 4 && charCode == 13) {
			$("#numInt").focus();
		} else {
			global.numeros(evt);
		}
    });
		//EVENTO KEYUP
	$("#numExt").on('keyup',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length == 4 && charCode == 13) {
			validarDatos();
		}
	});
		//EVENTO KEYPRESS NÚM. INT.
	$("#numInt").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 0 && charCode == 13) {
			$("#colonia").focus();
		} else {
			global.numerosLetras(evt);
		}
    });
		//EVENTO KEYUP
	$("#numInt").on('keyup',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 0 && charCode == 13) {
			validarDatos();
		}
	});
		//EVENTO KEYPRESS COLONIA
	$("#colonia").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 5 && charCode == 13) {
			$("#ciudad").focus();
		} else {
			global.numerosLetras(evt);
		}
    });
		//EVENTO KEYUP
	$("#colonia").on('keyup',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 5 && charCode == 13) {
			validarDatos();
		}
	});
		//EVENTO KEYPRESS CIUDAD
	$("#ciudad").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 5 && charCode == 13) {
			$("#estado").focus();
		} else {
			global.letras(evt);
		}
    });
		//EVENTO KEYUP
	$("#ciudad").on('keyup',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 3 && charCode == 13) {
			validarDatos();
		}
	});
   		//EVENTO KEYPRESS ESTADO
	$("#estado").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 3 && charCode == 13) {
			$("#btnSave").focus();
		} else {
			global.letras(evt);
		}
    });
		//EVENTO KEYUP
	$("#estado").on('keyup',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 3 && charCode == 13) {
			validarDatos();
		}
	});
		//EVENTO KEYPRESS
	$("#buscar").on('keypress',function(){
		if (((document.all) ? event.keyCode : event.which) == 13 && $(this).val() != "") {
			$("#btnSearch").focus();
		}
	});
		//AUTOCOMPLETE
	$("#buscar").autocomplete({
		minLength: 2,
		source: "php/autocomplete.php?opc=empleado",
		autoFocus: true,
		select: function (event, ui) {
			if (ui.item.id == 0) {
				$("#buscar").val("");
				console.log(ui.item.id);
			}
			$("#codigoEmpleado").val(ui.item.id);
			return ui.item.label;
		},
		response: function(event, ui) {
			if (ui.content[0].label == null) {
				var noResult = { value: "" ,label: "No Se Encontrarón Resultados" };
				ui.content.push(noResult);
			} 
		}
	});
		//FUNCIÓN PARA VALIDAR DATOS
    function validarDatos(){
    	var nombreEmpresa = $("#nombreEmpresa").val();
    	var nombreContacto = $("#nombreContacto").val();
    	var email = $("#email").val();
    	var telefono = $("#telefono").val();
    	var celular = $("#celular").val();
    	var puesto = $("#puesto").val();
    	var calle = $("#calle").val();
    	var numExt = $("#numExt").val();
    	var colonia = $("#colonia").val();
    	var ciudad = $("#ciudad").val();
    	var estado = $("#estado").val();

    	if (nombreEmpresa == "" && nombreContacto == ""  &&  email == "" && telefono == "" && celular == "" && 
    		puesto == "" && calle == "" && numExt == "" && colonia == "" && ciudad == "" && estado == "") {
    		$("#btnSave").prop('disabled',true);
    		$("#btnUpdate").prop('disabled',true);
    	} else {
    		if ( $("#codigoEmpleado").val() == "") {
    			$("#btnSave").prop('disabled',false);
    		} else {
    			$("#btnUpdate").prop('disabled',false);
    		}
    	}
    }
		//FUNCIÓN PARA ENTRAR DESDE BUSCAREMPLEADO Y MODIFICAR EL EMPLEADO	
	function entrar(){
		var res = "";
		var resJson = "";

		if (localStorage.empleado != undefined){
				//RECUPERAMOS LOS VALORES ALMACENADOS EN SESSION 
			res = localStorage.getItem('empleado');
				//CONVERTIMOS EL JSON A UN OBJETO
			resJson = JSON.parse(res);
			setTimeout(function() {
				numero = resJson[12].split(" ",2);
					//ASGINAMOS VALORES A LOS INPUTS
				$("#codigoEmpleado").val(resJson[0]);
				$("#nombreEmpleado").val(resJson[1]);
				$("#apellidoPaterno").val(resJson[13]);
				$("#apellidoMaterno").val(resJson[14]);
				$("#ciudad").val(resJson[4]);
				$("#estado").val(resJson[5]);
				$("#telefono").val(resJson[6]);
				$("#celular").val(resJson[7]);
				$("#sueldo").val(resJson[8]);
				$("#puesto").val(resJson[9]);
				$("#colonia").val(resJson[10]);
				$("#calle").val(resJson[11]);
				$("#numExt").val(numero[0]);
				$("#numInt").val(numero[1]);
					//OCULTAMOS BOTON GUARDAR Y MOSTRAMOS MODIFICAR
				$("#btnUpdate").prop('disabled',false);
					//VACIAMOS LA SESSION
				localStorage.clear();
			}, 300);	
		}
	}	
});