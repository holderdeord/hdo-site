var HDO = HDO || {};


$(document).ready(function() {
  $('.accordion-inner').click(function(){
    $('#warning').append('Velg et parti for å se deres løfter innenfor valgt tema.');  
    $('#what').load('topics/1');
    $('#warning').empty();
    return false;

  });

  $('#logos').click(function(){
    //TODO: Get promises for specific party
    return false;
  });

});
