var HDO = HDO || {};

(function (H, $) {
  HDO.votes = {
    create: function (params) {
      var instance = Object.create(this);
      instance.columns = params.columns;
      return instance;
    },

    init: function () {
      $(this.columns).on('click', 'p', function(){
        next_div = $(this).next();
        if( next_div.hasClass('hidden')) {
          next_div.removeClass('hidden');
        } else {
          next_div.addClass('hidden');
        }
      });
    }
  };

}(HDO, jQuery));