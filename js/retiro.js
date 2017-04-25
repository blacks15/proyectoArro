$(document).ready(function(){
	global.validaSesion();
	global.isAdmin();
	global.cargaFolio('php/retiro.php','recuperaFolio');
	$("#cantidad").focus(),
	$("#fecha").val(global.obtenerFechaActual());
	editarDatos();
///////////////////////////////////////////////////////////
		/**************************
	     *		BOTONOES		  *
	     **************************/
		//BOTÓN REFRESCAR
	$("#btnRefresh").on('click',function(){
		global.cargarPagina('pages/Retiro.html');
	});
		//BOTÓN GUARDAR
	$("#btnSave").on('click',function(){
		$("#btnSave").prop('disabled',true);
		var cadena = $("#frmAgregarRetiro").serialize();
		var parametros = {opc: 'guardar',cadena };

		if (cadena == "") {
			global.messajes('Error','!Debe llenar Todos los Campos','warning');
		} else {
			global.envioAjax('retiro',parametros);
		}
		$("#btnSave").prop('disabled',false);
	});
		//BOTÓN ACTUALIZAR
	$("#btnUpdate").on('click',function(){
		$("#btnUpdate").prop('disabled',true);
		var cadena = $("#frmAgregarRetiro").serialize();
		var parametros = {opc: 'actualizar',cadena };
		
		if (cadena == "") {
			global.mensajes('Advertencia','!Debe llenar Todos los Campos','warning');
		} else {
			global.envioAjax('retiro',parametros);
		}	
		$("#btnUpdate").prop('disabled',false);
	});
		//BOTÓN ACTUALIZAR
	$("#btnDelete").on('click',function(){
		$("#btnDelete").prop('disabled',true);
		var cadena = $("#frmAgregarRetiro").serialize();
		var parametros = {opc: 'borrar',cadena };
		
		if (cadena == "") {
			global.mensajes('Advertencia','!Debe llenar Todos los Campos','warning');
		} else {
			global.envioAjax('retiro',parametros);
		}	
		$("#btnDelete").prop('disabled',false);
	});
		//BOTÓN BUSCAR
	$("#btnSearch").on('click',function(e){
		e.preventDefault();
		var buscar = $("#buscar").val(); 

		if (buscar != "") {
			$("#btnSearch").prop('disabled',true);
			var parametros = {opc: 'buscarRetiro','buscar': buscar };

			var respuesta = global.buscar('retiro',parametros);
			if (respuesta.codRetorno == '000') {
				//console.log(respuesta);	
				$("#codigoRetiro").val(respuesta.id);
				$("#folio").val(respuesta.folio);
				$("#nombreEmpleado").val(respuesta.nombreEmpleado);
				$("#fecha").val(global.formatoFecha(respuesta.fecha) );
				$("#cantidad").val(respuesta.cantidad);
				$("#descripcion").val(respuesta.descripcion);
				
				$("#buscar").val("");
				$("#btnUpdate").prop('disabled',false);
				$("#btnDelete").prop('disabled',false);
			}	
		} else {
			$("#buscar").focus();
			global.mensajes('Advertencia','Campo Buscar vacio','warning');
		}
		$("#btnSearch").prop('disabled',false);
	});
/////////////////////////////////////////////////////////////////////////////
		/**************************
	     *		  EVENTOS		  *
	     **************************/
		//EVENTO KEYPRESS
	$("#cantidad").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#descripcion").focus();
		} else {
			global.numeros(evt);
		}
	});
		//EVENTO KEYUP
	$("#cantidad").on('keyup',function(evt){
		habilitarBoton();
	});
		//EVENTO KEYPRESS
	$("#descripcion").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#btnSave").focus();
		} else {
			global.numerosLetras(evt);
		}
	});
		//EVENTO KEYUP
	$("#descripcion").on('keyup',function(){
		habilitarBoton();
	});
	     //EVENTO KEYPRESS
	$("#buscar").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#btnSearch").focus();
		} else {
			global.numeros(evt);
		}
	});
/////////////////////////////////////////////////////
		/**************************
		*		  FUNCIONES		  *
		**************************/
		//FUNCIÓN PARA HABILITAR BOTÓN
	function habilitarBoton(){
		var id = $("#codigoRetiro").val();
		var cantidad = $("#cantidad").val();
		var descripcion = $("#descripcion").val();

		if (cantidad != "" && descripcion != "") {
			if (id == "") {
				$("#btnSave").prop('disabled',false);
			} else {
				$("#btnUpdate").prop('disabled',false);
			}
		}	
	}	
		//FUNCIÓN PARA EDITAR DATOS DESDE BUSCAR RETIROS
	function editarDatos(){
		var res = "";
		var resJson = "";

		if (localStorage.retiros != undefined){
				//RECUPERAMOS LOS VALORES ALMACENADOS EN SESSION 
			res = localStorage.getItem('retiros');
				//CONVERTIMOS EL JSON A UN OBJETO
			resJson = JSON.parse(res);
			console.log(resJson);
			setTimeout(function() {
					//ASGINAMOS VALORES A LOS INPUTS
				$("#codigoRetiro").val(resJson[0]);
				$("#folio").val(resJson[1]);
				$("#nombreEmpleado").val(resJson[2]);
				$("#cantidad").val(resJson[3]);
				$("#descripcion").val(resJson[4]);
				$("#fecha").val(resJson[5]);
					//OCULTAMOS BOTON GUARDAR Y MOSTRAMOS MODIFICAR
				$("#btnUpdate").prop('disabled',false);
					//VACIAMOS LA SESSION
				localStorage.clear();
			}, 300);	
		}
	}
});