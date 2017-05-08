$(document).ready(function(){
	 /**************************
     *	 OOCULTAR CAMPOS	   *
     **************************/
	// global.validaSesion();
	global.isNotAdminMenu($("#tipoUsuario").val());
	global.pagination('ControllerEditorial',1,0);
	$("#btnUpdate").hide('explode');
		/**************************
	     *		BOTONES		  *
	     **************************/
		//BOTÓN NUEVO AUTOR
	$("#btnNuevo").on('click',function(){
		$('#modal').modal('open');
	});
		//BOTÓN GUARDAR
	$("#btnSave").on('click',function(){
		$("#btnSave").prop('disabled',true);
		var cadena = $("#AgregarEditorial").serialize();
		var parametros = {opc: 'guardar',cadena };

		if (cadena == "") {
			global.messajes('Error','');
		} else {
			global.envioAjax('ControllerEditorial',parametros);
		}	
		$("#btnSave").prop('disabled',false);
	});
		//BOTÓN ACTUALIZAR
	$("#btnUpdate").on('click',function(e){
		e.preventDefault();
		$("#btnUpdate").prop('disabled',true);
		var cadena = $("#AgregarEditorial").serialize();
		var parametros = {opc: 'guardar',cadena };
		
		if (cadena == "") {
			global.mensajes('Advertencia','!Debe llenar Todos los Campos','warning');
		} else {
			global.envioAjax('ControllerEditorial',parametros);
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
		$("#btnSearch").prop('disabled',true);
		var buscar = $("#buscar").val(); 

		if (buscar != "") {
			global.pagination('ControllerEditorial',1,$("#codigoEditorial").val());
			$('#pagination').hide();
		} else {
			global.mensajes('Advertencia','Campo Buscar vacio','warning');
		}
	});
/////////////////////////////////////////////////////////////////////////////
		/**************************
	     *		EVENTOS			  *
	     **************************/
	$("#nombreEditorial").on('keypress',function(evt){
		var codigo = $("#codigoEditorial").val();
		var nombre = $("#nombreEditorial").val();
		var charCode = evt.which || evt.keyCode;

		if ( nombre.length > 0 && charCode == 13 && codigo == "") {
			$("#btnSave").focus();
		} else if (nombre.length > 0 && codigo != "" && charCode == 13) {
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
    		global.pagination('ControllerEditorial',1,0);
    	}
    });
		//AUTOCOMPLETE
	$("#buscar").autocomplete({
     	minLength: 2,
        source: "php/autocomplete.php?opc=editorial",
		autoFocus: true,
		select: function (event, ui) {
			$('#codigoEditorial').val(ui.item.id);
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
			global.pagination('ControllerEditorial',page,0);
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
			
			$("#codigoEditorial").val(array[0]);
			$("#nombreEditorial").val(array[1]);

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

	$('.modal').modal({
		dismissible: true, // Modal can be dismissed by clicking outside of the modal
		opacity: .5, // Opacity of modal background
		in_duration: 300, // Transition in duration
		out_duration: 200, // Transition out duration
		starting_top: '4%', // Starting top style attribute
		ending_top: '10%', // Ending top style attribute
		ready: function(modal, trigger) { // Callback for Modal open. Modal and trigger parameters available.
			$("#nombreEditorial").focus();
		},
		complete: function() { 
			$("#codigoEditorial").val("");
			$("#nombreEditorial").val("");
		} // Callback for Modal close
	});

	$('.tooltipped').tooltip({
		delay: 50,
		tooltip: "Escriba el Nombre de la Editorial",
		position: 'right',
	});
});