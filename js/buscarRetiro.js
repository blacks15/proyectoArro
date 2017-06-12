$(document).ready(function(){
	/**************************
     *	 OOCULTAR CAMPOS	   *
     **************************/
	//global.validaSesion();
	global.isNotAdminMenu($("#tipoUsuario").val());
	global.pagination('ControllerMovimientos',1,0,'');
	$("#buscar").focus();
//////////////////////////////////////////////////////
	/**************************
     *		BOTONOES		  *
     **************************/
		//BOTÓN NUEVO LIBRO
	$("#btnNuevo").on('click',function(){
		global.cargarPagina("Retiro");
	});
		//BOTÓN BUSCAR
	$("#btnSearch").on('click',function(e){
		e.preventDefault();
		$(this).prop('disabled',true);
		var buscar = $("#buscar").val(); 

		if (buscar == "") {
			global.mensajes('Advertencia','Campo Buscar vacio','warning','','','','');
		} else if (buscar.length < 13) {
            global.mensajes('Advertencia', 'El Folio Debe Ser Mayor a 13 Digitos', 'warning', '', '', '', '');
        } else {
			global.pagination('ControllerMovimientos',1,buscar,'');
			$('#pagination').hide();
		}

		$("#buscar").focus();
		$(this).prop('disabled',false);	
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
			global.pagination('ControllerMovimientos',1,0,'');
		}
	});
		//FUNCIÓN PARA CAMBIAR PÁGINACION
	$("#pagination").on('click',function(){
		$(".paginate").on('click',function(){
			var page = $(this).attr("data");	
			global.pagination('ControllerMovimientos',page,0,'');
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
			global.cargarPagina('Retiro');
			array.length = 0;
		});
	});
});