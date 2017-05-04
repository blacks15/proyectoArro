$(document).ready(function(){
	 /**************************
     *	 OOCULTAR CAMPOS	   *
     **************************/
	//global.validaSesion();
	//global.isAdmin();
	$('ul.tabs').tabs();
	$("#nombreEmpresa").focus();
	actualizarProveedor();
		/**************************
	     *		BOTONOES		  *
	     **************************/
		//BOTÓN REFRESCAR
	$("#btnRefresh").on('click',function(){
		global.cargarPagina('Proveedor');
	});
			//BOTÓN BUSCAR PROVEEDORES
	$("#btnProveedores").on('click',function(){
		global.cargarPagina('BuscarProveedor');
	});
		//BOTÓN GUARDAR
	$("#btnSave").on('click',function(){
		enviarDatos();
	});
		//BOTÓN ACTUALIZAR
	$("#btnUpdate").on('click',function(){
		enviarDatos();	
	});
		//BOTÓN REPORTE
	$("#btnReporte").on('click',function(){
		alert("reports");
	});
		//BOTÓN BUSCAR
	$("#btnSearch").on('click',function(e){
		e.preventDefault();
		$("#btnSearch").prop('disabled',true);
		var buscar = $("#codigoEmpresa").val();

		if (buscar != "") {
			$("#codigoEmpresa").val(''); 
			$("#buscar").val(''); 

			var respuesta = global.buscar('ControllerProveedor','buscar',buscar);

			if (respuesta.codRetorno == '000') {
				$.each(respuesta.datos,function(index,value){
					$("#codigoEmpresa").val(value.id);
					$("#nombreEmpresa").val(value.nombreProveedor);
					$("#nombreContacto").val(value.contacto);
					$("#telefono").val(value.telefono);
					$("#celular").val(value.celular);
					$("#email").val(value.email);
					$("#web").val(value.web);
					$("#calle").val(value.calle);
					$("#numExt").val(value.numExt);
					$("#numInt").val(value.numInt);
					$("#ciudad").val(value.ciudad);
					$("#estado").val(value.estado);
					$("#colonia").val(value.colonia);
				});

				$("#btnUpdate").prop('disabled',false);
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
		$('ul.tabs').tabs('select_tab', 'datosEmpresa');
		$("#nombreEmpresa").focus();
	});
/////////////////////////////////////////////////////////////////////////////
		/**************************
	     *		  EVENTOS		  *
	     **************************/
	$("#nombreEmpresa").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 3 && charCode == 13) {
			$("#nombreContacto").focus();
		} else {
			global.letras(evt);
		}
	});
		//EVENTO KEYUP
	$("#nombreEmpresa").on('keyup',function(evt){
		validarDatos();
	});
		//EVENTO KEYPRESS NOMBRE CONTACTO
	$("#nombreContacto").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 3 && charCode == 13) {
			$("#email").focus();
		} else {
			global.letras(evt);
		}
    });
		//EVENTO KEYUP
	$("#nombreContacto").on('keyup',function(evt){
		validarDatos();
	});
		//EVENTO KEYPRESS E-MAIL
	$("#email").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 5 && charCode == 13) {
			if (global.validarEmail( $(this).val() ) ) {
				$("#web").focus();
			}
		}
    });
		//EVENTO KEYUP
	$("#email").on('keyup',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 5 && charCode == 13) {
			if (global.validarEmail( $(this).val() ) ) {
				validarDatos();
			}
		}
	});
    	//EVENTO KEYPRESS PÁGINA WEB
	$("#web").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#telefono").focus();
		} else {
			global.numerosLetrasSig(evt);
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

		if ( $(this).val().length == 10) {
			validarDatos();
		}
	});
		//EVENTO KEYPRESS CELULAR
	$("#celular").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length == 10 && charCode == 13) {
			$("#btnSig").focus();
		} else {
			global.numeros(evt);
		}
    });
		//EVENTO KEYUP
	$("#celular").on('keyup',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length == 10) {
			validarDatos();
		}
	});
		//EVENTO KEYPRESS CALLE
	$("#calle").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val().length > 2 && charCode == 13) {
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

		if ( $(this).val().length == 2 && charCode == 13) {
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

		if ( $(this).val().length > 3 && charCode == 13) {
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

		if ( $(this).val().length > 3 && charCode == 13) {
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

		if ( $(this).val().length > 3 && charCode == 13) {
			$("#btnSave").focus();
		} else {
			global.letras(evt);
		}
    });
		//EVENTO KEYUP
	$("#estado").on('keyup',function(evt){
		validarDatos();
	});
		//AUTOCOMPLETE
	$("#buscar").autocomplete({
     	minLength: 2,
        source: "php/autocomplete.php?opc=proveedor",
		autoFocus: true,
		select: function (event, ui) {
			$("#codigoEmpresa").val(ui.item.id);
			return ui.item.label;
		},
		response: function(event, ui) {
			if (ui.content[0].label == null) {
				var noResult = { value: "" ,label: "No Se Encontrarón Resultados" };
				ui.content.push(noResult);
			} 
		}
    });
		//FUNCIÓN PARA VALIDAR LOS CAMPOS
	function validarDatos(){
		var nombreEmpresa = $("#nombreEmpresa").val();
		var nombreContacto = $("#nombreContacto").val();
		var email = $("#email").val();
		var telefono = $("#telefono").val();
		var celular = $("#celular").val();
		var calle = $("#calle").val();
		var numExt = $("#numExt").val();
		var colonia = $("#colonia").val();
		var ciudad = $("#ciudad").val();
		var estado = $("#estado").val();

		if (nombreEmpresa == "" && nombreContacto == ""  &&  email == "" && telefono == "" && celular == "" && calle == "" &&
			numExt == "" && colonia == "" && ciudad == "" && estado == "") {
			$("#btnSave").prop('disabled',true);
		} else {
			if (telefono.length != 10 || celular.length != 10) {
				global.mensajes('Advertencia',"Teléfono o Celular deben ser mayor a 10 dígitos",'','','','')
			} else {
				if ( $("#codigoEmpresa").val() == "") {
					$("#btnSave").prop('disabled',false);
				} else {
					$("#btnUpdate").prop('disabled',false);
				}
			}
		}
	}
    	//FUNCIÓN PARA ENVIAR DATOS AL CONTROLADOR
    function enviarDatos(){
    	var cadena = $("#frmAgregarProveedor").serialize();
		var parametros = {opc: 'guardar',cadena };

		if (cadena == "") {
			global.mensajes('Advertencia','!Debe llenar Todos los Campos','warning');
		} else {
			global.envioAjax('ControllerProveedor',parametros);
		}
    }
		//FUNCIÓN PARA ENTRAR DESDE BUSCARPROVEEDOR Y MODIFICAR EL PROVEEDOR	
	function actualizarProveedor(){
		var res = "";
		var resJson = "";

		if (localStorage.proveedor != undefined){
				//RECUPERAMOS LOS VALORES ALMACENADOS EN SESSION 
			res = localStorage.getItem('proveedor');
				//CONVERTIMOS EL JSON A UN OBJETO
			resJson = JSON.parse(res);
			setTimeout(function() {
					//ASGINAMOS VALORES A LOS INPUTS
				$("#codigoEmpresa").val(resJson[0]);
				$("#nombreEmpresa").val(resJson[1]);
				$("#nombreContacto").val(resJson[2]);
				$("#ciudad").val(resJson[4]);
				$("#estado").val(resJson[5]);
				$("#telefono").val(resJson[6]);
				$("#celular").val(resJson[7]);
				$("#email").val(resJson[8]);
				$("#web").val(resJson[9]);
				$("#colonia").val(resJson[10]);
				$("#calle").val(resJson[11]);
				$("#numExt").val(resJson[12]);
				$("#numInt").val(resJson[13]);
					//OCULTAMOS BOTON GUARDAR Y MOSTRAMOS MODIFICAR
				$("#btnUpdate").prop('disabled',false);
					//VACIAMOS LA SESSION
				localStorage.clear();
			}, 300);	
		}
	}	
});