var HDO = HDO || {};

(function (H, $) {

  function toggleRepresentatives(ev) {
    if ($(ev.target).attr("href")) {
      // don't toggle if a link was clicked
      return;
    }

    var self = this,
      partySlug = $(ev.currentTarget).data('party-slug'),
      columnsToShow = $(self.columns).find("div[data-party-slug='" + partySlug + "-reps']");

    $(columnsToShow).each(function () {
      if ($(this).hasClass('hidden')) {
        $(this).removeClass('hidden');
      } else {
        $(this).addClass('hidden');
      }
    });
  }

  HDO.voteRowToggler = {
    create: function (params) {
      var instance = Object.create(this);
      instance.columns = params.columns;
      return instance;
    },

    init: function () {
      $(this.columns).on('click', 'div', toggleRepresentatives.bind(this));
    }
  };

}(HDO, jQuery));