/*global HDO */

(function (H, $) {

  function insertResult(html) {
    this.resultElement.innerHTML = html;
  }

  HDO.search = {
    create: function (params) {
      var instance = Object.create(this);
      instance.input = params.input;
      instance.resultElement = params.resultElement;
      instance.server = params.server;
      return instance;
    },

    init: function () {
      this.throttler = HDO.requestThrottler.create(this.contactServer.bind(this), 300);

      $(this.input).on("input keyup", this.throttleRequest.bind(this));
    },

    throttleRequest: function () {
      this.throttler.queue(this.getValue());
    },

    getValue: function () {
      return this.input.value;
    },

    contactServer: function (query) {
      this.server.search(query, insertResult.bind(this));
    }
  };
}(HDO, jQuery));
