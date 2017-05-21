$(document).ready(function(){
	//global.validaSesion();
	//global.isAdmin();
	global.isNotAdminMenu($("#tipoUsuario").val());
	$("#nombreUsuario").focus();
		/**************************
	    *		 BOTONES	 	  *
	    **************************/
		//BOTÓN BUSCAR
	$("#btnSearch").on('click',function(e){
		e.preventDefault();
		$(this).prop('disabled',true);
		var buscar = $("#nombreUsuario").val(); 

		if (buscar != "") {
			var respuesta = global.buscar('ControllerUsuario','buscar',buscar);
			
			if (respuesta.codRetorno == '000') {
				$("#codigoEmpleado").val(respuesta.matricula);
				$("#nombreEmpleado").val(respuesta.nombreEmpleado);
				$("#tipo").val(respuesta.tipo_usuario).prop('selected','selected');

				$("#nombreUsuario").prop("readonly",true);
				habilitarCampos();
			} else {
				global.mensajes('Error','Ocurrio un Error con la Petición','warning','','','','');
			}
		} else {
			global.mensajes('Advertencia','Campo Buscar vacio','warning','','','','');
		}
		$(this).prop('disabled',false);
	});
		//BOTÓN GUARDAR
	$("#btnSave").on('click',function(){
		var cadena = $("#frmCambiarPassword").serialize();
		var parametros = {opc: 'cambiarContrasenia',cadena };

		if (cadena == "") {
			global.messajes('Error','!Debe llenar Todos los Campos','warning','','','','');
		} else {
			if ( validaCampos() ) {
				global.envioAjax('ControllerUsuario',parametros);
			}
		}
	});
/////////////////////////////////////////////////////
		/**************************
		*		EVENTOS			  *
		**************************/
	$("#nombreUsuario").on('keypress',function(event){
		if (((document.all) ? event.keyCode : event.which) == 13) {
			$("#btnSearch").focus();
		} else {
			global.numerosLetras(event);
		}
	});
		//EVENTO KEYPRESS
	$("#contrasenia").on('keypress',function(){
		if (((document.all) ? event.keyCode : event.which) == 13) {
			$("#repContrasenia").focus();
		} else {
			global.numerosLetrasSig(event);
		}
	});	
		//EVENTO KEYUP
	$("#contrasenia").on('keyup',function(){
		habilitarBoton();
	});
		//EVENTO KEYPRESS
	$("#repContrasenia").on('keypress',function(){
		if (((document.all) ? event.keyCode : event.which) == 13) {
			$("#btnSave").focus();
		} else {
			global.numerosLetrasSig(event);
		}
	});	
		//EVENTO KEYUP
	$("#repContrasenia").on('keyup',function(){
		habilitarBoton();
	});
//////////////////////////////////////////////////
		/**************************
		*		  FUNCIONES		  *
		**************************/
		//FUNCIÓN PARA VALIDAR CAMPOS
	function validaCampos(){
		var contrasenia = $("#contrasenia").val();
		var repContrasenia = $("#repContrasenia").val();

		if (contrasenia.length < 8) {
			$("#contrasenia").focus();
			global.mensajes('Advertencia','La contraseña debe ser mayor a 8 caracteres','info','','','','');	
			return false;
		} else if (repContrasenia.length < 8) {
			$("#repContrasenia").focus();
			global.mensajes('Advertencia','La confirmación de la contraseña debe ser mayor a 8 caracteres','info','','','','');	
			return false;
		} else if (contrasenia != repContrasenia) {
			$("#contrasenia").focus();
			$("#contrasenia").val("");
			$("#repContrasenia").val("");
			global.mensajes('Advertencia','La contraeña y la confirmación de la contraseña no son iguales','info','','','','');	
			return false;
		} else {
			return true
		}
	}
		//FUNCIÓN PARA HABILITAR BOTÓN
	function habilitarBoton(){
		var contrasenia = $("#contrasenia").val()
		var repContrasenia = $("#repContrasenia").val()
		
		if (contrasenia != "" && repContrasenia != "") {
			$("#btnSave").prop('disabled',false);
		} else {
			$("#btnSave").prop('disabled',true);
		}
	}
		//FUNCIÓN PARA HABILITAR CAMPOS
	function habilitarCampos(){
		$("#contrasenia").prop('disabled', false);
		$("#repContrasenia").prop('disabled', false);
		$("#contrasenia").focus();
	}
		//FUNCIÓN PARA DESHABILITAR CAMPOS
	function deshabilitarCampos(){
		$("#contrasenia").prop('disabled', true);
		$("#repContrasenia").prop('disabled', true);
		$("#nombreUsuario").focus();
	}
});