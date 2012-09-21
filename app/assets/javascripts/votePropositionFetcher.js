/* global HDO */

(function (HDO) {
  HDO.votePropositionFetcher = {
    create: function () {
      var instance = Object.create(this);
      return instance;
    },

    init: function () {
      $(document.body).delegate('[data-vote-id]', 'click', function () {
        var voteId, target;

        voteId = $(this).data('vote-id');
        target = $('#proposition-body-' + voteId);

        target.toggle();

        if (target.data('fetched')) {
          return;
        }

        $.ajax({
          url: "/votes/" + voteId + "/propositions",
          type: "GET",
          dataType: "html",

          complete: function () {
          },

          success: function (data) {
            target.data('fetched', true);
            target.html(data);
          },

          error: function () {
            target.html('Feil under henting av forslagstekst.');
          }
        });
      });
    }
  };
}(HDO));
