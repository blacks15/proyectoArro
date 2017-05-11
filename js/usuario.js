$(document).ready(function(){
	/**************************
    *	 LLAMAR FUNCIONES	  *
    **************************/
	//global.validaSesion();
	//global.isAdmin();
	global.isNotAdminMenu($("#tipoUsuario").val());
	$('ul.tabs').tabs();
	$("#nombreEmpleado").focus();
///////////////////////////////////////////////////
		/**************************
	    *		 BOTONOES		  *
	    **************************/
			//BOTÓN REFRESCAR
	$("#btnRefresh").on('click',function(){
		global.cargarPagina('Usuario');
	});
		//BOTÒN PARA CAMBIAR CONTRASEÑA DEL USUARIO
	$("#btnCambiarPass").on('click',function(){
		global.cargarPagina('CambiarContrasenia');
	});
		//BOTÓN GUARDAR
	$("#btnSave").on('click',function(){
		var cadena = $("#frmAgregarUsuario").serialize();
		var parametros = {opc: 'guardar',cadena };

		if (cadena == "") {
			global.messajes('Error','!Debe llenar Todos los Campos','warning','','','','');
		} else {
			if ( validaCampos() ) {
				global.envioAjax('usuario',parametros);
			}
		}
	});
		//BOTÓN BUSCAR
	$("#btnSearch").on('click',function(e){
		e.preventDefault();
		$(this).prop('disabled',true);
		var buscar = $("#buscar").val(); 

		if (buscar != "") {
			var respuesta = global.buscar('ControllerUsuario','buscar',buscar,'');
			if (respuesta.codRetorno == '000') {
				$("#codigoEmpleado").val(respuesta.matricula);
				$("#nombreEmpleado").val(respuesta.nombreEmpleado);
				$("#nombreUsuario").val(respuesta.usuario);
				$("#tipo").val(respuesta.tipo_usuario).prop('selected','selected');

				$("#buscar").val("");
				$("#nombreEmpleado").prop('disabled',true);
				$("#btnDelete").prop('disabled',false);
			}
		} else {
			global.mensajes('Advertencia','Campo Buscar vacio','warning','','','','');
		}
		$(this).prop('disabled',false);	
	});
		//BOTÓN BORRAR
	$("#btnDelete").on('click',function(e){
		e.preventDefault();
		var codigoEmpleado = $("#codigoEmpleado").val();
		var parametros = {opc: 'eliminar','codigoEmpleado': codigoEmpleado };

		$("#btnDelete").prop('disabled',true);
		
		if (codigoEmpleado == "") {
			global.messajes('Error','!Debe llenar Todos los Campos','warning');
		} else {
			global.envioAjax('usuario',parametros);
		}
	});
		//BOTÓN CAMBIAR NOMBRE
	$("#btnCanNom").on('click',function(){
		$("#nombreEmpleado").prop('disabled',false);
		ocultar();
		deshabilitarCampos();
		limpiar();
	});
/////////////////////////////////////////////////////////////////////////////
	/**************************
	*		  EVENTOS		  *
	**************************/
		//EVENTO FOCUSOUT
	$("#nombreEmpleado").on('focusout',function(e){
		e.preventDefault();
		setTimeout(function() {
			if ( $("#nombreEmpleado").val() != "" && $("#nombreEmpleado").val().length > 0 ) {
				if ( $("#isUsu").val() == 1 ) {
					global.mensajes('Advertencia','El Empleado ya Tiene un Usuario Activo!','info','','','Usuario','1');
				} else {
					habilitarCampos();
				}
			} else {
				$("#btnCanNom").hide('scale');
				$("#isUsu").val("");
				$("#codigoEmpleado").val("");
			}
		},500);
	});
		//EVENTO KEYPRESS
	$("#nombreEmpleado").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode != 13) {
			global.letras(evt);
		}
	});
		//EVENTO KEYPRESS
	$("#tipo").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#nombreUsuario").focus();
		}
	});
		//EVENTO CHANGE
	$("#tipo").on('change',function(){
		validarDatos();
	});
		//VALIDA SI EL USUARIO EXISTE AL PERDER EL FOCO EL CAMPO USUARIO
	$("#nombreUsuario").focusout(function(){
			//LLAMAMOS LA FUNCIÓN OCULTAR
		verificaUsuario();
			//ASIGNAMOS EL CONTENIDO DEL CAMPO USUARIO A LA VARIABLE
		var codigo = $("#codigoEmpleado").val();
		var usuario = $("#nombreUsuario").val();
			//VALIDAMOS SINO VIENE VACIA LA VARIABLE USUARIO
		if (usuario != "") {
			$.ajax({
				cache: false,
				type: "POST",
				datatype: "json",
				url: "php/usuario.php",
				data: {opc:"buscar_usuario", usuario: usuario,codigo:codigo },
				success: function(response){
					if (response.codRetorno == '001') {
						$("#noDisp").show("explode");
						 Materialize.toast('Usuario no disponible', 3000, 'rounded')
					} else if (response.codRetorno == '000') {
						$("#disp").show("explode");
					} else if (response.codRetorno == '003') {
						global.cerrarSesion(response.mensaje);
					}
				},
				error: function(xhr,ajaxOptions,throwError){
					console.log("Ocurrio un Error");
				}
			});
		} 
	});
		//EVENTO KEYPRESS
	$("#nombreUsuario").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#contrasenia").focus();
		} else {
			global.numerosLetras(evt);
		}
	});
		//EVENTO KEYUP
	$("#nombreUsuario").on('keyup',function(evt){
		validarDatos();
	});
		//EVENTO KEYPRESS
	$("#contrasenia").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#repContrasenia").focus();
		} else {
			global.numerosLetras(evt);
		}
	});
		//EVENTO KEYUP
	$("#contrasenia").on('keyup',function(evt){
		validarDatos();
	});
		//EVENTO KEYPRESS
	$("#repContrasenia").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#btnSave").focus();
		} else {
			global.numerosLetras(evt);
		}
	});
		//EVENTO KEYUP
	$("#repContrasenia").on('keyup',function(evt){
		validarDatos();
	});
		//AUTOCOMPLETE
	$("#nombreEmpleado").autocomplete({
		minLength: 2,
		source: "php/autocomplete.php?opc=empleado",
		autoFocus: true,
		select: function (event, ui) {
			//console.log(ui.item);
			if (ui.item.id == "" || ui.item.id == undefined) {
				$("#nombreEmpleado").prop('disabled', false);
				$("#nombreEmpleado").focus();
				return;
			} 
			$("#nombreEmpleado").prop('disabled', true);
			$("#codigoEmpleado").val(ui.item.id);
			$("#isUsu").val(ui.item.isUsu);
			return ui.item.label;
		},
		response: function(event, ui) {
			if (ui.content[0].label == null) {
				var noResult = { id: "", value: "" ,label: "No Se Encontrarón Resultados" };
				ui.content.push(noResult);
			} 
		}
	});
/////////////////////////////////////////////////////
		/**************************
		*		  FUNCIONES		  *
		**************************/
		//FUNCIÓN PARA VALIDAR CAMPOS
	function validaCampos(){
		var usuario = $("#nombreUsuario").val();
		var contrasenia = $("#contrasenia").val();
		var repContrasenia = $("#repContrasenia").val();

		if (usuario.length < 6) {
			$("#nombreUsuario").focus();
			global.mensajes('Advertencia','El usuario debe seer mayor a 5 caracteres','info','','','','');	
			return false;
		} else if (contrasenia.length < 8) {
			$("#contrasenia").focus();
			global.mensajes('Advertencia','La contraseña debe seer mayor a 8 caracteres','info','','','','');	
			return false;
		} else if (repContrasenia.length < 8) {
			$("#repContrasenia").focus();
			global.mensajes('Advertencia','La confirmación de la contraseña debe seer mayor a 8 caracteres','info','','','','');	
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
		//FUNCIÓN PARA HABILITAR BOTÓN DE GUARDAR
	function validarDatos(){
		var matricula = $("#codigoEmpleado").val();
		var usuario = $("#nombreUsuario").val();
		var contrasenia = $("#contrasenia").val();
		var repContrasenia = $("#repContrasenia").val();
		var tipo = $("#tipo").val();

		if (matricula != "") {
			if (matricula != "" && usuario != "" && contrasenia != "" && repContrasenia != "" && tipo != "" ) {
				$("#btnSave").prop('disabled',false);
			} else {
				$("#btnSave").prop('disabled',true);
			}
		} else {
			$("#nombreEmpleado").focus();
			$("#tipo").prop('selectedIndex', 0);
			global.mensajes('Adevrtencia','Nombre de empleado incorrecto','info');
		}
	}
		//FUNCIÓN PARA HABILITAR CAMPOS
	function habilitarCampos(){
		$("#nombreUsuario").prop('disabled', false);
		$("#contrasenia").prop('disabled', false);
		$("#repContrasenia").prop('disabled', false);
		$("#tipo").prop('disabled',false);
		$("#btnSave").prop('disabled',true);
		$("#btnCanNom").show('explode');
		$("#tipo").focus();
	}
		//FUNCIÓN PARA OCULTAR BOTÓNES (DISPONIBLE O NO DISPONIBLE)
	function verificaUsuario(){
		$("#noDisp").hide('explode');
		$("#disp").hide('explode');	
	}
		//FUNCIÓN PARA OCULTAR CAMPOS
	function ocultar(){
		$("#btnCanNom").hide();
		$("#noDisp").hide('explode');
		$("#disp").hide('explode');
	}
		//FUNCIÓN PARA LIMPIAR LOS CAMPOS
	function limpiar(){
		$("#codigoEmpleado").val("");
		$("#nombreEmpleado").val("");
		$("#nombreUsuario").val("");
		$("#contrasenia").val("");
		$("#repContrasenia").val("");
		$("#tipo").prop('selectedIndex', 0);
		$("#nombreEmpleado").focus();
	}
		//SE CREA TOOLTIP
	$('.tooltipped').tooltip({
		delay: 50,
		tooltip: "Cambiar Contraseña",
		position: 'right',
	});
});