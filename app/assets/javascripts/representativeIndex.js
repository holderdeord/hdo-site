/* global HDO, jQuery */

(function (HDO, $) {

  HDO.representativeIndex = {
    create: function (options) {
      var instance = Object.create(this);
      instance.options = options;
      instance.cache = [];

      return instance;
    },

    init: function () {
      var self = this;

      $(this.options.sortSelector).change(function () {
        var val = $(this).val(),
          path = self.options.paths[val];

        if (!path) {
          throw new Error('invalid sort value:' + val);
        }

        self.fetchAndRender(path);
      });
    },

    fetchAndRender: function (path) {
      var resultElement, cache;

      resultElement = $(this.options.resultSelector);
      cache = this.cache;

      if (cache[path]) {
        resultElement.html(this.cache[path]);
        return;
      }

      $("#spinner").show();

      $.ajax({
        url: path,
        type: "GET",
        dataType: "html",

        complete: function () {
          $("#spinner").hide();
        },

        success: function (html) {
          cache[path] = html;
          resultElement.html(html);
        },

        error: function () {
          resultElement.html(arguments.toString());
        }
      });
    }

  };
}(HDO, jQuery));

