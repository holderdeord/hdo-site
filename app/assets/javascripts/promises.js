var HDO = HDO || {};

$(document).ready(function(){

  $('.categories').on('click',function(e){

    e.preventDefault();  
    
    var id = $(this).attr('id');

    $('#promisesBody').empty();
    $('#promisesBody').append('<div id="promisesResults"></div>');

    $.ajax({
        url : '/promises/category/' + id,
        success: function(data) {
          console.log(data);
          $("#promisesResults").html(data);
          $(".span3").css('border-right','solid 1px #EEE');
        }
    });
  });
  
});