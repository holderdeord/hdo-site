define(["jquery"], function ($) {
  return {
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

      $("#keyword").keypress(function (e) {
        if (e.keyCode === 13) {
          e.preventDefault();
          $("#fetch-votes").click();
        }
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
});