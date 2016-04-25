
// $(function() {
$(document).on('ready page:load', function(){
			$("#school_search").autocomplete({
				delay: 500,
				minLength: 3,
				source: function(request, response) {
					$.getJSON("/school_info/find", {
						term: request.term
					}, function(data) {
						// data is an array of objects and must be transformed for autocomplete to use
						var array = data.error ? [] : $.map(data, function(m) {
							return {
								value: m.school_name,
								// label: m.id
							};
						});
						response(array);
					});
				},
				focus: function(event, ui) {
					// prevent autocomplete from updating the textbox
					// event.preventDefault();
				},
				select: function(event, ui) {

					// prevent autocomplete from updating the textbox
					// event.preventDefault();
					// navigate to the selected item's url
					// window.open(ui.item.url);
				}
			});

			$("#customer_vit_number").change(function(){
			    $.ajax({
						type: "GET",
						url: "/registration/vit_validation",
						async: false,
						data: { 'first_name':$( "#customer_first_name" ).val(), 'last_name':$( "#customer_last_name" ).val(), 'vit_number':$( "#customer_vit_number" ).val() },
						success: function(data) {	
							if (data == true){
								$("#customer_vit_number").css("background-color", "#55ff55");
							}
							else{
								$("#customer_vit_number").css("background-color", "pink");
							}
					    // for debug purposes
						// console.log(data);
						}
					});
			});
		});