 $(document).on('ready page:load', function(){
 	jQuery(".best_in_place").best_in_place();
 // make the day buttons green when you click them
 	$('.keyContactToggle').click(function (e) {
 		if ( ($(this).is('.btn')) && ($(this).is('.keyContactToggle')) && !($(this).is('.btn-success')) ) {
   		$(this).addClass('btn-success');
 		} else {
   			$(this).removeClass('btn-success');

		 }

	});
}); 