/*!
 * jQuery DG Magnet Combo 1.2
 * http://www.digitss.com/
 * http://blogs.digitss.com/projects/jquery-plugins/
 *
 * Uses and works with jQuery.js
 * http://jquery.com/
 * Copyright 2011, DiGiTSS
 * Released under the MIT, BSD, and GPL Licenses.
 *
 * Initial Release Date: Mon Jan 26 2011
 * Last Updated Date: Sat Feb 12 2011
 */
// TODO: Make it work with Shift key naturally
jQuery.fn.extend({
dgMagnetCombo: function()
{
  $.each($(this), function(){
    $(this).buildMagnetCombo();
  });
}
,
buildMagnetCombo: function()
{
  var bControlPress; // Maintain Control state  
  var dataKey = "data_" + $(this).attr("id");
  $(this).data("dgVal", $(this).val() || []); // Set selected values on load if any (reported by fflavio)
  $(this).click( function()
  {
    var sTop  = this.scrollTop;
    var oVal  = $(this).data("dgVal") || [];
    var nVal  = $(this).val();

    if(bControlPress != true)
    {     
      if(nVal.length > 0)
      {
        var cValIndex = $.inArray(nVal[0],oVal);
        if(cValIndex > -1)
        {
          oVal.splice(cValIndex,1);
        }
        else
        {
          oVal.push(nVal[0]);
        }
      }
      $(this).data("dgVal",oVal).val(oVal);
    }
    else
    { // This makes it work with CTL key
      if(oVal.length > 0)
      { 
        $.each(oVal, function(index, value){
          if($.inArray(value, nVal) < 0)
          {
            oVal.splice(index, 1);
          }
        });
        $(this).data("dgVal",oVal);
      }
    }
    this.scrollTop = sTop;
    return false;
  });

  $(this).keydown(function(e)
  {
    if(e.which == 17 || e.which == 16 || e.which == 18) // CTL, Shift Key check
    {
      bControlPress = true;
    }
    return true;
  });
  
  $(this).keyup( function(e)
  {
    var sTop  = this.scrollTop;

    if(e.which == 17 || e.which == 16 || e.which == 18) // CTL, Shift Key check
    {
      var oVal = $(this).data(dataKey) || [];
      if(oVal.length > 0)
      {
        $.each($(this).val(), function(index, value)
        {
          if($.inArray(value, oVal) < 0)
          {
            oVal.push(value);
          }
        });
        $(this).val(oVal);
      }
      bControlPress = false;
    }
    else
    {   
      if(!(e.which >= 37 && e.which <= 40)) // To make Up and Down arrow work
      {
        //$(this).click();
      }
      else
      {     
        $(this).val($(this).data(dataKey));
      }
    }
    this.scrollTop = sTop;
    return true;
  });
}
});