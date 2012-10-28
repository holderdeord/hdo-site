/*global HDO */

(function (H) {
  HDO.requestThrottler = {
    create: function (callback, timeout) {
      var instance = Object.create(this);
      instance.timeout = timeout;
      instance.callback = callback;
      return instance;
    },

    queue: function (query) {
      var self = this;
      clearTimeout(this.timer);

      this.timer = setTimeout(function () {
        delete self.timer;
        if (query !== self.lastQuery) {
          self.callback(query);
        }
        self.lastQuery = query;
      }, self.timeout);
    }
  };
}(HDO));
