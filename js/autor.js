$(document).ready(function(){
	 /**************************
     *	 LLAMAR FUNCIONESS	   *
     **************************/
	//global.validaSesion();
	global.isNotAdminMenu($("#tipoUsuario").val());
	global.pagination('ControllerAutor',1,0);
	$("#btnUpdate").hide('explode');
		/**************************
	     *		BOTONOES		  *
	     **************************/
		//BOTÓN NUEVO AUTOR
	$("#btnNuevo").on('click',function(){
		$('#modal').modal('open');
	});
		//BOTÓN GUARDAR
	$("#btnSave").on('click',function(){
		$("#btnSave").prop('disabled',true);
		var cadena = $("#frmAgregarAutor").serialize();
		var parametros = {opc: 'guardar',cadena };
		if (cadena == "") {
			global.messajes('Error','');
		} else {
			global.envioAjax('autor',parametros);
		}	
		$("#btnSave").prop('disabled',false);
	});
		//BOTÓN ACTUALIZAR
	$("#btnUpdate").on('click',function(e){
		e.preventDefault();
		$("#btnUpdate").prop('disabled',true);
		var cadena = $("#frmAgregarAutor").serialize();
		var parametros = {opc: 'actualizar',cadena };
		
		if (cadena == "") {
			global.mensajes('Advertencia','!Debe llenar Todos los Campos','warning');
		} else {
			global.envioAjax('autor',parametros);
		}	
		$("#btnUpdate").prop('disabled',false);
	});
		//BOTÓN CREAR REPORTE
	$("#btnReporte").on('click',function(){
		alert("hola salvaje");
	});
		//BOTÓN BUSCAR
	$("#btnSearch").on('click',function(e){
		e.preventDefault();
		var buscar = $("#buscar").val(); 
		var codigo = $("#codigoAutor").val();

		if (buscar != "") {
			$("#btnSearch").prop('disabled',true);
			global.pagination('ControllerAutor',1,codigo);

			$('#pagination').hide();
			$("#btnSearch").prop('disabled',false);	
		} else {
			global.mensajes('Advertencia','Campo Buscar vacio','warning');
		}
	});
/////////////////////////////////////////////////////////////////////////////
		/**************************
	     *		  EVENTOS		  *
	     **************************/
	$("#nombre").on('keypress',function(evt){
		var codigo = $("#codigo").val();
		var nombre = $("#nombre").val();
		var charCode = evt.which || evt.keyCode;

		if ( nombre.length > 5 && charCode == 13 && codigo == "") {
			$("#btnSave").focus();
		} else if (codigo != "" && charCode == 13) {
			$("#btnUpdate").focus();
		} else {
			global.letras(evt);
		}
	});
		//EVENTO KEYPRESS DEL CAMPO BUSCAR
	$("#buscar").on('keypress',function(evt){
		var charCode = evt.which || evt.keyCode;

		if ( $(this).val() != "" && charCode == 13) {
			$("#btnSearch").focus();
		} else {
			global.numerosLetras(evt);
		}
	});
		//EVENTO CHANGE DEL CAMPO BUSCAR
	$("#buscar").on('change',function(){
		if ( $(this).val().length == 0 ) {
			global.pagination('ControllerAutor',1,0);
			$('#pagination').show();
		}
	});
		//AUTOCOMPLETE
	$("#buscar").autocomplete({
     	minLength: 2,
        source: "php/autocomplete.php?opc=autor",
		autoFocus: true,
		select: function (event, ui) {
			$('#codigoAutor').val(ui.item.id);
			return ui.item.label;
		},
		response: function(event, ui) {
			if (ui.content[0].label == null) {
				var noResult = { value: "" ,label: "No Se Encontrarón Resultados" };
				ui.content.push(noResult);
			} 
		}
     });
		//FUNCIÓN PARA CAMBIAR PÁGINACION
	$("#pagination").on('click',function(){
		$(".paginate").on('click',function(){
			var page = $(this).attr("data");		
			global.pagination('ControllerAutor',page);
		});
	});
		//FUNCIÓN PARA TOMAR EL BOTOÓN ACTUALIZAR DE LA TABLA
	$('#table').on('click',function() {
		array = [];
		$(".btnEditar").on('click',function(index){

			$(this).parents("tr").find("td").each(function(){
				array.push($(this).text());
			});

			$('#modal').modal('open');
			
			$("#codigo").val(array[0]);
			$("#nombre").val(array[1]);

			$("#btnSave").hide('explode');
			$("#btnUpdate").show('explode');

			array.clear;
		});
	});
	    //FUNCIÓN PARA TOMAR EL BOTOÓN ELIMINAR DE LA TABLA
 	$('#table').on('click',function() {
 		array = [];
		$(".btnDelete").on('click',function(index){

			$(this).parents("tr").find("td").each(function(){
				array.push($(this).text());
            });
			
			var codigo = $array[0];

			alert(codigo)

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
		ready: function(modal, trigger) { // Callback for Modal open. Modal and trigger parameters available.
			$("#nombre").focus();
		},
		complete: function() { 
			$("#codigo").val("");
			$("#nombre").val("");
		} // Callback for Modal close
	});

	$('.tooltipped').tooltip({
		delay: 50,
		tooltip: "Escriba el Nombre Completo del Autor",
		position: 'right',
	});
});