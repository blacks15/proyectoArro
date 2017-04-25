$(document).ready(function(){
	global.validaSesion();
	$("#quitar").hide('explode');
	$("#folio").focus();
	$("#detalleVenta").hide();
/////////////////////////////////////////////////////////////
	/**************************
    *		BOTONES			  *
    **************************/
    	//BOTÓN QUITAR FOLIO
    $("#quitar").on('click',function(e){
    	e.preventDefault();
    	limpiarCampos();
    });
    	//BOTÓN GUARDAR
    $("#btnSave").on('click',function(){
    	var folio = $("#folio").val();
    	var status = $("#status").val();
		var parametros = {opc: 'cambiarStatus',folio: folio,status: status };
			//VALIDAMOS EL STATUS
		if (status == 0) {
			global.messajes('Error','Seleccione un status','warning');
		}
			//VALIDAMOS EL FOLIO
		if (folio == "") {
			global.messajes('Error','Ocurrio un error con el servidor','warning');
		} else {
			global.envioAjax('ventas',parametros);
		}
    });
    	//BOTÓN BUSCAR
	$("#btnSearch").on('click',function(e){
		e.preventDefault();
		var buscar = $("#folio").val(); 
		$("#btnSearch").prop('disabled',true);

		if (buscar != "") {
			$("#btnSearch").prop('disabled',true);
			$("#folio").prop('readonly',true);
			var parametros = {opc: 'buscarVenta','buscar': buscar };

			var respuesta = global.buscar('ventas',parametros);
			if (respuesta.codRetorno == '000') {
				if (respuesta.status == 'PAGADA') {
					status = 1;
				} else if (respuesta.status == 'CANCELADA') {
					status = 2;
				} else {
					status = 3;
				}
					//ASIGNAMOS DATOS A LOS CAMPOS
				$("#fechaVenta").val(global.formatoFecha(respuesta.fecha));
				$("#nombreEmpleado").val(respuesta.nombreEmpleado);
				$("#codigoEmpleado").val(respuesta.codigoEmpleado);
				$("#status").val(status).prop('selected','selected');
				$("#totalVenta").val('$'+respuesta.totalVenta);
				$("#detalleVenta").show();
				global.pagination('php/ventas.php',1,$("#folio").val());
				
				$("#btnSave").prop('disabled',false);
				$("#btnSearch").hide('explode');
				$("#quitar").show('explode');
			} else {
				$("#folio").prop('readonly',false);
				$("#folio").focus();
			}
		} else {
			global.mensajes('Advertencia','Campo Folio vacio','warning');
		}
		$("#btnSearch").prop('disabled',false);	
	});
/////////////////////////////////////////////////////////////////////////////
		/**************************
	     *		  EVENTOS		  *
	     **************************/
		//KEYPRESS
	$("#folio").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#btnSearch").focus();
		} else {
			global.numeros(evt);
		}
	});
/////////////////////////////////////////////////////////////
	/**************************
    *		FUNCIONES		  *
    **************************/
		//FUNCIÓN PARA LIMPIAR CAMPOS
    function limpiarCampos(){
		$("#folio").val('');
		$("#fechaVenta").val('');
		$("#nombreEmpleado").val('');
		$("#codigoEmpleado").val('');
		$("#nombreCliente").val('');
		$("#totalVenta").val('');
		$("#status").val(0).prop('selected','selected');
		$("#btnSearch").show('explode');
		$("#quitar").hide('explode');
		$("#btnSave").prop('disabled',true);
		$("#folio").prop('readonly',false);
		$("#folio").focus();
		$("#table").html("");
		$("#page-numbers").html("");
		$("#detalleVenta").hide();
	}
});	