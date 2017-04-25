$(document).ready(function(){
			//BLOQUEA CLICK DERCHO
	$(document).bind("contextmenu",function(e){
		return false;	
	});
		//BLOQUEA F12
	document.onkeypress = function (event) {
		event = (event || window.event);
		if (event.keyCode == 123) {
			return false;
		}
	}
		//BLOQUEA F12
	document.onmousedown = function (event) {
		event = (event || window.event);
		if (event.keyCode == 123) {
			return false;
		}
	}
		//BLOQUEA F12
	document.onkeydown = function (event) {
		event = (event || window.event);
		if (event.keyCode == 123) {
			return false;
		}
	}
});