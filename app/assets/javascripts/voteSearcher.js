/* global HDO */

(function (HDO) {
  HDO.voteSearcher = {
    create: function (url) {
      var instance = Object.create(this);
      instance.url = url;
      return instance;
    },

    init: function () {
      var self = this;

      $('#reset').click(function () {
        $("#result").html('');
        $("#filter").val('selected-categories');
        $("#keyword").val('');

        return false;
      });

      $('#fetch-votes').click(function () {
        var params = {
          keyword: $('#keyword').val(),
          filter: $('#filter').val()
        };

        $("#result").html('');
        $("#spinner").show();

        self.loadVotes(params);

        return false;
      });
    },

    loadVotes: function (params) {
      $.ajax({
        url: this.url,
        type: "GET",
        dataType: "html",
        data: $.param(params),

        complete: function () {
          $("#spinner").hide();
        },

        success: function (html) {
          $("#result").html(html);
        },

        error: function (err) {
          $("#result").html(err);
        }
      });
    }
  };
}(HDO));
