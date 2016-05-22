$(document).on('ready page:load', function(){
  if ($('#customers_table')){
    $('#customers_table').DataTable();
  }
  if ($('#presenters_table')){
    $('#presenters_table').DataTable();
  }
  if ($('#bookings_table')){
    $('#bookings_table').DataTable();
  }
});