var HDO = HDO || {};
(function (H, $, _) {
  H.xhrModal = function (element, options) {
    var button, url, target;

    button = $(element);
    url    = button.attr("data-modal-url");
    target = $(button.attr("href"));

    button.on('click', function () {
      $('body').modalmanager('loading');

      target.load(url, '', function () {
        target.modal($.extend({}, options));
      });
    });
  };
}(HDO, window.jQuery));
