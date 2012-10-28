/*global HDO */

(function (H) {
  buster.testCase("Throttler", {
    setUp: function () {
      this.callback = this.spy();
      this.throttler = H.throttler.create(100);
      this.clock = sinon.useFakeTimers();
    },


    "should make request after minimum timeout": function () {
      this.throttler.queue("LOL", this.callback);
      this.clock.tick(100);

      assert.calledOnceWith(this.callback, "LOL");
    },

    "should not make request before minimum timeout": function () {
      this.throttler.queue("LOL", this.callback);
      this.clock.tick(99);

      refute.called(this.callback);
    },

    "should clear previous requests": function () {
      this.throttler.queue("LOL", this.callback);
      this.clock.tick(99);
      this.throttler.queue("ROFL", this.callback);
      this.clock.tick(150);

      assert.calledOnceWith(this.callback, "ROFL");
    },

    "should discard equal requests": function () {
      this.throttler.queue("LOL", this.callback);
      this.clock.tick(150);

      this.throttler.queue("LOL", this.callback);
      this.clock.tick(150);

      assert.calledOnceWith(this.callback, "LOL");
    }
  });
}(HDO));