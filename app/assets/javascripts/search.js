$(document).on('ready page:load', function(){
	var id_val
	$("#subject_select").autocomplete({
		delay: 500,
		minLength: 1,
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
		}
	});
	// clear out the subject ID field if the search field is cleared
	$("#subject_select").blur(function() {
		if(!$(this).val()) {
			$("#subject_id").val("");
		}
	});

	$("#subject_select").keydown(function(){
		$("#subject_select").css("background-color", "");
	})

	// validation - can't search without a subject.
	$("#search_form").submit(function(e){
		if(!$("#subject_id").val()){
			e.preventDefault();
			$("#subject_select").css("background-color", "pink").focus();
		}
	})

});	