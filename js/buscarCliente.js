$(document).ready(function(){
	/**************************
     *	 OOCULTAR CAMPOS	   *
     **************************/
	//global.validaSesion();
	global.isNotAdminMenu($("#tipoUsuario").val());
	global.pagination('ControllerCliente',1,0,'');
	$("#busqueda").focus();
	$("#busquedas").hide();
//////////////////////////////////////////////////////
	/**************************
     *		BOTONOES		  *
     **************************/
		//BOTÓN NUEVO LIBRO
	$("#btnNuevo").on('click',function(){
		global.cargarPagina("Cliente");
	});
		//BOTÓN CREAR REPORTE
	$("#btnReporte").on('click',function(){
		alert("hola salvaje");
	});
		//BOTÓN CERRAR MODAL
	$("#btnClose").on('click',function(){
		$("#modal").modal('close');
	});
		//BOTÓN BUSCAR
	$("#btnSearch").on('click',function(e){
		e.preventDefault();
		$(this).prop('disabled',true);
		var buscar = $("#codigoCliente").val(); 
		var opc =  $("#busqueda").val();

		if (buscar != "") {
			global.pagination('ControllerCliente',1,buscar,opc);
		} else {
			global.mensajes('Advertencia','Campo Buscar vacio','warning');
		}

		$(this).prop('disabled',false);	
	});
/////////////////////////////////////////////////////////////////////////////
		/**************************
	     *		EVENTOS			  *
	     **************************/
		//OCULTA O MUESTRA CAMPOS PARA BUSQUEDA
	$("#busqueda").change(function(){
			//OBTENEMOS EL VALOR DEL SELECT Y LIMPIAMOS LOS CAMPOS
		var id = "";
		var opc =  $(this).val();
		$("#buscar").val('');

			//VALIDAMOS LA OPCIÓN SELECCIONADA 1 = NOMBRE , 2 = EMPRESA
		if (opc == 0) {
			$("#busquedas").hide('explode');
		} else if (opc == 1) {
			id = 1;
		} else if (opc == 2) {
			id = 2;
		}

		llamarAutocompletar(id);
	});
		//EVENTO KEYPRESS DEL CAMPO BUSCAR
	$("#buscar").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if (charCode == 13) {
			$("#btnSearch").focus();
		} else {
			global.numerosLetras(evt);
		}
	});
		//EVENTO CHANGE DEL CAMPO BUSCAR
	$("#buscar").on('keyup',function(){
		if ( $(this).val().length == 0 && $(this).val() == "") {
			global.pagination('ControllerCliente',1,0,'');
		}
	});
		//FUNCIÓN PARA CAMBIAR PÁGINACION
	$("#pages").on('click',function(){
		$(".paginate").on('click',function(){
			var page = $(this).attr("data");
			var opc =  $("#busqueda").val();
			var buscar = $("#codigoCliente").val(); 

			if (buscar == "") {
				buscar = 0;
			}

			global.pagination('ControllerCliente',page,buscar,opc);
		});
	});
		//FUNCIÓN PARA TOMAR EL BOTOÓN ACTUALIZAR DE LA TABLA
 	$('#table').on('click',function() {
 		array = [];
		$(".btnMostrar").on('click',function(index){

			$(this).parents("tr").find("td").each(function(){
				array.push($(this).text());
            });
				console.log(array);
			$('#modal').modal('open');
			
			for (var i = 0; i <= array.length; i++) {
				if (array[i] == "") {
					array[i] = "N/A";
				}
			}

			$("#codigo").html("<b>Código Cliente: </b>" +array[0]);
			$("#rfc").html("<b>R.F.C.: </b>"+array[1]);
			$("#nombreEmpresa").html("<b>Nombre Empresa: </b>"+array[2]);
			$("#nombreCliente").html("<b>Nombre Cliente: </b>"+array[3]);
			$("#apellidos").html("<b>Apellidos: </b>"+array[4]);
			$("#domicilio").html("<b>Domicilio: </b>"+array[5]);
			$("#ciudad").html("<b>Ciudad: </b>"+array[6]);
			$("#estado").html("<b>Estado: </b>"+array[7]);
			$("#telefono").html("<b>Teléfono: </b>"+array[8]);
			$("#celular").html("<b>Celular: </b>"+array[9]);
			$("#email").html("<b>E-mail: </b>"+array[10]);

			array.clear;
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
			localStorage.cliente = JSON.stringify(array);
			global.cargarPagina('Cliente');
			array.clear;
		});
	});
 		//CREAMOS LA MODAL
	$('.modal').modal({
		dismissible: true, // Modal can be dismissed by clicking outside of the modal
		opacity: .5, // Opacity of modal background
		in_duration: 300, // Transition in duration
		out_duration: 200, // Transition out duration
		starting_top: '4%', // Starting top style attribute
		ending_top: '10%', // Ending top style attribute
		complete: function() { 		
			$("#codigo").html("");
			$("#rfc").html("");
			$("#nombreEmpresa").html("");
			$("#nombreCliente").html("");
			$("#apellidos").html("");
			$("#domicilio").html("");
			$("#ciudad").html("");
			$("#estado").html("");
			$("#telefono").html("");
			$("#celular").html("");
			$("#email").html("");
		} // Callback for Modal close
	});
/////////////////////////////////////////////////////////////////////////////
		/**************************
	    *		FUNCIONES		  *
	    **************************/
	function llamarAutocompletar(opc){
		$("#buscar").show('explode');
		$("#busquedas").show("explode");
		$("#buscar").focus();
		autocompletar(opc);
	}
		//FUNCIÓN PARA AUTOMPLETAR
	function autocompletar(opc){
		$("#buscar").autocomplete({
			minLength: 2,
			source: "php/autocomplete.php?opc=cliente&id="+opc,
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
	}
});