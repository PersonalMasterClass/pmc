
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

			$("#customer[first_name]").change(function(){
			    $.ajax({
			      url: '../services/vit_validation.rb',
			      success: function(data){
			          $("#floors_select").html(data);
			      }
			    });

			});

			//frank func

		});