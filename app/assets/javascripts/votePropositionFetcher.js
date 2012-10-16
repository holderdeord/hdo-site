/* global HDO */

(function (HDO) {
  HDO.votePropositionFetcher = {
    create: function () {
      var instance = Object.create(this);
      return instance;
    },

    init: function () {
      $(document.body).delegate('[data-vote-id]', 'click', function () {
        var voteId, target, spinner;

        voteId = $(this).data('vote-id');
        target = $('#proposition-body-' + voteId);

        target.toggle();

        if (target.data('fetched')) {
          return;
        }

        spinner = target.find(".spinner");
        spinner.show();

        $.ajax({
          url: "/votes/" + voteId + "/propositions",
          type: "GET",
          dataType: "html",

          complete: function () {
            spinner.hide();
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
