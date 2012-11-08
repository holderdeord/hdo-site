define(["jquery", "twitter/bootstrap"], function ($) {

  function clearInput() {
    $(this).val("");
  }

  return {

    init: function (element, data) {
      var source = this.parse(data);
      // uses lib/bootstrap-typeahead.js, extension to regular bootstrap
      $(element).typeahead({
        source: source,
        itemSelected: function (item, val, text) {
          document.location = "/representatives/" + val;
        }
      });

      $(element).on("focus", clearInput);
    },

    parse: function (data) {
      return $.map(data, function (obj) {
        return {
          id: obj.slug,
          name: [obj.first_name, obj.last_name].join(" ")
        };
      });
    }
  };
});
