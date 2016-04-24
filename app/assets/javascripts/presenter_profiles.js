$(document).on('ready page:load', function(){
	var id_val
			$("#subject_select").autocomplete({
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
								id: m.id
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
					$("#subject_id").val(ui.item.id)
					// prevent autocomplete from updating the textbox
					// event.preventDefault();
					// navigate to the selected item's url
					// window.open(ui.item.url);
				}
			});
		});