var HDO = HDO || {};

$(document).ready(function(){
  var categoryId;
  var results;

   function getData(catId) {
    $.ajax({
      url: '/promises/category/'+ catId,
      success: function(data){
        setResults(data);
      }
    });
  }

  function setResults(data) {
    results = data;
  }

  function getResults(){
    return results;
  }
 
  function showAllPromisesInCategory(divId, catId) {

    getData(catId);
    setTimeout(function(){
      $('#' + divId).html(results);
      $('.categories').css('border-right','solid 1px #EEE');
    },100)
  }

  function showSpecificParty(divId, catId, partyId) {
    $('#' + divId).empty();
    
    if(partyId != "showAll") {
      $('#' + divId).append(results).css('display','none');

      $('#'+divId + ' div').each(function() {
        if($(this).attr('id') != partyId){
          $(this).hide();
        }
      });
      $('#' + divId).css('display', 'block');
    }
    else {
      showAllPromisesInCategory(divId,catId);
    }
  }

  function removeActiveClass(divClass) {
    $('.' + divClass).find('li').removeClass('active');
  }

  
  $('.categories a').on('click',function(e) {
    
    removeActiveClass("categories");
    $(this).parent().addClass('active');
    
    removeActiveClass("party-nav");
    $('#showAll').parent().addClass('active');
    
    $('#promisesBody').empty();
    $('#promisesBody').append('<div id="promisesResults"></div>');

    categoryId = $(this).attr('id');

    showAllPromisesInCategory("promisesResults", categoryId);
        
    e.preventDefault();  
    return false;
  
  });

  
  $('.party-nav a').on('click', function(e) {
    removeActiveClass("party-nav");
    $(this).parent().addClass('active');
    showSpecificParty("promisesResults" , categoryId, $(this).attr('id'));
    
    e.preventDefault();
    return false;
  });

});