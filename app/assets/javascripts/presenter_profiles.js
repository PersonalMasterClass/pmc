$(document).on('ready page:load', function(){

  if($("#profile_bio_edit")){
    alert($("#profile_bio_edit").html())
    $("#profile_bio_edit").html( 
      diffString(
        $("#profile_bio").html(),
        $("#profile_bio_edit").html()
      )
    );
  }
});