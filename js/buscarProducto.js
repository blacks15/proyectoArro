$(document).ready(function(){
	/**************************
     *	 OOCULTAR CAMPOS	   *
     **************************/
	global.validaSesion();
	global.isNotAdminMenu($("#tipoUsuario").val());
	global.pagination('php/producto.php',1,'','');
	$("#busqueda").focus();
	$("#busquedas").hide();
//////////////////////////////////////////////////////
	/**************************
     *		BOTONOES		  *
     **************************/
		//BOTÓN REFRESCAR
	$("#btnRefresh").on('click',function(){
		global.cargarPagina('pages/BuscarProducto.html');
	});
		//BOTÓN NUEVO LIBRO
	$("#btnNuevo").on('click',function(){
		global.cargarPagina("pages/Producto.html");
	});
		//BOTÓN BUSCAR
	$("#btnSearch").on('click',function(e){
		e.preventDefault();
		var parametros = "";
		var buscar = $("#codigoProducto").val(); 
		var opc =  $("#busqueda").val();
			//VALIDAMOS LA BUSQUEDA
		if (buscar == "") {
			buscar = $("#buscarC").val();
		}
			//VALIDAMOS EL CMAPO BUSCAR
		if (buscar != "") {
			global.pagination('php/producto.php',1,buscar,opc);
		} else {
			global.mensajes('Advertencia','Campo Buscar vacio','warning');
		}
		$("#btnSearch").prop('disabled',false);	
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
		var opc =  $(this).val();
		$("#buscarC").val("");
		$("#buscarN").val("");
		$("#buscarP").val("");
			//VALIDAMOS LA OPCIÓN SELECCIONADA 1 = NOMBRE , 2 = EMPRESA
		if (opc == 0) {
			$("#busquedas").hide('explode');
		} else if (opc == 1) {
			$("#buscarN").hide();
			$("#buscarP").hide();
			$("#buscarC").show('explode');
			$("#busquedas").show("explode");
			$("#buscarC").focus();
		} else if (opc == 2) {
			$("#buscarC").hide();
			$("#buscarP").hide();
			$("#buscarN").show('explode');
			$("#busquedas").show("explode");
			$("#buscarN").focus();
		} else if (opc == 3) {
			$("#buscarC").hide();
			$("#buscarN").hide();
			$("#buscarP").show('explode');
			$("#busquedas").show("explode");
			$("#buscarP").focus();
		}
	});
		//EVENTO KEYPRESS DEL CAMPO BUSCAR
	$("#buscarC").on('keypress',function(evt){
		global.numeros(evt);
	});
		//EVENTO KEYPRESS DEL CAMPO BUSCAR
	$("#buscarN").on('keypress',function(evt){
		global.numerosLetras(evt);
	});
		//EVENTO KEYPRESS DEL CAMPO BUSCAR
	$("#buscarP").on('keypress',function(evt){
		global.numerosLetras(evt);
	});
		//FUNCIÓN PARA CAMBIAR PÁGINACION
	$("#pages").on('click',function(){
		$(".paginate").on('click',function(){
			var page = $(this).attr("data");	
			var buscar = $("#codigoProducto").val(); 
			var opc =  $("#busqueda").val();
			global.pagination('php/producto.php',page,buscar,opc);
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
			global.cargarPagina('pages/Producto.html');
			array.clear;
		});
	});
/////////////////////////////////////////////////////////////////////////////
		/**************************
	    *		AUTOCOMPLETE	  *
	    **************************/
		//PRODUCTO
	$("#buscarN").autocomplete({
     	minLength: 2,
        source: "php/autocomplete.php?opc=producto",
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
		//PROVEEDOR
	$("#buscarP").autocomplete({
		minLength: 2,
		source: "php/autocomplete.php?opc=proveedor",
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
});