$(document).ready(function(){
	/**************************
     *	 OOCULTAR CAMPOS	   *
     **************************/
	global.validaSesion();
	global.isNotAdminMenu($("#tipoUsuario").val());
	global.pagination('php/retiro.php',1);
	$("#buscar").focus();
//////////////////////////////////////////////////////
	/**************************
     *		BOTONOES		  *
     **************************/
		//BOTÓN NUEVO LIBRO
	$("#btnNuevo").on('click',function(){
		global.cargarPagina("pages/Retiro.html");
	});
		//BOTÓN BUSCAR
	$("#btnSearch").on('click',function(e){
		e.preventDefault();
		$("#btnSearch").prop('disabled',true);
		var buscar = $("#buscar").val(); 

		if (buscar != "") {
			var parametros = {opc: 'buscarRetiro','buscar': buscar };

			var respuesta = global.buscar('retiro',parametros);
			if (respuesta.codRetorno == '000') {
				console.log(respuesta);
				$("#table").html("");
				$("#table").append("<tr><td style='display: none' width='5%'>"+respuesta.id+
					"</td><td width='15%'>"+respuesta.folio+"</td><td width='25%'>"+respuesta.nombreEmpleado+
					"</td><td width='15%'>"+respuesta.cantidad+"</td><td width='25%'>"+respuesta.descripcion+
					"</td><td width='15%'>"+global.formatoFecha(respuesta.fecha)+
					"</td><td style='display: none' width='15%'>"+respuesta.fecha+
					"</td><td><button type='button' class='icon-editar btn green lighten-1 btnEditar'></button>\
					</td></tr>"
				);

				$('#page-numbers').html("");
			}
		} else {
			global.mensajes('Advertencia','Campo Buscar vacio','warning');
		}
		$("#btnSearch").prop('disabled',false);	
	});
		//BOTÓN CREAR REPORTE
	$("#btnReporte").on('click',function(){
		alert("hola salvaje");
	});
/////////////////////////////////////////////////////////////////////////////
		/**************************
	     *		EVENTOS			  *
	     **************************/
		//EVENTO KEYPRESS DEL CAMPO BUSCAR
	$("#buscar").on('keypress',function(evt){
    	var charCode = evt.which || evt.keyCode;

		if ( charCode == 13) {
    		//$("#btnSearch").focus();
    	} else {
			global.numeros(evt);
		}
    });
		//EVENTO KEYUP DEL CAMPO BUSCAR
	$("#buscar").on('keyup',function(){
		if ( $(this).val().length == 0 && $(this).val() == "") {
			global.pagination('php/retiro.php',1);
		}
	});
		//FUNCIÓN PARA CAMBIAR PÁGINACION
	$("#pages").on('click',function(){
		$(".paginate").on('click',function(){
			var page = $(this).attr("data");	
			global.pagination('php/retiro.php',page);
		});
	});
		//FUNCIÓN PARA TOMAR EL BOTOÓN ACTUALIZAR DE LA TABLA
	$('#table').on('click',function() {
		array = [];
		$(".btnEditar").on('click',function(index){
			$(this).parents("tr").find("td").each(function(){
				array.push($(this).text());
			});

			localStorage.clear();
				//CONVERTIMOS A JSON 
			localStorage.retiros = JSON.stringify(array);
			global.cargarPagina('pages/Retiro.html');
			array.clear;
		});
	});
});