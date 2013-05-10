function create(element) {
  return $(document.createElement(element));
}

(function ($) {
  buster.testCase('Auto Select from form', {
    setUp: function () {
      // setup dom
      var select = create("select");
      var form = create("form").append(select);
      $("body").append(form);

      // setup spy
      this.submitSpy = sinon.spy();
      form.on("submit", function (e) {
        e.preventDefault();
        this.submitSpy();
      }.bind(this));

      // run function
      form.autoSelect();
    },

    tearDown: function () {
      $("body").remove();
    },

    "it should trigger form on event onchange": function () {
      var select = $("select");
      select.trigger("change");

      assert(this.submitSpy.called);
    }
  });
}(jQuery));