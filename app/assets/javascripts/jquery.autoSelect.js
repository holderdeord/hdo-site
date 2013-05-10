(function ($) {
  $.fn.autoSelect = function () {
    return this.each(function () {
      var form = $(this),
          selects = form.find("select");
      selects.on("change", function () {
        form.trigger("submit");
      });
    });
  };
}(jQuery));