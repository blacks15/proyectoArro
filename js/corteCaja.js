$(document).ready(function(){
	/****************************
    *		CARGA FUNCIONES		*
    ****************************/
	global.validaSesion();
	global.cargaFolio('php/corteCaja.php','recuperaFolio');
	global.Corte('php/corteCaja.php','calcularCorte');
	$("#fechaCorte").val(global.obtenerFechaActual());
////////////////////////////////////////////////////
	/**********************
    *	 	BOTONES		  *
    **********************/
	$("#btnSave").on('click',function(){
		var cadena = $("#frmAgregarCorteCaja").serialize();
		var parametros = {opc: 'guardar',cadena };

		if (cadena == "") {
			global.messajes('Error','!Debe llenar Todos los Campos','warning');
		} else {
			global.envioAjax('corteCaja',parametros);
		}
	});
});