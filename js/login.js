$(document).ready(function() {
    $("#usuario").focus();
    /**************************
     *		BOTONOES		  *
     **************************/
    //BOTÓN LOGIN
    $("#btnLogin").on('click', function() {
        $("#btnLogin").prop('disabled', true);
        validarLogin();
    });
    /////////////////////////////////////////////////////////////////////////////
    /**************************
     *		EVENTOS			  *
     **************************/
    $("#usuario").on('keypress', function(evt) {
        var charCode = evt.which || evt.keyCode;
        var usuario = $("#usuario").val();
        if (charCode == 13 && usuario.length > 5) {
            $("#password").focus();
        } else {
            global.numerosLetrasSig(evt);
        }
    });
    //EVENTO KEYPRESS DEL CAMPO USUARIO
    $("#usuario").on('keyup', function(evt) {
        var usuario = $("#usuario").val();
        if (password.length == 0 && password == "") {
            $("#btnLogin").prop('disabled', false);
        }
    });
    //EVENTO KEYPRESS DEL CAMPO PASSWORD
    $("#password").on('keypress', function(evt) {
        var charCode = evt.which || evt.keyCode;
        var password = $("#password").val();
        if (charCode == 13 && password.length > 5) {
            $("#btnLogin").focus();
        } else {
            global.numerosLetrasSig(evt);
        }
    });
    //EVENTO KEYUP DEL CAMPO PASSWORD
    $("#password").on('keyup', function() {
        var usuario = $("#usuario").val();
        var password = $("#password").val();
        if (usuario != "" && password != "" && password.length > 5) {
            $("#btnLogin").prop('disabled', false);
        } else {
            $("#btnLogin").prop('disabled', true);
        }
    });
    //FUNCIÓN PARA VALIDAR LOGIN
    function validarLogin() {
        var usuario = $("#usuario").val();
        var password = $("#password").val();
        var cadena = JSON.stringify(global.json("#frmLogin"));
        var parametros = { opc: 'login', cadena };

        if (usuario != "" && password != "") {
            global.envioAjax('ControllerLogin', parametros);
        } else {
            global.mensajes('Advertencia', '!Debe llenar Todos los Campos', 'warning');
            $("#usuario").focus();
        }
        $("#btnLogin").prop('disabled', false);
    }
});