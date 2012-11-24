/*global HDO */

(function (H) {
  HDO.throttler = {
    create: function (timeout) {
      var instance = Object.create(this);
      instance.timeout = timeout;
      return instance;
    },

    queue: function (query, callback) {
      var self = this;
      clearTimeout(this.timer);

      this.timer = setTimeout(function () {
        delete self.timer;
        if (query !== self.lastQuery) {
          callback(query);
        }
        self.lastQuery = query;
      }, self.timeout);
    }
  };
}(HDO));
