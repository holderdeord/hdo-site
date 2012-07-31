/* global HDO */

(function(HDO) {
  HDO.voteSearcher = {
    create: function(url) {
      var instance = Object.create(this);
      instance.url = url;
      return instance;
    },

    init: function() {
      var self = this;

      $('#reset').click(function() {
        $("#result").html('');
        return false;
      })

      $('#fetch-votes').click(function() {
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

    loadVotes: function(params) {
      $.ajax({
        url: this.url,
        type: "GET",
        dataType: "html",
        data: $.param(params),

        complete: function() {
          $("#spinner").hide();
        },

        success: function(html) {
          $("#result").html(html)
        },

        error: function() {
          $("#result").html(arguments[0]);
        },
      });
    }
  };
}(HDO));
