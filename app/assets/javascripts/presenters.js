$(document).on('ready page:load', function(){
			$("#subject_search").autocomplete({
				delay: 500,
				minLength: 2,
				source: function(request, response) {
					$.getJSON("/subjects/find", {
						term: request.term
					}, function(data) {
						// data is an array of objects and must be transformed for autocomplete to use
						var array = data.error ? [] : $.map(data, function(m) {
							return {
								value: m.name,
								
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
					$("#add_subject_form").submit()
					// prevent autocomplete from updating the textbox
					// event.preventDefault();
					// navigate to the selected item's url
					// window.open(ui.item.url);
				}
			});
		});