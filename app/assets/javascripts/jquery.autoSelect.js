(function ($) {
  $.fn.autoSelect = function () {
    return this.each(function () {
      var form, selects;

      form = $(this);
      selects = form.find("select");

      selects.on("change", function () {
        form.trigger("submit");
      });
    });
  };
}(jQuery));