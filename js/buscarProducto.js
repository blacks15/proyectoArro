$(document).ready(function(){
	/**************************
     *	 OOCULTAR CAMPOS	   *
     **************************/
	//global.validaSesion();
	global.isNotAdminMenu($("#tipoUsuario").val());
	global.pagination('ControllerProducto',1,0,'');
	$("#busqueda").focus();
	$("#busquedas").hide();
//////////////////////////////////////////////////////
	/**************************
     *		BOTONOES		  *
     **************************/
		//BOTÓN REFRESCAR
	$("#btnRefresh").on('click',function(){
		global.cargarPagina('BuscarProducto');
	});
		//BOTÓN NUEVO LIBRO
	$("#btnNuevo").on('click',function(){
		global.cargarPagina("Producto");
	});
		//BOTÓN BUSCAR
	$("#btnSearch").on('click',function(e){
		e.preventDefault();
		$(this).prop('disabled',false);	
		var buscar = $("#codigoProducto").val(); 
		var opc =  $("#busqueda").val();
			//VALIDAMOS LA BUSQUEDA
		if (buscar == "") {
			buscar = $("#buscar").val();
		}
			//VALIDAMOS EL CMAPO BUSCAR
		if (buscar != "") {
			global.pagination('ControllerProducto',1,buscar,opc);
		} else {
			global.mensajes('Advertencia','Campo Buscar vacio','warning','','','','');
		}
		$(this).prop('disabled',false);	
		$("#codigoProducto").val(''); 
	});
		//BOTÓN CREAR REPORTE
	$("#btnReporte").on('click',function(){
		alert("hola salvaje");
	});
/////////////////////////////////////////////////////////////////////////////
		/**************************
	     *		EVENTOS			  *
	     **************************/
		//OCULTA O MUESTRA CAMPOS PARA BUSQUEDA
	$("#busqueda").change(function(){
			//OBTENEMOS EL VALOR DEL SELECT Y LIMPIAMOS LOS CAMPOS
		var nombre = "";
		var opc =  $(this).val();

		$("#buscar").val("");
		$("#codigoProducto").val(''); 
			//VALIDAMOS LA OPCIÓN SELECCIONADA 1 = NOMBRE , 2 = PROVEEDOR
		if (opc == 0) {
			$("#busquedas").hide('explode');
		} else if (opc == 2) {
			nombre = "producto";
		} else if (opc == 3) {
			nombre = "proveedor";
		}

		llamarAutocompletar(nombre);
	});
		//EVENTO KEYPRESS
	$("#buscar").on('keypress',function(evt){
		global.numerosLetras(evt);
	});
		//FUNCIÓN PARA CAMBIAR PÁGINACION
	$("#pagination").on('click',function(){
		$(".paginate").on('click',function(){
			$(this).prop('disabled',true);
			var page = $(this).attr("data");	
			var buscar = $("#codigoProducto").val(); 
			var opc =  $("#busqueda").val();

			if (buscar == "") {
				buscar = 0;
			}

			setTimeout(function(){
				global.pagination('ControllerProducto',page,buscar,opc);
			},200);
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
			localStorage.producto = JSON.stringify(array);
			global.cargarPagina('Producto');
			array.length = 0;
		});
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
			source: "php/autocomplete.php?opc="+opc,
			autoFocus: true,
			select: function (event, ui) {
				$("#codigoProducto").val(ui.item.id);
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