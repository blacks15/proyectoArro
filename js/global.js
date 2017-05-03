var global = {
	mensajesError: function(titulo,texto,form,logOut){
		swal({
			title: titulo,
			text: texto,
			imageUrl: "img/ctris.png",
			confirmButtonColor: '#3085d6',
			confirmButtonText: 'Si',
			allowEscapeKey: false,
			allowOutsideClick: false
		}).then(function() {
			if (form != '' && form != undefined) {
				global.cargarPagina(form);
			} else if (logOut == 1) {
				window.open('index.html','_top');
			}
		});
	},
		//FUNCIÓN PARA VALIDAR SI ES ADMIN
	isAdmin: function(){
		var isAdmin = $("#tipoUsuario").val();
		$.ajax({
			cache: false,
			type: "POST",
			dataType: "json",
			url: 'php/isAdmin.php',
			success: function(response) {
				if (response.codRetorno == '001') {
					global.mensajesError('Usuario No autorizado!',response.mensaje,response.form,'');
				} else if (response.codRetorno == '003') {
					global.cerrarSesion(response.mensaje);
				}
			},
			error: function(xhr,ajaxOptions,throwError){
				if (xhr.status == 404) {
					global.mensajesError('Error','Ocurrio un error','','');
				}
			}
		});
	},
		//FUNCIÓN ENVAIA AJAX POST
	envioAjax: function(url,parametros){
		$.ajax({
			cache: false,
			type: "POST",
			dataType: "json",
			data: parametros,
			url: 'php/Controllers/'+url+'.php',
			beforeSend: function () {
				$("#loader").fadeIn(1000);
			},
			complete: function () {
				$("#loader").fadeOut(1000);
			},
			success: function(response) {
				if (response == "" || response == null) {
					global.mensajes('Error','Ocurrio un error','error','','','','');
					return;
				}
				if (response != 1) {
					if (response.codRetorno == "" || response.codRetorno == undefined) {
						global.mensajes('Error','Ocurrio un error','error','','','','');
						return;
					} else 	if (response.codRetorno == '000') {
						if (response.form == 'Autor' || response.form == 'Editorial' || response.form == 'Venta') {
							$('#modal').modal('close');
							$('#modal2').modal('close');
						}
						global.mensajes(response.Titulo,response.Mensaje,'success',response.url,response.codRetorno,response.form,response.tipo);
					} else if (response.codRetorno == '001') {
						global.mensajes('Advertencia',response.Mensaje,'warning',response.url,'','','');
					} else if (response.codRetorno == '002') {
						global.mensajes('Error',response.Mensaje,'error','','','','');
					} else if (response.codRetorno == '003') {
						global.cerrarSesion(response.Mensaje);
					} else if (response.codRetorno == '004') {
						global.mensajes(response.Titulo,response.Mensaje,'warning','','','','');
					}
				} else {
					global.mensajesError('Error','Contacte con el Administrador');
				}
			},
			error: function(xhr,ajaxOptions,throwError){
				console.log(xhr+" "+ajaxOptions+" "+throwError);
				if (xhr.status == 404) {
					global.mensajesError('Error','Ocurrio un error','');
				}
			}
		});
	},
		//FUNCIÓN PARA CREAR MENSAJES
	mensajes: function(titulo,texto,tipo,url,codRetorno,form,bus) {
		swal({
			title: titulo,
			type: tipo,
			text: texto,
			confirmButtonColor: '#3085d6',
			cancelButtonColor: '#d33',
			confirmButtonText: 'Ok',
			allowEscapeKey: false,
			allowOutsideClick: false,
			showLoaderOnConfirm: true,
		}).then(function() {
			if (url != "" && url != undefined) {
				if (form == 'frmLogin') {
					sessionStorage.usuario = texto;
					sessionStorage.tipo = bus;
				}
				window.location.href = url;
			} else if (codRetorno == '000') {
				$("#pages").load('pages/'+form+'.html');
			} else if (bus == '1') {
				global.cargarPagina(form);
			}
		});
	},
		//FUNCIÓN PARA CARGAR LAS PÁGINAS
	cargarPagina: function(pagina){
		$("#loader").fadeIn(500);
		$("#pages").load('pages/'+pagina+'.html',function(responseText,statusText, xhr){
			if(statusText == "error") {
				$("#pages").load("pages/404.html");
			}
		});
		$("#loader").fadeOut(500);
	},
		//FUNCIÓN PARA PAGINACIÓN
	pagination: function (url,page,dato,opc) {
		var parametros;
		if (page == "") {
			parametros = 'partida='+1+'&codigo='+dato+'&tipoBusqueda='+opc;
		} else {
			parametros = 'partida='+page+'&codigo='+dato+'&tipoBusqueda='+opc;
		}

		$.ajax({
			cache: false,
			type: "POST",
			dataType: "json",
			data: {opc:"buscar",parametros},
			url: 'php/Controllers/'+url+'.php',
			success:function(data){
				if (data.codRetorno == "001") {
					global.mensajesError('Error',data.Mensaje,data.form);
				} else if (data.codRetorno == '002') {
					global.mensajes('Error',data.Mensaje,'error','','',data.form,'1');
				} else {
					if (data.form == 'Libro') {
						$("#table").html("");
						$.each(data.datos,function(index,value){
							$("#table").append("<tr><td style='display: none' width='5%'>"+value.id+
								"</td><td width='30%'>"+value.nombre+"</td><td width='10%'>"+value.isbn+
								"</td><td width='15%'>"+value.autor+"</td><td width='15%'>"+value.editorial+
								"</td><td style='display: none' width='20%'>"+value.descripcion+
								"</td><td style='display: none' width='5%'>"+value.idAutor+
								"</td><td style='display: none' width='5%'>"+value.idEditorial+
								"</td><td><button type='button' class='icon-imagen btn blue btnImage'></button>\
								<button type='button' class='icon-editar btn green lighten-1 btnEditar'></button>\
								</td></tr>"
							).show('fold',1000);
						});
						$("#page-numbers").html(data.link);
						return;
					} else if (data.form == 'Proveedor') {
						$("#table").html("");
						$.each(data.datos,function(index,value){
							$("#table").append("<tr><td style='display: none' width='5%'>"+value.id+
								"</td><td width='30%'>"+value.nombreProveedor+"</td><td width='10%'>"+value.contacto+
								"</td><td width='25%'>"+value.direccion+"</td><td width='8%'>"+value.ciudad+"</td><td width='8%'>"+value.estado+
								"</td><td width='5%'>"+value.telefono+"</td><td width='5%'>"+value.celular+
								"</td><td style='display: none' width='10%'>"+value.email+"</td><td style='display: none'>"+value.web+
								"</td><td style='display: none'>"+value.colonia+"</td><td style='display: none'>"+value.calle+
								"</td><td style='display: none'>"+value.numExt+"</td><td style='display: none'>"+value.numInt+
								"</td><td><button type='button' class='icon-info btn blue btnMostrar'></button></td>\
								<td><button type='button' class='icon-editar btn green lighten-1 btnEditar'></button>\
								</td></tr>"
							).show('fold',1000);
						});
						$("#page-numbers").html(data.link);
						return;
					} else if (data.form == 'Empleado') {
						$("#table").html("");
						$.each(data.datos,function(index,value){
							numero = value.numExt+' '+value.numInt;
							$("#table").append("<tr><td style='display: none' width='5%'>"+value.id+
								"</td><td width='30%'>"+value.nombreEmpleado+"</td><td width='15%'>"+value.apellidos+
								"</td><td width='25%'>"+value.direccion+"</td><td width='8%'>"+value.ciudad+
								"</td><td width='8%'>"+value.estado+"</td><td width='5%'>"+value.telefono+
								"</td><td width='5%'>"+value.celular+"</td><td width='5%'>"+value.sueldo+
								"</td><td width='5%'>"+value.puesto+"</td><td style='display: none' width='5%'>"+value.colonia+
								"</td><td style='display: none' width='5%'>"+value.calle+"</td><td style='display: none' width='5%'>"+numero+
								"</td><td style='display: none' width='5%'>"+value.apellidoPaterno+"</td><td style='display: none' width='5%'>"+value.apellidoMaterno+
								"</td><td><button type='button' class='icon-info btn blue btnMostrar'></button></td>\
								<td><button type='button' class='icon-editar btn green lighten-1 btnEditar'></button>\
								</td></tr>"
							).show('fold',1000);
						});
						$("#page-numbers").html(data.link);
						return;
					} else if (data.form == 'Producto') {
						$("#table").html("");
						$.each(data.datos,function(index,value){
							if (value.status == "DISPONIBLE") {
								color = 'blue';
							} else if (value.status == 'AGOTADO'){
								color = 'red';
							} else if (value.status == 'SOBRESTOCK') {
								color = 'orange';
							}
							$("#table").append("<tr class='white-text "+color+"'><td style='display: none' width='5%'>"+value.id+"</td><td width='10%'>"+value.codigoBarras+
								"</td><td width='30%'>"+value.nombreProducto+"</td><td width='15%'>"+value.nombreProveedor+
								"</td><td width='8%'>"+value.stActual+"</td><td width='8%'>"+value.venta+
								"</td><td width='10%'>"+value.nombreCategoria+"</td></td><td style='display: none' width='10%'>"+value.proveedor+
								"</td><td style='display: none' width='5%'>"+value.stMin+"</td><td style='display: none' width='5%'>"+value.stMax+
								"</td><td style='display: none' width='5%'>"+value.compra+"</td><td style='display: none' width='5%'>"+value.categoria+
								"</td><td width='5%'>"+value.status+
								"</td><td><button type='button' class='icon-editar btn green lighten-1 btnEditar'></button>\
								</td></tr>"
							).show('fold',1000);
						});
						$("#page-numbers").html(data.link);
						return;
					} else if (data.form == 'Cliente') {
						$("#table").html("");
						$.each(data.datos,function(index,value){
							$("#table").append("<tr><td style='display: none' width='5%'>"+value.id+
								"</td><td width='8%'>"+value.rfc+"</td><td width='15%'>"+value.nombreEmpresa+
								"</td><td width='15%'>"+value.nombreCliente+"</td><td width='15%'>"+value.apellidos+
								"</td><td width='25%'>"+value.direccion+"</td><td width='8%'>"+value.ciudad+
								"</td><td width='8%'>"+value.estado+"</td><td width='5%'>"+value.telefono+
								"</td><td style='display: none' width='5%'>"+value.celular+"</td><td style='display: none' width='5%'>"+value.email+
								"</td><td style='display: none' width='5%'>"+value.colonia+
								"</td><td style='display: none' width='5%'>"+value.calle+"</td><td style='display: none' width='5%'>"+value.numero+
								"</td><td style='display: none' width='5%'>"+value.apellidoPaterno+"</td><td style='display: none' width='5%'>"+value.apellidoMaterno+
								"</td><td><button type='button' class='icon-info btn blue btnMostrar'></button></td>\
								<td><button type='button' class='icon-editar btn green lighten-1 btnEditar'></button>\
								</td></tr>"
							).show('fold',1000);
						});
						$("#page-numbers").html(data.link);
						return;
					} else if (data.form == 'Retiro') {
						$("#table").html("");
						$.each(data.datos,function(index,value){
							$("#table").append("<tr><td style='display: none' width='5%'>"+value.id+
								"</td><td width='15%'>"+value.folio+"</td><td width='25%'>"+value.empleado+
								"</td><td width='15%'>"+value.cantidad+"</td><td width='25%'>"+value.descripcion+
								"</td><td width='15%'>"+global.formatoFecha(value.fecha)+
								"</td><td style='display: none' width='15%'>"+value.fecha+
								"</td><td><button type='button' class='icon-editar btn green lighten-1 btnEditar'></button>\
								</td></tr>"
							).show('fold',1000);
						});
						$("#page-numbers").html(data.link);
						return;
					} else if (data.form == 'detalleVenta') {
						$("#table").html("");
						$.each(data.datos,function(index,value){
							$("#table").append("<tr><td width='20%'>"+value.id+
								"</td><td width='35%'>"+value.nombre+"</td><td width='10%'>"+value.cantidad+
								"</td><td width='15%'>"+value.precio+"</td><td width='20%'>"+value.subtotal+
								"</td></tr>"
							).show('fold',1000);
						});
						$("#page-numbers").html(data.link);
						return;
					} else if (data.form == 'Editorial' || data.form == 'Autor') {
						$("#table").html("");
						$.each(data.datos,function(index,value){
							$("#table").append("<tr><td width='25%'>"+value.codigo+"</td><td width='50%'>"+value.nombre+
								"</td><td><button type='button' class='icon-editar btn green lighten-1 btnEditar'></button>\
								<button type='button' class='icon-borrar btn red btnDelete'></button>\
								</td></tr>"
							).show('fold',1000);
						});
						$("#page-numbers").html(data.link);
					}
				}
			},
			error: function(xhr,ajaxOptions,throwError){
				if (xhr.status == 404) {
					global.mensajesError('Error','Ocurrio un error');
				}
			},
		});
	},
		//RECUPERAMOS EL CORTE DE CAJA
	Corte: function(url,opc){
		$.ajax({
			cache: false,
			type: "POST",
			dataType: "json",
			data: {opc:opc},
			url: url,
			success:function(respuesta){
				//console.log(respuesta);
				if (respuesta.codRetorno == '001')  {
					global.mensajes('Advertencia',respuesta.mensaje,'warning','','','Venta',1);
				} else if (respuesta.ingreso == null || respuesta.egreso == null) {
					global.mensajes('Advertencia','No hay movimientos registrados en el día','warning','','','Venta',1);
				} else {
					total = respuesta.ingreso - respuesta.egreso;
					$("#ingreso").val(respuesta.ingreso);
					$("#egreso").val(respuesta.egreso);
					$("#total").val(total);
					$("#tabla").append("<tr><td width='10%'>$"+respuesta.ingreso+"</td><td width='10%'>$"+respuesta.egreso+
						"</td><td width='10%'>$"+total+"</td></tr>"
					);
				}
			},
			error: function(xhr,ajaxOptions,throwError){
				if (xhr.status == 404) {
					global.mensajesError('Error','Ocurrio un error');
				}
			},
		});
	},
		//VALIDAMOS LA SESSIÓN
	validaSesion: function(){
		$.ajax({
			cache: false,
			type: "POST",
			dataType: "json",
			url: 'php/actualizaSesion.php',
			success: function(response) {
				if (response.codRetorno == '003') {
					global.cerrarSesion(response.mensaje);
				}
			},
			error: function(xhr,ajaxOptions,throwError){
				if (xhr.status == 404) {
					global.mensajesError('Error','Ocurrio un error');
				}
			}
		});
	},
		//FUNCIÓN PARA CERRAR SESIÓN
	cerrarSesion: function(titulo) {
		swal({
			title: titulo,
			type: 'warning',
			confirmButtonColor: '#3085d6',
			cancelButtonColor: '#d33',
			confirmButtonText: 'Ok',
			allowEscapeKey: false,
			allowOutsideClick: false,
			showLoaderOnConfirm: true,
		}).then(function() {
			sessionStorage.clear();
			window.open('index.html','_top');
		});
	},
		//FUNCIÓN PARA ACEPTAR SOLO LETRAS
	letras: function(evt){
		var charCode = evt.which || evt.keyCode;
        var str = String.fromCharCode(charCode);
		var expreg = /^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]*$/;

		if(!str.match(expreg) && charCode != 13){
			sweetAlert(
				'Alerta...',
				'Solo se Permiten Letras!',
				'warning'
			)
			return false;
		} else {
			return true;
		}
	},
		//FUNCIÓN PARA ACEPTAR SOLO NÚMEROS Y LETRAS
	numerosLetrasSig: function(evt){
		var charCode = evt.which || evt.keyCode;
	    var str = String.fromCharCode(charCode);
		var expreg = /^[a-zA-Z0-9\.\-\_\t\b\s]*$/;

		if(!str.match(expreg) && charCode != 13){
			sweetAlert(
				'Alerta...',
				'No se Permiten Caracteres Especiales!',
				'warning'
			)
			return false;
		} else {
			return true;
		}
	},
		//FUNCIÓN PARA ACEPTAR SOLO NÚMEROS Y LETRAS
	numerosLetras: function(evt){
		var charCode = evt.which || evt.keyCode;
	    var str = String.fromCharCode(charCode);
		var expreg = /^[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\t\b\s]*$/;

		if(!str.match(expreg) && charCode != 13){
			sweetAlert(
				'Alerta...',
				'No se Permiten Caracteres Especiales!',
				'warning'
			)
			return false;
		} else {
			return true;
		}
	},
		//FUNCIÓN PARA ACEPTAR SOLO NÚMEROS Y LETRAS
	numeros: function(evt){
		var charCode = evt.which || evt.keyCode;
	    var str = String.fromCharCode(charCode);
		var expreg = /^[0-9\.]*$/;

		if(!str.match(expreg) && charCode != 13){
			sweetAlert(
				'Alerta...',
				'Solo se Permiten Números!',
				'warning'
				)
			return false;
		} else {
			return true;
		}
	},
		//FUNCIÓN PARA VALIDAR E-MAILS
	validarEmail: function( email ) {
		expr = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
		if ( !expr.test(email) ){
			return false;
		} else {
			return true;
		}
	},
		//FUNCIÓN VALIDAR RFC DE 12 O 13 DIGITOS
	validaRFC: function(rfcStr) {
		var strCorrecta;
		strCorrecta = rfcStr;

		if (rfcStr.length == 12){
			var valid = '^(([A-Z]|[a-z]){3})([0-9]{6})((([A-Z]|[a-z]|[0-9]){3}))';
		} else {
			var valid = '^(([A-Z]|[a-z]|\s){1})(([A-Z]|[a-z]){3})([0-9]{6})((([A-Z]|[a-z]|[0-9]){3}))';
		}
		var validRfc = new RegExp(valid);
		var matchArray = strCorrecta.match(validRfc);

		if (matchArray == null) {
			return false;
		} else {
			return true;
		}
	},
		//FUNCIÓN PARA LIMPIAR CADENA DE ACENTOS
	getCleanedString: function(cadena){
			// Definimos los caracteres que queremos eliminar
		var specialChars = "!@#$^&%*()+=-[]\/{}|:<>?,.";
			// Los eliminamos todos
		for (var i = 0; i < specialChars.length; i++) {
		   cadena = cadena.replace(new RegExp("\\" + specialChars[i], 'gi'), '');
		}
			// Lo queremos devolver limpio en minusculas
		cadena = cadena.toLowerCase();
			// Quitamos espacios y los sustituimos por _ porque nos gusta mas asi
		cadena = cadena.replace(/ /g,"");
			// Quitamos acentos y "ñ". Fijate en que va sin comillas el primer parametro
		cadena = cadena.replace(/á/gi,"a");
		cadena = cadena.replace(/é/gi,"e");
		cadena = cadena.replace(/í/gi,"i");
		cadena = cadena.replace(/ó/gi,"o");
		cadena = cadena.replace(/ú/gi,"u");
		cadena = cadena.replace(/ñ/gi,"n");

		return cadena;
	},
		//FUNCIÓN PARA BUSCRA DATOS
	buscar: function(url,opc,buscar,tipo){
		var retorno = {};
		var parametros = 'partida='+1+'&codigo='+buscar+'&busqueda='+tipo;

		$.ajax({
			cache: false,
			type: "POST",
			dataType: "json",
			async: false,
			data: {opc: opc,parametros},
			url: 'php/Controllers/'+url+'.php',
			timeout: 200,
			success: function(response) {
				if(response.codRetorno == '000') {
					retorno = response;
				} else if (response.codRetorno == '001') {
					global.mensajes('Advertencia',response.mensaje,'warning',response.url);
				} else if (response.codRetorno == '002') {
					global.mensajes('Error',response.mensaje,'warning');
				} else if (response.codRetorno == '003') {
					global.cerrarSesion(response.mensaje);
				}
			},
			error: function(xhr,ajaxOptions,throwError){
				if (xhr.status == 404) {
					global.mensajesError('Error','Ocurrio un error','');
				}
			}
		});
		return retorno;
	},
		//FUNCIÓN VALIDA SI EXISTE LA IMÁGEN
	existeUrl: function(url) {
		var retorno = {};
		var http = new XMLHttpRequest();
		http.open('HEAD', url, false);
		http.send();
		if (http.status == 404) {
			return retorno = false;
		} else {
			return retorno = true;
		}
	},
	    //FUNCIÓN SUBIR IMAGEN
    subirimagen: function(nombre){
		var retorno = {};
		var name = nombre
		name = name.replace( /\s/g, "");
		name = global.remove_accent(name);
		var inputFileImage = document.getElementById('imagen');
		var file = inputFileImage.files[0];
		var data = new FormData();
		data.append('archivo',file);
		data.append('name',name);

        $.ajax({
            cache: false,
            url: 'php/img.php',
            dataType: 'json',
            type: "POST",
            async: false,
            data: data,
            contentType: false,
            processData: false,
            success: function(response) {
                if (response.codRetorno == '000') {
                	retorno = codRetorno = true;
                    console.log("imagen subida correctamente");
				} else {
					retorno = codRetorno = false;
				}
            }
        });
        return retorno;
    },
    	//FUNCIÓN PARA REMOVER ACENTOS
	remove_accent: function(str) {
		var map = {'À':'A','Á':'A','Â':'A','Ã':'A','Ä':'A','Å':'A','Æ':'AE','Ç':'C','È':'E','É':'E','Ê':'E','Ë':'E','Ì':'I','Í':'I','Î':'I','Ï':'I','Ð':'D','Ñ':'N','Ò':'O','Ó':'O','Ô':'O','Õ':'O','Ö':'O','Ø':'O','Ù':'U','Ú':'U','Û':'U','Ü':'U','Ý':'Y','ß':'s','à':'a','á':'a','â':'a','ã':'a','ä':'a','å':'a','æ':'ae','ç':'c','è':'e','é':'e','ê':'e','ë':'e','ì':'i','í':'i','î':'i','ï':'i','ñ':'n','ò':'o','ó':'o','ô':'o','õ':'o','ö':'o','ø':'o','ù':'u','ú':'u','û':'u','ü':'u','ý':'y','ÿ':'y','Ā':'A','ā':'a','Ă':'A','ă':'a','Ą':'A','ą':'a','Ć':'C','ć':'c','Ĉ':'C','ĉ':'c','Ċ':'C','ċ':'c','Č':'C','č':'c','Ď':'D','ď':'d','Đ':'D','đ':'d','Ē':'E','ē':'e','Ĕ':'E','ĕ':'e','Ė':'E','ė':'e','Ę':'E','ę':'e','Ě':'E','ě':'e','Ĝ':'G','ĝ':'g','Ğ':'G','ğ':'g','Ġ':'G','ġ':'g','Ģ':'G','ģ':'g','Ĥ':'H','ĥ':'h','Ħ':'H','ħ':'h','Ĩ':'I','ĩ':'i','Ī':'I','ī':'i','Ĭ':'I','ĭ':'i','Į':'I','į':'i','İ':'I','ı':'i','Ĳ':'IJ','ĳ':'ij','Ĵ':'J','ĵ':'j','Ķ':'K','ķ':'k','Ĺ':'L','ĺ':'l','Ļ':'L','ļ':'l','Ľ':'L','ľ':'l','Ŀ':'L','ŀ':'l','Ł':'L','ł':'l','Ń':'N','ń':'n','Ņ':'N','ņ':'n','Ň':'N','ň':'n','ŉ':'n','Ō':'O','ō':'o','Ŏ':'O','ŏ':'o','Ő':'O','ő':'o','Œ':'OE','œ':'oe','Ŕ':'R','ŕ':'r','Ŗ':'R','ŗ':'r','Ř':'R','ř':'r','Ś':'S','ś':'s','Ŝ':'S','ŝ':'s','Ş':'S','ş':'s','Š':'S','š':'s','Ţ':'T','ţ':'t','Ť':'T','ť':'t','Ŧ':'T','ŧ':'t','Ũ':'U','ũ':'u','Ū':'U','ū':'u','Ŭ':'U','ŭ':'u','Ů':'U','ů':'u','Ű':'U','ű':'u','Ų':'U','ų':'u','Ŵ':'W','ŵ':'w','Ŷ':'Y','ŷ':'y','Ÿ':'Y','Ź':'Z','ź':'z','Ż':'Z','ż':'z','Ž':'Z','ž':'z','ſ':'s','ƒ':'f','Ơ':'O','ơ':'o','Ư':'U','ư':'u','Ǎ':'A','ǎ':'a','Ǐ':'I','ǐ':'i','Ǒ':'O','ǒ':'o','Ǔ':'U','ǔ':'u','Ǖ':'U','ǖ':'u','Ǘ':'U','ǘ':'u','Ǚ':'U','ǚ':'u','Ǜ':'U','ǜ':'u','Ǻ':'A','ǻ':'a','Ǽ':'AE','ǽ':'ae','Ǿ':'O','ǿ':'o'};
		var res = '';
		for (var i = 0;i < str.length;i++){
			c = str.charAt(i);
			res+= map[c] || c;
		}
		//console.log(res);
		return res;
	},
		//FUNCIÓN PARA FORMATEAR PESOS
	formatearTotal: function(total) {
		total = '$'+total;
		return total;
	},
		//FUNCION PARA  OCULTAR MENÚ SEGÚN PERFIL
	isNotAdminMenu: function(perfil){
		if (perfil == "VENDEDOR") {
			$("#libros").hide();
			$("#autores").hide();
			$("#editoriales").hide();
			$("#productos").hide();
			$("#provedores").hide();
			$("#buscarProveedor").hide();
			$("#mEmpleado").hide();
			$("#mClientes").hide();
			$("#mMovimientos").hide();
			$("#btnNuevo").hide();
		} else if (perfil == "CAJERO") {
			$("#libros").hide();
			$("#autores").hide();
			$("#editoriales").hide();
			$("#productos").hide();
			$("#provedores").hide();
			$("#buscarProveedor").hide();
			$("#mEmpleado").hide();
			$("#mClientes").hide();
			$("#btnNuevo").hide();
		}
    },
		//FUNCIÓN PARA CARGAR EL SIG. FOLIO
	cargaFolio: function(url,opc){
		var retorno = {};
		$.ajax({
			cache: false,
			type: "POST",
			dataType: "json",
			async: false,
			url: url,
			data: {opc:opc},
			success: function(response){
				//console.log(response);
				if (response != 1) {
					$("#folio").val(response.folio);
					$("#nombreEmpleado").val(response.nombre);
					$("#codigoEmpleado").val(response.codigo);
				} else {
					global.mensajesError('Error','Contacte con el Administrador','',1);
				}
			},
			error: function(xhr,ajaxOptions,throwError){
				console.log(xhr+" "+throwError+" "+ajaxOptions);
			}
		});
	},
			//FUNCIÓN PARA OBTENER LA FECHA ACTUAL
	formatoFecha: function(fecha){
		var meses = new Array ("Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre");
		var day = parseInt(fecha.substr(0,2));
		var month = parseInt(fecha.substr(3,2));
		var year = parseInt(fecha.substr(6,4));
		var fechaActual = day + " de " + meses[parseInt(month)-1] + " de " + year;

		return fechaActual;
	},
		//FUNCIÓN PARA OBTENER LA FECHA ACTUAL
	obtenerFechaActual: function(){
		var meses = new Array ("Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre");
		var fecha = new Date();
		var fechaActual = fecha.getDate() + " de " + meses[fecha.getMonth()] + " de " + fecha.getFullYear()

		return fechaActual;
	},
		//
	imprimir: function(nombre) {
		var ficha = "Hola";
		var ventimp = window.open (' ', 'popimpr');
		ventimp.document.write( ficha.innerHTML );
		ventimp.document.close();
		ventimp.print( );
		ventimp.close();
	},
};
	// setInterval(function(){
	// 	global.validaSesion();
	// },10000);
$(document).ready(global);
