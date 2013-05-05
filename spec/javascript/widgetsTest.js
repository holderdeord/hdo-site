/*global HDO */

(function (H) {
  buster.testCase("widgets", {
    setUp: function () {
      H.widgets.baseUrl = "http://www.holderdeord.no/"
      this.element = document.createElement('div')
    },

    "should create issue URLs": function() {
      var widget = H.widgets.create('issue')
      this.element.setAttribute('data-issue-id', '1');

      assert.equals(widget.widgetOptionsFor(this.element).url,
        "http://www.holderdeord.no/issues/1/widget")
    },

    "should create party URLs": function() {
      var widget = H.widgets.create('party')
      this.element.setAttribute('data-party-id', 'a');

      assert.equals(widget.widgetOptionsFor(this.element).url,
        "http://www.holderdeord.no/parties/a/widget")
    },

    "should create representative URLs": function () {
      var widget = H.widgets.create('representative')

      this.element.setAttribute('data-representative-id', 'maaa')
      assert.equals(widget.widgetOptionsFor(this.element).url, "http://www.holderdeord.no/representatives/maaa/widget");

      this.element.setAttribute('data-issue-ids', '1,2,3')
      assert.equals(widget.widgetOptionsFor(this.element).url, "http://www.holderdeord.no/representatives/maaa/widget?issues=1%2C2%2C3");

      this.element.setAttribute('data-issue-ids', '')
      this.element.setAttribute('data-issue-count', '3')
      assert.equals(widget.widgetOptionsFor(this.element).url, "http://www.holderdeord.no/representatives/maaa/widget?count=3");
    },

    "should create topic URLs": function() {
      var widget = H.widgets.create('topic')
      this.element.setAttribute('data-issues', '1,2,3');
      this.element.setAttribute('data-promises', '101,101,102');

      assert.equals(widget.widgetOptionsFor(this.element).url,
        "http://www.holderdeord.no/widgets/topic?issues=1%2C2%2C3&promises=101%2C101%2C102")
    },

    "should create promises URL": function() {
      var widget = H.widgets.create('promises')
      this.element.setAttribute('data-promises', '101,101,102');

      assert.equals(widget.widgetOptionsFor(this.element).url,
        "http://www.holderdeord.no/promises/101%2C101%2C102/widget")
    },

  });
}(HDO));