/*global HDO, cull */

(function (H, cull) {
  var input = cull.dom.el.input;
  var form = cull.dom.el.form;
  var div = cull.dom.el.div;
  buster.testCase("Search", {
    setUp: function () {
      this.input = input();
      this.clock = sinon.useFakeTimers();
      this.resultElement = div();
      this.server = {
        search: this.spy()
      };

      this.searcher = HDO.search.create({
        input: this.input,
        resultElement: this.resultElement,
        server: this.server
      });
      this.searcher.init();
    },

    "should contact server after 300ms": function () {
      this.input.value = "s";
      $(this.input).trigger("keyup");
      this.clock.tick(150);

      this.input.value = "sk";
      $(this.input).trigger("keyup");
      this.clock.tick(150);

      this.input.value = "ska";
      $(this.input).trigger("keyup");
      this.clock.tick(300);

      assert.calledOnceWith(this.server.search, "ska");
    },

    "should insert result in resultElement": function () {
      this.server.search = this.stub();

      this.input.value = "ska";
      $(this.input).trigger("keyup");
      this.clock.tick(300);

      this.server.search.yield("LOL");
      assert.equals(this.resultElement.innerHTML, "LOL");
    }
  });
}(HDO, cull));
