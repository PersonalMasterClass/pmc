
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
					$("#school_id").val(ui.item.id)
					// prevent autocomplete from updating the textbox
					// event.preventDefault();
					// navigate to the selected item's url
					// window.open(ui.item.url);
				}
			});
			
			// clear out the subject ID field if the search field is cleared
			$("#school_search").blur(function() {
				if(!$(this).val()) {
					$("#school_id").val("");
				}
			});

			$("#vit_load_pic").hide();
			$("#failed_vit_validation_link").hide();

			$("#customer_vit_number,#presenter_vit_number, #customer_first_name, #customer_last_name, #presenter_first_name, #presenter_last_name").change(function(){				
				$("#vit_load_pic").show();
				$("#failed_vit_validation_link").hide();
			    $.ajax({
						type: "GET",
						url: "/registration/vit_validation",
						async: true,
						data: { 'first_name':$( "#customer_first_name, #presenter_first_name" ).val(), 'last_name':$( "#customer_last_name, #presenter_last_name" ).val(), 'vit_number':$( "#customer_vit_number, #presenter_vit_number" ).val() },
						success: function(data) {
								if (data == true){
									$("#customer_vit_number, #presenter_vit_number").css("background-color", "#55ff55");
								}
								else{
									$("#customer_vit_number, #presenter_vit_number").css("background-color", "pink");
									$("#failed_vit_validation_link").show();
								}
								$("#vit_load_pic").hide();
						}
					});
			});
});