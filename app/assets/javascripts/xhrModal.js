var HDO = HDO || {};
(function (H, $, _) {
  H.xhrModal = function (element, options) {
    var button = $(element);

    var url    = button.attr("data-modal-url");
    var target = $(button.attr("href"));

    button.on('click', function(){
      $('body').modalmanager('loading');

      target.load(url, '', function() {
        target.modal($.extend({}, options));
      });
    });
  };
}(HDO, window.jQuery));
