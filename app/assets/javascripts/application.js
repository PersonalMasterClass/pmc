// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require bootstrap-sprockets
//= require turbolinks
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require jquery-ui/autocomplete
//= require best_in_place
//= require best_in_place.jquery-ui
//= require datatables-lib
//= require_tree .
$(document).on('ready page:load', function(){
	var url = window.location.pathname;
	alert(url);
	$('.list-group').on("click",'a', function(event) {    
		// $(this).parent().children().find(".active").removeClass("active")
		$(this).addClass("list-group-item active");
	});
});